import { preferences } from '@kit.ArkData'
import { mMessageModel } from '../../models/mMessage'
import { defaultUserInfo, UsersInfo } from '../../models/mUsers'
import { emitter } from '@kit.BasicServicesKit'

export class preferencesUtils {
  static context: Context
  static storeName: string = 'MIMO_CHAT'

  // 初始化
  static init(context: Context) {
    preferencesUtils.context = context
  }

  // 创建/获取仓库
  static getStore(userId: string) {
    return preferences.getPreferencesSync(preferencesUtils.context, {
      name: `${preferencesUtils.storeName}_${userId}`
    })
  }

  //给某个人的仓库添加一条数据
  static async addMessage(userId: string, message: mMessageModel) {
    // 获取到创建的仓库
    const store = preferencesUtils.getStore(userId)
    // 添加数据
    // 注意：JSON.stringify(message) 要转换成json格式
    store.putSync(message.id, JSON.stringify(message))
    // 写入磁盘
    await store.flush()

    // 发布消息
    emitter.emit(preferencesUtils.storeName)
  }


  //移除某个人的一条数据
  static async removeMessageById(userId: string) {
    // 获取到创建的仓库
    const store = preferencesUtils.getStore(userId)

    store.deleteSync(userId)

    await store.flush()
  }

  //移除某个人的所有数据
  static removeAllMessageById(userId: string) {
    preferences.deletePreferences(preferencesUtils.context, {
      name: `${preferencesUtils.storeName}_${userId}`
    })
  }

  //获取某个人的所有数据
  static getMessageById(userId: string) {
    // 获取到创建的仓库
    const store = preferencesUtils.getStore(userId)
    const all = store.getAllSync() as object
    if (all) {
      try {
        const messageList = Object.values(all).map((item: string) => JSON.parse(item) as mMessageModel)

        console.log('mList', JSON.stringify(messageList))

        // 排序聊天记录列表
        messageList.sort((a, b) => a.sendTime - b.sendTime)

        return messageList

      } catch (err) {
        console.log('errMessage' + err)
      }
    }
    return []
  }

  //获取所有人的最后一条数据
  static getAllLastMessage() {
    // 所有联系人的最后一条消息的列表
    const lastMessageList: mMessageModel[] = []

    // 遍历所有有聊天记录的消息
    defaultUserInfo.forEach((user: UsersInfo) => {
      const messageList = preferencesUtils.getMessageById(user.userId)
      if (messageList.length) {
        lastMessageList.push(messageList[messageList.length-1])
      }
    })
    lastMessageList.sort((a, b) => b.sendTime - a.sendTime)
    return lastMessageList
  }
}