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