# Godot 4.6 实施蓝图

## 1. 目标

本蓝图将现有 PRD 进一步拆解为适合 Godot 4.6 开发的工程结构，重点回答四个问题：

- 场景怎么拆
- Autoload 怎么拆
- 数据资源怎么落
- MVP 应该按什么顺序实现

本文件默认约束：

- 引擎版本：Godot 4.6
- 主要语言：GDScript
- 地图与战斗均为 2D
- 战斗逻辑优先数据驱动，不把规则写死在 UI 或动画层

## 2. 推荐目录结构

```text
res://
├── scenes/
│   ├── boot/
│   │   └── boot_scene.tscn
│   ├── menu/
│   │   ├── main_menu.tscn
│   │   ├── settings_menu.tscn
│   │   └── save_load_menu.tscn
│   ├── battle/
│   │   ├── battle_scene.tscn
│   │   ├── cursor/
│   │   │   └── battle_cursor.tscn
│   │   ├── unit/
│   │   │   ├── unit.tscn
│   │   │   └── unit_status_icon.tscn
│   │   ├── ui/
│   │   │   ├── battle_hud.tscn
│   │   │   ├── action_menu.tscn
│   │   │   ├── attack_preview.tscn
│   │   │   └── tile_info_panel.tscn
│   │   └── effects/
│   │       ├── hit_effect.tscn
│   │       ├── crit_effect.tscn
│   │       └── skill_effect.tscn
│   └── story/
│       ├── story_player.tscn
│       ├── dialogue_box.tscn
│       └── choice_box.tscn
├── scripts/
│   ├── autoload/
│   ├── battle/
│   ├── unit/
│   ├── ui/
│   ├── story/
│   ├── data/
│   └── common/
├── data/
│   ├── units/
│   ├── weapons/
│   ├── jobs/
│   ├── skills/
│   ├── maps/
│   └── stories/
├── assets/
│   ├── sprites/
│   ├── portraits/
│   ├── audio/
│   └── vfx/
└── resources/
    ├── tilesets/
    ├── themes/
    └── shaders/
```

## 3. 场景拆分

### 3.1 Boot 层

`boot_scene.tscn`

- 负责最初启动
- 校验关键数据是否可加载
- 初始化 Autoload 依赖
- 根据状态跳转到主菜单或测试战斗场景

### 3.2 菜单层

`main_menu.tscn`

- 新游戏
- 继续游戏
- 设置
- 退出

`settings_menu.tscn`

- 分辨率
- 全屏
- Master/BGM/SFX/Voice
- 语言
- 按键

`save_load_menu.tscn`

- 存档列表
- 读取/覆盖确认

### 3.3 战斗层

`battle_scene.tscn` 推荐节点结构：

```text
BattleScene
├── MapRoot
│   ├── GroundTileMap
│   ├── BlockTileMap
│   ├── EventTileMap
│   └── HighlightTileMap
├── Units
├── Effects
├── Cursor
├── Camera2D
├── UI
└── AudioAnchor
```

节点职责：

- `GroundTileMap`：地形表现与基础地形数据
- `BlockTileMap`：阻挡与特殊可通行信息
- `EventTileMap`：撤离点、传送点、事件点
- `HighlightTileMap`：移动/攻击/治疗范围高亮
- `Units`：战斗单位实例容器
- `Effects`：命中、暴击、技能特效
- `Cursor`：战棋光标
- `UI`：战斗 HUD 与菜单

### 3.4 剧情层

`story_player.tscn`

- 解析 `stories/` 文本
- 控制立绘、文本、选项
- 调用 BGM/CG/Effect 事件

## 4. Autoload 拆分

推荐在 `Project Settings > Autoload` 注册以下脚本：

### 4.1 `data_manager.gd`

- 启动时加载 `res://data/`
- 提供 `get_unit/get_weapon/get_job/get_skill/get_map`
- 开发模式下支持 `reload()`

### 4.2 `game_state.gd`

- 当前章节
- 当前难度或模式标记
- 队伍与库存
- 剧情标记
- 全局运行状态

### 4.3 `scene_router.gd`

- 场景切换
- 主菜单/战斗/剧情互跳
- 场景切换前后淡入淡出

### 4.4 `save_manager.gd`

- 存档读写
- 自动存档调度
- 版本校验

### 4.5 `audio_manager.gd`

- BGM 切换
- 音效播放
- 总线音量设置

### 4.6 `input_manager.gd`

- 按键映射
- 战斗输入与菜单输入统一封装

## 5. 核心脚本职责

### 5.1 战斗域

`scripts/battle/battle_controller.gd`

- 战斗场景总控制器
- 组织回合、输入、胜负条件

`scripts/battle/turn_manager.gd`

- 维护 `Player Turn / Enemy Turn / NPC Turn / Round End`
- 重置单位 `action_state`
- 处理回合结算事件

`scripts/battle/combat_manager.gd`

- 统一命中/暴击/伤害/反击/追击计算
- 输出给 UI 和动画的同一份战斗结果对象

`scripts/battle/pathfinding_service.gd`

- 网格寻路
- 移动范围计算
- 攻击范围计算

`scripts/battle/ai_controller.gd`

