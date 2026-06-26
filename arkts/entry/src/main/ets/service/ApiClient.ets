// HTTP API 客户端 — 对接 Spring Boot 后端（自动探测服务器 IP + Token 鉴权）
import { http } from '@kit.NetworkKit'
import { fileIo } from '@kit.CoreFileKit'
import { preferences } from '@kit.ArkData'
import { ApiResponse } from '../model/ApiResponse'
import { discoverServerIp } from '../common/ServerDiscovery'

interface FilePart {
  name: string
  contentType: string
  data: ArrayBuffer
  remoteFileName: string
}

let baseUrl = ''
let initPromise: Promise<void> | null = null
let authToken: string = ''
let prefsInitialized = false

const PREF_NAME = 'chuizhi_shop'
const KEY_TOKEN = 'token'
const KEY_USER_ID = 'userId'
const KEY_USER_ROLE = 'userRole'

// 初始化（仅内存，不持久化 token — 每次启动需重新登录）
async function initPrefs(): Promise<void> {
  if (prefsInitialized) return
  // 不从磁盘恢复 token，每次启动都是干净状态
  prefsInitialized = true
}

export async function ensureTokenLoaded(): Promise<void> {
  await initPrefs()
}

export function getToken(): string {
  return authToken
}

export async function saveToken(token: string): Promise<void> {
  authToken = token
  await initPrefs()
}

export async function clearToken(): Promise<void> {
  authToken = ''
  await initPrefs()
}

async function ensureBaseUrl(): Promise<void> {
  if (baseUrl) return
  if (!initPromise) {
    initPromise = discoverServerIp().then((ip) => {
      baseUrl = `http://${ip}:8080/api`
    })
  }
  await initPromise
}

function authHeaders(): Record<string, string> {
  const h: Record<string, string> = { 'Content-Type': 'application/json' }
  if (authToken) h['Authorization'] = `Bearer ${authToken}`
  return h
}

export class ApiClient {

  private static parseResponse<T>(result: string | Object | ArrayBuffer): T {
    if (typeof result === 'string') {
      return JSON.parse(result as string) as T
    }
    return result as T
  }

  // ---- 公开方法 ----

  static async get<T>(path: string, params?: Record<string, string>): Promise<ApiResponse<T>> {
    try {
      await initPrefs()
      await ensureBaseUrl()
      const req = http.createHttp()
      let url = `${baseUrl}${path}`
      if (params) {
        const query = Object.keys(params)
          .filter(k => params[k] !== undefined && params[k] !== '')
          .map(k => `${k}=${encodeURIComponent(params[k])}`).join('&')
        if (query) url += `?${query}`
      }
      const resp = await req.request(url, {
        method: http.RequestMethod.GET,
        header: authHeaders(),
        connectTimeout: 10000,
        readTimeout: 15000
      })
      req.destroy()
      return ApiClient.parseResponse<ApiResponse<T>>(resp.result)
    } catch (err) {
      return { code: -1, message: `网络请求失败: ${JSON.stringify(err)}`, data: null as T }
    }
  }

  static async post<T>(path: string, body: object): Promise<ApiResponse<T>> {
    try {
      await initPrefs()
      await ensureBaseUrl()
      const req = http.createHttp()
      const resp = await req.request(`${baseUrl}${path}`, {
        method: http.RequestMethod.POST,
        header: authHeaders(),
        extraData: JSON.stringify(body),
        connectTimeout: 10000,
        readTimeout: 15000
      })
      req.destroy()
      return ApiClient.parseResponse<ApiResponse<T>>(resp.result)
    } catch (err) {
      return { code: -1, message: `网络请求失败: ${JSON.stringify(err)}`, data: null as T }
    }
  }

  static async put<T>(path: string, body: object): Promise<ApiResponse<T>> {
    try {
      await initPrefs()
      await ensureBaseUrl()
      const req = http.createHttp()
      const resp = await req.request(`${baseUrl}${path}`, {
        method: http.RequestMethod.PUT,
        header: authHeaders(),
        extraData: JSON.stringify(body),
        connectTimeout: 10000,
        readTimeout: 15000
      })
      req.destroy()
      return ApiClient.parseResponse<ApiResponse<T>>(resp.result)
    } catch (err) {
      return { code: -1, message: `网络请求失败: ${JSON.stringify(err)}`, data: null as T }
    }
  }

  static async del<T>(path: string): Promise<ApiResponse<T>> {
    try {
      await initPrefs()
      await ensureBaseUrl()
      const req = http.createHttp()
      const resp = await req.request(`${baseUrl}${path}`, {
        method: http.RequestMethod.DELETE,
        header: authHeaders(),
        connectTimeout: 10000,
        readTimeout: 15000
      })
      req.destroy()
      return ApiClient.parseResponse<ApiResponse<T>>(resp.result)
    } catch (err) {
      return { code: -1, message: `网络请求失败: ${JSON.stringify(err)}`, data: null as T }
    }
  }

  // 多文件上传
  static async uploadFiles(uris: string[]): Promise<ApiResponse<Record<string, string[]>>> {
    try {
      await ensureBaseUrl()
      const formData: FilePart[] = []

      for (let i = 0; i < uris.length; i++) {
        const uri = uris[i]
        const file = fileIo.openSync(uri, fileIo.OpenMode.READ_ONLY)
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
      const resp = await req.request(`${baseUrl}/upload`, {
        method: http.RequestMethod.POST,
        header: { 'Content-Type': 'multipart/form-data' },
        multiFormDataList: formData,
        connectTimeout: 30000,
        readTimeout: 30000
      })
      req.destroy()
      return ApiClient.parseResponse<ApiResponse<Record<string, string[]>>>(resp.result)
    } catch (err) {
      const emptyData: Record<string, string[]> = {}
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
