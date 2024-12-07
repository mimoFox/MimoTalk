import { Http } from '../utils/Http'

export interface ChatData {
  type: number
  info: ChatDataInfo
}

export interface ChatDataInfo {
  text: string
}

export interface paramsInfo {
  userid: number
  spoken: string
}

export const getMessageInfo = (keyword: string): Promise<ChatData> => {
  return Http.get<ChatData>(`/bot?userid=${Date.now()}&spoken=${keyword}`)
}