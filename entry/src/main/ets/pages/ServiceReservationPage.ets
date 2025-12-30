// 服务预约表单页
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import type common from '@ohos.app.ability.common';
import { ReservationStoreManager, type ReservationRecord } from '../utils/ReservationStoreManager';
import { CareUserStoreManager, CareUserRecord } from '../utils/CareUserStoreManager';
import { getDefaultServiceDetail, getServiceDetailById, loadServiceCatalog, type ServiceDetail } from '../model/ServiceCatalog';


class SelectOption {
  value: string;

  constructor(value: string) {
    this.value = value;
  }
}

interface ServiceReservationRouteParams {
  id?: number | string;
}

@Entry
@Component
export default struct ServiceReservationPage {
  private context: common.UIAbilityContext = getContext() as common.UIAbilityContext;
  @State detail: ServiceDetail = getDefaultServiceDetail();

  // 下拉选项：康养用户 / 看护 / 时间
  @State private userOptions: SelectOption[] = [];
  private nurseOptions: SelectOption[] = [
    new SelectOption('李梅'),
    new SelectOption('张三'),
    new SelectOption('陈芳')
  ];
  private timeOptions: SelectOption[] = [
    new SelectOption('2025-12-01 09:00'),
    new SelectOption('2025-12-01 14:00'),
    new SelectOption('2025-12-02 09:00')
  ];
  // 选中索引（-1 表示未选择）
  @State selectedUserIndex: number = -1;
  @State selectedNurseIndex: number = -1;
  @State selectedTimeIndex: number = -1;
  // 文本输入状态
  @State contactName: string = '';
  @State contactPhone: string = '';
  @State address: string = '';
  @State remark: string = '';

  aboutToAppear() {
    const params = router.getParams() as ServiceReservationRouteParams;
    let serviceId: number = 0;
    if (params && typeof params.id === 'number') {
      serviceId = params.id;
    } else if (params && typeof params.id === 'string') {
      const parsedId = Number(params.id);
      if (parsedId === parsedId) {
        serviceId = parsedId;
      }
    }
    loadServiceCatalog(this.context)
      .then((list: ServiceDetail[]) => {
        this.detail = getServiceDetailById(list, serviceId);
      })
      .catch((err: Error) => {
        console.error('预约服务加载失败:', err);
        this.detail = getDefaultServiceDetail();
      });

    this.loadCareUsers();
  }

  onPageShow(): void {
    // 返回页面时刷新康养用户列表
    this.loadCareUsers();
  }

  private loadCareUsers(): void {
    // 仅加载当前登录用户的康养用户列表
    const isLogin: boolean = AppStorage.get<boolean>('isLogin') === true;
    const ownerName: string = AppStorage.get<string>('userName') || '';
    if (!isLogin || !ownerName || ownerName === '未登录') {
      this.userOptions = [];
      this.selectedUserIndex = -1;
      return;
    }
    CareUserStoreManager.getInstance().initKvStore(this.context)
      .then(() => CareUserStoreManager.getInstance().getUsers(ownerName))
      .then((list: CareUserRecord[]) => {
        // 将康养用户转换为下拉选项
        this.userOptions = list.map((item: CareUserRecord) => {
          return new SelectOption(`${item.name}`);
        });
        if (this.userOptions.length === 0) {
          this.selectedUserIndex = -1;
        } else if (this.selectedUserIndex >= this.userOptions.length) {
          this.selectedUserIndex = -1;
        }
      })
      .catch((err: Error) => {
        console.error('读取康养用户失败:', err);
        this.userOptions = [];
        this.selectedUserIndex = -1;
      });
  }

