import router from '@ohos.router';
import type common from '@ohos.app.ability.common';
import { ReservationStoreManager, type ReservationRecord } from '../utils/ReservationStoreManager';
import { getDefaultServiceDetail, loadServiceCatalog, type FeeItem, type ServiceDetail } from '../model/ServiceCatalog';

// 路由参数结构：支持传入订单 id 或完整订单对象
interface ServiceOrderRouteParams {
  id?: string | number;
  order?: ReservationRecord;
}

// 空订单默认值，避免首次渲染时字段为 undefined
const DEFAULT_ORDER: ReservationRecord = {
  id: '',
  submitTime: 0,
  serviceType: '',
  status: '',
  orderNo: '',
  price: 0,
  serviceUser: '',
  nurseName: '',
  serviceTime: '',
  contactName: '',
  contactPhone: '',
  address: '',
  remark: ''
};

// 无法从订单或服务目录获取的静态信息
const STATIC_NURSE_PHONE = '13620240001';
const STATIC_DEPT_NAME = '25';

@Entry
@Component
export default struct ServiceOrderDetailPage {
  // Ability 上下文，用于读取 KvStore 与资源
  private context: common.UIAbilityContext = getContext() as common.UIAbilityContext;
  // 当前 Tab 索引
  @State currentIndex: number = 0;
  // 当前订单数据
  @State order: ReservationRecord = DEFAULT_ORDER;
  // 当前服务详情（来自服务目录）
  @State serviceDetail: ServiceDetail = getDefaultServiceDetail();

  aboutToAppear(): void {
    this.loadOrderDetail();
  }

  // 读取路由参数并加载订单详情
  private loadOrderDetail(): void {
    const params = router.getParams() as ServiceOrderRouteParams;
    if (params && params.order) {
      // 详情页直接拿到订单对象时，无需再次查询
      this.setOrder(params.order as ReservationRecord);
      return;
    }

    // 若仅传入 id，则从 KvStore 查找订单
    let targetId: string = '';
    if (params && typeof params.id === 'string') {
      targetId = params.id;
    } else if (params && typeof params.id === 'number') {
      targetId = String(params.id);
    }
    if (!targetId) {
      this.setOrder(DEFAULT_ORDER);
      return;
    }

    // 未登录时不读取用户订单
    const isLogin: boolean = AppStorage.get<boolean>('isLogin') === true;
    const ownerName: string = AppStorage.get<string>('userName') || '';
    if (!isLogin || !ownerName || ownerName === '未登录') {
      this.setOrder(DEFAULT_ORDER);
      return;
    }

    ReservationStoreManager.getInstance().initKvStore(this.context)
      // .then(() => ReservationStoreManager.getInstance().getReservations()) // 旧逻辑：读取全部用户订单
      .then(() => ReservationStoreManager.getInstance().getReservations(ownerName))
      .then((list: ReservationRecord[]) => {
        const matched = this.findOrderById(list, targetId);
        this.setOrder(matched ? matched : DEFAULT_ORDER);
      })
      .catch((err: Error) => {
        console.error('读取订单详情失败:', err);
        this.setOrder(DEFAULT_ORDER);
      });
  }

  // 写入订单并同步加载服务详情
  private setOrder(order: ReservationRecord): void {
    this.order = order;
    this.loadServiceDetail(order.serviceType);
  }

  // 根据 id 查找订单
  private findOrderById(list: ReservationRecord[], id: string): ReservationRecord | null {
    for (let i: number = 0; i < list.length; i++) {
      if (list[i].id === id) {
        return list[i];
      }
    }
    return null;
  }

  // 根据服务类型加载服务详情
  private loadServiceDetail(serviceType: string): void {
    if (!serviceType) {
      this.serviceDetail = getDefaultServiceDetail();
      return;
    }
    loadServiceCatalog(this.context)
      .then((list: ServiceDetail[]) => {
        this.serviceDetail = this.findServiceDetail(list, serviceType);
      })
      .catch((err: Error) => {
        console.error('读取服务详情失败:', err);
        this.serviceDetail = getDefaultServiceDetail();
      });
  }

  // 在服务目录中查找匹配的详情
  private findServiceDetail(list: ServiceDetail[], serviceType: string): ServiceDetail {
    for (let i: number = 0; i < list.length; i++) {
      const item = list[i];
      if (item.typeName === serviceType || item.title === serviceType) {
        return item;
      }
    }
    return getDefaultServiceDetail();
  }

