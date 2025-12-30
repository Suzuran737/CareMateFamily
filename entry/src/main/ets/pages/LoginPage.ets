// LoginPage.ets - 登录页面
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import type common from '@ohos.app.ability.common';
import { CaptchaCanvas } from '../components/CaptchaCanvas';
import { UserStoreManager, UserRecord } from '../utils/UserStoreManager';

@Entry
@Component
struct LoginPage {
  private context: common.UIAbilityContext = getContext() as common.UIAbilityContext;
  @State loginUserName: string = '';
  @State password: string = '';
  @State verificationCode: string = '';

  // 当前验证码
  @State captchaCode: string = '';
  // 页面想强制刷新验证码时：captchaSeed++
  @State captchaSeed: number = 0;
  // 验证码错误提示（为空表示不显示）
  @State captchaErrorText: string = '';

  // 登录按钮的颜色和样式与应用主色调保持一致
  private mainColor: number = 0xFF2ECFA8;

  // 路由跳转方法
  navigateTo(page: string) {
    switch (page) {
      case 'RegisterPage':
        router.pushUrl({ url: 'pages/RegisterPage' });
        break;
      case 'MainTabPage':
        router.replaceUrl({ url: 'pages/MainTabPage' });
        break;
    }
  }

  // 可复用的输入框组件
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
            this.loginUserName = value;
          } else if (placeholder.includes('密码')) {
            this.password = value;
          } else if (placeholder.includes('验证码')) {
            this.verificationCode = value;
            this.captchaErrorText = ''; // 用户重新输入时清掉错误提示
          }
        })

      // Canvas 图形验证码
      if (needCaptcha) {
        Blank().width(8)

        Row() {
          CaptchaCanvas({
            code: $captchaCode,
            seed: this.captchaSeed,
            length: 4
          })
        }
        .width(118)
        .height(36)
        .justifyContent(FlexAlign.End)
        .alignItems(VerticalAlign.Center)
        .margin({ right: 16 })
      } else {
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

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Text('<')
          .fontSize(24)
          .fontColor(0xFFFFFF)
          .margin({ left: 16 })
          .onClick(() => router.back())

        Text('登录')
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
          // 标题：互联网机构 家属端
          Row() {
            Divider().width(4).height(24).color(this.mainColor).margin({ right: 8 })
            Text('互联网机构 家属端')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.Black)
          }
          .width('90%')
          .margin({ top: 30, bottom: 40 })
          .justifyContent(FlexAlign.Start)

          // 登录方式 Tab
          Column() {
            Text('账号密码登录')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor(Color.Black)
              .margin({ bottom: 8 })

            Divider()
              .width(120)
              .strokeWidth(2)
              .color(this.mainColor)
          }
          .alignItems(HorizontalAlign.Start)
          .width('90%')
          .margin({ bottom: 20 })

          // 用户名输入框
          this.InputField($r('app.media.ic_user'), '请输入用户名')

          // 密码输入框
          this.InputField($r('app.media.ic_lock'), '密码', true)

          // 验证码输入框（右侧 Canvas）
          this.InputField($r('app.media.ic_code'), '验证码 (有效期限5分钟)', false, true)

          // 验证码错误提示（放在验证码行下面）
          if (this.captchaErrorText.length > 0) {
            Row() {
              Text(this.captchaErrorText)
                .fontSize(14)
                .fontColor(0xFFFF3B30)
            }
            .width('90%')
            .padding({ left: 12 })
            .margin({ top: 4 })
          }

          // 登录按钮
          Button('登录')
            .width('90%')
            .height(50)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .backgroundColor(this.mainColor)
            .borderRadius(25)
            .margin({ top: 30, bottom: 20 })
            .onClick(() => {
              // 1) 验证码校验（忽略大小写）
              const inputCode: string = this.verificationCode.trim().toUpperCase();
              const realCode: string = this.captchaCode.trim().toUpperCase();

              if (inputCode.length === 0) {
                this.captchaErrorText = '请输入验证码 !';
                return;
              }

              if (inputCode !== realCode) {
                this.captchaErrorText = '验证码输入错误 !';
                this.verificationCode = '';
                this.captchaSeed++; // 强制刷新验证码
                return;
              }

              const showLoginError = (message: string): void => {
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

              const userNameValue: string = this.loginUserName.trim();
              const passwordValue: string = this.password;

              UserStoreManager.getInstance().initKvStore(this.context)
                .then(() => UserStoreManager.getInstance().getUserByName(userNameValue))
                .then((record: UserRecord | null) => {
                  if (!record) {
                    showLoginError('用户不存在');
                    return;
                  }
                  if (record.password !== passwordValue) {
                    showLoginError('密码错误');
                    return;
                  }

                  // const registeredName: string = AppStorage.get<string>('tempRegisteredName') || '测试用户'; // 旧逻辑：读取临时注册信息

                  AppStorage.setOrCreate('isLogin', true);
                  AppStorage.setOrCreate('userPhone', record.phone);
                  AppStorage.setOrCreate('userName', record.userName);

                  this.navigateTo('MainTabPage');
                })
                .catch((err: Error) => {
                  console.error('登录失败:', err);
                  showLoginError('登录失败，请重试');
                });
            })

          // 注册入口
          Text() {
            Span('还没有账号？')
              .fontColor(Color.Gray)
            Span('立即注册')
              .fontColor(this.mainColor)
              .fontWeight(FontWeight.Medium)
              .onClick(() => this.navigateTo('RegisterPage'))
          }
          .fontSize(16)
          .width('90%')
          .textAlign(TextAlign.Start)

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
