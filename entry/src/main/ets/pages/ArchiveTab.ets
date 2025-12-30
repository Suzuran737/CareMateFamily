// 用户档案 Tab 页面
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import type common from '@ohos.app.ability.common';
import { CareUserStoreManager, CareUserRecord } from '../utils/CareUserStoreManager';

@Component
struct UserCard {
  // 使用@Prop装饰器实现卡片复用
  @Prop user: CareUserRecord;
  @State private isExpanded: boolean = false;

  build() {
    Column({ space: 4 }) {
      // 卡片主体：左右布局
      Row({ space: 8 }) {
        // 左侧：头像和姓名
        Column({ space: 8 }) {
          // 头像
          Image(this.user.gender === '男' ? $r('app.media.ic_man') : $r('app.media.ic_woman'))
            .width(80)
            .height(80)
            .borderRadius(40)
            .objectFit(ImageFit.Cover)
            .backgroundColor(Color.Gray)

          // 姓名
          Text(this.user.name)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .width('20%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)

        // 右侧：详细信息
        Column({ space: 6 }) {
          // 性别角标（右上角）
          Row() {
            Text(this.user.gender === '男' ? '♂' : '♀')
              .fontSize(14)
              .fontColor(this.user.gender === '男' ? Color.Blue : Color.Red)
              .margin({ right: 2 })

            Text(this.user.gender)
              .fontSize(14)
              .fontColor(Color.Black)
          }
          .padding({
            left: 6,
            right: 6,
            top: 2,
            bottom: 2
          })
          .borderRadius(2)
          .backgroundColor(this.user.gender === '男' ? '#E6F3FF' : '#FFE6E6') // 浅蓝/浅红背景
          .alignSelf(ItemAlign.End) // 靠右对齐
          .margin({ bottom: 8 })

          // 信息行：关系
          this.buildInfoRow('关系', this.user.relationship)

          // 信息行：生日
          this.buildInfoRow('生日', this.user.birthday)

          // 信息行：身份证
          this.buildInfoRow('身份证', this.user.idCard)
        }
        .width('80%')
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

    //.onClick(() => this.onEdit(this.user.id))
  }

  // 构建信息行的私有方法
  @Builder
  private buildInfoRow(label: string, value: string) {
    Row() {
      // 标签（灰色左对齐）
      Text(label)
        .fontSize(14)
        .fontColor('#666666') // 灰色
        .textAlign(TextAlign.Start)

      Blank().layoutWeight(1)

      // 信息（黑色右对齐）
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

// 页面入口
@Component
export default struct ArchiveTab {
  private context: common.UIAbilityContext = getContext() as common.UIAbilityContext;
  @StorageLink('careUserRefresh') @Watch('onRefreshKeyChanged') refreshKey: number = 0;
  // 登录状态或用户名变化时刷新列表
  @StorageLink('isLogin') @Watch('onLoginStateChanged') private isLogin: boolean = false;
  @StorageLink('userName') @Watch('onLoginUserChanged') private currentUserName: string = '未登录';
  @State users: CareUserRecord[] = []; // 用户数据数组

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
      Column() {
        // 1. 顶部标题栏
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

        // 2. 用户信息区
        Scroll() {
          Column() {
            // 用户列表标题
            Row() {
              Column() {
                Text('用户列表')
                  .fontSize(28)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(0xFF333333)

                // 下划线（从文字开头开始）
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
            .margin({
              top: 32,
              bottom: $r('app.float.home_health_section_title_bottom_margin')
            })
            .justifyContent(FlexAlign.Start)
            .alignItems(VerticalAlign.Center)

            Column({ space: 4 }) {
              // 使用 ForEach 循环渲染可复用卡片
              ForEach(this.users, (user: CareUserRecord) => {
                UserCard({ user: user })
              }, (user: CareUserRecord) => user.id)
            }
            .padding(4)
            .width('100%')

            Text('没有更多')
              .fontSize(12)
              .fontColor(Color.Grey)
              .opacity(0.9)
              .margin({ top: 15, bottom: 30 })
          }
          .width('100%')
        }
        .width('100%')
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)

      Blank().layoutWeight(1)

      // 3. 底部按钮
      Row() {
        Button('添加康养用户')
          .layoutWeight(1)
          .height(44)
          .backgroundColor('#07C6A5')
          .fontColor(Color.White)
          .onClick(() => this.onAdd())

        Button('清空档案')
          .layoutWeight(1)
          .height(44)
          .backgroundColor('#FFFFFF')
          .fontColor('#07C6A5')
          .borderWidth(1)
          .borderColor('#07C6A5')
          .borderRadius(6)
          .margin({ left: 12 })
          .onClick(() => this.onClearUsers())
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
      promptAction.showDialog({
        message: '请先登录后再添加档案',
        buttons: [
          {
            text: '确认',
            color: '#07C6A5'
          }
        ]
      });
      return;
    }
    router.pushUrl({ url: 'pages/AddCareUserPage' });
  }

  private onClearUsers(): void {
    const isLogin: boolean = AppStorage.get<boolean>('isLogin') === true;
    const ownerName: string = AppStorage.get<string>('userName') || '';
    if (!isLogin || !ownerName || ownerName === '未登录') {
      promptAction.showDialog({
        message: '请先登录后再清空档案',
        buttons: [
          {
            text: '确认',
            color: '#07C6A5'
          }
        ]
      });
      return;
    }
    CareUserStoreManager.getInstance().initKvStore(this.context)
      // .then(() => CareUserStoreManager.getInstance().clearUsers()) // 旧逻辑：清空所有用户
      .then(() => CareUserStoreManager.getInstance().clearUsers(ownerName))
      .then(() => {
        this.users = [];
        promptAction.showDialog({
          message: '已清空康养用户档案',
          buttons: [
            {
              text: '确认',
              color: '#07C6A5'
            }
          ]
        });
      })
      .catch((err: Error) => {
        console.error('清空康养用户失败:', err);
        promptAction.showDialog({
          message: '清空失败，请重试',
          buttons: [
            {
              text: '确认',
              color: '#07C6A5'
            }
          ]
        });
      });
  }

  // 从 KvStore 读取康养用户数据
  private loadUsers(): void {
    const isLogin: boolean = AppStorage.get<boolean>('isLogin') === true;
    const ownerName: string = AppStorage.get<string>('userName') || '';
    if (!isLogin || !ownerName || ownerName === '未登录') {
      this.users = [];
      return;
    }
    CareUserStoreManager.getInstance().initKvStore(this.context)
      // .then(() => CareUserStoreManager.getInstance().getUsers()) // 旧逻辑：读取所有用户
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
