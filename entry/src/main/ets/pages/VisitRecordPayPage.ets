import router from '@ohos.router';
import { OrderInfo, PrescriptionDetail } from '../model/AdmissionRecord';
import { getVisitRecordById, markVisitRecordPaid } from '../model/VisitRecordStore';

interface VisitRecordPayRouteParams {
  // 从详情页传入的订单 ID
  orderId?: string;
}

// 无路由参数时的兜底订单数据
function buildFallbackOrder(): OrderInfo {
  const prescription = new PrescriptionDetail();
  prescription.indexTitle = '#1 999感冒灵';
  prescription.type = '中成药';
  prescription.spec = '9包';
  prescription.dosage = '1';
  prescription.frequency = '1';
  prescription.quantity = '1';
  prescription.unitPrice = '10';
  prescription.totalPrice = '10';
  prescription.usage = '热水冲服';

  const order = new OrderInfo();
  order.id = 'ORD20231127001';
  order.patient = '赵智晟';
  order.paid = false;
  order.doctor = '张玉峰';
  order.time = '2024-04-26 15:34:24';
  order.amount = '￥34';
  order.symptom = '发热、胸闷、无力、咳嗽';
  order.medical_history = '无';
  order.allergy_history = '海鲜过敏';
  order.diagnosis = '发热';
  order.prescription = prescription;
  return order;
}

@Entry
@Component
export default struct VisitRecordPayPage {
  @State private order: OrderInfo = buildFallbackOrder();
  // 收件信息表单
  @State private receiverName: string = '';
  @State private receiverPhone: string = '';
  @State private receiverAddress: string = '';
  @State private remark: string = '';

  aboutToAppear(): void {
    const params = router.getParams() as VisitRecordPayRouteParams;
    if (params && params.orderId) {
      // 根据订单 ID 拉取详情
      const record = getVisitRecordById(params.orderId);
      if (record) {
        this.order = record;
      }
    }
  }

  build() {
    Column() {
      // 顶部导航栏
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

        Text('问诊订单支付')
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

      Scroll() {
        Column() {
          this.OrderSummaryCard()
          this.ReceiverFormCard()
          Blank().height(24)
        }
        .width('100%')
      }
      .width('100%')

      Blank().layoutWeight(1)

      // 支付按钮
      Row() {
        Button('支付')
          .width('100%')
          .height(44)
          .backgroundColor('#07C6A5')
          .fontColor(Color.White)
          .borderRadius(22)
          .onClick(() => {
            // 更新内存中的支付状态，并通知列表刷新
            markVisitRecordPaid(this.order.id);
            this.order.paid = true;
            AppStorage.set('visitRecordRefresh', Date.now());
            router.back();
          })
      }
      .width('90%')
      .margin({ top: 8, bottom: 16 })
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

  // 订单摘要卡片
  @Builder
  private OrderSummaryCard(): void {
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
          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
      }
      .margin({
        left: $r('app.float.service_text_left_right_margin'),
        right: $r('app.float.service_text_left_right_margin'),
        top: 16,
        bottom: 12
      })

      this.InfoRowWide('医护名称', this.order.doctor)
      this.InfoRowWide('问诊时间', this.order.time)

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
  }

  // 收件信息表单区域
  @Builder
  private ReceiverFormCard(): void {
    Column() {
      Text('收件信息')
        .fontSize($r('app.float.service_card_title_font_size'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.service_primary_text_color'))
        .margin({
          // left: $r('app.float.service_text_left_right_margin'),
          right: $r('app.float.service_text_left_right_margin'),
          top: 16,
          bottom: 12
        })
        .alignSelf(ItemAlign.Start)

      this.InputRow('收件人', true, '请输入收件人姓名', this.receiverName, (value: string) => {
        this.receiverName = value;
      })
      this.InputRow('手机号', true, '请输入联系人手机号', this.receiverPhone, (value: string) => {
        this.receiverPhone = value;
      })
      this.InputRow('地址', true, '请输入地址', this.receiverAddress, (value: string) => {
        this.receiverAddress = value;
      })
      this.InputRow('备注', false, '请输入备注', this.remark, (value: string) => {
        this.remark = value;
      })
    }
    .padding({ left: 12, right: 12, bottom: 8 })
    .backgroundColor($r('app.color.service_card_background_color'))
    .borderRadius($r('app.float.service_card_radius'))
    .borderWidth($r('app.float.service_card_border_width'))
    .borderColor($r('app.color.service_card_border_color'))
    .margin({
      left: $r('app.float.service_card_space'),
      right: $r('app.float.service_card_space'),
      top: 10
    })
  }

  @Builder
  private InputRow(label: string, required: boolean, placeholder: string, value: string, onChange: (val: string) => void): void {
    Row() {
      Row() {
        Text(label)
          .fontSize(14)
          .fontColor('#333333')
        if (required) {
          Text('*')
            .fontSize(14)
            .fontColor('#E53935')
            .margin({ left: 2 })
        }
      }

      Blank().layoutWeight(1)

      TextInput({ placeholder: placeholder, text: value })
        .fontSize(14)
        .fontColor('#333333')
        .placeholderFont({ size: $r('app.float.service_body_font_size') })
        .placeholderColor($r('app.color.service_secondary_text_color'))
        .textAlign(TextAlign.End)
        .onChange((val: string) => onChange(val))
        .width('70%')
    }
    .width('100%')
    .height(44)
    .margin({ bottom: 8 })
  }

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
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .margin({
      left: $r('app.float.service_text_left_right_margin'),
      right: $r('app.float.service_text_left_right_margin'),
      top: 8,
      bottom: 8
    })
  }
}
