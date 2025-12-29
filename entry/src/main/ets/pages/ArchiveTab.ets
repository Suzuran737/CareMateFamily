// 用户档案 Tab 页面
import { UserInfo } from '../model/AdmissionRecord';

@Component
struct UserCard {
  // 使用@Prop装饰器实现卡片复用
  @Prop user: UserInfo;
  @State private isExpanded: boolean = false;

  build() {
    Column({ space: 4 }) {
      // 卡片主体：左右布局
      Row({ space: 8 }) {
        // 左侧：头像和姓名
        Column({ space: 8 }) {
          // 头像
          Image(this.user.gender === '男' ? $r('app.media.ic_user'): $r('app.media.ic_user'))
            .width(70)
            .height(70)
            .borderRadius(35)
            .objectFit(ImageFit.Cover)
            .backgroundColor(Color.Gray)

          // 姓名
          Text(this.user.name)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .width('20%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)

        // 右侧：详细信息
        Column({ space: 6 }) {
          // 性别角标（右上角）
          Row() {
            Text(this.user.gender === '男' ? '♂' : '♀')
              .fontSize(12)
              .fontColor(this.user.gender === '男' ? Color.Blue : Color.Red)
              .margin({ right: 2 })

            Text(this.user.gender)
              .fontSize(12)
              .fontColor(Color.Black)
          }
          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
          .borderRadius(4)
          .backgroundColor(this.user.gender === '男' ?
            '#E6F3FF' : '#FFE6E6') // 浅蓝/浅红背景
          .alignSelf(ItemAlign.End) // 靠右对齐
          .margin({ bottom: 8 })

          // 信息行：关系
          this.buildInfoRow('关系', this.user.relationship)

          // 信息行：生日
          this.buildInfoRow('生日', this.user.birthday)

          // 信息行：身份证
          this.buildInfoRow('身份证', this.user.idCard)
        }
        .width('80%')
      }
      .padding(16)
    }
    .backgroundColor(0xFFFFFFFF)
    .borderWidth($r('app.float.home_health_card_border_width'))
    .borderColor(0x28000000)
    .borderRadius($r('app.float.home_health_card_radius'))
    .clip(true)
    .margin({
      left: $r('app.float.home_health_card_horizontal_margin'),
      right: $r('app.float.home_health_card_horizontal_margin'),
      top: $r('app.float.home_health_card_top_margin')
    })
    //.onClick(() => this.onEdit(this.user.id))
  }

  // 构建信息行的私有方法
  @Builder
  private buildInfoRow(label: string, value: string) {
    Row() {
      // 标签（灰色左对齐）
      Text(label)
        .fontSize(13)
        .fontColor('#666666') // 灰色
        .textAlign(TextAlign.Start)
        .width('40%')

      // 信息（黑色右对齐）
      Text(value)
        .fontSize(13)
        .fontColor(Color.Black)
        .textAlign(TextAlign.End)
        .width('60%')
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width('100%')
    .margin({ bottom: 4,right: 4})
  }
}

@Component
struct TextSelector {
  @State isShowDialog: boolean = false
  @Prop selectedValue: string
  @Prop options: string[]
  @State private popupPosition: Position = { x: 0, y: 0 }
  onValueChange?: (value: string) => void

  build() {
    Column({ space: 20 }) {
      // 文本选择器
      Text(this.selectedValue||'点击选择')
        .id('selectorText')
        .fontSize(20)
        .fontColor(Color.Blue)
        .padding(10)
        .border({ width: 1, color: Color.Gray })
        .borderRadius(8)
        .onClick(async () => {
          this.isShowDialog = !this.isShowDialog
        })
      if (this.isShowDialog){
        Column() {
          ForEach(this.options, (item: string) => {
            Text(item)
              .fontSize(18)
              .width('100%')
              .padding(15)
              .backgroundColor(Color.White)
              .onClick(() => {
                this.onSelect(item)
              })
          }, (item: string) => item)
        }
        .width('100%')
        .height('auto') // 限制最大高度
        .border({ width: 1, color: Color.Gray })
        .borderRadius(8)
        .backgroundColor(Color.White)
        .shadow({ radius: 10, color: Color.Gray, offsetX: 0, offsetY: 5 })
        .position({ x: 0, y: 20 }) // 在文本下方
        .zIndex(999) // 确保在最顶层
        .onClick(() => {
          // 阻止冒泡，避免点击选项时关闭
        })
      }
    }
    .width('100%')
    .height('auto')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
  onSelect(item: string) {
    this.selectedValue = item
    this.isShowDialog = false
    if (this.onValueChange !== undefined) {
      this.onValueChange(item)
    }
  }
}

@Component
export default struct ArchiveTab {
  private users: UserInfo[] = []; // 用户数据数组
  @State showInlineForm: boolean = false;
  @State showEditForm: boolean = false;
  @State newItem: UserInfo = {id:'',name:'',avatar:'',gender:'',relationship:'',birthday:'',idCard:''}
  @State editingID: number = -1; // 正在编辑的项目索引
  aboutToAppear() {
    // 这里模拟数据，实际应从网络或本地获取
    this.users = this.getMockUsers();
  }

  build() {
    Column() {
      Column() {
        // 1. 顶部标题栏
        Row() {
          Text('康养用户列表')
            .fontSize($r('app.float.home_header_title_font_size'))
            .fontWeight(FontWeight.Normal)
            .fontColor(0xFFFFFFFF)
        }
        .height($r('app.float.home_header_height'))
        .margin({bottom : 5})
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)

        // 2. 用户信息区
        if (!this.showInlineForm && !this.showEditForm) {
          Scroll() {
            Column() {
              Row() {
                Text('用户列表')
                  .fontSize(30)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Color.Black)
                  .textAlign(TextAlign.Start)
                  .padding({ left: 15, top: 20 })
              }
              .width('100%')
              .justifyContent(FlexAlign.Start)

              Column({ space: 12 }) {
                // 使用ForEach循环渲染可复用卡片
                ForEach(this.users, (user: UserInfo) => {
                  UserCard({ user: user })
                }, (user: UserInfo) => user.id)
              }
              .padding(4)
              .width('100%')

              Text('没有更多了喵')
                .fontSize(12)
                .fontColor(Color.Grey)
                .opacity(0.9)
                .margin({ top: 15, bottom: 30 })
            }
            .width('100%')
            .height('100%')
          }
          .width('100%')
          .height('85%')
          .backgroundColor('#EEEEEE')
          .scrollBar(BarState.Off)
        }

        // 3. 底部按钮
        if (!this.showInlineForm && !this.showEditForm) {
          Row() {
            Button('添加康养用户')
              .layoutWeight(1)
              .height(44)
              .backgroundColor('#07C6A5')
              .fontColor(Color.White)
              .onClick(() => this.onAdd())
          }
          .width('95%')
        }

        // --- 4. 添加人员的遮罩层/表单 ---
        if (this.showInlineForm || this.showEditForm) {
          // 表单卡片
          Column() {
            Text(this.showEditForm ? '编辑用户' : '新增用户')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: 20 })

            Image($r('app.media.ic_user'))
              .width(70)
              .height(70)
              .borderRadius(35)
              .objectFit(ImageFit.Cover)
              .backgroundColor(Color.Gray)

            this.InputBuilder('姓名', '请输入姓名', this.newItem.name, (val) => this.newItem.name = val)
            this.InputBuilder('关系', '请输入关系', this.newItem.name, (val) => this.newItem.name = val)
            this.InputBuilder('性别', '请输入“男”或“女”', this.newItem.name, (val) => this.newItem.name = val)
            this.InputBuilder('身份证', '请输入身份证号', this.newItem.idCard, (val) => this.newItem.idCard = val)

            Row() {
              Button(this.showEditForm ? '删除用户' : '取消')
                .onClick(() => this.onFormCancel())
                .backgroundColor('#F5F5F5')
                .fontColor('#666')
                .layoutWeight(1)
                .margin({ right: 12 })

              Button(this.showEditForm ? '保存修改' : '确认添加')
                //.onClick(() => this.onFormSubmit())
                .backgroundColor('#07C6A5')
                .fontColor(Color.White)
                .layoutWeight(1)
            }
            .margin({ top: 20 })
          }
          .width('96%')
          .backgroundColor(Color.White)
          .borderRadius(10)
          .padding(24)
          .zIndex(11)
          .shadow({ radius: 20, color: '#4D000000', offsetY: 10 })
          .margin({ bottom: '20%' })
        }

      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')


  }

  @Builder InputBuilder(label: string, placeholder: string, value: string, onChange: (val: string) => void) {
    Row() {
      Text(label)
        .fontSize(14)
        .fontColor('#333')
        .textAlign(TextAlign.Start)
        .width('20%')

      TextInput({ placeholder: placeholder, text: value })
        .fontSize(14)
        .textAlign(TextAlign.End)
        .width('80%')
        .maxLines(1)
        .onChange((val) => onChange(val))
    }
    .width('100%')
    .margin({ bottom: 4,right: 4})
  }
  @Builder SelectBuilder(label: string, options: string[], selectedValue: string, onSelect: (val: string) => void) {
    Row() {
      Text(label)
        .fontSize(14)
        .fontColor('#333')
        .textAlign(TextAlign.Start)
        .width('40%')
      // 手动实现文本选择器
      TextSelector({selectedValue:selectedValue, options:options, onValueChange:(val: string) => {onSelect(val)} })
    }
    .width('100%')
    .height(40)
    .margin({ bottom: 12 })
  }


  onAdd() {
    this.newItem = {id:'',name:'',avatar:'',gender:'',relationship:'',birthday:'',idCard:''}
    this.showInlineForm = true;
    this.showEditForm = false;
    this.editingID = -1;
  }

  onFormCancel() {
    this.showInlineForm = false;
    this.showEditForm = false;
    this.editingID = -1;
    this.newItem = {id:'',name:'',avatar:'',gender:'',relationship:'',birthday:'',idCard:''}
  }

  // 模拟用户数据
  private getMockUsers(): UserInfo[] {
    return [
      {
        id: '1',
        name: '张三',
        avatar: 'https://example.com/avatar1.jpg',
        gender: '男',
        relationship: '朋友',
        birthday: '1990-05-15',
        idCard: '11010119900515****'
      },
      {
        id: '2',
        name: '李四',
        avatar: 'https://example.com/avatar2.jpg',
        gender: '女',
        relationship: '家人',
        birthday: '1988-11-23',
        idCard: '11010119881123****'
      },
      {
        id: '3',
        name: '王五',
        avatar: 'https://example.com/avatar3.jpg',
        gender: '男',
        relationship: '同事',
        birthday: '1995-03-08',
        idCard: '11010119950308****'
      }
    ];
  }
}
