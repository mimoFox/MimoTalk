import { display, promptAction } from '@kit.ArkUI'
import { mPopup } from '../models/mPopup'
import { mVoiceStateEnum } from '../models/mVoiceStateEnum'
import voiceRecCom from './voiceRecCom'
import { photoAccessHelper } from '@kit.MediaLibraryKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { fileIo } from '@kit.CoreFileKit'
import { camera, cameraPicker as picker } from '@kit.CameraKit'
import { requestMicPhonePermission } from '../utils/requestPermission'
import { abilityAccessCtrl, common } from '@kit.AbilityKit'
import AudioCaptrer, { fileCapture } from '../utils/audioCapturer'
import { UsersInfo } from '../models/mUsers'
import { VoiceTransfer } from '../utils/VoiceTransfer'


@Component
export default struct BottomInput {
  @State showVoice: boolean = false
  @State sendText: string = ''
  @State showVoiceRec: boolean = false
  @State screenWidth: number = 0
  @State screenHeight: number = 0
  @Provide voiceState: mVoiceStateEnum = mVoiceStateEnum.RECORDING
  @State showBottomMenu: boolean = false
  @Provide asrResult: string = ''
  bottomMenuList: mPopup[] = [
    {
      icon: $r('app.media.picture'),
      title: '图片',
      popClick: () => {
        promptAction.showToast({
          message: '选择图片'
        })
        this.submitPicture()

      }
    },
    {
      icon: $r('app.media.camera'),
      title: '拍摄',
      popClick: () => {
        promptAction.showToast({
          message: '拍摄图片'
        })
        this.submitVideo()

      }
    },
    {
      icon: $r('app.media.postion'),
      title: '位置'
    },
    {
      icon: $r('app.media.mic'),
      title: '语音输入'
    },
    {
      icon: $r('app.media.01_collection'),
      title: '收藏'
    },
    {
      icon: $r("app.media.id_card"),
      title: '个人名片'
    },
    {
      icon: $r('app.media.file'),
      title: '文件'
    },
    {
      icon: $r('app.media.music_fill'),
      title: '音乐'
    }
  ]
  @State audioFilePath: string = ''
  // 计算计时器
  @State timer: number = -1 // 定时器标记
  @State duration: number = 0
  @Prop receiver: UsersInfo
  sendMessage: (sendText: string) => void = () => {
  }
  sendPictureMessage: (filePath: string) => void = () => {
  }
  sendVideoMessage: (filePath: string) => void = () => {
  }
  sendAudioMessage: (filePath: string, duration: number) => void = () => {
  }

  async aboutToAppear(): Promise<void> {
    //1.获取整个屏幕的宽度与高度
    //2.获取当前手指触摸的坐标x-y
    //3.手势拖动的时候，判断当前手指触摸的坐标x-y是否大于屏幕高度- 录音区域的高度
    //4.如果大于 屏幕高度-录音区域的高度 说明手势拖动录音区域
    //5.如果小于 屏暮高度-录音区域的高度 说明手势不在拖动录音区域
    this.screenWidth = px2vp(display.getDefaultDisplaySync().width)
    this.screenHeight = px2vp(display.getDefaultDisplaySync().height)

    // 初始化录音
    await AudioCaptrer.init()
  }

  aboutToDisappear(): void {
    // 释放录音器
    AudioCaptrer.release()
  }

  // 显示弹层
  @Builder
  voiceRecBuilder() {
    Column() {
      // 语音输入组件
      voiceRecCom()
    }
  }

  // 底部菜单
  @Builder
  bottomMenuBuilder() {
    GridRow({ columns: 4 }) {
      ForEach(this.bottomMenuList, (item: mPopup) => {
        GridCol() {
          Column({ space: 5 }) {
            Column() {
              Image(item.icon).width(30).autoResize(true)
            }
            .height(40)
            .width(50)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
            .backgroundColor($r('app.color.white'))

            Text(item.title)
              .fontSize(12)
              .fontColor($r('app.color.text_primary'))
          }
        }
        .margin({ bottom: 10 })
        .onClick(() => {
          item.popClick && item.popClick()
        })
      })
    }
    .width('100%')
    .padding(20)
    .backgroundColor($r('app.color.bottom_color'))
  }

  // 发送消息
  submitMessage() {
    if (this.sendText) {
      this.sendMessage(this.sendText)
      this.sendText = ''
      focusControl.requestFocus('input')
    } else {
      promptAction.showToast({
        message: '发送内容不能为空！',
        duration: 500,
        bottom: 200
      })
    }
  }

