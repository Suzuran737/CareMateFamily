// pages/AdmissionApplyPage.ets

import { AdmissionItem, AdmissionRecord, ApplyFormData } from '../model/AdmissionRecord';
import { KvStoreManager } from '../utils/KvStoreManager';
import { CareUserStoreManager, CareUserRecord } from '../utils/CareUserStoreManager';
import promptAction from '@ohos.promptAction';
import router from '@ohos.router';
import type common from '@ohos.app.ability.common';
import { BusinessError } from '@kit.BasicServicesKit';

class SelectOption {
  value: string;

  constructor(value: string) {
    this.value = value;
  }
}

@Entry
@Component
struct AdmissionApplyPage {
  // 状态管理
  @State items: AdmissionItem[] = [];
  @State showInlineForm: boolean = false;
  @State showEditForm: boolean = false;
  @State newItem: AdmissionItem = { name: '', org: '', dept: '', room: '', remark: '' };
  @State editingIndex: number = -1; // 正在编辑的项目索引
  @State private userOptions: SelectOption[] = [];
  @State private selectedUserIndex: number = -1;

  // 使用getContext()获取当前页面的context
  private context: common.UIAbilityContext = getContext() as common.UIAbilityContext;

  aboutToAppear() {
    console.info('页面上下文已获取:', this.context);

    // 初始化 KvStore
    if (this.context) {
      KvStoreManager.getInstance().initKvStore(this.context)
        .then(() => {
          console.info('KvStore初始化成功');
        })
        .catch((err: BusinessError) => {
          console.error('KvStore初始化失败: ', err.code, err.message);
          promptAction.showToast({
            message: '数据存储初始化失败',
            duration: 2000
          });
        });
    } else {
      console.error('无法获取UIAbilityContext，KvStore初始化失败。');
      promptAction.showToast({
        message: '系统上下文获取失败',
        duration: 2000
      });
    }

    this.loadCareUsers();
  }

  onPageShow(): void {
    this.loadCareUsers();
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column() {
        // --- 1. 标题栏 ---
        Row() {
          // 左：返回按钮（固定宽度）
          Row() {
            Text('‹')
              .fontSize($r('app.float.common_nav_icon_font_size'))
              .fontColor($r('app.color.common_nav_text_color'))
          }
          .width($r('app.float.common_nav_side_width'))
          .height($r('app.float.common_nav_height'))
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)
          .onClick(() => router.back())

          // 中：标题（占满剩余空间，居中）
          Text('入住申请')
            .fontSize($r('app.float.common_nav_title_font_size'))
            .fontWeight(FontWeight.Normal)
            .fontColor($r('app.color.common_nav_text_color'))
            .layoutWeight(1)
            .textAlign(TextAlign.Center)

          // 右：占位（与左边同宽，保证标题居中）
          Blank()
            .width($r('app.float.common_nav_side_width'))
        }
        .height($r('app.float.common_nav_height'))
        .width('100%')
        .alignItems(VerticalAlign.Center)

        // --- 2. 列表展示区域 ---
        if (this.items.length === 0) {
          Column() {
            Image($r('app.media.ic_user'))
              .width(100)
              .height(100)
              // .fillColor('#CCCCCC')
              .opacity(0.5)
              .margin({ top : 50 , bottom: 10 })
            Text('暂无入住人员，请点击下方按钮添加')
              .fontSize(14)
              .fontColor('#999999')
          }
          .width('100%')
          .height('30%')
          .justifyContent(FlexAlign.Center)
        } else {
          List({ space: 12 }) {
            ForEach(this.items, (item: AdmissionItem, index: number) => {
              ListItem() {
                Row() {
                  Column() {
                    Text(item.name)
                      .fontSize(16)
                      .fontWeight(FontWeight.Medium)
                    Text(`${item.org} | ${item.dept}`)
                      .fontSize(12)
                      .fontColor(Color.Gray)
                      .margin({ top: 4 })
                    if (item.room) {
                      Text(`房间: ${item.room}`)
                        .fontSize(12)
                        .fontColor('#666')
                        .margin({ top: 2 })
                    }
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)

                  // 操作按钮组
                  Row() {
                    // 编辑按钮
                    Button('编辑')
                      .type(ButtonType.Normal)
                      .backgroundColor('#1890FF')
                      .fontColor(Color.White)
                      .borderRadius(14)
                      .height(28)
                      .width(56)
                      .fontSize(12)
                      .margin({ right: 8 })
                      .onClick(() => this.onEdit(index))

                    // 删除按钮
                    Button('删除')
                      .type(ButtonType.Normal)
                      .backgroundColor('#FF4D4F')
                      .fontColor(Color.White)
                      .borderRadius(14)
                      .height(28)
                      .width(56)
                      .fontSize(12)
                      .onClick(() => this.onDelete(index))
                  }
                }
                .width('100%')
                .padding(16)
                .backgroundColor(Color.White)
                .borderRadius(12)
                .shadow({ radius: 4, color: '#1A000000', offsetY: 2 })
              }
            })
          }
          .width('100%')
          .layoutWeight(1)
          .padding({ left: 16, right: 16, bottom: 80 })
        }
      }
      .width('100%')
      .height('100%')


