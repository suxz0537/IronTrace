import {
  getPendingSession,
  getAllExercises,
  updateSet,
  removeSet,
  addExerciseToSession,
  finishSession,
  genId,
  calcSessionVolume,
  saveSession
} from '../../utils/storage'
import { formatDate, formatVolumeKg } from '../../utils/helpers'
import '../../utils/constants'
import type { Exercise, WorkoutSession, WorkoutSet } from '../../types/index'
import type { PageData, PageMethods } from '../../types/app'

interface GroupedSet {
  exerciseId: string
  exerciseName: string
  sets: Array<WorkoutSet & { volume: string }>
}

interface TrainingDetailPageData extends PageData {
  sessionId: string
  startTimeStr: string
  totalVolumeStr: string
  totalSets: number
  groupedSets: GroupedSet[]
  note: string
  isEmpty: boolean
  statusBarHeight: number
}

interface TrainingDetailPageMethods extends PageMethods {
  loadSession: () => void
  buildGroupedSets: (session: WorkoutSession, exercises: Exercise[]) => void
  onWeightChange: (e: WechatMiniprogram.CustomEvent) => void
  onRepsChange: (e: WechatMiniprogram.CustomEvent) => void
  onWarmupChange: (e: WechatMiniprogram.CustomEvent) => void
  onRpeChange: (e: WechatMiniprogram.CustomEvent) => void
  onAddSet: (e: WechatMiniprogram.CustomEvent) => void
  onRemoveSet: (e: WechatMiniprogram.CustomEvent) => void
  onGoAddExercise: () => void
  onNoteChange: (e: WechatMiniprogram.CustomEvent) => void
  onFinishSession: () => void
  onBack: () => void
}

