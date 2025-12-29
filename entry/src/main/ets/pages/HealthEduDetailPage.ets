import router from '@ohos.router';
import { getHealthEduDetailById, type HealthEduDetail } from '../model/HealthEduCatalog';

// 路由参数：从列表页传入 id
interface HealthEduRouteParams {
  id?: number | string;
}

// 详情段落结构，用于 ForEach 渲染
interface HealthEduSection {
  id: number;
  text: string;
}

// 默认详情：避免首次渲染空数据
const DEFAULT_HEALTH_DETAIL: HealthEduDetail = getHealthEduDetailById(1);

// 将段落数组转换为可渲染列表
function buildSectionList(sections: string[]): HealthEduSection[] {
  const list: HealthEduSection[] = [];
  for (let i: number = 0; i < sections.length; i++) {
    list.push({
      id: i,
      text: sections[i]
    });
  }
  return list;
}

@Entry
@Component
export default struct HealthEduDetailPage {
  @State detail: HealthEduDetail = DEFAULT_HEALTH_DETAIL;
  @State sectionList: HealthEduSection[] = buildSectionList(DEFAULT_HEALTH_DETAIL.sections);

  aboutToAppear(): void {
    // 读取路由参数并定位文章详情
    const params = router.getParams() as HealthEduRouteParams;
    let targetId: number = 0;
    if (params && typeof params.id === 'number') {
      targetId = params.id;
    } else if (params && typeof params.id === 'string') {
      const parsedId: number = Number(params.id);
      if (parsedId === parsedId) {
        targetId = parsedId;
      }
    }
    const detail: HealthEduDetail = getHealthEduDetailById(targetId);
    this.detail = detail;
    this.sectionList = buildSectionList(detail.sections);
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
        Text('资讯详情')
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

      // 详情正文
      Scroll() {
        Column() {
          // 详情卡片
          Column() {
            Image(this.detail.img)
              .width('100%')
              .height(180)
              .objectFit(ImageFit.Cover)
              .clip(true)
              .margin({ bottom: 12 })

            // 标题 + 元信息
            Column() {
              Text(this.detail.title)
                .fontSize(22)
                .fontWeight(FontWeight.Bold)
                .fontColor($r('app.color.service_primary_text_color'))
                .textAlign(TextAlign.Start)

              Row() {
                Text('健康宣教 · 家属端')
                  .fontSize(12)
                  .fontColor($r('app.color.service_secondary_text_color'))

                Blank().layoutWeight(1)
              }
              .margin({ top: 10 })
            }
            .padding({
              left: $r('app.float.service_text_left_right_margin'),
              right: $r('app.float.service_text_left_right_margin'),
              top: 16,
              bottom: 14
            })

            Divider()
              .color($r('app.color.service_card_border_color'))
              .strokeWidth(1)
              .margin({
                left: $r('app.float.service_text_left_right_margin'),
                right: $r('app.float.service_text_left_right_margin')
              })

            // 正文
            Column() {
              ForEach(
                this.sectionList,
                (section: HealthEduSection) => {
                  Text(section.text)
                    .fontSize(16)
                    .lineHeight(28)
                    .textIndent(28)
                    .fontColor($r('app.color.service_tertiary_text_color'))
                    .textAlign(TextAlign.Start)
                    .margin({ bottom: 18 })
                },
                (section: HealthEduSection) => section.id.toString()
              )
            }
            .padding({
              left: $r('app.float.service_text_left_right_margin'),
              right: $r('app.float.service_text_left_right_margin'),
              top: 16,
              bottom: 8
            })

          }
          .backgroundColor($r('app.color.service_card_background_color'))
          .borderRadius($r('app.float.service_card_radius'))
          .borderWidth($r('app.float.service_card_border_width'))
          .borderColor($r('app.color.service_card_border_color'))
          .clip(true)
          .margin({
            left: $r('app.float.service_detail_card_space'),
            right: $r('app.float.service_detail_card_space'),
            top: 0,
            bottom: $r('app.float.service_detail_card_space')
          })

          Blank().height(32)
        }
        .width('100%')
      }
      .width('100%')

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
