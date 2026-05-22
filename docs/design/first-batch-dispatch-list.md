# 第一批可立即分发任务清单

## 1. 目的

本文档把当前最值得立刻发出的任务整理成一页执行单，避免每次还要从排期、资源计划和模板里手动摘任务。

适用阶段：

- `M1 可玩占位包`

## 2. 发包优先级

建议严格按以下顺序发：

1. Tile 占位图
2. 单位占位图
3. UI 占位资源
4. 音频占位包
5. 中文字体确认

## 3. 任务清单

### 任务 1：Tile 占位图

| 项目 | 内容 |
|---|---|
| 任务类型 | 美术 |
| 优先级 | P0 |
| 交付物 | `tile_plain.png`, `tile_forest.png`, `tile_mountain.png` |
| 输入文档 | `mvp-map-production-pack.md`, `mvp-resource-production-plan.md`, `mvp-style-benchmark.md` |
| 最低标准 | 三种地形一眼可区分，不影响单位与高亮可读性 |

### 任务 2：单位占位图

| 项目 | 内容 |
|---|---|
| 任务类型 | 美术 |
| 优先级 | P0 |
| 交付物 | `sprite_hero_001.png`, `sprite_hero_002.png`, `sprite_enemy_001.png`, `sprite_enemy_002.png` |
| 输入文档 | `mvp-data-pack.md`, `mvp-resource-production-plan.md`, `mvp-style-benchmark.md` |
| 最低标准 | 玩家/敌方一眼可分，头目与普通敌兵一眼可分 |

### 任务 3：UI 占位资源

| 项目 | 内容 |
|---|---|
| 任务类型 | UI / 美术 |
| 优先级 | P0 |
| 交付物 | `ui_cursor.png`, `ui_highlight_move.png`, `ui_highlight_attack.png`, `ui_highlight_heal.png`, `ui_panel_bg.png`, `ui_button_normal.png`, `ui_button_hover.png`, `ui_button_pressed.png` |
| 输入文档 | `ui-wireframes.md`, `mvp-resource-production-plan.md`, `mvp-style-benchmark.md` |
| 最低标准 | 能清楚支撑菜单、战斗高亮和信息面板显示 |

### 任务 4：音频占位包

| 项目 | 内容 |
|---|---|
| 任务类型 | 音频 |
| 优先级 | P0 |
| 交付物 | `bgm_battle_theme.ogg`, `sfx_menu_confirm.wav`, `sfx_menu_cancel.wav`, `sfx_menu_cursor.wav`, `sfx_attack_sword.wav`, `sfx_attack_axe.wav`, `sfx_hit.wav`, `sfx_heal.wav`, `sfx_turn_change.wav`, `sfx_dialog_next.wav` |
| 输入文档 | `story-mvp-direction-sheet.md`, `mvp-resource-production-plan.md`, `mvp-style-benchmark.md` |
| 最低标准 | 可循环、不过刺、具备传统战棋气质 |

### 任务 5：中文字体确认

| 项目 | 内容 |
|---|---|
| 任务类型 | UI / 程序协作 |
| 优先级 | P0 |
| 交付物 | 1 套中文主字体，1 套粗体或标题字体 |
| 输入文档 | `resource-checklist.md`, `mvp-resource-production-plan.md`, `mvp-style-benchmark.md` |
| 最低标准 | UI 与对白场景可稳定显示中文，不缺常用字符 |

## 4. 交付后怎么收

这 5 个任务交付后，统一按下面顺序验收：

1. 用 `resource-delivery-checklist.md` 验文件
2. 用 `naming-conventions.md` 验命名
3. 用 `mvp-style-benchmark.md` 验风格方向
4. 通过后标记进入 `M1 可玩占位包`

## 5. 完成判定

当这 5 个任务全部交付且基本通过验收后，可以认为：

`非代码准备已完成到可启动 Godot 首轮联调的程度`

这也是当前准备工作的自然结束点。
