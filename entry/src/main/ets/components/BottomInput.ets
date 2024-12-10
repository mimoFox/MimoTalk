import { display, promptAction } from '@kit.ArkUI'
import { mVoiceStateEnum } from '../models/mVoiceStateEnum'
import voiceRecCom from './voiceRecCom'

@Component
export default struct BottomInput {
  @State showVoice: boolean = false
  @State sendText: string = ''
  @State showVoiceRec: boolean = false
  @State screenWidth: number = 0
  @State screenHeight: number = 0
  @Provide voiceState: mVoiceStateEnum = mVoiceStateEnum.RECORDING
  //1.获取整个屏幕的宽度与高度
  //2.获取当前手指触摸的坐标x-y
  //3.手势拖动的时候，判断当前手指触摸的坐标x-y是否大于屏幕高度- 录音区域的高度
  //4.如果大于 屏幕高度-录音区域的高度 说明手势拖动录音区域
  //5.如果小于 屏暮高度-录音区域的高度 说明手势不在拖动录音区域

  sendMessage: (sendText: string) => void = () => {
  }

  aboutToAppear(): void {
    this.screenWidth = px2vp(display.getDefaultDisplaySync().width)
    this.screenHeight = px2vp(display.getDefaultDisplaySync().height)
  }

  @Builder
  voiceRecBuilder() {
    Column() {
      // 语音输入组件
      voiceRecCom()
    }
  }

  // 发送消息
  submitMessage() {
    if (this.sendText) {
      this.sendMessage(this.sendText)
      this.sendText = ''
      focusControl.requestFocus('input')
    } else {
      promptAction.showToast({
        message: '发送内容不能为空！',
        duration: 500,
        bottom: 200
      })
    }
  }

  build() {
    Column() {
      Row({ space: 10 }) {
        Image(!this.showVoice ? $r('app.media.voiceprint') : $r('app.media.keyboard'))
          .width(25).height(25)
          .onClick(() => {
            this.showVoice = !this.showVoice
          })
          .animation({
            duration: 300,
            playMode: PlayMode.Reverse
          })

        if (this.showVoice) {
          Button('按住发送语音')
            .fontSize(16)
            .fontColor($r('app.color.text_primary'))
            .height(35)
            .layoutWeight(1)
            .backgroundColor($r('app.color.white'))
            .type(ButtonType.Normal)
            .borderRadius(4)
            .gesture(GestureGroup(
              GestureMode.Parallel,
              LongPressGesture()
                .onAction(() => {
                  this.showVoiceRec = true
                })
                .onActionEnd(() => {
                  this.showVoiceRec = false
                }),
              PanGesture()
                .onActionUpdate((event) => {
                  if (event.fingerList[0].globalY > this.screenHeight - 170) {
                    this.voiceState = mVoiceStateEnum.RECORDING
                    promptAction.showToast({
                      message: '录音中...'
                    })
                  } else {
                    if (event.fingerList[0].globalX > this.screenWidth / 2) {
                      this.voiceState = mVoiceStateEnum.TRANSFER
                      promptAction.showToast({
                        message: '右边'
                      })
                    } else {
                      this.voiceState = mVoiceStateEnum.CANCEL
                      promptAction.showToast({
                        message: '左边'
                      })
                    }
                  }


                })
                .onActionEnd(() => {
                  this.voiceState = mVoiceStateEnum.RECORDING
                })
            )

            )
            .bindContentCover(this.showVoiceRec, this.voiceRecBuilder())

        } else {
          TextArea({ text: $$this.sendText })
            .id('input')
            .focusable(true)
            .layoutWeight(1)
            .backgroundColor($r('app.color.white'))
            .borderRadius(4)
            .onSubmit(() => {

            })
          // TextInput({ text: $$this.sendText })
          //   .id('input')
          //   .focusable(true)
          //   .height(35)
          //   .layoutWeight(1)
          //   .backgroundColor($r('app.color.white'))
          //   .borderRadius(4)
          //   .onSubmit(() => {
          //     if (this.sendText) {
          //       this.sendMessage(this.sendText)
          //       this.sendText = ''
          //       focusControl.requestFocus('input')
          //     } else {
          //       promptAction.showToast({
          //         message: '发送内容不能为空！',
          //         duration: 500,
          //         bottom: 200
          //       })
          //     }
          //   })
        }


        Row({ space: 10 }) {
          Image($r('app.media.emoji'))
            .width(25).height(25)
          if (this.sendText != '') {
            Button('发送')
              .height(40)
              .layoutWeight(1)
              .fontColor($r('app.color.white'))
              .backgroundColor($r('app.color.second_primary'))
              .type(ButtonType.Normal)
              .borderRadius(5)
              .stateEffect(true)
              .onClick(() => {
                this.submitMessage()
              })
          } else {
            Image($r('app.media.plus'))
              .width(25).height(25)
          }
        }
        .width(this.sendText === '' ? 60 : 100)
        .animation({ duration: 300 })
      }
      .width('100%')
      // .height(60)
      .padding(10)
      .backgroundColor($r('app.color.back_color'))
      .margin({ bottom: 10 })
    }
  }
}