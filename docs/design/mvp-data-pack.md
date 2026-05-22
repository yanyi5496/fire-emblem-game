# MVP 数据包 —— 单位、武器、职业、技能、地图完整数据集

## 1. 概述

本文档定义 MVP 阶段所需的全部游戏数据，包括单位、武器、职业、技能、地图的 JSON 完整样例与字段说明。所有数据遵循 `data-driven.md` 规范，可直接录入 `res://data/` 对应子目录。

## 2. 单位数据

路径：`res://data/units/`

### 2.1 字段说明

| 字段 | 类型 | 必填 | 说明 |
|---|---|---|---|
| id | string | 是 | 唯一标识，snake_case |
| name | string | 是 | 显示名称 |
| job | string | 是 | 职业 ID，引用 jobs/ |
| level | int | 是 | 等级，1~20 |
| exp | int | 是 | 当前经验值，0~99 |
| stats | object | 是 | 10 项基础属性 |
| growth_rates | object | 否 | 成长率，缺省时视为 0 |
| inventory | string[] | 是 | 武器 ID 列表 |
| skills | string[] | 是 | 技能 ID 列表 |

### 2.2 hero_001 —— 艾克（玩家主角·剑士）

```json
{
  "id": "hero_001",
  "name": "艾克",
  "job": "swordman",
  "level": 1,
  "exp": 0,
  "stats": {
    "hp": 18,
    "mp": 0,
    "str": 7,
    "mag": 1,
    "skl": 6,
    "spd": 7,
    "def": 4,
    "res": 1,
    "luk": 5,
    "mov": 5
  },
  "growth_rates": {
    "hp": 80,
    "mp": 10,
    "str": 50,
    "mag": 15,
    "skl": 45,
    "spd": 55,
    "def": 35,
    "res": 20,
    "luk": 40
  },
  "inventory": ["iron_sword"],
  "skills": ["sword_adept"]
}
```

### 2.3 hero_002 —— 琳娜（玩家·牧师）

```json
{
  "id": "hero_002",
  "name": "琳娜",
  "job": "priest",
  "level": 1,
  "exp": 0,
  "stats": {
    "hp": 14,
    "mp": 12,
    "str": 1,
    "mag": 6,
    "skl": 5,
    "spd": 5,
    "def": 2,
    "res": 7,
    "luk": 6,
    "mov": 5
  },
  "growth_rates": {
    "hp": 60,
    "mp": 60,
    "str": 10,
    "mag": 55,
    "skl": 40,
    "spd": 45,
    "def": 20,
    "res": 55,
    "luk": 45
  },
  "inventory": ["heal_staff"],
  "skills": ["heal_light"]
}
```

### 2.4 enemy_001 —— 山贼（敌方·斧兵）

```json
{
  "id": "enemy_001",
  "name": "山贼",
  "job": "axefighter",
  "level": 1,
  "exp": 0,
  "stats": {
    "hp": 20,
    "mp": 0,
    "str": 8,
    "mag": 0,
    "skl": 3,
    "spd": 4,
    "def": 5,
    "res": 1,
    "luk": 2,
    "mov": 5
  },
  "growth_rates": {
    "hp": 85,
    "str": 55,
    "skl": 30,
    "spd": 35,
    "def": 40,
    "res": 10,
    "luk": 25
  },
  "inventory": ["iron_axe"],
  "skills": []
}
```

### 2.5 enemy_002 —— 山贼头目（敌方·斧兵 Boss）

```json
{
  "id": "enemy_002",
  "name": "山贼头目",
  "job": "axefighter",
  "level": 3,
  "exp": 0,
  "stats": {
    "hp": 28,
    "mp": 0,
    "str": 11,
    "mag": 0,
    "skl": 5,
    "spd": 5,
    "def": 7,
    "res": 2,
    "luk": 3,
    "mov": 5
  },
  "growth_rates": {
    "hp": 85,
    "str": 55,
    "skl": 30,
    "spd": 35,
    "def": 40,
    "res": 10,
    "luk": 25
  },
  "inventory": ["iron_axe"],
  "skills": ["tough_body"]
}
```

## 3. 武器数据

路径：`res://data/weapons/`

### 3.1 字段说明

| 字段 | 类型 | 必填 | 说明 |
|---|---|---|---|
| id | string | 是 | 唯一标识 |
| name | string | 是 | 显示名称 |
| type | string | 是 | sword/lance/axe/bow/staff/magic |
| might | int | 是 | 威力 |
| hit | int | 是 | 命中率修正 |
| crit | int | 是 | 暴击率修正 |
| weight | int | 是 | 重量 |
| min_range | int | 是 | 最小射程 |
| max_range | int | 是 | 最大射程 |
| durability | int | 是 | 耐久度 |
| effective_tags | string[] | 是 | 特攻标签列表 |
| is_magic | bool | 是 | 是否为魔法攻击 |

### 3.2 iron_sword

```json
{
  "id": "iron_sword",
  "name": "铁剑",
  "type": "sword",
  "might": 5,
  "hit": 90,
  "crit": 0,
  "weight": 5,
  "min_range": 1,
  "max_range": 1,
  "durability": 40,
  "effective_tags": [],
  "is_magic": false
}
```

