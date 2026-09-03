import type { Exercise, WorkoutSession, WorkoutSet, StorageKey } from '../types/index'
import builtinExercises from '../data/exercises.json'

const STORAGE_KEYS: Record<StorageKey, string> = {
  builtinExercises: 'builtinExercises',
  customExercises: 'customExercises',
  sessions: 'sessions'
}

function safeGetStorageSync<T>(key: string, fallback: T): T {
  try {
    const val = wx.getStorageSync(key)
    if (val === '' || val === null || val === undefined) return fallback
    return val as T
  } catch (e) {
    console.warn(`[storage] get ${key} error:`, e)
    return fallback
  }
}

function safeSetStorageSync(key: string, value: unknown): void {
  try {
    wx.setStorageSync(key, value)
  } catch (e) {
    console.error(`[storage] set ${key} error:`, e)
    throw e
  }
}

export function genId(prefix: string): string {
  return `${prefix}_${Date.now()}_${Math.random().toString(36).slice(2, 8)}`
}

export function initExercises(): Exercise[] {
  const list = builtinExercises as Exercise[]
  safeSetStorageSync(STORAGE_KEYS.builtinExercises, list)
  return list
}

export function getBuiltinExercises(): Exercise[] {
  const cached = safeGetStorageSync<Exercise[] | null>(STORAGE_KEYS.builtinExercises, null)
  if (cached && cached.length > 0) return cached
  return initExercises()
}

export function getCustomExercises(): Exercise[] {
  return safeGetStorageSync<Exercise[]>(STORAGE_KEYS.customExercises, [])
}

export function getAllExercises(): Exercise[] {
  return [...getBuiltinExercises(), ...getCustomExercises()]
}

export function saveCustomExercise(exercise: Omit<Exercise, '_id' | 'isCustom'>): Exercise {
  const custom = getCustomExercises()
  const newItem: Exercise = {
    ...exercise,
    _id: genId('custom'),
    isCustom: true
  }
  custom.push(newItem)
  safeSetStorageSync(STORAGE_KEYS.customExercises, custom)
  const app = getApp<IAppOption>()
  app.globalData.exercises = getAllExercises()
  return newItem
}

export function calcSessionVolume(session: WorkoutSession): number {
  if (!session.sets || session.sets.length === 0) return 0
  return session.sets
    .filter(s => !s.isWarmup)
    .reduce((sum, s) => sum + (s.weight ?? 0) * (s.reps ?? 0), 0)
}

export function calcSessionDurationMin(
  startTimeStr: string,
  endTimeStr?: string
): number | undefined {
  if (!endTimeStr) return undefined
  const start = new Date(startTimeStr).getTime()
  const end = new Date(endTimeStr).getTime()
  const diffMin = Math.round((end - start) / 60000)
  return diffMin > 0 ? diffMin : 0
}

export function getSessions(): WorkoutSession[] {
  return safeGetStorageSync<WorkoutSession[]>(STORAGE_KEYS.sessions, [])
}

export function saveSession(session: WorkoutSession): WorkoutSession {
  const sessions = getSessions()
  const volume = calcSessionVolume(session)
  const durationMin = calcSessionDurationMin(session.startTime, session.endTime)

  const saved: WorkoutSession = {
    ...session,
    totalVolume: volume,
    durationMin
  }

  const idx = sessions.findIndex(s => s._id === saved._id)
  if (idx >= 0) {
    sessions[idx] = saved
  } else {
    sessions.unshift(saved)
  }
  safeSetStorageSync(STORAGE_KEYS.sessions, sessions)
  return saved
}

export function deleteSession(sessionId: string): void {
  const sessions = getSessions().filter(s => s._id !== sessionId)
  safeSetStorageSync(STORAGE_KEYS.sessions, sessions)
}

export function getSessionById(sessionId: string): WorkoutSession | undefined {
  return getSessions().find(s => s._id === sessionId)
}

export function getPendingSession(): WorkoutSession | null {
  const sessions = getSessions()
  return sessions.find(s => !s.isCompleted) ?? null
}

export function createNewSession(): WorkoutSession {
  const pending = getPendingSession()
  if (pending) {
    const autoClose: WorkoutSession = {
      ...pending,
      endTime: new Date().toISOString(),
      isCompleted: true
    }
    autoClose.totalVolume = calcSessionVolume(autoClose)
    autoClose.durationMin = calcSessionDurationMin(autoClose.startTime, autoClose.endTime)
    saveSession(autoClose)
    wx.showToast({ title: '上次训练已自动保存', icon: 'none' })
  }

  const now = new Date()
  const newSession: WorkoutSession = {
    _id: genId('session'),
    startTime: now.toISOString(),
    totalVolume: 0,
    isCompleted: false,
    sets: []
  }
  saveSession(newSession)
  return newSession
}

export function addExerciseToSession(
  sessionId: string,
  exerciseId: string
): WorkoutSession {
  const session = getSessionById(sessionId)
  if (!session) throw new Error('Session not found')

  const nextSetNo = session.sets.length + 1
  const newSet: WorkoutSet = {
    _id: genId('set'),
    exerciseId,
    setNo: nextSetNo,
    weight: 0,
    reps: 0,
    isWarmup: false
  }
  session.sets.push(newSet)
  return saveSession(session)
}

export function updateSet(
  sessionId: string,
  setId: string,
  patch: Partial<WorkoutSet>
): WorkoutSession {
  const session = getSessionById(sessionId)
  if (!session) throw new Error('Session not found')
  const idx = session.sets.findIndex(s => s._id === setId)
  if (idx < 0) throw new Error('Set not found')
  session.sets[idx] = { ...session.sets[idx], ...patch }
  return saveSession(session)
}

export function removeSet(sessionId: string, setId: string): WorkoutSession {
  const session = getSessionById(sessionId)
  if (!session) throw new Error('Session not found')
  session.sets = session.sets.filter(s => s._id !== setId)
  let order = 1
  session.sets.forEach(s => { s.setNo = order++ })
  return saveSession(session)
}

export function finishSession(sessionId: string, note?: string): WorkoutSession {
  const session = getSessionById(sessionId)
  if (!session) throw new Error('Session not found')
  session.endTime = new Date().toISOString()
  session.isCompleted = true
  if (note !== undefined) session.note = note
  return saveSession(session)
}

export function calc1RM(weight: number, reps: number): number {
  if (!weight || !reps) return 0
  if (reps <= 1) return weight
  return Math.round(weight * (1 + reps / 30) * 10) / 10
}

export { STORAGE_KEYS }
