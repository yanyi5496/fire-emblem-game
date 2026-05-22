# 战斗系统 PRD

## 1. 概述

战斗是 SRPG 的核心。攻击方和防守方按统一流程进行计算，涉及命中、伤害、暴击、反击、追击与技能触发。规则需可直接映射到 Godot 的 `CombatManager` 与攻击预览 UI。

关联主 PRD: [TOP_PRD.md](./TOP_PRD.md)

## 2. 战斗流程

```text
1. 攻击声明 — 选择目标、武器或技能
2. 战斗前技能 — 处理 before_combat
3. 命中判定
4. 暴击判定
5. 伤害计算
6. 反击 — 条件满足时由防守方执行
7. 追击 — 条件满足时额外攻击一次
8. 战斗后技能 — 处理 after_combat / on_kill / on_death
9. 死亡结算
```

### 2.1 战斗状态

- 战斗开始时锁定双方位置与装备
- 战斗中不接受新的玩家输入
- 动画只负责表现，判定结果以 `CombatManager` 为准
- 行动合法性与限制状态先于战斗技能判定

## 3. 伤害公式

### 3.1 物理伤害

```text
物理伤害 = max(0, STR + WeaponMight + TriangleDamageBonus - (DEF + TerrainDefenseBonus))
```

### 3.2 魔法伤害

```text
魔法伤害 = max(0, MAG + WeaponMight - RES)
```

### 3.3 附加规则

- 暴击时最终伤害 × 3
- 武器克制优势：伤害 +1
- 武器克制劣势：伤害 -1
- Bow 对 `flying` 标签单位造成 1.5 倍最终伤害，向下取整

## 4. 命中公式

```text
命中率 = WeaponHit + SKL*2 + LUK + TriangleHitBonus + HeightBonus
         - (目标SPD/2 + 目标LUK + TerrainAvoidBonus)
```

### 4.1 高度差修正

- 攻击方高度高于防守方：`HeightBonus = +10`
- 攻击方高度低于防守方：`HeightBonus = -10`
- 高度差不会直接禁止攻击

### 4.2 命中判定规则

- 命中率上限 100，下限 0
- 随机数 `0~99 < 命中率` 则命中

## 5. 暴击公式

```text
暴击率 = SKL / 2 + WeaponCrit
```

- 暴击率上限 50
- 暴击率下限 0

## 6. 反击

当防守方满足以下全部条件时反击：

1. 防守方存活
2. 防守方装备可用武器
3. 攻击方位于该武器的最小/最大射程区间内
4. 防守方未被 `Sleep` 或 `Paralysis` 限制

## 7. 追击

### 7.1 攻击速度

```text
AttackSpeed = max(0, SPD - Weight)
```

### 7.2 追击条件

```text
攻击方 AttackSpeed >= 防守方 AttackSpeed + 4
```

满足条件时攻击方在正常攻击与反击结算后追加一次攻击。

## 8. 死亡结算

- HP 小于等于 0 时，`action_state` 设为 `Dead`
- 死亡单位从地图移除
- 触发 `on_death` 技能与剧情事件

### 8.1 结算顺序约束

为与 TOP PRD 保持一致，战斗内默认按以下顺序结算：

```text
行动合法性判定
→ before_combat
→ 命中/暴击/伤害
→ 死亡结算
→ after_combat / on_kill / on_death
```

## 9. 边界条件

| 场景 | 行为 |
|---|---|
| 命中率 0 | 必定闪避 |
| 命中率 100 | 必定命中 |
| 攻击者和防守者相同 | 不允许 |
| 双方都满足追击条件 | 仅当前攻击方追击 |
| 武器耐久为 0 | 不可发起攻击 |

## 10. 依赖关系

- [单位系统](./unit-system.md) — 提供单位属性与状态
- [武器系统](./weapon-system.md) — 提供武器属性、射程、重量与克制
- [地图系统](./map-system.md) — 提供地形加成和高度
- [技能系统](./skill-system.md) — 提供战斗时机技能
- [AI 系统](./ai-system.md) — AI 使用战斗系统评估收益
