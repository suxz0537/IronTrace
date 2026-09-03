import { getSessions, getPendingSession, createNewSession, deleteSession } from '../../utils/storage'
import { formatDate, formatDurationMin, formatVolumeKg } from '../../utils/helpers'
import '../../utils/constants'
import type { WorkoutSession } from '../../types/index'
import type { PageData, PageMethods } from '../../types/app'

interface TrainingPageData extends PageData {
  lastSession: WorkoutSession | null
  lastSessionDate: string
  lastSessionDesc: string
  lastSessionDuration: string
  lastSessionVolume: string
}

interface TrainingPageMethods extends PageMethods {
  onGoHistoryList: () => void
  onGoLastSessionDetail: () => void
  onStartTraining: () => void
  loadData: () => void
  checkPendingSession: () => void
  resumePendingSession: () => void
}

Page<TrainingPageData, TrainingPageMethods, WechatMiniprogram.Page.CustomOption>({
  data: {
    lastSession: null,
    lastSessionDate: '',
    lastSessionDesc: '',
    lastSessionDuration: '',
    lastSessionVolume: ''
  },

  onShow() {
    this.loadData()
    this.checkPendingSession()
  },

  loadData() {
    const sessions = getSessions()
    const completedSessions = sessions.filter(s => s.isCompleted)
    const lastSession = completedSessions.length > 0 ? completedSessions[0] : null

    if (lastSession) {
      const exerciseCount = new Set(lastSession.sets.map(s => s.exerciseId)).size
      const desc = exerciseCount > 0 ? `${exerciseCount} 个动作` : '暂无动作数据'
      this.setData({
        lastSession,
        lastSessionDate: formatDate(lastSession.startTime),
        lastSessionDesc: desc,
        lastSessionDuration: formatDurationMin(lastSession.durationMin),
        lastSessionVolume: formatVolumeKg(lastSession.totalVolume)
      })
    } else {
      this.setData({
        lastSession: null,
        lastSessionDate: '',
        lastSessionDesc: '',
        lastSessionDuration: '',
        lastSessionVolume: ''
      })
    }
  },

  checkPendingSession() {
    const pending = getPendingSession()
    if (!pending) return

    wx.showModal({
      title: '未完成训练',
      content: '检测到上次训练未完成，是否继续？',
      confirmText: '继续训练',
      cancelText: '丢弃',
      success: (res) => {
        if (res.confirm) {
          this.resumePendingSession()
        } else if (res.cancel) {
          deleteSession(pending._id)
          wx.showToast({ title: '已丢弃未完成训练', icon: 'none' })
        }
      }
    })
  },

  resumePendingSession() {
    const pending = getPendingSession()
    if (!pending) {
      wx.showToast({ title: '未找到待训练记录', icon: 'none' })
      return
    }
    const app = getApp<IAppOption>()
    app.globalData.pendingSession = pending
    wx.navigateTo({ url: '/pages/training-detail/index' })
  },

  onGoHistoryList() {
    wx.navigateTo({ url: '/pages/history-list/index' })
  },

  onGoLastSessionDetail() {
    const { lastSession } = this.data
    if (!lastSession) return
    wx.navigateTo({ url: `/pages/history-detail/index?id=${lastSession._id}` })
  },

  onStartTraining() {
    try {
      const newSession = createNewSession()
      const app = getApp<IAppOption>()
      app.globalData.pendingSession = newSession
      wx.navigateTo({ url: '/pages/training-detail/index' })
    } catch (e) {
      console.error('[training] onStartTraining error:', e)
      wx.showToast({ title: '创建训练失败', icon: 'none' })
    }
  }
})
