# AGENTS.md

This file provides guidance to Codex (Codex.ai/code) when working with code in this repository.

## 项目概述

**Project Ember** — 基于 Godot 4.6 的火焰纹章风格 SRPG（战棋策略角色扮演）游戏。

- 引擎：Godot 4.6（GL Compatibility 渲染器，D3D12 驱动）
- 语言：GDScript
- 数据格式：JSON / Resource
- 物理引擎：Jolt Physics（3D）
- 目标平台：Windows / Linux / macOS / Steam
- 目标帧率：60 FPS，最大地图 64x64

## 构建与运行

- 使用 Godot Editor 4.6 打开项目目录运行
- 无命令行构建/测试工具链，所有开发通过 Godot Editor 进行

## 架构设计

### 数据驱动

所有游戏数据存放在 `res://data/` 目录下，按类型分目录：`units/`、`skills/`、`weapons/`、`maps/`、`jobs/`。数据格式为 JSON。

### 核心场景结构

```
BattleScene
 ├── TileMap          — 格子地图，含地形属性（move_cost, avoid_bonus, defense_bonus, walkable, height）
 ├── Units            — 战斗单位
 ├── Cursor           — 玩家光标
 ├── Camera2D         — 摄像机
 ├── UI               — 战斗界面
 ├── TurnManager      — 回合管理
 ├── CombatManager    — 战斗计算
 └── AudioManager     — 音频管理
```

### 单位结构

```
Unit
 ├── Sprite2D / AnimatedSprite2D
 ├── AnimationPlayer
 ├── StateMachine     — 行动状态：Idle, Moved, Acted, Dead
 ├── StatusEffects    — 异常状态：Poison, Sleep, Paralysis, Silence
 ├── Stats            — 属性：HP, MP, STR, MAG, SKL, SPD, DEF, RES, LUK, MOV
 └── Weapon           — 武器：Sword, Lance, Axe, Bow, Staff, Magic
```

### 核心系统间关系

- **回合系统**驱动 Player/Enemy/NPC 轮流行动
- **战斗公式**：物理伤害 = max(0, STR + WeaponMight + 武器克制伤害修正 - (DEF + 地形defense_bonus))；魔法伤害 = max(0, MAG + WeaponMight - RES)；命中 = WeaponHit + SKL×2 + LUK + 武器克制命中修正 + 高度差修正 - (目标SPD/2 + 目标LUK + 地形avoid_bonus)；暴击 = SKL/2 + WeaponCrit
- **武器克制**：剑>斧>枪>剑，克制方命中+15、伤害+1
- **AI 优先级**：击杀 > 攻残血 > 攻治疗 > 占点 > 靠近玩家
- **成长系统**：升级时按成长率随机提升属性

## 开发阶段

1. **第一阶段（核心循环）**：TileMap、光标、单位移动、回合切换
2. **第二阶段（战斗）**：攻击、AI、死亡、动画
3. **第三阶段（成长）**：技能、职业、装备
4. **第四阶段（内容）**：剧情、地图、音乐
5. **第五阶段（优化）**：平衡、UI、性能

## PRD

完整产品需求文档见 `docs/prd/TOP_PRD.md`。
