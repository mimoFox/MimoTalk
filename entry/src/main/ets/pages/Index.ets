import { mTabs } from '../models/mTabs'

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
              Text('聊天页面')
            } else if (item.name === 'connect') {
              Text('通讯录页面')
            } else if (item.name === 'discover') {
              Text('发现页面')
            } else if (item.name === 'my') {
              Text('我的页面')
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