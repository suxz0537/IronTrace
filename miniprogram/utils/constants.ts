import type {
  BodyPart,
  Equipment,
  ExerciseType,
  TrainingGoal,
  EnumOption
} from '../types/index'

export const BODY_PART_OPTIONS: EnumOption<BodyPart>[] = [
  { value: 'chest', label: '胸部' },
  { value: 'back', label: '背部' },
  { value: 'legs', label: '腿部' },
  { value: 'shoulders', label: '肩部' },
  { value: 'arms', label: '手臂' },
  { value: 'core', label: '核心' },
  { value: 'cardio', label: '有氧' },
  { value: 'full_body', label: '全身' }
]

export const EQUIPMENT_OPTIONS: EnumOption<Equipment>[] = [
  { value: 'barbell', label: '杠铃' },
  { value: 'dumbbell', label: '哑铃' },
  { value: 'machine', label: '器械' },
  { value: 'cable', label: '绳索' },
  { value: 'bodyweight', label: '自重' },
  { value: 'kettlebell', label: '壶铃' },
  { value: 'other', label: '其他' }
]

export const EXERCISE_TYPE_OPTIONS: EnumOption<ExerciseType>[] = [
  { value: 'compound', label: '复合动作' },
  { value: 'isolation', label: '孤立动作' }
]

export const TRAINING_GOAL_OPTIONS: EnumOption<TrainingGoal>[] = [
  { value: 'strength', label: '力量' },
  { value: 'muscle', label: '增肌' },
  { value: 'fat_loss', label: '减脂' },
  { value: 'general', label: '综合' }
]

export function getBodyPartLabel(value: BodyPart): string {
  return BODY_PART_OPTIONS.find(o => o.value === value)?.label ?? value
}

export function getEquipmentLabel(value: Equipment): string {
  return EQUIPMENT_OPTIONS.find(o => o.value === value)?.label ?? value
}

export function getExerciseTypeLabel(value: ExerciseType): string {
  return EXERCISE_TYPE_OPTIONS.find(o => o.value === value)?.label ?? value
}

export function getTrainingGoalLabel(value: TrainingGoal): string {
  return TRAINING_GOAL_OPTIONS.find(o => o.value === value)?.label ?? value
}
