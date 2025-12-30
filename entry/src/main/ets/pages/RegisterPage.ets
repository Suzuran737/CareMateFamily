// RegisterPage.ets - 注册页面
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import type common from '@ohos.app.ability.common';
import { CaptchaCanvas } from '../components/CaptchaCanvas';
import { UserStoreManager, UserRecord } from '../utils/UserStoreManager';

@Entry
@Component
struct RegisterPage {
  private context: common.UIAbilityContext = getContext() as common.UIAbilityContext;
  @State username: string = '';
  @State phoneNumber: string = '';
  @State password: string = '';
  @State confirmPassword: string = '';
  @State verificationCode: string = '';

  // 当前验证码
  @State captchaCode: string = '';
  // 页面想强制刷新验证码时：captchaSeed++
  @State captchaSeed: number = 0;
  // 验证码错误提示（为空表示不显示）
  @State captchaErrorText: string = '';

  // ✅ 密码不一致错误提示（为空表示不显示）
  @State pwdErrorText: string = '';

  private mainColor: number = 0xFF2ECFA8;

  // InputField 组件定义：使用 ResourceStr | string 类型
  @Builder
  InputField(icon: ResourceStr | string, placeholder: string, isPassword: boolean = false, needCaptcha: boolean = false) {
    Row() {
      // 左侧图标
      Image(icon)
        .width(20)
        .height(20)
        .margin({ left: 16 })
        .fillColor(Color.Gray)

      // 输入框
      TextInput({ placeholder: placeholder })
        .layoutWeight(1)
        .type(isPassword ? InputType.Password : InputType.Normal)
        .placeholderColor(Color.Gray)
        .backgroundColor(Color.Transparent)
        .fontSize(16)
        .padding({ left: 12, right: 12 })
        .maxLength(needCaptcha ? 4 : undefined)
        .onChange((value: string) => {
          if (placeholder.includes('用户名')) {
            this.username = value;
          } else if (placeholder.includes('手机号')) {
            this.phoneNumber = value;
          } else if (placeholder.includes('密码') && !placeholder.includes('确认')) {
            this.password = value;
            this.pwdErrorText = ''; // 重新输入密码时清除提示
          } else if (placeholder.includes('确认密码')) {
            this.confirmPassword = value;
            this.pwdErrorText = ''; // 重新输入确认密码时清除提示
          } else if (placeholder.includes('验证码')) {
            this.verificationCode = value;
            this.captchaErrorText = ''; // 重新输入验证码时清除提示
          }
        })

      // 只有验证码时才显示：右侧固定宽度容器
      if (needCaptcha) {
        // 让验证码和输入框有间距
        Blank().width(8)

        Row() {
          CaptchaCanvas({
            code: $captchaCode,
            seed: this.captchaSeed,
            length: 4
          })
        }
        .width(118) // 固定右侧区域宽度（110 + 间距）
        .height(36)
        .justifyContent(FlexAlign.End)
        .alignItems(VerticalAlign.Center)
        .margin({ right: 16 })
      } else {
        // 不是验证码行时，保留右侧 padding，让输入框不贴边
        Blank().width(16)
      }
    }
    .width('90%')
    .height(50)
    .backgroundColor(0xFFF5F5F5)
    .borderRadius(25)
    .margin({ top: 8, bottom: 8 })
    .alignItems(VerticalAlign.Center)
  }

  // 通用的错误提示行（红字）
  @Builder
  ErrorTextRow(text: string) {
    Row() {
      Text(text)
        .fontSize(14)
        .fontColor(0xFFFF3B30)
    }
    .width('90%')
    .padding({ left: 12 })
    .margin({ top: 4 })
  }

