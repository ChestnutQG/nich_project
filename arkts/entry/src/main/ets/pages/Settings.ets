// 设置页面 — 国风版
import { router } from '@kit.ArkUI'
import { Colors } from '../common/Colors'
import { NavBar } from '../components/NavBar'
import { SettingsService, ThemeMode, FontScale, Language } from '../service/SettingsService'
import { Theme } from '../common/Theme'

@Entry
@Component
struct Settings {
  @StorageLink('theme') theme: ThemeMode = 'light'
  @StorageLink('fontScale') fontScale: FontScale = 'normal'
  @StorageLink('language') language: Language = 'zh'

  t(zh: string, en: string): string { return this.language === 'en' ? en : zh }

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

          // ══════ 外观 ══════
          this.SectionLabel(this.t('外观', 'Appearance'))

          Column() {
            // 主题 — 深浅切换
            Row() {
              Text(this.t('主题', 'Theme'))
                .fontSize(this.baseFontSize())
                .fontColor(Theme.textPrimary(this.theme))
                .layoutWeight(1)

              Row({ space: 8 }) {
                Text('☀️ ' + this.t('浅色', 'Light'))
                  .fontSize(13)
                  .fontColor(this.theme === 'light' ? Theme.WHITE : Theme.textSecondary(this.theme))
                  .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                  .borderRadius(3)
                  .backgroundColor(this.theme === 'light' ? Theme.primary(this.theme) : Color.Transparent)
                  .border({ width: 1, color: this.theme === 'light' ? Theme.primary(this.theme) : Theme.divider(this.theme) })
                  .onClick(() => { SettingsService.setTheme('light') })

                Text('🌙 ' + this.t('深色', 'Dark'))
                  .fontSize(13)
                  .fontColor(this.theme === 'dark' ? Theme.WHITE : Theme.textSecondary(this.theme))
                  .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                  .borderRadius(3)
                  .backgroundColor(this.theme === 'dark' ? Theme.primary(this.theme) : Color.Transparent)
                  .border({ width: 1, color: this.theme === 'dark' ? Theme.primary(this.theme) : Theme.divider(this.theme) })
                  .onClick(() => { SettingsService.setTheme('dark') })
              }
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 14, bottom: 14 })

            // 绢色分割
            Row()
              .width('100%')
              .height(0.5)
              .backgroundColor(Theme.divider(this.theme))
              .margin({ left: 16 })

