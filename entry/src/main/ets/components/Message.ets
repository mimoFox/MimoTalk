import { MessageInfo, mMessageModel } from '../models/mMessage'
import { currentUser } from '../models/mUsers'

@Component
export default struct Message {
  @Prop messageItem: mMessageModel = new mMessageModel({} as MessageInfo)

  build() {
    Row() {
      Image(this.messageItem.sender.avatar)
        .width(40)
        .height(40)
        .borderRadius(6)

      Row() {
        Column() {
          Text(this.messageItem.messageContent)
            .fontSize(14)
            .backgroundColor(this.messageItem.sender.userId === currentUser.userId ? $r('app.color.second_primary') :
            $r('app.color.white'))
            .borderRadius(4)
            .padding(10)
            .margin({ left: 10, right: 10 })
        }
      }
      .layoutWeight(6)
      .justifyContent(this.messageItem.sender.userId === currentUser.userId ? FlexAlign.End : FlexAlign.Start)

      Text('')
        .layoutWeight(1)
    }
    .direction(this.messageItem.sender.userId === currentUser.userId ? Direction.Rtl : Direction.Ltr)
    .padding({ top: 20, bottom: 10 })
    .width('100%')
    .alignItems(VerticalAlign.Top)
  }
}