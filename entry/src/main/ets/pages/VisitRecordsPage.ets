// VisitRecordsPage.ets - 问诊记录列表页
import router from '@ohos.router';
import { OrderInfo, PrescriptionDetail } from '../model/AdmissionRecord';
import { getVisitRecordList } from '../model/VisitRecordStore';

// 初始化刷新标记，确保 StorageLink 绑定键存在
AppStorage.setOrCreate('visitRecordRefresh', 0);


/**
 * 单条问诊记录卡片
 */
@Component
struct OrderCard {
  @Prop order: OrderInfo;

  build() {
    Column() {
      // 第一行：患者 + 支付状态
      Row() {
        Text(this.order.patient)
          .fontSize($r('app.float.service_card_title_font_size'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.service_primary_text_color'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Blank().layoutWeight(1)

        Text(this.order.paid ? '已支付' : '未支付')
          .fontSize($r('app.float.service_body_font_size'))
          .fontColor(this.order.paid ? $r('app.color.service_secondary_text_color') : 0xFFFF3B30)
          .borderWidth(1)
          .borderColor(this.order.paid ? $r('app.color.service_secondary_text_color') : 0xFFFF3B30)
          .borderRadius(2)
          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
      }
      .margin({
        left: $r('app.float.service_text_left_right_margin'),
        right: $r('app.float.service_text_left_right_margin'),
        top: $r('app.float.service_text_bottom_margin'),
        bottom: $r('app.float.service_item_small_bottom_margin')
      })

      // 信息行
      this.InfoRow('医护名称', this.order.doctor)
      this.InfoRow('问诊时间', this.order.time)

      // 金额：强调样式
      Row() {
        Text('金额')
          .fontSize($r('app.float.service_body_font_size'))
          .fontColor($r('app.color.service_secondary_text_color'))

        Blank().layoutWeight(1)

        Text(this.order.amount)
          .fontSize($r('app.float.service_emphasis_font_size'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.service_price_text_color'))
      }
      .margin({
        left: $r('app.float.service_text_left_right_margin'),
        right: $r('app.float.service_text_left_right_margin'),
        top: $r('app.float.service_item_small_bottom_margin'),
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
  }

  @Builder
  private InfoRow(label: string, value: string): void {
    Row() {
      Text(label)
        .fontSize($r('app.float.service_body_font_size'))
        .fontColor($r('app.color.service_secondary_text_color'))

      Blank().layoutWeight(1)

      Text(value)
        .fontSize($r('app.float.service_body_font_size'))
        .fontColor($r('app.color.service_primary_text_color'))
        .textAlign(TextAlign.End)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .margin({
      left: $r('app.float.service_text_left_right_margin'),
      right: $r('app.float.service_text_left_right_margin'),
      top: $r('app.float.service_item_small_bottom_margin'),
      bottom: $r('app.float.service_item_small_bottom_margin')
    })
  }
}

@Entry
@Component
export default struct VisitRecordsPage {
  @State private orders: OrderInfo[] = [];
  // 监听支付完成后的刷新信号
  @StorageLink('visitRecordRefresh') @Watch('onRefreshKeyChanged') private refreshKey: number = 0;
  // 强制刷新列表的版本号（用于 ForEach key）
  @State private listVersion: number = 0;

  aboutToAppear(): void {
    this.loadOrders();
  }

  onPageShow(): void {
    this.loadOrders();
  }

  // 页面内容（结构对齐 ServiceOrdersPage）
  @Builder
  private buildVisitRecordsContent(): void {
    Column() {
      // 顶部导航栏（统一样式）
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

        Text('问诊记录')
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
            this.orders,
            (order: OrderInfo) => {
              // 外层包一层 Column 以便加 onClick
              Column() {
                OrderCard({ order: order })
              }
              .onClick(() => {
                router.pushUrl({
                  url: 'pages/VisitRecordDetailPage',
                  params: { orderId: order.id }
                });
              })
            },
            // 通过版本号变化触发列表重新渲染
            (order: OrderInfo) => `${order.id}_${this.listVersion}`
          )

          Blank().height(16)
        }
        .width('100%')
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
  }

  build() {
    Column() {
      this.buildVisitRecordsContent()
    }
    .width('100%')
    .height('100%')
    // 渐变背景（与服务订单一致）
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

  private loadOrders(): void {
    const list = getVisitRecordList();
    const result: OrderInfo[] = [];
    for (let i: number = 0; i < list.length; i++) {
      // 拷贝对象，避免引用复用导致 UI 不刷新
      result.push(this.cloneOrder(list[i]));
    }
    this.orders = result;
    // 更新版本号，触发列表重建
    this.listVersion = this.listVersion + 1;
  }

  private onRefreshKeyChanged(): void {
    // 支付完成时通过 AppStorage 通知刷新
    this.loadOrders();
  }

  // 深拷贝处方信息
  private cloneOrder(source: OrderInfo): OrderInfo {
    const prescription = new PrescriptionDetail();
    prescription.indexTitle = source.prescription.indexTitle;
    prescription.type = source.prescription.type;
    prescription.spec = source.prescription.spec;
    prescription.dosage = source.prescription.dosage;
    prescription.frequency = source.prescription.frequency;
    prescription.quantity = source.prescription.quantity;
    prescription.unitPrice = source.prescription.unitPrice;
    prescription.totalPrice = source.prescription.totalPrice;
    prescription.usage = source.prescription.usage;

    const order = new OrderInfo();
    order.id = source.id;
    order.patient = source.patient;
    order.paid = source.paid;
    order.doctor = source.doctor;
    order.time = source.time;
    order.amount = source.amount;
    order.symptom = source.symptom;
    order.medical_history = source.medical_history;
    order.allergy_history = source.allergy_history;
    order.diagnosis = source.diagnosis;
    order.prescription = prescription;
    return order;
  }
}
