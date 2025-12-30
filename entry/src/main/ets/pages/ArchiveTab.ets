// 用户档案 Tab 页面
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import type common from '@ohos.app.ability.common';
import { CareUserStoreManager, CareUserRecord } from '../utils/CareUserStoreManager';

@Component
struct UserCard {
  @Prop user: CareUserRecord;

  build() {
    Column({ space: 4 }) {
      Row({ space: 8 }) {
        // 左侧：头像和姓名
        Column({ space: 8 }) {
          Image(this.user.gender === '男' ? $r('app.media.ic_man') : $r('app.media.ic_woman'))
            .width(80)
            .height(80)
            .borderRadius(40)
            .objectFit(ImageFit.Cover)
            .backgroundColor(Color.Gray)

          Text(this.user.name)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .width('25%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)

        // 右侧：信息
        Column({ space: 6 }) {
          Row() {
            Text(this.user.gender === '男' ? '♂' : '♀')
              .fontSize(14)
              .fontColor(this.user.gender === '男' ? Color.Blue : Color.Red)
              .margin({ right: 2 })

            Text(this.user.gender)
              .fontSize(14)
              .fontColor(Color.Black)
          }
          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
          .borderRadius(2)
          .backgroundColor(this.user.gender === '男' ? '#E6F3FF' : '#FFE6E6')
          .alignSelf(ItemAlign.End)
          .margin({ bottom: 8 })

          this.buildInfoRow('关系', this.user.relationship)
          this.buildInfoRow('生日', this.user.birthday)
          this.buildInfoRow('身份证', this.user.idCard)
        }
        .width('75%')
      }
      .padding(16)
    }
    .backgroundColor('#EEEEEE')
    .borderWidth($r('app.float.home_health_card_border_width'))
    .borderColor(0x28000000)
    .borderRadius(8)
    .clip(true)
    .margin({
      left: $r('app.float.home_health_card_horizontal_margin'),
      right: $r('app.float.home_health_card_horizontal_margin'),
      top: $r('app.float.home_health_card_top_margin')
    })
  }

  @Builder
  private buildInfoRow(label: string, value: string): void {
    Row() {
      Text(label)
        .fontSize(14)
        .fontColor('#666666')
        .textAlign(TextAlign.Start)

      Blank().layoutWeight(1)

      Text(value)
        .fontSize(14)
        .fontColor(Color.Black)
        .textAlign(TextAlign.End)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.None })
    }
    .width('90%')
    .margin({ left: 18, bottom: 8, right: 4 })
  }
}

@Component
export default struct ArchiveTab {
  private context: common.UIAbilityContext = getContext() as common.UIAbilityContext;

  @StorageLink('careUserRefresh') @Watch('onRefreshKeyChanged') refreshKey: number = 0;
  @StorageLink('isLogin') @Watch('onLoginStateChanged') private isLogin: boolean = false;
  @StorageLink('userName') @Watch('onLoginUserChanged') private currentUserName: string = '未登录';

  @State users: CareUserRecord[] = [];

  aboutToAppear(): void {
    this.loadUsers();
  }

  onPageShow(): void {
    this.loadUsers();
  }

  private onRefreshKeyChanged(): void {
    this.loadUsers();
  }

  private onLoginStateChanged(): void {
    this.loadUsers();
  }

  private onLoginUserChanged(): void {
    this.loadUsers();
  }

  build() {
    Column() {
      // 1. 顶部标题栏（固定高度）
      Row() {
        Text('康养用户列表')
          .fontSize($r('app.float.home_header_title_font_size'))
          .fontWeight(FontWeight.Normal)
          .fontColor(0xFFFFFFFF)
      }
      .height($r('app.float.home_header_height'))
      .margin({ bottom: 5 })
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)

      // 2. 滚动区
      Scroll() {
        Column() {
          // 用户列表标题
          Row() {
            Column() {
              Text('用户列表')
                .fontSize(28)
                .fontWeight(FontWeight.Bold)
                .fontColor(0xFF333333)

              Row()
                .width(56)
                .height(3)
                .backgroundColor(0xFF333333)
                .borderRadius(2)
                .margin({ top: 6 })
            }
            .alignItems(HorizontalAlign.Start)
            .margin({ left: $r('app.float.home_health_section_title_left_margin') })
          }
          .width('100%')
          .margin({ top: 20, bottom: 12 })

          // 列表
          Column({ space: 4 }) {
            ForEach(this.users, (user: CareUserRecord) => {
              UserCard({ user: user })
            }, (user: CareUserRecord) => user.id)
          }
          .padding(4)
          .width('100%')

          Blank().height(16).layoutWeight(1)
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)

      // 3. 底部按钮（固定在底部）
      Row() {
        Button('添加康养用户')
          .layoutWeight(1)
          .height(44)
          .backgroundColor('#07C6A5')
          .fontColor(Color.White)
          .onClick(() => this.onAdd())

        // Button('清空档案')
        //   .layoutWeight(1)
        //   .height(44)
        //   .backgroundColor('#FFFFFF')
        //   .fontColor('#07C6A5')
        //   .borderWidth(1)
        //   .borderColor('#07C6A5')
        //   .borderRadius(6)
        //   .margin({ left: 12 })
        //   .onClick(() => this.onClearUsers())
      }
      .width('95%')
      .margin({ bottom: 12 })
    }
    .width('100%')
    .height('100%')
  }

  private onAdd(): void {
    const isLogin: boolean = AppStorage.get<boolean>('isLogin') === true;
    if (!isLogin) {
      // 未登录时禁止进入新增页
      promptAction.showDialog({
        message: '请先登录后再添加档案',
        buttons: [{ text: '确认', color: '#07C6A5' }]
      });
      return;
    }
    router.pushUrl({ url: 'pages/AddCareUserPage' });
  }

  private onClearUsers(): void {
    const isLogin: boolean = AppStorage.get<boolean>('isLogin') === true;
    const ownerName: string = AppStorage.get<string>('userName') || '';
    if (!isLogin || !ownerName || ownerName === '未登录') {
      // 未登录不允许清空，避免误操作
      promptAction.showDialog({
        message: '请先登录后再清空档案',
        buttons: [{ text: '确认', color: '#07C6A5' }]
      });
      return;
    }

    CareUserStoreManager.getInstance()
      .initKvStore(this.context)
      .then(() => CareUserStoreManager.getInstance().clearUsers(ownerName))
      .then(() => {
        this.users = [];
        promptAction.showDialog({
          message: '已清空康养用户档案',
          buttons: [{ text: '确认', color: '#07C6A5' }]
        });
      })
      .catch((err: Error) => {
        console.error('清空康养用户失败:', err);
        promptAction.showDialog({
          message: '清空失败，请重试',
          buttons: [{ text: '确认', color: '#07C6A5' }]
        });
      });
  }

  private loadUsers(): void {
    // 仅加载当前登录用户的档案数据
    const isLogin: boolean = AppStorage.get<boolean>('isLogin') === true;
    const ownerName: string = AppStorage.get<string>('userName') || '';
    if (!isLogin || !ownerName || ownerName === '未登录') {
      this.users = [];
      return;
    }

    CareUserStoreManager.getInstance()
      .initKvStore(this.context)
      .then(() => CareUserStoreManager.getInstance().getUsers(ownerName))
      .then((list: CareUserRecord[]) => {
        this.users = list;
      })
      .catch((err: Error) => {
        console.error('读取康养用户失败:', err);
        this.users = [];
      });
  }
}
