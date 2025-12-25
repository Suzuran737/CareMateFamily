// pages/AdmissionFormPage.ets

import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import type common from '@ohos.app.ability.common';
import { ApplyFormData, AdmissionRecord } from '../model/AdmissionRecord';
import { KvStoreManager } from '../utils/KvStoreManager';

@Entry
@Component
struct AdmissionFormPage {
  @State formData: ApplyFormData = new ApplyFormData();

  // 在ETS页面中，我们使用getContext()来获取当前组件的context
  // 这个context包含了UIAbilityContext的能力
  private context: common.UIAbilityContext = getContext() as common.UIAbilityContext;

  aboutToAppear() {
    console.info('页面上下文已获取:', this.context);

    // 初始化 KvStore
    if (this.context) {
      KvStoreManager.getInstance().initKvStore(this.context)
        .then(() => {
          console.info('KvStore初始化成功');
        })
        .catch((err: Error) => {
          console.error('KvStore初始化失败: ', err);
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
  }

  build() {
    Column() {
      // --- 1. 顶部导航栏 ---
      Row() {
        Text($r('sys.symbol.chevron_left'))
          .fontSize(24)
          .fontColor(Color.White)
          .margin({ left: 16 })
          .onClick(() => {
            try { router.back() } catch(e) {}
          })

        Text('入住申请')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .margin({ left: 12 })
      }
      .width('100%')
      .height(56)
      .alignItems(VerticalAlign.Center)
      .backgroundColor('#07C6A5')

      // --- 2. 中间滚动内容区 ---
      Scroll() {
        Column() {
          // 白底圆角卡片
          Column() {
            Row().height(10) // 顶部留白

            this.FormItem('康养用户', '请填写姓名', this.formData.name, (v) => this.formData.name = v, true)
            this.FormItem('机构名称', '请填写机构', this.formData.org, (v) => this.formData.org = v, true)
            this.FormItem('部门名称', '请填写部门', this.formData.dept, (v) => this.formData.dept = v, true)
            this.FormItem('备注信息', '如有特殊需求请填写', this.formData.remark, (v) => this.formData.remark = v, false)

            Row().height(10) // 底部留白
          }
          .backgroundColor(Color.White)
          .borderRadius(12)
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .margin(16)
          .shadow({ radius: 8, color: '#0F000000', offsetY: 2 })

          Text('请确保以上信息真实有效，提交后将进入审核流程。')
            .fontSize(12)
            .fontColor('#999999')
            .padding({ left: 24, right: 24 })
        }
        .width('100%')
        .padding({ bottom: 100 })
      }
      .layoutWeight(1)
      .align(Alignment.Top)
      .scrollBar(BarState.Auto)

      // --- 3. 底部提交按钮 ---
      Column() {
        Button('立即申请')
          .width('90%')
          .height(48)
          .borderRadius(24)
          .backgroundColor('#07C6A5')
          .fontColor(Color.White)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .shadow({ radius: 8, color: '#4D07C6A5', offsetY: 4 })
          .onClick(() => this.onSubmit())
      }
      .width('100%')
      .padding({ top: 12, bottom: 24 })
      .backgroundColor(Color.White)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F1F3F5')
  }

  // --- 封装表单行组件 ---
  @Builder FormItem(label: string, placeholder: string, value: string, onChange: (val: string) => void, isRequired: boolean) {
    Column() {
      Row() {
        Text(label)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333')

        if (isRequired) {
          Text('*').fontColor(Color.Red).margin({ left: 4 })
        }
      }
      .width('100%')
      .margin({ bottom: 8, top: 8 })

      TextInput({ placeholder: placeholder, text: value })
        .height(44)
        .backgroundColor('#F8F9FA')
        .borderRadius(8)
        .padding({ left: 12 })
        .onChange((val) => onChange(val))
        .width('100%')
    }
    .margin({ bottom: 12 })
  }

  // 示例：AdmissionFormPage.ets 里的提交方法
  async onSubmit() {
    if (!this.formData.name || !this.formData.org || !this.formData.dept) {
      promptAction.showToast({ message: '请填写必填项' });
      return;
    }

    // 构建记录对象
    const data = new ApplyFormData();
    data.name = this.formData.name;
    data.org = this.formData.org;
    data.dept = this.formData.dept;
    data.remark = this.formData.remark; // 这里的备注只存用户填写的备注
    data.room = ""; // 单人表单页如果没有房间输入框，这里可以设为空字符串

    const newRecord = new AdmissionRecord('SINGLE', data);

    try {
      // 1. 初始化数据库
      await KvStoreManager.getInstance().initKvStore(this.context);

      // 2. 关键：必须 await 结果，确保数据写进硬盘
      console.info('正在保存数据...');
      const success = await KvStoreManager.getInstance().saveRecord(newRecord);

      if (success) {
        promptAction.showToast({ message: '申请已提交成功' });
        // 3. 稍微延迟一下再返回，确保数据库持久化完成
        setTimeout(() => {
          router.back();
        }, 300);
      } else {
        promptAction.showToast({ message: '保存失败，请重试' });
      }
    } catch (e) {
      console.error('提交逻辑崩溃');
    }
  }
}