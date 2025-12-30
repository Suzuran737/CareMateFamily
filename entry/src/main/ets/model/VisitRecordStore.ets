import { OrderInfo, PrescriptionDetail } from './AdmissionRecord';

// 内存中的问诊记录缓存（模拟数据）
let visitRecordCache: OrderInfo[] = [];
// 是否已初始化缓存
let initialized: boolean = false;

// 说明：该模块用于列表/详情/支付页面共享订单状态

// 获取问诊记录列表（返回拷贝，避免外部直接修改缓存）
export function getVisitRecordList(): OrderInfo[] {
  ensureInit();
  return visitRecordCache.slice();
}

// 获取默认展示的订单（用于详情页兜底）
export function getDefaultVisitRecord(): OrderInfo {
  ensureInit();
  if (visitRecordCache.length > 0) {
    return visitRecordCache[0];
  }
  return buildOrder(
    'ORD20231127001',
    '赵智晟',
    false,
    '张玉峰',
    '2024-04-26 15:34:24',
    '￥34',
    '发热、胸闷、无力、咳嗽',
    '无',
    '海鲜过敏',
    '发热',
    buildPrescription('#1 999感冒灵', '中成药', '9包', '1', '1', '1', '10', '10', '热水冲服')
  );
}

// 根据订单 ID 获取单条记录
export function getVisitRecordById(id: string): OrderInfo | null {
  // 通过 ID 查找订单，用于详情页/支付页同步状态
  ensureInit();
  for (let i: number = 0; i < visitRecordCache.length; i++) {
    if (visitRecordCache[i].id === id) {
      return visitRecordCache[i];
    }
  }
  return null;
}

// 标记订单为已支付（仅修改内存状态）
export function markVisitRecordPaid(id: string): void {
  const order = getVisitRecordById(id);
  if (order) {
    order.paid = true;
  }
}

// 初始化缓存（只执行一次）
function ensureInit(): void {
  if (!initialized) {
    visitRecordCache = buildMockOrders();
    initialized = true;
  }
}

// 构建模拟问诊记录数据
function buildMockOrders(): OrderInfo[] {
  return [
    buildOrder(
      'ORD20231127001',
      '赵智晟',
      true,
      '张玉峰',
      '2024-04-26 15:34:24',
      '￥34',
      '发热、胸闷、无力、咳嗽',
      '无',
      '海鲜过敏',
      '发热',
      buildPrescription('#1 999感冒灵', '中成药', '9包', '1', '1', '1', '10', '10', '热水冲服')
    ),
    buildOrder(
      'ORD20231127002',
      '李梅',
      false,
      '王洁',
      '2024-04-28 10:12:08',
      '￥56',
      '头痛、乏力',
      '高血压',
      '无',
      '偏头痛',
      buildPrescription('#1 布洛芬缓释胶囊', '西药', '12粒', '1', '2', '1', '18', '18', '饭后温水送服')
    ),
    buildOrder(
      'ORD20231127003',
      '陈海',
      false,
      '刘强',
      '2024-04-30 14:25:40',
      '￥88',
      '咽痛、发热',
      '无',
      '青霉素过敏',
      '咽炎',
      buildPrescription('#1 金银花颗粒', '中成药', '10袋', '1', '3', '1', '12', '12', '温水冲服')
    ),
    buildOrder(
      'ORD20231127004',
      '周芳',
      false,
      '赵倩',
      '2024-05-01 10:12:01',
      '￥42',
      '胃胀、反酸',
      '胃炎',
      '无',
      '胃炎',
      buildPrescription('#1 奥美拉唑肠溶胶囊', '西药', '14粒', '1', '1', '1', '20', '20', '晨起空腹服用')
    )
  ];
}

// 构建处方信息
function buildPrescription(
  indexTitle: string,
  type: string,
  spec: string,
  dosage: string,
  frequency: string,
  quantity: string,
  unitPrice: string,
  totalPrice: string,
  usage: string
): PrescriptionDetail {
  const prescription = new PrescriptionDetail();
  prescription.indexTitle = indexTitle;
  prescription.type = type;
  prescription.spec = spec;
  prescription.dosage = dosage;
  prescription.frequency = frequency;
  prescription.quantity = quantity;
  prescription.unitPrice = unitPrice;
  prescription.totalPrice = totalPrice;
  prescription.usage = usage;
  return prescription;
}

// 构建订单信息
function buildOrder(
  id: string,
  patient: string,
  paid: boolean,
  doctor: string,
  time: string,
  amount: string,
  symptom: string,
  medicalHistory: string,
  allergyHistory: string,
  diagnosis: string,
  prescription: PrescriptionDetail
): OrderInfo {
  const order = new OrderInfo();
  order.id = id;
  order.patient = patient;
  order.paid = paid;
  order.doctor = doctor;
  order.time = time;
  order.amount = amount;
  order.symptom = symptom;
  order.medical_history = medicalHistory;
  order.allergy_history = allergyHistory;
  order.diagnosis = diagnosis;
  order.prescription = prescription;
  return order;
}
