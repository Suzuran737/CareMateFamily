import router from '@ohos.router';
import type common from '@ohos.app.ability.common';
import { ReservationStoreManager, type ReservationRecord } from '../utils/ReservationStoreManager';

// 静态“已服务”示例
const STATIC_SERVICE_ORDER: ReservationRecord = {
  id: 'static_demo_1',
  submitTime: 0,
  serviceType: '检查',
  status: '已服务',
  orderNo: 'kh_171013049489',
  price: 36,
  serviceUser: '王国栋',
  nurseName: '陈婷',
  serviceTime: '2025-01-01 09:00',
  contactName: '陈婷',
  contactPhone: '18800000000',
  address: '北京',
  remark: ''
};

interface ServiceOrderRouteParams {
  id: string;
  order: ReservationRecord;
}

// 单个服务订单卡片
@Component
struct ServiceOrderCard {
  @Prop order: ReservationRecord;

  build() {
    Column() {
      // 第一行：服务类型 + 状态
      Row() {
        Text(this.order.serviceType)
          .fontSize($r('app.float.service_card_title_font_size'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.service_primary_text_color'))

        Blank().layoutWeight(1)

        // “已服务” “未服务”
        Text(this.order.status)
          .fontSize($r('app.float.service_body_font_size'))
          .fontColor(this.order.status === '已服务' ? $r('app.color.service_secondary_text_color') : 0xFF2F80ED)
          .borderWidth(1)
          .borderColor(this.order.status === '已服务' ? $r('app.color.service_secondary_text_color') : 0xFF2F80ED)
          .borderRadius(2)
          .padding({
            left: 2,
            right: 2,
            top: 2,
            bottom: 2
          })
      }
      .margin({
        left: $r('app.float.service_text_left_right_margin'),
        right: $r('app.float.service_text_left_right_margin'),
        top: $r('app.float.service_text_bottom_margin'),
        bottom: $r('app.float.service_item_small_bottom_margin')
      })

      this.InfoRow('被看护人', this.order.serviceUser)
      this.InfoRow('服务单号', this.order.orderNo)
      this.InfoRow('看护名称', this.order.nurseName)
      this.InfoRow('预约时间', this.order.serviceTime)

      // 服务价格
      Row() {
        Text('服务价格')
          .fontSize($r('app.float.service_body_font_size'))
          .fontColor($r('app.color.service_secondary_text_color'))

        Blank().layoutWeight(1)

        Text('¥ ' + this.order.price.toString())
          .fontSize($r('app.float.service_emphasis_font_size'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.service_price_text_color'))
      }
      .margin({
        left: $r('app.float.service_text_left_right_margin'),
        right: $r('app.float.service_text_left_right_margin'),
        top: $r('app.float.service_blank_width'),
        bottom: $r('app.float.service_text_bottom_margin')
      })
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
      const params: ServiceOrderRouteParams = {
        id: this.order.id,
        order: this.order
      };
      router.pushUrl({ url: 'pages/ServiceOrderDetailPage', params: params })
    })
  }

  // 左右对齐信息行
  @Builder
  InfoRow(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize($r('app.float.service_body_font_size'))
        .fontColor($r('app.color.service_secondary_text_color'))

      Blank().layoutWeight(1)

      Text(value)
        .fontSize($r('app.float.service_body_font_size'))
        .fontColor($r('app.color.service_primary_text_color'))
        .textAlign(TextAlign.End)
    }
    .margin({
      left: $r('app.float.service_text_left_right_margin'),
      right: $r('app.float.service_text_left_right_margin'),
      top: $r('app.float.service_item_small_bottom_margin'),
      bottom: $r('app.float.service_item_small_bottom_margin')
    })
  }
}

// 页面入口
@Entry
@Component
export default struct ServiceOrdersPage {
  private context: common.UIAbilityContext = getContext() as common.UIAbilityContext;
  @State orderList: ReservationRecord[] = [];

  aboutToAppear(): void {
    this.loadOrders();
  }

  // 从 KvStore 读取订单
  private loadOrders(): void {
    ReservationStoreManager.getInstance()
      .initKvStore(this.context)
      .then(() => ReservationStoreManager.getInstance().getReservations())
      .then((list: ReservationRecord[]) => {
        this.orderList = [STATIC_SERVICE_ORDER].concat(list);
      })
      .catch((err: Error) => {
        console.error('读取订单失败:', err);
        this.orderList = [STATIC_SERVICE_ORDER];
      });
  }

  // 页面内容
  @Builder
  private buildOrdersContent(): void {
    Column() {
      // 顶部标题栏
      Row() {
        Row() {
          Text('<')
            .fontSize($r('app.float.common_nav_icon_font_size'))
            .fontColor($r('app.color.common_nav_text_color'))
        }
        .width($r('app.float.common_nav_side_width'))
        .height($r('app.float.common_nav_height'))
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
        .onClick(() => router.back())

        Text('服务订单')
          .fontSize($r('app.float.common_nav_title_font_size'))
          .fontColor($r('app.color.common_nav_text_color'))
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Blank().width($r('app.float.common_nav_side_width'))
      }
      .height($r('app.float.common_nav_height'))
      .width('100%')

      // 列表区域
      Scroll() {
        Column() {
          ForEach(
            this.orderList,
            (order: ReservationRecord) => {
              ServiceOrderCard({ order: order })
            },
            (order: ReservationRecord) => order.id.toString()
          )

          Blank().height(16)
        }
        .width('100%')
      }
    }
    .width('100%')
    .height('100%')
  }

  // 构造页面
  build() {
    Column() {
      this.buildOrdersContent()
    }
    .width('100%')
    .height('100%')
    .linearGradient({
      angle: 180,
      colors: [
        [0xFF2EC7A8, 0.0],
        [0xFFA0EACD, 0.35],
        [0xFFF5FFFC, 0.5],
        [0xFFFFFFFF, 1.0]
      ]
    })
    .expandSafeArea(
      [SafeAreaType.SYSTEM],
      [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]
    )
  }
}
