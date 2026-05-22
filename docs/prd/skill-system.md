# 技能系统 PRD

## 1. 概述

技能扩展战斗与策略深度。技能分为主动、被动、光环和反击四类，并通过统一事件枚举触发。技能数据以 JSON 存储在 `res://data/skills/`。

关联主 PRD: [TOP_PRD.md](./TOP_PRD.md)

## 2. 技能类型

| 类型 | 描述 | 示例 |
|---|---|---|
| active | 玩家主动使用 | 连续攻击、治愈 |
| passive | 常驻生效 | 防御+5、生命回复 |
| aura | 范围内生效 | 领导力 |
| counter | 被攻击时触发 | 反击强化、魔法屏障 |

## 3. 数据结构

### 3.1 JSON 数据示例

```json
{
  "id": "double_attack",
  "name": "连续攻击",
  "type": "active",
  "trigger": "before_combat",
  "cost": {
    "mp": 5
  },
  "effect": {
    "type": "extra_attack",
    "value": 1
  },
  "cooldown": 2,
  "description": "本次战斗额外追加一次攻击"
}
```

### 3.2 属性定义

| 属性 | 类型 | 描述 |
|---|---|---|
| id | string | 唯一标识 |
| name | string | 显示名称 |
| type | string | active / passive / aura / counter |
| trigger | string | 触发时机 |
| cost | object | 消耗（MP、HP 等） |
| effect | object | 效果定义 |
| range | int | 光环半径（仅 aura） |
| cooldown | int | 冷却回合数（仅 active） |

## 4. 触发时机

| 枚举 | 说明 |
|---|---|
| `turn_start` | 回合开始时触发 |
| `turn_end` | 回合结束时触发 |
| `before_combat` | 战斗开始前触发 |
| `after_combat` | 战斗结束后触发 |
| `on_hit` | 命中目标后触发 |
| `on_damage` | 受到伤害后触发 |
| `on_kill` | 击杀目标后触发 |
| `on_death` | 死亡时触发 |

## 5. 效果系统

### 5.1 效果类型

| 效果 | 描述 |
|---|---|
| stat_bonus | 属性加成/减益 |
| extra_attack | 追加攻击 |
| heal | 治疗 |
| damage | 直接伤害 |
| status | 附加状态 |
| teleport | 传送 |
| summon | 召唤单位 |

### 5.2 叠加规则

- 同名持续效果默认不叠加，刷新持续时间
- 不同来源的数值加成可叠加
- 冲突技能按触发优先级执行，优先级需在数据中可配置
- 附加异常状态时需遵守单位系统中的“同类不叠加、控制类互斥”规则

### 5.3 顶层顺序映射

- `before_combat`：在行动合法性判定之后、命中判定之前执行
- `after_combat`：在死亡结算之后执行
- `on_kill`、`on_death`：与死亡结算同一批次处理，具体优先级由子系统配置决定

### 5.4 优先级示例

建议为技能定义可比较的整数优先级，数值越大越先执行：

| 场景 | 示例技能 | 推荐优先级 |
|---|---|---|
| 战斗前自增益 | `battle_focus` | 100 |
| 命中后追加效果 | `poison_strike` | 80 |
| 受到伤害后护盾 | `magic_barrier` | 70 |
| 击杀后回血 | `life_drain` | 60 |
| 死亡后遗言/爆炸 | `last_flame` | 50 |

示例规则：

- 同一时机下，先按优先级降序执行
- 优先级相同时，先执行主动方技能，再执行被动方技能
- 同优先级且同阵营时，按技能 ID 字典序保证稳定结果

## 6. Godot 实现约束

- 战斗与回合事件应统一由事件分发器或管理器触发
- 不允许使用未定义的 `trigger` 枚举
- 技能描述文本不参与逻辑判定，逻辑以 `effect` 字段为准

## 7. 边界条件

| 场景 | 行为 |
|---|---|
| MP 不足 | 技能灰显，不可选 |
| 光环范围重叠 | 同名效果取最高值 |
| 技能冷却中 | 不可使用 |
| 被动技能冲突 | 按优先级依次结算 |
| 效果导致负属性 | 锁定在 0 |
| 控制类异常重复附加 | 刷新或替换，不同时保留多个控制类异常 |

## 8. 依赖关系

- [战斗系统](./combat-system.md) — 技能参与战斗计算
- [单位系统](./unit-system.md) — 单位拥有技能
- [UI 系统](./ui-system.md) — 技能菜单展示
- [数据驱动设计](./data-driven.md) — 加载技能模板