  build() {
    Column() {
      /** ---------- 顶部导航栏 ---------- */
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

        Text('服务订单详情')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .fontSize($r('app.float.common_nav_title_font_size'))
          .fontColor($r('app.color.common_nav_text_color'))

        Blank().width($r('app.float.common_nav_side_width'))
      }
      .height($r('app.float.common_nav_height'))

      /** ---------- Tab 区域 ---------- */
      Column() {
        Tabs({ index: this.currentIndex }) {
          TabContent() {
            this.ServiceIntroTab();
          }.tabBar(this.TabTitle('服务介绍', 0))

          TabContent() {
            this.CareInfoTab();
          }.tabBar(this.TabTitle('看护信息', 1))

          TabContent() {
            this.ServiceRecordTab();
          }.tabBar(this.TabTitle('服务记录', 2))

          TabContent() {
            this.RehabAssessmentTab();
          }.tabBar(this.TabTitle('康复评估', 3))
        }
        .onChange(index => this.currentIndex = index)
        .barMode(BarMode.Fixed)
        .barHeight(48)
        .width('100%')
        .layoutWeight(1)
      }
      .backgroundColor($r('app.color.service_card_background_color'))
      .borderRadius($r('app.float.service_card_radius'))
      .borderWidth($r('app.float.service_card_border_width'))
      .borderColor($r('app.color.service_card_border_color'))
      .margin({
        left: $r('app.float.service_detail_card_space'),
        right: $r('app.float.service_detail_card_space'),
        top: $r('app.float.service_detail_card_space')
      })
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
    .expandSafeArea(
      [SafeAreaType.SYSTEM],
      [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]
    )
  }

