import { UsersInfo } from './mUsers'
import { util } from '@kit.ArkTS'

export enum MessageTypeEnum {
  TEXT,
  IMAGE,
  AUDIO,
  VIDEO,
  LOCATION,
  LINK
}

export interface MessageInfo {
  id: string
  sender: UsersInfo // 发送者
  sendTime: number // 发送时间
  sourceFilePath: string // 资源地址
  sourceDuration: number // 发送的长度
  messageType: MessageTypeEnum // 发送的类型
  messageContent: string // 发送的内容
  connectUser: UsersInfo // 消息的归属者
}

export class mMessageModel implements MessageInfo {
  id: string
  sender: UsersInfo // 发送者
  sendTime: number // 发送时间
  sourceFilePath: string // 资源地址
  sourceDuration: number // 发送的长度
  messageType: MessageTypeEnum = MessageTypeEnum.TEXT // 发送的类型 默认发送文本
  messageContent: string // 发送的内容
  connectUser: UsersInfo // 消息的归属者

  constructor(mModel: MessageInfo) {
    this.id = mModel.id || util.generateRandomUUID()
    this.sender = mModel.sender
    this.sendTime = mModel.sendTime || Date.now()
    this.sourceFilePath = mModel.sourceFilePath
    this.sourceDuration = mModel.sourceDuration
    this.messageType = mModel.messageType || MessageTypeEnum.TEXT
    this.messageContent = mModel.messageContent
    this.connectUser = mModel.connectUser
  }
}