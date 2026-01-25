/**
 * 服务项目目录数据与解析工具
 */

// 服务项目数据模块
import type common from '@ohos.app.ability.common';
import util from '@ohos.util';

// rawfile 内的服务目录文件名
const RAWFILE_PATH = 'service_catalog.json';

// 服务列表的基础字段
export interface ServiceItem {
  id: number;
  title: string;
  orgName: string;
  typeName: string;
  price: number;
  image: Resource;
}

// 费用明细项
export interface FeeItem {
  label: string;
  amount: number;
}

// 详情字段（包含列表字段）
export interface ServiceDetail extends ServiceItem {
  intro: string;
  reservationNotice: string;
  feeNotice: string;
  feeItems: FeeItem[];
  totalPrice: number;
}

// rawfile JSON 中的费用项结构
interface RawFeeItem {
  label: string;
  amount: number;
}

// rawfile JSON 中的详情结构
interface RawServiceDetail {
  id: number;
  title: string;
  orgName: string;
  typeName: string;
  price: number;
  imageName: string;
  intro: string;
  reservationNotice: string;
  feeNotice: string;
  feeItems: RawFeeItem[];
  totalPrice: number;
}

// rawfile JSON 根结构
interface ServiceCatalogJson {
  items: RawServiceDetail[];
}

// 缺省详情（数据加载失败时兜底）
const DEFAULT_DETAIL: ServiceDetail = {
  id: 0,
  title: '',
  orgName: '',
  typeName: '',
  price: 0,
  image: $r('app.media.service_img1'),
  intro: '',
  reservationNotice: '',
  feeNotice: '',
  feeItems: [],
  totalPrice: 0
};

// 缓存已加载的目录数据
let cachedCatalog: ServiceDetail[] = [];

// 将图片名映射为资源
function getImageResource(name: string): Resource {
  switch (name) {
    case 'service_img1':
      return $r('app.media.service_img1');
    case 'service_img2':
      return $r('app.media.service_img2');
    case 'service_img3':
      return $r('app.media.service_img3');
    case 'service_img4':
      return $r('app.media.service_img4');
    default:
      return $r('app.media.service_img1');
  }
}

// 将 rawfile JSON 对象转换为页面可用数据
function mapRawToDetail(item: RawServiceDetail): ServiceDetail {
  return {
    id: item.id,
    title: item.title,
    orgName: item.orgName,
    typeName: item.typeName,
    price: item.price,
    image: getImageResource(item.imageName),
    intro: item.intro,
    reservationNotice: item.reservationNotice,
    feeNotice: item.feeNotice,
    feeItems: item.feeItems,
    totalPrice: item.totalPrice
  };
}

// 获取默认详情
export function getDefaultServiceDetail(): ServiceDetail {
  return DEFAULT_DETAIL;
}

// 加载服务目录（带缓存）
export async function loadServiceCatalog(context: common.UIAbilityContext): Promise<ServiceDetail[]> {
  if (cachedCatalog.length > 0) {
    return cachedCatalog;
  }

  const content: Uint8Array = await context.resourceManager.getRawFileContent(RAWFILE_PATH);
  const decoder = new util.TextDecoder('utf-8');
  const jsonString = decoder.decode(content);
  const parsed = JSON.parse(jsonString) as ServiceCatalogJson;
  const rawItems: RawServiceDetail[] = parsed.items ? parsed.items : [];

  cachedCatalog = rawItems.map((item: RawServiceDetail) => mapRawToDetail(item));
  return cachedCatalog;
}

// 根据 id 查找服务详情
export function getServiceDetailById(list: ServiceDetail[], id: number): ServiceDetail {
  for (let i = 0; i < list.length; i++) {
    if (list[i].id === id) {
      return list[i];
    }
  }
  return list.length > 0 ? list[0] : getDefaultServiceDetail();
}
