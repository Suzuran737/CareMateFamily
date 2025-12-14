// 服务采购首页：服务项目列表页
import router from '@ohos.router';

// 服务项目数据结构定义
interface ServiceItem {
  id: number; // 唯一标识
  title: string; // 服务名称/类型，例如“检查”
  orgName: string; // 服务机构名称
  typeName: string; // 服务类型显示文本
  price: number; // 价格
  image: Resource; // 图片资源
}


// 示例数据（后续可改为从 JSON 读取）
const SERVICE_LIST: ServiceItem[] = [
  {
    id: 1,
    title: '检查',
    orgName: '福建星网锐捷',
    typeName: '检查',
    price: 36,
    image: $r('app.media.service_img1')
  },
  {
    id: 2,
    title: '检查',
    orgName: '中山大学展示中心',
    typeName: '检查',
    price: 36,
    image: $r('app.media.service_img1')
  },
  {
    id: 3,
    title: '检查',
    orgName: '示例康养中心',
    typeName: '检查',
    price: 36,
    image: $r('app.media.service_img1')
  }
];


// 服务项目卡片组件
@Component
struct ServiceItemCard {
  @Prop item: ServiceItem;

  build() {
    Column() {
      // 顶部大图
      Image(this.item.image)
        .width('100%')
        .objectFit(ImageFit.Cover)
        .padding({
          left: $r('app.float.service_image_space'),
          right: $r('app.float.service_image_space'),
          top: $r('app.float.service_image_space'),
          bottom: $r('app.float.service_image_space')
        })
        .clip(true)
        .borderRadius($r('app.float.service_card_radius'))

      // 下方文字区域
      Column() {
        // 服务名称
        Text(this.item.title)
          .fontSize($r('app.float.service_card_title_font_size'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.service_primary_text_color'))
          .margin({
            left: $r('app.float.service_text_left_right_margin'),
            right: $r('app.float.service_text_left_right_margin'),
            bottom: $r('app.float.service_text_bottom_margin')
          })
          .alignSelf(ItemAlign.Start)

        // 服务机构
        Row() {
          Text('服务机构')
            .fontSize($r('app.float.service_body_font_size'))
            .fontColor($r('app.color.service_secondary_text_color'))

          Blank().layoutWeight(1)

          Text(this.item.orgName)
            .fontSize($r('app.float.service_body_font_size'))
            .fontColor($r('app.color.service_primary_text_color'))
        }
        .margin({
          left: $r('app.float.service_text_left_right_margin'),
          right: $r('app.float.service_text_left_right_margin'),
          bottom: $r('app.float.service_text_bottom_margin')
        })

        // 服务类型
        Row() {
          Text('服务类型')
            .fontSize($r('app.float.service_body_font_size'))
            .fontColor($r('app.color.service_secondary_text_color'))

          Blank().layoutWeight(1)

          Text(this.item.typeName)
            .fontSize($r('app.float.service_body_font_size'))
            .fontColor($r('app.color.service_primary_text_color'))
        }
        .margin({
          left: $r('app.float.service_text_left_right_margin'),
          right: $r('app.float.service_text_left_right_margin'),
          bottom: $r('app.float.service_text_bottom_margin')
        })

        // 服务价格
        Row() {
          Text('服务价格')
            .fontSize($r('app.float.service_body_font_size'))
            .fontColor($r('app.color.service_secondary_text_color'))

          Blank().layoutWeight(1)

          Text('¥ ' + this.item.price.toString())
            .fontSize($r('app.float.service_emphasis_font_size'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.service_price_text_color')) // 示例中的橙色
        }
        .margin({
          left: $r('app.float.service_text_left_right_margin'),
          right: $r('app.float.service_text_left_right_margin'),
          bottom: $r('app.float.service_text_bottom_margin')
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
    }
    .backgroundColor($r('app.color.service_card_background_color'))
    .borderRadius($r('app.float.service_card_radius'))
    .borderWidth($r('app.float.service_card_border_width'))
    .borderColor($r('app.color.service_card_border_color'))
    .margin({
      left: $r('app.float.service_card_space'),
      right: $r('app.float.service_card_space'),
      top: $r('app.float.service_card_space')
    })
    .onClick(() => {
      // 点击进入详情页
      router.pushUrl({ url: 'pages/ServiceItemDetailPage' });
    })
  }
}


// 页面内部内容
@Builder
function ServicePurchaseContent() {
  Column() {
    // 顶部标题栏：返回 + 标题
    Row() {
      // 左：返回按钮
      Row() {
        Text('‹')
          .fontSize($r('app.float.common_nav_icon_font_size'))
          .fontColor($r('app.color.common_nav_text_color'))
      }
      .width($r('app.float.common_nav_side_width'))
      .height($r('app.float.common_nav_height'))
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .onClick(() => router.back())

      // 中：标题（占满剩余空间，居中）
      Text('服务项目列表')
        .fontSize($r('app.float.common_nav_title_font_size'))
        .fontWeight(FontWeight.Normal)
        .fontColor($r('app.color.common_nav_text_color'))
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      // 右：占位（与左边同宽，保证标题居中）
      Blank()
        .width($r('app.float.common_nav_side_width'))
    }
    .height($r('app.float.common_nav_height'))
    .width('100%')
    .alignItems(VerticalAlign.Center)


    // 列表区域
    Scroll() {
      Column() {
        ForEach(
          SERVICE_LIST,
          (item: ServiceItem) => {
            ServiceItemCard({ item: item });
          },
          (item: ServiceItem) => item.id.toString()
        )

        Blank().height(16)
      }
      .width('100%')
    }
    .width('100%')
    .layoutWeight(1)
  }
  .width('100%')
  .height('100%')
}

// 页面组件入口
@Entry
@Component
export default struct ServicePurchasePage {
  build() {
    Column() {
      // 把真正页面内容塞进来
      ServicePurchaseContent();
    }
    .width('100%')
    .height('100%')
    // 渐变效果
    .linearGradient({
      angle: 180, // 从上到下
      colors: [
        // 顶部绿色 → 渐变到白色
        [0xFF2EC7A8, 0.0],
        [0xFFA0EACD, 0.35],
        [0xFFF5FFFC, 0.5],
        [0xFFFFFFFF, 1.0]
      ]
    })
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);
  }
}
