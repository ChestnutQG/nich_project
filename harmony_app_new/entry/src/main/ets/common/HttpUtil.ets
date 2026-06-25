import http from '@ohos.net.http';
import preferences from '@ohos.data.preferences';
import promptAction from '@ohos.promptAction';

// 后端服务基础地址
const BASE_URL = 'http://10.73.180.63:8080';
// 本地持久化存储名称
const PREF_NAME = 'nonheritage_prefs';

// 统一API响应结构
export interface ApiResp {
  code: number;
  message: string;
  data: Object | null;
}

// HTTP工具类：封装网络请求与Token管理
class HttpUtil {
  // 当前登录令牌
  private token: string = '';

  // 初始化：从本地存储读取已保存的token
  async init(): Promise<void> {
    try {
      let prefs: preferences.Preferences = await preferences.getPreferences(getContext(), PREF_NAME);
      this.token = await prefs.get('token', '') as string;
    } catch (e) {
      this.token = '';
    }
  }

  // 保存token到内存和本地持久化存储
  async saveToken(token: string): Promise<void> {
    this.token = token;
    let prefs: preferences.Preferences = await preferences.getPreferences(getContext(), PREF_NAME);
    await prefs.put('token', token);
    await prefs.flush();
  }

  // 清除token（退出登录时调用）
  async clearToken(): Promise<void> {
    this.token = '';
    let prefs: preferences.Preferences = await preferences.getPreferences(getContext(), PREF_NAME);
    await prefs.put('token', '');
    await prefs.flush();
  }

  // 获取当前内存中的token
  async getToken(): Promise<string> {
    return this.token;
  }

  // 通用请求方法：自动附加token、处理错误提示
  async request(method: http.RequestMethod, path: string, body?: ESObject): Promise<ApiResp> {
    let req = http.createHttp();
    let url = BASE_URL + path;

    let reqHeader: Record<string, string> = {
      'Content-Type': 'application/json'
    };

    if (this.token) {
      reqHeader['Authorization'] = 'Bearer ' + this.token;
    }

    let opts: http.HttpRequestOptions = {
      method: method,
      header: reqHeader,
      connectTimeout: 10000,
      readTimeout: 10000
    };

    if (body) {
      opts.extraData = JSON.stringify(body) as string;
    }

    try {
      let resp = await req.request(url, opts);
      let data: ApiResp = JSON.parse(resp.result as string) as ApiResp;
      if (data.code !== 200) {
        promptAction.showToast({ message: data.message || '请求失败', duration: 2000 });
        throw new Error(data.message);
      }
      return data;
    } catch (e) {
      promptAction.showToast({ message: '网络请求失败', duration: 2000 });
      throw new Error(String(e));
    } finally {
      req.destroy();
    }
  }

  // GET请求
  async get(path: string): Promise<ApiResp> {
    return this.request(http.RequestMethod.GET, path);
  }

  // POST请求
  async post(path: string, body?: ESObject): Promise<ApiResp> {
    return this.request(http.RequestMethod.POST, path, body);
  }

  // PUT请求
  async put(path: string, body?: ESObject): Promise<ApiResp> {
    return this.request(http.RequestMethod.PUT, path, body);
  }
}

// 导出单例
export default new HttpUtil();
