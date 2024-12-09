@Component
export default struct ChatList {
  build() {
    Column() {
      List() {
        ListItem() {
          Row({ space: 10 }) {
            Image('https://iknow-pic.cdn.bcebos.com/96dda144ad345982c29d3c0f1ef431adcbef841c')
              .width(40).height(40).borderRadius(5)
            Column() {
              Row() {
                Text('女神').fontSize(16).fontWeight(600).fontColor($r('app.color.text_primary'))
                Text('00:25').fontSize(12).fontColor($r('app.color.text_second'))
              }
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween)

              Row() {
                Text('今天晚上吃什么？').fontSize(12).fontColor($r('app.color.text_second'))
              }
              .width('100%')
              .justifyContent(FlexAlign.Start)
            }
            .width('100%')
            .height('100%')
            .layoutWeight(1)
            .padding({ top: 5, bottom: 5 })
            .justifyContent(FlexAlign.SpaceBetween)
          }
          .width('100%')
          .height('100%')
          .padding({ left: 10, right: 10 })
        }
        .width('100%')
        .height(50)
        .stateStyles({
          pressed: {
            .backgroundColor($r('app.color.back_color'))
          },
          normal: {
            .backgroundColor($r('app.color.white'))
          }
        })
      }
      .width('100%')
      .height('100%')
      .layoutWeight(1)
      .divider({
        strokeWidth: 1,
        color: $r('app.color.border_color')
      })
    }
    .width('100%')
    .height('100%')
  }
}