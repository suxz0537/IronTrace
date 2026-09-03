import {
  getAllExercises,
  getPendingSession,
  createNewSession,
  addExerciseToSession
} from '../../utils/storage'
import '../../utils/helpers'
import {
  getBodyPartLabel,
  getEquipmentLabel,
  getExerciseTypeLabel
} from '../../utils/constants'
import type { Exercise, ExerciseType } from '../../types/index'
import type { PageData, PageMethods } from '../../types/app'

interface ExerciseDetailPageData extends PageData {
  exercise: Exercise | null
  name: string
  bodyPartLabel: string
  equipmentLabel: string
  typeLabel: string
  type: ExerciseType
  instructions: string
  isPickMode: boolean
}

interface ExerciseDetailPageMethods extends PageMethods {
  onBack: () => void
  onAddToSession: () => void
}

Page<ExerciseDetailPageData, ExerciseDetailPageMethods, WechatMiniprogram.Page.CustomOption>({
  data: {
    exercise: null,
    name: '',
    bodyPartLabel: '',
    equipmentLabel: '',
    typeLabel: '',
    type: 'compound',
    instructions: '',
    isPickMode: false
  },

  onLoad(options) {
    const id = options?.id as string
    const mode = options?.mode as string

    if (!id) {
      wx.showToast({ title: '参数错误', icon: 'none' })
      setTimeout(() => wx.navigateBack(), 1000)
      return
    }

    const exercise = getAllExercises().find(ex => ex._id === id)
    if (!exercise) {
      wx.showToast({ title: '未找到动作', icon: 'none' })
      setTimeout(() => wx.navigateBack(), 1000)
      return
    }

    this.setData({
      exercise,
      name: exercise.name,
      bodyPartLabel: getBodyPartLabel(exercise.bodyPart),
      equipmentLabel: getEquipmentLabel(exercise.equipment),
      typeLabel: getExerciseTypeLabel(exercise.type),
      type: exercise.type,
      instructions: exercise.instructions ?? '',
      isPickMode: mode === 'pick'
    })
  },

  onBack() {
    wx.navigateBack()
  },

  onAddToSession() {
    const { exercise } = this.data
    if (!exercise) return

    try {
      let session = getPendingSession()
      if (!session) {
        session = createNewSession()
      }
      addExerciseToSession(session._id, exercise._id)
      const app = getApp<IAppOption>()
      app.globalData.pendingSession = session
      wx.showToast({ title: '已添加到训练', icon: 'success' })
      setTimeout(() => wx.navigateBack(), 500)
    } catch (e) {
      console.error('[exercise-detail] onAddToSession error:', e)
      wx.showToast({ title: '添加失败', icon: 'none' })
    }
  }
})
