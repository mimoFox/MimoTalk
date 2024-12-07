@Component
export default struct BottomInput {
  @State showVoice: boolean = false

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
          TextInput()
            .height(35)
            .layoutWeight(1)
            .backgroundColor($r('app.color.white'))
            .borderRadius(4)
        }


        Row({ space: 10 }) {
          Image($r('app.media.emoji'))
            .width(25).height(25)
          Image($r('app.media.plus'))
            .width(25).height(25)
        }
        .width(60)
      }
      .width('100%')
      .height(60)
      .padding({ left: 10, right: 10 })
      .backgroundColor($r('app.color.back_color'))
    }
  }
}