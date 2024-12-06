import { defaultUserInfo, UsersInfo } from '../models/mUsers'

@Component
export default struct Connect {
  @State userList: UsersInfo[] = []

  aboutToAppear(): void {
    this.userList = defaultUserInfo
  }

  build() {
    Column() {
      // 搜索栏
      Row() {
        Search({ placeholder: '搜索' })
          .backgroundColor($r('app.color.white'))
          .borderRadius(8)
          .height(35)
      }
      .width('100%')
      .padding({ left: 10, right: 10 })

      // 联系人
      List() {
        ForEach(this.userList, (user: UsersInfo) => {
          ListItem() {
            Row({ space: 10 }) {
              Image(user.avatar)
                .width(30).height(30)
                .borderRadius(15)
                .margin({ left: 10 })
              Column() {
                Text(user.userName).fontSize(14)

              }
              .width('100%')
              .height('100%')
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .height(50)
          }
          .stateStyles({
            pressed: {
              .backgroundColor($r('app.color.second_back_color'))
            },
            normal: {
              .backgroundColor($r('app.color.white'))
            }
          })

        }, (user: UsersInfo) => user.userId)
        // 不重复的情况，可以填写第三个参数
      }
      .width('100%')
      .layoutWeight(1)
      .divider({
        strokeWidth: 0.2,
        startMargin: 46,
        endMargin: 2,
        color: $r('app.color.black')
      })
      .backgroundColor($r('app.color.white'))
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.back_color'))
  }
}