  build() {
    Column() {
      // 顶部标题栏：返回 + 标题（标题真正居中）
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
        Text('服务预约')
          .fontSize($r('app.float.common_nav_title_font_size'))
          .fontWeight(FontWeight.Normal)
          .fontColor($r('app.color.common_nav_text_color'))
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        // 右：占位（与左边同宽，保证标题居中）
        Blank()
          .width($r('app.float.common_nav_side_width'))
      }
      .height($r('app.float.common_nav_height'))
      .width('100%')
      .alignItems(VerticalAlign.Center)

      // 中间内容 + 底部按钮
      Column() {
        // 可滚动区域
        Scroll() {
          Column() {
            // 顶部服务信息卡片
            Column() {
              // 顶部图片
              Image(this.detail.image)
                .width('100%')
                .objectFit(ImageFit.Cover)
                .padding({
                  left: $r('app.float.service_image_space'),
                  right: $r('app.float.service_image_space'),
                  top: $r('app.float.service_image_space'),
                  bottom: $r('app.float.service_image_space')
                })
                .clip(true)
                .borderRadius($r('app.float.service_card_radius'))

              // 文字信息
              Column() {
                Text(this.detail.title)
                  .fontSize($r('app.float.service_card_title_font_size'))
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('app.color.service_primary_text_color'))
                  .margin({
                    left: $r('app.float.service_text_left_right_margin'),
                    right: $r('app.float.service_text_left_right_margin'),
                    bottom: $r('app.float.service_text_bottom_margin')
                  })
                  .alignSelf(ItemAlign.Start)

                // 服务机构
                Row() {
                  Text('服务机构')
                    .fontSize($r('app.float.service_body_font_size'))
                    .fontColor($r('app.color.service_secondary_text_color'))

                  Blank().layoutWeight(1)

                  Text(this.detail.orgName)
                    .fontSize($r('app.float.service_body_font_size'))
                    .fontColor($r('app.color.service_primary_text_color'))
                }
                .margin({
                  left: $r('app.float.service_text_left_right_margin'),
                  right: $r('app.float.service_text_left_right_margin'),
                  bottom: $r('app.float.service_text_bottom_margin')
                })

                // 服务类型
                Row() {
                  Text('服务类型')
                    .fontSize($r('app.float.service_body_font_size'))
                    .fontColor($r('app.color.service_secondary_text_color'))

                  Blank().layoutWeight(1)

                  Text(this.detail.typeName)
                    .fontSize($r('app.float.service_body_font_size'))
                    .fontColor($r('app.color.service_primary_text_color'))
                }
                .margin({
                  left: $r('app.float.service_text_left_right_margin'),
                  right: $r('app.float.service_text_left_right_margin'),
                  bottom: $r('app.float.service_text_bottom_margin')
                })

                // 服务价格
                Row() {
                  Text('服务价格')
                    .fontSize($r('app.float.service_body_font_size'))
                    .fontColor($r('app.color.service_secondary_text_color'))

                  Blank().layoutWeight(1)

                  Text('¥ ' + this.detail.price.toString())
                    .fontSize($r('app.float.service_emphasis_font_size'))
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('app.color.service_price_text_color')) // 示例中的橙色
                }
                .margin({
                  left: $r('app.float.service_text_left_right_margin'),
                  right: $r('app.float.service_text_left_right_margin'),
                  bottom: $r('app.float.service_text_bottom_margin')
                })
              }
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

            // 预约信息表单卡片
            Column() {
              // 标题
              Row() {
                Text('预约信息')
                  .fontSize($r('app.float.service_card_title_font_size'))
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('app.color.service_primary_text_color'))
              }
              .alignSelf(ItemAlign.Start)
              .margin({
                left: $r('app.float.service_reservation_left_right_margin'),
                right: $r('app.float.service_reservation_left_right_margin'),
                top: $r('app.float.service_reservation_top_bottom_margin'),
                bottom: $r('app.float.service_reservation_top_bottom_margin')
              })

              // 康养用户（下拉，必填）
              Row() {
                Row() {
                  Text('康养用户')
                    .fontSize($r('app.float.service_body_font_size'))
                    .fontColor($r('app.color.service_primary_text_color'))
                  Text('*')
                    .fontSize($r('app.float.service_body_font_size'))
                    .fontColor($r('app.color.service_required_mark_color'))
                    .margin({ left: 2 })
                }

                Blank().layoutWeight(1)

                Select(this.userOptions)
                  .selected(this.selectedUserIndex)
                  .value(
                    this.selectedUserIndex >= 0
                      ? this.userOptions[this.selectedUserIndex].value
                      : '请选择康养用户'
                  )
                  .font({ size: $r('app.float.service_body_font_size') })
                  .fontColor($r('app.color.service_secondary_text_color'))
                  // 注意：onSelect 第二个参数是 string，而不是 SelectOption
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
              .alignItems(VerticalAlign.Center)

              // 看护名称（下拉，必填）
              Row() {
                Row() {
                  Text('看护名称')
                    .fontSize($r('app.float.service_body_font_size'))
                    .fontColor($r('app.color.service_primary_text_color'))
                  Text('*')
                    .fontSize($r('app.float.service_body_font_size'))
                    .fontColor($r('app.color.service_required_mark_color'))
                    .margin({ left: 2 })
                }

                Blank().layoutWeight(1)

                Select(this.nurseOptions)
                  .selected(this.selectedNurseIndex)
                  .font({ size: $r('app.float.service_body_font_size') })
                  .fontColor($r('app.color.service_secondary_text_color'))
                  .value(
                    this.selectedNurseIndex >= 0
                      ? this.nurseOptions[this.selectedNurseIndex].value
                      : '请选择看护'
                  )
                  .onSelect((index: number, value: string) => {
                    this.selectedNurseIndex = index;
                  })
              }
              .margin({
                left: $r('app.float.service_reservation_left_right_margin'),
                right: $r('app.float.service_reservation_left_right_margin'),
                top: $r('app.float.service_reservation_top_bottom_margin'),
                bottom: $r('app.float.service_reservation_top_bottom_margin')
              })
              .alignItems(VerticalAlign.Center)

              // 预约时间（下拉，必填）
              Row() {
                Row() {
                  Text('预约时间')
                    .fontSize($r('app.float.service_body_font_size'))
                    .fontColor($r('app.color.service_primary_text_color'))
                  Text('*')
                    .fontSize($r('app.float.service_body_font_size'))
                    .fontColor($r('app.color.service_required_mark_color'))
                    .margin({ left: 2 })
                }

                Blank().layoutWeight(1)

                Select(this.timeOptions)
                  .selected(this.selectedTimeIndex)
                  .font({ size: $r('app.float.service_body_font_size') })
                  .fontColor($r('app.color.service_secondary_text_color'))
                  .value(
                    this.selectedTimeIndex >= 0
                      ? this.timeOptions[this.selectedTimeIndex].value
                      : '请选择预约时间'
                  )
                  .onSelect((index: number, value: string) => {
                    this.selectedTimeIndex = index;
                  })
              }
              .margin({
                left: $r('app.float.service_reservation_left_right_margin'),
                right: $r('app.float.service_reservation_left_right_margin'),
                top: $r('app.float.service_reservation_top_bottom_margin'),
                bottom: $r('app.float.service_reservation_top_bottom_margin')
              })
              .alignItems(VerticalAlign.Center)

              // 联系人（必填）
              Row() {
                Row() {
                  Text('联系人')
                    .fontSize($r('app.float.service_body_font_size'))
                    .fontColor($r('app.color.service_primary_text_color'))
                  Text('*')
                    .fontSize($r('app.float.service_body_font_size'))
                    .fontColor($r('app.color.service_required_mark_color'))
                    .margin({ left: 2 })
                }

                Blank().layoutWeight(1)

                TextInput({ placeholder: '请输入联系人姓名', text: this.contactName })
                  .fontSize($r('app.float.service_body_font_size'))
                  .placeholderFont({ size: $r('app.float.service_body_font_size') })
                  .placeholderColor($r('app.color.service_secondary_text_color'))
                  .textAlign(TextAlign.End)
                  .onChange((value: string) => {
                    this.contactName = value;
                  })
                  .width('70%')
              }
              .margin({
                left: $r('app.float.service_reservation_left_right_margin'),
                right: $r('app.float.service_reservation_left_right_margin'),
                top: $r('app.float.service_reservation_top_bottom_margin'),
                bottom: $r('app.float.service_reservation_top_bottom_margin')
              })
              .alignItems(VerticalAlign.Center)

              // 手机号码（11 位，必填）
              Row() {
                Row() {
                  Text('手机号码')
                    .fontSize($r('app.float.service_body_font_size'))
                    .fontColor($r('app.color.service_primary_text_color'))
                  Text('*')
                    .fontSize($r('app.float.service_body_font_size'))
                    .fontColor($r('app.color.service_required_mark_color'))
                    .margin({ left: 2 })
                }

                Blank().layoutWeight(1)

                TextInput({ placeholder: '请输入手机号码', text: this.contactPhone })
                  .fontSize($r('app.float.service_body_font_size'))
                  .placeholderFont({ size: $r('app.float.service_body_font_size') })
                  .placeholderColor($r('app.color.service_secondary_text_color'))
                  .textAlign(TextAlign.End)
                  .onChange((value: string) => {
                    this.contactPhone = value;
                  })
                  .width('70%')
              }
              .margin({
                left: $r('app.float.service_reservation_left_right_margin'),
                right: $r('app.float.service_reservation_left_right_margin'),
                top: $r('app.float.service_reservation_top_bottom_margin'),
                bottom: $r('app.float.service_reservation_top_bottom_margin')
              })
              .alignItems(VerticalAlign.Center)

              // 地址（必填）
              Row() {
                Row() {
                  Text('地址')
                    .fontSize($r('app.float.service_body_font_size'))
                    .fontColor($r('app.color.service_primary_text_color'))
                  Text('*')
                    .fontSize($r('app.float.service_body_font_size'))
                    .fontColor($r('app.color.service_required_mark_color'))
                    .margin({ left: 2 })
                }

                Blank().layoutWeight(1)

                TextInput({ placeholder: '请输入详细地址', text: this.address })
                  .fontSize($r('app.float.service_body_font_size'))
                  .textAlign(TextAlign.End)
                  .placeholderFont({ size: $r('app.float.service_body_font_size') })
                  .placeholderColor($r('app.color.service_secondary_text_color'))
                  .onChange((value: string) => {
                    this.address = value;
                  })
                  .width('70%')
              }
              .margin({
                left: $r('app.float.service_reservation_left_right_margin'),
                right: $r('app.float.service_reservation_left_right_margin'),
                top: $r('app.float.service_reservation_top_bottom_margin'),
                bottom: $r('app.float.service_reservation_top_bottom_margin')
              })
              .alignItems(VerticalAlign.Center)

              // 备注（选填）
              Row() {
                Text('备注')
                  .fontSize($r('app.float.service_body_font_size'))
                  .fontColor($r('app.color.service_primary_text_color'))

                Blank().layoutWeight(1)

                TextInput({ placeholder: '可填写特殊需求', text: this.remark })
                  .fontSize($r('app.float.service_body_font_size'))
                  .textAlign(TextAlign.End)
                  .placeholderFont({ size: $r('app.float.service_body_font_size') })
                  .placeholderColor($r('app.color.service_secondary_text_color'))
                  .onChange((value: string) => {
                    this.remark = value;
                  })
                  .width('70%')
              }
              .margin({
                left: $r('app.float.service_reservation_left_right_margin'),
                right: $r('app.float.service_reservation_left_right_margin'),
                top: $r('app.float.service_reservation_top_bottom_margin'),
                bottom: $r('app.float.service_reservation_top_bottom_margin')
              })
              .alignItems(VerticalAlign.Center)
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

        // 底部“预约下单”按钮
        Column() {
          Button('预约下单')
            .width('80%')
            .height($r('app.float.service_button_height'))
            .backgroundColor($r('app.color.service_button_background_color'))
            .fontColor($r('app.color.service_button_text_color'))
            .fontSize($r('app.float.service_button_font_size'))
            .borderRadius($r('app.float.service_button_border_radius'))
            .onClick(() => {
              // 表单校验：必填项与手机号长度要求
              const showValidation = (message: string): void => {
                promptAction.showDialog({
                  message: message,
                  buttons: [
                    {
                      text: '确认',
                      color: '#07C6A5'
                    }
                  ]
                });
              };

              const contactName = this.contactName.trim();
              const contactPhone = this.contactPhone.trim();
              const address = this.address.trim();

              if (this.selectedUserIndex < 0) {
                showValidation('请选择康养用户');
                return;
              }
              if (this.selectedNurseIndex < 0) {
                showValidation('请选择看护名称');
                return;
              }
              if (this.selectedTimeIndex < 0) {
                showValidation('请选择预约时间');
                return;
              }
              if (!contactName) {
                showValidation('请输入联系人');
                return;
              }
              if (!contactPhone) {
                showValidation('请输入手机号码');
                return;
              }
              if (contactPhone.length !== 11) {
                showValidation('手机号需为 11 位');
                return;
              }
              if (!address) {
                showValidation('请输入地址');
                return;
              }

              // 保存预约订单到本地KvStore（按登录用户前缀区分）
              const isLogin: boolean = AppStorage.get<boolean>('isLogin') === true;
              const ownerName: string = AppStorage.get<string>('userName') || '';
              if (!isLogin || !ownerName || ownerName === '未登录') {
                // 未登录不允许下单
                showValidation('请先登录后再下单');
                return;
              }
              const now: number = Date.now();
              const record: ReservationRecord = {
                id: `${now}`,
                submitTime: now,
                serviceType: this.detail.typeName,
                status: '待服务',
                orderNo: `kh_${now}`,
                price: this.detail.price,
                serviceUser: this.selectedUserIndex >= 0 ? this.userOptions[this.selectedUserIndex].value : '',
                nurseName: this.selectedNurseIndex >= 0 ? this.nurseOptions[this.selectedNurseIndex].value : '',
                serviceTime: this.selectedTimeIndex >= 0 ? this.timeOptions[this.selectedTimeIndex].value : '',
                contactName: contactName,
                contactPhone: contactPhone,
                address: address,
                remark: this.remark
              };

              ReservationStoreManager.getInstance().initKvStore(this.context)
                // .then(() => ReservationStoreManager.getInstance().saveReservation(record)) // 旧逻辑：未区分登录用户
                .then(() => ReservationStoreManager.getInstance().saveReservation(ownerName, record))
                .then(() => {
                  // 弹出确认框提示保存成功
                  promptAction.showDialog({
                    message: '已成功下单',
                    buttons: [
                      {
                        text: '确认',
                        color: '#07C6A5'
                      }
                    ]
                  });
                })
                .catch((err: Error) => {
                  console.error('下单失败:', err);
                });
            })

          // 清空已保存订单
          Button('清空已保存订单')
            .width('80%')
            .height($r('app.float.service_button_height'))
            .backgroundColor($r('app.color.service_button_background_color'))
            .fontColor($r('app.color.service_button_text_color'))
            .fontSize($r('app.float.service_button_font_size'))
            .borderRadius($r('app.float.service_button_border_radius'))
            .margin({ top: 12 })
            .onClick(() => {
              const isLogin: boolean = AppStorage.get<boolean>('isLogin') === true;
              const ownerName: string = AppStorage.get<string>('userName') || '';
              if (!isLogin || !ownerName || ownerName === '未登录') {
                // 未登录不允许清空订单
                promptAction.showDialog({
                  message: '请先登录后再清空订单',
                  buttons: [
                    {
                      text: '确认',
                      color: '#07C6A5'
                    }
                  ]
                });
                return;
              }
              ReservationStoreManager.getInstance().initKvStore(this.context)
                // .then(() => ReservationStoreManager.getInstance().clearReservations()) // 旧逻辑：清空全部用户订单
                .then(() => ReservationStoreManager.getInstance().clearReservations(ownerName))
                .then(() => {
                  promptAction.showDialog({
                    message: '已清空已保存订单',
                    buttons: [
                      {
                        text: '确认',
                        color: '#07C6A5'
                      }
                    ]
                  });
                })
                .catch((err: Error) => {
                  promptAction.showDialog({
                    title: '提示',
                    message: `清空订单失败：${err?.message ?? '未知错误'}`
                  });
                  console.error('清空订单失败:', err);
                });
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
