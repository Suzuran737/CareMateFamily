import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import type common from '@ohos.app.ability.common';
import { CareUserStoreManager, CareUserRecord } from '../utils/CareUserStoreManager';

interface SelectOption {
  value: string;
}

@Entry
@Component
export default struct AddCareUserPage {
  // Ability 上下文，用于初始化 KvStore
  private context: common.UIAbilityContext = getContext() as common.UIAbilityContext;
  // 关系下拉选项
  private relationshipOptions: SelectOption[] = [
    { value: '父亲' },
    { value: '母亲' },
    { value: '配偶' },
    { value: '子女' },
    { value: '亲属' }
  ];

  // 表单状态（必填项 + 可选项）
  @State userName: string = '';
  @State relationshipIndex: number = -1;
  @State gender: string = '';
  @State birthday: string = '';
  @State idCard: string = '';
  @State occupation: string = '';
  @State address: string = '';

  build() {
    Column() {
      // 顶部标题栏：返回 + 标题
      Row() {
        // 左：返回按钮
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
        Text('添加康养用户')
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

      // 表单区域
      Scroll() {
        Column() {
          Column() {
            // 头像
            Image($r('app.media.ic_man'))
              .width(120)
              .height(120)
              .borderRadius(60)
              .objectFit(ImageFit.Cover)
              .backgroundColor('#DDDDDD')
              .margin({ top: 8, bottom: 16 })

            // 用户名称
            this.InputRow('用户名', true, '请输入康养用户名称', this.userName, (val: string) => {
              this.userName = val;
            })

            // 关系（下拉选择）
            this.SelectRow('关系', true)

            // 性别（点击选择）
            this.GenderRow()

            // 出生日期
            this.InputRow('出生日期', true, '请选择出生日期', this.birthday, (val: string) => {
              this.birthday = val;
            })

            // 身份证号
            this.InputRow('身份证号', true, '请输入身份证号码', this.idCard, (val: string) => {
              this.idCard = val;
            })

            // 职业
            this.InputRow('职业', false, '请输入职业', this.occupation, (val: string) => {
              this.occupation = val;
            })

            // 地址
            this.InputRow('地址', false, '请输入地址', this.address, (val: string) => {
              this.address = val;
            })
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
        }
        .width('100%')
      }

      Blank().layoutWeight(1)

      // 底部按钮
      Row() {
        Button('添加')
          .height(44)
          .layoutWeight(1)
          .backgroundColor('#07C6A5')
          .fontColor(Color.White)
          .borderRadius(22)
          .onClick(() => {
            // 必填项校验
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

            const nameValue = this.userName.trim();
            const relationship = this.relationshipIndex >= 0
              ? this.relationshipOptions[this.relationshipIndex].value
              : '';
            const birthdayValue = this.birthday.trim();
            const idCardValue = this.idCard.trim();

            if (!nameValue) {
              showValidation('请输入康养用户名称');
              return;
            }
            if (!relationship) {
              showValidation('请选择关系');
              return;
            }
            if (!this.gender) {
              showValidation('请选择性别');
              return;
            }
            if (!birthdayValue) {
              showValidation('请选择出生日期');
              return;
            }
            if (!idCardValue) {
              showValidation('请输入身份证号码');
              return;
            }

            // 保存到 KvStore 后返回上一页
            const isLogin: boolean = AppStorage.get<boolean>('isLogin') === true;
            const ownerName: string = AppStorage.get<string>('userName') || '';
            if (!isLogin || !ownerName || ownerName === '未登录') {
              showValidation('请先登录后再添加档案');
              return;
            }

            const now: number = Date.now();
            const record = new CareUserRecord(
              `care_user_${now}`,
              now,
              nameValue,
              this.gender,
              relationship,
              birthdayValue,
              idCardValue,
              this.occupation,
              this.address
            );
            CareUserStoreManager.getInstance().initKvStore(this.context)
              // .then(() => CareUserStoreManager.getInstance().saveUser(record)) // 旧逻辑：未区分登录用户
              .then(() => CareUserStoreManager.getInstance().saveUser(ownerName, record))
              .then(() => {
                AppStorage.setOrCreate('careUserRefresh', Date.now());
                router.back();
              })
              .catch((err: Error) => {
                console.error('保存康养用户失败:', err);
              });
          })
      }
      .width('90%')
      .margin({ top: 8, bottom: 16 })
    }
    .width('100%')
    .height('100%')
    // 渐变效果
    .linearGradient({
      angle: 180, // 从上到下
      colors: [
        // 顶部绿色 → 渐变到白色
        [0xFF2EC7A8, 0.0],
        [0xFFA0EACD, 0.35],
        [0xFFF5FFFC, 0.5],
        [0xFFFFFFFF, 1.0]
      ]
    })
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);
  }

  // 输入行（文本输入）
  @Builder
  private InputRow(label: string, required: boolean, placeholder: string, value: string, onChange: (val: string) => void) {
    Row() {
      Row() {
        Text(label)
          .fontSize(14)
          .fontColor('#333333')
        if (required) {
          Text('*')
            .fontSize(14)
            .fontColor('#E53935')
            .margin({ left: 2 })
        }
      }

      Blank().layoutWeight(1)

      TextInput({ placeholder: placeholder, text: value })
        .fontSize(14)
        .fontColor('#333333')
        .placeholderFont({ size: $r('app.float.service_body_font_size') })
        .placeholderColor($r('app.color.service_secondary_text_color'))
        .textAlign(TextAlign.End)
        .onChange((val: string) => onChange(val))
        .width('70%')
    }
    .width('100%')
    .height(44)
    .border({ width: 0 })
    .margin({ bottom: 8 })
  }

  // 关系选择行（下拉）
  @Builder
  private SelectRow(label: string, required: boolean) {
    Row() {
      Row() {
        Text(label)
          .fontSize(14)
          .fontColor('#333333')
        if (required) {
          Text('*')
            .fontSize(14)
            .fontColor('#E53935')
            .margin({ left: 2 })
        }
      }

      Blank().layoutWeight(1)

      Select(this.relationshipOptions)
        .selected(this.relationshipIndex)
        .value(
          this.relationshipIndex >= 0
            ? this.relationshipOptions[this.relationshipIndex].value
            : '请选择关系'
        )
        .font({ size: 14 })
        .fontColor('#999999')
        .onSelect((index: number, value: string) => {
          this.relationshipIndex = index;
        })
    }
    .width('100%')
    .height(44)
    .margin({ bottom: 8 })
    .alignItems(VerticalAlign.Center)
  }

  // 性别选择行（点击选择）
  @Builder
  private GenderRow() {
    Row() {
      Row() {
        Text('性别')
          .fontSize(14)
          .fontColor('#333333')
        Text('*')
          .fontSize(14)
          .fontColor('#E53935')
          .margin({ left: 2 })
      }

      Blank().layoutWeight(1)

      Row({ space: 16 }) {
        this.GenderOption('男')
        this.GenderOption('女')
      }
    }
    .width('100%')
    .height(44)
    .margin({ bottom: 8 })
    .alignItems(VerticalAlign.Center)
  }

  // 单个性别选项
  @Builder
  private GenderOption(label: string) {
    Row({ space: 6 }) {
      Row()
        .width(16)
        .height(16)
        .borderRadius(8)
        .borderWidth(1)
        .borderColor(this.gender === label ? '#07C6A5' : '#999999')
        .backgroundColor(this.gender === label ? '#07C6A5' : '#FFFFFF')

      Text(label)
        .fontSize(14)
        .fontColor('#333333')
    }
    .onClick(() => {
      this.gender = label;
    })
  }
}
