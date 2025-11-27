// 主页面：底部 Tabs 导航，共 5 个标签
import HomeTab from './HomeTab';
import HealthTab from './HealthTab';
import ConsultTab from './ConsultTab';
import ArchiveTab from './ArchiveTab';
import ProfileTab from './ProfileTab';

@Entry
@Component
struct MainTabPage {
  // 当前选中的 Tab 索引
  @State currentIndex: number = 0;

  // 自定义底部 Tab：图标 + 文字，选中时变绿色
  @Builder
  tabItem(title: string, icon: Resource, index: number) {
    Column() {
      Image(icon)
        .width(28)
        .height(28)
        .fillColor(this.currentIndex === index ? 0xFF2ECFA8 : 0xFF999999)

      Text(title)
        .fontSize(10)
        .fontColor(this.currentIndex === index ? 0xFF2ECFA8 : 0xFF999999)
        .margin({ top: 2 })
    }
    .alignItems(HorizontalAlign.Center)
  }

  build() {
    Tabs({ index: this.currentIndex, barPosition: BarPosition.End }) {
      TabContent() {
        HomeTab();
      }
      .tabBar(this.tabItem('首页', $r('app.media.tab_home'), 0))

      TabContent() {
        HealthTab();
      }
      .tabBar(this.tabItem('健康', $r('app.media.tab_health'), 1))

      TabContent() {
        ConsultTab();
      }
      .tabBar(this.tabItem('咨询', $r('app.media.tab_consult'), 2))

      TabContent() {
        ArchiveTab();
      }
      .tabBar(this.tabItem('用户档案', $r('app.media.tab_archive'), 3))

      TabContent() {
        ProfileTab();
      }
      .tabBar(this.tabItem('我的', $r('app.media.tab_profile'), 4))
    }
    .onChange((index: number) => {
      // 切换底部 Tab 时更新索引
      this.currentIndex = index;
    })
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
    // 扩展到系统顶部/底部
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);
  }
}