  /** ---------- Tab 标题（绿色选中态） ---------- */
  @Builder
  TabTitle(title: string, index: number) {
    Column() {
      Text(title)
        .fontSize($r('app.float.service_body_font_size'))
        .fontColor(
          this.currentIndex === index
            ? $r('app.color.service_button_background_color')
            : $r('app.color.service_secondary_text_color')
        )

      if (this.currentIndex === index) {
        Blank()
          .height(2)
          .width(24)
          .backgroundColor($r('app.color.service_button_background_color'))
          .margin({ top: 4 })
      }
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  /** ---------- 公共行：左标题 / 右内容 ---------- */
  @Builder
  InfoRow(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize($r('app.float.service_body_font_size'))
        .fontColor($r('app.color.service_secondary_text_color'))

      Blank().layoutWeight(1)

      Text(value)
        .fontSize($r('app.float.service_body_font_size'))
        .fontColor($r('app.color.service_primary_text_color'))
    }
    .margin({
      left: $r('app.float.service_text_left_right_margin'),
      right: $r('app.float.service_text_left_right_margin'),
      bottom: $r('app.float.service_text_bottom_margin')
    })
  }

  /** ---------- 服务介绍 Tab（动态渲染） ---------- */
  @Builder
  ServiceIntroTab() {
    Scroll() {
      Column() {
        Column() {
          Row() {
            Text(this.order.serviceType)
              .fontSize($r('app.float.service_card_title_font_size'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.service_primary_text_color'))

            Blank().layoutWeight(1)

            Text(this.order.status)
              .fontSize($r('app.float.service_body_font_size'))
              .fontColor($r('app.color.service_secondary_text_color'))
          }
          .margin({
            left: $r('app.float.service_text_left_right_margin'),
            right: $r('app.float.service_text_left_right_margin'),
            bottom: $r('app.float.service_item_large_bottom_margin')
          })

          Column() {
            this.InfoRow('被看护人', this.order.serviceUser)
            this.InfoRow('服务单号', this.order.orderNo)
            this.InfoRow('预约时间', this.order.serviceTime)
            this.InfoRow('联系电话', this.order.contactPhone)
            this.InfoRow('联系地址', this.order.address)
            this.InfoRow('服务机构', this.serviceDetail.orgName)
            this.InfoRow('服务类型', this.order.serviceType)
          }
          .margin({
            bottom: $r('app.float.service_item_large_bottom_margin')
          })

          Column() {
            SectionTitle('服务介绍')
            SectionText(this.serviceDetail.intro)
          }
          .margin({
            bottom: $r('app.float.service_item_large_bottom_margin')
          })

          Column() {
            SectionTitle('预约须知')
            SectionText(this.serviceDetail.reservationNotice)
          }
          .margin({
            bottom: $r('app.float.service_item_large_bottom_margin')
          })

          Column() {
            SectionTitle('费用须知')
            SectionText(this.serviceDetail.feeNotice)
          }
          .margin({
            bottom: $r('app.float.service_item_large_bottom_margin')
          })

          Column() {
            SectionTitle('费用')

            ForEach(
              this.serviceDetail.feeItems,
              (item: FeeItem) => {
                this.InfoRow(item.label, '¥ ' + item.amount.toString())
              },
              (item: FeeItem) => item.label
            )

            Row() {
              Text('总金额')
                .fontWeight(FontWeight.Medium)
              Blank().layoutWeight(1)
              Text('¥ ' + this.serviceDetail.totalPrice.toString())
                .fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.service_price_text_color'))
            }
            .margin({
              left: $r('app.float.service_text_left_right_margin'),
              right: $r('app.float.service_text_left_right_margin'),
              bottom: $r('app.float.service_item_large_bottom_margin')
            })
          }
          .margin({
            bottom: $r('app.float.service_item_large_bottom_margin')
          })
        }
        .backgroundColor($r('app.color.service_card_background_color'))
        .margin({
          left: $r('app.float.service_detail_card_space'),
          right: $r('app.float.service_detail_card_space'),
          top: $r('app.float.service_detail_card_space'),
          bottom: $r('app.float.service_detail_card_space')
        })

        Blank().height(8)
      }
      .width('100%')
    }
  }

  /** ---------- 看护信息 Tab（动态渲染） ---------- */
  @Builder
  CareInfoTab() {
    Scroll() {
      Column() {
        Column() {
          Row() {
            Text(this.order.nurseName)
              .fontSize($r('app.float.service_card_title_font_size'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.service_primary_text_color'))
          }
          .alignSelf(ItemAlign.Start)
          .margin({
            left: $r('app.float.service_text_left_right_margin'),
            right: $r('app.float.service_text_left_right_margin'),
            bottom: $r('app.float.service_item_large_bottom_margin')
          })

          Column() {
            this.InfoRow('看护名称', this.order.nurseName)
            this.InfoRow('看护电话', STATIC_NURSE_PHONE)
            this.InfoRow('机构名称', this.serviceDetail.orgName)
            this.InfoRow('部门名称', STATIC_DEPT_NAME)
          }
          .margin({
            bottom: $r('app.float.service_item_large_bottom_margin')
          })
        }
        .backgroundColor($r('app.color.service_card_background_color'))
        .margin({
          left: $r('app.float.service_detail_card_space'),
          right: $r('app.float.service_detail_card_space'),
          top: $r('app.float.service_detail_card_space'),
          bottom: $r('app.float.service_detail_card_space')
        })

        Blank().height(8)
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Start)
    }
  }

  /** ---------- 服务记录 Tab ---------- */
  @Builder
  ServiceRecordTab() {
    Scroll() {
      Column() {
        Column() {
          Text('未上传服务记录')
            .fontSize($r('app.float.service_body_font_size'))
            .fontColor($r('app.color.service_secondary_text_color'))
        }
        .backgroundColor($r('app.color.service_card_background_color'))
        .margin({
          left: $r('app.float.service_detail_card_space'),
          right: $r('app.float.service_detail_card_space'),
          top: $r('app.float.service_detail_card_space'),
          bottom: $r('app.float.service_detail_card_space')
        })
        .alignSelf(ItemAlign.Center)

        Blank().height(8)
      }
      .width('100%')
    }
  }

  /** ---------- 康复评估 Tab ---------- */
  @Builder
  RehabAssessmentTab() {
    Scroll() {
      Column() {
        Column() {
          this.InfoRow('有无心血管疾病？', '无')
          this.InfoRow('有无心血管疾病家族史？', '无')
          this.InfoRow('有无糖尿病？', '无')
          this.InfoRow('有无吸烟？', '无')
          this.InfoRow('身高（cm）', '170')
          this.InfoRow('体重（kg）', '70')
          this.InfoRow('血压水平', '80-110')
          this.InfoRow('血脂水平', '10 / 10 / 10')
          this.InfoRow('体育锻炼情况', '无')
          this.InfoRow('康复情况评估', '康复情况良好')
        }
        .backgroundColor($r('app.color.service_card_background_color'))
        .margin({
          left: $r('app.float.service_detail_card_space'),
          right: $r('app.float.service_detail_card_space'),
          top: $r('app.float.service_item_large_bottom_margin'),
          bottom: $r('app.float.service_detail_card_space')
        })

        Blank().height(8)
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Start)
    }
  }
}

// SectionTitle 和 SectionText
@Builder
function SectionTitle(title: string) {
  Row() {
    Blank()
      .width($r('app.float.service_blank_width'))
      .height($r('app.float.service_blank_height'))
      .backgroundColor($r('app.color.service_blank_background_color'))
      .borderRadius($r('app.float.service_blank_border_radius'))
      .margin({ right: $r('app.float.service_blank_right_margin') })

    Text(title)
      .fontSize($r('app.float.service_body_font_size'))
      .fontWeight(FontWeight.Medium)
      .fontColor($r('app.color.service_primary_text_color'))
  }
  .alignSelf(ItemAlign.Start)
  .margin({
    left: $r('app.float.service_text_left_right_margin'),
    right: $r('app.float.service_text_left_right_margin'),
    bottom: $r('app.float.service_item_small_bottom_margin')
  })
}

@Builder
function SectionText(title: string) {
  Row() {
    Text(title)
      .fontSize($r('app.float.service_body_font_size'))
      .fontColor($r('app.color.service_tertiary_text_color'))
      .margin({
        left: $r('app.float.service_text_left_right_margin'),
        right: $r('app.float.service_text_left_right_margin'),
        top: $r('app.float.service_reservation_top_bottom_margin'),
        bottom: $r('app.float.service_item_large_bottom_margin')
      })
  }
  .width('100%')
  .justifyContent(FlexAlign.SpaceBetween)
}
