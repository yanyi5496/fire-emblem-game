# 协作者任务包模板

## 1. 目的

本文档用于把当前 MVP 非代码准备成果打包成可直接分发的协作任务。适用于美术、音频、剧情整理、UI 设计等外部或内部协作者。

使用方式：

- 每发一个任务，复制本模板
- 按具体岗位填写
- 同时附上对应文档链接与资源命名要求

## 2. 通用任务头

```text
任务名称：
任务类型：美术 / UI / 音频 / 剧情整理 / 测试支持 / 其他
优先级：P0 / P1 / P2
所属阶段：M1 可玩占位包 / M2 首关联调包 / M3 演示增强包
预计交付时间：
对接人：
```

## 3. 必附背景

```text
项目背景：
这是一个基于 Godot 4.6 的 2D TileMap SRPG 项目，当前只做 MVP 首关“山道遭遇战”。

本任务服务目标：
- 打通可玩链路 / 提升演示质量 / 锁定风格方向（三选一或多选）

必须遵守：
- 只围绕首关 MVP
- 不扩地图、不扩角色、不扩系统
- 所有命名遵守 naming-conventions.md
- 所有资源风格遵守 mvp-style-benchmark.md
```

## 4. 任务说明模板

```text
任务描述：

输入文档：
1.
2.
3.

交付物：
1.
2.
3.

最低完成标准：
1.
2.
3.

可接受占位方案：
1.
2.

不需要做的内容：
1.
2.
```

## 5. 美术任务模板

### 5.1 Tile 占位任务包

```text
任务名称：首关 Tile 占位图制作
任务类型：美术
优先级：P0
所属阶段：M1 可玩占位包

任务描述：
为首关制作 3 张 64x64 的 Tile 占位图，分别对应 plain / forest / mountain。

输入文档：
1. mvp-map-production-pack.md
2. mvp-resource-production-plan.md
3. mvp-style-benchmark.md

交付物：
1. tile_plain.png
2. tile_forest.png
3. tile_mountain.png

最低完成标准：
1. 三种地形一眼可区分
2. 平铺后不刺眼
3. 不影响单位与高亮可读性

可接受占位方案：
1. 纯色块 + 简单纹理

不需要做的内容：
1. 自动拼接
2. 高精度法线/阴影
```

### 5.2 单位占位任务包

```text
任务名称：首关单位占位图制作
任务类型：美术
优先级：P0
所属阶段：M1 可玩占位包

任务描述：
为艾克、琳娜、山贼、山贼头目制作 4 个可区分的单位占位图。

输入文档：
1. mvp-data-pack.md
2. mvp-resource-production-plan.md
3. mvp-style-benchmark.md

交付物：
1. sprite_hero_001.png
2. sprite_hero_002.png
3. sprite_enemy_001.png
4. sprite_enemy_002.png

最低完成标准：
1. 玩家与敌方一眼可分
2. 头目与普通山贼一眼可分
3. 放在地图上不糊、不抢 UI

可接受占位方案：
1. 简单角色剪影
2. 色块 + 武器轮廓

不需要做的内容：
1. 完整动作表
2. 高精度光影
```

## 6. UI 任务模板

```text
任务名称：首关战斗 UI 占位资源
任务类型：UI / 美术
优先级：P0
所属阶段：M1 可玩占位包

任务描述：
制作战斗中必须使用的光标、高亮、面板底图与按钮三态资源。

输入文档：
1. ui-wireframes.md
2. mvp-resource-production-plan.md
3. mvp-style-benchmark.md

交付物：
1. ui_cursor.png
2. ui_highlight_move.png
3. ui_highlight_attack.png
4. ui_highlight_heal.png
5. ui_panel_bg.png
6. ui_button_normal.png
7. ui_button_hover.png
8. ui_button_pressed.png
```

## 7. 音频任务模板

```text
任务名称：首关音频占位包
任务类型：音频
优先级：P0
所属阶段：M1 可玩占位包

任务描述：
提供首关联调必须的战斗 BGM 与基础 SFX。

输入文档：
1. story-mvp-direction-sheet.md
2. mvp-resource-production-plan.md
3. mvp-style-benchmark.md

交付物：
1. bgm_battle_theme.ogg
2. sfx_menu_confirm.wav
3. sfx_menu_cancel.wav
4. sfx_menu_cursor.wav
5. sfx_attack_sword.wav
6. sfx_attack_axe.wav
7. sfx_hit.wav
8. sfx_heal.wav
9. sfx_turn_change.wav
10. sfx_dialog_next.wav

最低完成标准：
1. 可循环或可重复使用
2. 不刺耳
3. 与传统战棋气质不冲突
```

## 8. 剧情整理任务模板

```text
任务名称：首关对白与演出复核
任务类型：剧情整理
优先级：P1
所属阶段：M2 首关联调包

任务描述：
对现有首关对白、立绘使用、BGM 切换和事件触发做文字层复核。

输入文档：
1. story-mvp-script.md
2. story-mvp-direction-sheet.md

交付物：
1. 一份修订建议清单
2. 一份精简对白版本（如有必要）

不需要做的内容：
1. 扩写第二章剧情
2. 增加分支系统
```

## 9. 任务发出前检查表

发送给协作者前，至少确认：

1. 是否写清楚资源 ID 和文件名
2. 是否写清楚分辨率或格式
3. 是否给了对应文档入口
4. 是否说明“最低完成标准”
5. 是否说明“可接受占位方案”
6. 是否说明“不需要做的内容”

## 10. 当前建议

如果现在马上要发包，我建议优先发这 4 个：

1. Tile 占位图
2. 单位占位图
3. UI 占位资源
4. 音频占位包

这四类最能直接支撑后续 Godot 联调，也最适合并行给不同人做。
