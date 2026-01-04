// 用户相关模型
export class HealthUser {
  id: string;
  name: string;
  avatar?: string;

  constructor(id: string, name: string, avatar?: string) {
    this.id = id;
    this.name = name;
    this.avatar = avatar;
  }
}

// 健康数据接口
export interface HealthData {
  userId: string;
  type: string;
  value: string;
  measurementTime: string;
  unit?: string;
  recordId?: string;
  submitTime?: number;
}

// 健康数据类型
export const HEALTH_TYPES: string[] = ['心率', '血氧', '体温', '血糖', '血压', '压力', '睡眠'];

// 静态展示用户（仅保留刘刚与赵婷）
export const STATIC_USERS: HealthUser[] = [
  new HealthUser('static_liugang', '展示1'),
  new HealthUser('static_zhaoting', '展示2')
];

// 静态模拟健康数据
export const MOCK_HEALTH_DATA: HealthData[] = [
  // 刘刚（展示1）
  { userId: 'static_liugang', type: '心率', value: '76', measurementTime: '2024-02-01 08:10', unit: '次/分' },
  { userId: 'static_liugang', type: '心率', value: '80', measurementTime: '2024-02-03 09:20', unit: '次/分' },
  { userId: 'static_liugang', type: '心率', value: '78', measurementTime: '2024-02-05 19:10', unit: '次/分' },
  { userId: 'static_liugang', type: '心率', value: '82', measurementTime: '2024-02-07 07:55', unit: '次/分' },

  { userId: 'static_liugang', type: '血氧', value: '95', measurementTime: '2024-02-01 08:30', unit: '%' },
  { userId: 'static_liugang', type: '血氧', value: '96', measurementTime: '2024-02-05 20:10', unit: '%' },
  { userId: 'static_liugang', type: '血氧', value: '94', measurementTime: '2024-02-07 08:10', unit: '%' },

  { userId: 'static_liugang', type: '体温', value: '36.5', measurementTime: '2024-02-01 09:00', unit: '°C' },
  { userId: 'static_liugang', type: '体温', value: '36.7', measurementTime: '2024-02-06 18:30', unit: '°C' },

  { userId: 'static_liugang', type: '血糖', value: '5.2', measurementTime: '2024-02-02 07:10', unit: 'mmol/L' },
  { userId: 'static_liugang', type: '血糖', value: '5.7', measurementTime: '2024-02-06 12:20', unit: 'mmol/L' },

  { userId: 'static_liugang', type: '血压', value: '120/80', measurementTime: '2024-02-02 08:40', unit: 'mmHg' },
  { userId: 'static_liugang', type: '血压', value: '118/78', measurementTime: '2024-02-06 19:10', unit: 'mmHg' },

  { userId: 'static_liugang', type: '压力', value: '2', measurementTime: '2024-02-02 21:00', unit: '' },
  { userId: 'static_liugang', type: '压力', value: '3', measurementTime: '2024-02-06 21:10', unit: '' },

  { userId: 'static_liugang', type: '睡眠', value: '6.5', measurementTime: '2024-02-01 23:00-06:00', unit: '小时' },
  { userId: 'static_liugang', type: '睡眠', value: '7.0', measurementTime: '2024-02-05 23:20-06:30', unit: '小时' },

  // 赵婷（展示2）
  { userId: 'static_zhaoting', type: '心率', value: '70', measurementTime: '2024-02-01 08:20', unit: '次/分' },
  { userId: 'static_zhaoting', type: '心率', value: '74', measurementTime: '2024-02-04 09:10', unit: '次/分' },
  { userId: 'static_zhaoting', type: '心率', value: '72', measurementTime: '2024-02-06 18:40', unit: '次/分' },

  { userId: 'static_zhaoting', type: '血氧', value: '97', measurementTime: '2024-02-01 08:50', unit: '%' },
  { userId: 'static_zhaoting', type: '血氧', value: '98', measurementTime: '2024-02-06 19:00', unit: '%' },

  { userId: 'static_zhaoting', type: '体温', value: '36.4', measurementTime: '2024-02-02 09:10', unit: '°C' },
  { userId: 'static_zhaoting', type: '体温', value: '36.6', measurementTime: '2024-02-06 18:10', unit: '°C' },

  { userId: 'static_zhaoting', type: '血糖', value: '5.0', measurementTime: '2024-02-02 07:30', unit: 'mmol/L' },
  { userId: 'static_zhaoting', type: '血糖', value: '5.4', measurementTime: '2024-02-06 12:10', unit: 'mmol/L' },

  { userId: 'static_zhaoting', type: '血压', value: '118/76', measurementTime: '2024-02-02 08:20', unit: 'mmHg' },
  { userId: 'static_zhaoting', type: '血压', value: '122/78', measurementTime: '2024-02-06 19:30', unit: 'mmHg' },

  { userId: 'static_zhaoting', type: '压力', value: '1', measurementTime: '2024-02-02 20:30', unit: '' },
  { userId: 'static_zhaoting', type: '压力', value: '2', measurementTime: '2024-02-06 20:50', unit: '' },

  { userId: 'static_zhaoting', type: '睡眠', value: '7.2', measurementTime: '2024-02-01 23:10-06:40', unit: '小时' },
  { userId: 'static_zhaoting', type: '睡眠', value: '6.8', measurementTime: '2024-02-05 23:30-06:20', unit: '小时' }
];

// 健康数据管理类
export class HealthDataManager {
  /**
   * 获取用户健康数据
   * @param userId 用户ID
   * @param type 健康数据类型
   * @returns 健康数据数组
   */
  static getHealthData(userId: string, type: string): HealthData[] {
    return MOCK_HEALTH_DATA.filter(data =>
      data.userId === userId && data.type === type
    );
  }

  /**
   * 添加健康数据
   * @param data 健康数据
   * @returns 是否成功
   */
  static addHealthData(data: HealthData): boolean {
    // 这里实现数据添加逻辑
    // 在实际应用中，这里应该调用API或存储到数据库
    return true;
  }

  /**
   * 获取静态展示用户
   * @returns 用户列表
   */
  static getUsers(): HealthUser[] {
    return STATIC_USERS;
  }

  /**
   * 获取健康数据类型列表
   * @returns 健康数据类型数组
   */
  static getHealthTypes(): string[] {
    return HEALTH_TYPES;
  }
}
