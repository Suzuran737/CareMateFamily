/**
 * 健康记录的 KvStore 封装
 */

import distributedKVStore from '@ohos.data.distributedKVStore';
import type common from '@ohos.app.ability.common';
import util from '@ohos.util';

const STORE_ID = 'health_record_store';
const TABLE_PREFIX = 'health_records';

interface ValueWrapper {
  value: string | number | boolean | Uint8Array | ArrayBuffer | ValueWrapper;
}

type KvValue = string | number | boolean | Uint8Array | ArrayBuffer | ValueWrapper;

export class HealthRecord {
  id: string;
  submitTime: number;
  userId: string;
  userName: string;
  type: string;
  value: string;
  unit: string;
  measurementTime: string;

  constructor(
    id: string,
    submitTime: number,
    userId: string,
    userName: string,
    type: string,
    value: string,
    unit: string,
    measurementTime: string
  ) {
    this.id = id;
    this.submitTime = submitTime;
    this.userId = userId;
    this.userName = userName;
    this.type = type;
    this.value = value;
    this.unit = unit;
    this.measurementTime = measurementTime;
  }
}

interface HealthRecordRaw {
  id?: string;
  submitTime?: number;
  userId?: string;
  userName?: string;
  type?: string;
  value?: string;
  unit?: string;
  measurementTime?: string;
}

function normalizeHealthRecord(raw: HealthRecordRaw): HealthRecord {
  const id: string = raw.id ? raw.id : `${Date.now()}`;
  const submitTime: number = typeof raw.submitTime === 'number' ? raw.submitTime : Date.now();
  const userId: string = raw.userId ? raw.userId : '';
  const userName: string = raw.userName ? raw.userName : '';
  const type: string = raw.type ? raw.type : '';
  const value: string = raw.value ? raw.value : '';
  const unit: string = raw.unit ? raw.unit : '';
  const measurementTime: string = raw.measurementTime ? raw.measurementTime : '';

  return new HealthRecord(
    id,
    submitTime,
    userId,
    userName,
    type,
    value,
    unit,
    measurementTime
  );
}

export class HealthRecordStoreManager {
  private static instance: HealthRecordStoreManager | null = null;
  private kvStore: distributedKVStore.SingleKVStore | null = null;

  private constructor() {}

  public static getInstance(): HealthRecordStoreManager {
    if (!HealthRecordStoreManager.instance) {
      HealthRecordStoreManager.instance = new HealthRecordStoreManager();
    }
    return HealthRecordStoreManager.instance;
  }

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

  public async saveRecord(ownerName: string, record: HealthRecord): Promise<void> {
    if (!this.kvStore) {
      throw new Error('KvStore is not initialized.');
    }
    if (!ownerName) {
      throw new Error('User name is required.');
    }
    const key = `${TABLE_PREFIX}_${ownerName}_${record.id}`;
    const value = JSON.stringify(record);
    await this.kvStore.put(key, value);
  }

  public async getRecords(ownerName: string): Promise<HealthRecord[]> {
    if (!this.kvStore) {
      throw new Error('KvStore is not initialized.');
    }
    if (!ownerName) {
      throw new Error('User name is required.');
    }

    const entries = await this.kvStore.getEntries(`${TABLE_PREFIX}_${ownerName}`);
    const decoder = new util.TextDecoder('utf-8');

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
      const rawRecord = JSON.parse(jsonString) as HealthRecordRaw;
      return normalizeHealthRecord(rawRecord);
    }).sort((a: HealthRecord, b: HealthRecord) => b.submitTime - a.submitTime);
  }

  public async getRecordsByUser(ownerName: string, userId: string): Promise<HealthRecord[]> {
    const list = await this.getRecords(ownerName);
    return list.filter((record: HealthRecord) => record.userId === userId);
  }

  public async getRecordsByUserAndType(ownerName: string, userId: string, type: string): Promise<HealthRecord[]> {
    const list = await this.getRecordsByUser(ownerName, userId);
    return list.filter((record: HealthRecord) => record.type === type);
  }
}
