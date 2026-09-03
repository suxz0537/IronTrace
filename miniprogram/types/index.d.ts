export type BodyPart =
  | 'chest'
  | 'back'
  | 'legs'
  | 'shoulders'
  | 'arms'
  | 'core'
  | 'cardio'
  | 'full_body'

export type Equipment =
  | 'barbell'
  | 'dumbbell'
  | 'machine'
  | 'cable'
  | 'bodyweight'
  | 'kettlebell'
  | 'other'

export type ExerciseType = 'compound' | 'isolation'

export type TrainingGoal = 'strength' | 'muscle' | 'fat_loss' | 'general'

export interface Exercise {
  _id: string
  name: string
  bodyPart: BodyPart
  equipment: Equipment
  type: ExerciseType
  met?: number
  instructions?: string
  mediaUrl?: string
  isCustom: boolean
}

export interface WorkoutSet {
  _id: string
  exerciseId: string
  setNo: number
  weight: number
  reps: number
  rpe?: number
  restSec?: number
  isWarmup: boolean
}

export interface WorkoutSession {
  _id: string
  startTime: string
  endTime?: string
  durationMin?: number
  bodyWeight?: number
  totalVolume: number
  note?: string
  isCompleted: boolean
  sets: WorkoutSet[]
}

export interface UserInfo {
  _id: string
  nickname?: string
  gender?: 'male' | 'female'
  birthYear?: number
  heightCm?: number
  trainingGoal?: TrainingGoal
}

export interface BodyMetric {
  _id: string
  userId: string
  date: string
  weight?: number
  bodyFat?: number
  waistCm?: number
}

export interface EnumOption<T> {
  value: T
  label: string
}

export type StorageKey = 'builtinExercises' | 'customExercises' | 'sessions'
