/**
 * 健康数据录入表单页
 */

import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import type common from '@ohos.app.ability.common';
import { CareUserStoreManager, CareUserRecord } from '../utils/CareUserStoreManager';
import { HealthRecordStoreManager, HealthRecord } from '../utils/HealthRecordStoreManager';
import { HealthDataManager } from '../model/HealthData';

class SelectOption {
  value: string;
  id?: string;

  constructor(value: string, id?: string) {
    this.value = value;
    if (id !== undefined) {
      this.id = id;
    }
  }
}

@Entry
@Component
export default struct HealthRecordFormPage {
  private context: common.UIAbilityContext = getContext() as common.UIAbilityContext;
  private careStore: CareUserStoreManager = CareUserStoreManager.getInstance();
  private healthStore: HealthRecordStoreManager = HealthRecordStoreManager.getInstance();

  @State private userOptions: SelectOption[] = [];
  @State private selectedUserIndex: number = -1;
  @State private typeOptions: SelectOption[] = [];
  @State private selectedTypeIndex: number = -1;
  @State private valueText: string = '';

  aboutToAppear(): void {
    this.loadCareUsers();
    this.loadHealthTypes();
  }

  onPageShow(): void {
    this.loadCareUsers();
  }

  private loadHealthTypes(): void {
    const list: string[] = HealthDataManager.getHealthTypes();
    this.typeOptions = list.map((type: string) => new SelectOption(type));
    if (this.typeOptions.length > 0 && this.selectedTypeIndex >= this.typeOptions.length) {
      this.selectedTypeIndex = -1;
    }
  }

  private loadCareUsers(): void {
    const isLogin: boolean = AppStorage.get<boolean>('isLogin') === true;
    const ownerName: string = AppStorage.get<string>('userName') || '';
    if (!isLogin || !ownerName || ownerName === '未登录') {
      this.userOptions = [];
      this.selectedUserIndex = -1;
      return;
    }

    this.careStore.initKvStore(this.context)
      .then(() => this.careStore.getUsers(ownerName))
      .then((list: CareUserRecord[]) => {
        this.userOptions = list.map((item: CareUserRecord) => new SelectOption(item.name, item.id));
        if (this.userOptions.length === 0) {
          this.selectedUserIndex = -1;
        } else if (this.selectedUserIndex >= this.userOptions.length) {
          this.selectedUserIndex = 0;
        }
      })
      .catch((err: Error) => {
        console.error('读取康养用户失败:', err);
        this.userOptions = [];
        this.selectedUserIndex = -1;
      });
  }

  private buildRecord(): HealthRecord {
    const now: number = Date.now();
    const measurementTime: string = this.formatDateTime(new Date(now));
    const userName: string = this.selectedUserIndex >= 0
      ? this.userOptions[this.selectedUserIndex].value
      : '';
    const userId: string = this.selectedUserIndex >= 0 && this.userOptions[this.selectedUserIndex].id
      ? this.userOptions[this.selectedUserIndex].id as string
      : '';
    const type: string = this.selectedTypeIndex >= 0
      ? this.typeOptions[this.selectedTypeIndex].value
      : '';
    const value: string = this.valueText.trim();
    const unit: string = this.getUnitByType(type);

    return new HealthRecord(
      `${now}`,
      now,
      userId,
      userName,
      type,
      value,
      unit,
      measurementTime
    );
  }

  private getUnitByType(type: string): string {
    switch (type) {
      case '心率':
        return '次/分钟';
      case '血氧':
        return '%';
      case '体温':
        return '℃';
      case '血糖':
        return 'mmol/L';
      case '血压':
        return 'mmHg';
      case '睡眠':
        return '小时';
      case '压力':
      default:
        return '';
    }
  }

  private getSelectedUnit(): string {
    if (this.selectedTypeIndex < 0 || this.selectedTypeIndex >= this.typeOptions.length) {
      return '';
    }
    return this.getUnitByType(this.typeOptions[this.selectedTypeIndex].value);
  }

