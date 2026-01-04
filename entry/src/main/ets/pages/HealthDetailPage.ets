// 导入数据模型
import router from '@ohos.router';
import type common from '@ohos.app.ability.common';
import { CareUserStoreManager, CareUserRecord } from '../utils/CareUserStoreManager';
import { HealthRecordStoreManager } from '../utils/HealthRecordStoreManager';
import { HealthUser, HealthData, HealthDataManager } from '../model/HealthData';

// 选择器选项类型
class SelectOption {
  label: string;
  value: string;

  constructor(label: string, value: string) {
    this.label = label;
    this.value = value;
  }
}

interface HealthDetailRouteParams {
  userId?: string | number;
  type?: string;
}

class ChartPoint {
  x: number;
  y: number;

  constructor(x: number, y: number) {
    this.x = x;
    this.y = y;
  }
}

@Component
struct HealthTrendCard {
  @Prop title: string;
  @Prop valueText: string;
  @Prop values: number[] = [];
  @Prop @Watch('onRefreshSeedChanged') refreshSeed: number = 0;
  private ctx: CanvasRenderingContext2D = new CanvasRenderingContext2D();
  private ready: boolean = false;

  private onRefreshSeedChanged(): void {
    if (!this.ready) {
      return;
    }
    this.drawTrend(this.ctx);
  }

  build() {
    Column() {
      Row() {
        Column() {
          Text(this.title)
            .fontSize($r('app.float.service_body_font_size'))
            .fontColor($r('app.color.service_secondary_text_color'))

          Text(this.valueText)
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.service_primary_text_color'))
            .margin({ top: 6 })
        }
        .alignItems(HorizontalAlign.Start)

        Blank().layoutWeight(1)
      }
      .margin({ bottom: 10 })

      // 曲线图 Canvas
      Canvas(this.ctx)
        .width('100%')
        .height(100)
        .borderRadius(12)
        .onReady(() => {
          this.ready = true;
          this.drawTrend(this.ctx);
        })
    }
    .padding(12)
    .borderRadius(12)
    .backgroundColor(0xFFFFFFFF)
    .borderWidth(1)
    .borderColor(0x1A000000)
  }

  private drawTrend(ctx: CanvasRenderingContext2D): void {
    const width: number = ctx.width;
    const height: number = ctx.height;
    const paddingX: number = 10;
    const paddingY: number = 12;

    const values: number[] = this.getSafeValues();
    let minVal: number = values[0];
    let maxVal: number = values[0];
    for (let i = 1; i < values.length; i++) {
      if (values[i] < minVal) {
        minVal = values[i];
      }
      if (values[i] > maxVal) {
        maxVal = values[i];
      }
    }
    if (maxVal - minVal < 1) {
      maxVal = minVal + 1;
    }

    ctx.clearRect(0, 0, width, height);

    // 背景渐变
    const background = ctx.createLinearGradient(0, 0, 0, height);
    background.addColorStop(0, '#FFEDEE');
    background.addColorStop(1, '#FFFFFF');
    ctx.fillStyle = background;
    ctx.fillRect(0, 0, width, height);

    const stepX: number = (width - paddingX * 2) / (values.length - 1);
    const chartHeight: number = height - paddingY * 2;
    const points: ChartPoint[] = [];
    for (let i = 0; i < values.length; i++) {
      const ratio: number = (values[i] - minVal) / (maxVal - minVal);
      const x = paddingX + stepX * i;
      const y = height - paddingY - ratio * chartHeight;
      points.push(new ChartPoint(x, y));
    }

    // 填充区域
    this.buildCurvePath(ctx, points);
    ctx.lineTo(points[points.length - 1].x, height - paddingY);
    ctx.lineTo(points[0].x, height - paddingY);
    ctx.closePath();

    const fill = ctx.createLinearGradient(0, 0, 0, height);
    fill.addColorStop(0, 'rgba(255, 92, 92, 0.35)');
    fill.addColorStop(1, 'rgba(255, 92, 92, 0)');
    ctx.fillStyle = fill;
    ctx.fill();

    // 折线描边
    this.buildCurvePath(ctx, points);
    ctx.strokeStyle = '#FF5C5C';
    ctx.lineWidth = 2;
    ctx.lineJoin = 'round';
    ctx.lineCap = 'round';
    ctx.stroke();

    // 节点与数值
    ctx.fillStyle = '#FF5C5C';
    ctx.font = '12vp sans-serif';
    ctx.textAlign = 'center';
    ctx.textBaseline = 'bottom';
    for (let i = 0; i < points.length; i++) {
      const point = points[i];
      ctx.beginPath();
      ctx.arc(point.x, point.y, 3, 0, Math.PI * 2);
      ctx.fill();
      ctx.fillText(values[i].toString(), point.x, point.y - 6);
    }
  }

