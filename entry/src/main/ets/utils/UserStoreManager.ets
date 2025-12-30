import distributedKVStore from '@ohos.data.distributedKVStore';
import type common from '@ohos.app.ability.common';
import util from '@ohos.util';

const STORE_ID = 'app_user_store';
const TABLE_PREFIX = 'users';

interface ValueWrapper {
  value: string | number | boolean | Uint8Array | ArrayBuffer | ValueWrapper;
}

type KvValue = string | number | boolean | Uint8Array | ArrayBuffer | ValueWrapper;

export class UserRecord {
  userName: string;
  phone: string;
  password: string;
  registerTime: number;

  constructor(userName: string, phone: string, password: string, registerTime: number) {
    this.userName = userName;
    this.phone = phone;
    this.password = password;
    this.registerTime = registerTime;
  }
}

interface UserRecordRaw {
  userName?: string;
  phone?: string;
  password?: string;
  registerTime?: number;
}

function normalizeUserRecord(raw: UserRecordRaw): UserRecord {
  const userName: string = raw.userName ? raw.userName : '';
  const phone: string = raw.phone ? raw.phone : '';
  const password: string = raw.password ? raw.password : '';
  const registerTime: number = typeof raw.registerTime === 'number' ? raw.registerTime : Date.now();
  return new UserRecord(userName, phone, password, registerTime);
}

function decodeValue(value: KvValue, decoder: util.TextDecoder): string {
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
    return decodeValue(wrapper.value, decoder);
  }
  throw new Error(`Unsupported value type: ${typeof value}`);
}

export class UserStoreManager {
  private static instance: UserStoreManager | null = null;
  private kvStore: distributedKVStore.SingleKVStore | null = null;

  private constructor() {}

  public static getInstance(): UserStoreManager {
    if (!UserStoreManager.instance) {
      UserStoreManager.instance = new UserStoreManager();
    }
    return UserStoreManager.instance;
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

  public async saveUser(record: UserRecord): Promise<void> {
    if (!this.kvStore) {
      throw new Error('KvStore is not initialized.');
    }

    const key = `${TABLE_PREFIX}_${record.userName}`;
    const value = JSON.stringify(record);
    await this.kvStore.put(key, value);
  }

  public async getUserByName(userName: string): Promise<UserRecord | null> {
    if (!this.kvStore) {
      throw new Error('KvStore is not initialized.');
    }

    const key = `${TABLE_PREFIX}_${userName}`;
    const entries = await this.kvStore.getEntries(key);
    if (entries.length === 0) {
      return null;
    }
    const decoder = new util.TextDecoder('utf-8');
    for (let i: number = 0; i < entries.length; i++) {
      if (entries[i].key !== key) {
        continue;
      }
      const jsonString = decodeValue(entries[i].value as KvValue, decoder);
      const rawRecord = JSON.parse(jsonString) as UserRecordRaw;
      return normalizeUserRecord(rawRecord);
    }
    return null;
  }

  public async getUserByPhone(phone: string): Promise<UserRecord | null> {
    if (!this.kvStore) {
      throw new Error('KvStore is not initialized.');
    }

    const entries = await this.kvStore.getEntries(TABLE_PREFIX);
    const decoder = new util.TextDecoder('utf-8');
    for (let i: number = 0; i < entries.length; i++) {
      const jsonString = decodeValue(entries[i].value as KvValue, decoder);
      const rawRecord = JSON.parse(jsonString) as UserRecordRaw;
      const record = normalizeUserRecord(rawRecord);
      if (record.phone === phone) {
        return record;
      }
    }
    return null;
  }
}