  private validateRequired(): string {
    if (this.selectedUserIndex < 0) {
      return '请选择康养用户';
    }
    if (this.selectedTypeIndex < 0) {
      return '请选择数据类型';
    }
    if (this.valueText.trim().length === 0) {
      return '请输入测量数值';
    }
    return '';
  }

  private formatDateTime(date: Date): string {
    const year: number = date.getFullYear();
    const month: number = date.getMonth() + 1;
    const day: number = date.getDate();
    const hour: number = date.getHours();
    const minute: number = date.getMinutes();
    return `${year}-${this.pad2(month)}-${this.pad2(day)} ${this.pad2(hour)}:${this.pad2(minute)}`;
  }

  private pad2(value: number): string {
    if (value < 10) {
      return `0${value}`;
    }
    return value.toString();
  }

  private submitRecord(): void {
    const isLogin: boolean = AppStorage.get<boolean>('isLogin') === true;
    const ownerName: string = AppStorage.get<string>('userName') || '';
    if (!isLogin || !ownerName || ownerName === '未登录') {
      promptAction.showDialog({
        message: '请先登录后再提交健康数据',
        buttons: [{ text: '确认', color: '#07C6A5' }]
      });
      return;
    }

    const errorMessage: string = this.validateRequired();
    if (errorMessage.length > 0) {
      promptAction.showDialog({
        message: errorMessage,
        buttons: [{ text: '确认', color: '#07C6A5' }]
      });
      return;
    }

    const record: HealthRecord = this.buildRecord();
    this.healthStore.initKvStore(this.context)
      .then(() => this.healthStore.saveRecord(ownerName, record))
      .then(() => {
        AppStorage.setOrCreate('healthDataRefresh', Date.now());
        promptAction.showDialog({
          message: '已保存健康数据',
          buttons: [{ text: '确认', color: '#07C6A5' }]
        });
        router.back();
      })
      .catch((err: Error) => {
        console.error('保存健康数据失败:', err);
        promptAction.showDialog({
          message: '保存失败，请稍后重试',
          buttons: [{ text: '确认', color: '#07C6A5' }]
        });
      });
  }

  build() {
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

        Text('新增健康数据')
          .fontSize($r('app.float.common_nav_title_font_size'))
          .fontWeight(FontWeight.Normal)
          .fontColor($r('app.color.common_nav_text_color'))
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Blank()
          .width($r('app.float.common_nav_side_width'))
      }
      .height($r('app.float.common_nav_height'))
      .width('100%')