            // 字体大小
            Row() {
              Text(this.t('字体大小', 'Font Size'))
                .fontSize(this.baseFontSize())
                .fontColor(Theme.textPrimary(this.theme))
                .layoutWeight(1)

              Row({ space: 8 }) {
                Text(this.t('小', 'S'))
                  .fontSize(12)
                  .fontColor(this.fontScale === 'small' ? Theme.WHITE : Theme.textSecondary(this.theme))
                  .width(36).height(32)
                  .textAlign(TextAlign.Center)
                  .borderRadius(3)
                  .backgroundColor(this.fontScale === 'small' ? Theme.primary(this.theme) : Color.Transparent)
                  .border({ width: 1, color: this.fontScale === 'small' ? Theme.primary(this.theme) : Theme.divider(this.theme) })
                  .onClick(() => { SettingsService.setFontScale('small') })

                Text(this.t('标准', 'M'))
                  .fontSize(15)
                  .fontColor(this.fontScale === 'normal' ? Theme.WHITE : Theme.textSecondary(this.theme))
                  .width(36).height(32)
                  .textAlign(TextAlign.Center)
                  .borderRadius(3)
                  .backgroundColor(this.fontScale === 'normal' ? Theme.primary(this.theme) : Color.Transparent)
                  .border({ width: 1, color: this.fontScale === 'normal' ? Theme.primary(this.theme) : Theme.divider(this.theme) })
                  .onClick(() => { SettingsService.setFontScale('normal') })

                Text(this.t('大', 'L'))
                  .fontSize(18)
                  .fontColor(this.fontScale === 'large' ? Theme.WHITE : Theme.textSecondary(this.theme))
                  .width(36).height(32)
                  .textAlign(TextAlign.Center)
                  .borderRadius(3)
                  .backgroundColor(this.fontScale === 'large' ? Theme.primary(this.theme) : Color.Transparent)
                  .border({ width: 1, color: this.fontScale === 'large' ? Theme.primary(this.theme) : Theme.divider(this.theme) })
                  .onClick(() => { SettingsService.setFontScale('large') })
              }
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 14, bottom: 14 })
          }
          .width('100%')
          .backgroundColor(Theme.card(this.theme))
          .borderRadius(4)
          .border({ width: 0.5, color: Theme.divider(this.theme) })
          .margin({ left: 16, right: 16, top: 0 })

          // ══════ 语言 ══════
          this.SectionLabel(this.t('语言', 'Language'))

          Column() {
            Row() {
              Text(this.t('显示语言', 'Display Language'))
                .fontSize(this.baseFontSize())
                .fontColor(Theme.textPrimary(this.theme))
                .layoutWeight(1)

              Row({ space: 8 }) {
                Text('简体中文')
                  .fontSize(13)
                  .fontColor(this.language === 'zh' ? Theme.WHITE : Theme.textSecondary(this.theme))
                  .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                  .borderRadius(3)
                  .backgroundColor(this.language === 'zh' ? Theme.primary(this.theme) : Color.Transparent)
                  .border({ width: 1, color: this.language === 'zh' ? Theme.primary(this.theme) : Theme.divider(this.theme) })
                  .onClick(() => { SettingsService.setLanguage('zh') })

                Text('English')
                  .fontSize(13)
                  .fontColor(this.language === 'en' ? Theme.WHITE : Theme.textSecondary(this.theme))
                  .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                  .borderRadius(3)
                  .backgroundColor(this.language === 'en' ? Theme.primary(this.theme) : Color.Transparent)
                  .border({ width: 1, color: this.language === 'en' ? Theme.primary(this.theme) : Theme.divider(this.theme) })
                  .onClick(() => { SettingsService.setLanguage('en') })
              }
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 14, bottom: 14 })
          }
          .width('100%')
          .backgroundColor(Theme.card(this.theme))
          .borderRadius(4)
          .border({ width: 0.5, color: Theme.divider(this.theme) })
          .margin({ left: 16, right: 16, top: 0 })

          // ══════ 效果预览 ══════
          this.SectionLabel(this.t('效果预览', 'Preview'))

          Column() {
            // 预览卡片标题
            Row() {
              Column()
                .width(3).height(16)
                .backgroundColor(Theme.primary(this.theme))
                .margin({ right: 8 })
              Text(this.t('锤子铺', 'Chuizhi'))
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor(Theme.textPrimary(this.theme))
                .letterSpacing(2)
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 16 })

            Text(this.t('正文文本 — 感受字体大小与墨色', 'Body text — feel the font size & ink color'))
              .fontSize(this.baseFontSize())
              .fontColor(Theme.textPrimary(this.theme))
              .width('100%')
              .padding({ left: 16, right: 16, top: 12, bottom: 6 })

            Text(this.t('次要说明 — 茶色，轻于墨', 'Secondary text — tea color, lighter than ink'))
              .fontSize(this.baseFontSize() - 2)
              .fontColor(Theme.textSecondary(this.theme))
              .width('100%')
              .padding({ left: 16, right: 16, bottom: 4 })

            Text(this.t('提示文字 — 烟灰色，若有似无', 'Hint text — smoke gray, barely there'))
              .fontSize(this.baseFontSize() - 3)
              .fontColor(Theme.textHint(this.theme))
              .width('100%')
              .padding({ left: 16, right: 16, bottom: 12 })

            // 配色预览条
            Row({ space: 6 }) {
              Column().width(24).height(24).borderRadius(3).backgroundColor(Theme.primary(this.theme))
              Column().width(24).height(24).borderRadius(3).backgroundColor(Theme.gold(this.theme))
              Column().width(24).height(24).borderRadius(3).backgroundColor(Theme.accent(this.theme))
              Column().width(24).height(24).borderRadius(3).backgroundColor(Theme.success(this.theme))
              Column().width(24).height(24).borderRadius(3).backgroundColor(Theme.warning(this.theme))
              Column().width(24).height(24).borderRadius(3).backgroundColor(Theme.error(this.theme))
            }
            .width('100%')
            .padding({ left: 16, right: 16, bottom: 8 })

            // 当前配置摘要
            Row() {
              Text(this.t('当前', 'Current') + '：')
                .fontSize(12)
                .fontColor(Theme.textSecondary(this.theme))
              Text(this.configSummary())
                .fontSize(12)
                .fontColor(Theme.primary(this.theme))
                .fontWeight(FontWeight.Medium)
            }
            .width('100%')
            .padding({ left: 16, right: 16, bottom: 16 })
          }
          .width('100%')
          .backgroundColor(Theme.card(this.theme))
          .borderRadius(4)
          .border({ width: 0.5, color: Theme.divider(this.theme) })
          .margin({ left: 16, right: 16, top: 0 })

          // ══════ 关于 ══════
          this.SectionLabel(this.t('关于', 'About'))

          Column() {
            Row() {
              Text(this.t('锤子铺 · 非遗手工艺品平台', 'Chuizhi · Heritage Crafts'))
                .fontSize(this.baseFontSize())
                .fontColor(Theme.textPrimary(this.theme))
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 14, bottom: 4 })

            Text('v1.0.0')
              .fontSize(12)
              .fontColor(Theme.textHint(this.theme))
              .width('100%')
              .padding({ left: 16, right: 16, bottom: 14 })
          }
          .width('100%')
          .backgroundColor(Theme.card(this.theme))
          .borderRadius(4)
          .border({ width: 0.5, color: Theme.divider(this.theme) })
          .margin({ left: 16, right: 16, top: 0 })

          Row().height(24)
        }
        .padding({ top: 12 })
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor(Theme.bg(this.theme))
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.bg(this.theme))
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
      .fontColor(Theme.textSecondary(this.theme))
      .width('100%')
      .padding({ left: 28, top: 20, bottom: 8 })
  }
}