  private getSafeValues(): number[] {
    if (this.values.length > 1) {
      return this.values;
    }
    const fallback: number = this.values.length === 1 ? this.values[0] : 0;
    return [fallback, fallback];
  }

  private buildCurvePath(ctx: CanvasRenderingContext2D, points: ChartPoint[]): void {
    if (points.length < 2) {
      return;
    }
    ctx.beginPath();
    ctx.moveTo(points[0].x, points[0].y);
    for (let i = 0; i < points.length - 1; i++) {
      const p0: ChartPoint = i > 0 ? points[i - 1] : points[i];
      const p1: ChartPoint = points[i];
      const p2: ChartPoint = points[i + 1];
      const p3: ChartPoint = i + 2 < points.length ? points[i + 2] : p2;

      const cp1 = new ChartPoint(
        p1.x + (p2.x - p0.x) / 6,
        p1.y + (p2.y - p0.y) / 6
      );
      const cp2 = new ChartPoint(
        p2.x - (p3.x - p1.x) / 6,
        p2.y - (p3.y - p1.y) / 6
      );

      ctx.bezierCurveTo(cp1.x, cp1.y, cp2.x, cp2.y, p2.x, p2.y);
    }
  }
}

@Entry
@Component
export default struct HealthDetailPage {
  private context: common.UIAbilityContext = getContext() as common.UIAbilityContext;
  private healthStore: HealthRecordStoreManager = HealthRecordStoreManager.getInstance();
  private careStore: CareUserStoreManager = CareUserStoreManager.getInstance();

  @StorageLink('healthDataRefresh') @Watch('onHealthRefreshChanged') private refreshKey: number = 0;
  @StorageLink('isLogin') @Watch('onLoginStateChanged') private isLogin: boolean = false;
  @StorageLink('userName') @Watch('onLoginUserChanged') private ownerName: string = '未登录';

  // 状态变量
  @State selectedUser: HealthUser | null = null;
  @State private users: HealthUser[] = [];
  @State selectedHealthType: string = '心率';
  @State currentTabIndex: number = 0;
  @State showHealthData: boolean = false;
  @State dataList: HealthData[] = [];
  @State chartValues: number[] = [];
  @State chartSeed: number = 0;
  @State currentValueText: string = '--';

  // 静态数据
  private healthTypes: string[] = HealthDataManager.getHealthTypes();
  @State private userOptions: SelectOption[] = [];
  private routeUserId: string = '';
  private routeType: string = '';

  // 生命周期回调 - 初始化数据
  aboutToAppear(): void {
    this.readRouteParams();
    this.loadUsers();
  }

  private onHealthRefreshChanged(): void {
    this.loadUsers();
  }

  private onLoginStateChanged(): void {
    this.loadUsers();
  }

  private onLoginUserChanged(): void {
    this.loadUsers();
  }

  private readRouteParams(): void {
    const params = router.getParams() as HealthDetailRouteParams;
    if (!params) {
      return;
    }
    if (typeof params.userId === 'string') {
      this.routeUserId = params.userId;
    } else if (typeof params.userId === 'number') {
      this.routeUserId = params.userId.toString();
    }
    if (typeof params.type === 'string') {
      this.routeType = params.type;
    }
  }

  private async loadUsers(): Promise<void> {
    const merged: HealthUser[] = [];
    const staticUsers: HealthUser[] = HealthDataManager.getUsers();
    for (let i = 0; i < staticUsers.length; i++) {
      merged.push(staticUsers[i]);
    }

    if (this.isLogin && this.ownerName && this.ownerName !== '未登录') {
      try {
        await this.careStore.initKvStore(this.context);
        const careUsers: CareUserRecord[] = await this.careStore.getUsers(this.ownerName);
        for (let i = 0; i < careUsers.length; i++) {
          const record: CareUserRecord = careUsers[i];
          if (!this.hasUser(merged, record.id, record.name)) {
            merged.push(new HealthUser(record.id, record.name));
          }
        }
      } catch (err) {
        console.error('[HealthDetail] load care users failed:', err);
      }
    }

    this.users = merged;
    this.userOptions = merged.map((user: HealthUser) => {
      return new SelectOption(user.id, user.name);
    });

    if (this.users.length === 0) {
      this.selectedUser = null;
      this.dataList = [];
      this.chartValues = [];
      this.currentValueText = '--';
      this.chartSeed++;
      return;
    }

    await this.applyRouteSelection();
  }

