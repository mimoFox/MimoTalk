import { mMessageModel } from '../models/mMessage';
import { preferencesUtils } from '../utils/preferences/preferencesUtils';
import { formatTime } from '../utils/Utils';
import { emitter } from '@kit.BasicServicesKit';
import { router } from '@kit.ArkUI';

@Component
export default struct ChatList {
  @State lastMessageList: mMessageModel[] = []

  aboutToAppear() {
    this.lastMessageList = preferencesUtils.getAllLastMessage()

    // 订阅消息
    emitter.on(preferencesUtils.storeName, () => {
      //重新刷新聊天列表
      this.lastMessageList = preferencesUtils.getAllLastMessage()
    })
  }

  @Builder
  swipeBuilder(userId: string) {
    Row() {
      Text('删除').fontSize(20).fontColor($r('app.color.white'))
        .textAlign(TextAlign.Center)
        .width('100%')
    }
    .width(60).backgroundColor($r('app.color.danger'))
    .height('100%')
    .onClick(() => {
      // 删除首选项中的数据
      preferencesUtils.removeAllMessageById(userId)

      // 删除UI界面的数据
      const index = this.lastMessageList.findIndex((item: mMessageModel) => item.connectUser.userId === userId)
      animateTo({ duration: 1000 }, () => {
        this.lastMessageList.splice(index, 1)
      })

    })
  }

  build() {
    Column() {
      List({ space: 10 }) {
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
                  Text(`${formatTime(message.sendTime)}`).fontSize(12).fontColor($r('app.color.text_second'))
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
            .stateStyles({
              pressed: {
                .backgroundColor($r('app.color.back_color'))
              },
              normal: {
                .backgroundColor($r('app.color.white'))
              }
            }) // 这个效果会跟listItem的swipeAction冲突，所以需要分开写
          }
          .width('100%')
          .height(50)

          .onClick(() => {

            router.pushUrl({
              url: 'pages/chat/SingleChat',
              params: message.connectUser // 传递接收者信息
            })
          })
          .swipeAction({
            end: () => {
              this.swipeBuilder(message.connectUser.userId)
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
      .margin({ top: 10, bottom: 10 })
      .backgroundColor($r('app.color.white'))
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.back_color'))

  }
}