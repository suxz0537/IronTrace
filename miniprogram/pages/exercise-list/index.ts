import {
  getAllExercises,
  addExerciseToSession,
  getPendingSession,
  createNewSession
} from '../../utils/storage'
import { matchExerciseKeyword, BODY_PART_ORDER } from '../../utils/helpers'
import {
  BODY_PART_OPTIONS,
  getBodyPartLabel,
  getEquipmentLabel,
  getExerciseTypeLabel
} from '../../utils/constants'
import type { BodyPart, Exercise } from '../../types/index'
import type { PageData, PageMethods } from '../../types/app'

interface BodyPartFilterOption {
  value: BodyPart | 'all'
  label: string
}

interface GroupedExercise {
  bodyPart: BodyPart
  bodyPartLabel: string
  data: Array<{
    _id: string
    name: string
    equipmentLabel: string
    typeLabel: string
    type: Exercise['type']
  }>
}

interface ExerciseListPageData extends PageData {
  keyword: string
  activeBodyPart: BodyPart | 'all'
  bodyPartOptions: BodyPartFilterOption[]
  groupedExercises: GroupedExercise[]
  isEmpty: boolean
  mode: 'browse' | 'pick'
  sessionId?: string
}

interface ExerciseListPageMethods extends PageMethods {
  onSearch: (e: WechatMiniprogram.CustomEvent) => void
  onSearchChange: (e: WechatMiniprogram.CustomEvent) => void
  onClearSearch: () => void
  onSelectBodyPart: (e: WechatMiniprogram.CustomEvent) => void
  onGoAddExercise: () => void
  onGoExerciseDetail: (e: WechatMiniprogram.CustomEvent) => void
  onPickExercise: (e: WechatMiniprogram.CustomEvent) => void
  loadAndFilterExercises: () => void
}

const ALL_OPTION: BodyPartFilterOption = { value: 'all', label: '全部' }

Page<ExerciseListPageData, ExerciseListPageMethods, WechatMiniprogram.Page.CustomOption>({
  data: {
    keyword: '',
    activeBodyPart: 'all',
    bodyPartOptions: [ALL_OPTION, ...BODY_PART_OPTIONS],
    groupedExercises: [],
    isEmpty: false,
    mode: 'browse',
    sessionId: undefined
  },

  onLoad(options) {
    const mode = options?.mode === 'pick' ? 'pick' : 'browse'
    const sessionId = options?.sessionId || undefined
    this.setData({ mode, sessionId })
    if (mode === 'pick') {
      wx.setNavigationBarTitle({ title: '选择动作' })
    }
  },

  onShow() {
    this.loadAndFilterExercises()
  },

  loadAndFilterExercises() {
    const { keyword, activeBodyPart } = this.data
    const allExercises = getAllExercises()

    let filtered = allExercises.filter(ex => {
      if (!matchExerciseKeyword(ex, keyword)) return false
      if (activeBodyPart !== 'all' && ex.bodyPart !== activeBodyPart) return false
      return true
    })

    const map = new Map<BodyPart, Exercise[]>()
    filtered.forEach(ex => {
      const list = map.get(ex.bodyPart) ?? []
      list.push(ex)
      map.set(ex.bodyPart, list)
    })

    const groupedExercises: GroupedExercise[] = BODY_PART_ORDER
      .filter(bp => map.has(bp))
      .map(bp => {
        const exercises = map.get(bp)!
        return {
          bodyPart: bp,
          bodyPartLabel: getBodyPartLabel(bp),
          data: exercises.map(ex => ({
            _id: ex._id,
            name: ex.name,
            equipmentLabel: getEquipmentLabel(ex.equipment),
            typeLabel: getExerciseTypeLabel(ex.type),
            type: ex.type
          }))
        }
      })

    this.setData({
      groupedExercises,
      isEmpty: groupedExercises.length === 0
    })
  },

  onSearch(e: WechatMiniprogram.CustomEvent) {
    this.setData({ keyword: e.detail ?? '' }, () => {
      this.loadAndFilterExercises()
    })
  },

  onSearchChange(e: WechatMiniprogram.CustomEvent) {
    this.setData({ keyword: e.detail ?? '' }, () => {
      this.loadAndFilterExercises()
    })
  },

  onClearSearch() {
    this.setData({ keyword: '' }, () => {
      this.loadAndFilterExercises()
    })
  },

  onSelectBodyPart(e: WechatMiniprogram.CustomEvent) {
    const value = e.currentTarget.dataset.value as BodyPart | 'all'
    this.setData({ activeBodyPart: value }, () => {
      this.loadAndFilterExercises()
    })
  },

  onGoAddExercise() {
    wx.navigateTo({ url: '/pages/exercise-add/index' })
  },

  onGoExerciseDetail(e: WechatMiniprogram.CustomEvent) {
    const id = e.currentTarget.dataset.id as string
    if (!id) return
    if (this.data.mode === 'pick') {
      this.onPickExercise(e)
      return
    }
    wx.navigateTo({ url: `/pages/exercise-detail/index?id=${id}` })
  },

  onPickExercise(e: WechatMiniprogram.CustomEvent) {
    const exerciseId = e.currentTarget.dataset.id as string
    if (!exerciseId) return
    try {
      let { sessionId } = this.data
      if (!sessionId) {
        const pending = getPendingSession()
        if (pending) {
          sessionId = pending._id
        } else {
          const newSession = createNewSession()
          sessionId = newSession._id
        }
      }
      addExerciseToSession(sessionId, exerciseId)
      wx.showToast({ title: '动作已添加', icon: 'success' })
      setTimeout(() => {
        wx.navigateBack({ delta: 1 })
      }, 500)
    } catch (err) {
      console.error('[exercise-list] pick exercise error:', err)
      wx.showToast({ title: '添加失败，请重试', icon: 'none' })
    }
  }
})
