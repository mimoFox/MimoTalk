import { mVoiceStateEnum } from '../models/mVoiceStateEnum'

@Component
export default struct voiceRecCom {
  @Consume voiceState: mVoiceStateEnum

  // 移动时显示的界面
  @Builder
  displayRecBuilder() {
    if (this.voiceState === mVoiceStateEnum.CANCEL) {
      Row() {

      }
      .width(100)
      .height(80)
      .borderRadius(20)
      .backgroundColor($r('app.color.danger'))
      .margin({ left: 20 })
    }
    if (this.voiceState === mVoiceStateEnum.RECORDING) {
      Row() {

      }
      .width(200)
      .height(100)
      .borderRadius(20)
      .backgroundColor($r('app.color.primary'))
    }
    if (this.voiceState === mVoiceStateEnum.TRANSFER) {
      Row() {

      }
      .width(300)
      .height(180)
      .borderRadius(20)
      .backgroundColor($r('app.color.primary'))
    }
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column() {
        Column() {
          this.displayRecBuilder()
        }
        .width('100%')
        .height(200)
        .justifyContent(FlexAlign.Center)
        .alignItems(this.voiceState === mVoiceStateEnum.CANCEL ? HorizontalAlign.Start : HorizontalAlign.Center)

        // 取消 和 转文字区域
        Column() {
          Row() {

            Column() {
              if (this.voiceState === mVoiceStateEnum.CANCEL) {
                Text('松开 取消').fontSize(12).fontColor($r('app.color.text_second'))
                  .margin({ bottom: 10 })
              } else {
                Row() {

                }.height(12).margin({ bottom: 10 })
              }
              Row() {
                Text('X')
                  .fontSize(30)
                  .rotate({ angle: -10 })
                  .fontColor(this.voiceState === mVoiceStateEnum.CANCEL ? $r('app.color.white') :
                  $r('app.color.text_second'))
              }
              .width(70)
              .height(70)
              .borderRadius(35)
              .justifyContent(FlexAlign.Center)
              .backgroundColor(this.voiceState === mVoiceStateEnum.CANCEL ? $r('app.color.danger') : '#3a3a3a')
            }
            .height('100%')
            .justifyContent(FlexAlign.Center)

            Column() {
              if (this.voiceState === mVoiceStateEnum.TRANSFER) {
                Text('松开 发送').fontSize(12).fontColor($r('app.color.text_second'))
                  .margin({ bottom: 10 })
              } else {
                Row() {

                }.height(12).margin({ bottom: 10 })
              }

              Row() {
                Text('文')
                  .fontSize(30)
                  .rotate({ angle: 10 })
                  .fontColor(this.voiceState === mVoiceStateEnum.TRANSFER ? $r('app.color.white') :
                  $r('app.color.text_second'))
              }
              .width(70)
              .height(70)
              .borderRadius(35)
              .justifyContent(FlexAlign.Center)
              .backgroundColor(this.voiceState === mVoiceStateEnum.TRANSFER ? $r('app.color.primary') : '#3a3a3a')
            }
            .height('100%')
            .justifyContent(FlexAlign.Center)

          }
          .width('100%')
          .height(92)
          .justifyContent(FlexAlign.SpaceBetween)
          .padding({ left: 20, right: 20 })
          .margin({ bottom: 30 })

          if (this.voiceState === mVoiceStateEnum.RECORDING) {
            Text('松开 发送').fontSize(12).fontColor($r('app.color.text_second'))
              .margin({ bottom: 10 })
          }
        }

        // 发送语音区域
        Row() {
          Stack() {
            Image($r('app.media.vBg'))
              .width('100%').autoResize(true)
              .height(140)
              .fillColor(this.voiceState ===
              mVoiceStateEnum.RECORDING ? $r('app.color.white') : $r('app.color.bottom_voice_color'))

            Row() {
              Image($r('app.media.voice1')).width(70).autoResize(true)
            }
            .width('100%').justifyContent(FlexAlign.Center)
          }
        }
        .width('100%')

      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.voice_back_color'))
  }
}