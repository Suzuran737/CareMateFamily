// pages/AdmissionRecordDetailPage.ets
import router from '@ohos.router';
import { AdmissionRecord, ApplyFormData, AdmissionItem } from '../model/AdmissionRecord';

@Entry
@Component
struct AdmissionRecordDetailPage {
  @State record: AdmissionRecord | undefined = undefined;

  aboutToAppear() {
    const params = router.getParams() as Record<string, AdmissionRecord>;
    if (params && params.record) {
      this.record = params.record;
    }
  }

  formatDate(timestamp: number): string {
    const date = new Date(timestamp);
    return `${date.getFullYear()}-${(date.getMonth() + 1).toString().padStart(2, '0')}-${date.getDate().toString().padStart(2, '0')} ${date.getHours().toString().padStart(2, '0')}:${date.getMinutes().toString().padStart(2, '0')}`;
  }

  build() {
    Column() {
      // 1. 导航栏
      Row() {
        Text('<')
          .fontSize(26)
          .fontColor(Color.White)
          .margin({ left: 16 })
          .onClick(() => router.back())
        Text('申请详情')
          .fontSize(16)
          .fontWeight(FontWeight.Normal)
          .fontColor(Color.White)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .margin({ right: 40 })
      }
      .width('100%')
      .height(56)
      .backgroundColor('#ff12cdaf')

      if (this.record) {
        Scroll() {
          Column() {
            // 2. 状态横幅
            this.StatusBanner()

            // 3. 基本信息卡片 (使用最直接的写法，不再使用带 @BuilderParam 的函数)
            Column() {
              this.CardTitle('基本信息')
              this.InfoRow('申请单号', this.record.id)
              this.InfoRow('申请类型', this.record.type === 'SINGLE' ? '单人入住' : '批量入住')
              this.InfoRow('提交时间', this.formatDate(this.record.submitTime))
            }
            .width('100%').backgroundColor(Color.White).borderRadius(12).padding(16).margin({ bottom: 16 })

            // 4. 人员清单
            if (this.record.type === 'SINGLE') {
              Column() {
                this.CardTitle('入住人员')
                // 核心修复：直接在参数内进行类型转换 (Inline Casting)
                this.InfoRow('姓名', (this.record.data as ApplyFormData).name)
                this.InfoRow('机构', (this.record.data as ApplyFormData).org)
                this.InfoRow('部门', (this.record.data as ApplyFormData).dept)
                this.InfoRow('房间号', (this.record.data as ApplyFormData).room || '未填写')
                this.InfoRow('备注', (this.record.data as ApplyFormData).remark || '无')
              }
              .width('100%').backgroundColor(Color.White).borderRadius(12).padding(16).margin({ bottom: 16 })

            } else {
              Column() {
                this.CardTitle(`入住人员 (${(this.record.data as AdmissionItem[]).length}人)`)
                ForEach((this.record.data as AdmissionItem[]), (item: AdmissionItem, index: number) => {
                  Column() {
                    Text(`人员 ${index + 1}`).fontSize(14).fontWeight(FontWeight.Bold).margin({ bottom: 8, top: index > 0 ? 12 : 0 })
                    this.InfoRow('姓名', item.name)
                    this.InfoRow('机构/部门', `${item.org} / ${item.dept}`)
                    if (item.room) this.InfoRow('房间号', item.room)
                    this.InfoRow('备注', item.remark || '无')
                    if (index < (this.record?.data as AdmissionItem[]).length - 1) {
                      Divider().margin({ top: 12 }).color('#EEE')
                    }
                  }.alignItems(HorizontalAlign.Start).width('100%')
                })
              }
              .width('100%').backgroundColor(Color.White).borderRadius(12).padding(16).margin({ bottom: 16 })
            }
          }.width('100%').padding(16)
        }
      }
    }
    .width('100%').height('100%').backgroundColor('#F1F3F5')
  }

  @Builder StatusBanner() {
    Column() {
      Text(this.record?.status === 'PENDING' ? '待审核' : this.record?.status === 'APPROVED' ? '已通过' : '已拒绝')
        .fontSize(24).fontWeight(FontWeight.Bold).fontColor(Color.White)
      Text('您的申请正在处理中，请耐心等待')
        .fontSize(14).fontColor(Color.White).margin({ top: 8 }).opacity(0.8)
    }
    .width('100%').padding(30).backgroundColor('#ff12cdaf').alignItems(HorizontalAlign.Center)
    .margin({ bottom: 16 })
  }

  @Builder CardTitle(title: string) {
    Text(title).fontSize(16).fontWeight(FontWeight.Bold).margin({ bottom: 12 }).fontColor('#333')
  }

  @Builder InfoRow(label: string, value: string) {
    Row() {
      Text(label).fontSize(14).fontColor('#666').width(80)
      Text(value).fontSize(14).fontColor('#333').layoutWeight(1).fontWeight(FontWeight.Medium)
    }.width('100%').margin({ bottom: 8 }).alignItems(VerticalAlign.Top)
  }
}