  // 发送图片
  submitPicture() {

    try {
      // 配置选择相片的选项
      let PhotoSelectOptions = new photoAccessHelper.PhotoSelectOptions();

      // 选择的类型
      PhotoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_VIDEO_TYPE;

      // 选择的最大数量
      PhotoSelectOptions.maxSelectNumber = 9;

      // 打开相册
      let photoPicker = new photoAccessHelper.PhotoViewPicker();
      photoPicker.select(PhotoSelectOptions).then((PhotoSelectResult: photoAccessHelper.PhotoSelectResult) => {
        console.info('选择相片成功, 相片uri: ' + JSON.stringify(PhotoSelectResult));
        if (PhotoSelectResult.photoUris.length) {
          PhotoSelectResult.photoUris.forEach((item) => {
            // 将图片保存到沙箱
            // 如果路径存在则打开，不存在则创建
            let filePath = getContext().filesDir + '/' + Date.now() + '_mimo' + '.jpg'
            // 打开文件
            let file = fileIo.openSync(item, fileIo.OpenMode.READ_ONLY)

            fileIo.copyFileSync(file.fd, filePath)

            fileIo.closeSync(file.fd)

            this.sendPictureMessage(filePath)
          })
        }


      }).catch((err: BusinessError) => {
        console.error(`选择相片失败: ${err.code}, ${err.message}`);
      });
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      console.error(`选择相片失败: ${err.code}, ${err.message}`);
    }
  }

  // 发送拍摄图片或者视频
  async submitVideo() {
    try {
      let pickerProfile: picker.PickerProfile = {
        cameraPosition: camera.CameraPosition.CAMERA_POSITION_BACK
      };
      let pickerResult: picker.PickerResult = await picker.pick(getContext(),
        [picker.PickerMediaType.PHOTO, picker.PickerMediaType.VIDEO], pickerProfile);
      console.log("拍摄图片或者视频:" + JSON.stringify(pickerResult));

      if (pickerResult.mediaType === 'photo' && pickerResult.resultUri != '') {
        // 将图片保存到沙箱
        // 如果路径存在则打开，不存在则创建
        let filePath = getContext().filesDir + '/' + Date.now() + '_mimo' + '.jpg'
        // 打开文件
        let file = fileIo.openSync(pickerResult.resultUri, fileIo.OpenMode.READ_ONLY)

        fileIo.copyFileSync(file.fd, filePath)

        fileIo.closeSync(file.fd)

        this.sendPictureMessage(filePath)
      } else {
        // 将视频保存到沙箱
        // 如果路径存在则打开，不存在则创建
        let filePath = getContext().filesDir + '/' + Date.now() + '_mimo' + '.mp4'
        // 打开文件
        let file = fileIo.openSync(pickerResult.resultUri, fileIo.OpenMode.READ_ONLY)

        fileIo.copyFileSync(file.fd, filePath)

        fileIo.closeSync(file.fd)

        this.sendVideoMessage(filePath)
      }

    } catch (error) {
      let err = error as BusinessError;
      console.error(`the pick call failed. error code: ${err.code}`);
    }
  }

  submitAudio() {
    this.sendAudioMessage(this.audioFilePath, this.duration)
  }

  // 开始计时
  startTime() {
    this.timer = setInterval(() => {
      this.duration++
      promptAction.showToast({
        message: `当前语音:${this.duration}秒`
      })
    }, 1000)
  }

  // 结束计时
  endTime() {
    clearInterval(this.timer)
  }

  // 检测麦克风权限是否开启
  checkMicPermission() {
    let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    let context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;

    requestMicPhonePermission(context, (res) => {
      if (!res) {
        this.showVoiceRec = false
        // 再次申请权限
        atManager.requestPermissionOnSetting(context, ['ohos.permission.MICROPHONE'])
          .then((data: Array<abilityAccessCtrl.GrantStatus>) => {
            console.info('data:' + JSON.stringify(data));
          })
          .catch((err: BusinessError) => {
            console.error('data:' + JSON.stringify(err));
          });
      } else {
        // 开始录音
        this.audioFilePath = fileCapture.createAudioFile(this.receiver.userId)

        AudioCaptrer.start(this.audioFilePath)
      }
    })
  }

  // 停止录音
  // 松手判断逻辑
  stopRecord() {
    this.showVoiceRec = false

    AudioCaptrer.stop()

    this.endTime()

    if (this.voiceState === mVoiceStateEnum.RECORDING) {
      // 如果时间太短就不发送
      if (this.duration < 1) {
        promptAction.showToast({ message: '说话时间太短' })
        fileCapture.delFilePath(this.audioFilePath) // 删除路径
        return
      }
      this.submitAudio()
      this.duration = 0
      this.audioFilePath = ''
    } else if (this.voiceState === mVoiceStateEnum.CANCEL) {
      // 如果松手时，是取消状态 不管录的语音怎么样 直接删除
      fileCapture.delFilePath(this.audioFilePath) // 删除路径
      this.duration = 0
      this.audioFilePath = ''
    } else if (this.voiceState === mVoiceStateEnum.TRANSFER) {
      // 如果是转化文本类
      if (this.asrResult) {
        this.sendMessage(this.asrResult)
      }
      this.duration = 0
      this.asrResult = ''
      this.audioFilePath = ''
    }
    this.voiceState = mVoiceStateEnum.RECORDING
  }

