import HeaderCom from '../../components/HeaderCom'
import { router } from '@kit.ArkUI'
import { generateBarcode, scanCore } from '@kit.ScanKit'
import { image } from '@kit.ImageKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { buffer } from '@kit.ArkTS'

@Entry
@Component
struct Receipts_Payments {
  @State showPop?: boolean = false
  @State payParams: string = Math.random().toString()
  @State barcodeImg: PixelMap | null = null

  aboutToAppear(): void {
    this.refreshStr()
  }

  refreshStr() {
    setInterval(() => {
      this.payParams = Math.random().toString()
    }, 3000)
  }

  createBarcode() {

    try {
      if (canIUse('SystemCapability.Multimedia.Scan.Core')) {
        let contentBuffer: ArrayBuffer = buffer.from(this.payParams, 'hex').buffer
        let barcodeOptions: generateBarcode.CreateOptions = {
          scanType: scanCore.ScanType.QR_CODE,
          height: 300,
          width: 800
        }
        if (canIUse('SystemCapability.Multimedia.Scan.GenerateBarcode')) {
          generateBarcode.createBarcode(contentBuffer, barcodeOptions).then((result: image.PixelMap) => {
            // 码图生成接口，成功返回PixelMap格式图片
            hilog.info(0x0001, '[Scan Sample]', `成功获取PixelMap.`);

            this.barcodeImg = result

            console.log('成功获取PixelMap' + JSON.stringify(result))

          }).catch((error: BusinessError) => {
            hilog.error(0x0001, '[Scan Sample]',
              `PixelMap获取失败 Code: ${error.code}, message: ${error.message}`);
          });
        }

      }

    } catch (error) {
      hilog.error(0x0001, '[Scan Sample]', `PixelMap获取失败 Code: ${error.code}, message: ${error.message}`);
    }
  }

  build() {
    Column() {
      // 头部显示
      HeaderCom({
        textColor: $r('app.color.white'),
        backItem: {
          icon: $r('app.media.back_white'),
          title: '',
          popClick: () => {
            router.back()
          }
        },
        item: {
          title: '收付款',
          icon: ''
        },
        showPop: this.showPop
      })

      // 二维码显示
      Column() {
        Column() {
          // 顶部
          Row() {
            Row({ space: 10 }) {
              Image($r('app.media.pay'))
                .width(25).height(25)
                .fillColor($r('app.color.pay_back'))
              Text('付款码').fontSize(16)
                .fontColor($r('app.color.pay_back'))
            }

            Image($r('app.media.point'))
              .width(20)
          }
          .width('100%')
          .height(60)
          .justifyContent(FlexAlign.SpaceBetween)
          .border({
            width: {
              bottom: 1
            },
            color: $r('app.color.border_color'),
          })
          .margin({ left: 10, right: 10 })

          Column({ space: 15 }) {
            Text(`优先使用零钱付款`)
              .fontSize(14)
              .fontColor($r('app.color.text_second'))

            // 条形码  模拟器不支持显示， 需要真机
            if (this.barcodeImg) {
              Image(`${this.barcodeImg}`)
                .width(280).height(100)
            }

            // 二维码
            QRCode(this.payParams)
              .width(140)
              .height(140)

          }
          .margin({ top: 15 })

        }
        .width('100%')
        .height(500)
        .padding({ left: 20, right: 20 })
        .borderRadius(5)
        .backgroundColor($r('app.color.white'))

      }
      .width('100%')
      .layoutWeight(1)
      .padding(10)

    }
    .height('100%')
    .width('100%')
    .backgroundColor($r('app.color.pay_back'))
  }
}