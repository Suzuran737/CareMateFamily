// HealthTab.ets - 用户健康 Tab（纯 UI 静态占位版）
//
// ✅ 目标：先把页面结构/布局搭好（标题 + 用户下拉选择 + 多张健康数据卡片）
// - 静态用户 + KvStore 用户数据混合展示
// - UI 风格尽量对齐你给的 ArchiveTab：顶部标题栏 + 内容区标题带下划线 + 卡片圆角/浅灰背景/边框
//
// 🧩 交互：
// - 使用 Select 下拉选择用户
// - 选择不同用户后，更新页面展示的静态数据（占位文字）
//
// ⚠️ 注意：
// - 该 Tab 一般由 MainTabPage 引用，因此不加 @Entry
// - 如果你希望它单独运行测试，再加 @Entry 即可

import router from '@ohos.router';
import type common from '@ohos.app.ability.common';
import { CareUserStoreManager, CareUserRecord } from '../utils/CareUserStoreManager';
import { HealthRecordStoreManager } from '../utils/HealthRecordStoreManager';
import { HealthData, HealthDataManager, HealthUser } from '../model/HealthData';

class SelectOption {
  value: string;

  constructor(value: string) {
    this.value = value;
  }
}

class HealthUiSnapshot {
  heartRateText: string;   // 心率
  spo2Text: string;        // 血氧
  tempText: string;        // 体温
  glucoseText: string;     // 血糖
  bpText: string;          // 血压
  stressText: string;      // 压力
  sleepText: string;       // 睡眠
  updatedText: string;     // 更新时间

  constructor(
    heartRateText: string,
    spo2Text: string,
    tempText: string,
    glucoseText: string,
    bpText: string,
    stressText: string,
    sleepText: string,
    updatedText: string
  ) {
    this.heartRateText = heartRateText;
    this.spo2Text = spo2Text;
    this.tempText = tempText;
    this.glucoseText = glucoseText;
    this.bpText = bpText;
    this.stressText = stressText;
    this.sleepText = sleepText;
    this.updatedText = updatedText;
  }
}

class ChartPoint {
  x: number;
  y: number;

  constructor(x: number, y: number) {
    this.x = x;
    this.y = y;
  }
}

class HealthDetailRouteParams {
  type: string;
  userId?: string;

  constructor(type: string, userId?: string) {
    this.type = type;
    if (userId !== undefined) {
      this.userId = userId;
    }
  }
}

/**
 * 通用卡片（小卡片）：颜色块 + 标题 + 值（占位）
 */
@Component
struct HealthSmallCard {
  @Prop title: string;
  @Prop value: string;
  @Prop blockColor: number = 0xFFEAF7F2; // 默认浅绿块
  @Prop useImage: boolean = false;
  @Prop useBars: boolean = false;
  @Prop image: Resource = $r('app.media.health_example1');
  @Prop barValues: number[] = [];
  @Prop barColor: number = 0xFF2FB86E;
  @Prop @Watch('onBarRefreshChanged') barRefreshSeed: number = 0;
  private barCtx: CanvasRenderingContext2D = new CanvasRenderingContext2D();
  private barReady: boolean = false;

  private onBarRefreshChanged(): void {
    if (!this.barReady) {
      return;
    }
    this.drawBars(this.barCtx);
  }

  build() {
    Column() {
      // 顶部：标题
      Text(this.title)
        .fontSize(14)
        .fontColor(0xFF666666)
        .margin({ bottom: 6 })

      // 中部：值
      Text(this.value)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(0xFF333333)
        .margin({ bottom: 10 })

      // 底部：颜色块占位 / 图片示例
      if (this.useImage) {
        Image(this.image)
          .width('100%')
          .height(60)
          .objectFit(ImageFit.Cover)
          .borderRadius(10)
          .backgroundColor(this.blockColor)
          .clip(true)
      } else if (this.useBars) {
        Canvas(this.barCtx)
          .width('100%')
          .height(70)
          .borderRadius(10)
          .backgroundColor(this.blockColor)
          .clip(true)
          .onReady(() => {
            this.barReady = true;
            this.drawBars(this.barCtx);
          })
      } else {
        Row()
          .width('100%')
          .height(46)
          .backgroundColor(this.blockColor)
          .borderRadius(10)
      }
    }
    .alignItems(HorizontalAlign.Start)
    .padding({ top: 12, bottom: 4 })
    .borderRadius(12)
    .backgroundColor(0xFFFFFFFF)
    .borderWidth(1)
    .borderColor(0x1A000000)
  }

