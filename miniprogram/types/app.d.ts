import type { Exercise, WorkoutSession } from './index'

export interface AppOptions {
  globalData: {
    exercises: Exercise[]
    pendingSession: WorkoutSession | null
  }
}

export interface PageData {
  [key: string]: unknown
}

export interface PageMethods {
  [key: string]: (...args: unknown[]) => unknown
}
