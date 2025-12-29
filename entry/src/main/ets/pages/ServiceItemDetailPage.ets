// 服务项目详情页
import router from '@ohos.router';
import type common from '@ohos.app.ability.common';
import { getDefaultServiceDetail, getServiceDetailById, loadServiceCatalog, type FeeItem, type ServiceDetail } from '../model/ServiceCatalog';

interface ServiceDetailRouteParams {
  id?: number | string;
}

@Entry
@Component
export default struct ServiceItemDetailPage {
  private context: common.UIAbilityContext = getContext() as common.UIAbilityContext;
  @State detail: ServiceDetail = getDefaultServiceDetail();

  aboutToAppear() {
    const params = router.getParams() as ServiceDetailRouteParams;
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
        console.error('服务详情加载失败:', err);
        this.detail = getDefaultServiceDetail();
      });
  }

  build() {
    Column() {
      // 顶部导肮栏
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
        Text('服务项目详情')
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
        // 可滚动内容区域
        Scroll() {
          Column() {
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

              // 卡片文字信息
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
              }
              .margin({ bottom: 8 })

              // 服务介绍
              Row() {
                Blank()
                  .width($r('app.float.service_blank_width'))
                  .height($r('app.float.service_blank_height'))
                  .backgroundColor($r('app.color.service_blank_background_color'))
                  .borderRadius($r('app.float.service_blank_border_radius'))
                  .margin({ right: $r('app.float.service_blank_right_margin') })

                Text('服务介绍')
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

              Text(this.detail.intro)
                .fontSize($r('app.float.service_body_font_size'))
                .fontColor($r('app.color.service_tertiary_text_color'))
                .margin({
                  left: $r('app.float.service_text_left_right_margin'),
                  right: $r('app.float.service_text_left_right_margin'),
                  bottom: $r('app.float.service_item_large_bottom_margin')
                })

              // 预约须知
              Row() {
                Blank()
                  .width($r('app.float.service_blank_width'))
                  .height($r('app.float.service_blank_height'))
                  .backgroundColor($r('app.color.service_blank_background_color'))
                  .borderRadius($r('app.float.service_blank_border_radius'))
                  .margin({ right: $r('app.float.service_blank_right_margin') })

                Text('预约须知')
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

              Text(this.detail.reservationNotice)
                .fontSize($r('app.float.service_body_font_size'))
                .fontColor($r('app.color.service_tertiary_text_color'))
                .margin({
                  left: $r('app.float.service_text_left_right_margin'),
                  right: $r('app.float.service_text_left_right_margin'),
                  bottom: $r('app.float.service_item_large_bottom_margin')
                })

              // 费用须知
              Row() {
                Blank()
                  .width($r('app.float.service_blank_width'))
                  .height($r('app.float.service_blank_height'))
                  .backgroundColor($r('app.color.service_blank_background_color'))
                  .borderRadius($r('app.float.service_blank_border_radius'))
                  .margin({ right: $r('app.float.service_blank_right_margin') })

                Text('费用须知')
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

              Text(this.detail.feeNotice)
                .fontSize($r('app.float.service_body_font_size'))
                .fontColor($r('app.color.service_tertiary_text_color'))
                .margin({
                  left: $r('app.float.service_text_left_right_margin'),
                  right: $r('app.float.service_text_left_right_margin'),
                  bottom: $r('app.float.service_item_large_bottom_margin')
                })

              // 费用明细
              Row() {
                Blank()
                  .width($r('app.float.service_blank_width'))
                  .height($r('app.float.service_blank_height'))
                  .backgroundColor($r('app.color.service_blank_background_color'))
                  .borderRadius($r('app.float.service_blank_border_radius'))
                  .margin({ right: $r('app.float.service_blank_right_margin') })

                Text('费用')
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

              // 各种费用
              Column() {
                ForEach(
                  this.detail.feeItems,
                  (item: FeeItem) => {
                    Row() {
                      Text(item.label)
                        .fontSize($r('app.float.service_body_font_size'))
                        .fontColor($r('app.color.service_tertiary_text_color'))
                      Blank().layoutWeight(1)
                      Text('¥ ' + item.amount.toString())
                        .fontSize($r('app.float.service_body_font_size'))
                        .fontColor($r('app.color.service_tertiary_text_color'))
                    }
                    .margin({
                      left: $r('app.float.service_text_left_right_margin'),
                      right: $r('app.float.service_text_left_right_margin'),
                      bottom: 12
                    })
                  },
                  (item: FeeItem) => item.label
                )

                // 总金额
                Row() {
                  Text('总金额')
                    .fontSize($r('app.float.service_body_font_size'))
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('app.color.service_primary_text_color'))
                  Blank().layoutWeight(1)
                  Text('¥ ' + this.detail.totalPrice.toString())
                    .fontSize($r('app.float.service_mid_emphasis_font_size'))
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('app.color.service_price_text_color'))
                }
                .margin({
                  left: $r('app.float.service_text_left_right_margin'),
                  right: $r('app.float.service_text_left_right_margin'),
                  bottom: 12
                })
              }
            }
            .backgroundColor($r('app.color.service_card_background_color'))
            .borderRadius($r('app.float.service_card_radius'))
            .borderWidth($r('app.float.service_card_border_width'))
            .borderColor($r('app.color.service_card_border_color'))
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
        .width('100%')
        .layoutWeight(1)

        // 底部“预约服务”按钮
        Row() {
          Button('预约服务')
            .width('80%')
            .height($r('app.float.service_button_height'))
            .backgroundColor($r('app.color.service_button_background_color'))
            .fontColor($r('app.color.service_button_text_color'))
            .fontSize($r('app.float.service_button_font_size'))
            .borderRadius($r('app.float.service_button_border_radius'))
            .onClick(() => {
              router.pushUrl({
                url: 'pages/ServiceReservationPage',
                params: {
                  id: this.detail.id
                }
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