### 3.3 iron_axe

```json
{
  "id": "iron_axe",
  "name": "铁斧",
  "type": "axe",
  "might": 8,
  "hit": 75,
  "crit": 0,
  "weight": 8,
  "min_range": 1,
  "max_range": 1,
  "durability": 35,
  "effective_tags": [],
  "is_magic": false
}
```

### 3.4 heal_staff

```json
{
  "id": "heal_staff",
  "name": "治疗杖",
  "type": "staff",
  "might": 0,
  "hit": 100,
  "crit": 0,
  "weight": 2,
  "min_range": 1,
  "max_range": 2,
  "durability": 30,
  "effective_tags": [],
  "is_magic": false
}
```

### 3.5 fire_magic

```json
{
  "id": "fire_magic",
  "name": "火球术",
  "type": "magic",
  "might": 6,
  "hit": 85,
  "crit": 5,
  "weight": 4,
  "min_range": 1,
  "max_range": 2,
  "durability": 25,
  "effective_tags": [],
  "is_magic": true
}
```

## 4. 职业数据

路径：`res://data/jobs/`

### 4.1 字段说明

| 字段 | 类型 | 必填 | 说明 |
|---|---|---|---|
| id | string | 是 | 唯一标识 |
| name | string | 是 | 显示名称 |
| tier | int | 是 | 职业阶层：1=初级，2=高级 |
| promotes_to | string | 否 | 转职目标职业 ID |
| weapons | string[] | 是 | 可用武器类型列表 |
| mov | int | 是 | 基础移动力 |
| growth_bonus | object | 否 | 成长率修正 |
| terrain_adaptation | object | 否 | 地形适应，key=地形ID，value=额外移动消耗 |
| skills | string[] | 否 | 职业技能列表 |

### 4.2 swordman

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
    "forest": 1
  },
  "skills": []
}
```

### 4.3 axefighter

```json
{
  "id": "axefighter",
  "name": "斧兵",
  "tier": 1,
  "promotes_to": "warrior",
  "weapons": ["axe"],
  "mov": 5,
  "growth_bonus": {
    "hp": 10,
    "str": 10,
    "def": 5
  },
  "terrain_adaptation": {},
  "skills": []
}
```

### 4.4 priest

```json
{
  "id": "priest",
  "name": "牧师",
  "tier": 1,
  "promotes_to": "sage",
  "weapons": ["staff"],
  "mov": 5,
  "growth_bonus": {
    "mp": 10,
    "mag": 5,
    "res": 10
  },
  "terrain_adaptation": {},
  "skills": []
}
```

## 5. 技能数据

路径：`res://data/skills/`

### 5.1 字段说明

| 字段 | 类型 | 必填 | 说明 |
|---|---|---|---|
| id | string | 是 | 唯一标识 |
| name | string | 是 | 显示名称 |
| type | string | 是 | active / passive / aura / counter |
| trigger | string | 是 | 触发时机枚举 |
| cost | object | 否 | 消耗，如 {"mp": 5} |
| effect | object | 是 | 效果定义 |
| range | int | 否 | 光环半径（仅 aura） |
| cooldown | int | 否 | 冷却回合（仅 active） |
| description | string | 否 | 技能描述文本 |
| priority | int | 否 | 执行优先级，默认 50 |

### 5.2 sword_adept

```json
{
  "id": "sword_adept",
  "name": "剑术专精",
  "type": "passive",
  "trigger": "before_combat",
  "cost": {},
  "effect": {
    "type": "stat_bonus",
    "target": "self",
    "stat": "str",
    "value": 2,
    "duration": 1
  },
  "description": "战斗时力量 +2",
  "priority": 100
}
```

### 5.3 heal_light

```json
{
  "id": "heal_light",
  "name": "治愈之光",
  "type": "active",
  "trigger": "before_combat",
  "cost": {
    "mp": 4
  },
  "effect": {
    "type": "heal",
    "value": 10
  },
  "cooldown": 1,
  "description": "恢复一名友军 10 点 HP",
  "priority": 50
}
```

### 5.4 tough_body

```json
{
  "id": "tough_body",
  "name": "强韧体魄",
  "type": "passive",
  "trigger": "on_damage",
  "cost": {},
  "effect": {
    "type": "stat_bonus",
    "target": "self",
    "stat": "def",
    "value": 3,
    "duration": 1
  },
  "description": "被攻击时防御 +3",
  "priority": 70
}
```

## 6. 地图数据

路径：`res://data/maps/`

### 6.1 字段说明

| 字段 | 类型 | 必填 | 说明 |
|---|---|---|---|
| id | string | 是 | 唯一标识 |
| name | string | 是 | 显示名称 |
| width | int | 是 | 地图宽（格数） |
| height | int | 是 | 地图高（格数） |
| tiles | int[][] | 是 | 地形数据，二维数组 [row][col] |
| terrain_ids | string[][] | 否 | 显式地形 ID 矩阵，缺省时 tiles 存地形 ID |
| events | object[] | 否 | 事件点列表 |
| units | object[] | 是 | 初始单位站位 |
| victory_condition | string | 是 | "rout" / "seize" / "defend" / "escape" |
| defeat_condition | string | 是 | "all_dead" / "commander_dead" |
| max_turns | int | 否 | 回合上限，缺省为 20 |

