# MVP 资源生产计划

## 1. 目的

本文档基于 `resource-checklist.md`，把资源需求转换成可分发、可排期、可占位替代的生产计划。目标是在不阻塞 Godot 开发的前提下，优先把 MVP 真正需要的资源准备到位。

## 2. 生产原则

### 2.1 总原则

- 先保证可玩，再追求精细表现
- P0 资源允许占位，但必须可被程序直接接入
- 同类资源优先保持统一风格，不追求单个资源过度精修
- 所有资源文件命名遵守 `naming-conventions.md`

### 2.2 交付状态定义

| 状态 | 含义 |
|---|---|
| 待制作 | 尚未开始 |
| 占位可用 | 可支持开发联调 |
| 正式可用 | 可进入 MVP 演示 |
| 后续优化 | MVP 之后继续打磨 |

## 3. 第一批必须准备的资源

### 3.1 P0 资源包

| 类别 | 资源数量 | 最低交付要求 | 目标状态 |
|---|---|---|---|
| 单位 Sprite | 4 | 可区分阵营与角色 | 占位可用 |
| Tile 图块 | 3 | 平原/森林/山地能一眼区分 | 占位可用 |
| UI 核心元素 | 10+ | 光标、按钮、面板、高亮齐备 | 占位可用 |
| 核心 VFX | 3 | 命中/治疗/死亡有反馈 | 占位可用 |
| 核心 BGM | 2 | 战斗、胜利 | 占位可用 |
| 核心 SFX | 10+ | 输入、命中、治疗、死亡、回合切换 | 占位可用 |
| 字体 | 2 | 中文稳定显示 | 正式可用 |

## 4. 分类生产表

### 4.1 单位与立绘

| 资源 ID | 当前优先级 | 首轮交付 | 正式版要求 | 占位方案 |
|---|---|---|---|---|
| `sprite_hero_001` | P0 | 蓝色近战占位图 | 剑士动作表 | 蓝色方块 + “艾” |
| `sprite_hero_002` | P0 | 蓝色支援占位图 | 牧师动作表 | 蓝色方块 + “琳” |
| `sprite_enemy_001` | P0 | 红色敌兵占位图 | 山贼动作表 | 红色方块 + “贼” |
| `sprite_enemy_002` | P0 | 红色 Boss 占位图 | 头目动作表 | 深红方块 + “头” |
| `portrait_hero_001` | P1 | 可缺省 | 3 种表情 | 用名称条替代 |
| `portrait_hero_002` | P1 | 可缺省 | 3 种表情 | 用名称条替代 |
| `portrait_enemy_002` | P1 | 可缺省 | 1 种表情 | 用名称条替代 |

### 4.2 Tile 与场景表现

| 资源 ID | 当前优先级 | 首轮交付 | 正式版要求 | 占位方案 |
|---|---|---|---|---|
| `tile_plain` | P0 | 纯色可辨识 | 带轻微纹理的平原图块 | 浅绿色色块 |
| `tile_forest` | P0 | 纯色可辨识 | 带树冠/阴影感的森林图块 | 深绿色色块 |
| `tile_mountain` | P0 | 纯色可辨识 | 带岩石轮廓的山地图块 | 灰棕色色块 |

### 4.3 UI 资源

| 资源组 | 必须项 | 首轮交付要求 | 可后补项 |
|---|---|---|---|
| 主菜单 | `ui_logo`, `ui_button_*`, `ui_panel_bg` | 按钮状态可区分 | `ui_bg_mainmenu` |
| 战斗界面 | `ui_cursor`, `ui_panel_bg`, `ui_highlight_*` | 战斗信息与范围可读 | 额外装饰边框 |
| 图标 | `ui_icon_hp`, `ui_icon_mp`, `ui_icon_sword`, `ui_icon_axe`, `ui_icon_staff` | 可读即可 | 更细致职业/状态图标 |
| 对话框 | `ui_arrow_continue` | 有继续提示 | 更完整装饰元素 |

### 4.4 VFX 与音频

