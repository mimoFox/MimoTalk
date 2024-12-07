export interface UsersInfo {
  userId: string
  userName: string
  avatar: ResourceStr
}

export const defaultUserInfo: UsersInfo[] = [
  {
    userId: '1',
    userName: '小可爱',
    avatar: 'https://iknow-pic.cdn.bcebos.com/96dda144ad345982c29d3c0f1ef431adcbef841c'
  },
  {
    userId: '2',
    userName: '女神',
    avatar: 'https://iknow-pic.cdn.bcebos.com/f11f3a292df5e0fe02d7579c4e6034a85fdf7264'
  },
  {
    userId: '3',
    userName: '木鱼',
    avatar: 'https://q8.itc.cn/q_70/images03/20240728/77ece92ffefc4ad7b28f86fcb85ae84f.jpeg'
  },
  {
    userId: '4',
    userName: '小鱼儿',
    avatar: 'https://pic.rmb.bdstatic.com/bjh/240226/events/7b0df3cf421dc74a5b759c1cf4e6ca1a3794.jpeg@h_1280'
  },
  {
    userId: '5',
    userName: 'Lucy',
    avatar: 'https://iknow-pic.cdn.bcebos.com/4afbfbedab64034faf14fb98bdc379310b551d56'
  }
]

export const currentUser: UsersInfo = {
  userId: 'root',
  userName: '',
  avatar: 'https://iknow-pic.cdn.bcebos.com/96dda144ad345982c29d3c0f1ef431adcbef841c'
}