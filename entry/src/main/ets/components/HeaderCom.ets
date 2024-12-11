import { mPopup } from '../models/mPopup'

@Component
export default struct HeaderCom {
  item: mPopup = {} as mPopup
  @Link showPop: boolean
  @Prop popList: mPopup[]

  @Builder
  dropDownBuilder() {
    Column({ space: 20 }) {
      ForEach(this.popList, (item: mPopup) => {
        Row({ space: 10 }) {
          Image(item.icon).width(20).height(20)
          Text(item.title).fontSize(20).fontColor($r('app.color.white'))
        }
        .width('100%')
        .onClick(() => {
          item.popClick && item.popClick()
        })
      })
    }
    .width(150)
    .padding(20)
  }

  build() {
    Row() {
      Stack({ alignContent: Alignment.End }) {
        Text(this.item.title)
          .fontSize(20)
          .width('100%')
          .textAlign(TextAlign.Center)

        Image(this.item.icon)
          .width(20)
          .height(20)
          .margin({ right: 20 })
          .onClick(() => {
            this.item.popClick && this.item.popClick()
          })
          .bindPopup($$this.showPop, {
            builder: this.dropDownBuilder(),
            arrowPointPosition: ArrowPointPosition.END,
            popupColor: $r('app.color.popup_back'),
            backgroundBlurStyle: BlurStyle.NONE,
            onStateChange: (event) => {
              if (event) {
                this.showPop = event.isVisible
              }
            }
          })
      }
    }
    .width('100%')
    .height(50)
    .justifyContent(FlexAlign.Center)
    .backgroundColor($r('app.color.second_back_color'))
  }
}