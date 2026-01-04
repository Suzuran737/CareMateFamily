import router from '@ohos.router';
import type common from '@ohos.app.ability.common';
import { CareUserStoreManager, CareUserRecord } from '../utils/CareUserStoreManager';

interface CareUserDetailParams {
  id?: string | number;
}

@Entry
@Component
export default struct CareUserDetailPage {
  private context: common.UIAbilityContext = getContext() as common.UIAbilityContext;
  private careStore: CareUserStoreManager = CareUserStoreManager.getInstance();
  private userId: string = '';

  @State private user: CareUserRecord | null = null;

  aboutToAppear(): void {
    this.readRouteParams();
    this.loadUser();
  }

  private readRouteParams(): void {
    const params = router.getParams() as CareUserDetailParams;
    if (params && typeof params.id === 'string') {
      this.userId = params.id;
    } else if (params && typeof params.id === 'number') {
      this.userId = params.id.toString();
    }
  }

  private loadUser(): void {
    const isLogin: boolean = AppStorage.get<boolean>('isLogin') === true;
    const ownerName: string = AppStorage.get<string>('userName') || '';
    if (!isLogin || !ownerName || ownerName === '未登录') {
      this.user = null;
      return;
    }

    this.careStore.initKvStore(this.context)
      .then(() => this.careStore.getUsers(ownerName))
      .then((list: CareUserRecord[]) => {
        const target: CareUserRecord | null = list.find((item: CareUserRecord) => item.id === this.userId) || null;
        this.user = target;
      })
      .catch((err: Error) => {
        console.error('读取用户详情失败:', err);
        this.user = null;
      });
  }

  build() {
    Column() {
      // 顶部标题栏：返回 + 标题
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

        Text('用户详情')
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
      .alignItems(VerticalAlign.Center)

      Scroll() {
        Column() {
          if (this.user) {
            Column() {
              Image(this.user!.gender === '男' ? $r('app.media.ic_man') : $r('app.media.ic_woman'))
                .width(120)
                .height(120)
                .borderRadius(60)
                .objectFit(ImageFit.Cover)
                .backgroundColor('#DDDDDD')
                .margin({ top: 8, bottom: 16 })

              this.InfoRow('用户名称', this.user!.name)
              this.InfoRow('关系', this.user!.relationship)
              this.InfoRow('性别', this.user!.gender)
              this.InfoRow('出生日期', this.user!.birthday)
              this.InfoRow('身份证号', this.user!.idCard)
              this.InfoRow('职业', this.user!.occupation)
              this.InfoRow('地址', this.user!.address)
            }
            .padding(16)
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
          } else {
            Column() {
              Text('暂无用户信息')
                .fontSize(14)
                .fontColor($r('app.color.service_secondary_text_color'))
                .margin({ top: 40, bottom: 40 })
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
          }
        }
        .width('100%')
      }
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

  @Builder
  private InfoRow(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(14)
        .fontColor('#333333')

      Blank().layoutWeight(1)

      Text(value || '--')
        .fontSize(14)
        .fontColor('#333333')
        .textAlign(TextAlign.End)
        .width('70%')
    }
    .width('100%')
    .height(44)
    .border({ width: 0 })
    .margin({ bottom: 8 })
    .alignItems(VerticalAlign.Center)
  }
}
