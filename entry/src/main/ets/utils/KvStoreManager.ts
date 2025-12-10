// utils/KvStoreManager.ts

// 1. 注意：引入的模块变成了 @ohos.data.distributedKVStore
import distributedKVStore from '@ohos.data.distributedKVStore';
import type common from '@ohos.app.ability.common';
import { AdmissionRecord } from '../model/AdmissionRecord'; // 确保路径正确

const STORE_ID = 'admission_app_store';
const TABLE_PREFIX = 'admission_records';

export class KvStoreManager {
  private static instance: KvStoreManager | null = null;
  // 2. 类型变更为 SingleKVStore (单版本数据库)
  private kvStore: distributedKVStore.SingleKVStore | null = null;

  private constructor() {}

  public static getInstance(): KvStoreManager {
    if (!KvStoreManager.instance) {
      KvStoreManager.instance = new KvStoreManager();
    }
    return KvStoreManager.instance;
  }

  /**
   * 初始化 KvStore (适配 API 9+ 及 HarmonyOS Next)
   */
  public async initKvStore(context: common.UIAbilityContext): Promise<void> {
    if (this.kvStore) {
      return;
    }

    try {
      // 3. 创建 KVManagerConfig
      const kvManagerConfig: distributedKVStore.KVManagerConfig = {
        context: context,
        bundleName: context.applicationInfo.name // 动态获取包名
      };

      // 4. 创建 KVManager 实例
      const manager = distributedKVStore.createKVManager(kvManagerConfig);

      // 5. 定义 Options
      const options: distributedKVStore.Options = {
        createIfMissing: true,
        encrypt: false,
        backup: false,
        kvStoreType: distributedKVStore.KVStoreType.SINGLE_VERSION, // 指定为单版本
        securityLevel: distributedKVStore.SecurityLevel.S1 // 安全等级
      };

      // 6. 通过 Manager 获取 KVStore
      this.kvStore = await manager.getKVStore(STORE_ID, options);

      console.info('KvStore initialized successfully (API 9+ style).');
    } catch (e) {
      console.error('Failed to initialize KvStore:', JSON.stringify(e));
      throw e;
    }
  }

  /**
   * 存储记录
   */
  public async saveRecord(record: AdmissionRecord): Promise<void> {
    if (!this.kvStore) {
      throw new Error('KvStore is not initialized.');
    }

    const key = `${TABLE_PREFIX}_${record.id}`;
    const value = JSON.stringify(record);

    try {
      await this.kvStore.put(key, value);
      console.info(`Record ${record.id} saved.`);
    } catch (e) {
      console.error(`Failed to save record ${record.id}:`, JSON.stringify(e));
      throw e;
    }
  }

  /**
   * 获取所有记录
   */
  public async getRecords(): Promise<AdmissionRecord[]> {
    if (!this.kvStore) {
      throw new Error('KvStore is not initialized.');
    }

    try {
      // 查询前缀
      const entries = await this.kvStore.getEntries(TABLE_PREFIX);

      return entries.map(entry => {
        // value 在新版 API 中可能是 Uint8Array 或 string，通常需要转换
        let jsonString = '';
        if (typeof entry.value === 'string') {
          jsonString = entry.value;
        } else {
          // 如果是 Uint8Array (字节数组)，需要根据具体情况转换，
          // 但通常 JSON.stringify 存进去如果是 string，取出来也是 string。
          // 假如是 Uint8Array，可以使用 new util.TextDecoder().decode(entry.value)
          jsonString = entry.value as unknown as string;
        }
        return JSON.parse(jsonString) as AdmissionRecord;
      }).sort((a, b) => b.submitTime - a.submitTime);

    } catch (e) {
      console.error('Failed to get records:', JSON.stringify(e));
      return [];
    }
  }
}