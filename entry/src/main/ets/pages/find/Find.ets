@Component
struct Find {
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
      color: $r("app.color.border_color"),
      width: {
        bottom: 0.5
      }
    })
  }

  build() {
    Column() {
      Row() {
        Text("发现")
      }
      .justifyContent(FlexAlign.Center)
      .height(50)
      .width('100%')

      Scroll(this.scroller) {
        Column() {
          // 顶部
          this.getRenderItem("朋友圈")
          Row().height(10)
          this.getRenderItem("视频号")
          this.getRenderItem("直播")
          Row().height(10)
          this.getRenderItem("扫一扫")
          this.getRenderItem("摇一摇")
          Row().height(10)
          this.getRenderItem("看一看")
          this.getRenderItem("搜一搜")
          Row().height(10)
          this.getRenderItem("附近")
          Row().height(10)
          this.getRenderItem("购物")
          this.getRenderItem("游戏")
          Row().height(10)
          this.getRenderItem("小程序")
          Row().height(10)
        }
      }
      .width('100%')
      .height('100%')
      .padding({
        bottom: 50
      })
      .align(Alignment.Top)
      .scrollBar(BarState.Off)
      .friction(0.6)
      .edgeEffect(this.yOffset <= 0 ? EdgeEffect.Spring : EdgeEffect.Spring) // 滚动到边沿后回弹
      .onDidScroll(() => {
        this.yOffset = this.scroller.currentOffset().yOffset;
      })
    }
    .width('100%')

    .backgroundColor($r('app.color.back_color'))
  }
}

export default Find