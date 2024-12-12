import HeaderCom from '../../components/HeaderCom'
import { router } from '@kit.ArkUI'

@Entry
@Component
struct Receipts_Payments {
  @State showPop?: boolean = false

  build() {
    Column() {
      // 头部显示
      HeaderCom({
        backItem: {
          icon: $r('app.media.back'),
          title: '',
          popClick: () => {
            router.back()
          }
        },
        item: {
          title: '收付款',
          icon: ''
        },
        showPop: this.showPop
      })
    }
    .height('100%')
    .width('100%')
    .backgroundColor($r('app.color.second_primary'))
  }
}