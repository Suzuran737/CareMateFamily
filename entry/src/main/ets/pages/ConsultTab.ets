// 咨询 Tab 页面
@Component
export default struct ConsultTab {
  build() {
    Column() {
      Text('这里是咨询页面')
        .fontSize(20)
        .fontWeight(FontWeight.Medium);
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center);
  }
}
