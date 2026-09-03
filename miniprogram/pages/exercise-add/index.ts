import { saveCustomExercise } from '../../utils/storage'
import '../../utils/helpers'
import {
  BODY_PART_OPTIONS,
  EQUIPMENT_OPTIONS,
  EXERCISE_TYPE_OPTIONS,
  getBodyPartLabel,
  getEquipmentLabel,
  getExerciseTypeLabel
} from '../../utils/constants'
import type { BodyPart, Equipment, ExerciseType } from '../../types/index'
import type { PageData, PageMethods } from '../../types/app'

interface ExerciseAddPageData extends PageData {
  name: string
  nameError: string
  bodyPart: BodyPart
  bodyPartLabel: string
  bodyPartOptions: typeof BODY_PART_OPTIONS
  bodyPartPickerIndex: number
  showBodyPartPicker: boolean
  equipment: Equipment
  equipmentLabel: string
  equipmentOptions: typeof EQUIPMENT_OPTIONS
  equipmentPickerIndex: number
  showEquipmentPicker: boolean
  type: ExerciseType
  typeLabel: string
  typeOptions: typeof EXERCISE_TYPE_OPTIONS
  typePickerIndex: number
  showTypePicker: boolean
  instructions: string
}

interface ExerciseAddPageMethods extends PageMethods {
  onBack: () => void
  onSave: () => void
  onNameChange: (e: WechatMiniprogram.CustomEvent) => void
  onNameBlur: (e: WechatMiniprogram.CustomEvent) => void
  onShowBodyPartPicker: () => void
  onBodyPartPickerConfirm: (e: WechatMiniprogram.CustomEvent) => void
  onBodyPartPickerCancel: () => void
  onShowEquipmentPicker: () => void
  onEquipmentPickerConfirm: (e: WechatMiniprogram.CustomEvent) => void
  onEquipmentPickerCancel: () => void
  onShowTypePicker: () => void
  onTypePickerConfirm: (e: WechatMiniprogram.CustomEvent) => void
  onTypePickerCancel: () => void
  onInstructionsChange: (e: WechatMiniprogram.CustomEvent) => void
  validate: () => boolean
}

Page<ExerciseAddPageData, ExerciseAddPageMethods, WechatMiniprogram.Page.CustomOption>({
  data: {
    name: '',
    nameError: '',
    bodyPart: 'chest',
    bodyPartLabel: getBodyPartLabel('chest'),
    bodyPartOptions: BODY_PART_OPTIONS,
    bodyPartPickerIndex: 0,
    showBodyPartPicker: false,
    equipment: 'barbell',
    equipmentLabel: getEquipmentLabel('barbell'),
    equipmentOptions: EQUIPMENT_OPTIONS,
    equipmentPickerIndex: 0,
    showEquipmentPicker: false,
    type: 'compound',
    typeLabel: getExerciseTypeLabel('compound'),
    typeOptions: EXERCISE_TYPE_OPTIONS,
    typePickerIndex: 0,
    showTypePicker: false,
    instructions: ''
  },

  onBack() {
    wx.navigateBack()
  },

  onSave() {
    if (!this.validate()) return

    const { name, bodyPart, equipment, type, instructions } = this.data
    try {
      saveCustomExercise({
        name,
        bodyPart,
        equipment,
        type,
        instructions: instructions || undefined,
        isCustom: true
      })
      wx.showToast({ title: '保存成功', icon: 'success' })
      setTimeout(() => wx.navigateBack(), 500)
    } catch (e) {
      console.error('[exercise-add] onSave error:', e)
      wx.showToast({ title: '保存失败', icon: 'none' })
    }
  },

  onNameChange(e: WechatMiniprogram.CustomEvent) {
    const value = e.detail ?? ''
    this.setData({
      name: value,
      nameError: value ? '' : '请输入动作名称'
    })
  },

  onNameBlur() {
    const { name } = this.data
    this.setData({
      nameError: name ? '' : '请输入动作名称'
    })
  },

  onShowBodyPartPicker() {
    this.setData({ showBodyPartPicker: true })
  },

  onBodyPartPickerConfirm(e: WechatMiniprogram.CustomEvent) {
    const index = e.detail.index as number
    const option = this.data.bodyPartOptions[index]
    this.setData({
      bodyPart: option.value,
      bodyPartLabel: option.label,
      bodyPartPickerIndex: index,
      showBodyPartPicker: false
    })
  },

  onBodyPartPickerCancel() {
    this.setData({ showBodyPartPicker: false })
  },

  onShowEquipmentPicker() {
    this.setData({ showEquipmentPicker: true })
  },

  onEquipmentPickerConfirm(e: WechatMiniprogram.CustomEvent) {
    const index = e.detail.index as number
    const option = this.data.equipmentOptions[index]
    this.setData({
      equipment: option.value,
      equipmentLabel: option.label,
      equipmentPickerIndex: index,
      showEquipmentPicker: false
    })
  },

  onEquipmentPickerCancel() {
    this.setData({ showEquipmentPicker: false })
  },

  onShowTypePicker() {
    this.setData({ showTypePicker: true })
  },

  onTypePickerConfirm(e: WechatMiniprogram.CustomEvent) {
    const index = e.detail.index as number
    const option = this.data.typeOptions[index]
    this.setData({
      type: option.value,
      typeLabel: option.label,
      typePickerIndex: index,
      showTypePicker: false
    })
  },

  onTypePickerCancel() {
    this.setData({ showTypePicker: false })
  },

  onInstructionsChange(e: WechatMiniprogram.CustomEvent) {
    this.setData({ instructions: e.detail ?? '' })
  },

  validate() {
    const { name } = this.data
    if (!name || !name.trim()) {
      this.setData({ nameError: '请输入动作名称' })
      return false
    }
    return true
  }
})