      // --- 3. 底部固定按钮区 ---
      if (!this.showInlineForm && !this.showEditForm) {
        Column() {
          Row() {
            Button('添加入住人')
              .layoutWeight(1)
              .height(44)
              .backgroundColor(Color.White)
              .fontColor('#07C6A5')
              .border({ width: 1, color: '#07C6A5' })
              .margin({ right: 12 })
              .onClick(() => this.onAdd())

            Button('提交申请')
              .layoutWeight(1)
              .height(44)
              .backgroundColor('#07C6A5')
              .fontColor(Color.White)
              .onClick(() => this.onApply())
          }
          .width('100%')
        }
        .padding(16)
        .backgroundColor(Color.White)
        .shadow({ radius: 10, color: '#1A000000', offsetY: -2 })
      }

      // --- 4. 添加人员的遮罩层/表单 ---
      if (this.showInlineForm || this.showEditForm) {
        // 半透明背景
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('#80000000')
          .onClick(() => this.onFormCancel())
          .zIndex(10)

        // 表单卡片
        Column() {
          Text(this.showEditForm ? '编辑入住人' : '新增入住人')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 20 })

          this.SelectNameRow()
          this.InputBuilder('机构', '请输入机构名称', this.newItem.org, (val) => this.newItem.org = val, true)
          this.InputBuilder('部门', '请输入部门名称', this.newItem.dept, (val) => this.newItem.dept = val, true)
          this.InputBuilder('房间', '请输入房间名称', this.newItem.room, (val) => this.newItem.room = val, false)
          this.InputBuilder('备注', '请输入备注信息', this.newItem.remark, (val) => this.newItem.remark = val, false)

