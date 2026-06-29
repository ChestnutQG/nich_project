// 应用设置服务 — 主题/字体/语言持久化 + AppStorage 同步
import { preferences } from '@kit.ArkData'
import { ConfigurationConstant } from '@kit.AbilityKit'

const PREFS_NAME = 'app_settings'

export type ThemeMode = 'light' | 'dark'
export type FontScale = 'small' | 'normal' | 'large'
export type Language = 'zh' | 'en'

class SettingsServiceImpl {
  private prefs: preferences.Preferences | null = null
  private initialized = false

  // 首次访问时从磁盘恢复设置
  async ensureInit(): Promise<void> {
    if (this.initialized) return
    try {
      this.prefs = await preferences.getPreferences(getContext(), PREFS_NAME)
      const theme = this.prefs.getSync('theme', 'light') as ThemeMode
      const fontScale = this.prefs.getSync('fontScale', 'normal') as FontScale
      const language = this.prefs.getSync('language', 'zh') as Language
      AppStorage.setOrCreate<ThemeMode>('theme', theme)
      AppStorage.setOrCreate<FontScale>('fontScale', fontScale)
      AppStorage.setOrCreate<Language>('language', language)
      this.applyColorMode(theme)
    } catch (_) {
      AppStorage.setOrCreate<ThemeMode>('theme', 'light')
      AppStorage.setOrCreate<FontScale>('fontScale', 'normal')
      AppStorage.setOrCreate<Language>('language', 'zh')
    }
    this.initialized = true
  }

  // 切换系统颜色模式，影响状态栏等系统 UI
  private applyColorMode(mode: ThemeMode): void {
    try {
      const colorMode = mode === 'dark'
        ? ConfigurationConstant.ColorMode.COLOR_MODE_DARK
        : ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT
      getContext().getApplicationContext().setColorMode(colorMode)
    } catch (_) {
      // 部分环境不支持，忽略
    }
  }

  async setTheme(mode: ThemeMode): Promise<void> {
    AppStorage.set<ThemeMode>('theme', mode)
    this.applyColorMode(mode)
    await this.persist('theme', mode)
  }

  async setFontScale(scale: FontScale): Promise<void> {
    AppStorage.set<FontScale>('fontScale', scale)
    await this.persist('fontScale', scale)
  }

  async setLanguage(lang: Language): Promise<void> {
    AppStorage.set<Language>('language', lang)
    await this.persist('language', lang)
  }

  private async persist(key: string, value: string): Promise<void> {
    if (!this.prefs) return
    try {
      this.prefs.putSync(key, value)
      await this.prefs.flush()
    } catch (_) {}
  }
}

export const SettingsService = new SettingsServiceImpl()