  private hasUser(list: HealthUser[], id: string, name: string): boolean {
    for (let i = 0; i < list.length; i++) {
      if (list[i].id === id || list[i].name === name) {
        return true;
      }
    }
    return false;
  }

  private async applyRouteSelection(): Promise<void> {
    let targetUser: HealthUser | null = null;
    if (this.routeUserId) {
      for (let i = 0; i < this.users.length; i++) {
        if (this.users[i].id === this.routeUserId) {
          targetUser = this.users[i];
          break;
        }
      }
    }
    if (!targetUser) {
      targetUser = this.users[0];
    }
    await this.selectUser(targetUser);

    if (this.routeType) {
      const typeIndex: number = this.healthTypes.indexOf(this.routeType);
      if (typeIndex >= 0) {
        this.currentTabIndex = typeIndex;
        await this.selectHealthType(this.routeType);
      }
    }
  }

  // 选择用户
  private async selectUser(user: HealthUser): Promise<void> {
    this.selectedUser = user;
    this.showHealthData = false;
    // 重置 Tab 状态
    this.currentTabIndex = 0;
    this.selectedHealthType = this.healthTypes[0] || '心率';
    await this.selectHealthType(this.selectedHealthType);
  }

  // 选择健康数据类型
  private async selectHealthType(type: string): Promise<void> {
    this.selectedHealthType = type;
    if (this.selectedUser) {
      this.showHealthData = true;
      await this.loadCurrentHealthData();
    }
  }

  // 处理 Tab 切换
  private handleTabChange(index: number): void {
    this.currentTabIndex = index;
    const type = this.healthTypes[index];
    if (type) {
      this.selectHealthType(type);
    }
  }

  private async loadCurrentHealthData(): Promise<void> {
    this.dataList = await this.getCurrentHealthData();
    this.updateChartData();
  }

  // 获取当前用户的健康数据
  private async getCurrentHealthData(): Promise<HealthData[]> {
    if (!this.selectedUser) {
      return [];
    }
    return this.getHealthDataByUserAndType(this.selectedUser.id, this.selectedHealthType);
  }

  private isStaticUser(userId: string): boolean {
    return userId.indexOf('static_') === 0;
  }

  private async getHealthDataByUserAndType(userId: string, type: string): Promise<HealthData[]> {
    if (this.isStaticUser(userId)) {
      return HealthDataManager.getHealthData(userId, type);
    }
    if (!this.isLogin || !this.ownerName || this.ownerName === '未登录') {
      return [];
    }
    await this.healthStore.initKvStore(this.context);
    return this.healthStore.getRecordsByUserAndType(this.ownerName, userId, type);
  }

  private updateChartData(): void {
    if (this.dataList.length === 0) {
      this.chartValues = [];
      this.currentValueText = '--';
      this.chartSeed++;
      return;
    }
    const ordered: HealthData[] = this.orderBySubmitTime(this.dataList);
    const values: number[] = [];
    for (let i = 0; i < ordered.length; i++) {
      const parsed: number = this.parseNumber(ordered[i].value);
      if (parsed > 0) {
        values.push(parsed);
      }
    }
    this.chartValues = values;
    const latest: HealthData = this.getLatestFromList(this.dataList);
    this.currentValueText = this.formatHealthValue(latest);
    this.chartSeed++;
  }

  private orderBySubmitTime(list: HealthData[]): HealthData[] {
    if (list.length === 0) {
      return [];
    }
    if (typeof list[0].submitTime !== 'number') {
      return list;
    }
    const ordered: HealthData[] = list.slice(0);
    ordered.sort((a: HealthData, b: HealthData) => {
      const timeA: number = typeof a.submitTime === 'number' ? a.submitTime : 0;
      const timeB: number = typeof b.submitTime === 'number' ? b.submitTime : 0;
      return timeA - timeB;
    });
    return ordered;
  }

  private getLatestFromList(list: HealthData[]): HealthData {
    const ordered: HealthData[] = this.orderBySubmitTime(list);
    return ordered[ordered.length - 1];
  }

  private parseNumber(value: string): number {
    let numStr: string = '';
    for (let i = 0; i < value.length; i++) {
      const ch = value.charAt(i);
      if ((ch >= '0' && ch <= '9') || ch === '.') {
        numStr += ch;
      } else if (numStr.length > 0) {
        break;
      }
    }
    if (numStr.length === 0) {
      return 0;
    }
    return Number(numStr);
  }

