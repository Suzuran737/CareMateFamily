// 统一背景的页面骨架组件
@Component
export struct AppPageScaffold {
  @BuilderParam content: () => void;

  build() {
    Column() {
      this.content();
    }
    .width('100%')
    .height('100%')
    // .backgroundColor(Color.Blue)
    // 绿色渐变背景
    .linearGradient({
      angle: 180, // 从上到下
      colors: [
        [0xFF2EC7A8, 0.0],
        [0xFFA0EACD, 0.35],
        [0xFFF5FFFC, 0.5],
        [0xFFFFFFFF, 1.0]
      ]
    })
  }
}