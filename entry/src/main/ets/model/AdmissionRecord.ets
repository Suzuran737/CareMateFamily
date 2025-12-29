// 1. 声明 AdmissionItem
export class AdmissionItem {
  name: string = '';
  org: string = '';
  dept: string = '';
  room: string = '';
}

// 2. 声明 ApplyFormData
export class ApplyFormData {
  name: string = '';
  org: string = '';
  dept: string = '';
  remark: string = '';
}

// *** 新增的申请记录结构 ***
export type AdmissionData = ApplyFormData | AdmissionItem[];

export class AdmissionRecord {
  id: string; // 唯一ID
  type: 'SINGLE' | 'MULTI'; // 申请类型
  submitTime: number;       // 提交时间戳
  status: 'PENDING' | 'APPROVED' | 'REJECTED'; // 申请状态
  data: AdmissionData;

  constructor(type: 'SINGLE' | 'MULTI', data: AdmissionData) {
    // 使用时间戳作为简单 ID
    this.id = 'record_' + Date.now().toString();
    this.type = type;
    this.submitTime = Date.now();
    this.status = 'PENDING';
    this.data = data;
  }
}

//用户档案信息
export class UserInfo {
  id: string = '';          // 用户ID
  name: string = '';        // 姓名
  avatar: string = '';      // 头像URL
  gender: string = '男'; // 性别
  relationship: string = ''; // 关系
  birthday: string = '';    // 生日
  idCard: string = '';      // 身份证号
}
//问诊订单信息
export class OrderInfo {
  id: string = '';          // ID
  paid: boolean = false;
  patient: string = '';
  doctor: string = '';
  time: string = '';
  amount: string = '';
  symptom: string = '';
  medical_history: string = '';
  allergy_history: string = '';
  diagnosis: string = '';
  prescription: string = '';
}
//药物信息
export class MedicineInfo {
  id: string = '';          // ID
  name: string = '';
  type: string = '';

}