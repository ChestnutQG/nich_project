// 主题色工具 — 根据 ThemeMode 返回对应颜色字符串
// 所有页面/组件通过 @StorageProp('theme') 拿到 theme 后传入这些函数
import { ThemeMode } from '../service/SettingsService'
import { Colors } from './Colors'

export class Theme {
  // 背景
  static bg(t: ThemeMode): string { return t === 'dark' ? '#1A1815' : Colors.BG_PAPER }
  static card(t: ThemeMode): string { return t === 'dark' ? '#252320' : Colors.BG_CARD }

  // 文字
  static textPrimary(t: ThemeMode): string { return t === 'dark' ? '#E8E2D4' : Colors.TEXT_PRIMARY }
  static textSecondary(t: ThemeMode): string { return t === 'dark' ? '#A09888' : Colors.TEXT_SECONDARY }
  static textHint(t: ThemeMode): string { return t === 'dark' ? '#6B6358' : Colors.TEXT_HINT }

  // 主题色（朱砂红在深色模式下稍浅）
  static primary(t: ThemeMode): string { return t === 'dark' ? '#D48080' : Colors.PRIMARY }
  static primaryBg(t: ThemeMode): string { return t === 'dark' ? '#3A1F1F' : Colors.PRIMARY_BG }
  static primaryLight(t: ThemeMode): string { return t === 'dark' ? '#4A2525' : Colors.PRIMARY_LIGHT }

  // 分割线 / 边框
  static divider(t: ThemeMode): string { return t === 'dark' ? '#3A3530' : Colors.DIVIDER }

  // 金色（匠人标识）
  static gold(t: ThemeMode): string { return t === 'dark' ? '#D4B06A' : Colors.GOLD }

  // 辅助色（石青）
  static accent(t: ThemeMode): string { return t === 'dark' ? '#7BA0C0' : Colors.ACCENT }

  // 状态色
  static success(t: ThemeMode): string { return t === 'dark' ? '#7BA87B' : Colors.SUCCESS }
  static warning(t: ThemeMode): string { return t === 'dark' ? '#D4A860' : Colors.WARNING }
  static error(t: ThemeMode): string { return t === 'dark' ? '#E06050' : Colors.ERROR }

  // 常量色（不受主题影响）
  static readonly WHITE = '#FFFFFF'
}
