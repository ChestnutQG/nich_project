// 发布作品页面 — 支持选择是否售卖
import { router } from '@kit.ArkUI'
import { promptAction } from '@kit.ArkUI'
import { photoAccessHelper } from '@kit.MediaLibraryKit'
import { Colors } from '../common/Colors'
import { Constants } from '../common/Constants'
import { NavBar } from '../components/NavBar'
import { ProductService } from '../service/ProductService'
import { ApiClient } from '../service/ApiClient'

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
  @State selectedUris: string[] = []      // 图片 uri
  @State selectedVideoUris: string[] = [] // 视频 uri
  @State uploadedUrls: string[] = []
  @State submitting: boolean = false
  @State uploading: boolean = false

  private categories: Record<number, string> = {
    1: '传统技艺', 2: '传统美术', 3: '传统医药', 4: '民俗', 5: '传统戏剧',
    6: '传统音乐', 7: '传统舞蹈', 8: '曲艺', 9: '传统体育游艺', 10: '民间文学'
  }

  build() {
    Column() {
      NavBar({ title: '发布作品', showBack: true })

      Scroll() {
        Column() {
          // 基本信息
          Text('基本信息')
            .fontSize(13).fontColor(Colors.TEXT_SECONDARY).width('100%')
            .padding({ left: 16, right: 16, top: 20, bottom: 8 })

          Row() {
            Text('作品名称 *').fontSize(14).fontColor(Colors.TEXT_PRIMARY).width(100)
            TextInput({ placeholder: '请输入作品名称' })
              .fontSize(14).fontColor(Colors.TEXT_PRIMARY).placeholderColor(Colors.TEXT_HINT)
              .backgroundColor(Color.Transparent).layoutWeight(1)
              .onChange((v: string) => { this.name = v })
          }
          .width('100%').padding({ left: 16, right: 16, top: 12, bottom: 12 }).backgroundColor(Colors.BG_WHITE)

          Divider().color(Colors.DIVIDER).margin({ left: 16 })

          Row() {
            Text('作品描述').fontSize(14).fontColor(Colors.TEXT_PRIMARY).width(100)
            TextInput({ placeholder: '简要描述作品特点' })
              .fontSize(14).fontColor(Colors.TEXT_PRIMARY).placeholderColor(Colors.TEXT_HINT)
              .backgroundColor(Color.Transparent).layoutWeight(1)
              .onChange((v: string) => { this.description = v })
          }
          .width('100%').padding({ left: 16, right: 16, top: 12, bottom: 12 }).backgroundColor(Colors.BG_WHITE)

          Divider().color(Colors.DIVIDER).margin({ left: 16 })

          // 分类选择
          Row() {
            Text('非遗分类').fontSize(14).fontColor(Colors.TEXT_PRIMARY).width(80)
            Blank()
            Text(this.selectedCategoryName).fontSize(14).fontColor(Colors.PRIMARY).margin({ right: 4 })
            Text('▼').fontSize(10).fontColor(Colors.TEXT_HINT)
          }
          .width('100%').padding({ left: 16, right: 16, top: 14, bottom: 14 }).backgroundColor(Colors.BG_WHITE)
          .onClick(() => { this.showCategoryPicker() })

          Divider().color(Colors.DIVIDER).margin({ left: 16 })

          // 是否售卖开关
          Row() {
            Text('是否售卖').fontSize(14).fontColor(Colors.TEXT_PRIMARY).layoutWeight(1)
            Toggle({ type: ToggleType.Switch, isOn: this.isSellable })
              .selectedColor(Colors.PRIMARY)
              .onChange((v: boolean) => { this.isSellable = v })
          }
          .width('100%').padding({ left: 16, right: 16, top: 14, bottom: 14 }).backgroundColor(Colors.BG_WHITE)

          // 价格与库存 — 仅在开启售卖时显示
          if (this.isSellable) {
            Text('价格与库存')
              .fontSize(13).fontColor(Colors.TEXT_SECONDARY).width('100%')
              .padding({ left: 16, right: 16, top: 20, bottom: 8 })

            Row() {
              Text('售价 *（元）').fontSize(14).fontColor(Colors.TEXT_PRIMARY).width(100)
              TextInput({ placeholder: '例如 1280' })
                .fontSize(14).fontColor(Colors.TEXT_PRIMARY).placeholderColor(Colors.TEXT_HINT)
                .backgroundColor(Color.Transparent).layoutWeight(1).type(InputType.Number)
                .onChange((v: string) => { this.price = v })
            }
            .width('100%').padding({ left: 16, right: 16, top: 12, bottom: 12 }).backgroundColor(Colors.BG_WHITE)

            Divider().color(Colors.DIVIDER).margin({ left: 16 })

            Row() {
              Text('原价（元）').fontSize(14).fontColor(Colors.TEXT_PRIMARY).width(100)
              TextInput({ placeholder: '划线价，可不填' })
                .fontSize(14).fontColor(Colors.TEXT_PRIMARY).placeholderColor(Colors.TEXT_HINT)
                .backgroundColor(Color.Transparent).layoutWeight(1).type(InputType.Number)
                .onChange((v: string) => { this.originalPrice = v })
            }
            .width('100%').padding({ left: 16, right: 16, top: 12, bottom: 12 }).backgroundColor(Colors.BG_WHITE)

            Divider().color(Colors.DIVIDER).margin({ left: 16 })

            Row() {
              Text('库存数量').fontSize(14).fontColor(Colors.TEXT_PRIMARY).width(100)
              TextInput({ placeholder: '1', text: '1' })
                .fontSize(14).fontColor(Colors.TEXT_PRIMARY).placeholderColor(Colors.TEXT_HINT)
                .backgroundColor(Color.Transparent).layoutWeight(1).type(InputType.Number)
                .onChange((v: string) => { this.stock = v })
            }
            .width('100%').padding({ left: 16, right: 16, top: 12, bottom: 12 }).backgroundColor(Colors.BG_WHITE)
          }

          // 产地与技艺
          Text('产地与技艺')
            .fontSize(13).fontColor(Colors.TEXT_SECONDARY).width('100%')
            .padding({ left: 16, right: 16, top: 20, bottom: 8 })

          Row() {
            Text('产地').fontSize(14).fontColor(Colors.TEXT_PRIMARY).width(100)
            TextInput({ placeholder: '例如：江苏苏州' })
              .fontSize(14).fontColor(Colors.TEXT_PRIMARY).placeholderColor(Colors.TEXT_HINT)
              .backgroundColor(Color.Transparent).layoutWeight(1)
              .onChange((v: string) => { this.region = v })
          }
          .width('100%').padding({ left: 16, right: 16, top: 12, bottom: 12 }).backgroundColor(Colors.BG_WHITE)

          Divider().color(Colors.DIVIDER).margin({ left: 16 })

          Row() {
            Text('技艺类型').fontSize(14).fontColor(Colors.TEXT_PRIMARY).width(100)
            TextInput({ placeholder: '例如：苏绣、青花瓷' })
              .fontSize(14).fontColor(Colors.TEXT_PRIMARY).placeholderColor(Colors.TEXT_HINT)
              .backgroundColor(Color.Transparent).layoutWeight(1)
              .onChange((v: string) => { this.craftType = v })
          }
          .width('100%').padding({ left: 16, right: 16, top: 12, bottom: 12 }).backgroundColor(Colors.BG_WHITE)

          Divider().color(Colors.DIVIDER).margin({ left: 16 })

          Row() {
            Text('标签').fontSize(14).fontColor(Colors.TEXT_PRIMARY).width(100)
            TextInput({ placeholder: '多个用逗号分隔' })
              .fontSize(14).fontColor(Colors.TEXT_PRIMARY).placeholderColor(Colors.TEXT_HINT)
              .backgroundColor(Color.Transparent).layoutWeight(1)
              .onChange((v: string) => { this.tags = v })
          }
          .width('100%').padding({ left: 16, right: 16, top: 12, bottom: 12 }).backgroundColor(Colors.BG_WHITE)

          // 图片选择
          Text('作品图片与视频')
            .fontSize(13).fontColor(Colors.TEXT_SECONDARY).width('100%')
            .padding({ left: 16, right: 16, top: 20, bottom: 8 })

          if (this.selectedUris.length > 0 || this.selectedVideoUris.length > 0 || this.uploadedUrls.length > 0) {
            Grid() {
              ForEach(this.selectedUris, (uri: string, index: number) => {
                GridItem() {
                  Stack() {
                    Image(uri)
                      .width('100%').height('100%')
                      .objectFit(ImageFit.Cover).borderRadius(6)
                    Text('✕')
                      .fontSize(12).fontColor(Color.White)
                      .width(20).height(20).borderRadius(10)
                      .backgroundColor('#99000000').textAlign(TextAlign.Center)
                      .position({ x: -6, y: -6 })
                      .onClick(() => {
                        this.selectedUris.splice(index, 1)
                      })
                  }
                }.width('100%').aspectRatio(1)
              })
              ForEach(this.selectedVideoUris, (uri: string, index: number) => {
                GridItem() {
                  Stack() {
                    Image(uri)  // 系统会自动生成视频缩略图
                      .width('100%').height('100%')
                      .objectFit(ImageFit.Cover).borderRadius(6)
                    Text('▶')
                      .fontSize(24).fontColor(Color.White)
                      .width('100%').height('100%')
                      .textAlign(TextAlign.Center)
                      .backgroundColor('#66000000').borderRadius(6)
                    Text('✕')
                      .fontSize(12).fontColor(Color.White)
                      .width(20).height(20).borderRadius(10)
                      .backgroundColor('#99000000').textAlign(TextAlign.Center)
                      .position({ x: -6, y: -6 })
                      .onClick(() => {
                        this.selectedVideoUris.splice(index, 1)
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
            Text(this.selectedUris.length > 0 ? `已选 ${this.selectedUris.length} 张图片` : '从相册选择图片')
              .fontSize(14).fontColor(Colors.TEXT_SECONDARY)
          }
          .width('100%').height(44).justifyContent(FlexAlign.Center)
          .borderRadius(8).border({ width: 1, color: Colors.DIVIDER, style: BorderStyle.Dashed })
          .margin({ left: 16, right: 16, top: 8 })
          .onClick(() => { this.pickImages() })

          Row() {
            Text(this.selectedVideoUris.length > 0 ? `已选 ${this.selectedVideoUris.length} 个视频` : '从相册选择视频')
              .fontSize(14).fontColor(Colors.TEXT_SECONDARY)
          }
          .width('100%').height(44).justifyContent(FlexAlign.Center)
          .borderRadius(8).border({ width: 1, color: Colors.DIVIDER, style: BorderStyle.Dashed })
          .margin({ left: 16, right: 16, top: 8 })
          .onClick(() => { this.pickVideos() })

          // 提交
          Button(this.submitting ? '发布中...' : (this.uploading ? '上传文件中...' : '立即发布'))
            .fontSize(16)
            .backgroundColor((this.submitting || this.uploading) ? Colors.TEXT_HINT : Colors.PRIMARY)
            .borderRadius(24).height(48).width('100%')
            .margin({ left: 16, right: 16, top: 30, bottom: 30 })
            .onClick(() => {
              if (!this.submitting && !this.uploading) { this.handlePublish() }
            })
        }
      }
      .width('100%').layoutWeight(1).backgroundColor(Colors.BG_PAPER).scrollBar(BarState.Off)
    }
    .width('100%').height('100%')
  }

  private showCategoryPicker(): void {
    AlertDialog.show({
      title: '选择非遗分类',
      message: '1-传统技艺  2-传统美术  3-传统医药  4-民俗  5-传统戏剧\n6-传统音乐  7-传统舞蹈  8-曲艺  9-传统体育  10-民间文学',
      autoCancel: true,
      alignment: DialogAlignment.Bottom,
      primaryButton: { value: '确定', action: () => {} }
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

  private async pickVideos(): Promise<void> {
    try {
      const picker = new photoAccessHelper.PhotoViewPicker()
      const result = await picker.select({
        MIMEType: photoAccessHelper.PhotoViewMIMETypes.VIDEO_TYPE,
        maxSelectNumber: 3 - this.selectedVideoUris.length
      })
      const uris = result.photoUris
      if (uris && uris.length > 0) {
        const newUris: string[] = [...this.selectedVideoUris]
        for (let i = 0; i < uris.length; i++) {
          newUris.push(uris[i])
        }
        this.selectedVideoUris = newUris
      }
    } catch (err) {
      // 用户取消选择会抛异常，忽略
    }
  }

  private async handlePublish(): Promise<void> {
    if (!this.name.trim()) {
      promptAction.showToast({ message: '请输入作品名称' })
      return
    }

    // 仅售卖时需要验证价格
    if (this.isSellable) {
      const priceNum = parseFloat(this.price)
      if (isNaN(priceNum) || priceNum <= 0) {
        promptAction.showToast({ message: '请输入有效价格' })
        return
      }
    }

    this.submitting = true

    let finalUrls: string[] = []
    // 合并图片和视频 URI 一起上传
    const allMediaUris: string[] = [...this.selectedUris, ...this.selectedVideoUris]
    if (allMediaUris.length > 0) {
      this.uploading = true
      const resp = await ApiClient.uploadFiles(allMediaUris)
      this.uploading = false
      if (resp.code === 0 && resp.data) {
        finalUrls = resp.data['urls'] || []
      } else {
        promptAction.showToast({ message: resp.message || '文件上传失败' })
        this.submitting = false
        return
      }
    }

    const body: Record<string, Object> = {}
    body['name'] = this.name.trim()
    body['description'] = this.description.trim()
    body['categoryId'] = this.categoryId
    body['artisanId'] = 1
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
      promptAction.showToast({ message: '发布成功！' })
      router.back()
    } else {
      promptAction.showToast({ message: resp.message || '发布失败' })
    }
  }
}
