// VisitRecordDetailPage.ets
import router from '@ohos.router';
import { OrderInfo, PrescriptionDetail } from '../model/AdmissionRecord';
import { getDefaultVisitRecord, getVisitRecordById } from '../model/VisitRecordStore';

/**
 * 静态订单数据：用于直接渲染
 */
interface VisitRecordRouteParams {
  order?: OrderInfo;
  // 优先使用订单 ID 从内存仓库读取
  orderId?: string;
}

// 深拷贝处方信息，避免引用共用
function cloneOrder(source: OrderInfo): OrderInfo {
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

/**
 * 静态订单数据：无路由参数时的默认展示
 */
const STATIC_ORDER: OrderInfo = cloneOrder(getDefaultVisitRecord());

@Entry
@Component
export default struct VisitRecordDetailPage {
  @State private order: OrderInfo = STATIC_ORDER;
  // 记录当前订单 ID，便于返回后同步状态
  private orderId: string = '';

  aboutToAppear(): void {
    const params = router.getParams() as VisitRecordRouteParams;
    if (params && params.orderId) {
      // 通过 ID 获取订单，确保状态与列表一致
      this.orderId = params.orderId;
      const record = getVisitRecordById(params.orderId);
      if (record) {
        this.order = cloneOrder(record);
      }
    } else if (params && params.order) {
      // 兼容直接传订单对象的场景
      this.order = cloneOrder(params.order as OrderInfo);
      this.orderId = this.order.id;
    }
  }

  onPageShow(): void {
    // 页面返回时同步订单支付状态
    this.syncOrderFromStore();
  }

  build() {
    Column() {
      // 顶部导航栏（与服务订单风格一致）
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

        Text('问诊订单信息')
          .fontSize($r('app.float.common_nav_title_font_size'))
          .fontWeight(FontWeight.Normal)
          .fontColor($r('app.color.common_nav_text_color'))
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Blank().width($r('app.float.common_nav_side_width'))
      }
      .height($r('app.float.common_nav_height'))
      .width('100%')
      .alignItems(VerticalAlign.Center)

      // 正文
      Scroll() {
        Column() {
          // ================== ① 问诊订单信息 ==================
          Column() {
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
                .padding({ left: 8, right: 8, top: 3, bottom: 3 })
            }
            .margin({
              left: $r('app.float.service_text_left_right_margin'),
              right: $r('app.float.service_text_left_right_margin'),
              top: 16,
              bottom: 14
            })

            // 信息行（加大行距）
            this.InfoRowWide('医护名称', this.safeText(this.order.doctor))
            this.InfoRowWide('问诊时间', this.safeText(this.order.time))

            // 金额（强调）
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
              top: 10,
              bottom: 16
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

          // ================== ② 处方信息 ==================
          Column() {
            Text('处方信息')
              .fontSize($r('app.float.service_card_title_font_size'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.service_primary_text_color'))
              .margin({
                left: $r('app.float.service_text_left_right_margin'),
                right: $r('app.float.service_text_left_right_margin'),
                top: 16,
                bottom: 14
              })
              .alignSelf(ItemAlign.Start)

            this.InfoRowWide('主诉', this.safeText(this.order.symptom))
            this.InfoRowWide('病史', this.safeText(this.order.medical_history))
            this.InfoRowWide('过敏史', this.safeText(this.order.allergy_history))
            this.InfoRowWide('诊断', this.safeText(this.order.diagnosis))

            Blank().height(10)
          }
          .backgroundColor($r('app.color.service_card_background_color'))
          .borderRadius($r('app.float.service_card_radius'))
          .borderWidth($r('app.float.service_card_border_width'))
          .borderColor($r('app.color.service_card_border_color'))
          .margin({
            left: $r('app.float.service_card_space'),
            right: $r('app.float.service_card_space'),
            top: 10
          })

          // ================== ③ 处方药信息 ==================
          Column() {
            Text('处方药信息')
              .fontSize($r('app.float.service_card_title_font_size'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.service_primary_text_color'))
              .margin({
                left: $r('app.float.service_text_left_right_margin'),
                right: $r('app.float.service_text_left_right_margin'),
                top: 16,
                bottom: 10
              })
              .alignSelf(ItemAlign.Start)

            Divider()
              .strokeWidth(1)
              .color($r('app.color.service_card_border_color'))
              .margin({
                left: $r('app.float.service_text_left_right_margin'),
                right: $r('app.float.service_text_left_right_margin'),
                bottom: 12
              })

            // 药品标题：#1 999感冒灵
            Text(this.order.prescription.indexTitle)
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.service_primary_text_color'))
              .margin({
                left: $r('app.float.service_text_left_right_margin'),
                right: $r('app.float.service_text_left_right_margin'),
                bottom: 14
              })

            // 药品详情：左标签 + 右内容
            this.InfoRowWide('类型', this.order.prescription.type)
            this.InfoRowWide('规格', this.order.prescription.spec)
            this.InfoRowWide('剂量', this.order.prescription.dosage)
            this.InfoRowWide('频次', this.order.prescription.frequency)
            this.InfoRowWide('数量', this.order.prescription.quantity)
            this.InfoRowWide('单价', this.order.prescription.unitPrice)
            this.InfoRowWide('总价', this.order.prescription.totalPrice)
            this.InfoRowWide('用法', this.order.prescription.usage)

            Blank().height(14)
          }
          .backgroundColor($r('app.color.service_card_background_color'))
          .borderRadius($r('app.float.service_card_radius'))
          .borderWidth($r('app.float.service_card_border_width'))
          .borderColor($r('app.color.service_card_border_color'))
          .margin({
            left: $r('app.float.service_card_space'),
            right: $r('app.float.service_card_space'),
            top: 10
          })

          // 底部留白
          Blank().height(24)
        }
        .width('100%')
      }
      .width('100%')
      .layoutWeight(1)

      if (!this.order.paid) {
        // 未支付订单显示“去支付”入口
        Row() {
          Button('去支付')
            .height(44)
            .layoutWeight(1)
            .backgroundColor('#07C6A5')
            .fontColor(Color.White)
            .borderRadius(22)
            .onClick(() => {
              router.pushUrl({
                url: 'pages/VisitRecordPayPage',
                params: { orderId: this.order.id }
              });
            })
        }
        .width('90%')
        .margin({ top: 8, bottom: 16 })
      }
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
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);
  }

  /**
   * 信息行组件：
   */
  @Builder
  private InfoRowWide(label: string, value: string): void {
    Row() {
      Text(label)
        .fontSize($r('app.float.service_body_font_size'))
        .fontColor($r('app.color.service_secondary_text_color'))
        .textAlign(TextAlign.Start)

      Blank().layoutWeight(1)

      Text(value)
        .fontSize($r('app.float.service_body_font_size'))
        .fontColor($r('app.color.service_primary_text_color'))
        .textAlign(TextAlign.End)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .margin({
      left: $r('app.float.service_text_left_right_margin'),
      right: $r('app.float.service_text_left_right_margin'),
      top: 10,
      bottom: 10
    })
  }

  private safeText(value: string): string {
    if (!value || value.trim().length === 0) {
      return '无';
    }
    return value;
  }

  private syncOrderFromStore(): void {
    if (!this.orderId) {
      return;
    }
    // 从内存仓库读取最新状态
    const record = getVisitRecordById(this.orderId);
    if (record) {
      this.order = cloneOrder(record);
    }
  }
}
