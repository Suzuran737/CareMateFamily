import router from '@ohos.router';
import { OrderInfo } from '../model/AdmissionRecord';

interface OrderRouteParams {
  id?: string | number;
  order?: OrderInfo;
}
@Component
struct OrderCard {
  // 使用@Prop装饰器实现卡片复用
  @Prop order: OrderInfo;
  @State private isExpanded: boolean = false;

  build() {
    Column({ space: 8 }) {
      Column({ space: 6 }) {
        Row() {
          Row(){
            Text(this.order.patient)
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .alignSelf(ItemAlign.Start)

          Row() {
            Text(this.order.paid ? '已支付' : '未支付')
              .fontSize(12)
              .fontColor(this.order.paid ? Color.Blue : Color.Red)
              .margin({ right: 2 })
          }
          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
          .borderRadius(4)
          .backgroundColor(this.order.paid?'#E6F3FF' : '#FFE6E6') // 浅蓝/浅红背景
          .alignSelf(ItemAlign.End) // 靠右对齐
        }
        .margin({ bottom: 8 })

        this.buildInfoRow('医护名称', this.order.doctor)

        this.buildInfoRow('问诊时间', this.order.time)

        this.buildInfoRow('金额', this.order.amount)
      }
      .padding(16)
      .width('100%')

        Column({ space: 6 }) {
          Row() {
            Text('处方信息')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .margin({ bottom: 8 })
          .alignSelf(ItemAlign.Start)

          this.buildInfoRow('主诉', this.order.symptom)

          this.buildInfoRow('病史', this.order.medical_history)

          this.buildInfoRow('过敏史', this.order.allergy_history)

          this.buildInfoRow('诊断', this.order.diagnosis)
        }
        .padding(16)

    }
    .backgroundColor(0xFFFFFFFF)
    .borderWidth($r('app.float.home_health_card_border_width'))
    .borderColor(0x28000000)
    .borderRadius($r('app.float.home_health_card_radius'))
    .clip(true)
    .margin({
      left: $r('app.float.home_health_card_horizontal_margin'),
      right: $r('app.float.home_health_card_horizontal_margin'),
      top: $r('app.float.home_health_card_top_margin')
    })
  }

  // 构建信息行的私有方法
  @Builder
  private buildInfoRow(label: string, value: string) {
    Row() {
      // 标签（灰色左对齐）
      Text(label)
        .fontSize(13)
        .fontColor('#666666') // 灰色
        .textAlign(TextAlign.Start)
        .width('40%')

      // 信息（黑色右对齐）
      Text(value)
        .fontSize(13)
        .fontColor(Color.Black)
        .textAlign(TextAlign.End)
        .width('60%')
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width('100%')
    .margin({ bottom: 4,right: 4})
  }
}

@Entry
@Component
export default struct VisitRecordDetailPage {
  @State order: OrderInfo = new OrderInfo();
  aboutToAppear(): void {
    // 获取路由参数
    const params = router.getParams() as OrderRouteParams;
    if (params && params.order) {
      // 如果传入了完整的订单对象
      this.order = params.order;
    } else if (params && params.id) {
      // 如果只传入了ID，可以在这里添加从本地存储或API获取数据的逻辑
      console.log('需要根据ID获取订单详情:', params.id);
      // 这里可以调用方法从本地存储或网络获取数据
    }
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
        .margin({bottom : 5})
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)

        // 2. 问诊记录信息区
        Scroll() {
          Column() {
                OrderCard({ order: this.order })
            }
            .padding(4)
            .width('100%')
        }
        .width('100%')
        .height('85%')
        .backgroundColor('#EEEEEE')
        .scrollBar(BarState.Off)
      }
    }
  }

}