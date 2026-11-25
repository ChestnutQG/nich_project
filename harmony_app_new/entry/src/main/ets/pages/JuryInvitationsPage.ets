import router from '@ohos.router';
import HttpUtil from '../common/HttpUtil';
import { JuryInvitationItem } from '../common/DataModels';
import promptAction from '@ohos.promptAction';

// 陪审邀请页：查看收到的陪审邀请，支持投票（买家/卖家）
@Entry
@Component
struct JuryInvitationsPage {
  @State invitations: JuryInvitationItem[] = [];  // 我的陪审邀请列表
  @State loading: boolean = true;                 // 加载中
  @State votingDisputeId: number = 0;             // 当前投票的纠纷ID
  @State showVoteDialog: boolean = false;         // 是否显示投票弹窗

  // 加载我的陪审邀请
  async aboutToAppear() {
    await this.loadData();
  }

  // 从后端加载陪审邀请列表
  async loadData() {
    this.loading = true;
    try {
      let res = await HttpUtil.get('/api/jury/invitations/mine');
      let arr = res.data as JuryInvitationItem[];
      this.invitations = [];
      for (let r of arr) {
        let inv = new JuryInvitationItem();
        inv.id = r.id;
        inv.disputeId = r.disputeId;
        inv.userId = r.userId;
        inv.status = r.status;
        inv.inviteTime = r.inviteTime;
        inv.voteTime = r.voteTime;
        this.invitations.push(inv);
      }
    } catch (e) {
    } finally {
      this.loading = false;
    }
  }

  // 提交投票：side为"buyer"或"seller"
  async vote(side: string) {
    try {
      let body: ESObject = {
        disputeId: this.votingDisputeId,
        voteSide: side
      };
      await HttpUtil.post('/api/jury/votes', body);
      promptAction.showToast({ message: '投票成功' });
      this.showVoteDialog = false;
      await this.loadData();
    } catch (e) {}
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Button('←').type(ButtonType.Normal).onClick(() => { router.back(); })
          Text('陪审邀请').fontSize(18).fontWeight(FontWeight.Bold).margin({ left: 12 })
          Blank()
        }.width('100%').padding(12)

        if (this.loading) {
          LoadingProgress().width(28).height(28).margin({ top: 80 })
        } else if (this.invitations.length === 0) {
          Text('暂无陪审邀请').fontSize(16).fontColor('#999').margin({ top: 80 })
        } else {
          List() {
            ForEach(this.invitations, (inv: JuryInvitationItem) => {
              ListItem() {
                Row() {
                  Column() {
                    Text('纠纷 #' + inv.disputeId).fontSize(15).fontWeight(FontWeight.Medium)
                    Text('邀请时间：' + inv.inviteTime).fontSize(12).fontColor('#999')
                    Text('状态：' + inv.status).fontSize(12)
                      .fontColor(inv.status === 'pending' ? '#FF9800' : '#4CAF50')
                  }.alignItems(HorizontalAlign.Start).layoutWeight(1)

                  if (inv.status === 'pending') {
                    Button('投票').fontSize(12)
                      .onClick(() => {
                        this.votingDisputeId = inv.disputeId;
                        this.showVoteDialog = true;
                      })
                  }
                }
                .width('100%').padding(12)
                .border({ width: { bottom: 0.5 }, color: '#eee' })
              }
            })
          }.layoutWeight(1)
        }
      }
      .width('100%').height('100%')

      if (this.showVoteDialog) {
        Column() {
          Text('选择你的投票立场').fontSize(18).fontWeight(FontWeight.Bold).margin({ bottom: 24 })
          Row() {
            Button('支持买家').width(120)
              .onClick(() => { this.vote('buyer'); })
            Button('支持卖家').width(120).margin({ left: 16 })
              .onClick(() => { this.vote('seller'); })
          }
          Button('取消').type(ButtonType.Normal).margin({ top: 16 })
            .onClick(() => { this.showVoteDialog = false; })
        }
        .padding(24).backgroundColor(Color.White).borderRadius(12)
        .shadow({ radius: 10 })
      }
    }
    .width('100%').height('100%')
  }
}