### 6.2 单位站位字段

| 字段 | 类型 | 说明 |
|---|---|---|
| unit_id | string | 单位模板 ID |
| x | int | 列（0-base） |
| y | int | 行（0-base） |
| team | string | "player" / "enemy" / "npc" |

### 6.3 事件点字段

| 字段 | 类型 | 说明 |
|---|---|---|
| x | int | 列 |
| y | int | 行 |
| type | string | "dialog" / "reward" / "reinforce" / "teleport" / "escape" |
| params | object | 事件参数 |

### 6.4 mvp_map_01 —— 山道遭遇战

```json
{
  "id": "mvp_map_01",
  "name": "山道遭遇战",
  "width": 10,
  "height": 10,
  "tiles": [
    [1,1,1,1,1,1,1,1,1,1],
    [1,1,1,1,1,1,1,1,1,1],
    [1,1,2,2,1,1,2,2,1,1],
    [1,1,2,2,1,1,2,2,1,1],
    [1,1,1,1,3,3,1,1,1,1],
    [1,1,1,1,3,3,1,1,1,1],
    [1,1,2,2,1,1,2,2,1,1],
    [1,1,2,2,1,1,2,2,1,1],
    [1,1,1,1,1,1,1,1,1,1],
    [1,1,1,1,1,1,1,1,1,1]
  ],
  "terrain_ids": [
    ["plain","plain","plain","plain","plain","plain","plain","plain","plain","plain"],
    ["plain","plain","plain","plain","plain","plain","plain","plain","plain","plain"],
    ["plain","plain","forest","forest","plain","plain","forest","forest","plain","plain"],
    ["plain","plain","forest","forest","plain","plain","forest","forest","plain","plain"],
    ["plain","plain","plain","plain","mountain","mountain","plain","plain","plain","plain"],
    ["plain","plain","plain","plain","mountain","mountain","plain","plain","plain","plain"],
    ["plain","plain","forest","forest","plain","plain","forest","forest","plain","plain"],
    ["plain","plain","forest","forest","plain","plain","forest","forest","plain","plain"],
    ["plain","plain","plain","plain","plain","plain","plain","plain","plain","plain"],
    ["plain","plain","plain","plain","plain","plain","plain","plain","plain","plain"]
  ],
  "terrain_defs": {
    "plain": {"move_cost": 1, "avoid_bonus": 0, "defense_bonus": 0, "walkable": true, "height": 0},
    "forest": {"move_cost": 2, "avoid_bonus": 20, "defense_bonus": 1, "walkable": true, "height": 1},
    "mountain": {"move_cost": 3, "avoid_bonus": 10, "defense_bonus": 2, "walkable": true, "height": 2}
  },
  "units": [
    {"unit_id": "hero_001", "x": 1, "y": 1, "team": "player"},
    {"unit_id": "hero_002", "x": 2, "y": 1, "team": "player"},
    {"unit_id": "enemy_001", "x": 8, "y": 8, "team": "enemy"},
    {"unit_id": "enemy_002", "x": 7, "y": 9, "team": "enemy"}
  ],
  "victory_condition": "rout",
  "defeat_condition": "all_dead",
  "max_turns": 20
}
```

地形 ID 说明：
- `1` = plain，`2` = forest，`3` = mountain
- `terrain_defs` 中的定义覆盖默认地形表

## 7. 数据交叉引用一致性

| 数据文件 | 被引用方 | 检查项 |
|---|---|---|
| hero_001.job="swordman" | jobs/swordman.json | 必须存在 |
| hero_001.inventory=["iron_sword"] | weapons/iron_sword.json | 必须存在 |
| hero_001.skills=["sword_adept"] | skills/sword_adept.json | 必须存在 |
| hero_002.job="priest" | jobs/priest.json | 必须存在 |
| hero_002.inventory=["heal_staff"] | weapons/heal_staff.json | 必须存在 |
| enemy_001.inventory=["iron_axe"] | weapons/iron_axe.json | 必须存在 |
| mvp_map_01.units[].unit_id | units/ 下对应 JSON | 全部必须存在 |
| mvp_map_01.terrain_ids[] | terrain_defs key | 全部必须有定义 |

## 8. 数据目录文件清单

```
res://data/
├── units/
│   ├── hero_001.json
│   ├── hero_002.json
│   ├── enemy_001.json
│   └── enemy_002.json
├── weapons/
│   ├── iron_sword.json
│   ├── iron_axe.json
│   ├── heal_staff.json
│   └── fire_magic.json
├── jobs/
│   ├── swordman.json
│   ├── axefighter.json
│   └── priest.json
├── skills/
│   ├── sword_adept.json
│   ├── heal_light.json
│   └── tough_body.json
└── maps/
    └── mvp_map_01.json
```
