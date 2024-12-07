import { UsersInfo } from '../../models/mUsers'
import { router } from '@kit.ArkUI'
import BottomInput from '../../components/BottomInput'

@Entry
@Component
struct SingleChat {
  @State userItem: UsersInfo = {} as UsersInfo

  aboutToAppear(): void {
    this.userItem = router.getParams() as UsersInfo
    console.log('userItem' + JSON.stringify(this.userItem))
  }

  build() {
    Column() {
      Row() {
        Stack({ alignContent: Alignment.Start }) {
          Text(`${this.userItem.userName}`)
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

      Blank()
      // 底部输入栏
      BottomInput()
    }
    .height('100%')
    .width('100%')
  }
}