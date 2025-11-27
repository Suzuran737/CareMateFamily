// 我的 Tab 页面
@Component
export default struct ProfileTab {
  build() {
    Column() {
      Text('这里是我的页面')
        .fontSize(20)
        .fontWeight(FontWeight.Medium);
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center);
  }
}
