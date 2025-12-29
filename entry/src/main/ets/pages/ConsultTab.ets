import router from '@ohos.router';
import { PullToRefresh } from '../components/PullToRefresh';
import { getHealthEduList, type HealthEduItem } from '../model/HealthEduCatalog';

/**
 * 健康宣教卡片组件
 */
@Component
struct HealthEduCard {
  @Prop img: Resource; // 宣教图片资源
  @Prop title: string; // 宣教标题

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
          .margin({ left: 4, right: 10 })
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
 * 咨询 Tab 页面
 */
@Component
export default struct ConsultTab {
  // 下拉刷新状态，配合 PullToRefresh 使用
  @State @Watch('onRefreshingChanged') isRefreshing: boolean = false;
  @State healthEduList: HealthEduItem[] = getHealthEduList();

  // 打乱健康宣教列表顺序
  private shuffleHealthEduList(): void {
    const oldIds: number[] = this.healthEduList.map((it: HealthEduItem) => it.id);
    const list: HealthEduItem[] = this.healthEduList.slice();
    // Fisher–Yates 洗牌
    for (let i: number = list.length - 1; i > 0; i--) {
      const j: number = Math.floor(Math.random() * (i + 1));
      const temp: HealthEduItem = list[i];
      list[i] = list[j];
      list[j] = temp;
    }
    // 若顺序未变化，强制交换前两项
    const newIds: number[] = list.map((it: HealthEduItem) => it.id);
    let same: boolean = true;
    for (let k: number = 0; k < oldIds.length; k++) {
      if (oldIds[k] !== newIds[k]) {
        same = false;
        break;
      }
    }
    if (same && list.length >= 2) {
      const t: HealthEduItem = list[0];
      list[0] = list[1];
      list[1] = t;
    }
    this.healthEduList = list;
  }

  // 监听刷新状态变化，触发模拟刷新
  private onRefreshingChanged(): void {
    if (!this.isRefreshing) {
      return;
    }
    this.shuffleHealthEduList();
    setTimeout((): void => {
      this.isRefreshing = false;
    }, 500);
  }

  // 咨询页主体内容 Builder
  @Builder
  private buildConsultContent(): void {
    Scroll() {
      Column() {
        // 顶部标题栏
        Row() {
          Text('健康资讯列表')
            .fontSize($r('app.float.home_header_title_font_size'))
            .fontWeight(FontWeight.Normal)
            .fontColor(0xFFFFFFFF)
        }
        .height($r('app.float.home_header_height'))
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)

        Row() {
          Column() {
            Text('健康资讯')
              .fontSize(32)
              .fontWeight(FontWeight.Bold)
              .fontColor(0xFF333333)

            // 下划线（从文字开头开始）
            Row()
              .width(56)
              .height(3)
              .backgroundColor(0xFF333333)
              .borderRadius(2)
              .margin({ top: 6 })
          }
          .alignItems(HorizontalAlign.Start)
          .margin({ left: $r('app.float.home_health_section_title_left_margin') })
        }
        .width('100%')
        .margin({
          top: $r('app.float.home_health_section_title_top_margin'),
          bottom: $r('app.float.home_health_section_title_bottom_margin')
        })
        .justifyContent(FlexAlign.Start)
        .alignItems(VerticalAlign.Center)

        // 健康宣教卡片列表（数据驱动）
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
      PullToRefresh({
        refreshing: $isRefreshing,
        pullOffset: 64
      }) {
        this.buildConsultContent();
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