  // 路由跳转方法
  navigateTo(page: string) {
    if (page === 'LoginPage') {
      router.replaceUrl({ url: 'pages/LoginPage' });
    }
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Text('<')
          .fontSize(24)
          .fontColor(0xFFFFFF)
          .margin({ left: 16 })
          .onClick(() => router.back())

        Text('注册')
          .fontSize(18)
          .fontColor(Color.Black)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .margin({ right: 40 })
      }
      .width('100%')
      .height(56)
      .alignItems(VerticalAlign.Center)
      .zIndex(1)

      Scroll() {
        Column() {
          // 标题：用户注册
          Row() {
            Divider().width(4).height(24).color(this.mainColor).margin({ right: 8 })
            Text('用户注册')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.Black)
          }
          .width('90%')
          .margin({ top: 40, bottom: 30 })
          .justifyContent(FlexAlign.Start)

          // 1. 用户名输入框
          this.InputField($r('app.media.ic_user'), '请输入用户名')

          // 2. 手机号输入框
          this.InputField($r('app.media.ic_phone'), '请输入手机号码')

          // 3. 密码输入框
          this.InputField($r('app.media.ic_lock'), '密码', true)

          // 密码错误提示（显示在密码框下面）
          if (this.pwdErrorText.length > 0) {
            this.ErrorTextRow(this.pwdErrorText)
          }

          // 4. 确认密码输入框
          this.InputField($r('app.media.ic_lock'), '确认密码', true)

          // 密码错误提示（显示在确认密码框下面）
          if (this.pwdErrorText.length > 0) {
            this.ErrorTextRow(this.pwdErrorText)
          }

          // 5. 验证码输入框
          this.InputField($r('app.media.ic_code'), '验证码 (有效期限5分钟)', false, true)

          // 验证码错误提示
          if (this.captchaErrorText.length > 0) {
            this.ErrorTextRow(this.captchaErrorText)
          }

          // 立即注册按钮
          Button('注册')
            .width('90%')
            .height(50)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .backgroundColor(this.mainColor)
            .borderRadius(25)
            .margin({ top: 40, bottom: 40 })
            .onClick(() => {
              // 1) 密码一致性校验（失败则在两个密码框下都显示红字）
              if (this.password !== this.confirmPassword) {
                console.error('两次密码输入不一致');
                this.pwdErrorText = '两次密码输入不一致 !';
                return;
              } else {
                this.pwdErrorText = '';
              }

              // 2) 图形验证码校验（忽略大小写）
              const inputCode: string = this.verificationCode.trim().toUpperCase();
              const realCode: string = this.captchaCode.trim().toUpperCase();

              if (inputCode.length === 0) {
                console.error('请输入验证码');
                this.captchaErrorText = '请输入验证码 !';
                return;
              }

              if (inputCode !== realCode) {
                console.error('验证码错误');
                this.captchaErrorText = '验证码输入错误 !';
                this.verificationCode = '';
                this.captchaSeed++; // 刷新验证码
                return;
              } else {
                this.captchaErrorText = '';
              }

              const showRegisterError = (message: string): void => {
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

              const userNameValue: string = this.username.trim();
              if (!userNameValue) {
                showRegisterError('请输入用户名');
                return;
              }

              const record = new UserRecord(
                userNameValue,
                this.phoneNumber.trim(),
                this.password,
                Date.now()
              );

              UserStoreManager.getInstance().initKvStore(this.context)
                .then(() => UserStoreManager.getInstance().getUserByName(userNameValue))
                .then((exist: UserRecord | null) => {
                  if (exist) {
                    showRegisterError('用户名已存在');
                    return;
                  }
                  return UserStoreManager.getInstance().saveUser(record)
                    .then(() => {
                      // AppStorage.setOrCreate('tempRegisteredName', this.username); // 旧逻辑：临时保存注册信息
                      // AppStorage.setOrCreate('tempRegisteredPhone', this.phoneNumber); // 旧逻辑：临时保存注册信息
                      this.navigateTo('LoginPage');
                    });
                })
                .catch((err: Error) => {
                  console.error('注册失败:', err);
                });
            })

          Blank().height(40)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
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
