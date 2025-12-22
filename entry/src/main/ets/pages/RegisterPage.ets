// RegisterPage.ets - 注册页面 (使用 Text 符号解决返回箭头报错)
import router from '@ohos.router';

// 注意：以下代码中所有 $r('app.media.xxx') 引用，请确保您的项目 media 目录中包含对应的图片文件，
// 否则仍然会出现 'Unknown resource name' 错误。

@Entry
@Component
struct RegisterPage {
  @State username: string = '';
  @State phoneNumber: string = '';
  @State password: string = '';
  @State confirmPassword: string = '';
  @State verificationCode: string = '';

  private mockCaptcha: string = '6705';
  private mainColor: number = 0xFF2ECFA8;

  // InputField 组件定义：使用 ResourceStr | string 类型
  @Builder
  InputField(icon: ResourceStr | string, placeholder: string, isPassword: boolean = false, needCaptcha: boolean = false) {
    Row() {
      // 左侧图标
      Image(icon) // <--- 确保 icon 传入的是 $r('app.media.xxx')
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
        .onChange((value) => {
          if (placeholder.includes('用户名')) this.username = value;
          else if (placeholder.includes('手机号')) this.phoneNumber = value;
          else if (placeholder.includes('密码') && !placeholder.includes('确认')) this.password = value;
          else if (placeholder.includes('确认密码')) this.confirmPassword = value;
          else if (placeholder.includes('验证码')) this.verificationCode = value;
        })

      // 图形验证码 (仅在需要时显示)
      if (needCaptcha) {
        Text(this.mockCaptcha)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.mainColor)
          // 再次使用 decoration 属性，如果仍报错，请您手动注释掉此行。
          .decoration({ type: TextDecorationType.LineThrough, color: Color.Red })
          .margin({ right: 16 })
          .onClick(() => {
            console.log('刷新验证码逻辑');
          })
      }
    }
    .width('90%')
    .height(50)
    .backgroundColor(0xFFF5F5F5)
    .borderRadius(25)
    .margin({ top: 8, bottom: 8 })
  }

  // 路由跳转方法
  navigateTo(page: string) {
    console.log(`Navigating to ${page}`);
    if (page === 'LoginPage') {
      router.replaceUrl({ url: 'pages/LoginPage' });
    }
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        // 修正：使用 Text 符号 '<' 模拟返回箭头
        Text('<')
          .fontSize(24)
          .fontColor(this.mainColor)
          .margin({ left: 16 })
          .onClick(() => router.back())

        Text('注册')
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
      .backgroundColor(Color.White)
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

          // 4. 确认密码输入框
          this.InputField($r('app.media.ic_lock'), '确认密码', true)

          // 5. 验证码输入框
          this.InputField($r('app.media.ic_code'), '验证码 (有效期限5分钟)', false, true)

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
              if (this.password !== this.confirmPassword) {
                console.error('两次密码输入不一致');
                return;
              }
              AppStorage.setOrCreate('tempRegisteredName', this.username);
              AppStorage.setOrCreate('tempRegisteredPhone', this.phoneNumber);
              this.navigateTo('LoginPage');
            })

          Blank().height(40)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
    // 顶部背景色
    .linearGradient({
      angle: 180,
      colors: [
        [this.mainColor, 0.0],
        [Color.White, 0.3]
      ]
    })
  }
}