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

  private constructor() {
  }

  public static getInstance(): KvStoreManager {
    if (!KvStoreManager.instance) {
      KvStoreManager.instance = new KvStoreManager();
    }
    return KvStoreManager.instance;
  }

  // utils/KvStoreManager.ts

  public async initKvStore(context: common.UIAbilityContext): Promise<void> {
    if (this.kvStore) return;

    try {
      // --- 关键修正：从 abilityInfo 中获取真正的包名 ---
      const bName = context.abilityInfo.bundleName;

      const kvManagerConfig: distributedKVStore.KVManagerConfig = {
        context: context,
        bundleName: bName
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
      console.info('KvStore 初始化成功，包名: ' + bName);
    } catch (e) {
      console.error('KvStore 初始化失败');
    }
  }

  public async saveRecord(record: AdmissionRecord): Promise<boolean> {
    if (!this.kvStore) return false;
    // 强制 Key 格式：前缀_ID
    const key = `admission_records_${record.id}`;
    try {
      const jsonStr = JSON.stringify(record);
      console.info(`[KV_SAVE] 写入 Key: ${key}`);
      await this.kvStore.put(key, jsonStr);
      return true;
    } catch (e) {
      return false;
    }
  }

  public async getRecords(): Promise<AdmissionRecord[]> {
    if (!this.kvStore) return [];

    try {
      const entries = await this.kvStore.getEntries(new distributedKVStore.Query());
      const result: AdmissionRecord[] = [];
      const decoder = new util.TextDecoder('utf-8');

      console.info(`[KV_GET] 数据库原始总条数: ${entries.length}`);

      for (let i = 0; i < entries.length; i++) {
        const entry = entries[i];
        const val = entry.value;
        let workStr = "";

        // 步骤 1：把 val 统一转为字符串（解决 [object Object] 的问题）
        if (typeof val === 'string') {
          workStr = val;
        } else if (val instanceof Uint8Array) {
          workStr = decoder.decode(val);
        } else {
          // 如果系统返回的是对象，我们直接转回字符串
          workStr = JSON.stringify(val);
        }

        // 步骤 2：判断并解开系统包装 (剥壳)
        // 你的日志里内容是: {"type":0,"value":"{...}"}
        try {
          if (workStr.includes('"value"') && workStr.includes('"type"')) {
            const wrapper = JSON.parse(workStr) as Record<string, Object>;
            const innerVal = wrapper["value"];
            if (typeof innerVal === 'string') {
              console.info(`[KV_GET] 项 ${i} 检测到外壳，正在执行二次解析...`);
              workStr = innerVal; // 取出壳子里真正的 JSON 字符串
            }
          }
        } catch (e) {
          console.warn('剥壳失败，尝试直接解析原字符串');
        }

        // 步骤 3：解析最终的业务对象
        if (workStr && workStr.includes('{')) {
          try {
            const record = JSON.parse(workStr) as AdmissionRecord;
            // 只要有 submitTime，就是我们要的数据
            if (record && record.submitTime) {
              result.push(record);
              console.info(`[KV_GET] 成功解救记录: ${record.id}`);
            }
          } catch (e) {
            console.error(`[KV_GET] 业务 JSON 解析失败`);
          }
        }
      }

      result.sort((a, b) => b.submitTime - a.submitTime);
      console.info(`[KV_GET] 最终展示条数: ${result.length}`);
      return result;
    } catch (error) {
      return [];
    }
  }

  // 清空所有入住申请记录
  public async clearRecords(): Promise<boolean> {
    if (!this.kvStore) return false;

    try {
      const entries = await this.kvStore.getEntries(new distributedKVStore.Query());
      const keys: string[] = [];
      for (let i = 0; i < entries.length; i++) {
        const key = entries[i].key;
        if (typeof key === 'string' && key.startsWith(TABLE_PREFIX)) {
          keys.push(key);
        }
      }
      if (keys.length === 0) {
        return true;
      }
      await this.kvStore.deleteBatch(keys);
      return true;
    } catch (e) {
      return false;
    }
  }
}
