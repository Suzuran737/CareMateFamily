// 导入数据模型
import { User, HealthData, HealthDataManager } from '../model/HealthData';

@Component
export default struct HealthTab {
  @State selectedUser: User | null = null;
  @State selectedHealthType: string = '心率';
  @State showUserSelector: boolean = false;
  @State showHealthData: boolean = false;
  @State dataList:HealthData[] = [];

  // 获取健康数据类型列表
  private healthTypes: string[] = HealthDataManager.getHealthTypes();

  // 获取用户列表
  private users: User[] = HealthDataManager.getUsers();

  // 选择用户
  private selectUser(user: User) {
    this.selectedUser = user;
    this.showUserSelector = false;
    this.showHealthData = false;
  }

  // 选择健康数据类型
  private selectHealthType(type: string) {
    this.selectedHealthType = type;
    if (this.selectedUser) {
      this.showHealthData = true;
    }
  }

  // 获取当前用户的健康数据
  private getCurrentHealthData(): HealthData[] {
    if (!this.selectedUser) {
      return [];
    }
    return HealthDataManager.getHealthData(this.selectedUser.id, this.selectedHealthType);
  }

  build() {
    Column() {
      // 1. 顶部标题栏
      Row() {
        Text('健康')
          .fontSize($r('app.float.home_header_title_font_size'))
          .fontWeight(FontWeight.Normal)
          .fontColor(0xFFFFFFFF)
      }
      .height($r('app.float.home_header_height'))
      .margin({ bottom: 20 })
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)

      // 2. 用户选择按钮
      Button(this.selectedUser ? this.selectedUser.name : '选择用户')
        .width('90%')
        .height(48)
        .fontSize(18)
        .backgroundColor(0x007DFF)
        .fontColor(0xFFFFFFFF)
        .margin({ bottom: 20 })
        .onClick(() => {
          this.showUserSelector = true;
        })

      // 3. 用户选择弹窗
      if (this.showUserSelector) {
        Column() {
          // 弹窗标题
          Row() {
            Text('选择用户')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .margin({ top: 20, bottom: 20 })
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)

          // 用户列表
          ForEach(this.users, (user: User, index?: number) => {
            Row() {
              Text(user.name)
                .fontSize(18)
                .fontColor(0xFF000000)
            }
            .width('100%')
            .height(50)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(0xFFFFFFFF)
            .borderRadius(8)
            .margin({ bottom: 10 })
            .padding(10)
            .onClick(() => {
              this.selectUser(user);
              this.dataList = this.getCurrentHealthData();
            })
          }, (user: User) => user.id.toString())

          // 关闭按钮
          Button('取消')
            .width('80%')
            .height(40)
            .margin({ top: 20, bottom: 20 })
            .onClick(() => {
              this.showUserSelector = false;
            })
        }
        .width('80%')
        .backgroundColor(0xF5F5F5FF)
        .borderRadius(12)
        .shadow({ radius: 20, color: 0x40000000 })
        .alignItems(HorizontalAlign.Center)
        .position({ x: '10%', y: '25%' })
        .zIndex(100)
      }

      // 4. 健康数据选择（当用户被选中时显示）
      if (this.selectedUser) {
        Column() {
          Text('选择健康数据')
            .fontSize(16)
            .fontColor(0xFF666666)
            .margin({ bottom: 15 })

          // 健康数据类型选择 - 使用Column和Row代替Wrap
          Column() {
            // 第一行
            Row() {
              ForEach(this.healthTypes.slice(0, 4), (type: string) => {
                Text(type)
                  .fontSize(14)
                  .fontColor(this.selectedHealthType === type ? 0xFFFFFFFF : 0xFF007DFF)
                  .padding({ left: 15, right: 15, top: 8, bottom: 8 })
                  .backgroundColor(this.selectedHealthType === type ? 0xFF007DFF : 0xFFFFFFFF)
                  .borderRadius(20)
                  .border({ width: 1, color: 0xFF007DFF })
                  .margin({ right: 10, bottom: 10 })
                  .onClick(() => {
                    this.selectHealthType(type);
                  })
              })
            }
            .margin({ bottom: 5 })

            // 第二行
            Row() {
              ForEach(this.healthTypes.slice(4), (type: string) => {
                Text(type)
                  .fontSize(14)
                  .fontColor(this.selectedHealthType === type ? 0xFFFFFFFF : 0xFF007DFF)
                  .padding({ left: 15, right: 15, top: 8, bottom: 8 })
                  .backgroundColor(this.selectedHealthType === type ? 0xFF007DFF : 0xFFFFFFFF)
                  .borderRadius(20)
                  .border({ width: 1, color: 0xFF007DFF })
                  .margin({ right: 10, bottom: 10 })
                  .onClick(() => {
                    this.selectHealthType(type);
                  })
              })
            }
          }
          .margin({ bottom: 20 })
        }
        .width('90%')
        .alignItems(HorizontalAlign.Start)
        .margin({ bottom: 20 })
      }

      // 5. 健康数据表格（当有数据时显示）
      if (this.showHealthData && this.selectedUser) {
        Column() {
          // 表格标题
          Row() {
            Text(`${this.selectedUser.name}的${this.selectedHealthType}数据`)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor(0xFF333333)
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .margin({ bottom: 15 })

          // 表格头部
          Row() {
            Text('测量时间')
              .width('50%')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor(0xFF666666)
              .textAlign(TextAlign.Center)

            Text('测量数据')
              .width('50%')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor(0xFF666666)
              .textAlign(TextAlign.Center)
          }
          .width('100%')
          .padding({ top: 10, bottom: 10 })
          .backgroundColor(0xFFF0F0F0)
          .borderRadius(8)
          .margin({ bottom: 10 })

          if (this.dataList.length > 0) {
            ForEach(this.dataList, (item: HealthData, index?: number) => {
              Row() {
                Text(item.measurementTime)
                  .width('50%')
                  .fontSize(14)
                  .fontColor(0xFF333333)
                  .textAlign(TextAlign.Center)

                Text(`${item.value} ${item.unit || ''}`)
                  .width('50%')
                  .fontSize(14)
                  .fontColor(0xFF333333)
                  .textAlign(TextAlign.Center)
              }
              .width('100%')
              .padding({ top: 8, bottom: 8 })
              .backgroundColor((index || 0) % 2 === 0 ? 0xFFFFFFFF : 0xFFF9F9F9)
              .borderRadius(4)
            }, (item: HealthData) => `${item.userId}-${item.type}-${item.measurementTime}`)
          } else {
            // 无数据提示
            Column() {
              Text('暂无数据')
                .fontSize(16)
                .fontColor(0xFF999999)
                .margin({ top: 40, bottom: 40 })
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
          }
        }
        .width('90%')
        .padding(15)
        .backgroundColor(0xFFFFFFFF)
        .borderRadius(12)
        .shadow({ radius: 8, color: 0x1A000000 })
      } else if (this.selectedUser) {
        // 提示选择健康数据类型
        Column() {
          Text('请选择上方健康数据类型查看')
            .fontSize(16)
            .fontColor(0xFF999999)
            .margin({ top: 40, bottom: 40 })
        }
        .width('90%')
        .justifyContent(FlexAlign.Center)
      }

      // 空白区域，用于布局填充
      Blank()
    }
    .width('100%')
    .height('100%')
    .backgroundColor(0xFFF5F5F5)
    .padding({ top: 10 })
  }
}