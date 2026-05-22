# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

**Project Ember** — 基于 Godot 4.6 的火焰纹章风格 SRPG（战棋策略角色扮演）游戏。

- 引擎：Godot 4.6（GL Compatibility 渲染器，D3D12 驱动）
- 语言：GDScript
- 数据格式：JSON / Resource
- 物理引擎：Jolt Physics（3D）
- 目标平台：Windows / Linux / macOS / Steam
- 目标帧率：60 FPS，最大地图 64x64

## 当前真源

当前开发应以以下文档为最高优先级真源：

1. `docs/prd/TOP_PRD.md`
2. `docs/architecture/godot-implementation-blueprint.md`
3. `docs/design/README.md`

如果旧文档、旧注释、旧脚本习惯与上述内容冲突，以上述真源为准。

## 构建与运行

- 使用 Godot Editor 4.6 打开项目目录运行
- 无命令行构建/测试工具链，所有开发通过 Godot Editor 进行

## 当前玩法边界

- 当前 MVP 只做 `2D TileMap` 战棋主循环
- 当前只保障首关 `mvp_map_01`
- 当前只保障 2 名玩家单位、2 名敌方单位的首轮闭环
- 非 MVP 内容不得通过“顺手一起做”混入核心链路

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
 ├── StateMachine     — 状态：Idle, Moved, Acted, Dead, Poison, Sleep, Paralysis, Silence
 ├── Stats            — 属性：HP, MP, STR, MAG, SKL, SPD, DEF, RES, LUK, MOV
 └── Weapon           — 武器：Sword, Lance, Axe, Bow, Staff, Magic