      Column() {
        Scroll() {
          Column() {
            Column() {
              Row() {
                Text('康养用户')
                  .fontSize($r('app.float.service_body_font_size'))
                  .fontColor($r('app.color.service_primary_text_color'))
                Text('*')
                  .fontSize($r('app.float.service_body_font_size'))
                  .fontColor(0xFFE53935)
                  .margin({ left: 2 })

                Blank().layoutWeight(1)

                Select(this.userOptions)
                  .selected(this.selectedUserIndex)
                  .value(
                    this.selectedUserIndex >= 0
                      ? this.userOptions[this.selectedUserIndex].value
                      : '请选择'
                  )
                  .font({ size: $r('app.float.service_body_font_size') })
                  .fontColor($r('app.color.service_secondary_text_color'))
                  .onSelect((index: number, value: string) => {
                    this.selectedUserIndex = index;
                  })
              }
              .margin({
                left: $r('app.float.service_reservation_left_right_margin'),
                right: $r('app.float.service_reservation_left_right_margin'),
                top: $r('app.float.service_reservation_top_bottom_margin'),
                bottom: $r('app.float.service_reservation_top_bottom_margin')
              })

              Row() {
                Text('数据类型')
                  .fontSize($r('app.float.service_body_font_size'))
                  .fontColor($r('app.color.service_primary_text_color'))
                Text('*')
                  .fontSize($r('app.float.service_body_font_size'))
                  .fontColor(0xFFE53935)
                  .margin({ left: 2 })

                Blank().layoutWeight(1)

                Select(this.typeOptions)
                  .selected(this.selectedTypeIndex)
                  .value(
                    this.selectedTypeIndex >= 0
                      ? this.typeOptions[this.selectedTypeIndex].value
                      : '请选择'
                  )
                  .font({ size: $r('app.float.service_body_font_size') })
                  .fontColor($r('app.color.service_secondary_text_color'))
                  .onSelect((index: number, value: string) => {
                    this.selectedTypeIndex = index;
                  })
              }
              .margin({
                left: $r('app.float.service_reservation_left_right_margin'),
                right: $r('app.float.service_reservation_left_right_margin'),
                top: $r('app.float.service_reservation_top_bottom_margin'),
                bottom: $r('app.float.service_reservation_top_bottom_margin')
              })

              Row() {
                Text('测量数值')
                  .fontSize($r('app.float.service_body_font_size'))
                  .fontColor($r('app.color.service_primary_text_color'))
                Text('*')
                  .fontSize($r('app.float.service_body_font_size'))
                  .fontColor(0xFFE53935)
                  .margin({ left: 2 })

                Blank().layoutWeight(1)

                Row() {
                  TextInput({ placeholder: '请输入', text: this.valueText })
                    .fontSize($r('app.float.service_body_font_size'))
                    .placeholderFont({ size: $r('app.float.service_body_font_size') })
                    .placeholderColor($r('app.color.service_secondary_text_color'))
                    .textAlign(TextAlign.End)
                    .onChange((value: string) => {
                      this.valueText = value;
                    })
                    .layoutWeight(1)

                  Text(this.getSelectedUnit())
                    .fontSize($r('app.float.service_body_font_size'))
                    .fontColor($r('app.color.service_secondary_text_color'))
                    .margin({ left: 6 })
                }
                .width('70%')
                .alignItems(VerticalAlign.Center)
              }
              .margin({
                left: $r('app.float.service_reservation_left_right_margin'),
                right: $r('app.float.service_reservation_left_right_margin'),
                top: $r('app.float.service_reservation_top_bottom_margin'),
                bottom: $r('app.float.service_reservation_top_bottom_margin')
              })

              Row() {
                Text('测量时间')
                  .fontSize($r('app.float.service_body_font_size'))
                  .fontColor($r('app.color.service_primary_text_color'))

                Blank().layoutWeight(1)

                Text(this.formatDateTime(new Date()))
                  .fontSize($r('app.float.service_body_font_size'))
                  .fontColor($r('app.color.service_secondary_text_color'))
              }
              .margin({
                left: $r('app.float.service_reservation_left_right_margin'),
                right: $r('app.float.service_reservation_left_right_margin'),
                top: $r('app.float.service_reservation_top_bottom_margin'),
                bottom: $r('app.float.service_reservation_top_bottom_margin')
              })
            }
            .backgroundColor($r('app.color.service_card_background_color'))
            .borderRadius($r('app.float.service_card_radius'))
            .borderWidth($r('app.float.service_card_border_width'))
            .borderColor($r('app.color.service_card_border_color'))
            .margin({
              left: 8,
              right: 8,
              top: 8,
              bottom: 16
            })

            Blank().height(8)
          }
          .width('100%')
        }
        .width('100%')
        .layoutWeight(1)

        Column() {
          Button('保存')
            .width('80%')
            .height($r('app.float.service_button_height'))
            .backgroundColor($r('app.color.service_button_background_color'))
            .fontColor($r('app.color.service_button_text_color'))
            .fontSize($r('app.float.service_button_font_size'))
            .borderRadius($r('app.float.service_button_border_radius'))
            .onClick(() => {
              this.submitRecord();
            })
        }
        .width('100%')
        .margin({ bottom: $r('app.float.service_button_bottom_margin') })
        .justifyContent(FlexAlign.Center)
      }
      .width('100%')
      .layoutWeight(1)
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
}
