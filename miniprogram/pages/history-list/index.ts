import { getSessions, deleteSession, getAllExercises } from '../../utils/storage'
import { formatDate, formatDurationMin, formatVolumeKg } from '../../utils/helpers'
import '../../utils/constants'
import type { WorkoutSession } from '../../types/index'
import type { PageData, PageMethods } from '../../types/app'

interface HistoryListItem {
  _id: string
  dateStr: string
  durationStr: string
  volumeStr: string
  exerciseCount: number
  totalSets: number
}

interface HistoryListPageData extends PageData {
  list: HistoryListItem[]
  isEmpty: boolean
  statusBarHeight: number
}

interface HistoryListPageMethods extends PageMethods {
  loadSessions: () => void
  onItemTap: (e: WechatMiniprogram.CustomEvent) => void
  onDelete: (e: WechatMiniprogram.CustomEvent) => void
  onBack: () => void
}

Page<HistoryListPageData, HistoryListPageMethods, WechatMiniprogram.Page.CustomOption>({
  data: {
    list: [],
    isEmpty: true,
    statusBarHeight: 20
  },

  onLoad() {
    const sysInfo = wx.getWindowInfo()
    this.setData({ statusBarHeight: sysInfo.statusBarHeight ?? 20 })
  },

  onShow() {
    this.loadSessions()
  },

  loadSessions() {
    const allSessions = getSessions()
    const completed = allSessions.filter(s => s.isCompleted)
    const sorted = [...completed].sort((a, b) => {
      return new Date(b.startTime).getTime() - new Date(a.startTime).getTime()
    })

    const exercises = getAllExercises()
    const exerciseMap = new Map(exercises.map(e => [e._id, e]))

    const list: HistoryListItem[] = sorted.map((session: WorkoutSession) => {
      const uniqueExerciseIds = new Set(session.sets.map(s => s.exerciseId))
      return {
        _id: session._id,
        dateStr: formatDate(session.startTime),
        durationStr: formatDurationMin(session.durationMin),
        volumeStr: formatVolumeKg(session.totalVolume ?? 0),
        exerciseCount: uniqueExerciseIds.size,
        totalSets: session.sets.length
      }
    })

    this.setData({
      list,
      isEmpty: list.length === 0
    })
  },

  onItemTap(e: WechatMiniprogram.CustomEvent) {
    const id = e.currentTarget.dataset.id as string
    if (!id) return
    wx.navigateTo({ url: `/pages/history-detail/index?id=${id}` })
  },

  onDelete(e: WechatMiniprogram.CustomEvent) {
    const id = e.currentTarget.dataset.id as string
    if (!id) return
    wx.showModal({
      title: '删除训练记录',
      content: '确定要删除这条训练记录吗？此操作不可恢复。',
      confirmColor: '#ee0a24',
      confirmText: '删除',
      success: (res) => {
        if (!res.confirm) return
        try {
          deleteSession(id)
          this.loadSessions()
          wx.showToast({ title: '已删除', icon: 'success' })
        } catch (err) {
          console.error('[history-list] onDelete error:', err)
          wx.showToast({ title: '删除失败', icon: 'none' })
        }
      }
    })
  },

  onBack() {
    wx.navigateBack()
  }
})
