import { MessageInfo, MessageTypeEnum, mMessageModel } from '../models/mMessage'
import { mPopup } from '../models/mPopup'
import { currentUser } from '../models/mUsers'
import { preferencesUtils } from '../utils/preferences/preferencesUtils'

@Component
export default struct Message {
  @Prop messageItem: mMessageModel = new mMessageModel({} as MessageInfo)
  @State customPopup: boolean = false
  @State popList: mPopup[] = [
    {
      icon: $r('app.media.ear'),
      title: '听筒播放'
    },
    {
      icon: $r('app.media.01_collection'),
      title: '收藏'
    },
    {
      icon: $r('app.media.icon_tab_convert_to_text'),
      title: '转文字'
    },
    {
      icon: $r('app.media.delete'),
      title: '删除',
      popClick: () => {
        preferencesUtils.removeMessageById(this.messageItem.connectUser.userId, this.messageItem.id)

        this.deleteUiMessage(this.messageItem.id)
      }
    },
    {
      icon: $r('app.media.multiple'),
      title: '多选'
    },
    {
      icon: $r('app.media.editor_cite'),
      title: '引用'
    },
    {
      icon: $r('app.media.remind'),
      title: '提醒'
    }
  ]
  videoController: VideoController = new VideoController()
  deleteUiMessage: (messageId: string) => void = () => {
  }
  previewImg: (filePath: string, messageType?: MessageTypeEnum) => void = () => {
  }

  @Builder
  bubbleBuilder() {
    GridRow({ columns: 5 }) {
      ForEach(this.popList, (pop: mPopup) => {
        GridCol() {
          Column({ space: 5 }) {
            Image(pop.icon)
              .width(18)
              .fillColor($r('app.color.white'))
            Text(pop.title)
              .fontSize(12)
              .fontColor($r('app.color.white'))
          }
          .width('100%')
          .layoutWeight(1)
          .onClick(() => {
            // 如果popClick不是undefined话才调用
            pop.popClick && pop.popClick()
          })
        }
        .height(60)
        .padding({ top: 10, bottom: 10 })
      })

    }
    .width('70%')
    .borderRadius(10)
  }

  build() {
    Row() {
      Image(this.messageItem.sender.avatar)
        .width(40)
        .height(40)
        .borderRadius(6)


      Row() {
        Column() {
          if (this.messageItem.messageType === MessageTypeEnum.IMAGE) {
            Column() {
              Image('file://' + this.messageItem.sourceFilePath)
                .width('100%')
                .borderRadius(4)
                .onClick(() => {
                  this.previewImg(this.messageItem.sourceFilePath, this.messageItem.messageType)
                })
            }
            .width('40%')
            .margin({ left: 10, right: 10 })
          } else if (this.messageItem.messageType === MessageTypeEnum.VIDEO) {
            Column() {
              Stack() {
                Video({
                  src: 'file://' + this.messageItem.sourceFilePath,

                  controller: this.videoController
                })
                  .controls(false)
                  .width('100%')
                  .height(150)
                  .borderRadius(4)
                  .id(this.messageItem.id)
                  .onPrepared(async () => {
                    // 缓存加载预览画面
                    await this.videoController.setCurrentTime(0.1)
                  })

                Image($r('app.media.play_fill')).width(30).height(30)
                  .onClick(() => {
                    this.previewImg(this.messageItem.sourceFilePath, this.messageItem.messageType)
                    this.videoController.start()
                  })
              }
            }
            .width('40%')
            .margin({ left: 10, right: 10 })
          } else if (this.messageItem.messageType === MessageTypeEnum.TEXT) {
            Text(this.messageItem.messageContent)
              .fontSize(14)
              .backgroundColor(this.messageItem.sender.userId === currentUser.userId ? $r('app.color.second_primary') :
              $r('app.color.white'))
              .borderRadius(4)
              .padding(10)
              .margin({ left: 10, right: 10 })
          }
        }
      }
      .layoutWeight(6)
      .justifyContent(this.messageItem.sender.userId === currentUser.userId ? FlexAlign.End : FlexAlign.Start)
      .bindPopup(this.customPopup, {
        builder: this.bubbleBuilder(),
        popupColor: $r('app.color.popup_back'),
        backgroundBlurStyle: BlurStyle.NONE,
        onStateChange: (event) => {
          if (!event.isVisible) {
            this.customPopup = false
          }
        },
        // 设置弹窗显示动效与退出动效为缩放动效
        // transition: TransitionEffect.scale({ x: 1, y: 0 })
        //   .animation({ duration: 500, curve: Curve.Ease }),
        placement: Placement.Top, // 气泡弹出位置
        arrowPointPosition: this.messageItem.sender.userId === currentUser.userId ? ArrowPointPosition.END :
        ArrowPointPosition.START
      })
      // 长按手势
      .gesture(LongPressGesture().onAction(() => {
        this.customPopup = true
      }))


      Text('')
        .layoutWeight(1)
    }
    .direction(this.messageItem.sender.userId === currentUser.userId ? Direction.Rtl : Direction.Ltr)
    .padding({
      top: 20,
      bottom: 10,
      left: 10,
      right: 10
    })
    .width('100%')
    .alignItems(VerticalAlign.Top)
  }
}