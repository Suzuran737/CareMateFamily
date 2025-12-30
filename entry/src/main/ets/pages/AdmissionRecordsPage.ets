// pages/AdmissionRecordsPage.ets
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import type common from '@ohos.app.ability.common';
import { AdmissionRecord, ApplyFormData, AdmissionItem } from '../model/AdmissionRecord';
import { KvStoreManager } from '../utils/KvStoreManager';

@Entry
@Component
struct AdmissionRecordsPage {
  @State records: AdmissionRecord[] = [];
  @State isLoading: boolean = true;
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;

  onPageShow() {
    this.loadRecords();
  }

  async loadRecords() {
    this.isLoading = true;
    try {
      console.info('正在刷新列表...');
      await KvStoreManager.getInstance().initKvStore(this.context);
      const data = await KvStoreManager.getInstance().getRecords();
      this.records = [...data];
    } catch (e) {
      console.error('刷新失败');
    } finally {
      this.isLoading = false;
    }
  }

  formatDate(timestamp: number): string {
    const date = new Date(timestamp);
    return `${date.getFullYear()}-${(date.getMonth() + 1).toString().padStart(2, '0')}-${date.getDate().toString().padStart(2, '0')} ${date.getHours().toString().padStart(2, '0')}:${date.getMinutes().toString().padStart(2, '0')}`;
  }

  build() {
    // 最外层 Column 垂直排列：导航栏 -> 列表(自适应) -> 底部按钮(固定)
    Column() {
      // --- 1. 顶部导航栏 ---
      Row() {
        Text('<')
          .fontSize(24)
          .fontColor(Color.White)
          .margin({ left: 16 })
          .onClick(() => router.back())

        Text('我的申请记录')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Text('刷新')
          .fontSize(14)
          .fontColor(Color.White)
          .margin({ right: 16 })
          .onClick(() => this.loadRecords())
      }
      .width('100%')
      .height(56)
      .backgroundColor('#07C6A5')

      // --- 2. 中间内容区 (使用 layoutWeight 确保它占据剩余空间) ---
      Column() {
        if (this.isLoading) {
          Column() {
            LoadingProgress().width(40).height(40).color('#07C6A5')
            Text('加载中...').fontColor('#999').margin({ top: 8 })
          }.width('100%').height('100%').justifyContent(FlexAlign.Center)
        } else if (this.records.length === 0) {
          Column() {
            Image($r('app.media.ic_empty_record'))
              .width(100).height(100).opacity(0.5)
            Text('暂无申请记录').fontColor('#999').margin({ top: 16 })
          }.width('100%').height('100%').justifyContent(FlexAlign.Center)
        } else {
          List({ space: 12 }) {
            ForEach(this.records, (record: AdmissionRecord) => {
              ListItem() {
                this.RecordCard(record)
              }
            }, (item: AdmissionRecord) => item.id + item.submitTime)
          }
          .width('100%')
          .height('100%')
          .padding({ left: 16, right: 16, top: 12 })
        }
      }
      .layoutWeight(1) // 重要：这会让中间区域自适应，从而把按钮顶到底部
      .width('100%')

      // --- 3. 底部固定按钮区 ---
      Column() {
        Button('申请入住')
          .width('90%')
          .height(50)
          .borderRadius(25)
          .backgroundColor('#07C6A5')
          .fontColor(Color.White)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .shadow({ radius: 8, color: '#4D07C6A5', offsetY: 4 })
          .onClick(() => {
            router.pushUrl({ url: 'pages/AdmissionApplyPage' });
          })
      }
      .width('100%')
      .padding({ top: 12, bottom: 24 }) // 底部预留安全距离
      .backgroundColor(Color.White)
      .shadow({ radius: 10, color: '#1A000000', offsetY: -2 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F1F3F5')
  }

  // --- 记录卡片组件 ---
  @Builder RecordCard(record: AdmissionRecord) {
    Column() {
      Row() {
        Row() {
          Circle({ width: 8, height: 8 }).fill(record.type === 'SINGLE' ? '#07C6A5' : '#1890FF')
          Text(record.type === 'SINGLE' ? ' 单人申请' : ' 批量申请')
            .fontSize(14).fontWeight(FontWeight.Medium).fontColor(record.type === 'SINGLE' ? '#07C6A5' : '#1890FF')
        }
        this.StatusBadge(record.status)
      }.width('100%').justifyContent(FlexAlign.SpaceBetween).margin({ bottom: 12 })

      Column() {
        if (record.type === 'SINGLE') {
          this.InfoLine('姓名', (record.data as ApplyFormData).name)
          this.InfoLine('机构', (record.data as ApplyFormData).org)
        } else {
          this.InfoLine('申请人数', (record.data as AdmissionItem[]).length + ' 人')
          if ((record.data as AdmissionItem[]).length > 0) {
            this.InfoLine('主要人员', (record.data as AdmissionItem[])[0].name)
          }
        }
      }.alignItems(HorizontalAlign.Start).backgroundColor('#F8F9FA').padding(12).borderRadius(8).width('100%')

      Text('提交时间：' + this.formatDate(record.submitTime)).fontSize(12).fontColor('#999').margin({ top: 12 })
    }
    .padding(16).backgroundColor(Color.White).borderRadius(12).shadow({ radius: 6, color: '#10000000', offsetY: 2 })
    .onClick(() => {
      router.pushUrl({ url: 'pages/AdmissionRecordDetailPage', params: { record: record } });
    })
  }

  @Builder InfoLine(label: string, value: string) {
    Row() {
      Text(label + '：').fontSize(13).fontColor('#666')
      Text(value).fontSize(13).fontColor('#333').fontWeight(FontWeight.Medium)
    }.margin({ bottom: 4 })
  }

  @Builder StatusBadge(status: string) {
    Text(status === 'PENDING' ? '待审核' : status === 'APPROVED' ? '已通过' : '已拒绝')
      .fontSize(11).fontColor('#FAAD14').backgroundColor('#FFFBE6').padding({ left: 8, right: 8, top: 2, bottom: 2 }).borderRadius(4)
  }
}