import { initExercises } from './utils/storage'
import type { AppOptions } from './types/app'

App<AppOptions>({
  globalData: {
    exercises: [],
    pendingSession: null
  },

  onLaunch() {
    try {
      initExercises()
    } catch (e) {
      console.error('[App] onLaunch initExercises error:', e)
    }
  },

  onShow() {}
})