```

### 核心系统间关系

- **回合系统**驱动 Player/Enemy/NPC 轮流行动
- **战斗公式**：Damage = Attack - Defense；Hit = WeaponHit + Skill×2 + Luck；Crit = Skill/2 + WeaponCrit
- **武器克制**：剑>斧>枪>剑，克制方命中+15、伤害+1
- **AI 优先级**：击杀 > 攻残血 > 攻治疗 > 占点 > 靠近玩家
- **成长系统**：升级时按成长率随机提升属性

## 运行时架构约束

### 1. GameState 是全局运行时权威

`GameState` 是唯一允许长期持有以下信息的全局权威对象：

- 当前章节
- 当前地图 ID
- 当前回合数
- 当前全局 phase
- 可被存档序列化的剧情/背包/金币/完成记录

约束：

- 其他系统可以缓存这些值，但不能悄悄拥有第二份“真相”
- 只要 battle/story/save 流程会修改这些值，就必须同步回 `GameState`

### 2. TurnManager 拥有回合推进，GameState 镜像回合结果

- `TurnManager` 负责玩家/敌方/NPC/Round End 的推进顺序
- `GameState.turn_number` 必须与 `TurnManager.turn_number` 同步
- 任何增加回合数的逻辑，必须同时更新 `GameState`

禁止：

- 在多个系统里各自独立递增回合数
- 依赖某个局部节点变量作为唯一回合真相

### 3. SaveManager 只序列化受控 schema

存档不是任意字典快照，而是受控 schema。

强制要求：

- `SaveManager` 只能保存 `GameState` 已声明的稳定字段
- 只要存档字段结构发生不兼容变化，必须升级 `SAVE_VERSION`
- `_validate_version()` 不能只检查有没有 `version` 字段，必须验证版本和关键字段
- 如果要兼容旧档，必须显式写迁移逻辑

禁止：

- 变更存档结构但不改版本号
- 读档成功却 silently 回退默认值

### 4. SceneRouter 只负责切场景，不负责业务真相

`SceneRouter` 的职责是切场景，不是保存业务上下文。

强制要求：

- 场景切换依赖的业务参数，必须在切场景前写入 `GameState` 或专门的 route state
- 被切入的场景必须自己校验所需上下文是否齐全

禁止：

- 假设 `goto("battle")` 会自动知道当前地图
- 在路由层偷偷吞掉业务参数

### 5. StoryPlayer 必须统一进入和退出

`StoryPlayer` 的生命周期必须走统一入口/出口：

- 进入：`play_story()`
- 退出：统一清理函数（例如 `_finish()`）

强制要求：

- 任何结束剧情的事件都必须走统一清理路径
- 统一清理路径必须负责：
  - 隐藏 UI
  - 恢复/切换 phase
  - 发出完成信号

禁止：

- 在某些分支里直接 `emit` 完成信号但不清理 phase
- 让 `InputManager` 残留在 `DIALOGUE` 模式

### 6. InputManager 模式切换必须集中管理

输入模式是全局行为，不允许分散写死。

强制要求：

- 菜单/剧情/战斗输入模式切换统一通过 `GameState.set_phase()` 触发
- 新增 phase 时，必须同时补 `GameState._sync_input_mode()`

禁止：

- 在业务脚本里绕过 phase 直接随意改输入模式
- 新增菜单或剧情场景但忘记接 phase

### 7. 场景契约必须闭合

任何挂脚本的 `.tscn` 都必须满足该脚本所依赖的最小节点契约。

强制要求：

- 如果脚本里存在 `@onready` 节点依赖，场景中必须有对应节点
- 如果一个场景承担主流程入口职责（如 `BattleScene`、`MainMenu`、`StoryPlayer`），它必须真正挂上主控脚本
- 场景装配层不能停留在“只有根节点”的空壳状态然后假设后续再补

禁止：

- 脚本已经依赖 `$AnimatedSprite2D` / `$TurnManager` / `$DialogueBox`，但场景里没有这些节点
- 战斗场景只有 TileMap 壳子，没有真正的 battle 启动链

### 8. BattleScene 必须能自启动

`BattleScene` 作为战斗入口，进入场景后必须具备最小可运行能力：

- 能从 `GameState.current_map_id` 读取当前地图
- 能完成地图数据加载
- 能生成单位
- 能启动第一回合

禁止：

- 进入战斗场景后还需要外部手动补调 `start_battle()` 才能动
- 路由层只切场景，不补业务上下文，导致战斗场景空转

## 编码约束

### 1. 能用枚举就不用字符串

如果某个系统已经引入枚举，例如：

- `GameState.GamePhase`
- `UnitRuntimeState.ActionState`

则后续代码不得继续扩写同义字符串分支。

### 2. Autoload 单例不要再注册同名 class_name

如果某个脚本已经在 `project.godot` 中注册为 autoload 单例，例如 `DataManager`、`GameState`、`SaveManager`，则该脚本本身不要再声明同名 `class_name`。

强制要求：

- autoload 脚本通过单例名全局访问
- 只有确实需要被实例化复用的普通脚本，才声明 `class_name`

禁止：

- 让 autoload 名和 `class_name` 同名，触发 Godot 的命名遮蔽警告
- 既把脚本当全局单例，又把它当普通类到处 `new()`

### 3. 禁止双重真相

以下信息不得在多个系统中各自独立维护而不声明同步关系：

- 当前地图
- 当前回合
- 当前 phase
- 单位行动状态
- 存档版本

如果确实需要镜像：

- 必须明确“谁是权威、谁是镜像”
- 必须在代码里有显式同步点

### 4. 改存档必须成套修改

只要新增、删除、重命名存档字段，必须同时修改：

1. `GameState.to_dict()`
2. `GameState.from_dict()`
3. `SaveManager.SAVE_VERSION`
4. `SaveManager._validate_version()`
5. 对应测试

### 5. 改 phase 必须成套修改

只要新增或调整全局 phase，必须同时检查：

1. `GameState.GamePhase`
2. `GameState._sync_input_mode()`
3. 进入该 phase 的调用点
4. 退出该 phase 的调用点
5. 相关测试或手工验收脚本

### 6. 路由依赖必须显式声明

任何会依赖外部上下文的场景，必须明确：

- 由谁写入上下文
- 写入哪些字段
- 场景进入时如何校验
- 缺失时如何报错或回退

### 7. 新逻辑必须补最小回归

涉及以下类别的改动，必须至少补一条最小回归测试或验收项：

- 存档 schema
- phase / 输入模式切换
- 剧情结束路径
- 回合推进
- 地图加载入口

### 8. Dictionary 数据只能显式取值

GDScript 中 `Dictionary` 不是稳定的对象字段协议，运行时数据必须显式读取。

强制要求：

- 对 `Dictionary` 取值时，只能使用 `data["key"]` 或 `data.get("key", default)`
- 来自 JSON、剧情解析、战斗预览、AI 决策、寻路队列的运行时数据，一律按字典处理
- 如果某段数据已经稳定成对象协议，必须先封装成明确类或资源，再使用点号属性

禁止：

- 把 `Dictionary` 当成对象写成 `data.unit_id`、`line.type`、`result.damage`
- 在 AI、剧情、存档、战斗这类主链路里混用字典访问和对象访问

### 9. 场景改动必须补契约测试

只要修改以下任一内容，必须同步检查或补充场景契约测试：

- 新增 `@onready` 节点依赖
- 场景主控脚本挂载关系
- 菜单 / 剧情 / 战斗入口场景

最低标准：

- 场景能 `instantiate()`
- 关键节点路径存在
- 主流程入口场景不再是空壳

## 推荐开发顺序

如果一个需求同时涉及多个系统，默认按下面顺序落地：

1. 先定数据和状态边界
2. 再定场景切换和生命周期
3. 再写业务逻辑
4. 最后补 UI 表现和资源引用

不要反过来从 UI 或场景引用开始倒推核心状态。

## 开发阶段

1. **第一阶段（核心循环）**：TileMap、光标、单位移动、回合切换
2. **第二阶段（战斗）**：攻击、AI、死亡、动画
3. **第三阶段（成长）**：技能、职业、装备
4. **第四阶段（内容）**：剧情、地图、音乐
5. **第五阶段（优化）**：平衡、UI、性能

## PRD

当前顶层产品需求文档见 `docs/prd/TOP_PRD.md`。