  build() {
    Column() {

      // 输入栏
      Row({ space: 10 }) {
        Image(!this.showVoice ? $r('app.media.voiceprint') : $r('app.media.keyboard'))
          .width(25).height(25)
          .onClick(() => {
            this.showVoice = !this.showVoice
            if (this.showVoice) {
              animateTo({ duration: 500 }, () => {
                this.showBottomMenu = false
              })
            }
          })
          .animation({
            duration: 300,
            playMode: PlayMode.Reverse
          })

        if (this.showVoice) {
          Button('按住发送语音')
            .fontSize(16)
            .fontColor($r('app.color.text_primary'))
            .height(35)
            .layoutWeight(1)
            .backgroundColor($r('app.color.white'))
            .type(ButtonType.Normal)
            .borderRadius(4)
            .gesture(GestureGroup(
              GestureMode.Parallel,
              LongPressGesture()
                .onAction(() => {
                  // 显示蒙层
                  this.showVoiceRec = true
                  this.startTime()
                  // 长按手势开始
                  this.checkMicPermission()
                })
                .onActionEnd(() => {

                  // 停止录音
                  this.stopRecord()
                }),
              PanGesture()
                .onActionUpdate((event) => {
                  // 长按后移动更新
                  if (event.fingerList[0].globalY > this.screenHeight - 170) {
                    this.voiceState = mVoiceStateEnum.RECORDING
                  } else {
                    if (event.fingerList[0].globalX > this.screenWidth / 2) {
                      this.voiceState = mVoiceStateEnum.TRANSFER
                      VoiceTransfer.voiceToText(this.audioFilePath, (res) => {
                        this.asrResult = res.result
                      })
                    } else {
                      this.voiceState = mVoiceStateEnum.CANCEL
                    }
                  }


                })
                .onActionEnd(() => {
                  this.voiceState = mVoiceStateEnum.RECORDING
                })
            )

            )
            .bindContentCover(this.showVoiceRec, this.voiceRecBuilder())

        } else {
          TextArea({ text: $$this.sendText })
            .id('input')
            .focusable(!this.showBottomMenu)
            .layoutWeight(1)
            .backgroundColor($r('app.color.white'))
            .borderRadius(4)
            .onClick(() => {
              animateTo({ duration: 500 }, () => {
                this.showBottomMenu = false
              })
            })
            .onFocus(() => {
              animateTo({ duration: 500 }, () => {
                this.showBottomMenu = false
              })
            })

          // TextInput({ text: $$this.sendText })
          //   .id('input')
          //   .focusable(true)
          //   .height(35)
          //   .layoutWeight(1)
          //   .backgroundColor($r('app.color.white'))
          //   .borderRadius(4)
          //   .onSubmit(() => {
          //     if (this.sendText) {
          //       this.sendMessage(this.sendText)
          //       this.sendText = ''
          //       focusControl.requestFocus('input')
          //     } else {
          //       promptAction.showToast({
          //         message: '发送内容不能为空！',
          //         duration: 500,
          //         bottom: 200
          //       })
          //     }
          //   })
        }


        Row({ space: 10 }) {
          Image($r('app.media.emoji'))
            .width(25).height(25)
          if (this.sendText != '') {
            Button('发送')
              .height(40)
              .layoutWeight(1)
              .fontColor($r('app.color.white'))
              .backgroundColor($r('app.color.second_primary'))
              .type(ButtonType.Normal)
              .borderRadius(5)
              .stateEffect(true)
              .onClick(() => {
                this.submitMessage()
              })
          } else {
            Image($r('app.media.plus'))
              .width(25).height(25)
              .onClick(() => {
                animateTo({ duration: 500 }, () => {
                  this.showBottomMenu = !this.showBottomMenu
                })
              })
          }
        }
        .width(this.sendText === '' ? 60 : 100)
        .animation({ duration: 300 })
      }
      .width('100%')
      // .height(60)
      .padding(10)
      .backgroundColor($r('app.color.back_color'))
      .margin({ bottom: 10 })

      // 底部菜单栏
      if (this.showBottomMenu) {
        this.bottomMenuBuilder()
      }
    }
  }
}