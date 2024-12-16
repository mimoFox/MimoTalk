import { MessageInfo, MessageTypeEnum, mMessageModel } from '../models/mMessage'
import { mPopup } from '../models/mPopup'
import { currentUser } from '../models/mUsers'
import { AudioRenderer, fileCapture } from '../utils/audioCapturer'
import { preferencesUtils } from '../utils/preferences/preferencesUtils'
import { VoiceTransfer } from '../utils/VoiceTransfer'

@Component
export default struct Message {
  @Prop messageItem: mMessageModel = new mMessageModel({} as MessageInfo)
  @State customPopup: boolean = false
  @State transferResult: string = ''
  @State popList: mPopup[] = [
    {
      icon: $r('app.media.ear'),
      title: '听筒播放',
      popClick: () => {
        if (this.messageItem.messageType === MessageTypeEnum.TEXT) {
          // 文本朗读
          VoiceTransfer.textToVoice(this.messageItem.messageContent)
        }
      }
    },
    {
      icon: $r('app.media.01_collection'),
      title: '收藏'
    },
    {
      icon: $r('app.media.icon_tab_convert_to_text'),
      title: '转文字',
      popClick: () => {
        if (this.messageItem.messageType === MessageTypeEnum.AUDIO) {
          VoiceTransfer.voiceToText(this.messageItem.sourceFilePath, (res) => {
            this.transferResult = res.result
          })
        }
        this.customPopup = false
      }
    },
    {
      icon: $r('app.media.delete'),
      title: '删除',
      popClick: async () => {
        // 如果语音文件存在则删除
        if (this.messageItem.sourceFilePath) {
          fileCapture.delFilePath(this.messageItem.sourceFilePath)
        }

        // 删除消息记录
        await preferencesUtils.removeMessageById(this.messageItem.connectUser.userId, this.messageItem.id)
        // 删除UI界面显示
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
  @State audioState: AnimationStatus = AnimationStatus.Initial
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

  @Builder
  imgBuilder() {
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
  }

  @Builder
  videoBuilder() {
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
  }

  @Builder
  textBuilder() {
    Text(this.messageItem.messageContent)
      .fontSize(14)
      .backgroundColor(this.messageItem.sender.userId === currentUser.userId ? $r('app.color.second_primary') :
      $r('app.color.white'))
      .borderRadius(4)
      .padding(10)
      .margin({ left: 10, right: 10 })
  }

  @Builder
  audioBuilder() {
    Column({ space: 10 }) {
      Row({ space: 5 }) {
        Text(`${this.messageItem.sourceDuration}″`)
          .textAlign(TextAlign.Center)
        ImageAnimator()
          .images([
            {
              src:
              $r("app.media.ic_public_voice3")
            },
            {
              src: $r("app.media.ic_public_voice1")
            },
            {
              src: $r("app.media.ic_public_voice2")
            },
            {
              src: $r("app.media.ic_public_voice3")
            }
          ])
          .iterations(-1)
          .duration(500)
          .state(this.audioState)
          .fillMode(FillMode.None)
          .width(20)
          .height(20)
          .rotate({
            angle: currentUser.userId === this.messageItem.sender.userId ? 180 : 0
          })
      }
      .width(this.getAudioWidth())
      .backgroundColor(currentUser.userId === this.messageItem.sender.userId ?
      $r('app.color.chat_primary') : $r('app.color.white'))
      .justifyContent(currentUser.userId === this.messageItem.sender.userId ? FlexAlign.End : FlexAlign.Start)
      .height(40)
      .padding({
        left: 10,
        right: 10
      })
      .margin({
        left: 10,
        right: 10
      })
      .borderRadius(4)
      .direction(currentUser.userId === this.messageItem.sender.userId ? Direction.Ltr : Direction.Rtl)
      .onClick(() => {
        AudioRenderer.start(this.messageItem.sourceFilePath, () => {
          this.audioState = AnimationStatus.Running
        },
          () => {
            this.audioState = AnimationStatus.Stopped
          }
        )
      })

      //添加条件渲染
      if (this.transferResult) {
        Text(this.transferResult)
          .backgroundColor(currentUser.userId === this.messageItem.sender.userId ?
          $r('app.color.second_primary') : $r('app.color.white'))
          .fontColor($r('app.color.text_primary'))
          .padding(10)
          .lineHeight(24)
          .margin({
            left: 10,
            right: 10
          })
          .borderRadius(5)
      }
    }
    .alignItems(currentUser.userId === this.messageItem.sender.userId ? HorizontalAlign.End : HorizontalAlign.Start)
  }

  // 获取语音宽度
  getAudioWidth() {
    let minWidth: number = 20
    let maxWidth: number = 90
    let calWidth: number = minWidth + (100 * this.messageItem.sourceDuration / 60)
    if (calWidth > maxWidth) {
      return maxWidth + "%"
    }
    return calWidth + "%"
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
            this.imgBuilder()
          } else if (this.messageItem.messageType === MessageTypeEnum.VIDEO) {
            this.videoBuilder()
          } else if (this.messageItem.messageType === MessageTypeEnum.AUDIO) {
            this.audioBuilder()
          } else if (this.messageItem.messageType === MessageTypeEnum.TEXT) {
            this.textBuilder()
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