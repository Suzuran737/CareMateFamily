// pages/AdmissionRecordsPage.ets
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import type common from '@ohos.app.ability.common';
import { AdmissionRecord, ApplyFormData, AdmissionItem } from '../model/AdmissionRecord';
import { KvStoreManager } from '../utils/KvStoreManager';
import util from '@ohos.util';

@Entry
@Component
struct AdmissionRecordsPage {
  @State records: AdmissionRecord[] = [];
  @State isLoading: boolean = true;
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;

  aboutToAppear() {
    this.loadRecords();
  }

  // pages/AdmissionRecordsPage.ets 里的 loadRecords 方法
  async loadRecords() {
    this.isLoading = true;
    try {
      console.info('正在刷新列表...');
      await KvStoreManager.getInstance().initKvStore(this.context);
      const data = await KvStoreManager.getInstance().getRecords();

      // --- 关键：使用展开运算符确保 UI 感知到数组变化 ---
      this.records = [...data];

      promptAction.showToast({ message: `同步完成，共 ${this.records.length} 条` });
    } catch (e) {
      console.error('刷新失败');
    } finally {
      this.isLoading = false;
    }
  }

  // 格式化时间戳
  formatDate(timestamp: number): string {
    const date = new Date(timestamp);
    return `${date.getFullYear()}-${(date.getMonth() + 1).toString().padStart(2, '0')}-${date.getDate().toString().padStart(2, '0')} ${date.getHours().toString().padStart(2, '0')}:${date.getMinutes().toString().padStart(2, '0')}`;
  }

  build() {
    Column() {
      // --- 1. 导航栏 ---
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
          .margin({ right: 40 })
        // pages/AdmissionRecordsPage.ets 标题栏 Row 内部追加
        Text('刷新')
          .fontSize(14)
          .fontColor(Color.White)
          .margin({ right: 16 })
          .onClick(() => {
            this.loadRecords(); // 点击手动触发加载
          })
      }
      .width('100%')
      .height(56)
      .backgroundColor('#07C6A5')

      // --- 2. 内容区 ---
      if (this.isLoading) {
        Column() {
          LoadingProgress().width(40).height(40).color('#07C6A5')
          Text('加载中...').fontColor('#999').margin({ top: 8 })
        }.justifyContent(FlexAlign.Center).layoutWeight(1)
      } else if (this.records.length === 0) {
        Column() {
          Image($r('app.media.ic_empty_record')) // 请确保有此图标或换成文字
            .width(100).height(100).opacity(0.5)
          Text('暂无申请记录').fontColor('#999').margin({ top: 16 })
        }.justifyContent(FlexAlign.Center).layoutWeight(1)
      } else {
        List({ space: 12 }) {
          ForEach(this.records, (record: AdmissionRecord) => {
            ListItem() {
              this.RecordCard(record)
            }
          })
        }
        .width('100%')
        .layoutWeight(1)
        .padding(16)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F1F3F5')
  }

  // --- 3. 记录卡片组件 ---
  @Builder RecordCard(record: AdmissionRecord) {
    Column() {
      // 头部：类型 + 状态
      Row() {
        Row() {
          Circle({ width: 8, height: 8 }).fill(record.type === 'SINGLE' ? '#07C6A5' : '#1890FF')
          Text(record.type === 'SINGLE' ? ' 单人申请' : ' 批量申请')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor(record.type === 'SINGLE' ? '#07C6A5' : '#1890FF')
        }

        this.StatusBadge(record.status)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 12 })

      // 中间：人员信息
      Column() {
        if (record.type === 'SINGLE') {
          // 直接在参数里进行类型转换 (record.data as ApplyFormData)
          this.InfoLine('姓名', (record.data as ApplyFormData).name)
          this.InfoLine('机构/部门', `${(record.data as ApplyFormData).org} / ${(record.data as ApplyFormData).dept}`)
        } else {
          // 同样，批量申请也直接转换 (record.data as AdmissionItem[])
          this.InfoLine('申请人数', `${(record.data as AdmissionItem[]).length} 人`)
          this.InfoLine('主要人员', (record.data as AdmissionItem[])[0].name +
            ((record.data as AdmissionItem[]).length > 1 ? ` 等${(record.data as AdmissionItem[]).length}人` : ''))
        }
      }
      .alignItems(HorizontalAlign.Start)
      .backgroundColor('#F8F9FA')
      .padding(12)
      .borderRadius(8)
      .width('100%')

      // 底部：时间
      Row() {
        Text('提交时间：' + this.formatDate(record.submitTime))
          .fontSize(12)
          .fontColor('#999')
      }
      .width('100%')
      .margin({ top: 12 })
    }
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .shadow({ radius: 6, color: '#10000000', offsetY: 2 })
    .onClick(() => {
      router.pushUrl({
        url: 'pages/AdmissionRecordDetailPage',
        params: {
          record: record // 把整条数据塞进参数传过去
        }
      });
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
      .fontSize(11)
      .fontColor(status === 'PENDING' ? '#FAAD14' : status === 'APPROVED' ? '#52C41A' : '#F5222D')
      .backgroundColor(status === 'PENDING' ? '#FFFBE6' : status === 'APPROVED' ? '#F6FFED' : '#FFF1F0')
      .padding({ left: 8, right: 8, top: 2, bottom: 2 })
      .border({ width: 0.5, color: status === 'PENDING' ? '#FFE58F' : status === 'APPROVED' ? '#B7EB8F' : '#FFA39E' })
      .borderRadius(4)
  }
}