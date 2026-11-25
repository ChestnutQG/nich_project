// 发布作品页面 — 支持选择是否售卖
import { router } from '@kit.ArkUI'
import { promptAction } from '@kit.ArkUI'
import { photoAccessHelper } from '@kit.MediaLibraryKit'
import { Colors } from '../common/Colors'
import { Constants } from '../common/Constants'
import { NavBar } from '../components/NavBar'
import { ProductService } from '../service/ProductService'
import { CategoryService } from '../service/CategoryService'
import { Category } from '../model/Category'
import { ApiClient } from '../service/ApiClient'
import { Theme } from '../common/Theme'
import { ThemeMode, FontScale, Language } from '../service/SettingsService'

@Entry
@Component
struct ProductPublish {
  @State name: string = ''
  @State description: string = ''
  @State categoryId: number = 1
  @State selectedCategoryName: string = '传统技艺'
  @State isSellable: boolean = true
  @State price: string = ''
  @State originalPrice: string = ''
  @State stock: string = '1'
  @State region: string = ''
  @State craftType: string = ''
  @State tags: string = ''
  @State selectedUris: string[] = []
  @State uploadedUrls: string[] = []
  @State submitting: boolean = false
  @State uploading: boolean = false

  @State private categoryList: Category[] = []

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
    this.loadCategories()
  }

  async loadCategories(): Promise<void> {
    const resp = await CategoryService.fetchCategories()
    if (resp.code === 0 && resp.data.length > 0) {
      this.categoryList = resp.data
      const first = resp.data[0]
      this.categoryId = parseInt(first.id)
      this.selectedCategoryName = first.name
    }
  }

  build() {
    Column() {
      NavBar({ title: this.t('发布作品', 'Publish Work'), showBack: true })

      Scroll() {
        Column() {
          // 基本信息
          Text(this.t('基本信息', 'Basic Info'))
            .fontSize(this.fs(13)).fontColor(Theme.textSecondary(this.theme)).width('100%')
            .padding({ left: 16, right: 16, top: 20, bottom: 8 })

          Row() {
            Text(`${this.t('作品名称', 'Name')} *`).fontSize(this.fs(14)).fontColor(Theme.textPrimary(this.theme)).width(100)
            TextInput({ placeholder: this.t('请输入作品名称', 'Enter work name') })
              .fontSize(this.fs(14)).fontColor(Theme.textPrimary(this.theme)).placeholderColor(Theme.textHint(this.theme))
              .backgroundColor(Color.Transparent).layoutWeight(1)
              .onChange((v: string) => { this.name = v })
          }
          .width('100%').padding({ left: 16, right: 16, top: 12, bottom: 12 }).backgroundColor(Theme.card(this.theme))

          Divider().color(Theme.divider(this.theme)).margin({ left: 16 })

          Row() {
            Text(this.t('作品描述', 'Description')).fontSize(this.fs(14)).fontColor(Theme.textPrimary(this.theme)).width(100)
            TextInput({ placeholder: this.t('简要描述作品特点', 'Brief description') })
              .fontSize(this.fs(14)).fontColor(Theme.textPrimary(this.theme)).placeholderColor(Theme.textHint(this.theme))
              .backgroundColor(Color.Transparent).layoutWeight(1)
              .onChange((v: string) => { this.description = v })
          }
          .width('100%').padding({ left: 16, right: 16, top: 12, bottom: 12 }).backgroundColor(Theme.card(this.theme))

          Divider().color(Theme.divider(this.theme)).margin({ left: 16 })

          Row() {
            Text(this.t('非遗分类', 'Category')).fontSize(this.fs(14)).fontColor(Theme.textPrimary(this.theme)).width(80)
            Blank()
            Text(this.selectedCategoryName).fontSize(this.fs(14)).fontColor(Theme.primary(this.theme)).margin({ right: 4 })
            Text('▼').fontSize(this.fs(10)).fontColor(Theme.textHint(this.theme))
          }
          .width('100%').padding({ left: 16, right: 16, top: 14, bottom: 14 }).backgroundColor(Theme.card(this.theme))
          .onClick(() => { this.showCategoryPicker() })

          Divider().color(Theme.divider(this.theme)).margin({ left: 16 })

          Row() {
            Text(this.t('是否售卖', 'For Sale')).fontSize(this.fs(14)).fontColor(Theme.textPrimary(this.theme)).layoutWeight(1)
            Toggle({ type: ToggleType.Switch, isOn: this.isSellable })
              .selectedColor(Theme.primary(this.theme))
              .onChange((v: boolean) => { this.isSellable = v })
          }
          .width('100%').padding({ left: 16, right: 16, top: 14, bottom: 14 }).backgroundColor(Theme.card(this.theme))

          if (this.isSellable) {
            Text(this.t('价格与库存', 'Price & Stock'))
              .fontSize(this.fs(13)).fontColor(Theme.textSecondary(this.theme)).width('100%')
              .padding({ left: 16, right: 16, top: 20, bottom: 8 })

            Row() {
              Text(`${this.t('售价', 'Price')} *（${this.t('元', 'CNY')}）`).fontSize(this.fs(14)).fontColor(Theme.textPrimary(this.theme)).width(100)
              TextInput({ placeholder: this.t('例如 1280', 'e.g. 1280') })
                .fontSize(this.fs(14)).fontColor(Theme.textPrimary(this.theme)).placeholderColor(Theme.textHint(this.theme))
                .backgroundColor(Color.Transparent).layoutWeight(1).type(InputType.Number)
                .onChange((v: string) => { this.price = v })
            }
            .width('100%').padding({ left: 16, right: 16, top: 12, bottom: 12 }).backgroundColor(Theme.card(this.theme))

            Divider().color(Theme.divider(this.theme)).margin({ left: 16 })

            Row() {
              Text(`${this.t('原价', 'Original')}（${this.t('元', 'CNY')}）`).fontSize(this.fs(14)).fontColor(Theme.textPrimary(this.theme)).width(100)
              TextInput({ placeholder: this.t('划线价，可不填', 'Optional') })
                .fontSize(this.fs(14)).fontColor(Theme.textPrimary(this.theme)).placeholderColor(Theme.textHint(this.theme))
                .backgroundColor(Color.Transparent).layoutWeight(1).type(InputType.Number)
                .onChange((v: string) => { this.originalPrice = v })
            }
            .width('100%').padding({ left: 16, right: 16, top: 12, bottom: 12 }).backgroundColor(Theme.card(this.theme))

            Divider().color(Theme.divider(this.theme)).margin({ left: 16 })

            Row() {
              Text(this.t('库存数量', 'Stock')).fontSize(this.fs(14)).fontColor(Theme.textPrimary(this.theme)).width(100)
              TextInput({ placeholder: '1', text: '1' })
                .fontSize(this.fs(14)).fontColor(Theme.textPrimary(this.theme)).placeholderColor(Theme.textHint(this.theme))
                .backgroundColor(Color.Transparent).layoutWeight(1).type(InputType.Number)
                .onChange((v: string) => { this.stock = v })
            }
            .width('100%').padding({ left: 16, right: 16, top: 12, bottom: 12 }).backgroundColor(Theme.card(this.theme))
          }

          Text(this.t('产地与技艺', 'Origin & Craft'))
            .fontSize(this.fs(13)).fontColor(Theme.textSecondary(this.theme)).width('100%')
            .padding({ left: 16, right: 16, top: 20, bottom: 8 })

          Row() {
            Text(this.t('产地', 'Region')).fontSize(this.fs(14)).fontColor(Theme.textPrimary(this.theme)).width(100)
            TextInput({ placeholder: this.t('例如：江苏苏州', 'e.g. Suzhou, Jiangsu') })
              .fontSize(this.fs(14)).fontColor(Theme.textPrimary(this.theme)).placeholderColor(Theme.textHint(this.theme))
              .backgroundColor(Color.Transparent).layoutWeight(1)
              .onChange((v: string) => { this.region = v })
          }
          .width('100%').padding({ left: 16, right: 16, top: 12, bottom: 12 }).backgroundColor(Theme.card(this.theme))

          Divider().color(Theme.divider(this.theme)).margin({ left: 16 })

          Row() {
            Text(this.t('技艺类型', 'Craft')).fontSize(this.fs(14)).fontColor(Theme.textPrimary(this.theme)).width(100)
            TextInput({ placeholder: this.t('例如：苏绣、青花瓷', 'e.g. Suzhou Embroidery') })
              .fontSize(this.fs(14)).fontColor(Theme.textPrimary(this.theme)).placeholderColor(Theme.textHint(this.theme))
              .backgroundColor(Color.Transparent).layoutWeight(1)
              .onChange((v: string) => { this.craftType = v })
          }
          .width('100%').padding({ left: 16, right: 16, top: 12, bottom: 12 }).backgroundColor(Theme.card(this.theme))

          Divider().color(Theme.divider(this.theme)).margin({ left: 16 })

          Row() {
            Text(this.t('标签', 'Tags')).fontSize(this.fs(14)).fontColor(Theme.textPrimary(this.theme)).width(100)
            TextInput({ placeholder: this.t('多个用逗号分隔', 'Comma separated') })
              .fontSize(this.fs(14)).fontColor(Theme.textPrimary(this.theme)).placeholderColor(Theme.textHint(this.theme))
              .backgroundColor(Color.Transparent).layoutWeight(1)
              .onChange((v: string) => { this.tags = v })
          }
          .width('100%').padding({ left: 16, right: 16, top: 12, bottom: 12 }).backgroundColor(Theme.card(this.theme))

          Text(this.t('作品图片', 'Images'))
            .fontSize(this.fs(13)).fontColor(Theme.textSecondary(this.theme)).width('100%')
            .padding({ left: 16, right: 16, top: 20, bottom: 8 })

          if (this.selectedUris.length > 0 || this.uploadedUrls.length > 0) {
            Grid() {
              ForEach(this.selectedUris, (uri: string, index: number) => {
                GridItem() {
                  Stack() {
                    Image(uri)
                      .width('100%').height('100%')
                      .objectFit(ImageFit.Cover).borderRadius(6)
                    Text('✕')
                      .fontSize(this.fs(12)).fontColor(Color.White)
                      .width(20).height(20).borderRadius(10)
                      .backgroundColor('#99000000').textAlign(TextAlign.Center)
                      .position({ x: -6, y: -6 })
                      .onClick(() => {
                        this.selectedUris.splice(index, 1)
                      })
                  }
                }.width('100%').aspectRatio(1)
              })
            }
            .columnsTemplate('1fr 1fr 1fr 1fr')
            .columnsGap(8).rowsGap(8)
            .width('100%').padding({ left: 16, right: 16 })
          }

          Row() {
            Text(this.selectedUris.length > 0
              ? `${this.t('已选', 'Selected')} ${this.selectedUris.length} ${this.t('张', '')}`
              : this.t('从相册选择图片', 'Choose from album'))
              .fontSize(this.fs(14)).fontColor(Theme.textSecondary(this.theme))
          }
          .width('100%').height(44).justifyContent(FlexAlign.Center)
          .borderRadius(8).border({ width: 1, color: Theme.divider(this.theme), style: BorderStyle.Dashed })
          .margin({ left: 16, right: 16, top: 8 })
          .onClick(() => { this.pickImages() })

          Button(this.submitting
            ? this.t('发布中...', 'Publishing...')
            : (this.uploading ? this.t('上传文件中...', 'Uploading...') : this.t('立即发布', 'Publish')))
            .fontSize(this.fs(16))
            .backgroundColor((this.submitting || this.uploading) ? Theme.textHint(this.theme) : Theme.primary(this.theme))
            .borderRadius(24).height(48).width('100%')
            .margin({ left: 16, right: 16, top: 30, bottom: 30 })
            .onClick(() => {
              if (!this.submitting && !this.uploading) { this.handlePublish() }
            })
        }
      }
      .width('100%').layoutWeight(1).backgroundColor(Theme.bg(this.theme)).scrollBar(BarState.Off)
    }
    .width('100%').height('100%')
    .backgroundColor(Theme.bg(this.theme))
  }

  private showCategoryPicker(): void {
    if (this.categoryList.length === 0) {
      promptAction.showToast({ message: this.t('分类加载中，请稍候', 'Loading categories...') })
      return
    }
    const names: string[] = this.categoryList.map((c: Category) => c.name)
    let selectedIndex = this.categoryList.findIndex((c: Category) => c.name === this.selectedCategoryName)
    if (selectedIndex < 0) selectedIndex = 0
    TextPickerDialog.show({
      range: names,
      selected: selectedIndex,
      onAccept: (result: TextPickerResult) => {
        const idx = result.index as number
        const picked = this.categoryList[idx]
        if (picked) {
          this.categoryId = parseInt(picked.id)
          this.selectedCategoryName = picked.name
        }
      }
    })
  }

  private async pickImages(): Promise<void> {
    try {
      const picker = new photoAccessHelper.PhotoViewPicker()
      const result = await picker.select({
        MIMEType: photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE,
        maxSelectNumber: 9 - this.selectedUris.length
      })
      const uris = result.photoUris
      if (uris && uris.length > 0) {
        const newUris: string[] = [...this.selectedUris]
        for (let i = 0; i < uris.length; i++) {
          newUris.push(uris[i])
        }
        this.selectedUris = newUris
      }
    } catch (err) {
      // 用户取消选择会抛异常，忽略
    }
  }

  private async handlePublish(): Promise<void> {
    if (!this.name.trim()) {
      promptAction.showToast({ message: this.t('请输入作品名称', 'Please enter a name') })
      return
    }

    if (this.isSellable) {
      const priceNum = parseFloat(this.price)
      if (isNaN(priceNum) || priceNum <= 0) {
        promptAction.showToast({ message: this.t('请输入有效价格', 'Please enter a valid price') })
        return
      }
    }

    this.submitting = true

    let finalUrls: string[] = []
    if (this.selectedUris.length > 0) {
      this.uploading = true
      const resp = await ApiClient.uploadFiles(this.selectedUris)
      this.uploading = false
      if (resp.code === 0 && resp.data) {
        finalUrls = resp.data['urls'] || []
      } else {
        promptAction.showToast({ message: resp.message || this.t('图片上传失败', 'Image upload failed') })
        this.submitting = false
        return
      }
    }

    const body: Record<string, Object> = {}
    body['name'] = this.name.trim()
    body['description'] = this.description.trim()
    body['categoryId'] = this.categoryId
    body['isSellable'] = this.isSellable

    if (this.isSellable) {
      const priceNum = parseFloat(this.price)
      body['price'] = Math.round(priceNum * 100)
      const origPrice = parseFloat(this.originalPrice)
      body['originalPrice'] = isNaN(origPrice) ? 0 : Math.round(origPrice * 100)
      const stockNum = parseInt(this.stock)
      body['stock'] = isNaN(stockNum) ? 1 : stockNum
    } else {
      body['price'] = 0
      body['originalPrice'] = 0
      body['stock'] = 0
    }

    body['region'] = this.region.trim()
    body['craftType'] = this.craftType.trim()
    body['tags'] = this.tags.trim()
    body['images'] = finalUrls

    if (this.isSellable) {
      const priceNum = parseFloat(this.price)
      const stockNum = parseInt(this.stock)
      const skus: Record<string, Object>[] = []
      const sku: Record<string, Object> = {}
      sku['name'] = this.name.trim()
      sku['price'] = Math.round(priceNum * 100)
      sku['stock'] = isNaN(stockNum) ? 1 : stockNum
      sku['image'] = finalUrls.length > 0 ? finalUrls[0] : ''
      skus.push(sku)
      body['skus'] = skus
    } else {
      body['skus'] = []
    }

    const resp = await ProductService.publishProduct(body)
    this.submitting = false

    if (resp.code === 0) {
      promptAction.showToast({
        message: this.t('作品已提交，等待管理员审核', 'Submitted and awaiting review')
      })
      router.back()
    } else {
      promptAction.showToast({ message: resp.message || this.t('发布失败', 'Publish failed') })
    }
  }
}
