import router from '@ohos.router';
// 引入全局渐变背景样式
import { AppPageScaffold } from '../components/AppPageScaffold';


// 首页四个功能入口的小组件
@Component
struct HomeFunctionItem {
  @Prop label: string;
  @Prop icon: Resource;

  build() {
    Column() {
      // 图标（圆形背景 + 图片）
      Image(this.icon)
        .width(48)
        .height(48)
        .borderRadius(8)
        .objectFit(ImageFit.Cover)
        .backgroundColor(0xFF2EC7A8)

      // 文字
      Text(this.label)
        .fontSize(14)
        .fontColor(0xFF333333)
        .margin({ top: 12 })
        .textAlign(TextAlign.Center)
    }
    .alignItems(HorizontalAlign.Center)
  }
}

// 健康宣教卡片组件
@Component
struct HealthEduCard {
  @Prop img: Resource;
  @Prop title: string;

  build() {
    Column() {
      // 上方图片
      Image(this.img)
        .width('100%')

      // 下方标题
      Text(this.title)
        .width('100%')
        .fontSize(16)
        .fontColor(0xFF333333)
        .margin({ left: 8, top: 12, bottom: 12 })
    }
    .backgroundColor(0xFFFFFFFF)
    .borderWidth(1)
    .borderColor(0x28000000)
    .borderRadius(16)
    .margin({ left: 4, right: 4, top: 8 })
  }
}

// 用 @Builder 定义首页内容
@Builder
function HomePageContent() {
  Scroll() {
    Column() {
      // 1. 顶部标题栏
      Row() {
        Text('首页')
          .fontSize(16)
          .fontWeight(FontWeight.Normal)
          .fontColor(0xFFFFFFFF)
      }
      .height(48)
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)

      // 2. Banner 区域
      Image($r('app.media.home_banner'))
        .width('100%')
        .margin({ top: 4 })
        .objectFit(ImageFit.Cover)

      // 3. 四个功能入口卡片
      Column() {
        Row() {
          // 问诊记录
          Column() {
            HomeFunctionItem({
              label: '问诊记录',
              icon: $r('app.media.home_icon1')
            })
          }
          .onClick(() => {
            router.pushUrl({ url: 'pages/VisitRecordsPage' });
          })

          // 服务订单
          Column() {
            HomeFunctionItem({
              label: '服务订单',
              icon: $r('app.media.home_icon2')
            })
          }
          .onClick(() => {
            router.pushUrl({ url: 'pages/ServiceOrdersPage' });
          })

          // 服务采购
          Column() {
            HomeFunctionItem({
              label: '服务采购',
              icon: $r('app.media.home_icon3')
            })
          }
          .onClick(() => {
            router.pushUrl({ url: 'pages/ServicePurchasePage' });
          })

          // 入住申请
          Column() {
            HomeFunctionItem({
              label: '入住申请',
              icon: $r('app.media.home_icon4')
            })
          }
          .onClick(() => {
            router.pushUrl({ url: 'pages/AdmissionApplyPage' });
          })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceAround)
        .alignItems(VerticalAlign.Center)
        .height(90)
      }
      .margin({ left: 4, right: 4, top: 8 })
      .backgroundColor(0xFFFFFFFF)
      .borderRadius(12)
      .padding({ left: 8, right: 8 })


      // 4. “健康宣教” 标题行
      Row() {
        Text('健康宣教')
          .fontSize(18)
          .margin({ left: 16 })
          .fontWeight(FontWeight.Normal)
          .fontColor(0xFF333333)
      }
      .width('100%')
      .margin({ top: 16, bottom: 4 })
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Center)

      // 5. 健康宣教卡片列表
      HealthEduCard({ img: $r('app.media.health_img1'), title: '老年痴呆' })
      HealthEduCard({ img: $r('app.media.health_img2'), title: '关注帕金森病' })
      HealthEduCard({ img: $r('app.media.health_img3'), title: '运动健康' })

      // 底部留一点空
      Blank()
        .height(16)
    }
    .width('100%')
  }
  .width('100%')
  .height('100%')
}


@Component
export default struct HomeTab {
  build() {
    // 套上统一背景
    AppPageScaffold({ content: HomePageContent })
  }
}
