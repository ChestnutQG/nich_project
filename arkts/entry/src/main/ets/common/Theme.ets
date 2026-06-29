// 主题色工具 — 根据 ThemeMode 返回对应颜色字符串
// 所有页面/组件通过 @StorageProp('theme') 拿到 theme 后传入这些函数
import { ThemeMode } from '../service/SettingsService'

export class Theme {
  // 背景
  static bg(t: ThemeMode): string { return t === 'dark' ? '#121212' : '#F5F5F5' }
  static card(t: ThemeMode): string { return t === 'dark' ? '#1E1E1E' : '#FFFFFF' }

  // 文字
  static textPrimary(t: ThemeMode): string { return t === 'dark' ? '#EEEEEE' : '#333333' }
  static textSecondary(t: ThemeMode): string { return t === 'dark' ? '#AAAAAA' : '#666666' }
  static textHint(t: ThemeMode): string { return t === 'dark' ? '#666666' : '#999999' }

  // 主题色（红色在深色模式下稍浅）
  static primary(t: ThemeMode): string { return t === 'dark' ? '#EF9A9A' : '#C62828' }
  static primaryBg(t: ThemeMode): string { return t === 'dark' ? '#3A1F1F' : '#FFF0F0' }
  static primaryLight(t: ThemeMode): string { return t === 'dark' ? '#4A1A1A' : '#FFCDD2' }

  // 分割线 / 边框
  static divider(t: ThemeMode): string { return t === 'dark' ? '#2A2A2A' : '#EEEEEE' }

  // 金色（匠人标识）
  static gold(t: ThemeMode): string { return t === 'dark' ? '#E8C07A' : '#C8A45C' }

  // 状态色
  static success(t: ThemeMode): string { return t === 'dark' ? '#66BB6A' : '#4CAF50' }
  static warning(t: ThemeMode): string { return t === 'dark' ? '#FFA726' : '#FF9800' }
  static error(t: ThemeMode): string { return t === 'dark' ? '#EF5350' : '#E74C3C' }

  // 常量色（不受主题影响）
  static readonly WHITE = '#FFFFFF'
}
