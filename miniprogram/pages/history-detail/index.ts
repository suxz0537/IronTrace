import { getSessionById, getAllExercises } from '../../utils/storage'
import { formatDate, formatDurationMin, formatVolumeKg } from '../../utils/helpers'
import '../../utils/constants'
import type { Exercise, WorkoutSession, WorkoutSet } from '../../types/index'
import type { PageData, PageMethods } from '../../types/app'

interface GroupedSet {
  exerciseId: string
  exerciseName: string
  sets: Array<WorkoutSet & { volume: string }>
}

interface HistoryDetailPageData extends PageData {
  sessionId: string
  startTimeStr: string
  endTimeStr: string
  durationStr: string
  totalVolumeStr: string
  note: string
  groupedSets: GroupedSet[]
  totalSets: number
  totalExercises: number
  isEmpty: boolean
  statusBarHeight: number
}

interface HistoryDetailPageMethods extends PageMethods {
  loadSession: () => void
  buildGroupedSets: (session: WorkoutSession, exercises: Exercise[]) => void
  onBack: () => void
}

Page<HistoryDetailPageData, HistoryDetailPageMethods, WechatMiniprogram.Page.CustomOption>({
  data: {
    sessionId: '',
    startTimeStr: '',
    endTimeStr: '',
    durationStr: '--',
    totalVolumeStr: '0 kg',
    note: '',
    groupedSets: [],
    totalSets: 0,
    totalExercises: 0,
    isEmpty: true,
    statusBarHeight: 20
  },

  onLoad(options) {
    const sysInfo = wx.getWindowInfo()
    this.setData({ statusBarHeight: sysInfo.statusBarHeight ?? 20 })
    const id = (options?.id as string) || ''
    if (!id) {
      wx.showToast({ title: '参数错误', icon: 'none' })
      setTimeout(() => wx.navigateBack(), 1000)
      return
    }
    this.setData({ sessionId: id })
    this.loadSession()
  },

  onShow() {
    if (this.data.sessionId) {
      this.loadSession()
    }
  },

  loadSession() {
    const { sessionId } = this.data
    const session = getSessionById(sessionId)

    if (!session) {
      wx.showToast({ title: '未找到训练记录', icon: 'none' })
      setTimeout(() => wx.navigateBack(), 1000)
      return
    }

    const exercises = getAllExercises()
    const uniqueExerciseIds = new Set(session.sets.map(s => s.exerciseId))

    this.setData({
      startTimeStr: formatDate(session.startTime),
      endTimeStr: session.endTime ? formatDate(session.endTime) : '--',
      durationStr: formatDurationMin(session.durationMin),
      totalVolumeStr: formatVolumeKg(session.totalVolume ?? 0),
      note: session.note ?? '无',
      totalSets: session.sets.length,
      totalExercises: uniqueExerciseIds.size
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

    this.setData({
      groupedSets,
      isEmpty: groupedSets.length === 0
    })
  },

  onBack() {
    wx.navigateBack()
  }
})
