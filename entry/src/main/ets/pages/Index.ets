import ChatList from '../components/ChatList'
import Connect from '../components/Connect'
import { mTabs } from '../models/mTabs'
import Find from './find/Find'
import My from './my/My'

@Entry
@Component
struct Index {
  @State tabList: mTabs[] = [
    {
      name: 'mChat',
      title: '聊天',
      normalImg: $r('app.media.tabbar_home'),
      activeImg: $r('app.media.tabbar_home_active'),
    },
    {
      name: 'connect',
      title: '通讯录',
      normalImg: $r('app.media.tabbar_see'),
      activeImg: $r('app.media.tabbar_see_active'),
    },
    {
      name: 'discover',
      title: '发现',
      normalImg: $r('app.media.tabbar_discover'),
      activeImg: $r('app.media.tabbar_discover_active'),
    },
    {
      name: 'my',
      title: '我的',
      normalImg: $r('app.media.tabbar_my'),
      activeImg: $r('app.media.tabbar_my_active'),
    }
  ]
  @State currentIndex: number = 0

  @Builder
  tabsBuilder(item: mTabs) {
    Column() {
      Image(this.tabList[this.currentIndex].name === item.name ? item.activeImg : item.normalImg).width(20).height(20)
      Text(item.title)
        .fontSize(14)
        .fontColor(this.tabList[this.currentIndex].name === item.name ? $r('app.color.primary') :
        $r('app.color.text_primary'))
    }
  }

  build() {
    Column() {
      Tabs({
        index: $$this.currentIndex,
        barPosition: BarPosition.End
      }) {
        ForEach(this.tabList, (item: mTabs) => {
          TabContent() {
            if (item.name === 'mChat') {
              ChatList()
            } else if (item.name === 'connect') {
              Connect()
            } else if (item.name === 'discover') {
              Find()
            } else if (item.name === 'my') {
              My()
            }

          }.tabBar(this.tabsBuilder(item))
        })
      }
      .animationDuration(300)
    }
    .height('100%')
    .width('100%')
  }
}