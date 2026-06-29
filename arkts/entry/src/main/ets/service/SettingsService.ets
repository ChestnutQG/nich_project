// 应用设置服务 — PersistentStorage 自动持久化，无异步竞态
// PersistentStorage 作为 AppStorage ↔ 磁盘的桥接层，修改 AppStorage 即自动写盘
import { ConfigurationConstant } from '@kit.AbilityKit'

export type ThemeMode = 'light' | 'dark'
export type FontScale = 'small' | 'normal' | 'large'
export type Language = 'zh' | 'en'

class SettingsServiceImpl {

  // 在 EntryAbility.onCreate() 里同步调用，必须早于任何页面/组件初始化
  // PersistentStorage.persistProp 会从磁盘读取存档值写入 AppStorage，
  // 保证 @StorageLink 初始化时拿到的是上次保存的值而不是默认值
  init(): void {
    PersistentStorage.persistProp<ThemeMode>('theme', 'light')
    PersistentStorage.persistProp<FontScale>('fontScale', 'normal')
    PersistentStorage.persistProp<Language>('language', 'zh')
    // 还原上次保存的系统颜色模式（影响状态栏等系统 UI）
    const theme = AppStorage.get<ThemeMode>('theme') ?? 'light'
    this.applyColorMode(theme)
  }

  // 兼容旧调用，init 已在 Ability 启动时处理，这里无需再做
  ensureInit(): void {}

  setTheme(mode: ThemeMode): void {
    AppStorage.set<ThemeMode>('theme', mode)
    // PersistentStorage 监听到 AppStorage 变化后自动写盘，不用手动 flush
    this.applyColorMode(mode)
  }

  setFontScale(scale: FontScale): void {
    AppStorage.set<FontScale>('fontScale', scale)
  }

  setLanguage(lang: Language): void {
    AppStorage.set<Language>('language', lang)
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
