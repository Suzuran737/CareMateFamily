// pages/AdmissionRecordsPage.ets - 入住申请列表
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

  // 清空已存储的入住申请记录
  private onClearRecords(): void {
    promptAction.showDialog({
      title: '确认清空',
      message: '确定要删除所有入住申请记录吗？',
      buttons: [
        { text: '取消', color: '#666666' },
        { text: '确认', color: '#FF4D4F' }
      ]
    })
      .then(result => {
        if (result.index === 1) {
          this.executeClearRecords();
        }
      })
  }

  // 执行清空并刷新页面
  private async executeClearRecords(): Promise<void> {
    this.isLoading = true;
    try {
      await KvStoreManager.getInstance().initKvStore(this.context);
      const success = await KvStoreManager.getInstance().clearRecords();
      if (success) {
        this.records = [];
        promptAction.showToast({ message: '已清空申请记录' });
      } else {
        promptAction.showToast({ message: '清空失败，请重试' });
      }
    } catch (e) {
      promptAction.showToast({ message: '清空失败，请重试' });
    } finally {
      this.isLoading = false;
    }
  }

  formatDate(timestamp: number): string {
    const date = new Date(timestamp);
    return `${date.getFullYear()}-${(date.getMonth() + 1).toString().padStart(2, '0')}-${date.getDate()
      .toString()
      .padStart(2, '0')} ${date.getHours().toString().padStart(2, '0')}:${date.getMinutes()
      .toString()
      .padStart(2, '0')}`;
  }

  build() {
    // 最外层 Column 垂直排列：导航栏 -> 列表(自适应) -> 底部按钮(固定)
    Column() {
      // --- 1. 顶部导航栏 ---
      Row() {
        // 左：返回按钮（固定宽度）
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
        Text('入住申请列表')
          .fontSize($r('app.float.common_nav_title_font_size'))
          .fontWeight(FontWeight.Normal)
          .fontColor($r('app.color.common_nav_text_color'))
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Text('刷新')
          .fontSize(14)
          .width(48)
          .fontColor(Color.White)
          // .margin({ right: 16 })
          .onClick(() => this.loadRecords())
      }
      .height($r('app.float.common_nav_height'))
      .width('100%')
      .alignItems(VerticalAlign.Center)

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
        Row() {
          Button('清空记录')
            .layoutWeight(1)
            .height($r('app.float.service_button_height'))
            .backgroundColor(Color.White)
            .fontColor('#FF4D4F')
            .fontSize($r('app.float.service_button_font_size'))
            .borderRadius($r('app.float.service_button_border_radius'))
            .border({ width: 1, color: '#FF4D4F' })
            .margin({ right: 12 })
            .onClick(() => this.onClearRecords())

          Button('申请入住')
            .layoutWeight(1)
            .height($r('app.float.service_button_height'))
            .backgroundColor($r('app.color.service_button_background_color'))
            .fontColor($r('app.color.service_button_text_color'))
            .fontSize($r('app.float.service_button_font_size'))
            .borderRadius($r('app.float.service_button_border_radius'))
            .onClick(() => {
              router.pushUrl({ url: 'pages/AdmissionApplyPage' });
            })
        }
        .width('90%')
      }
      .width('100%')
      .padding({ top: 12, bottom: 24 }) // 底部预留安全距离
      .backgroundColor(Color.White)
      .shadow({ radius: 10, color: '#1A000000', offsetY: -2 })
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

  // --- 记录卡片组件 ---
  @Builder
  RecordCard(record: AdmissionRecord) {
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
      }
      .alignItems(HorizontalAlign.Start)
      .backgroundColor('#F8F9FA')
      .padding(12)
      .borderRadius(8)
      .width('100%')

      Text('提交时间：' + this.formatDate(record.submitTime)).fontSize(12).fontColor('#999').margin({ top: 12 })
    }
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .borderWidth(1)
    .borderColor(0x28000000)
    .shadow({ radius: 6, color: '#10000000', offsetY: 2 })
    .onClick(() => {
      router.pushUrl({ url: 'pages/AdmissionRecordDetailPage', params: { record: record } });
    })
  }

  @Builder
  InfoLine(label: string, value: string) {
    Row() {
      Text(label + '：').fontSize(13).fontColor('#666')
      Text(value).fontSize(13).fontColor('#333').fontWeight(FontWeight.Medium)
    }.margin({ bottom: 4 })
  }

  @Builder
  StatusBadge(status: string) {
    Text(status === 'PENDING' ? '待审核' : status === 'APPROVED' ? '已通过' : '已拒绝')
      .fontSize(11)
      .fontColor('#FAAD14')
      .backgroundColor('#FFFBE6')
      .padding({
        left: 8,
        right: 8,
        top: 2,
        bottom: 2
      })
      .borderRadius(4)
  }
}
