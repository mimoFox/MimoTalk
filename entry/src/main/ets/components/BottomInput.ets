import { promptAction } from '@kit.ArkUI'

@Component
export default struct BottomInput {
  @State showVoice: boolean = false
  @State sendText: string = ''
  sendMessage: (sendText: string) => void = () => {
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
        } else {
          TextInput({ text: $$this.sendText })
            .id('input')
            .focusable(true)
            .height(35)
            .layoutWeight(1)
            .backgroundColor($r('app.color.white'))
            .borderRadius(4)
            .onSubmit(() => {
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
            })
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
          } else {
            Image($r('app.media.plus'))
              .width(25).height(25)
          }
        }
        .width(this.sendText === '' ? 60 : 100)
        .animation({ duration: 300 })
      }
      .width('100%')
      .height(60)
      .padding({ left: 10, right: 10 })
      .backgroundColor($r('app.color.back_color'))
    }
  }
}