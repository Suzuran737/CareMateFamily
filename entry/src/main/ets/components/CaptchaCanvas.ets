/**
 * CaptchaCanvas.ets
 * ------------------------------------------------------------
 * 功能：使用 ArkUI Canvas 绘制「彩色扭曲图片验证码」
 * - 随机生成验证码字符串（默认 4 位）
 * - 每个字符：随机颜色 + 随机旋转 + 随机倾斜（扭曲效果）
 * - 干扰线 + 噪点
 * - 点击验证码区域可刷新（重新生成并重绘）
 */

@Component
export struct CaptchaCanvas {
  /** 当前验证码（组件生成后写回页面，用于比对） */
  @Link code: string;

  /** 画布尺寸（vp） */
  // @Prop width: number = 110;
  // @Prop height: number = 36;

  /** 验证码长度 */
  @Prop length: number = 4;

  /**
   * 可选：外部刷新种子
   * - 页面里 this.captchaSeed++ 即可触发组件刷新
   */
  @Prop @Watch('onSeedChanged') seed: number = 0;

  /** Canvas 绘制上下文 */
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private ctx: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);

  /** Canvas 是否已就绪 */
  @State private ready: boolean = false;

  /** 字符集：去掉易混淆字符（0/O, 1/I 等） */
  private readonly charset: string = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  /** seed 变化时，触发刷新 */
  private onSeedChanged(): void {
    if (!this.ready) {
      return;
    }
    this.refresh();
  }

  /** 点击/外部触发：生成新验证码并重绘 */
  private refresh(): void {
    this.code = this.generateCode(this.length);
    this.draw();
  }

  /** 生成随机验证码字符串 */
  private generateCode(len: number): string {
    let out: string = '';
    for (let i: number = 0; i < len; i++) {
      const idx: number = Math.floor(Math.random() * this.charset.length);
      out += this.charset.charAt(idx);
    }
    return out;
  }

  private randInt(min: number, max: number): number {
    return Math.floor(Math.random() * (max - min + 1)) + min;
  }

  private clamp(n: number, min: number, max: number): number {
    if (n < min) return min;
    if (n > max) return max;
    return n;
  }

  /** 生成带透明度的 #AARRGGBB 颜色字符串 */
  private rgbaHex(r: number, g: number, b: number, a: number): string {
    const rr: number = this.clamp(r, 0, 255);
    const gg: number = this.clamp(g, 0, 255);
    const bb: number = this.clamp(b, 0, 255);
    const aa: number = this.clamp(a, 0, 255);

    const to2: (v: number) => string = (v: number): string => v.toString(16).padStart(2, '0');
    return `#${to2(aa)}${to2(rr)}${to2(gg)}${to2(bb)}`.toUpperCase();
  }

  /** 清屏 + 背景 */
  private drawBackground(w: number, h: number): void {
    // 背景浅色（带一点随机变化）
    const base: number = this.randInt(235, 248);
    this.ctx.fillStyle = this.rgbaHex(base, base, base, 255);
    this.ctx.fillRect(0, 0, w, h);

    // 轻微渐变/阴影感（再叠一层）
    const tintR: number = this.randInt(180, 240);
    const tintG: number = this.randInt(220, 255);
    const tintB: number = this.randInt(200, 245);
    this.ctx.fillStyle = this.rgbaHex(tintR, tintG, tintB, 50);
    this.ctx.fillRect(0, 0, w, h);
  }

  /** 干扰线 */
  private drawNoiseLines(w: number, h: number): void {
    const lines: number = this.randInt(3, 5);
    for (let i: number = 0; i < lines; i++) {
      const r: number = this.randInt(20, 200);
      const g: number = this.randInt(20, 200);
      const b: number = this.randInt(20, 200);
      this.ctx.strokeStyle = this.rgbaHex(r, g, b, this.randInt(80, 140));
      this.ctx.lineWidth = this.randInt(1, 2);

      const x1: number = this.randInt(0, w);
      const y1: number = this.randInt(0, h);
      const x2: number = this.randInt(0, w);
      const y2: number = this.randInt(0, h);
      const cx: number = this.randInt(0, w);
      const cy: number = this.randInt(0, h);

      this.ctx.beginPath();
      this.ctx.moveTo(x1, y1);
      // 用二次贝塞尔做“弯曲”干扰线
      this.ctx.quadraticCurveTo(cx, cy, x2, y2);
      this.ctx.stroke();
    }
  }

  /** 噪点 */
  private drawNoiseDots(w: number, h: number): void {
    const dots: number = this.randInt(25, 40);
    for (let i: number = 0; i < dots; i++) {
      const r: number = this.randInt(0, 255);
      const g: number = this.randInt(0, 255);
      const b: number = this.randInt(0, 255);
      this.ctx.fillStyle = this.rgbaHex(r, g, b, this.randInt(60, 130));

      const x: number = this.randInt(0, w);
      const y: number = this.randInt(0, h);
      const radius: number = this.randInt(1, 2);

      this.ctx.beginPath();
      this.ctx.arc(x, y, radius, 0, Math.PI * 2);
      this.ctx.fill();
    }
  }

  /** 绘制验证码字符（彩色 + 旋转 + 倾斜扭曲） */
  private drawChars(w: number, h: number): void {
    const text: string = (this.code && this.code.length > 0) ? this.code : this.generateCode(this.length);
    if (!this.code || this.code.length === 0) {
      // 如果页面传进来的 code 为空，组件自己补上并写回页面
      this.code = text;
    }

    this.ctx.textAlign = 'center';
    this.ctx.textBaseline = 'middle';

    const step: number = w / (this.length + 1);
    for (let i: number = 0; i < text.length; i++) {
      const ch: string = text.charAt(i);

      // 每个字符随机颜色
      const r: number = this.randInt(30, 220);
      const g: number = this.randInt(30, 220);
      const b: number = this.randInt(30, 220);
      this.ctx.fillStyle = this.rgbaHex(r, g, b, 255);

      // 字体大小：随高度浮动
      const fontSize: number = this.randInt(Math.floor(h * 0.55), Math.floor(h * 0.75));
      this.ctx.font = `bold ${fontSize}vp sans-serif`;

      // 位置：基础 + 抖动
      const x: number = step * (i + 1) + this.randInt(-2, 2);
      const y: number = Math.floor(h / 2) + this.randInt(-4, 4);

      // 扭曲：旋转 + 倾斜（shear）
      const rotate: number = (this.randInt(-25, 25) * Math.PI) / 180;     // -25°~25°
      const skewX: number = this.randInt(-10, 10) / 100;                  // -0.10~0.10

      this.ctx.save();
      this.ctx.translate(x, y);
      this.ctx.rotate(rotate);
      // transform(a, b, c, d, e, f)：这里用 c 做 x 方向倾斜
      this.ctx.transform(1, 0, skewX, 1, 0, 0);

      // 轻微描边增强可读性
      this.ctx.strokeStyle = this.rgbaHex(10, 10, 10, 120);
      this.ctx.lineWidth = 1;
      this.ctx.strokeText(ch, 0, 0);

      this.ctx.fillText(ch, 0, 0);
      this.ctx.restore();
    }
  }

  /** 外框 */
  private drawBorder(w: number, h: number): void {
    this.ctx.strokeStyle = this.rgbaHex(160, 160, 160, 180);
    this.ctx.lineWidth = 1;
    this.ctx.strokeRect(0.5, 0.5, w - 1, h - 1);
  }

  /** 一次完整重绘 */
  private draw(): void {
    const w: number = 110;
    const h: number = 36;

    // 清屏 + 背景
    this.ctx.clearRect(0, 0, w, h);
    this.drawBackground(w, h);

    // 干扰（先画线点，再画字也行；这里“线/点在字上面”更像图片验证码）
    this.drawChars(w, h);
    this.drawNoiseLines(w, h);
    this.drawNoiseDots(w, h);

    this.drawBorder(w, h);
  }

  build() {
    // 用 Stack 包一层，方便加圆角裁剪 + 点击事件
    Stack() {
      Canvas(this.ctx)
        .width(this.width)
        .height(this.height)
        .onReady(() => {
          this.ready = true;
          // 首次生成并绘制验证码
          this.refresh();
        })
    }
    .width(this.width)
    .height(this.height)
    .borderRadius(8)
    .clip(true)
    .onClick(() => {
      // 点击刷新验证码
      if (this.ready) {
        this.refresh();
      }
    })
  }
}
