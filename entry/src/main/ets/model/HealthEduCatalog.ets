/**
 * 健康宣教文章数据
 */

export interface HealthEduItem {
  id: number;
  img: Resource;
  title: string;
}

export interface HealthEduDetail extends HealthEduItem {
  sections: string[];
}

// 列表使用的简化数据类，避免直接返回未显式类型的对象字面量
class HealthEduListItem implements HealthEduItem {
  id: number;
  img: Resource;
  title: string;

  constructor(id: number, img: Resource, title: string) {
    this.id = id;
    this.img = img;
    this.title = title;
  }
}

const HEALTH_EDU_LIST: HealthEduDetail[] = [
  {
    id: 1,
    img: $r('app.media.health_img1'),
    title: '老年痴呆',
    sections: [
      '老年痴呆（阿尔茨海默病）是一种进行性脑部退行性疾病，常见于老年人。早期可能只是偶尔忘事，但随着病程进展，会出现明显的记忆和判断能力下降。',
      '常见的早期信号包括：反复询问同一问题、近期记忆明显变差、做熟悉事情变得困难、时间和地点感混乱等。如果家人发现这些变化，应尽早就医评估。',
      '日常照护建议：保持规律作息，建立固定的生活流程；在家中张贴提示卡片或使用标签；减少复杂环境和安全隐患，避免煤气忘关、夜间跌倒。',
      '适度认知训练、社交活动和兴趣爱好有助于延缓认知衰退。若行为改变、情绪异常或自理能力明显下降，应及时寻求专业帮助。'
    ]
  },
  {
    id: 2,
    img: $r('app.media.health_img2'),
    title: '关注帕金森病',
    sections: [
      '帕金森病是一种常见的神经退行性疾病，主要表现为动作迟缓、肌肉僵硬、静止性震颤和姿势平衡障碍。',
      '早期症状可能不明显，例如：写字变小、动作变慢、走路拖步或手臂摆动减少。家属若发现类似变化，建议尽早就诊。',
      '药物治疗是控制症状的主要手段，需严格遵医嘱。配合规律运动（如步行、太极、拉伸和力量训练）可改善平衡与步态。',
      '居家照护要注意防跌倒，地面保持干净防滑，床边、卫生间配置扶手。情绪支持同样重要，可帮助患者更好地应对疾病。'
    ]
  },
  {
    id: 3,
    img: $r('app.media.health_img3'),
    title: '运动健康',
    sections: [
      '规律运动有助于维持心肺功能、增强肌肉力量、改善关节灵活性，并降低慢性病风险，是老年人健康管理的重要部分。',
      '建议选择适合自己的运动方式：散步、太极、慢跑、游泳、简易力量训练或拉伸等，以中低强度为主。',
      '运动前充分热身，运动后适当放松；每周至少 150 分钟中等强度运动，可分多次完成。',
      '如有慢性病或术后恢复期，请先咨询医生。运动过程中若出现胸闷、头晕、心悸等不适，应立即停止并休息。'
    ]
  },
  {
    id: 4,
    img: $r('app.media.health_img4'),
    title: '骨质疏松预防',
    sections: [
      '骨质疏松会增加骨折风险，老年人尤其要重视。早期通常无明显症状，常在跌倒骨折后才被发现。',
      '饮食上建议摄入足量钙和维生素D，例如牛奶、豆制品、深绿色蔬菜等，并适度晒太阳促进维生素D合成。',
      '负重和抗阻运动能刺激骨骼生长，如快走、爬楼、轻度力量训练等；同时可练习平衡训练减少跌倒风险。',
      '建议定期骨密度检查，特别是绝经后的女性或有骨折史的人群，必要时在医生指导下进行干预治疗。'
    ]
  },
  {
    id: 5,
    img: $r('app.media.health_img5'),
    title: '高血压管理',
    sections: [
      '高血压是常见慢性病，长期控制不佳会增加心脑血管事件风险。家庭血压监测是管理的重要方式。',
      '建议每日固定时间测量血压，记录并观察趋势。多数老年人的目标血压需由医生综合评估确定。',
      '生活方式调整包括：低盐饮食、控制体重、戒烟限酒、规律运动和保持情绪稳定。',
      '药物治疗需长期坚持，不要随意停药或自行调整剂量。如出现持续头痛、胸痛、视物模糊等症状，应及时就医。'
    ]
  },
  {
    id: 6,
    img: $r('app.media.health_img6'),
    title: '睡眠健康',
    sections: [
      '良好的睡眠有助于恢复精力、增强免疫力，并改善情绪与记忆力。老年人常见睡眠问题包括入睡困难、易醒或早醒。',
      '保持规律作息，尽量固定入睡与起床时间；睡前避免大量饮水、浓茶或咖啡，减少电子屏幕刺激。',
      '白天适度活动与日照可改善夜间睡眠，午睡控制在 30 分钟以内，避免影响夜间入睡。',
      '若长期失眠或伴有打鼾、呼吸暂停等症状，建议尽早到睡眠门诊或专科就诊。'
    ]
  }
];

/**
 * 获取宣教列表（返回新数组，避免原数组被直接修改）
 */
export function getHealthEduList(): HealthEduItem[] {
  const list: HealthEduItem[] = [];
  for (let i: number = 0; i < HEALTH_EDU_LIST.length; i++) {
    const item: HealthEduDetail = HEALTH_EDU_LIST[i];
    list.push(new HealthEduListItem(item.id, item.img, item.title));
  }
  return list;
}

/**
 * 根据 id 获取宣教详情
 */
export function getHealthEduDetailById(id: number): HealthEduDetail {
  for (let i = 0; i < HEALTH_EDU_LIST.length; i++) {
    if (HEALTH_EDU_LIST[i].id === id) {
      return HEALTH_EDU_LIST[i];
    }
  }
  return HEALTH_EDU_LIST[0];
}
