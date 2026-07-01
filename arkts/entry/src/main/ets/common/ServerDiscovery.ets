// 服务器地址自动探测 — 启动时并行探测候选 IP，缓存结果
import { http } from '@kit.NetworkKit'
import { preferences } from '@kit.ArkData'
import { SERVER_IP } from './LocalConfig'

const PREF_NAME = 'server_config'
const KEY_LAST_IP = 'last_server_ip'
const PING_TIMEOUT = 2000  // 单个候选的超时（ms）
const PING_PATH = '/api/ping'

// 并行探测所有候选 IP，返回第一个可用的
async function probeCandidates(candidates: string[]): Promise<string | null> {
  const tasks = candidates.map((ip) => probeOne(ip))
  // 用 Promise.race 拿到最先成功的
  return new Promise<string | null>((resolve) => {
    let settled = false
    for (let i = 0; i < tasks.length; i++) {
      tasks[i].then((ok) => {
        if (!settled && ok) {
          settled = true
          resolve(ok)
        }
      })
    }
    // 全部失败
    Promise.all(tasks).then(() => {
      if (!settled) {
        settled = true
        resolve(null)
      }
    })
  })
}

// 探测单个 IP，成功返回 IP，失败返回 null
async function probeOne(ip: string): Promise<string | null> {
  try {
    const req = http.createHttp()
    const resp = await req.request(`http://${ip}${PING_PATH}`, {
      method: http.RequestMethod.GET,
      connectTimeout: PING_TIMEOUT,
      readTimeout: PING_TIMEOUT
    })
    req.destroy()
    if (resp.responseCode === 200) {
      return ip
    }
  } catch (_) {
    // 连不上，忽略
  }
  return null
}

// 读取上次缓存的 IP
async function getCachedIp(): Promise<string | null> {
  try {
    const ctx = getContext()
    const prefs = await preferences.getPreferences(ctx, PREF_NAME)
    const ip = prefs.getSync(KEY_LAST_IP, '') as string
    return ip || null
  } catch (_) {
    return null
  }
}

// 缓存成功的 IP
async function cacheIp(ip: string): Promise<void> {
  try {
    const ctx = getContext()
    const prefs = await preferences.getPreferences(ctx, PREF_NAME)
    prefs.putSync(KEY_LAST_IP, ip)
    prefs.flush()
  } catch (_) {
    // 缓存失败，不影响使用
  }
}

// 构建候选 IP 列表
async function buildCandidates(): Promise<string[]> {
  const list: string[] = ['10.0.2.2']  // 模拟器始终排第一

  // 上次成功的 IP 优先
  const cached = await getCachedIp()
  if (cached && !list.includes(cached)) {
    list.unshift(cached)
  }

  return list
}

// ---- 公开接口 ----

let discoveredIp: string | null = null

// 获取服务器 IP（自动探测 + 缓存）
export async function discoverServerIp(): Promise<string> {
  if (discoveredIp) return discoveredIp

  const candidates = await buildCandidates()
  const found = await probeCandidates(candidates)
  if (found) {
    discoveredIp = found
    await cacheIp(found)
    return found
  }

  // 全部失败，回退 LocalConfig 中配置的 IP
  return SERVER_IP
}

// 重置探测结果（IP 变更后调用）
export function resetServerIp(): void {
  discoveredIp = null
}
