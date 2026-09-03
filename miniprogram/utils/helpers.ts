import type { BodyPart, Equipment, Exercise } from '../types/index'

const PinyinFirstLetterMap: Record<string, string> = {
  '杠': 'G', '铃': 'L', '卧': 'W', '推': 'T', '上': 'S', '斜': 'X', '下': 'X',
  '哑': 'Y', '飞': 'F', '鸟': 'N', '绳': 'S', '索': 'S', '夹': 'J', '胸': 'X',
  '器': 'Q', '械': 'X', '坐': 'Z', '姿': 'Z', '蝴': 'H', '蝶': 'D', '俯': 'F',
  '身': 'S', '撑': 'C', '硬': 'Y', '拉': 'L', '罗': 'L', '马': 'M', '尼': 'N',
  '亚': 'Y', '划': 'H', '船': 'C', 'T': 'T', '单': 'D', '臂': 'B', '高': 'G',
  '位': 'W', '引': 'Y', '体': 'T', '向': 'X', '上': 'S', '反': 'F', '握': 'W',
  '面': 'M', '山': 'S', '羊': 'Y', '挺': 'T', '深': 'S', '蹲': 'D', '颈': 'J',
  '前': 'Q', '腿': 'T', '举': 'J', '箭': 'J', '步': 'B', '屈': 'Q', '伸': 'S',
  '弯': 'W', '提': 'T', '踵': 'Z', '壶': 'H', '杯': 'B', '保': 'B', '加': 'J',
  '利': 'L', '分': 'F', '肩': 'J', '直': 'Z', '立': 'L', '侧': 'C', '平': 'P',
  '俯': 'F', '军': 'J', '事': 'S', '弯': 'W', '锤': 'C', '三': 'S', '头': 'T',
  '压': 'Y', '仰': 'Y', '双': 'S', '窄': 'Z', '距': 'J', '平': 'P', '板': 'B',
  '支': 'Z', '卷': 'J', '腹': 'F', '悬': 'X', '垂': 'C', '俄': 'E', '斯': 'S',
  '转': 'Z', '死': 'S', '虫': 'C', '式': 'S', '跑': 'P', '步': 'B', '机': 'J',
  '摇': 'Y', '摆': 'B', '全': 'Q', '腿': 'T', '部': 'B', '背': 'B', '手': 'S'
}

function charPinyin(ch: string): string {
  const code = ch.charCodeAt(0)
  if (code >= 0x4e00 && code <= 0x9fa5) {
    return PinyinFirstLetterMap[ch] ?? ch
  }
  return ch.toUpperCase()
}

export function namePinyinInitials(name: string): string {
  if (!name) return ''
  let res = ''
  for (const ch of name) {
    res += charPinyin(ch)
  }
  return res
}

export function matchExerciseKeyword(exercise: Exercise, keyword: string): boolean {
  if (!keyword) return true
  const kw = keyword.trim().toUpperCase()
  if (!kw) return true
  if (exercise.name.includes(keyword)) return true
  const initials = namePinyinInitials(exercise.name)
  return initials.includes(kw)
}

export function groupExercisesByBodyPart(
  exercises: Exercise[]
): Array<{ bodyPart: BodyPart; data: Exercise[] }> {
  const map = new Map<BodyPart, Exercise[]>()
  exercises.forEach(ex => {
    const list = map.get(ex.bodyPart) ?? []
    list.push(ex)
    map.set(ex.bodyPart, list)
  })
  return Array.from(map.entries()).map(([bodyPart, data]) => ({ bodyPart, data }))
}

export function formatDate(dateStr: string): string {
  const d = new Date(dateStr)
  const y = d.getFullYear()
  const m = String(d.getMonth() + 1).padStart(2, '0')
  const day = String(d.getDate()).padStart(2, '0')
  const hh = String(d.getHours()).padStart(2, '0')
  const mm = String(d.getMinutes()).padStart(2, '0')
  return `${y}-${m}-${day} ${hh}:${mm}`
}

export function formatDurationMin(min?: number): string {
  if (min === undefined || min === null) return '--'
  if (min < 60) return `${min} 分钟`
  const h = Math.floor(min / 60)
  const m = min % 60
  return m ? `${h} 小时 ${m} 分` : `${h} 小时`
}

export function formatVolumeKg(volume: number): string {
  if (!volume) return '0 kg'
  return `${volume.toLocaleString()} kg`
}

export type EquipmentOptionValue =
  | Equipment
  | 'all'

export const BODY_PART_ORDER: BodyPart[] = [
  'chest',
  'back',
  'legs',
  'shoulders',
  'arms',
  'core',
  'cardio',
  'full_body'
]
