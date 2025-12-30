// 导入数据模型
import { User, HealthData, HealthDataManager } from '../model/HealthData';

// 选择器选项类型
interface SelectOption {
  label: string;
  value: string;
}

@Component
export default struct HealthTab {
  // 状态变量
  @State selectedUser: User | null = null;
  @State selectedHealthType: string = '心率';
  @State currentTabIndex: number = 0;
  @State showHealthData: boolean = false;
  @State dataList: HealthData[] = [];

  // 静态数据
  private healthTypes: string[] = HealthDataManager.getHealthTypes();
  private userOptions: SelectOption[] = [];

  // 生命周期回调 - 初始化数据
  aboutToAppear(): void {
    this.updateUserOptions();
  }

  // 更新用户选项
  private updateUserOptions(): void {
    const users = HealthDataManager.getUsers();
    const options: SelectOption[] = [];

    users.forEach(user => {
      const option: SelectOption = {
        label: user.id.toString(),
        value: user.name
      };
      options.push(option);
    });

    this.userOptions = options;

    // 默认选择第一个用户
    if (users.length > 0 && !this.selectedUser) {
      this.selectUser(users[0]);
    }
  }

  // 选择用户
  private selectUser(user: User) {
    this.selectedUser = user;
    this.showHealthData = false;
    // 重置 Tab 状态
    this.currentTabIndex = 0;
    this.selectedHealthType = this.healthTypes[0] || '心率';
  }

  // 选择健康数据类型
  private selectHealthType(type: string) {
    this.selectedHealthType = type;
    if (this.selectedUser) {
      this.showHealthData = true;
      this.dataList = this.getCurrentHealthData();
    }
  }

  // 处理 Tab 切换
  private handleTabChange(index: number) {
    this.currentTabIndex = index;
    const type = this.healthTypes[index];
    if (type) {
      this.selectHealthType(type);
    }
  }

  // 获取当前用户的健康数据
  private getCurrentHealthData(): HealthData[] {
    if (!this.selectedUser) {
      return [];
    }
    return HealthDataManager.getHealthData(this.selectedUser.id, this.selectedHealthType);
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
        /** ---------- 修改一：添加占位空白容器（用于后续插图） ---------- */
        Column() {
          // 这里可以后续添加插图或图表
          // 当前先保持空白，设置固定高度
        }
        .height(2) // 占位高度，可根据插图需求调整
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
            .selected(this.selectedUser ? this.userOptions.findIndex(option => option.label === this.selectedUser!.id.toString()) : -1)
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
                const users = HealthDataManager.getUsers();
                this.selectUser(users[index]);
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