  private drawBars(ctx: CanvasRenderingContext2D): void {
    const width: number = ctx.width;
    const height: number = ctx.height;
    const paddingX: number = 10;
    const paddingY: number = 8;

    const isEmpty: boolean = this.barValues.length === 0;
    const values: number[] = this.getSafeBarValues();
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

    const barAreaWidth: number = width - paddingX * 2;
    const slotWidth: number = barAreaWidth / values.length;
    const barWidth: number = Math.max(6, slotWidth * 0.32);
    const baseY: number = height - paddingY;
    const barMaxHeight: number = height - paddingY * 2 - 10;

    for (let i = 0; i < values.length; i++) {
      const ratio: number = (values[i] - minVal) / (maxVal - minVal);
      const barHeight: number = isEmpty ? 2 : Math.max(8, ratio * barMaxHeight);
      const x: number = paddingX + slotWidth * i + (slotWidth - barWidth) / 2;
      const y: number = baseY - barHeight;

      ctx.fillStyle = this.barColor;
      ctx.fillRect(x, y, barWidth, barHeight);

      ctx.fillStyle = '#FF6A6A';
      ctx.font = '10vp sans-serif';
      ctx.textAlign = 'center';
      ctx.textBaseline = 'bottom';
      ctx.fillText(values[i].toString(), x + barWidth / 2, y - 2);
    }
  }

  private getSafeBarValues(): number[] {
    if (this.barValues.length > 0) {
      return this.barValues;
    }
    return [0];
  }
}

/**
 * 小卡片曲线图：用于睡眠等小尺寸曲线展示
 */
@Component
struct HealthSmallLineCard {
  @Prop title: string;
  @Prop value: string;
  @Prop blockColor: number = 0xFFEAF7F2;
  @Prop lineValues: number[] = [];
  @Prop lineColor: number = 0xFF2FB86E;
  @Prop @Watch('onLineRefreshChanged') lineRefreshSeed: number = 0;
  private lineCtx: CanvasRenderingContext2D = new CanvasRenderingContext2D();
  private lineReady: boolean = false;

  private onLineRefreshChanged(): void {
    if (!this.lineReady) {
      return;
    }
    this.drawLine(this.lineCtx);
  }

  build() {
    Column() {
      Text(this.title)
        .fontSize(14)
        .fontColor(0xFF666666)
        .margin({ bottom: 6 })

      Text(this.value)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(0xFF333333)
        .margin({ bottom: 10 })

      Canvas(this.lineCtx)
        .width('100%')
        .height(70)
        .borderRadius(10)
        .backgroundColor(this.blockColor)
        .clip(true)
        .onReady(() => {
          this.lineReady = true;
          this.drawLine(this.lineCtx);
        })
    }
    .alignItems(HorizontalAlign.Start)
    .padding({ top: 12, bottom: 4 })
    .borderRadius(12)
    .backgroundColor(0xFFFFFFFF)
    .borderWidth(1)
    .borderColor(0x1A000000)
  }

