# 职业系统 PRD

## 1. 概述

职业决定单位的武器适性、成长修正、移动力和地形适应。职业数据以 JSON 存储在 `res://data/jobs/`。

关联主 PRD: [TOP_PRD.md](./TOP_PRD.md)

## 2. 职业分类

### 2.1 基础职业

| 职业 | 可用武器 | 移动力 | 特点 |
|---|---|---|---|
| 剑士 | Sword | 5 | 高技巧、高速度 |
| 枪兵 | Lance | 5 | 平衡型 |
| 斧兵 | Axe | 5 | 高力量 |
| 骑士 | Sword, Lance | 7 | 高移动 |
| 弓箭手 | Bow | 5 | 远程攻击 |
| 法师 | Magic | 5 | 魔法攻击 |
| 牧师 | Staff | 5 | 治疗与辅助 |
| 飞行单位 | Sword, Lance | 6 | 无视多数地面阻挡 |

### 2.2 高级职业

- 剑圣
- 圣骑士
- 贤者
- 勇者

### 2.3 特殊职业

- 领主
- 龙骑士
- 暗法师
- 舞者

## 3. 职业属性

| 属性 | 描述 |
|---|---|
| weapons | 可用武器类型 |
| growth_bonus | 成长率修正 |
| mov | 基础移动力 |
| terrain_adaptation | 地形适应 |
| skills | 职业技能 |

### 3.1 JSON 数据示例

```json
{
  "id": "swordman",
  "name": "剑士",
  "tier": 1,
  "promotes_to": "swordmaster",
  "weapons": ["sword"],
  "mov": 5,
  "growth_bonus": {
    "str": 5,
    "skl": 10,
    "spd": 10
  },
  "terrain_adaptation": {
    "forest": 1,
    "mountain": 2
  },
  "skills": ["sword_adept"]
}
```

## 4. 转职系统

- 达到等级要求后可转职
- 转职后提升职业能力并解锁新武器或技能
- 剧情强制转职需通过剧情系统触发

当前 MVP 不要求实现完整转职流程，职业系统优先承担武器适性、移动力和成长修正。

## 5. 边界条件

| 场景 | 行为 |
|---|---|
| 单位装备不允许的武器 | 自动卸下 |
| 转职条件未满足 | 转职入口不可用 |
| 成长修正导致超过 100 | 锁定在 100 |

## 6. 依赖关系

- [单位系统](./unit-system.md) — 职业附加给单位
- [武器系统](./weapon-system.md) — 决定可用武器
- [地图系统](./map-system.md) — 地形适应影响移动
