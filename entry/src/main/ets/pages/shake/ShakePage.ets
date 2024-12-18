import { AVPlayerClass } from '../../utils/AVPlayerClass'
import { sensor } from '@kit.SensorServiceKit'
import { webSocket } from '@kit.NetworkKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { promptAction } from '@kit.ArkUI'

interface messageModel {
  id: string
  name: string
  text: string
}

@Entry
@Component
struct ShakePage {
  @State timer: number = -1
  @State angle: number = 0
  @State startRange: number = 30 // 两次加速度差值大于阈值，判定进行了摇一摇
  @State endRange: number = 10 // 两次加速度差值小于阈值，停止摇动手机
  @State isShake: boolean = false // 是否摇动手机
  @State lastX: number = 0
  @State lastY: number = 0
  @State lastZ: number = 0
  @State isConnect: boolean = false
  @State nickName: string = ''
  @State content: string = ''
  @State ws: webSocket.WebSocket | null = null
  @State roomList: messageModel[] = []
  scroller: Scroller = new Scroller()

  // 摇一摇动画
  run() {
    this.timer = setInterval(() => {
      if (this.angle !== 30) {
        this.angle = 30
      } else {
        this.angle = 0
      }
      // 播放音频
      AVPlayerClass.play("shake")
      this.onSensor()
    }, 1000)
  }

  stop() {
    setTimeout(() => {
      // 关闭动画
      clearInterval(this.timer)
    }, 1000)
  }

  handleShake(data: sensor.AccelerometerResponse) {
    let range = Math.abs(data.x - this.lastX) + Math.abs(data.y - this.lastY) + Math.abs(data.z - this.lastZ)
    if (range > this.startRange) {
      // 开始摇一摇
      this.isShake = true
      this.run()
    }
    if (range < this.endRange && this.isShake) {
      // 结束摇一摇,执行业务
      // AlertDialog.show({ message: '摇一摇了！' })
      this.isShake = false
      this.stop()

    }
    // 记录最后一次摇一摇加速度
    this.lastX = data.x
    this.lastY = data.y
    this.lastZ = data.z
  }

  // 监听动力加速度传感器
  onSensor() {
    try {
      let num: number = 15
      sensor.on(sensor.SensorId.ACCELEROMETER, (data: sensor.AccelerometerResponse) => {
        console.log('Succeeded in invoking on. X-coordinate component: ' + data.x);
        console.log('Succeeded in invoking on. Y-coordinate component: ' + data.y);
        console.log('Succeeded in invoking on. Z-coordinate component: ' + data.z);
        // 摇一摇检测...
        if (data.x > num || data.x < -num || data.y < -num || data.y > num || data.z > num || data.z < -num) {
          this.handleShake(data)
        }

      }, { interval: 10000000000 });
    } catch (error) {
      console.error(error)
    }
  }

  aboutToAppear(): void {
    this.onSensor()
  }

  aboutToDisappear() {
    sensor.off(sensor.SensorId.ACCELEROMETER);
  }

  connectWebSocket() {
    if (this.isConnect) {
      return
    }
    this.ws = webSocket.createWebSocket()


    this.ws.connect('ws://ss.9yuecloud.com', (err: BusinessError, value: boolean) => {
      if (!err) {
        promptAction.showToast({
          message: '等待连接'
        })
        this.isConnect = true
      } else {
        promptAction.showToast({
          message: '连接失败'
        })
        console.log('连接失败： ' + JSON.stringify(err))
      }
    })

    this.ws.on('open', (err: BusinessError, value: object) => {
      if (!err) {
        promptAction.showToast({
          message: '打开连接'
        })

      } else {
        promptAction.showToast({
          message: '打开失败'
        })
      }
    })

    this.ws.on('close', (err: BusinessError, value: webSocket.CloseResult) => {
      if (!err) {
        promptAction.showToast({
          message: '关闭连接'
        })
        this.isConnect = false
      } else {
        promptAction.showToast({
          message: '关闭失败'
        })
      }
    })

    this.ws.on('error', (err: BusinessError) => {
      if (!err) {
        promptAction.showToast({
          message: '错误连接'
        })
      } else {
        promptAction.showToast({
          message: '和服务器断开连接！'
        })
      }
    })


    this.ws.on('message', (err: BusinessError, value: string | ArrayBuffer | messageModel) => {
      if (!err) {

        const data = JSON.parse(JSON.stringify(value)) as messageModel
        const newData: messageModel = JSON.parse(data.toString()) as messageModel

        if (newData.text) {
          this.roomList.push(newData as messageModel)
        } else {
          promptAction.showToast({
            message: value.toString()
          })
        }


      } else {
        console.log('接受消息失败： ' + JSON.stringify(err))
      }
    })
  }

  sendMessage() {
    this.ws?.send(JSON.stringify({
      id: Date.now() + this.nickName,
      name: this.nickName,
      text: this.content
    }))
  }

  build() {
    Column({ space: 10 }) {
      // Image($r('app.media.shake'))
      //   .width('50%')
      //   .autoResize(true)
      //   .animation({
      //     duration: 1000
      //   })
      //   .rotate({
      //     angle: this.angle
      //   })

      Button('连接服务器')
        .onClick(() => {
          this.connectWebSocket()
        })
      Row() {
        TextInput({ placeholder: '请输入用户名', text: $$this.nickName })
          .layoutWeight(1)

        Button('加入聊天室')
          .onClick(() => {
            if (!this.nickName) {
              promptAction.showToast({ message: '用户名不能为空' })
              return
            }
            promptAction.showToast({
              message: `欢迎${this.nickName}加入聊天室！`
            })
            this.connectWebSocket()

          })
      }
      .width('100%')

      Scroll(this.scroller) {
        Column({ space: 20 }) {
          ForEach(this.roomList, (item: messageModel) => {
            Row() {
              Text(`${item.name}说：${item.text}`)
                .fontSize(14)
            }
            .width('100%')
            .borderRadius(5)
            .padding(10)
            .justifyContent(FlexAlign.Start)
            .backgroundColor($r('app.color.primary'))
          })
        }
      }
      .width('100%')
      .margin({ top: 20 })
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .align(Alignment.Top)


      Row() {
        TextInput({ placeholder: '请输入消息内容', text: $$this.content })
          .layoutWeight(1)

        Button('发送')
          .onClick(() => {
            if (!this.content) {
              return
            }
            this.sendMessage()
            this.content = ''
            this.scroller.scrollEdge(Edge.Bottom)
          })
      }
      .width('100%')

    }
    .width('100%')
    .height('100%')
    .padding(20)
    .justifyContent(FlexAlign.Center)
  }
}