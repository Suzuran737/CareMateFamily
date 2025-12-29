import router from '@ohos.router';
import { PullToRefresh } from '../components/PullToRefresh';
import { getHealthEduList, type HealthEduItem } from '../model/HealthEduCatalog';

/**
 * 首页功能入口小组件
 * - 用于展示首页四个功能入口（图标 + 文案）
 */
@Component
struct HomeFunctionItem {
  @Prop label: string;
  @Prop icon: Resource;

  build() {
    Column() {
      // 图标区域
      Image(this.icon)
        .width($r('app.float.home_function_icon_size'))
        .height($r('app.float.home_function_icon_size'))
        .borderRadius($r('app.float.home_function_icon_radius'))
        .objectFit(ImageFit.Cover)
        .backgroundColor(0xFF2EC7A8)

      // 文案区域
      Text(this.label)
        .fontSize($r('app.float.home_function_text_font_size'))
        .fontColor(0xFF333333)
        .margin({ top: $r('app.float.home_function_text_top_margin') })
        .textAlign(TextAlign.Center)
    }
    .alignItems(HorizontalAlign.Center)
  }
}

/**
 * 健康宣教卡片组件
 */
@Component
struct HealthEduCard {
  @Prop img: Resource;   // 宣教图片资源
  @Prop title: string;   // 宣教标题

