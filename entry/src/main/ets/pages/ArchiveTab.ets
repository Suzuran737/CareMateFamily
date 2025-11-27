// 用户档案 Tab 页面
@Component
export default struct ArchiveTab {
  build() {
    Column() {
      Text('这里是用户档案页面')
        .fontSize(20)
        .fontWeight(FontWeight.Medium);
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center);
  }
}
