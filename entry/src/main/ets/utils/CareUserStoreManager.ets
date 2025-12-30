import distributedKVStore from '@ohos.data.distributedKVStore';
import type common from '@ohos.app.ability.common';
import util from '@ohos.util';

const STORE_ID = 'care_user_store';
const TABLE_PREFIX = 'care_users';

interface ValueWrapper {
  value: string | number | boolean | Uint8Array | ArrayBuffer | ValueWrapper;
}

type KvValue = string | number | boolean | Uint8Array | ArrayBuffer | ValueWrapper;

export class CareUserRecord {
  id: string;
  submitTime: number;
  name: string;
  gender: string;
  relationship: string;
  birthday: string;
  idCard: string;
  occupation: string;
  address: string;

  constructor(
    id: string,
    submitTime: number,
    name: string,
    gender: string,
    relationship: string,
    birthday: string,
    idCard: string,
    occupation: string,
    address: string
  ) {
    this.id = id;
    this.submitTime = submitTime;
    this.name = name;
    this.gender = gender;
    this.relationship = relationship;
    this.birthday = birthday;
    this.idCard = idCard;
    this.occupation = occupation;
    this.address = address;
  }
}

interface CareUserRecordRaw {
  id?: string;
  submitTime?: number;
  name?: string;
  gender?: string;
  relationship?: string;
  birthday?: string;
  idCard?: string;
  occupation?: string;
  address?: string;
}

function normalizeCareUserRecord(raw: CareUserRecordRaw): CareUserRecord {
  const id: string = raw.id ? raw.id : `${Date.now()}`;
  const submitTime: number = typeof raw.submitTime === 'number' ? raw.submitTime : Date.now();
  const name: string = raw.name ? raw.name : '';
  const gender: string = raw.gender ? raw.gender : '';
  const relationship: string = raw.relationship ? raw.relationship : '';
  const birthday: string = raw.birthday ? raw.birthday : '';
  const idCard: string = raw.idCard ? raw.idCard : '';
  const occupation: string = raw.occupation ? raw.occupation : '';
  const address: string = raw.address ? raw.address : '';

  return new CareUserRecord(
    id,
    submitTime,
    name,
    gender,
    relationship,
    birthday,
    idCard,
    occupation,
    address
  );
}

export class CareUserStoreManager {
  private static instance: CareUserStoreManager | null = null;
  private kvStore: distributedKVStore.SingleKVStore | null = null;

  private constructor() {}

  public static getInstance(): CareUserStoreManager {
    if (!CareUserStoreManager.instance) {
      CareUserStoreManager.instance = new CareUserStoreManager();
    }
    return CareUserStoreManager.instance;
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

  public async saveUser(record: CareUserRecord): Promise<void> {
    if (!this.kvStore) {
      throw new Error('KvStore is not initialized.');
    }

    const key = `${TABLE_PREFIX}_${record.id}`;
    const value = JSON.stringify(record);
    await this.kvStore.put(key, value);
  }

  public async getUsers(): Promise<CareUserRecord[]> {
    if (!this.kvStore) {
      throw new Error('KvStore is not initialized.');
    }

    const entries = await this.kvStore.getEntries(TABLE_PREFIX);
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
      const rawRecord = JSON.parse(jsonString) as CareUserRecordRaw;
      return normalizeCareUserRecord(rawRecord);
    }).sort((a: CareUserRecord, b: CareUserRecord) => b.submitTime - a.submitTime);
  }

  // 清空已保存的康养用户
  public async clearUsers(): Promise<void> {
    if (!this.kvStore) {
      throw new Error('KvStore is not initialized.');
    }

    const entries: distributedKVStore.Entry[] = await this.kvStore.getEntries(TABLE_PREFIX);
    const keys: string[] = [];
    for (let i: number = 0; i < entries.length; i++) {
      keys.push(entries[i].key);
    }
    if (keys.length === 0) {
      return;
    }
    await this.kvStore.deleteBatch(keys);
  }
}