          Row() {
            Button('取消')
              .onClick(() => this.onFormCancel())
              .backgroundColor('#F5F5F5')
              .fontColor('#666')
              .layoutWeight(1)
              .margin({ right: 12 })

            Button(this.showEditForm ? '保存修改' : '确认添加')
              .onClick(() => this.onFormSubmit())
              .backgroundColor('#07C6A5')
              .fontColor(Color.White)
              .layoutWeight(1)
          }
          .margin({ top: 20 })
        }
        .width('90%')
        .backgroundColor(Color.White)
        .borderRadius(16)
        .padding(24)
        .zIndex(11)
        .shadow({ radius: 20, color: '#4D000000', offsetY: 10 })
        .margin({ bottom: '20%' })
      }
    }
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
  }

  @Builder InputBuilder(label: string, placeholder: string, value: string, onChange: (val: string) => void, required: boolean) {
    Column() {
      Row() {
        Text(label).fontSize(14).fontColor('#333')
        if (required) {
          Text('*').fontSize(14).fontColor(Color.Red).margin({ left: 4 })
        }
      }
      .margin({ bottom: 6 })
      TextInput({ placeholder: placeholder, text: value })
        .height(40)
        .backgroundColor('#F5F7FA')
        .borderRadius(8)
        .onChange((val) => onChange(val))
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .margin({ bottom: 12 })
  }

  @Builder private SelectNameRow() {
    Column() {
      Row() {
        Text('姓名').fontSize(14).fontColor('#333')
        Text('*').fontSize(14).fontColor(Color.Red).margin({ left: 4 })
      }
      .margin({ bottom: 6 })

      Row() {
        Select(this.userOptions)
          .selected(this.selectedUserIndex)
          .value(
            this.selectedUserIndex >= 0
              ? this.userOptions[this.selectedUserIndex].value
              : '请选择姓名'
          )
          .font({ size: 14 })
          .fontColor('#333333')
          .onSelect((index: number, value: string) => {
            this.selectedUserIndex = index;
            this.newItem.name = value;
          })
          .width('100%')
      }
      .height(40)
      .backgroundColor('#F5F7FA')
      .borderRadius(8)
      .alignItems(VerticalAlign.Center)
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .margin({ bottom: 12 })
  }

  // --- 逻辑处理 ---
  onAdd() {
    this.newItem = { name: '', org: '', dept: '', room: '', remark: '' };
    this.selectedUserIndex = -1;
    this.showInlineForm = true;
    this.showEditForm = false;
    this.editingIndex = -1;
  }

  onEdit(index: number) {
    if (index >= 0 && index < this.items.length) {
      // 自定义拷贝：遍历AdmissionItem的属性逐一赋值
      const sourceItem = this.items[index] as AdmissionItem;
      const itemToEdit: AdmissionItem = {
        name: sourceItem.name,
        org: sourceItem.org,
        dept: sourceItem.dept,
        room: sourceItem.room,
        remark: sourceItem.remark // <-- 确保拷贝备注
      };

      this.newItem = itemToEdit;
      this.editingIndex = index;
      this.showEditForm = true;
      this.showInlineForm = false;
      this.syncSelectedUserIndex(this.newItem.name);
    } else {
      promptAction.showToast({ message: '无法找到要编辑的项', duration: 2000 });
    }
  }

  onDelete(index: number) {
    if (index >= 0 && index < this.items.length) {
      // 创建确认弹窗
      promptAction.showDialog({
        title: '确认删除',
        message: `确定要删除 ${this.items[index].name} 吗？`,
        buttons: [
          {
            text: '取消',
            color: '#666666'
          },
          {
            text: '确定',
            color: '#FF4D4F'
          }
        ]
      })
        .then(result => {
          if (result.index === 1) { // 点击确定
            // 使用 filter 创建新数组（避免状态更新问题）
            this.items = this.items.filter((_, idx) => idx !== index);
            promptAction.showToast({ message: '删除成功' });
          }
        })
        .catch((err: BusinessError) => {
          console.error('删除操作失败:', err);
        });
    }
  }

  onFormCancel() {
    this.showInlineForm = false;
    this.showEditForm = false;
    this.editingIndex = -1;
    this.newItem = { name: '', org: '', dept: '', room: '', remark: '' };
    this.selectedUserIndex = -1;
  }

  onFormSubmit() {
    const nameValue = this.newItem.name.trim();
    const orgValue = this.newItem.org.trim();
    const deptValue = this.newItem.dept.trim();

    if (!nameValue) {
      promptAction.showToast({ message: '姓名不能为空' });
      return;
    }
    if (!orgValue) {
      promptAction.showToast({ message: '机构不能为空' });
      return;
    }
    if (!deptValue) {
      promptAction.showToast({ message: '部门不能为空' });
      return;
    }

    const processedItem: AdmissionItem = {
      name: nameValue,
      org: orgValue,
      dept: deptValue,
      room: this.newItem.room.trim(),
      remark: this.newItem.remark.trim()
    };

    if (this.showEditForm && this.editingIndex >= 0) {
      // 编辑模式：更新现有项
      this.items = this.items.map((item, idx) => {
        return idx === this.editingIndex ? processedItem : item;
      });

      promptAction.showToast({ message: '修改成功' });
    } else {
      // 添加模式：添加新项
      this.items = [...this.items, processedItem];
      promptAction.showToast({ message: '添加成功' });
    }

    this.onFormCancel();
  }

  onApply() {
    if (this.items.length === 0) {
      promptAction.showToast({ message: '请至少添加一名入住人' });
      return;
    }

    // 创建确认弹窗
    promptAction.showDialog({
      title: '确认提交',
      message: `确定要提交 ${this.items.length} 人的申请吗？`,
      buttons: [
        {
          text: '再检查一下',
          color: '#666666'
        },
        {
          text: '确定提交',
          color: '#07C6A5'
        }
      ]
    })
      .then(result => {
        if (result.index === 1) { // 点击确定提交
          this.submitApplication();
        }
      })
      .catch((err: BusinessError) => {
        console.error('提交确认操作失败:', err);
      });
  }

  private async submitApplication() {
    // 1. 显式标注 boolean 类型
    const isSingle: boolean = this.items.length === 1;

    try {
      await KvStoreManager.getInstance().initKvStore(this.context);

      if (isSingle) {
        const item: AdmissionItem = this.items[0];
        const singleData: ApplyFormData = new ApplyFormData();

        singleData.name = item.name;
        singleData.org = item.org;
        singleData.dept = item.dept;

        // --- 核心修正：直接存入 room，不要再写进 remark ---
        singleData.room = item.room;
        singleData.remark = item.remark; // 备注恢复清净，不再显示“预排房间...”

        const record = new AdmissionRecord('SINGLE', singleData);
        await this.executeSave(record, true);
      } else {
        // --- 处理批量申请 ---
        const itemsCopy: AdmissionItem[] = this.items.map((item: AdmissionItem): AdmissionItem => {
          const newItem = new AdmissionItem();
          newItem.name = item.name;
          newItem.org = item.org;
          newItem.dept = item.dept;
          newItem.room = item.room;
          newItem.remark = item.remark;
          return newItem;
        });

        const record = new AdmissionRecord('MULTI', itemsCopy);
        await this.executeSave(record, false);
      }
    } catch (e) {
      console.error('提交过程发生异常');
    }
  }

  /**
   * 提取公共保存逻辑，确保存储过程也是强类型的
   */
  private async executeSave(record: AdmissionRecord, isSingle: boolean) {
    const success: boolean = await KvStoreManager.getInstance().saveRecord(record);
    if (success) {
      promptAction.showToast({
        message: isSingle ? '单人申请提交成功' : `已成功提交 ${this.items.length} 人的批量申请`,
        duration: 2000
      });
      this.items = [];
      setTimeout(() => {
        router.back();
      }, 500);
    }
  }

  private loadCareUsers(): void {
    const isLogin: boolean = AppStorage.get<boolean>('isLogin') === true;
    const ownerName: string = AppStorage.get<string>('userName') || '';
    if (!isLogin || !ownerName || ownerName === '未登录') {
      this.userOptions = [];
      this.selectedUserIndex = -1;
      return;
    }

    CareUserStoreManager.getInstance()
      .initKvStore(this.context)
      .then(() => CareUserStoreManager.getInstance().getUsers(ownerName))
      .then((list: CareUserRecord[]) => {
        this.userOptions = list.map((item: CareUserRecord) => {
          return new SelectOption(item.name);
        });
        this.syncSelectedUserIndex(this.newItem.name);
      })
      .catch((err: BusinessError) => {
        console.error('读取康养用户失败:', err);
        this.userOptions = [];
        this.selectedUserIndex = -1;
      });
  }

  private syncSelectedUserIndex(name: string): void {
    if (!name) {
      this.selectedUserIndex = -1;
      return;
    }
    let matchIndex = -1;
    for (let i = 0; i < this.userOptions.length; i++) {
      if (this.userOptions[i].value === name) {
        matchIndex = i;
        break;
      }
    }
    this.selectedUserIndex = matchIndex;
  }
}