  private drawLine(ctx: CanvasRenderingContext2D): void {
    const width: number = ctx.width;
    const height: number = ctx.height;
    const paddingX: number = 8;
    const paddingY: number = 10;

    const values: number[] = this.getSafeLineValues();
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
    fill.addColorStop(0, 'rgba(46, 199, 168, 0.35)');
    fill.addColorStop(1, 'rgba(46, 199, 168, 0)');
    ctx.fillStyle = fill;
    ctx.fill();

    // 折线描边
    this.buildCurvePath(ctx, points);
    ctx.strokeStyle = this.toHexColor(this.lineColor);
    ctx.lineWidth = 2;
    ctx.lineJoin = 'round';
    ctx.lineCap = 'round';
    ctx.stroke();

    // 节点数值
    ctx.fillStyle = this.toHexColor(this.lineColor);
    ctx.font = '10vp sans-serif';
    ctx.textAlign = 'center';
    ctx.textBaseline = 'bottom';
    for (let i = 0; i < points.length; i++) {
      const point = points[i];
      ctx.beginPath();
      ctx.arc(point.x, point.y, 2.5, 0, Math.PI * 2);
      ctx.fill();
      ctx.fillText(values[i].toString(), point.x, point.y - 4);
    }
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

  private getSafeLineValues(): number[] {
    if (this.lineValues.length > 1) {
      return this.lineValues;
    }
    const fallback: number = this.lineValues.length === 1 ? this.lineValues[0] : 0;
    return [fallback, fallback];
  }

  private toHexColor(color: number): string {
    const hex: string = color.toString(16).padStart(8, '0').toUpperCase();
    return `#${hex}`;
  }
}

/**
 * 通用卡片（大卡片）：用于顶部“心率”类似的大块展示
 */
@Component
struct HealthLargeCard {
  @Prop title: string;
  @Prop value: string;
  @Prop subtitle: string = '';
  @Prop blockColor: number = 0xFFF8EAEA; // 默认浅红块
  @Prop chartValues: number[] = [];
  @Prop @Watch('onRefreshSeedChanged') refreshSeed: number = 0;
  private ctx: CanvasRenderingContext2D = new CanvasRenderingContext2D();
  private ready: boolean = false;

  private onRefreshSeedChanged(): void {
    if (!this.ready) {
      return;
    }
    this.drawHeartRate(this.ctx);
  }

  build() {
    Column() {
      Row() {
        Column() {
          Text(this.title)
            .fontSize(14)
            .fontColor(0xFF666666)

          Text(this.value)
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(0xFF333333)
            .margin({ top: 6 })
        }
        .alignItems(HorizontalAlign.Start)

        Blank().layoutWeight(1)

        // 右上角：更新时间占位
        if (this.subtitle.length > 0) {
          Text(this.subtitle)
            .fontSize(12)
            .fontColor(0xFF999999)
        }
      }
      .margin({ bottom: 10 })

      // 心率曲线 Canvas
      Canvas(this.ctx)
        .width('100%')
        .height(90)
        .borderRadius(12)
        .onReady(() => {
          this.ready = true;
          this.drawHeartRate(this.ctx);
        })
    }
    .alignItems(HorizontalAlign.Start)
    .padding(12)
    .borderRadius(12)
    .backgroundColor(0xFFFFFFFF)
    .borderWidth(1)
    .borderColor(0x1A000000)
  }

