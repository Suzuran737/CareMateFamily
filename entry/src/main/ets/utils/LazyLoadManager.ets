/**
 * 列表懒加载的通用逻辑
 */

export class LazyLoadManager<T> {
  private pageSize: number;
  private items: T[] = [];
  private visibleCount: number = 0;

  constructor(pageSize: number) {
    this.pageSize = pageSize;
  }

  reset(items: T[], keepCount: boolean = false): void {
    this.items = items.slice(0);
    if (keepCount) {
      this.visibleCount = Math.min(this.visibleCount, this.items.length);
    } else {
      this.visibleCount = Math.min(this.pageSize, this.items.length);
    }
  }

  getVisibleItems(): T[] {
    return this.items.slice(0, this.visibleCount);
  }

  canLoadMore(): boolean {
    return this.visibleCount < this.items.length;
  }

  loadMore(): T[] {
    if (this.canLoadMore()) {
      this.visibleCount = Math.min(this.visibleCount + this.pageSize, this.items.length);
    }
    return this.getVisibleItems();
  }
}
