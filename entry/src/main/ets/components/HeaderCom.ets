import { mPopup } from '../models/mPopup'

@Component
export default struct HeaderCom {
  item: mPopup = {} as mPopup
  @Link showPop?: boolean
  @Prop popList: mPopup[]
  backItem?: mPopup = {} as mPopup

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

      Image(this.backItem?.icon)
        .width(20)
        .height(20)
        .margin({ left: 10 })
        .onClick(() => {
          this.backItem?.popClick && this.backItem.popClick()
        })

      Text(this.item.title)
        .fontSize(20)
        .textAlign(TextAlign.Center)
        .layoutWeight(1)

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
    .width('100%')
    .height(50)
    .justifyContent(FlexAlign.Center)
  }
}