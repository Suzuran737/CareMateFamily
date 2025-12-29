import { OrderInfo } from '../model/AdmissionRecord';
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

        if(!this.isExpanded){
          Text('展开喵')
            .fontSize(12)
            .fontColor(Color.Grey)
            .opacity(0.9)
            .margin({ top: 10, bottom: 10 })
            .onClick(()=>{
              this.isExpanded = !this.isExpanded;
            })
        }
      }
      .padding(16)
      .width('100%')

      if (this.isExpanded) {
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

          Text('收起喵')
            .fontSize(12)
            .fontColor(Color.Grey)
            .opacity(0.9)
            .margin({ top: 5, bottom: 1 })
            .onClick(()=>{
              this.isExpanded = !this.isExpanded;
            })
        }
        .padding(16)
      }
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
struct VisitRecordsPage {
  private orders: OrderInfo[] = []; // 用户数据数组
  aboutToAppear() {
    // 这里模拟数据，实际应从网络或本地获取
    this.orders = this.getMockOrders();
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
            Column({ space: 12 }) {
              // 使用ForEach循环渲染可复用卡片
              ForEach(this.orders, (order: OrderInfo) => {
                OrderCard({ order: order })
              }, (order: OrderInfo) => order.id)
            }
            .padding(4)
            .width('100%')

            Text('没有更多了喵')
              .fontSize(12)
              .fontColor(Color.Grey)
              .opacity(0.9)
              .margin({ top: 15, bottom: 30 })
          }
          .width('100%')
          .height('100%')
        }
        .width('100%')
        .height('85%')
        .backgroundColor('#EEEEEE')
        .scrollBar(BarState.Off)
        }
      }
    }
  // VisitRecordsPage.ts 中的模拟数据函数
  private getMockOrders(): OrderInfo[] {
    return [
      {
        id: 'ORD20231127001',
        patient: '张三',
        paid: true,
        doctor: '王医生',
        time: '2023-11-27 09:30:00',
        amount: '¥150.00',
        symptom: '咳嗽、发热3天，伴有咽痛',
        medical_history: '无重大病史，有季节性过敏',
        allergy_history: '青霉素过敏',
        diagnosis: '急性上呼吸道感染',
        prescription: '阿莫西林胶囊 0.5g*24片\n用法：一次2片，一日3次'
      },
      {
        id: 'ORD20231127002',
        patient: '李四',
        paid: false,
        doctor: '刘医生',
        time: '2023-11-27 10:15:00',
        amount: '¥200.00',
        symptom: '持续性头痛，伴有恶心',
        medical_history: '高血压病史5年',
        allergy_history: '无',
        diagnosis: '偏头痛急性发作',
        prescription: '布洛芬缓释胶囊 300mg*20粒\n用法：一次1粒，一日2次'
      },
      {
        id: 'ORD20231127003',
        patient: '王五',
        paid: true,
        doctor: '赵医生',
        time: '2023-11-27 14:20:00',
        amount: '¥180.00',
        symptom: '腰部扭伤，活动受限',
        medical_history: '腰椎间盘突出病史',
        allergy_history: '磺胺类药物过敏',
        diagnosis: '急性腰扭伤',
        prescription: '外用止痛膏，每日3次\n建议休息，避免重体力劳动'
      },
      {
        id: 'ORD20231127004',
        patient: '赵六',
        paid: true,
        doctor: '孙医生',
        time: '2023-11-27 16:45:00',
        amount: '¥120.00',
        symptom: '胃部不适，反酸烧心',
        medical_history: '慢性胃炎病史',
        allergy_history: '无',
        diagnosis: '慢性胃炎急性发作',
        prescription: '奥美拉唑肠溶胶囊 20mg*14粒\n用法：一次1粒，一日1次'
      },
      {
        id: 'ORD20231127005',
        patient: '钱七',
        paid: false,
        doctor: '周医生',
        time: '2023-11-27 18:30:00',
        amount: '¥250.00',
        symptom: '手腕关节肿胀疼痛',
        medical_history: '痛风病史2年',
        allergy_history: '头孢类药物过敏',
        diagnosis: '痛风性关节炎',
        prescription: '秋水仙碱片 0.5mg*20片\n用法：遵医嘱服用'
      },
      {
        id: 'ORD20231127006',
        patient: '孙八',
        paid: true,
        doctor: '吴医生',
        time: '2023-11-27 19:15:00',
        amount: '¥300.00',
        symptom: '失眠，入睡困难',
        medical_history: '焦虑症病史',
        allergy_history: '无',
        diagnosis: '睡眠障碍',
        prescription: '佐匹克隆片 7.5mg*20片\n用法：睡前1片'
      },
      {
        id: 'ORD20231127007',
        patient: '周九',
        paid: true,
        doctor: '郑医生',
        time: '2023-11-27 20:45:00',
        amount: '¥180.00',
        symptom: '皮肤瘙痒，出现红疹',
        medical_history: '过敏性体质',
        allergy_history: '海鲜过敏',
        diagnosis: '过敏性皮炎',
        prescription: '氯雷他定片 10mg*6片\n用法：一次1片，一日1次'
      },
      {
        id: 'ORD20231127008',
        patient: '吴十',
        paid: false,
        doctor: '王医生',
        time: '2023-11-27 21:30:00',
        amount: '¥220.00',
        symptom: '膝关节疼痛，上下楼困难',
        medical_history: '关节炎病史',
        allergy_history: '无',
        diagnosis: '骨性关节炎',
        prescription: '盐酸氨基葡萄糖胶囊 0.75g*42粒\n用法：一次2粒，一日2次'
      }
    ];
  }
}
