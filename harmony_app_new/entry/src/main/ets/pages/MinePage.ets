import router from '@ohos.router';
import HttpUtil from '../common/HttpUtil';
import { UserInfo } from '../common/DataModels';

// 我的页：用户信息展示 + 功能入口列表（发布/订单/纠纷/陪审）
@Component
export struct MineComponent {
  @State user: UserInfo = new UserInfo();  // 当前用户信息
  @State loaded: boolean = false;          // 数据是否加载完成

  // 加载当前用户信息
  async aboutToAppear() {
    try {
      let res = await HttpUtil.get('/api/users/me');
      let data = res.data as UserInfo;
      this.user.id = data.id;
      this.user.username = data.username;
      this.user.avatarUrl = data.avatarUrl || '';
      this.user.role = data.role;
      this.user.creditScore = data.creditScore;
      this.loaded = true;
    } catch (e) {
    }
  }

  // 退出登录：清除token并跳回登录页
  async logout() {
    await HttpUtil.clearToken();
    router.replaceUrl({ url: 'pages/LoginPage' });
  }

  build() {
    Column() {
      Row() {
        if (this.loaded) {
          Column() {
            Text(this.user.username).fontSize(20).fontWeight(FontWeight.Bold)
            Text('信用分：' + this.user.creditScore).fontSize(12).fontColor('#999')
          }.alignItems(HorizontalAlign.Start)
        } else {
          LoadingProgress().width(24).height(24)
        }
        Blank()
        Button('退出').type(ButtonType.Normal).fontSize(12).onClick(() => { this.logout(); })
      }
      .width('100%').padding(16)

      Scroll() {
        Column() {
          this.MenuItem('我发布的', () => {
            router.pushUrl({ url: 'pages/MyPostsPage' });
          })
          this.MenuItem('我买到的', () => {
            router.pushUrl({ url: 'pages/OrderListPage', params: { type: 'bought' } });
          })
          this.MenuItem('我卖出的', () => {
            router.pushUrl({ url: 'pages/OrderListPage', params: { type: 'sold' } });
          })
          this.MenuItem('陪审邀请', () => {
            router.pushUrl({ url: 'pages/JuryInvitationsPage' });
          })
          this.MenuItem('我的纠纷', () => {
            router.pushUrl({ url: 'pages/DisputeDetailPage' });
          })
        }
      }
      .layoutWeight(1)
    }
    .width('100%').height('100%')
  }

  // 菜单项构建器：标题 + 箭头，点击触发回调
  @Builder MenuItem(title: string, action: () => void) {
    Row() {
      Text(title).fontSize(16)
      Blank()
      Text('>').fontColor('#ccc')
    }
    .width('100%').padding(16)
    .border({ width: { bottom: 0.5 }, color: '#eee' })
    .onClick(action)
  }
}
