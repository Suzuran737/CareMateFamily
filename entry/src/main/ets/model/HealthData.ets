// 用户相关接口
export interface User {
  id: number;
  name: string;
  avatar?: string;
}

// 健康数据接口
export interface HealthData {
  userId: number;
  type: string;
  value: string;
  measurementTime: string;
  unit?: string;
}

// 健康数据类型
export const HEALTH_TYPES: string[] = ['心率', '血氧', '体温', '血糖', '血压', '睡眠', '体脂'];

// 模拟用户数据
export const USERS: User[] = [
  { id: 1, name: '张三' },
  { id: 2, name: '李四' },
  { id: 3, name: '王五' }
];

// 模拟健康数据
export const MOCK_HEALTH_DATA: HealthData[] = [
  // 张三的数据
  { userId: 1, type: '心率', value: '65', measurementTime: '2024-01-10 07:30', unit: '次/分' },
  { userId: 1, type: '心率', value: '72', measurementTime: '2024-01-10 12:00', unit: '次/分' },
  { userId: 1, type: '心率', value: '70', measurementTime: '2024-01-10 18:45', unit: '次/分' },
  { userId: 1, type: '心率', value: '68', measurementTime: '2024-01-15 07:45', unit: '次/分' },
  { userId: 1, type: '心率', value: '72', measurementTime: '2024-01-15 08:30', unit: '次/分' },
  { userId: 1, type: '心率', value: '75', measurementTime: '2024-01-15 12:45', unit: '次/分' },
  { userId: 1, type: '心率', value: '73', measurementTime: '2024-01-15 19:20', unit: '次/分' },
  { userId: 1, type: '心率', value: '71', measurementTime: '2024-01-20 08:15', unit: '次/分' },

  { userId: 1, type: '血氧', value: '97%', measurementTime: '2024-01-10 08:00', unit: '' },
  { userId: 1, type: '血氧', value: '98%', measurementTime: '2024-01-15 09:00', unit: '' },
  { userId: 1, type: '血氧', value: '96%', measurementTime: '2024-01-15 17:30', unit: '' },
  { userId: 1, type: '血氧', value: '98%', measurementTime: '2024-01-20 07:45', unit: '' },
  { userId: 1, type: '血氧', value: '97%', measurementTime: '2024-01-20 22:10', unit: '' },

  { userId: 1, type: '体温', value: '36.4', measurementTime: '2024-01-10 08:30', unit: '°C' },
  { userId: 1, type: '体温', value: '36.6', measurementTime: '2024-01-10 16:45', unit: '°C' },
  { userId: 1, type: '体温', value: '36.5', measurementTime: '2024-01-15 10:15', unit: '°C' },
  { userId: 1, type: '体温', value: '36.7', measurementTime: '2024-01-15 20:00', unit: '°C' },
  { userId: 1, type: '体温', value: '36.3', measurementTime: '2024-01-20 09:00', unit: '°C' },
  { userId: 1, type: '体温', value: '36.8', measurementTime: '2024-01-20 18:30', unit: '°C' },

  { userId: 1, type: '血糖', value: '5.0', measurementTime: '2024-01-10 06:45', unit: 'mmol/L' },
  { userId: 1, type: '血糖', value: '6.1', measurementTime: '2024-01-10 12:30', unit: 'mmol/L' },
  { userId: 1, type: '血糖', value: '5.8', measurementTime: '2024-01-10 19:15', unit: 'mmol/L' },
  { userId: 1, type: '血糖', value: '5.2', measurementTime: '2024-01-15 07:00', unit: 'mmol/L' },
  { userId: 1, type: '血糖', value: '5.9', measurementTime: '2024-01-15 13:00', unit: 'mmol/L' },
  { userId: 1, type: '血糖', value: '5.3', measurementTime: '2024-01-15 20:30', unit: 'mmol/L' },
  { userId: 1, type: '血糖', value: '5.1', measurementTime: '2024-01-20 07:15', unit: 'mmol/L' },
  { userId: 1, type: '血糖', value: '6.0', measurementTime: '2024-01-20 12:45', unit: 'mmol/L' },
  { userId: 1, type: '血糖', value: '5.4', measurementTime: '2024-01-20 19:00', unit: 'mmol/L' },

  { userId: 1, type: '血压', value: '118/78', measurementTime: '2024-01-10 07:00', unit: 'mmHg' },
  { userId: 1, type: '血压', value: '122/82', measurementTime: '2024-01-10 14:30', unit: 'mmHg' },
  { userId: 1, type: '血压', value: '120/80', measurementTime: '2024-01-15 08:00', unit: 'mmHg' },
  { userId: 1, type: '血压', value: '125/83', measurementTime: '2024-01-15 16:00', unit: 'mmHg' },
  { userId: 1, type: '血压', value: '119/79', measurementTime: '2024-01-20 08:30', unit: 'mmHg' },
  { userId: 1, type: '血压', value: '121/81', measurementTime: '2024-01-20 17:45', unit: 'mmHg' },

  { userId: 1, type: '睡眠', value: '6.8', measurementTime: '2024-01-09 23:15-06:00', unit: '小时' },
  { userId: 1, type: '睡眠', value: '7.2', measurementTime: '2024-01-14 22:00-06:30', unit: '小时' },
  { userId: 1, type: '睡眠', value: '8.1', measurementTime: '2024-01-19 22:30-06:45', unit: '小时' },

  { userId: 1, type: '体脂', value: '18.8', measurementTime: '2024-01-09 18:30', unit: '%' },
  { userId: 1, type: '体脂', value: '18.5', measurementTime: '2024-01-14 19:00', unit: '%' },
  { userId: 1, type: '体脂', value: '18.2', measurementTime: '2024-01-19 20:15', unit: '%' },

  // 李四的数据
  { userId: 2, type: '心率', value: '68', measurementTime: '2024-01-15 09:00', unit: '次/分' },
  { userId: 2, type: '心率', value: '70', measurementTime: '2024-01-15 14:20', unit: '次/分' },
  { userId: 2, type: '血氧', value: '99%', measurementTime: '2024-01-15 10:00', unit: '' },
  { userId: 2, type: '体温', value: '36.7', measurementTime: '2024-01-15 11:30', unit: '°C' },
  { userId: 2, type: '血糖', value: '4.8', measurementTime: '2024-01-15 07:30', unit: 'mmol/L' },
  { userId: 2, type: '血压', value: '118/76', measurementTime: '2024-01-15 09:00', unit: 'mmHg' },
  { userId: 2, type: '睡眠', value: '8.0', measurementTime: '2024-01-14 22:30-06:30', unit: '小时' },
  { userId: 2, type: '体脂', value: '20.2', measurementTime: '2024-01-14 20:00', unit: '%' }
];

// 健康数据管理类
export class HealthDataManager {
  /**
   * 获取用户健康数据
   * @param userId 用户ID
   * @param type 健康数据类型
   * @returns 健康数据数组
   */
  static getHealthData(userId: number, type: string): HealthData[] {
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
   * 获取所有用户
   * @returns 用户列表
   */
  static getUsers(): User[] {
    return USERS;
  }

  /**
   * 获取健康数据类型列表
   * @returns 健康数据类型数组
   */
  static getHealthTypes(): string[] {
    return HEALTH_TYPES;
  }
}