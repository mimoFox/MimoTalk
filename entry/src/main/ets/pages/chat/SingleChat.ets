import { currentUser, UsersInfo } from '../../models/mUsers'
import { router } from '@kit.ArkUI'
import BottomInput from '../../components/BottomInput'
import Message from '../../components/Message'
import { MessageInfo, mMessageModel } from '../../models/mMessage'
import { getMessageInfo } from '../../api'
import { preferencesUtils } from '../../utils/preferences/preferencesUtils'
import { emitter } from '@kit.BasicServicesKit'

@Entry
@Component
struct SingleChat {
  @State receiver: UsersInfo = {} as UsersInfo
  @State messageList: mMessageModel[] = [
    new mMessageModel(
      {
        id: '1',
        sender: currentUser,
        sendTime: 123586489,
        sourceFilePath: '',
        sourceDuration: 0,
        messageType: 0,
        messageContent: '在吗？',
        connectUser: currentUser
      }),
    new mMessageModel(
      {
        id: '2',
        sender: {
          userId: 'Mimo',
          userName: 'Mimo',
          avatar: 'https://iknow-pic.cdn.bcebos.com/96dda144ad345982c29d3c0f1ef431adcbef841c'
        },
        sendTime: 123586489,
        sourceFilePath: '',
        sourceDuration: 0,
        messageType: 0,
        messageContent: '怎么了？',
        connectUser: currentUser
      }),
    new mMessageModel(
      {
        id: '3',
        sender: currentUser,
        sendTime: 123586489,
        sourceFilePath: '',
        sourceDuration: 0,
        messageType: 0,
        messageContent: '要不要出来喝一杯？',
        connectUser: currentUser
      }),
    new mMessageModel(
      {
        id: '4',
        sender: {
          userId: 'Mimo',
          userName: 'Mimo',
          avatar: 'https://iknow-pic.cdn.bcebos.com/96dda144ad345982c29d3c0f1ef431adcbef841c'
        },
        sendTime: 123586489,
        sourceFilePath: '',
        sourceDuration: 0,
        messageType: 0,
        messageContent: '好，老地方见',
        connectUser: currentUser
      })
  ]
  @State sendText: string = ''
  scroller: Scroller = new Scroller()
  @State receiverInput: boolean = false

  aboutToAppear(): void {
    this.receiver = router.getParams() as UsersInfo

    // 获取当前聊天对象的所有聊天记录
    this.messageList = preferencesUtils.getMessageById(this.receiver.userId)
    console.log('userItem' + JSON.stringify(this.receiver))
  }

  sendMessage(sendText: string) {
    let message = new mMessageModel({
      connectUser: this.receiver,
      messageContent: sendText,
      sender: currentUser
    } as MessageInfo)

    this.messageList.push(message)

    // 存储聊天记录
    preferencesUtils.addMessage(this.receiver.userId, message)

    // 自动定位到最后一条消息
    this.scroller.scrollEdge(Edge.Bottom)

    this.getMessage(sendText)
  }

  // 获取机器人回复信息
  async getMessage(keyword: string) {
    this.receiverInput = true
    let res = await getMessageInfo(keyword)
    let message = new mMessageModel({
      connectUser: this.receiver,
      messageContent: res?.info?.text,
      sender: this.receiver
    } as MessageInfo)

    this.messageList.push(message)

    // 存储聊天记录
    preferencesUtils.addMessage(this.receiver.userId, message)

    this.receiverInput = false
    // 自动定位到最后一条消息
    this.scroller.scrollEdge(Edge.Bottom)
  }

  // 删除单条聊天记录
  deleteUiMessage(messageId: string) {
    const index = this.messageList.findIndex((item: MessageInfo) => item.id === messageId)
    this.messageList.splice(index, 1)

    emitter.emit(preferencesUtils.storeName)
  }

  build() {
    Column() {
      Row() {
        Stack({ alignContent: Alignment.Start }) {
          Text(this.receiverInput ? '对方正在输入...' : `${this.receiver.userName}`)
            .fontSize(20)
            .textAlign(TextAlign.Center)
            .width('100%')
          Image($r('app.media.back'))
            .width(20).height(20)
            .padding({ left: 10 })
            .onClick(() => {
              router.back()
            })
        }
      }
      .width('100%')
      .height(50)

      // 聊天内容显示
      List({ scroller: this.scroller }) {
        ForEach(this.messageList, (item: mMessageModel) => {
          ListItem() {
            Message({
              messageItem: item,
              deleteUiMessage: (messageId: string) => {
                this.deleteUiMessage(messageId)
              }
            })
          }
        })
      }
      .layoutWeight(1)
      .backgroundColor($r('app.color.second_back_color'))

      // 底部输入栏
      BottomInput({
        sendMessage: (sendText: string) => {
          this.sendMessage(sendText)
        }
      })
    }
    .height('100%')
    .width('100%')

  }
}