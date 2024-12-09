import { mMessageModel } from '../models/mMessage'
import { preferencesUtils } from '../utils/preferences/preferencesUtils'

@Component
export default struct ChatList {
  @State lastMessageList: mMessageModel[] = []

  aboutToAppear() {
    this.lastMessageList = preferencesUtils.getAllLastMessage()
  }

  build() {
    Column() {
      List() {
        ForEach(this.lastMessageList, (message: mMessageModel) => {
          ListItem() {
            Row({ space: 10 }) {
              Image(message.connectUser.avatar)
                .width(40).height(40).borderRadius(5)
              Column() {
                Row() {
                  Text(message.connectUser.userName)
                    .fontSize(16)
                    .fontWeight(600)
                    .fontColor($r('app.color.text_primary'))
                  Text(`${message.sendTime}`).fontSize(12).fontColor($r('app.color.text_second'))
                }
                .width('100%')
                .justifyContent(FlexAlign.SpaceBetween)

                Row() {
                  Text(message.messageContent)
                    .fontSize(12)
                    .fontColor($r('app.color.text_second'))
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
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