// utils/KvStoreManager.ts

// 1. 注意：引入的模块变成了 @ohos.data.distributedKVStore
import distributedKVStore from '@ohos.data.distributedKVStore';
import type common from '@ohos.app.ability.common';
import { AdmissionRecord } from '../model/AdmissionRecord'; // 确保路径正确
import util from '@ohos.util'; // 引入系统编解码模块
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
      throw new Error(`Failed to initialize KvStore: ${JSON.stringify(e)}`);
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
      throw new Error(`Failed to save record ${record.id}: ${JSON.stringify(e)}`);
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
      const entries = await this.kvStore.getEntries(TABLE_PREFIX);
      // 替换为系统 TextDecoder
      const decoder = new util.TextDecoder('utf-8');

      return entries.map((entry: distributedKVStore.Entry) => { // 显式声明entry类型
        let jsonString: string = '';
        if (typeof entry.value === 'string') {
          jsonString = entry.value;
        } else if (entry.value instanceof Uint8Array) {
          jsonString = decoder.decode(entry.value); // 使用系统API解码
        } else {
          throw new Error(`Unsupported value type for key ${entry.key}: ${typeof entry.value}`);
        }
        return JSON.parse(jsonString) as AdmissionRecord;
      }).sort((a: AdmissionRecord, b: AdmissionRecord) => b.submitTime - a.submitTime);

    } catch (e) {
      console.error('Failed to get records:', JSON.stringify(e));
      return [];
    }
  }
}