Page<TrainingDetailPageData, TrainingDetailPageMethods, WechatMiniprogram.Page.CustomOption>({
  data: {
    sessionId: '',
    startTimeStr: '',
    totalVolumeStr: '0 kg',
    totalSets: 0,
    groupedSets: [],
    note: '',
    isEmpty: true,
    statusBarHeight: 20
  },

  onLoad() {
    const sysInfo = wx.getWindowInfo()
    this.setData({ statusBarHeight: sysInfo.statusBarHeight ?? 20 })
    this.loadSession()
  },

  onShow() {
    this.loadSession()
  },

  loadSession() {
    const app = getApp<IAppOption>()
    let session: WorkoutSession | null = app.globalData.pendingSession

    if (!session) {
      session = getPendingSession()
    }

    if (!session) {
      wx.showToast({ title: '未找到训练数据', icon: 'none' })
      setTimeout(() => wx.navigateBack(), 1000)
      return
    }

    app.globalData.pendingSession = session
    const exercises = app.globalData.exercises?.length > 0
      ? app.globalData.exercises
      : getAllExercises()

    this.setData({
      sessionId: session._id,
      startTimeStr: formatDate(session.startTime),
      note: session.note ?? ''
    })

    this.buildGroupedSets(session, exercises)
  },

  buildGroupedSets(session: WorkoutSession, exercises: Exercise[]) {
    const exerciseMap = new Map<string, Exercise>()
    exercises.forEach(ex => exerciseMap.set(ex._id, ex))

    const groupsMap = new Map<string, WorkoutSet[]>()
    session.sets.forEach(set => {
      const list = groupsMap.get(set.exerciseId) ?? []
      list.push(set)
      groupsMap.set(set.exerciseId, list)
    })

    const groupedSets: GroupedSet[] = []
    groupsMap.forEach((sets, exerciseId) => {
      const exercise = exerciseMap.get(exerciseId)
      const exerciseName = exercise?.name ?? '未知动作'
      const sortedSets = [...sets].sort((a, b) => a.setNo - b.setNo)
      groupedSets.push({
        exerciseId,
        exerciseName,
        sets: sortedSets.map(s => ({
          ...s,
          volume: formatVolumeKg((s.isWarmup ? 0 : s.weight) * s.reps)
        }))
      })
    })

    const totalVolume = calcSessionVolume(session)
    this.setData({
      groupedSets,
      totalVolumeStr: formatVolumeKg(totalVolume),
      totalSets: session.sets.length,
      isEmpty: groupedSets.length === 0
    })
  },

  onWeightChange(e: WechatMiniprogram.CustomEvent) {
    const setId = e.currentTarget.dataset.setId as string
    if (!setId) return
    const weight = Number(e.detail) ?? 0
    try {
      const session = updateSet(this.data.sessionId, setId, { weight })
      const app = getApp<IAppOption>()
      app.globalData.pendingSession = session
      this.buildGroupedSets(session, getAllExercises())
    } catch (err) {
      console.error('[training-detail] onWeightChange error:', err)
    }
  },

  onRepsChange(e: WechatMiniprogram.CustomEvent) {
    const setId = e.currentTarget.dataset.setId as string
    if (!setId) return
    const reps = Number(e.detail) ?? 0
    try {
      const session = updateSet(this.data.sessionId, setId, { reps })
      const app = getApp<IAppOption>()
      app.globalData.pendingSession = session
      this.buildGroupedSets(session, getAllExercises())
    } catch (err) {
      console.error('[training-detail] onRepsChange error:', err)
    }
  },

  onWarmupChange(e: WechatMiniprogram.CustomEvent) {
    const setId = e.currentTarget.dataset.setId as string
    if (!setId) return
    const isWarmup = Boolean(e.detail)
    try {
      const session = updateSet(this.data.sessionId, setId, { isWarmup })
      const app = getApp<IAppOption>()
      app.globalData.pendingSession = session
      this.buildGroupedSets(session, getAllExercises())
    } catch (err) {
      console.error('[training-detail] onWarmupChange error:', err)
    }
  },

  onRpeChange(e: WechatMiniprogram.CustomEvent) {
    const setId = e.currentTarget.dataset.setId as string
    if (!setId) return
    const val = e.detail
    const rpe = val === '' || val === null || val === undefined
      ? undefined
      : Number(val)
    try {
      const session = updateSet(this.data.sessionId, setId, { rpe })
      const app = getApp<IAppOption>()
      app.globalData.pendingSession = session
    } catch (err) {
      console.error('[training-detail] onRpeChange error:', err)
    }
  },

  onAddSet(e: WechatMiniprogram.CustomEvent) {
    const exerciseId = e.currentTarget.dataset.exerciseId as string
    if (!exerciseId) return
    try {
      const app = getApp<IAppOption>()
      let session = app.globalData.pendingSession
      if (!session) {
        session = getPendingSession()
      }
      if (!session) return

      const exerciseSets = session.sets.filter(s => s.exerciseId === exerciseId)
      const maxSetNo = exerciseSets.length > 0
        ? Math.max(...exerciseSets.map(s => s.setNo))
        : 0

      const prevSet = exerciseSets.find(s => s.setNo === maxSetNo)
      const newSet: WorkoutSet = {
        _id: genId('set'),
        exerciseId,
        setNo: session.sets.length + 1,
        weight: prevSet?.weight ?? 0,
        reps: prevSet?.reps ?? 0,
        isWarmup: false
      }
      session.sets.push(newSet)
      session = saveSession(session)
      app.globalData.pendingSession = session
      this.buildGroupedSets(session, getAllExercises())
    } catch (err) {
      console.error('[training-detail] onAddSet error:', err)
      wx.showToast({ title: '添加失败', icon: 'none' })
    }
  },

  onRemoveSet(e: WechatMiniprogram.CustomEvent) {
    const setId = e.currentTarget.dataset.setId as string
    if (!setId) return
    wx.showModal({
      title: '删除组',
      content: '确定删除该组记录吗？',
      confirmColor: '#ee0a24',
      success: (res) => {
        if (!res.confirm) return
        try {
          const session = removeSet(this.data.sessionId, setId)
          const app = getApp<IAppOption>()
          app.globalData.pendingSession = session
          this.buildGroupedSets(session, getAllExercises())
          wx.showToast({ title: '已删除', icon: 'success' })
        } catch (err) {
          console.error('[training-detail] onRemoveSet error:', err)
          wx.showToast({ title: '删除失败', icon: 'none' })
        }
      }
    })
  },

  onGoAddExercise() {
    wx.navigateTo({
      url: '/pages/exercise-list/index?mode=pick&sessionId=' + this.data.sessionId
    })
  },

  onNoteChange(e: WechatMiniprogram.CustomEvent) {
    const note = e.detail ?? ''
    this.setData({ note })
  },

  onFinishSession() {
    const { sessionId, note, isEmpty } = this.data
    if (isEmpty) {
      wx.showModal({
        title: '提示',
        content: '当前还没有记录任何组，确定结束训练吗？',
        success: (res) => {
          if (!res.confirm) return
          this.doFinish(sessionId, note)
        }
      })
      return
    }
    this.doFinish(sessionId, note)
  },

  doFinish(sessionId: string, note: string) {
    try {
      const finished = finishSession(sessionId, note)
      const app = getApp<IAppOption>()
      app.globalData.pendingSession = null
      wx.redirectTo({
        url: '/pages/history-detail/index?id=' + finished._id
      })
    } catch (err) {
      console.error('[training-detail] onFinishSession error:', err)
      wx.showToast({ title: '保存失败', icon: 'none' })
    }
  },

  onBack() {
    const app = getApp<IAppOption>()
    const session = app.globalData.pendingSession
    if (session && session.sets.length > 0) {
      wx.showModal({
        title: '离开训练',
        content: '当前训练数据已自动保存，稍后可从主页继续。确定离开吗？',
        confirmText: '确定离开',
        success: (res) => {
          if (res.confirm) {
            wx.navigateBack()
          }
        }
      })
    } else {
      wx.navigateBack()
    }
  }
})
