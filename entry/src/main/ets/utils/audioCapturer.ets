import { fileIo } from '@kit.CoreFileKit';
import { audio } from '@kit.AudioKit';

class Options {
  offset?: number;
  length?: number;
}

export class fileCapture {
  // 创建音频文件
  static createAudioFile(userId: string) {
    // 判断有无路径,没有就创建
    let dirPath = getContext().filesDir + '/' + userId
    let flag = fileIo.accessSync(dirPath) // 判断目录是否存在
    if (!flag) {
      // 目录不存在就创建目录
      fileIo.mkdirSync(dirPath)
    }

    // 定义音频文件的类型，和保存路径
    let filePath = dirPath + '/' + Date.now() + '_mimo' + '.wav'

    // 定义保存的文件流
    let file = fileIo.openSync(filePath, fileIo.OpenMode.CREATE)

    // 关闭文件
    fileIo.closeSync(file)

    // 将文件路径返回出去
    return filePath
  }

  // 删除某个文件
  static delFilePath(filePath: string) {
    if (filePath) {
      fileIo.unlinkSync(filePath)
    }
  }

  // 删除整个人的目录
  static delUserPath(userId: string) {
    if (userId) {
      let dirPath = getContext().filesDir + '/' + userId
      let flag = fileIo.accessSync(dirPath)
      if (flag) {
        fileIo.rmdirSync(dirPath)
      }
    }
  }
}

export default class AudioCaptrer {
  static audioCapturer: audio.AudioCapturer
  static audioStreamInfo: audio.AudioStreamInfo = {
    // 需要注意： 语音转文字只能支持真机，只能支持采样率为16000赫兹的pcm音频识别
    // AudioCaputur/AudioRenderer 都要换成16000赫兹
    samplingRate: audio.AudioSamplingRate.SAMPLE_RATE_16000,
    channels: audio.AudioChannel.CHANNEL_2,
    sampleFormat: audio.AudioSampleFormat.SAMPLE_FORMAT_S16LE,
    encodingType: audio.AudioEncodingType.ENCODING_TYPE_RAW
  }
  static audioCapturerInfo: audio.AudioCapturerInfo = {
    source: audio.SourceType.SOURCE_TYPE_MIC,
    capturerFlags: 0
  }
  static audioCapturerOptions: audio.AudioCapturerOptions = {
    streamInfo: AudioCaptrer.audioStreamInfo,
    capturerInfo: AudioCaptrer.audioCapturerInfo
  }
  static recording: boolean = false

  // 初始化录音采集器
  static async init() {
    AudioCaptrer.audioCapturer = await audio.createAudioCapturer(AudioCaptrer.audioCapturerOptions)
  }

  // 开始录音
  static async start(filePath: string) {
    try {
      if (!AudioCaptrer.audioCapturer) {
        return
      }
      let file = fileIo.openSync(filePath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE)
      let bufferSize = fileIo.statSync(file.fd).size

      // 录音中
      AudioCaptrer.recording = true

      // 开始录音
      await AudioCaptrer.audioCapturer.start()

      // 循环保存录音文件
      while (AudioCaptrer.recording) {
        let readDataCallback = (buffer: ArrayBuffer) => {
          if (bufferSize) {
            let options: Options = {
              offset: bufferSize,
              length: buffer.byteLength
            }
            fileIo.writeSync(file.fd, buffer, options)
            bufferSize += buffer.byteLength
          }
        }
        AudioCaptrer.audioCapturer.on('readData', readDataCallback);
      }


    } catch (err) {
    }

  }

  // 停止录音
  static stop() {
    if (AudioCaptrer.audioCapturer) {
      AudioCaptrer.audioCapturer.stop()
      AudioCaptrer.recording = false
    }
  }

  static release() {
    if (AudioCaptrer.audioCapturer) {
      AudioCaptrer.audioCapturer.release()
      AudioCaptrer.recording = false
    }
  }
}

export class AudioRenderer {
  static renderIng: boolean = false // 是否正在播放
  // 实例
  static renderModel: audio.AudioRenderer
  // 采样配置
  static audioStreamInfo: audio.AudioStreamInfo = {
    // 需要注意： 语音转文字只能支持真机，只能支持采样率为16000赫兹的pcm音频识别
    // AudioCaputur/AudioRenderer 都要换成16000赫兹
    samplingRate: audio.AudioSamplingRate.SAMPLE_RATE_16000,
    channels: audio.AudioChannel.CHANNEL_1,
    sampleFormat: audio.AudioSampleFormat.SAMPLE_FORMAT_S16LE,
    encodingType: audio.AudioEncodingType.ENCODING_TYPE_RAW
  };
  static audioRendererInfo: audio.AudioRendererInfo = {
    rendererFlags: 0, // 音频渲染器 0 普通  1 低时延 (不支持)
    usage: audio.StreamUsage.STREAM_USAGE_VOICE_ASSISTANT
    // 场景
  }
  // 创建播放器的参数准备好了
  static audioRendererOptions: audio.AudioRendererOptions = {
    streamInfo: AudioRenderer.audioStreamInfo,
    rendererInfo: AudioRenderer.audioRendererInfo
  }
  // 读取的size
  static renderSize: number = 0
  // 文件的size
  static maxSize: number = 0
  // 读取的文件
  static renderFile: fileIo.File
  // 播放的回调函数
  static renderCallback: (() => void) | undefined

  // 初始化方法
  static async init() {
    // 当实例对象不存在的时候才创建
    if (!AudioRenderer.renderModel) {
      // 创建实例
      AudioRenderer.renderModel = await audio.createAudioRenderer(AudioRenderer.audioRendererOptions)
      // 监听事件
      AudioRenderer.renderModel.on('writeData', (buffer: ArrayBuffer) => {
        if (AudioRenderer.renderFile) {
          fileIo.readSync(AudioRenderer.renderFile.fd, buffer, {
            offset: AudioRenderer.renderSize,
            length: buffer.byteLength
          })
          AudioRenderer.renderSize += buffer.byteLength
          // 自动结束
          if (AudioRenderer.renderSize >= AudioRenderer.maxSize) {
            fileIo.closeSync(AudioRenderer.renderFile.fd)
            AudioRenderer.stop()
          }
        }
      })
    }
  }

  // 音频的释放和暂停
  static async stop() {
    if (AudioRenderer.renderModel && AudioRenderer.renderModel.state === audio.AudioState.STATE_RUNNING) {
      await AudioRenderer.renderModel.stop()
      AudioRenderer.renderSize = 0
      AudioRenderer.maxSize = 0
    }
  }

  // 开始语音播放
  static async start(filePath: string, startCallback?: () => void, endCallback?: () => void) {
    if (AudioRenderer.renderModel && filePath) {
      // 可能有正在播放的语音，手动结束一次（也可以加个标记，但是没必要）
      await AudioRenderer.stop()
      // 停止上一次动画
      AudioRenderer.renderCallback && AudioRenderer.renderCallback()
      // 开始新的动画
      startCallback && startCallback()

      // 开始新的播放
      AudioRenderer.renderFile = fileIo.openSync(filePath, fileIo.OpenMode.READ_ONLY) // 读这个文件的buffer  一段段的读取 1280
      AudioRenderer.maxSize = fileIo.statSync(AudioRenderer.renderFile.fd).size // 语音详细信息
      AudioRenderer.renderCallback = endCallback
      await AudioRenderer.renderModel.start()
    }
  }

  // 释放
  static async release() {
    if (AudioRenderer.renderModel) {
      await AudioRenderer.stop() //先停，可能还在播放
      await AudioRenderer.renderModel.release() // 释放
    }
  }
}