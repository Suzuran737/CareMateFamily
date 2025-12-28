/**
 * 为任意可滚动内容（Scroll/List）提供「下拉刷新」能力
 */

@Component
export struct PullToRefresh {
  /**
   * 外部绑定的刷新状态（必须是 @State，并用 $ 传进来）
   * 例如：refreshing: $isRefreshing
   */
  @Link refreshing: boolean;

  /**
   * 下拉触发阈值（单位 vp）
   */
  @Prop pullOffset: number = 64;

  /**
   * 内容插槽 Scroll/List 等放进来
   */
  @BuilderParam content: () => void;

  build() {
    Refresh({ refreshing: this.refreshing }) {
      this.content()
    }
    .refreshOffset(this.pullOffset)
    .onRefreshing((): void => {
      // 避免重复触发
      if (!this.refreshing) {
        this.refreshing = true;
      }
    })
  }
}
