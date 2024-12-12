import { mMessageModel } from '../models/mMessage';
import { preferencesUtils } from '../utils/preferences/preferencesUtils';
import { formatTime } from '../utils/Utils';
import { BusinessError, emitter } from '@kit.BasicServicesKit';
import { promptAction, router } from '@kit.ArkUI';
import HeaderCom from './HeaderCom';
import { mPopup } from '../models/mPopup';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { scanBarcode, scanCore } from '@kit.ScanKit';

@Component
export default struct ChatList {
  @State lastMessageList: mMessageModel[] = []
  @State showPop: boolean = false
  @State HeaderItem: mPopup = {
    title: '微信',
    icon: $r('app.media.plus'),
    popClick: () => {
      this.showPop = !this.showPop
    }
  }
  @State popList: mPopup[] = [
    {
      title: '发起群聊',
      icon: $r('app.media.chat_group')
    },
    {
      title: '添加朋友',
      icon: $r('app.media.add_friend')
    },
    {
      title: '扫一扫',
      icon: $r('app.media.scan'),
      popClick: () => {
        promptAction.showToast({
          message: '扫一扫'
        })
        // cnaIUse() 先检测是否能用扫码功能
        if (canIUse('SystemCapability.Multimedia.Scan.Core')) {
          // 定义扫码参数options
          let options: scanBarcode.ScanOptions = {
            scanTypes: [scanCore.ScanType.ALL],
            enableMultiMode: true,
            enableAlbum: true
          };
          if (canIUse('SystemCapability.Multimedia.Scan.ScanBarcode')) {
            try {
              scanBarcode.startScanForResult(getContext(this), options).then((result: scanBarcode.ScanResult) => {
                hilog.info(0x0001, '[Scan Sample]',
                  `成功扫描，结果： ${JSON.stringify(result)}`);
              }).catch((error: BusinessError) => {
                hilog.error(0x0001, '[Scan Sample]',
                  `扫描失败， Code: ${error.code}, message: ${error.message}`);
              });
            } catch (error) {
              hilog.error(0x0001, '[Scan Sample]',
                `扫描失败， Code: ${error.code}, message: ${error.message}`);
            }
          }
        }


      }
    },
    {
      title: '收付款',
      icon: $r('app.media.pay'),
      popClick: () => {
        router.pushUrl({
          url: 'pages/payments/Receipts_Payments'
        })
      }
    }
  ]

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
      // 聊天列表顶部栏
      HeaderCom({
        item: this.HeaderItem,
        showPop: this.showPop,
        popList: this.popList
      })


      // 聊天列表
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
      .padding({ top: 10, bottom: 10 })
      .backgroundColor($r('app.color.white'))
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.back_color'))

  }
}