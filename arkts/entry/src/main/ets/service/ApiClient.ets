// HTTP API 客户端 — 对接 Spring Boot 后端
import { http } from '@kit.NetworkKit'
import { fileIo, fileUri } from '@kit.CoreFileKit'
import { ApiResponse } from '../model/ApiResponse'

// multipart 文件上传数据项
interface FilePart {
  name: string
  contentType: string
  data: ArrayBuffer
  remoteFileName: string
}

// Spring Boot 后端地址（开发环境）
// 真机调试时需改为电脑的局域网 IP，例如 http://192.168.1.xxx:8080
const BASE_URL = 'http://10.73.187.13:8080/api'

// 如果需要在模拟器上调试，使用以下地址：
// const BASE_URL = 'http://10.0.2.2:8080/api'

export class ApiClient {

  // GET 请求
  static async get<T>(path: string, params?: Record<string, string>): Promise<ApiResponse<T>> {
    try {
      const req = http.createHttp()
      let url = `${BASE_URL}${path}`
      if (params) {
        const query = Object.keys(params)
          .filter(k => params[k] !== undefined && params[k] !== '')
          .map(k => `${k}=${encodeURIComponent(params[k])}`).join('&')
        if (query) url += `?${query}`
      }
      const resp = await req.request(url, {
        method: http.RequestMethod.GET,
        header: { 'Content-Type': 'application/json' },
        connectTimeout: 10000,
        readTimeout: 15000
      })
      req.destroy()
      return JSON.parse(resp.result as string) as ApiResponse<T>
    } catch (err) {
      return { code: -1, message: `网络请求失败: ${JSON.stringify(err)}`, data: null as T }
    }
  }

  // POST 请求
  static async post<T>(path: string, body: object): Promise<ApiResponse<T>> {
    try {
      const req = http.createHttp()
      const resp = await req.request(`${BASE_URL}${path}`, {
        method: http.RequestMethod.POST,
        header: { 'Content-Type': 'application/json' },
        extraData: JSON.stringify(body),
        connectTimeout: 10000,
        readTimeout: 15000
      })
      req.destroy()
      return JSON.parse(resp.result as string) as ApiResponse<T>
    } catch (err) {
      return { code: -1, message: `网络请求失败: ${JSON.stringify(err)}`, data: null as T }
    }
  }

  // PUT 请求
  static async put<T>(path: string, body: object): Promise<ApiResponse<T>> {
    try {
      const req = http.createHttp()
      const resp = await req.request(`${BASE_URL}${path}`, {
        method: http.RequestMethod.PUT,
        header: { 'Content-Type': 'application/json' },
        extraData: JSON.stringify(body),
        connectTimeout: 10000,
        readTimeout: 15000
      })
      req.destroy()
      return JSON.parse(resp.result as string) as ApiResponse<T>
    } catch (err) {
      return { code: -1, message: `网络请求失败: ${JSON.stringify(err)}`, data: null as T }
    }
  }

  // DELETE 请求
  static async del<T>(path: string): Promise<ApiResponse<T>> {
    try {
      const req = http.createHttp()
      const resp = await req.request(`${BASE_URL}${path}`, {
        method: http.RequestMethod.DELETE,
        header: { 'Content-Type': 'application/json' },
        connectTimeout: 10000,
        readTimeout: 15000
      })
      req.destroy()
      return JSON.parse(resp.result as string) as ApiResponse<T>
    } catch (err) {
      return { code: -1, message: `网络请求失败: ${JSON.stringify(err)}`, data: null as T }
    }
  }

  // 多文件上传 — 使用 SDK 原生 multiFormDataList
  static async uploadFiles(uris: string[]): Promise<ApiResponse<Record<string, string[]>>> {
    try {
      const formData: FilePart[] = []

      for (let i = 0; i < uris.length; i++) {
        const uri = uris[i]
        // content URI → 实际文件路径
        const path = fileUri.getPath(uri)
        const file = fileIo.openSync(path, fileIo.OpenMode.READ_ONLY)
        const stat = fileIo.statSync(file.fd)
        const buf = new ArrayBuffer(stat.size)
        fileIo.readSync(file.fd, buf)
        fileIo.closeSync(file)

        const parts = uri.split('/')
        const filename = parts[parts.length - 1] || `photo_${i}.jpg`

        formData.push({
          name: 'files',
          contentType: 'image/jpeg',
          data: buf,
          remoteFileName: filename
        })
      }

      const req = http.createHttp()
      const resp = await req.request(`${BASE_URL}/upload`, {
        method: http.RequestMethod.POST,
        header: { 'Content-Type': 'multipart/form-data' },
        multiFormDataList: formData,
        connectTimeout: 30000,
        readTimeout: 30000
      })
      req.destroy()
      return JSON.parse(resp.result as string) as ApiResponse<Record<string, string[]>>
    } catch (err) {
      const emptyData: Record<string, string[]> = {}
      // 尽量提取可读的错误信息
      const e = err as Record<string, string>
      let detail = '未知错误'
      if (e && e['message'] as string) {
        detail = e['message'] as string
      } else {
        detail = `${err}`
      }
      return {
        code: -1,
        message: `上传失败: ${detail}`,
        data: emptyData
      }
    }
  }
}