- 生成敌人回合行动
- 评估收益
- 调用 `combat_manager` 模拟结果

### 5.2 单位域

`scripts/unit/unit_actor.gd`

- 单位场景主脚本
- 维护当前位置、动画、血条、选中状态

`scripts/unit/unit_runtime_state.gd`

- 运行时战斗数据
- `action_state`
- `status_effects`
- 当前 HP/MP/经验/装备

`scripts/unit/status_effect_service.gd`

- 中毒、睡眠、沉默、麻痹的添加/移除/结算

### 5.3 UI 域

`scripts/ui/battle_hud.gd`

- 同步选中单位信息
- 控制回合提示与消息提示

`scripts/ui/action_menu.gd`

- 攻击/技能/待机/物品菜单

`scripts/ui/attack_preview.gd`

- 仅展示 `combat_manager` 的模拟结果
- 不自行重新计算公式

### 5.4 剧情域

`scripts/story/story_parser.gd`

- 解析 `[Character: xxx]`
- 解析 `[Choice]`、`[Condition]`、`[Event]`

`scripts/story/story_player.gd`

- 驱动文本推进
- 发出剧情事件

## 6. 数据层落地建议

### 6.1 模板数据与运行时数据分离

建议采用两层：

- 模板层：`res://data/*.json`
- 运行时层：GDScript Dictionary / Object

不要在战斗中直接修改模板 JSON。

### 6.2 推荐数据最小集合

`units/*.json`

- 基础属性
- 成长率
- 初始职业
- 初始库存
- 技能列表

`weapons/*.json`

- `might/hit/crit/weight/min_range/max_range/durability`
- `effective_tags`

`jobs/*.json`

- `weapons`
- `mov`
- `growth_bonus`
- `terrain_adaptation`

`skills/*.json`

- `type`
- `trigger`
- `cost`
- `effect`
- `cooldown`

`maps/*.json`

- 地图尺寸
- 单位初始站位
- 胜负条件
- 事件点和传送点

`stories/*.txt` 或 `stories/*.json`

- 推荐前期继续使用文本格式
- 等分支复杂度上来后再考虑结构化

## 7. 关键对象建议

### 7.1 战斗结果对象

建议统一一份结果结构，供动画、音效、UI、日志共用：

```json
{
  "attacker_id": "hero_001",
  "defender_id": "enemy_001",
  "weapon_id": "iron_sword",
  "hit_rate": 78,
  "crit_rate": 6,
  "damage": 7,
  "did_hit": true,
  "did_crit": false,
  "did_counter": true,
  "did_follow_up": false,
  "applied_effects": []
}
```

### 7.2 单位运行时对象

```json
{
  "unit_id": "hero_001",
  "grid_pos": [4, 7],
  "current_hp": 18,
  "current_mp": 0,
  "action_state": "Idle",
  "status_effects": [],
  "equipped_weapon": "iron_sword"
}
```

## 8. MVP 开发顺序

### 阶段 1：最小战场

- `BattleScene`
- `Cursor`
- 单位生成
- TileMap 点击/移动
- 基础回合切换

完成标准：

- 2 名玩家单位、2 名敌方单位可正常站位与轮流行动

### 阶段 2：基础战斗

- `CombatManager`
- 攻击预览
- 命中/伤害/死亡
- 武器耐久

完成标准：

- 能完成一次完整“移动 -> 攻击 -> 反击/死亡 -> 回合结束”

### 阶段 3：数据驱动

- `DataManager`
- 从 JSON 生成单位、武器、职业、地图
- 存档最小闭环

完成标准：

- 更换 JSON 不改脚本即可改单位数值与地图配置

### 阶段 4：技能与 AI

- `before_combat/after_combat`
- 中毒、沉默等基础状态
- 敌方主动寻敌与攻击

完成标准：

- 敌人能自动行动，技能能参与战斗流程

### 阶段 5：剧情与菜单

- 主菜单
- 设置
- 剧情对话
- 进入关卡/结束关卡流程

完成标准：

- 从主菜单开始一局，战斗结束后进入下一段流程

## 9. 现在就可以开始建的空壳

如果马上开工，建议先建立这些文件：

```text
res://scenes/battle/battle_scene.tscn
res://scenes/battle/unit/unit.tscn
res://scenes/battle/cursor/battle_cursor.tscn
res://scenes/battle/ui/battle_hud.tscn
res://scripts/autoload/data_manager.gd
res://scripts/autoload/game_state.gd
res://scripts/autoload/scene_router.gd
res://scripts/autoload/save_manager.gd
res://scripts/autoload/audio_manager.gd
res://scripts/battle/battle_controller.gd
res://scripts/battle/turn_manager.gd
res://scripts/battle/combat_manager.gd
res://scripts/battle/pathfinding_service.gd
res://scripts/unit/unit_actor.gd
res://scripts/unit/unit_runtime_state.gd
res://scripts/story/story_parser.gd
```

## 10. 不建议现在做的事

- 先做复杂转职树
- 先做联机
- 先做支持系统和结局配对
- 先把剧情解析做成超复杂 DSL
- 先做高成本动态镜头和全屏战斗演出

这些都容易打断 MVP 主链路。
