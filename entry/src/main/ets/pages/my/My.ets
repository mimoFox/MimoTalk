@Preview
@Component
struct My {
  @State yOffset: number = 0
  scroller: Scroller = new Scroller()

  @Builder
  getRenderItem(left: string, rightClick?: () => void) {
    Row() {
      Text(left)
      Image(
        $r("app.media.back"))
        .width(16)
        .height(16)
        .rotate({ angle: 180 })
    }
    .width('100%')
    .padding({
      left: 20,
      right: 20
    })
    .backgroundColor($r("app.color.white"))
    .height(60)
    .justifyContent(FlexAlign.SpaceBetween)
    .border({
      color:
      $r("app.color.border_color"),
      width: {
        bottom: 0.5
      }
    })
  }

  build() {
    Scroll(this.scroller) {
      Column() {
        // 顶部
        Row() {
          Row({ space: 10 }) {
            Image("https://iknow-pic.cdn.bcebos.com/96dda144ad345982c29d3c0f1ef431adcbef841c")
              .width(60)
              .height(60)
              .borderRadius(6)
            Column({ space: 10 }) {
              Text("Mimo").fontSize(18).fontColor($r('app.color.text_primary'))
              Text("微信号：666666").fontColor(
                $r('app.color.text_second')).fontSize(14)
            }.alignItems(HorizontalAlign.Start)
          }
          .layoutWeight(1)

          Image($r("app.media.back"))
            .width(16)
            .height(16)
            .fillColor(
              $r('app.color.text_second'))
            .rotate({ angle: 180 })
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .padding(20)
        .width('100%')
        .backgroundColor($r("app.color.white"))

        Row().height(10)
        this.getRenderItem("服务")
        Row().height(10)
        this.getRenderItem("收藏")
        this.getRenderItem("朋友圈")
        this.getRenderItem("卡包")
        this.getRenderItem("表情")
        Row().height(10)
        this.getRenderItem("设置")
      }
      .width('100%')
      .backgroundColor($r('app.color.back_color'))
      .justifyContent(FlexAlign.Start)

    }
    .width('100%')
    .height('100%')
    .align(Alignment.Top)
    .backgroundColor($r('app.color.back_color'))
    .scrollBar(BarState.Off)
    .friction(0.6)
    .edgeEffect(this.yOffset <= 0 ? EdgeEffect.Spring : EdgeEffect.Spring) // 滚动到边沿后回弹
    .onDidScroll(() => {
      this.yOffset = this.scroller.currentOffset().yOffset;
    })
  }
}

export default My