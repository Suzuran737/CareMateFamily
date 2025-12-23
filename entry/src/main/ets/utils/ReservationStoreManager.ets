import distributedKVStore from '@ohos.data.distributedKVStore';
import type common from '@ohos.app.ability.common';
import util from '@ohos.util';

// 预约订单本地存储的KvStore配置
const STORE_ID = 'service_reservation_store';
const TABLE_PREFIX = 'service_reservations';

interface ValueWrapper {
  value: string | number | boolean | Uint8Array | ArrayBuffer | ValueWrapper;
}

type KvValue = string | number | boolean | Uint8Array | ArrayBuffer | ValueWrapper;

// 预约订单数据结构
export interface ReservationRecord {
  id: string;
  submitTime: number;
  serviceUser: string;
  nurseName: string;
  serviceTime: string;
  contactName: string;
  contactPhone: string;
  address: string;
  remark: string;
}

// 预约订单KvStore封装
export class ReservationStoreManager {
  private static instance: ReservationStoreManager | null = null;
  // 单设备KvStore句柄
  private kvStore: distributedKVStore.SingleKVStore | null = null;

  private constructor() {}

  // 获取单例
  public static getInstance(): ReservationStoreManager {
    if (!ReservationStoreManager.instance) {
      ReservationStoreManager.instance = new ReservationStoreManager();
    }
    return ReservationStoreManager.instance;
  }

  // 初始化KvStore
  public async initKvStore(context: common.UIAbilityContext): Promise<void> {
    if (this.kvStore) {
      return;
    }

    const kvManagerConfig: distributedKVStore.KVManagerConfig = {
      context: context,
      bundleName: context.applicationInfo.name
    };

    const manager = distributedKVStore.createKVManager(kvManagerConfig);
    const options: distributedKVStore.Options = {
      createIfMissing: true,
      encrypt: false,
      backup: false,
      kvStoreType: distributedKVStore.KVStoreType.SINGLE_VERSION,
      securityLevel: distributedKVStore.SecurityLevel.S1
    };

    this.kvStore = await manager.getKVStore(STORE_ID, options);
  }

  // 保存预约订单
  public async saveReservation(record: ReservationRecord): Promise<void> {
    if (!this.kvStore) {
      throw new Error('KvStore is not initialized.');
    }

    const key = `${TABLE_PREFIX}_${record.id}`;
    const value = JSON.stringify(record);

    await this.kvStore.put(key, value);
  }

  // 读取已保存的预约订单
  public async getReservations(): Promise<ReservationRecord[]> {
    if (!this.kvStore) {
      throw new Error('KvStore is not initialized.');
    }

    const entries = await this.kvStore.getEntries(TABLE_PREFIX);
    const decoder = new util.TextDecoder('utf-8');

    // 兼容多种value类型的解码
    const decodeValue = (value: KvValue): string => {
      if (typeof value === 'string') {
        return value;
      }
      if (typeof value === 'number' || typeof value === 'boolean') {
        return String(value);
      }
      if (value instanceof Uint8Array) {
        return decoder.decode(value);
      }
      if (value instanceof ArrayBuffer) {
        return decoder.decode(new Uint8Array(value));
      }
      const wrapper = value as ValueWrapper;
      if (wrapper && typeof wrapper.value !== 'undefined') {
        return decodeValue(wrapper.value);
      }
      throw new Error(`Unsupported value type: ${typeof value}`);
    };

    return entries.map((entry: distributedKVStore.Entry) => {
      const jsonString = decodeValue(entry.value as KvValue);
      return JSON.parse(jsonString) as ReservationRecord;
    }).sort((a: ReservationRecord, b: ReservationRecord) => b.submitTime - a.submitTime);
  }
}
