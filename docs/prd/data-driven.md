# 数据驱动设计 PRD

## 1. 概述

项目采用数据驱动架构，所有核心游戏数据通过 JSON 文件定义，运行时由 Godot 加载为模板数据和内存实例。模板数据不在战斗中直接修改。

关联主 PRD: [TOP_PRD.md](./TOP_PRD.md)

## 2. 目录结构

```text
res://data/
├── units/
├── skills/
├── weapons/
├── maps/
└── jobs/
```

## 3. 加载架构

```text
启动时:
  1. 扫描 res://data/*/ 下所有 .json
  2. 解析为 Dictionary 或 Resource
  3. 注册到 DataManager
  4. 通过 ID 提供只读模板查询

运行时:
  5. 根据模板创建单位/地图等实例
  6. 战斗中的变化只写入运行时实例或存档
```

## 4. JSON 规范

### 4.1 通用规则

- 所有 ID 使用 `snake_case`
- 每种类型内 ID 必须唯一
- 未知字段在开发模式下报错
- 可选字段必须在文档中定义默认值

### 4.2 数据示例

**武器**

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
  "effective_tags": []
}
```

**单位**

```json
{
  "id": "hero_001",
  "name": "艾克",
  "job": "swordman",
  "level": 1,
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
    "str": 50,
    "skl": 45,
    "spd": 55,
    "def": 35,
    "res": 20,
    "luk": 40
  },
  "inventory": ["iron_sword"],
  "skills": []
}
```

**职业**

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
  }
}
```

## 5. DataManager API

| 方法 | 描述 |
|---|---|
| `get_unit(id)` | 获取单位模板 |
| `get_weapon(id)` | 获取武器模板 |
| `get_skill(id)` | 获取技能模板 |
| `get_job(id)` | 获取职业模板 |
| `get_map(id)` | 获取地图模板 |
| `load_all()` | 加载全部数据 |
| `reload()` | 编辑器开发模式重载 |

## 6. 运行时数据

- 单位实例数据存储在内存中
- 地图实例保存地形破坏、事件完成等动态变化
- 存档序列化运行时实例，不序列化原始模板
- 运行时单位实例应包含 `action_state`、`status_effects`、当前 HP/MP 等战斗态字段

## 7. Godot 实现约束

- 重复 ID 在开发模式下视为致命错误
- JSON 解析失败时阻止进入战斗场景
- 建议在 Autoload 中提供 `DataManager`

### 7.1 Schema 校验策略

建议分三层校验：

| 层级 | 检查内容 | 失败处理 |
|---|---|---|
| 语法层 | JSON 是否可解析 | 直接报错并停止加载 |
| 结构层 | 必填字段、字段类型、枚举值是否合法 | 报错并阻止该模板进入运行时 |
| 引用层 | `job`、`weapon`、`skill` 等外键是否存在 | 报错并终止启动流程 |

推荐最小校验项：

- 单位：`id`、`job`、`stats`、`growth_rates`
- 武器：`id`、`type`、`might`、`min_range`、`max_range`
- 技能：`id`、`type`、`trigger`、`effect`
- 职业：`id`、`weapons`、`mov`

## 8. 边界条件

| 场景 | 行为 |
|---|---|
| JSON 格式错误 | 报错并阻止加载 |
| 缺失引用 | 报错并阻止对应数据进入运行时 |
| ID 重复 | 报错并中止启动流程 |
| 文件编码错误 | 记录错误并终止加载 |
| 目录不存在 | 记录错误，要求补全资源 |

## 9. 依赖关系

- [单位系统](./unit-system.md) — 加载单位模板
- [武器系统](./weapon-system.md) — 加载武器模板
- [技能系统](./skill-system.md) — 加载技能模板
- [职业系统](./job-system.md) — 加载职业模板
- [地图系统](./map-system.md) — 加载地图模板
- [存档系统](./save-system.md) — 序列化运行时实例