  build() {
    Column() {
      // 上方图片
      Image(this.img)
        .width('100%')

      // 下方标题（图标 + 文案）
      Row() {
        Image($r('app.media.ic_health_edu_tag'))
          .width(20)
          .height(20)
          .fillColor(0xFF1FAF8F)
          .margin({ left : 4 , right: 10 })

        Text(this.title)
          .fontSize($r('app.float.home_health_card_title_font_size'))
          .fontColor(0xFF333333)
      }
      .width('100%')
      .margin({
        left: $r('app.float.home_health_card_title_left_margin'),
        top: $r('app.float.home_health_card_title_top_margin'),
        bottom: $r('app.float.home_health_card_title_bottom_margin')
      })
      .alignItems(VerticalAlign.Center)
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
}


/**
 * 首页 Tab 页面
 */
@Component
export default struct HomeTab {
  // 下拉刷新状态，由 PullToRefresh 在下拉触发时改为 true，onRefreshingChanged() 执行刷新逻辑后再改回 false（结束刷新动画）
  @State @Watch('onRefreshingChanged') isRefreshing: boolean = false;

  @State healthEduList: HealthEduItem[] = getHealthEduList();

  //打乱健康宣教列表顺序
  private shuffleHealthEduList(): void {
    // 记录旧顺序（仅用于判断是否完全没变化）
    const oldIds: number[] = this.healthEduList.map((it: HealthEduItem) => it.id);

    // 复制一份新数组，避免原地修改导致渲染复用不明显
    const list: HealthEduItem[] = this.healthEduList.slice();

    // Fisher–Yates shuffle：从后往前随机交换
    for (let i: number = list.length - 1; i > 0; i--) {
      const j: number = Math.floor(Math.random() * (i + 1));
      const temp: HealthEduItem = list[i];
      list[i] = list[j];
      list[j] = temp;
    }

    // 判断是否完全一致
    const newIds: number[] = list.map((it: HealthEduItem) => it.id);
    let same: boolean = true;
    for (let k: number = 0; k < oldIds.length; k++) {
      if (oldIds[k] !== newIds[k]) {
        same = false;
        break;
      }
    }

    // 若完全一致，则强制交换前两项，确保刷新结果可见
    if (same && list.length >= 2) {
      const t: HealthEduItem = list[0];
      list[0] = list[1];
      list[1] = t;
    }

    // 更新状态：赋新引用触发重新渲染
    this.healthEduList = list;
  }

  // 监听刷新状态变化
  private onRefreshingChanged(): void {
    if (!this.isRefreshing) {
      return;
    }

    // 刷新逻辑：打乱健康宣教展示顺序
    this.shuffleHealthEduList();

    // 延迟收起刷新头，避免刷新动画一闪而过
    setTimeout((): void => {
      this.isRefreshing = false;
    }, 500);
  }

  //首页主体内容 Builder
  @Builder
  private buildHomeContent(): void {
    Scroll() {
      Column() {
        // 1. 顶部标题栏
        Row() {
          Text('首页')
            .fontSize($r('app.float.home_header_title_font_size'))
            .fontWeight(FontWeight.Normal)
            .fontColor(0xFFFFFFFF)
        }
        .height($r('app.float.home_header_height'))
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)

        // 2. Banner 区域（静态资源展示）
        Image($r('app.media.home_banner'))
          .width('100%')
          .margin({ top: $r('app.float.home_banner_top_margin') })
          .objectFit(ImageFit.Cover)

        // 3. 四个功能入口卡片区域
        Column() {
          Row() {
            // 问诊记录
            Column() {
              HomeFunctionItem({
                label: '问诊记录',
                icon: $r('app.media.home_icon1')
              })
            }
            .onClick((): void => {
              router.pushUrl({ url: 'pages/VisitRecordsPage' });
            })

            // 服务订单
            Column() {
              HomeFunctionItem({
                label: '服务订单',
                icon: $r('app.media.home_icon2')
              })
            }
            .onClick((): void => {
              router.pushUrl({ url: 'pages/ServiceOrdersPage' });
            })

            // 服务采购
            Column() {
              HomeFunctionItem({
                label: '服务采购',
                icon: $r('app.media.home_icon3')
              })
            }
            .onClick((): void => {
              router.pushUrl({ url: 'pages/ServicePurchasePage' });
            })

            // 入住申请
            Column() {
              HomeFunctionItem({
                label: '入住申请',
                icon: $r('app.media.home_icon4')
              })
            }
            .onClick((): void => {
              router.pushUrl({ url: 'pages/AdmissionApplyPage' });
            })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceAround)
          .alignItems(VerticalAlign.Center)
          .height($r('app.float.home_function_row_height'))
        }
        .margin({
          left: $r('app.float.home_function_area_horizontal_margin'),
          right: $r('app.float.home_function_area_horizontal_margin'),
          top: $r('app.float.home_function_area_top_margin')
        })
        .backgroundColor(0xFFFFFFFF)
        .borderRadius($r('app.float.home_function_area_radius'))
        .padding({
          left: $r('app.float.home_function_area_horizontal_padding'),
          right: $r('app.float.home_function_area_horizontal_padding')
        })

        // 4. “健康宣教” 标题行
        Row() {
          // 左侧小占位符（小竖条）
          Column()
            .width(4)           // 竖条宽度
            .height(16)         // 竖条高度
            .backgroundColor(0xFF2EC7A8) // 颜色
            .borderRadius(2)    // 圆角
            .margin({ left: $r('app.float.home_health_section_title_left_margin'), right: 8 })

          // 标题文字
          Text('健康宣教')
            .fontSize($r('app.float.home_health_section_title_font_size'))
            .fontWeight(FontWeight.Normal)
            .fontColor(0xFF333333)
        }
        .width('100%')
        .margin({
          top: $r('app.float.home_health_section_title_top_margin'),
          bottom: $r('app.float.home_health_section_title_bottom_margin')
        })
        .justifyContent(FlexAlign.Start)
        .alignItems(VerticalAlign.Center)


        // 5. 健康宣教卡片列表（数据驱动渲染）
        ForEach(
          this.healthEduList,
          (item: HealthEduItem) => {
            Column() {
              HealthEduCard({ img: item.img, title: item.title });
            }
            .onClick((): void => {
              router.pushUrl({
                url: 'pages/HealthEduDetailPage',
                params: { id: item.id }
              });
            })
          },
          (item: HealthEduItem) => item.id.toString()
        )

        // 底部留白
        Blank()
          .height($r('app.float.home_bottom_blank_height'))
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
  }

  build() {
    Column() {
      /**
       * PullToRefresh 负责：
       * 1) 包裹可滚动内容（Scroll）
       * 2) 下拉触发时把 refreshing 改为 true
       *
       * 真正的刷新逻辑由 @Watch(onRefreshingChanged) 负责
       */
      PullToRefresh({
        refreshing: $isRefreshing,
        pullOffset: 64 // 下拉触发阈值
      }) {
        this.buildHomeContent();
      }
    }
    .width('100%')
    .height('100%')
    // 页面绿色渐变背景
    .linearGradient({
      angle: 180,
      colors: [
        [0xFF2EC7A8, 0.0],
        [0xFFA0EACD, 0.35],
        [0xFFF5FFFC, 0.5],
        [0xFFFFFFFF, 1.0]
      ]
    })
  }
}
