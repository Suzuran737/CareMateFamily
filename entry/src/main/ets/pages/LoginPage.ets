// LoginPage.ets - 登录页面 (修正 ArkTS 语法错误)
import router from '@ohos.router';

@Entry
@Component
struct LoginPage {

  @State phoneNumber: string = '';
  @State password: string = '';
  @State verificationCode: string = '';

  // 模拟图形验证码
  private mockCaptcha: string = '5771';

  // 登录按钮的颜色和样式与应用主色调保持一致
  private mainColor: number = 0xFF2ECFA8;

  // 路由跳转方法
  navigateTo(page: string) {
    console.log(`Navigating to ${page}`);
    switch (page) {
      case 'RegisterPage':
        router.pushUrl({ url: 'pages/RegisterPage' });
        break;
      case 'MainTabPage':
        // 登录成功后，清除当前页面栈并跳转到主页 (根据项目实际需求选择 replaceUrl 或 pushUrl)
        router.replaceUrl({ url: 'pages/MainTabPage' });
        break;
    }
  }

  // 可复用的输入框组件
  // 修正了 marginV 和 marginEnd 错误
  @Builder
  InputField(icon: ResourceStr | string, placeholder: string, isPassword: boolean = false, needCaptcha: boolean = false) {
    Row() {
      // 左侧图标
      Image(icon)
        .width(20)
        .height(20)
        .margin({ left: 16 }) // 使用 margin({ left }) 替代 marginStart
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
        .onChange((value) => {
          // 实际应用中需要将值绑定到 State 变量
          if (placeholder.includes('手机号')) this.phoneNumber = value;
          else if (placeholder.includes('密码')) this.password = value;
          else if (placeholder.includes('验证码')) this.verificationCode = value;
        })

      // 图形验证码 (仅在需要时显示)
      if (needCaptcha) {
        // 修正 textStyle -> decoration, TextDecorationType.LINE_THROUGH -> TextDecorationType.LineThrough
        Text(this.mockCaptcha)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.mainColor)
          .decoration({ type: TextDecorationType.LineThrough, color: Color.Red })
          .margin({ right: 16 }) // 使用 margin({ right }) 替代 marginEnd
          .onClick(() => {
            // 刷新验证码逻辑
            console.log('刷新验证码');
          })
      }
    }
    .width('90%')
    .height(50)
    .backgroundColor(0xFFF5F5F5) // 浅灰色背景
    .borderRadius(25)
    .margin({ top: 8, bottom: 8 }) // 使用 margin({ top, bottom }) 替代 marginV
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
          .margin({ right: 40 }) // 留出左侧 Text 的空间
      }
      .width('100%')
      .height(56)
      .alignItems(VerticalAlign.Center)
      .zIndex(1)

      Scroll() { // 使用 Scroll 包裹内容，避免输入法弹出导致的溢出问题
        Column() {
          // 标题：互联网机构 家属端
          Row() {
            Divider().width(4).height(24).color(this.mainColor).margin({ right: 8 }) // 修正 marginEnd
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

          // 手机号输入框 (使用 $r 资源占位符，如果未定义，请检查您的 resource/base/media 目录)
          this.InputField($r('app.media.ic_phone'), '请输入手机号码') // 假设资源存在

          // 密码输入框].

          this.InputField($r('app.media.ic_lock'), '密码', true) // 假设资源存在

          // 验证码输入框 (包含图形验证码)
          this.InputField($r('app.media.ic_code'), '验证码 (有效期限5分钟)', false, true) // 假设资源存在

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
              let registeredName = AppStorage.get<string>('tempRegisteredName') || '测试用户';

              // 1. 设置登录状态
              AppStorage.setOrCreate('isLogin', true);
              AppStorage.setOrCreate('userPhone', this.phoneNumber);

              // 2. 这里使用真实读取到的注册名！
              AppStorage.setOrCreate('userName', registeredName);

              this.navigateTo('MainTabPage');
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

          // 修正 Spacer 错误：使用 <Blank> 或直接移除，或确保组件已导入
          Blank().height(40) // 使用 Blank 替代 Spacer 来提供底部空间
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
      }
      .layoutWeight(1) // 确保 Scroll 占据剩余空间
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