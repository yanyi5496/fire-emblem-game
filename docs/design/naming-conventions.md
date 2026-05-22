# 命名规范

## 1. 概述

本文档统一 Project Ember 在 Godot 工程中的文件、节点、资源、脚本、数据 ID 的命名规则，确保团队协作时保持一致性。所有规则以 MSP（最小合理原则）为基准，MVP 阶段不强制全覆盖。

## 2. 通用规则

| 规则 | 说明 | 示例 |
|---|---|---|
| 全小写 + snake_case | 文件名、目录名、数据 ID | `hero_001.json`, `iron_sword` |
| PascalCase | 场景文件名、节点名、类名 | `BattleScene.tscn`, `TurnManager` |
| 前缀分类 | 类似类型加语义前缀 | `enemy_001`, `hero_002` |
| 不用数字开头 | 文件名/ID 不以数字开头 | 用 `enemy_001` 而非 `001_enemy` |
| 禁止特殊字符 | 文件名仅用 `a-z` `0-9` `_` `-` | — |
| 中文仅用于显示 | 代码、文件名、ID 中不用中文 | name="艾克"，id="hero_001" |

## 3. 目录命名

| 路径 | 规范 | 说明 |
|---|---|---|
| `res://scenes/` | 全小写，单数 | 场景目录 |
| `res://scripts/` | 全小写，单数 | 脚本目录 |
| `res://data/` | 全小写，单数 | 数据目录 |
| `res://assets/` | 全小写，复数 | 资源目录 |
| `res://resources/` | 全小写，复数 | Godot Resource 目录 |
| 子分类目录 | 全小写 snake_case | `battle/`, `unit/`, `ui/` |

## 4. 文件命名

### 4.1 场景文件 (.tscn)

| 模式 | 说明 | 示例 |
|---|---|---|
| `{PascalCase}.tscn` | 主场景 | `BattleScene.tscn`, `MainMenu.tscn` |
| `{PascalCase}.tscn` | 组件场景 | `ActionMenu.tscn`, `DialogueBox.tscn` |
| `{lower_case}.tscn` | 单一功能小组件 | `hp_bar.tscn`, `portrait_frame.tscn` |

### 4.2 脚本文件 (.gd)

| 模式 | 说明 | 示例 |
|---|---|---|
| `{snake_case}.gd` | 普通脚本 | `battle_controller.gd`, `turn_manager.gd` |
| `{snake_case}.gd` | Autoload 脚本 | `data_manager.gd`, `game_state.gd` |

### 4.3 数据文件 (.json)

| 模式 | 说明 | 示例 |
|---|---|---|
| `{snake_case}.json` | 单位、武器、职业、技能 | `hero_001.json`, `iron_sword.json` |
| `{snake_case}_map_XX.json` | 地图数据 | `mvp_map_01.json` |
| `{snake_case}.txt` | 剧情文本 | `mvp_story_01.txt` |

### 4.4 资源文件 (.png/.ogg/.wav)

| 前缀 | 分类 | 示例 |
|---|---|---|
| `sprite_` | 单位行走图/战斗图 | `sprite_hero_001.png` |
| `tile_` | TileMap 瓦片 | `tile_forest.png` |
| `portrait_` | 立绘 | `portrait_hero_001.png` |
| `ui_` | UI 元素 | `ui_button_normal.png`, `ui_cursor.png` |
| `vfx_` | 特效 | `vfx_hit.png` |
| `bgm_` | 背景音乐 | `bgm_battle_theme.ogg` |
| `sfx_` | 音效 | `sfx_hit.wav` |
| `font_` | 字体文件 | `font_noto_sans_sc.ttf` (可选前缀) |

## 5. ID 命名

### 5.1 单位 vs 角色

| 实体 | ID 模式 | 示例 |
|---|---|---|
| 有名角色（战斗模板） | `hero_XXX` | `hero_001`, `hero_002` |
| 通用敌人 | `enemy_XXX` | `enemy_001`, `enemy_002` |
| 特殊敌人 (Boss) | `boss_XXX` 或 `enemy_XXX` | `enemy_002`（Boss 也走 enemy 前缀） |
| 纯剧情角色（无战斗数据） | `char_XXX` | `char_villager_001`（MVP 不要求） |

### 5.2 武器/职业/技能

| 类型 | ID 模式 | 示例 |
|---|---|---|
| 武器 | `{材质}_{类型}` | `iron_sword`, `iron_axe`, `heal_staff`, `fire_magic` |
| 职业 | 职业 English 单字 | `swordman`, `axefighter`, `priest` |
| 技能 | `{效果}_{形容词}` snake_case | `sword_adept`, `heal_light`, `tough_body` |
| 地图 | `{章节}_map_{数字}` | `mvp_map_01` |

### 5.3 场景节点

| 节点 | 推荐节点名 | 对应的 tscn |
|---|---|---|
| 战斗主节点 | BattleScene | `battle_scene.tscn` |
| 地面 TileMap | GroundTileMap | 内建于场景 |
| 高亮 TileMap | HighlightTileMap | 内建于场景 |
| 单位容器 | Units | 内建于场景 |
| 光标 | Cursor | `battle_cursor.tscn` |
| 主菜单 | MainMenu | `main_menu.tscn` |
| 设置面板 | SettingsMenu | `settings_menu.tscn` |
| 对话框 | DialogueBox | `dialogue_box.tscn` |

## 6. 信号命名

| 模式 | 说明 | 示例 |
|---|---|---|
| `{事件}_started` | 事件开始 | `combat_started`, `turn_started` |
| `{事件}_finished` | 事件结束 | `combat_finished`, `turn_finished` |
| `{对象}_selected` | 选中 | `unit_selected`, `tile_selected` |
| `{对象}_moved` | 对象移动 | `unit_moved` |
| `{对象}_changed` | 属性变更 | `hp_changed`, `action_state_changed` |

示例：
```gdscript
signal combat_started(attacker, defender)
signal combat_finished(result)
signal unit_selected(unit)
signal turn_changed(phase_name)
```

## 7. 常量与枚举命名

| 模式 | 说明 | 示例 |
|---|---|---|
| `UPPER_SNAKE_CASE` | 全局常量 | `MAX_MAP_SIZE = 64` |
| PascalCase | 枚举名 | `enum ActionState { Idle, Moved, Acted, Dead }` |
| `UPPER_SNAKE_CASE` | 枚举成员 | `ActionState.Idle` |

## 8. 地图 JSON 字段命名

| 字段 | 规则 | 示例值 |
|---|---|---|
| 地形 ID | 全小写 | `"plain"`, `"forest"`, `"mountain"` |
| 单位坐标 | `x`=列, `y`=行 | `"x": 1, "y": 1` |
| 队伍标识 | 全小写 | `"player"`, `"enemy"`, `"npc"` |
| 胜负条件 | 全小写 | `"rout"`, `"seize"`, `"escape"` |

## 9. Git 提交信息规范

对将来开发阶段的参考格式（MVP 开发阶段不强制）：

```
类型(范围): 简短描述

示例:
feat(core): add movement range highlight
fix(combat): correct crit rate floor to 0
data(units): adjust hero_001 growth rates
docs(map): add mvp map layout diagram
```

## 10. 避免的做法

| ❌ 不要做 | ✅ 改为 |
|---|---|
| `final_battle_final_v3.png` | `map_01_boss.png` |
| `0001.json` | `enemy_001.json` |
| `艾克.json` | `hero_001.json` (中文仅写在 name 字段) |
| `testScene.tscn` | 发布时重命名为规范名 |
| `unit_script.gd` 混入节点名 | `unit_actor.gd`（功能明确的名称） |
