// 应用设置服务 — 显式传入 context，避免 getContext() 在 Ability 启动阶段失效
import { preferences } from '@kit.ArkData'
import { ConfigurationConstant, common } from '@kit.AbilityKit'

export type ThemeMode = 'light' | 'dark'
export type FontScale = 'small' | 'normal' | 'large'
export type Language = 'zh' | 'en'

const PREFS_NAME = 'app_settings'

class SettingsServiceImpl {
  private prefs: preferences.Preferences | null = null
  private ctx: common.UIAbilityContext | null = null

  // 由 EntryAbility.onCreate 显式传入 this.context，早于任何页面初始化
  init(context: common.UIAbilityContext): void {
    this.ctx = context
    try {
      this.prefs = preferences.getPreferencesSync(context, { name: PREFS_NAME })
      const theme     = this.prefs.getSync('theme',     'light')  as ThemeMode
      const fontScale = this.prefs.getSync('fontScale', 'normal') as FontScale
      const language  = this.prefs.getSync('language',  'zh')     as Language
      AppStorage.setOrCreate<ThemeMode>('theme',     theme)
      AppStorage.setOrCreate<FontScale>('fontScale', fontScale)
      AppStorage.setOrCreate<Language>('language',   language)
      this.applyColorMode(theme)
    } catch (e) {
      // 首次安装无存档，使用默认值
      AppStorage.setOrCreate<ThemeMode>('theme',     'light')
      AppStorage.setOrCreate<FontScale>('fontScale', 'normal')
      AppStorage.setOrCreate<Language>('language',   'zh')
    }
  }

  ensureInit(): void {} // 兼容旧调用

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

  // 进入后台时由 EntryAbility.onBackground 主动调用，确保数据落盘
  flush(): void {
    this.prefs?.flush()
  }

  private save(key: string, value: string): void {
    if (!this.prefs) return
    this.prefs.putSync(key, value)
    this.prefs.flush()
  }

  private applyColorMode(mode: ThemeMode): void {
    try {
      const colorMode = mode === 'dark'
        ? ConfigurationConstant.ColorMode.COLOR_MODE_DARK
        : ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT
      // 优先用存储的 context，fallback 到 getContext()
      const ctx = this.ctx ?? getContext()
      ctx.getApplicationContext().setColorMode(colorMode)
    } catch (_) {}
  }
}

export const SettingsService = new SettingsServiceImpl()
