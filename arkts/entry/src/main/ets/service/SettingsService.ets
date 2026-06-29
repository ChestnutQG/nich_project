// 应用设置服务 — 同步初始化 + 即时写盘，彻底解决重启丢失问题
import { preferences } from '@kit.ArkData'
import { ConfigurationConstant } from '@kit.AbilityKit'

export type ThemeMode = 'light' | 'dark'
export type FontScale = 'small' | 'normal' | 'large'
export type Language = 'zh' | 'en'

const PREFS_NAME = 'app_settings'

class SettingsServiceImpl {
  private prefs: preferences.Preferences | null = null

  // 同步初始化，在 EntryAbility.onCreate 中调用（早于任何页面/组件）
  // getPreferencesSync 直接从磁盘读取，保证 @StorageLink 初始化时拿到存档值
  init(): void {
    try {
      this.prefs = preferences.getPreferencesSync(getContext(), { name: PREFS_NAME })
      const theme    = this.prefs.getSync('theme',     'light')  as ThemeMode
      const fontScale = this.prefs.getSync('fontScale', 'normal') as FontScale
      const language  = this.prefs.getSync('language',  'zh')     as Language
      AppStorage.setOrCreate<ThemeMode>('theme',     theme)
      AppStorage.setOrCreate<FontScale>('fontScale', fontScale)
      AppStorage.setOrCreate<Language>('language',   language)
      this.applyColorMode(theme)
    } catch (_) {
      // 首次安装或读盘失败，使用默认值
      AppStorage.setOrCreate<ThemeMode>('theme',     'light')
      AppStorage.setOrCreate<FontScale>('fontScale', 'normal')
      AppStorage.setOrCreate<Language>('language',   'zh')
    }
  }

  // 兼容旧调用
  ensureInit(): void {}

  setTheme(mode: ThemeMode): void {
    AppStorage.set<ThemeMode>('theme', mode)
    this.applyColorMode(mode)
    this.save('theme', mode)
  }

  setFontScale(scale: FontScale): void {
    AppStorage.set<FontScale>('fontScale', scale)
    this.save('fontScale', scale)
  }

  setLanguage(lang: Language): void {
    AppStorage.set<Language>('language', lang)
    this.save('language', lang)
  }

  // 在 EntryAbility.onBackground 中调用，确保进入后台时数据已落盘
  flush(): void {
    this.prefs?.flush()
  }

  private save(key: string, value: string): void {
    if (!this.prefs) return
    this.prefs.putSync(key, value)
    this.prefs.flush() // 立即启动异步写盘，用户正常操作下足够在杀进程前完成
  }

  private applyColorMode(mode: ThemeMode): void {
    try {
      const colorMode = mode === 'dark'
        ? ConfigurationConstant.ColorMode.COLOR_MODE_DARK
        : ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT
      getContext().getApplicationContext().setColorMode(colorMode)
    } catch (_) {}
  }
}

export const SettingsService = new SettingsServiceImpl()
