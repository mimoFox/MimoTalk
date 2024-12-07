import axios, { AxiosError, AxiosResponse, InternalAxiosRequestConfig } from '@ohos/axios';

//  https://api.ownthink.com/bot?userid=user&spoken=测试

const server = axios.create({
  baseURL: 'https://api.ownthink.com',
  timeout: 10000
})


// 请求拦截器
server.interceptors.request.use((config: InternalAxiosRequestConfig) => {
  // Do something about the request data.
  return config;
}, (error: AxiosError) => {
  // Do something with the request error.
  return Promise.reject(error);
});


// 响应拦截器
server.interceptors.response.use((response: AxiosResponse) => {
  // Do something about the response data.
  return response.data.data;
}, (error: AxiosError) => {
  // Do something with the response error.
  return Promise.reject(error);
});

// 封装请求方法
export class Http {
  static get<T>(url: string, params?: object) {
    return server.get<null, T>(url, { params })
  }

  static post<T>(url: string, data?: object) {
    return server.post<null, T>(url, data)
  }

  static put<T>(url: string, data?: object) {
    return server.put<null, T>(url, data)
  }

  static delete<T>(url: string, data?: object) {
    return server.delete<null, T>(url, data)
  }
}

export default server