  private drawHeartRate(ctx: CanvasRenderingContext2D): void {
    const width: number = ctx.width;
    const height: number = ctx.height;
    const paddingX: number = 8;
    const paddingY: number = 10;

    let values: number[] = [];
    if (this.chartValues.length > 0) {
      values = this.chartValues.slice(0);
    } else {
      values = [0, 0, 0, 0];
    }
    if (values.length < 2) {
      const fallback: number = values.length > 0 ? values[0] : 78;
      while (values.length < 2) {
        values.push(fallback);
      }
    }

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

  private parseHeartRate(text: string): number {
    let numStr = '';
    for (let i = 0; i < text.length; i++) {
      const ch = text.charAt(i);
      if (ch >= '0' && ch <= '9') {
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
}

@Component
export default struct HealthTab {
  private context: common.UIAbilityContext = getContext() as common.UIAbilityContext;
  private healthStore: HealthRecordStoreManager = HealthRecordStoreManager.getInstance();
  private careStore: CareUserStoreManager = CareUserStoreManager.getInstance();

  @StorageLink('healthDataRefresh') @Watch('onHealthRefreshChanged') private refreshKey: number = 0;
  @StorageLink('isLogin') @Watch('onLoginStateChanged') private isLogin: boolean = false;
  @StorageLink('userName') @Watch('onLoginUserChanged') private ownerName: string = '未登录';

  /** 用户列表（静态用户 + 康养用户） */
  @State private users: HealthUser[] = [];
  // 下拉选项（参照 ServiceReservationPage 的 Select 写法）
  @State private userOptions: SelectOption[] = [];

  /** 当前选中的用户下标（用于 UI 展示与数据切换） */
  @State private selectedIndex: number = 0;

  /** 当前展示的健康数据（静态占位） */
  @State private snapshot: HealthUiSnapshot = new HealthUiSnapshot('', '', '', '', '', '', '', '');
  /** 当前心率曲线数据 */
  @State private heartRateValues: number[] = [];
  /** 触发曲线重绘的标记 */
  @State private heartRateSeed: number = 0;
  /** 血氧柱状图数据 */
  @State private spo2Bars: number[] = [];
  /** 压力柱状图数据 */
  @State private stressBars: number[] = [];
  /** 睡眠曲线数据 */
  @State private sleepValues: number[] = [];
  /** 触发柱状图重绘 */
  @State private barSeed: number = 0;
  /** 触发睡眠曲线重绘 */
  @State private sleepSeed: number = 0;

  aboutToAppear(): void {
    this.loadUsersAndRefresh();
  }

  private onHealthRefreshChanged(): void {
    this.loadUsersAndRefresh();
  }

  private onLoginStateChanged(): void {
    this.loadUsersAndRefresh();
  }

  private onLoginUserChanged(): void {
    this.loadUsersAndRefresh();
  }

  /**
   * 合并静态用户与康养用户
   */
  private async loadUsersAndRefresh(): Promise<void> {
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
        console.error('[HealthTab] load care users failed:', err);
      }
    }

    this.users = merged;
    this.userOptions = merged.map((item: HealthUser) => new SelectOption(item.name));

    if (this.users.length === 0) {
      this.selectedIndex = -1;
      this.resetSnapshot();
      return;
    }

    if (this.selectedIndex < 0 || this.selectedIndex >= this.users.length) {
      this.selectedIndex = 0;
    }

    await this.applySnapshotByIndex(this.selectedIndex);
  }

  private hasUser(list: HealthUser[], id: string, name: string): boolean {
    for (let i = 0; i < list.length; i++) {
      if (list[i].id === id || list[i].name === name) {
        return true;
      }
    }
    return false;
  }

  private resetSnapshot(): void {
    this.snapshot = new HealthUiSnapshot('', '', '', '', '', '', '', '');
    this.heartRateValues = [];
    this.spo2Bars = [];
    this.stressBars = [];
    this.sleepValues = [];
    this.heartRateSeed++;
    this.barSeed++;
    this.sleepSeed++;
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

  private async getLatestHealthValue(userId: string, type: string): Promise<HealthData | null> {
    const list: HealthData[] = await this.getHealthDataByUserAndType(userId, type);
    if (list.length === 0) {
      return null;
    }
    const ordered: HealthData[] = this.orderBySubmitTime(list);
    return ordered[ordered.length - 1];
  }

  private formatHealthValue(data: HealthData | null, fallback: string): string {
    if (data === null) {
      return fallback;
    }
    const value: string = data.value;
    const unit: string = data.unit ? data.unit : '';
    if (unit.length > 0 && value.indexOf(unit) < 0) {
      return `${value} ${unit}`;
    }
    return value;
  }

  private async buildSnapshotForUser(userId: string): Promise<HealthUiSnapshot> {
    const heartRate: HealthData | null = await this.getLatestHealthValue(userId, '心率');
    const spo2: HealthData | null = await this.getLatestHealthValue(userId, '血氧');
    const temp: HealthData | null = await this.getLatestHealthValue(userId, '体温');
    const glucose: HealthData | null = await this.getLatestHealthValue(userId, '血糖');
    const bp: HealthData | null = await this.getLatestHealthValue(userId, '血压');
    const sleep: HealthData | null = await this.getLatestHealthValue(userId, '睡眠');
    const stress: HealthData | null = await this.getLatestHealthValue(userId, '压力');

    const updatedText: string = heartRate ? heartRate.measurementTime : '刚刚更新';

    return new HealthUiSnapshot(
      this.formatHealthValue(heartRate, '--'),
      this.formatHealthValue(spo2, '--'),
      this.formatHealthValue(temp, '--'),
      this.formatHealthValue(glucose, '--'),
      this.formatHealthValue(bp, '--'),
      this.formatHealthValue(stress, '--'),
      this.formatHealthValue(sleep, '--'),
      updatedText
    );
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

  private async getHeartRateSeries(userId: string): Promise<number[]> {
    const list: HealthData[] = this.orderBySubmitTime(
      await this.getHealthDataByUserAndType(userId, '心率')
    );
    const values: number[] = [];
    for (let i = 0; i < list.length; i++) {
      const parsed: number = this.parseNumber(list[i].value);
      if (parsed > 0) {
        values.push(parsed);
      }
    }
    return values;
  }

  private async getBarSeries(userId: string, type: string): Promise<number[]> {
    const list: HealthData[] = this.orderBySubmitTime(
      await this.getHealthDataByUserAndType(userId, type)
    );
    const values: number[] = [];
    for (let i = 0; i < list.length; i++) {
      const parsed: number = this.parseNumber(list[i].value);
      if (parsed > 0) {
        values.push(parsed);
      }
    }
    if (values.length === 0) {
      return [];
    }
    const maxCount: number = 4;
    const startIndex: number = Math.max(0, values.length - maxCount);
    return values.slice(startIndex);
  }

  private async getLineSeries(userId: string, type: string): Promise<number[]> {
    const list: HealthData[] = this.orderBySubmitTime(
      await this.getHealthDataByUserAndType(userId, type)
    );
    const values: number[] = [];
    for (let i = 0; i < list.length; i++) {
      const parsed: number = this.parseNumber(list[i].value);
      if (parsed > 0) {
        values.push(parsed);
      }
    }
    return values;
  }

  /**
   * 根据用户下标切换数据
   * - 真实项目：这里可以改成 await load(userId) 再 this.snapshot = xxx
   */
  private async applySnapshotByIndex(index: number): Promise<void> {
    if (this.users.length === 0) {
      return;
    }
    const safeIndex: number = Math.max(0, Math.min(index, this.users.length - 1));
    this.selectedIndex = safeIndex;

    const userId: string = this.users[safeIndex].id;
    this.snapshot = await this.buildSnapshotForUser(userId);
    this.heartRateValues = await this.getHeartRateSeries(userId);
    this.heartRateSeed++;
    this.spo2Bars = await this.getBarSeries(userId, '血氧');
    this.stressBars = await this.getBarSeries(userId, '压力');
    this.barSeed++;
    this.sleepValues = await this.getLineSeries(userId, '睡眠');
    this.sleepSeed++;
  }

  private openHealthDetail(type: string): void {
    let userId: string | undefined = undefined;
    if (this.users.length > 0 && this.selectedIndex >= 0 && this.selectedIndex < this.users.length) {
      userId = this.users[this.selectedIndex].id;
    }
    const params: HealthDetailRouteParams = new HealthDetailRouteParams(type, userId);
    router.pushUrl({
      url: 'pages/HealthDetailPage',
      params: params
    });
  }

  private openHealthForm(): void {
    router.pushUrl({ url: 'pages/HealthRecordFormPage' });
  }

  build() {
    Stack({alignContent: Alignment.BottomEnd}) {
      Column() {
        // 1) 顶部标题栏（固定高度，风格对齐 ArchiveTab）
        Row() {
          Text('健康')
            .fontSize($r('app.float.home_header_title_font_size'))
            .fontWeight(FontWeight.Normal)
            .fontColor(0xFFFFFFFF)
        }
        .height($r('app.float.home_header_height'))
        .margin({ bottom: 5 })
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)

        // 2) 滚动内容区
        Scroll() {
          Column() {
            // ---------- 页面标题：用户健康 + 下划线 ----------
            Row() {
              Column() {
                Text('用户健康')
                  .fontSize(28)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(0xFF333333)

                // 下划线（从文字开头开始）
                Row()
                  .width(84)
                  .height(3)
                  .backgroundColor(0xFF333333)
                  .borderRadius(2)
                  .margin({ top: 6 })
              }
              .alignItems(HorizontalAlign.Start)
              .margin({ left: $r('app.float.home_health_section_title_left_margin') })
            }
            .width('100%')
            .margin({ top: 20, bottom: 12 })
            .justifyContent(FlexAlign.Start)
            .alignItems(VerticalAlign.Center)

            Row() {
              // 下拉选择用户
              Select(this.userOptions)
                .selected(this.selectedIndex)
                .value(
                  this.userOptions.length > 0 && this.selectedIndex >= 0
                    ? this.userOptions[this.selectedIndex].value
                    : '暂无用户'
                )
                .font({ size: 16 })
                .fontColor(0xFF333333)
                .onSelect((index: number, value: string) => {
                  this.applySnapshotByIndex(index);
                })
            }
            .width('90%')
            .height(44)
            .padding({ left: 12, right: 12 })
            .backgroundColor(0xFFFFFFFF)
            .borderRadius(10)
            .borderWidth(1)
            .borderColor(0x1A000000)
            .margin({ bottom: 12 })
            // ---------- 顶部大卡片（心率折线占位） ----------
            Column() {
              HealthLargeCard({
                title: '心率',
                value: this.snapshot.heartRateText,
                subtitle: this.snapshot.updatedText,
                blockColor: 0xFFF8EAEA,
                chartValues: this.heartRateValues,
                refreshSeed: this.heartRateSeed
              })
            }
            .onClick((): void => {
              this.openHealthDetail('心率');
            })
            .width('90%')
            .margin({ bottom: 12 })

            // ---------- 两列小卡片区域（颜色块 + 文字占位） ----------
            // 第一行
            Row({ space: 12 }) {
              Column() {
              HealthSmallCard({
                title: '血氧饱和度',
                value: this.snapshot.spo2Text,
                blockColor: 0xFFEAF7F2,
                useBars: true,
                barValues: this.spo2Bars,
                barColor: 0xFF2FB86E,
                barRefreshSeed: this.barSeed
              })
              }
              .onClick((): void => {
                this.openHealthDetail('血氧');
              })
              .layoutWeight(1)

              Column() {
                HealthSmallCard({
                  title: '体温',
                  value: this.snapshot.tempText,
                  blockColor: 0xFFF3F0FF,
                  useImage: true,
                  image: $r('app.media.health_example1')
                })
              }
              .onClick((): void => {
                this.openHealthDetail('体温');
              })
              .layoutWeight(1)
            }
            .width('90%')
            .margin({ bottom: 12 })

            // 第二行
            Row({ space: 12 }) {
              Column() {
                HealthSmallCard({
                  title: '血糖',
                  value: this.snapshot.glucoseText,
                  blockColor: 0xFFFFF3E5,
                  useImage: true,
                  image: $r('app.media.health_example2')
                })
              }
              .onClick((): void => {
                this.openHealthDetail('血糖');
              })
              .layoutWeight(1)

              Column() {
                HealthSmallCard({
                  title: '血压',
                  value: this.snapshot.bpText,
                  blockColor: 0xFFF8EAEA,
                  useImage: true,
                  image: $r('app.media.health_example3')
                })
              }
              .onClick((): void => {
                this.openHealthDetail('血压');
              })
              .layoutWeight(1)
            }
            .width('90%')
            .margin({ bottom: 12 })

            // 第三行
            Row({ space: 12 }) {
              Column() {
              HealthSmallCard({
                title: '压力',
                value: this.snapshot.stressText,
                blockColor: 0xFFEAF7F2,
                useBars: true,
                barValues: this.stressBars,
                barColor: 0xFF2FB86E,
                barRefreshSeed: this.barSeed
              })
              }
              .onClick((): void => {
                this.openHealthDetail('压力');
              })
              .layoutWeight(1)

              Column() {
                HealthSmallLineCard({
                  title: '睡眠',
                  value: this.snapshot.sleepText,
                  blockColor: 0xFFEFF7FF,
                  lineValues: this.sleepValues,
                  lineColor: 0xFF2EC7A8,
                  lineRefreshSeed: this.sleepSeed
                })
              }
              .onClick((): void => {
                this.openHealthDetail('睡眠');
              })
              .layoutWeight(1)
            }
            .width('90%')
            .margin({ bottom: 18 })

            // 底部留白：避免内容贴底/被手势条遮挡
            Blank().height(24)
          }
          .width('100%')
          // 关键：让内容从顶部开始排布（避免空数据时标题“跑中间”的错觉）
          .justifyContent(FlexAlign.Start)
          .alignItems(HorizontalAlign.Center)
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .backgroundColor('#EEEEEE')
      }
      .width('100%')
      .height('100%')
      // 与你项目整体一致的渐变背景（可按需删除）
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
      .margin({ right: 20, bottom: 20 })
      .zIndex(10)
      .onClick(() => {
        this.openHealthForm();
      })
    }
    .width('100%')
    .height('100%')
  }
}
