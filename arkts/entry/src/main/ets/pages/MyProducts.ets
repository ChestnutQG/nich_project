import { router, promptAction } from '@kit.ArkUI'
import { Constants } from '../common/Constants'
import { Product } from '../model/Product'
import { ProductService } from '../service/ProductService'
import { NavBar } from '../components/NavBar'
import { Theme } from '../common/Theme'
import { ThemeMode, FontScale, Language } from '../service/SettingsService'

@Entry
@Component
struct MyProducts {
  @State products: Product[] = []
  @State loading: boolean = true
  @State deletingId: string = ''

  @StorageProp('theme') theme: ThemeMode = 'light'
  @StorageProp('fontScale') fontScale: FontScale = 'normal'
  @StorageProp('language') language: Language = 'zh'

  fs(n: number): number {
    return Math.round(n * (this.fontScale === 'small' ? 0.85 : this.fontScale === 'large' ? 1.2 : 1.0))
  }

  t(zh: string, en: string): string {
    return this.language === 'en' ? en : zh
  }

  aboutToAppear(): void {
    this.loadProducts()
  }

  onPageShow(): void {
    this.loadProducts()
  }

  async loadProducts(): Promise<void> {
    this.loading = true
    const resp = await ProductService.fetchMyProducts()
    if (resp.code === 0) {
      this.products = resp.data
    } else {
      promptAction.showToast({ message: resp.message || this.t('加载失败', 'Failed to load') })
    }
    this.loading = false
  }

  statusText(status?: string): string {
    if (status === 'approved') return this.t('已通过', 'Approved')
    if (status === 'rejected') return this.t('已驳回', 'Rejected')
    return this.t('待审核', 'Pending')
  }

  statusColor(status?: string): string {
    if (status === 'approved') return Theme.success(this.theme)
    if (status === 'rejected') return Theme.error(this.theme)
    return Theme.warning(this.theme)
  }

  confirmDelete(product: Product): void {
    AlertDialog.show({
      title: this.t('删除作品', 'Delete Work'),
      message: this.t(`确定删除“${product.name}”吗？删除后将不再展示。`,
        `Delete "${product.name}"? It will no longer be visible.`),
      primaryButton: {
        value: this.t('取消', 'Cancel'),
        action: () => {}
      },
      secondaryButton: {
        value: this.t('删除', 'Delete'),
        fontColor: Theme.error(this.theme),
        action: () => { this.deleteProduct(product.id) }
      }
    })
  }

  async deleteProduct(id: string): Promise<void> {
    if (this.deletingId !== '') return
    this.deletingId = id
    const resp = await ProductService.deleteMyProduct(id)
    if (resp.code === 0) {
      this.products = this.products.filter((item: Product) => item.id !== id)
      promptAction.showToast({ message: this.t('作品已删除', 'Work deleted') })
    } else {
      promptAction.showToast({ message: resp.message || this.t('删除失败', 'Delete failed') })
    }
    this.deletingId = ''
  }

  build() {
    Column() {
      NavBar({ title: this.t('管理作品', 'Manage Works'), showBack: true })

      if (this.loading) {
        Column() {
          LoadingProgress().width(32).height(32).color(Theme.primary(this.theme))
        }
        .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
      } else if (this.products.length === 0) {
        Column() {
          Text('🗂️').fontSize(this.fs(48)).opacity(0.6)
          Text(this.t('还没有发布作品', 'No works published'))
            .fontSize(this.fs(14)).fontColor(Theme.textHint(this.theme)).margin({ top: 10 })
          Button(this.t('发布作品', 'Publish Work'))
            .fontSize(this.fs(14)).fontColor(Theme.WHITE)
            .backgroundColor(Theme.primary(this.theme))
            .margin({ top: 18 })
            .onClick(() => router.pushUrl({ url: Constants.PAGE_PRODUCT_PUBLISH }))
        }
        .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
      } else {
        List({ space: 10 }) {
          ForEach(this.products, (product: Product) => {
            ListItem() {
              Row() {
                Image(product.images && product.images.length > 0 ? product.images[0] : '')
                  .width(86).height(86).objectFit(ImageFit.Cover)
                  .borderRadius(6).backgroundColor(Theme.divider(this.theme))
                  .onClick(() => router.pushUrl({
                    url: Constants.PAGE_PRODUCT_DETAIL,
                    params: { productId: product.id }
                  }))

                Column() {
                  Row() {
                    Text(product.name)
                      .fontSize(this.fs(15)).fontColor(Theme.textPrimary(this.theme))
                      .maxLines(2).textOverflow({ overflow: TextOverflow.Ellipsis })
                      .layoutWeight(1)
                    Text(this.statusText(product.auditStatus))
                      .fontSize(this.fs(11)).fontColor(this.statusColor(product.auditStatus))
                      .margin({ left: 8 })
                  }.width('100%')

                  Text(product.isSellable ? `¥${(product.price / 100).toFixed(2)}` : this.t('仅展示', 'Display only'))
                    .fontSize(this.fs(13)).fontColor(Theme.primary(this.theme)).margin({ top: 8 })

                  Row() {
                    Blank()
                    Button(this.deletingId === product.id ? this.t('删除中…', 'Deleting…') : this.t('删除', 'Delete'))
                      .fontSize(this.fs(12)).fontColor(Theme.error(this.theme))
                      .backgroundColor(Color.Transparent)
                      .border({ width: 1, color: Theme.error(this.theme) })
                      .height(30)
                      .enabled(this.deletingId === '')
                      .onClick(() => this.confirmDelete(product))
                  }.width('100%').margin({ top: 8 })
                }
                .layoutWeight(1).margin({ left: 12 }).alignItems(HorizontalAlign.Start)
              }
              .width('100%').padding(12)
              .backgroundColor(Theme.card(this.theme))
              .borderRadius(6)
              .border({ width: 0.5, color: Theme.divider(this.theme) })
            }
          }, (product: Product) => product.id)
        }
        .width('100%').layoutWeight(1)
        .padding({ left: 16, right: 16, top: 12, bottom: 16 })
      }
    }
    .width('100%').height('100%').backgroundColor(Theme.bg(this.theme))
  }
}
