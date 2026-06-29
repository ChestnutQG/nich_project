// 设置页面 — 主题/字体/语言，实时生效 + 持久化
import { router } from '@kit.ArkUI'
import { Colors } from '../common/Colors'
import { NavBar } from '../components/NavBar'
import { SettingsService, ThemeMode, FontScale, Language } from '../service/SettingsService'

@Entry
@Component
struct Settings {
  @StorageLink('theme') theme: ThemeMode = 'light'
  @StorageLink('fontScale') fontScale: FontScale = 'normal'
  @StorageLink('language') language: Language = 'zh'

  // 根据主题返回对应色值
  bgPage(): string { return this.theme === 'dark' ? '#121212' : '#F5F5F5' }
  bgCard(): string { return this.theme === 'dark' ? '#1E1E1E' : '#FFFFFF' }
  bgSelected(): string { return this.theme === 'dark' ? '#3A1F1F' : Colors.PRIMARY_BG }
  textPrimary(): string { return this.theme === 'dark' ? '#EEEEEE' : Colors.TEXT_PRIMARY }
  textSecondary(): string { return this.theme === 'dark' ? '#AAAAAA' : Colors.TEXT_SECONDARY }
  dividerColor(): string { return this.theme === 'dark' ? '#2A2A2A' : Colors.DIVIDER }

  // 双语文本
  t(zh: string, en: string): string { return this.language === 'en' ? en : zh }

  // 字体基准尺寸
  baseFontSize(): number {
    if (this.fontScale === 'small') return 13
    if (this.fontScale === 'large') return 18
    return 15
  }

  aboutToAppear(): void {
    SettingsService.ensureInit()
  }

  build() {
    Column() {
      NavBar({ title: this.t('设置', 'Settings'), showBack: true })

      Scroll() {
        Column({ space: 0 }) {

          // ── 外观 ──
          this.SectionLabel(this.t('外观', 'Appearance'))

          Column() {
            // 主题
            Row() {
              Text(this.t('主题', 'Theme'))
                .fontSize(this.baseFontSize())
                .fontColor(this.textPrimary())
                .layoutWeight(1)

              Row({ space: 8 }) {
                this.ThemeChip('☀️ ' + this.t('浅色', 'Light'), 'light')
                this.ThemeChip('🌙 ' + this.t('深色', 'Dark'), 'dark')
              }
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 14, bottom: 14 })

            Divider()
              .color(this.dividerColor())
              .margin({ left: 16 })

            // 字体大小
            Row() {
              Text(this.t('字体大小', 'Font Size'))
                .fontSize(this.baseFontSize())
                .fontColor(this.textPrimary())
                .layoutWeight(1)

              Row({ space: 8 }) {
                this.FontChip(this.t('小', 'S'), 12, 'small')
                this.FontChip(this.t('标准', 'M'), 15, 'normal')
                this.FontChip(this.t('大', 'L'), 18, 'large')
              }
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 14, bottom: 14 })
          }
          .width('100%')
          .backgroundColor(this.bgCard())
          .borderRadius(8)
          .margin({ left: 16, right: 16, top: 0 })

          // ── 语言 ──
          this.SectionLabel(this.t('语言', 'Language'))

          Column() {
            Row() {
              Text(this.t('显示语言', 'Display Language'))
                .fontSize(this.baseFontSize())
                .fontColor(this.textPrimary())
                .layoutWeight(1)

              Row({ space: 8 }) {
                this.LangChip('简体中文', 'zh')
                this.LangChip('English', 'en')
              }
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 14, bottom: 14 })
          }
          .width('100%')
          .backgroundColor(this.bgCard())
          .borderRadius(8)
          .margin({ left: 16, right: 16, top: 0 })

          // ── 预览 ──
          this.SectionLabel(this.t('效果预览', 'Preview'))

          Column() {
            Text(this.t('这是正文文本，感受字体大小变化', 'This is body text — feel the font size change'))
              .fontSize(this.baseFontSize())
              .fontColor(this.textPrimary())
              .padding({ left: 16, right: 16, top: 16, bottom: 8 })

            Text(this.t('这是次要说明文字，颜色稍浅', 'Secondary text with lighter color'))
              .fontSize(this.baseFontSize() - 2)
              .fontColor(this.textSecondary())
              .padding({ left: 16, right: 16, bottom: 16 })

            Row() {
              Text(this.t('当前配置', 'Current Config'))
                .fontSize(12)
                .fontColor(this.textSecondary())
              Text(this.configSummary())
                .fontSize(12)
                .fontColor(Colors.PRIMARY)
                .margin({ left: 8 })
            }
            .padding({ left: 16, right: 16, bottom: 16 })
          }
          .width('100%')
          .backgroundColor(this.bgCard())
          .borderRadius(8)
          .margin({ left: 16, right: 16, top: 0 })

          Row().height(24)
        }
        .padding({ top: 12 })
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor(this.bgPage())
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.bgPage())
  }

  configSummary(): string {
    const themeStr = this.theme === 'dark' ? this.t('深色', 'Dark') : this.t('浅色', 'Light')
    const fontStr = this.fontScale === 'small'
      ? this.t('小', 'S')
      : this.fontScale === 'large' ? this.t('大', 'L') : this.t('标准', 'M')
    const langStr = this.language === 'en' ? 'EN' : '中'
    return `${themeStr} · ${fontStr} · ${langStr}`
  }

  @Builder
  SectionLabel(label: string) {
    Text(label)
      .fontSize(12)
      .fontColor(this.textSecondary())
      .width('100%')
      .padding({ left: 28, top: 16, bottom: 6 })
  }

  // 主题选项按钮 — 在 builder 内部读 this.theme，保证响应式
  @Builder
  ThemeChip(label: string, value: ThemeMode) {
    Text(label)
      .fontSize(13)
      .fontColor(this.theme === value ? Colors.PRIMARY : this.textSecondary())
      .padding({ left: 10, right: 10, top: 5, bottom: 5 })
      .borderRadius(6)
      .border({ width: 1.5, color: this.theme === value ? Colors.PRIMARY : this.dividerColor() })
      .backgroundColor(this.theme === value ? this.bgSelected() : 'transparent')
      .onClick(() => { SettingsService.setTheme(value) })
  }

  // 语言选项按钮 — 同理，在 builder 内部读 this.language
  @Builder
  LangChip(label: string, value: Language) {
    Text(label)
      .fontSize(13)
      .fontColor(this.language === value ? Colors.PRIMARY : this.textSecondary())
      .padding({ left: 10, right: 10, top: 5, bottom: 5 })
      .borderRadius(6)
      .border({ width: 1.5, color: this.language === value ? Colors.PRIMARY : this.dividerColor() })
      .backgroundColor(this.language === value ? this.bgSelected() : 'transparent')
      .onClick(() => { SettingsService.setLanguage(value) })
  }

  // 字体大小选项按钮，文字本身即示例
  @Builder
  FontChip(label: string, size: number, scale: FontScale) {
    Text(label)
      .fontSize(size)
      .fontColor(this.fontScale === scale ? Colors.PRIMARY : this.textSecondary())
      .width(36)
      .height(32)
      .textAlign(TextAlign.Center)
      .borderRadius(6)
      .border({ width: 1.5, color: this.fontScale === scale ? Colors.PRIMARY : this.dividerColor() })
      .backgroundColor(this.fontScale === scale ? this.bgSelected() : 'transparent')
      .onClick(() => { SettingsService.setFontScale(scale) })
  }
}