| 资源 ID | 当前优先级 | 首轮交付 | 占位方案 |
|---|---|---|---|
| `vfx_hit` | P0 | 命中闪烁/爆点 | 白色闪烁 Sprite |
| `vfx_heal` | P0 | 绿色上升特效 | 绿色圆环缩放 |
| `vfx_death` | P0 | 淡出/碎散效果 | Alpha 淡出 |
| `bgm_battle_theme` | P0 | 循环战斗曲 | 临时循环音乐 |
| `bgm_victory` | P0 | 胜利结束曲 | 短提示音延长版 |
| `sfx_menu_confirm` | P0 | 菜单确认音 | 测试哔声 |
| `sfx_menu_cancel` | P0 | 菜单取消音 | 测试哔声 |
| `sfx_menu_cursor` | P0 | 光标移动音 | 测试哔声 |
| `sfx_attack_sword` | P0 | 剑攻击音 | 通用挥击音 |
| `sfx_attack_axe` | P0 | 斧攻击音 | 通用挥击音 |
| `sfx_hit` | P0 | 命中反馈音 | 通用打击音 |
| `sfx_death` | P0 | 死亡反馈音 | 短淡出音 |
| `sfx_heal` | P0 | 治疗反馈音 | 上升音阶 |
| `sfx_turn_change` | P0 | 回合切换音 | 短提示音 |
| `sfx_dialog_next` | P0 | 对话推进音 | 轻点击音 |

## 5. 开发阻塞关系

### 5.1 会直接阻塞场景联调的资源

- `tile_plain`
- `tile_forest`
- `tile_mountain`
- `ui_cursor`
- `ui_highlight_move`
- `ui_highlight_attack`
- `ui_highlight_heal`
- 4 个单位占位图
- 中文字体

### 5.2 不阻塞逻辑、但会明显影响演示质量的资源

- `ui_logo`
- `ui_panel_bg`
- `bgm_battle_theme`
- `bgm_victory`
- `vfx_hit`
- `vfx_heal`
- `portrait_*`

## 6. 推荐排期

### 第 1 批：开战可玩包

- 3 张 Tile 占位图
- 4 个单位占位图
- `ui_cursor`
- `ui_highlight_move`
- `ui_highlight_attack`
- `ui_highlight_heal`
- 中文字体

目标：能进入地图、移动、攻击、治疗、看清格子与单位。

### 第 2 批：战斗反馈包

- `ui_panel_bg`
- `ui_button_*`
- `vfx_hit`
- `vfx_heal`
- `vfx_death`
- `sfx_menu_*`
- `sfx_attack_*`
- `sfx_hit`
- `sfx_heal`
- `sfx_turn_change`

目标：战斗过程具备基本手感和反馈。

### 第 3 批：演示增强包

- `ui_logo`
- `ui_bg_mainmenu`
- `portrait_*`
- `bgm_main_menu`
- `bgm_battle_prepare`
- `bgm_battle_theme`
- `bgm_victory`
- `bgm_sad_defeat`

目标：做出可以对外演示的 MVP 包装层。

## 7. 验收标准

每类资源交付后，至少检查：

1. 文件名与资源 ID 是否一致
2. 分辨率是否符合文档约定
3. 是否能被占位方案无缝替换
4. 是否存在透明边缘、尺寸错位或中文显示问题
5. 是否会阻塞地图、UI 或战斗联调

## 8. 资源外包或协作说明

如果资源由其他人制作，建议同时发出以下信息：

- 资源 ID 与用途
- 分辨率
- 是否需要透明背景
- 动画帧数
- 是否允许先交占位版本
- 预计使用场景截图或线框

## 9. 当前建议

如果资源人力有限，优先保住下面这条链路：

`Tile 占位 -> 单位占位 -> 光标/高亮 -> 字体 -> 命中/治疗反馈 -> 战斗 BGM`

只要这条链路打通，Godot 侧就能开始进行完整战斗流程联调，其余资源都可以继续并行补充。
