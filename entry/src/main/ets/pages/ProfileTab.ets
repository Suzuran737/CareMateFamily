// ProfileTab.ets - 我的 Tab 页面
import router from '@ohos.router';

@Component
export default struct ProfileTab {
  // 使用 StorageLink 绑定全局变量
  // 如果 AppStorage 中没值，则使用默认值
  @StorageLink('userName') nickname: string = '未登录';
  @StorageLink('userPhone') phoneNumber: string = '点击头像登录';
  @StorageLink('isLogin') isLogin: boolean = false;

  navigateTo(pageName: string): void {
    router.pushUrl({ url: `pages/${pageName}` });
  }

  build() {
    Scroll() {
      Column() {
        // 1. 顶部标题栏
        Text('我的')
          .fontSize(18)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Medium)
          .margin({ top: 16, bottom: 30 })

        // 2. 个人信息区
        Column() {
          Image($r('app.media.ic_user'))
            .width(90)
            .height(90)
            .borderRadius(45)
            .border({ width: 2, color: Color.White })
            .backgroundColor(0xEEEEEE)
            .onClick(() => {
              if (!this.isLogin) {
                // 如果没登录，点击头像跳转到登录页
                router.pushUrl({ url: 'pages/LoginPage' });
              } else {
                // 如果已登录，可以点击进入“个人资料编辑”页面（后续扩展）
                console.info('已登录状态，点击头像');
              }
            })

          Text(this.nickname)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
            .margin({ top: 12 })

          Text(this.phoneNumber)
            .fontSize(16)
            .fontColor(Color.White)
            .opacity(0.9)
            .margin({ top: 8, bottom: 30 })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)

        // 3. 功能列表区 - 已根据你的截图修正文件名
        Column({ space: 12 }) {
          ProfileItem({
            icon: $r('app.media.ic_consultation_record'),
            title: '问诊记录',
            // 对应文件名：VisitRecordsPage.ets
            onItemClick: () => this.navigateTo('VisitRecordsPage')
          })

          ProfileItem({
            icon: $r('app.media.ic_service_order'),
            title: '服务订单',
            // 对应文件名：ServiceOrdersPage.ets
            onItemClick: () => this.navigateTo('ServiceOrdersPage')
          })

          ProfileItem({
            icon: $r('app.media.ic_admission_apply'),
            title: '入住申请',
            // 对应文件名：AdmissionApplyPage.ets
            onItemClick: () => this.navigateTo('AdmissionApplyPage')
          })

          ProfileItem({
            icon: $r('app.media.ic_logout'),
            title: this.isLogin ? '退出登录' : '前往登录',
            onItemClick: () => {
              if (this.isLogin) {
                // 退出登录：清除状态
                AppStorage.setOrCreate('isLogin', false);
                AppStorage.setOrCreate('userName', '未登录');
                AppStorage.setOrCreate('userPhone', '点击头像登录');
              }
              router.replaceUrl({ url: 'pages/LoginPage' });
            }
          })
        }
        .padding({ left: 16, right: 16 })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
  }
}

// --------------------------- 子组件---------------------------
@Component
struct ProfileItem {
  @Prop icon: Resource;
  @Prop title: string;
  onItemClick: () => void = () => {};

  build() {
    Row() {
      Image(this.icon)
        .width(22)
        .height(22)
        .margin({ right: 12 })
        .objectFit(ImageFit.Contain)

      Text(this.title)
        .fontSize(16)
        .fontColor(0x333333)
        .layoutWeight(1)

      Text('>')
        .fontSize(20)
        .fontColor(0xCCCCCC)
        .fontWeight(FontWeight.Lighter)
        .margin({ right: 4 })
    }
    .width('100%')
    .height(64)
    .padding({ left: 16, right: 16 })
    .backgroundColor(Color.White)
    .borderRadius(12)
    .shadow({ radius: 2, color: 0x10000000, offsetX: 0, offsetY: 2 })
    .onClick(() => {
      if (this.onItemClick) this.onItemClick();
    })
  }
}