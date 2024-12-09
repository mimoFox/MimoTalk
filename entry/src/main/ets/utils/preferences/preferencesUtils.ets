import { preferences } from '@kit.ArkData'
import { mMessageModel } from '../../models/mMessage'

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
    store.putSync(message.id, message)
    // 写入磁盘
    await store.flush()
  }

  //获取某个人的所有数据

  //移除某个人的一条数据

  //移除某个人的所有数据

  //获取所有人的最后一条数据

}