  private formatHealthValue(data: HealthData): string {
    const unit: string = data.unit ? data.unit : '';
    if (unit.length > 0 && data.value.indexOf(unit) < 0) {
      return `${data.value} ${unit}`;
    }
    return data.value;
  }

  private openHealthForm(): void {
    router.pushUrl({ url: 'pages/HealthRecordFormPage' });
  }

  /** ---------- 公共行：左标题 / 右内容 ---------- */
  @Builder
  InfoRow(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize($r('app.float.service_body_font_size'))
        .fontColor($r('app.color.service_secondary_text_color'))

      Blank().layoutWeight(1)

      Text(value)
        .fontSize($r('app.float.service_body_font_size'))
        .fontColor($r('app.color.service_primary_text_color'))
    }
    .margin({
      left: $r('app.float.service_text_left_right_margin'),
      right: $r('app.float.service_text_left_right_margin'),
      bottom: $r('app.float.service_text_bottom_margin')
    })
  }

  /** ---------- Tab 标题（绿色选中态） ---------- */
  @Builder
  TabTitle(title: string, index: number) {
    Column() {
      Text(title)
        .fontSize($r('app.float.service_body_font_size'))
        .fontColor(
          this.currentTabIndex === index
            ? $r('app.color.service_button_background_color')
            : $r('app.color.service_secondary_text_color')
        )

      if (this.currentTabIndex === index) {
        Blank()
          .height(2)
          .width(24)
          .backgroundColor($r('app.color.service_button_background_color'))
          .margin({ top: 4 })
      }
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  /** ---------- 构建 Tab 内容 ---------- */
  @Builder
  HealthDataTab() {
    Scroll() {
      Column() {
        /** ---------- 曲线图区域 ---------- */
        HealthTrendCard({
          title: this.selectedHealthType,
          valueText: this.currentValueText,
          values: this.chartValues,
          refreshSeed: this.chartSeed
        })
        .width('100%')
        .margin({
          top: $r('app.float.service_detail_card_space'),
          bottom: $r('app.float.service_detail_card_space')
        })

        /** ---------- 数据表格区域 ---------- */
        Column() {
          if (this.dataList.length > 0) {
            // 表格头部
            Row() {
              Text('测量时间')
                .width('50%')
                .fontSize($r('app.float.service_body_font_size'))
                .fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.service_secondary_text_color'))
                .textAlign(TextAlign.Center)

              Text('测量数据')
                .width('50%')
                .fontSize($r('app.float.service_body_font_size'))
                .fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.service_secondary_text_color'))
                .textAlign(TextAlign.Center)
            }
            .width('100%')
            .padding({ top: 12, bottom: 12 })
            .backgroundColor(0xFFF0F0F0)
            .borderRadius(8)
            .margin({
              left: $r('app.float.service_text_left_right_margin'),
              right: $r('app.float.service_text_left_right_margin'),
              bottom: $r('app.float.service_text_bottom_margin')
            })

            // 数据行
            ForEach(this.dataList, (item: HealthData, index?: number) => {
              Row() {
                Text(item.measurementTime)
                  .width('50%')
                  .fontSize($r('app.float.service_body_font_size'))
                  .fontColor($r('app.color.service_primary_text_color'))
                  .textAlign(TextAlign.Center)

                Text(`${item.value} ${item.unit || ''}`)
                  .width('50%')
                  .fontSize($r('app.float.service_body_font_size'))
                  .fontColor($r('app.color.service_primary_text_color'))
                  .textAlign(TextAlign.Center)
              }
              .width('100%')
              .padding({ top: 10, bottom: 10 })
              .backgroundColor((index || 0) % 2 === 0 ? $r('app.color.service_card_background_color') : 0xFFF9F9F9)
              .borderRadius(4)
              .margin({
                left: $r('app.float.service_text_left_right_margin'),
                right: $r('app.float.service_text_left_right_margin'),
                bottom: $r('app.float.service_text_bottom_margin')
              })
            }, (item: HealthData) => `${item.userId}-${item.type}-${item.measurementTime}`)
          } else {
            // 无数据提示
            Column() {
              Text('暂无数据')
                .fontSize($r('app.float.service_body_font_size'))
                .fontColor($r('app.color.service_secondary_text_color'))
                .margin({ top: 40, bottom: 40 })
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
          }
        }
        .margin({
          left: $r('app.float.service_detail_card_space'),
          right: $r('app.float.service_detail_card_space')
        })
        .align(Alignment.Top)

        Blank().height(8)
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
    }
    .align(Alignment.Top)
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Column() {
      /** ---------- 顶部导航栏 ---------- */
      Row() {
        Text('健康数据')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .fontSize($r('app.float.common_nav_title_font_size'))
          .fontColor($r('app.color.common_nav_text_color'))
      }
      .height($r('app.float.common_nav_height'))
      .margin({bottom : 5})

      /** ---------- 主内容区域 ---------- */
      Column() {
        // 用户选择区域
        Column() {
          // 使用 Select 组件选择用户（显示人名）
          Select(this.userOptions)
            .selected(this.selectedUser ? this.userOptions.findIndex(option => option.label === this.selectedUser!.id) : -1)
            .value(
              this.selectedUser
                ? this.selectedUser.name
                : '请选择用户'
            )
            .width('100%')
            .height(20)
            .backgroundColor($r('app.color.service_card_background_color'))
            .borderRadius($r('app.float.service_card_radius'))
            .border({
              width: $r('app.float.service_card_border_width'),
              color: $r('app.color.service_card_border_color')
            })
            .padding({ left: 16, right: 16 })
            .font({ size: $r('app.float.service_body_font_size') })
            .fontColor($r('app.color.service_primary_text_color'))
            .onSelect((index: number, value: string) => {
              if (index >= 0) {
                if (index < this.users.length) {
                  this.selectUser(this.users[index]);
                }
              }
            })
        }
        .backgroundColor($r('app.color.service_card_background_color'))
        .borderRadius($r('app.float.service_card_radius'))
        .borderWidth($r('app.float.service_card_border_width'))
        .borderColor($r('app.color.service_card_border_color'))
        .margin({
          left: $r('app.float.service_detail_card_space'),
          right: $r('app.float.service_detail_card_space'),
          top: $r('app.float.service_detail_card_space')
        })
        .padding({
          top: $r('app.float.service_detail_card_space'),
          bottom: $r('app.float.service_detail_card_space'),
          left: $r('app.float.service_text_left_right_margin'),
          right: $r('app.float.service_text_left_right_margin')
        })

        /** ---------- Tab 区域（健康数据类型选择） ---------- */
        Column() {
          // 只有当选择了用户时才显示 Tab
          if (this.selectedUser) {
            Tabs({ index: this.currentTabIndex }) {
              ForEach(this.healthTypes, (type: string, index: number) => {
                TabContent() {
                  this.HealthDataTab();
                }.tabBar(this.TabTitle(type, index))
              })
            }
            .onChange(index => this.handleTabChange(index))
            .barMode(BarMode.Fixed)
            .barHeight(48)
            .height('auto')
            .width('100%')
            .layoutWeight(1)
            /** ---------- 修改四：顶端对齐 ---------- */
            .align(Alignment.Top)
          } else {
            // 未选择用户时的提示
            Column() {
              Text('请先选择用户')
                .fontSize($r('app.float.service_body_font_size'))
                .fontColor($r('app.color.service_secondary_text_color'))
                .margin({ top: 100, bottom: 100 })
            }
            .width('100%')
            .height('100%')
            .justifyContent(FlexAlign.Center)
          }
        }
        .backgroundColor($r('app.color.service_card_background_color'))
        .borderRadius($r('app.float.service_card_radius'))
        .borderWidth($r('app.float.service_card_border_width'))
        .borderColor($r('app.color.service_card_border_color'))
        .margin({
          left: $r('app.float.service_detail_card_space'),
          right: $r('app.float.service_detail_card_space'),
          top: $r('app.float.service_detail_card_space')
        })
        /** ---------- 修改四：顶端对齐 ---------- */
        .alignSelf(ItemAlign.Start)
        .layoutWeight(1)
      }
      .layoutWeight(1)
      .width('100%')
      /** ---------- 修改四：顶端对齐 ---------- */
      .justifyContent(FlexAlign.Start)
    }
      .width('100%')
      .height('100%')

      // 右下角新增健康数据按钮（浮层）
      Row() {
        Text('+')
          .fontSize(28)
          .fontColor(0xFFFFFFFF)
      }
      .width(54)
      .height(54)
      .backgroundColor($r('app.color.service_button_background_color'))
      .borderRadius(27)
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .align(Alignment.BottomEnd)
      .margin({ right: 20, bottom: 20 })
      .onClick(() => {
        this.openHealthForm();
      })
      .zIndex(10)
    }
    .width('100%')
    .height('100%')
    .linearGradient({
      angle: 180,
      colors: [
        [0xFF2EC7A8, 0.0],
        [0xFFA0EACD, 0.35],
        [0xFFF5FFFC, 0.5],
        [0xFFFFFFFF, 1.0]
      ]
    })
    .expandSafeArea(
      [SafeAreaType.SYSTEM],
      [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]
    )
  }
}
