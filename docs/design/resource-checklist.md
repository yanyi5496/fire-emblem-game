# MVP 资源清单

## 1. 概述

本文档罗列 MVP 阶段需要制作或购买的所有美术、音频资源，含文件命名、规格说明和优先级标注。

资源配置路径以架构蓝图 `res://assets/` 下的约定为准。

## 2. 美术资源

### 2.1 角色 Sprite（单位行走图/战斗图）

| 资源 ID | 用途 | 分辨率 | 帧数 | 动画需求 | 优先级 |
|---|---|---|---|---|---|
| sprite_hero_001 | 艾克战斗图 | 64×64 (单帧) | 4×4 精灵表 | idle(4), walk(4), attack(4), hurt(2), death(2) | P0 |
| sprite_hero_002 | 琳娜战斗图 | 64×64 (单帧) | 4×4 精灵表 | idle(4), walk(4), attack(2), hurt(2), death(2) | P0 |
| sprite_enemy_001 | 山贼战斗图 | 64×64 (单帧) | 4×4 精灵表 | idle(4), walk(4), attack(4), hurt(2), death(2) | P0 |
| sprite_enemy_002 | 山贼头目战斗图 | 64×64 (单帧) | 4×4 精灵表 | idle(4), walk(4), attack(4), hurt(2), death(2) | P0 |

**文件路径：** `res://assets/sprites/units/`

**开发初期替代方案：** 使用 Godot `ColorRect` + 标签 或矩形色块占位，确保逻辑可测。

### 2.2 立绘（Portrait）

| 资源 ID | 角色 | 分辨率 | 表情 | 优先级 |
|---|---|---|---|---|
| portrait_hero_001 | 艾克 | 256×256 | normal / angry / injured | P1 |
| portrait_hero_002 | 琳娜 | 256×256 | normal / worried / smile | P1 |
| portrait_enemy_002 | 山贼头目 | 256×256 | angry | P1 |

**文件路径：** `res://assets/portraits/`

### 2.3 TileSet 瓦片

| 资源 ID | 地形 | 分辨率 | TileSet 中的 Tile ID | 优先级 |
|---|---|---|---|---|
| tile_plain | 平原 | 64×64 | 1 | P0 |
| tile_forest | 森林 | 64×64 | 2 | P0 |
| tile_mountain | 山地 | 64×64 | 3 | P0 |

**文件路径：** `res://assets/sprites/tiles/`

**占位方案：** 使用单色方框 `ColorRect` 代替，颜色按文档约定：
- 平原：#90B860
- 森林：#3A7A2A
- 山地：#8A7A5A

### 2.4 UI 元素

| 资源 ID | 用途 | 分辨率 | 格式 | 优先级 |
|---|---|---|---|---|
| ui_bg_mainmenu | 主菜单背景 | 1920×1080 | PNG | P1 |
| ui_logo | 游戏 Logo | 400×200 | PNG（含透明通道） | P0 |
| ui_button_normal | 默认按钮背景 | 32×16 (九宫格) | PNG | P0 |
| ui_button_hover | 悬停按钮背景 | 32×16 (九宫格) | PNG | P0 |
| ui_button_pressed | 按下按钮背景 | 32×16 (九宫格) | PNG | P0 |
| ui_panel_bg | 面板背景 | 16×16 (九宫格) | PNG | P0 |
| ui_icon_hp | HP 图标 | 16×16 | PNG | P0 |
| ui_icon_mp | MP 图标 | 16×16 | PNG | P0 |
| ui_icon_sword | 剑图标 | 16×16 | PNG | P0 |
| ui_icon_axe | 斧图标 | 16×16 | PNG | P0 |
| ui_icon_staff | 杖图标 | 16×16 | PNG | P0 |
| ui_cursor | 光标箭头/边框 | 64×64 | PNG | P0 |
| ui_arrow_continue | 对话继续箭头 | 16×16 | PNG 动画 | P0 |
| ui_highlight_move | 移动范围高亮 | 64×64 | PNG（半透明蓝） | P0 |
| ui_highlight_attack | 攻击范围高亮 | 64×64 | PNG（半透明红） | P0 |
| ui_highlight_heal | 治疗范围高亮 | 64×64 | PNG（半透明绿） | P0 |

**文件路径：** `res://assets/sprites/ui/`

### 2.5 特效（VFX）

| 资源 ID | 用途 | 分辨率 | 帧数 | 优先级 |
|---|---|---|---|---|
| vfx_hit | 命中特效 | 64×64 | 4 帧 | P0 |
| vfx_crit | 暴击特效 | 64×64 | 6 帧 | P1 |
| vfx_heal | 治疗特效 | 64×64 | 4 帧 | P0 |
| vfx_death | 死亡消散 | 64×64 | 4 帧 | P0 |

**文件路径：** `res://assets/vfx/`

**占位方案：** 圆形渐变或星形 Sprite 单帧替代。

## 3. 音频资源

### 3.1 BGM

| 资源 ID | 用途 | 格式 | 时长 | 优先级 |
|---|---|---|---|---|
| bgm_main_menu | 主菜单 | OGG | ~60s | P1 |
| bgm_battle_prepare | 战斗前准备 | OGG | ~60s | P1 |
| bgm_battle_theme | 战斗 BGM | OGG | ~90s | P0 |
| bgm_victory | 胜利 BGM | OGG | ~30s | P0 |
| bgm_sad_defeat | 败北 BGM | OGG | ~30s | P1 |

**文件路径：** `res://assets/audio/bgm/`

### 3.2 SFX

| 资源 ID | 用途 | 格式 | 优先级 |
|---|---|---|---|
| sfx_menu_confirm | 菜单确认 | WAV (16-bit 44100Hz) | P0 |
| sfx_menu_cancel | 菜单取消/返回 | WAV | P0 |
| sfx_menu_cursor | 光标移动 | WAV | P0 |
| sfx_attack_sword | 剑攻击 | WAV | P0 |
| sfx_attack_axe | 斧攻击 | WAV | P0 |
| sfx_hit | 命中 | WAV | P0 |
| sfx_miss | 闪避 | WAV | P0 |
| sfx_crit | 暴击 | WAV | P1 |
| sfx_death | 死亡 | WAV | P0 |
| sfx_heal | 治疗 | WAV | P0 |
| sfx_move | 移动脚步声 | WAV | P0 |
| sfx_turn_change | 回合切换 | WAV | P0 |
| sfx_victory_jingle | 胜利短音 | WAV | P0 |
| sfx_defeat_jingle | 败北短音 | WAV | P1 |
| sfx_dialog_next | 对话推进 | WAV | P0 |

**文件路径：** `res://assets/audio/sfx/`

## 4. 字体资源

| 文件 | 用途 | 优先级 |
|---|---|---|
| NotoSansSC-Regular.ttf (或替代中文字体) | 对话文本、UI 标签 | P0 |
| NotoSansSC-Bold.ttf | 标题、HP 数字 | P0 |

**文件路径：** `res://assets/fonts/`

## 5. 资源依赖关系总表

| 资源 | 被谁使用 | 缺省影响 |
|---|---|---|
| sprite_hero_001 | unit.tscn 中 AnimatedSprite2D | 单位无法显示 |
| tile_plain/forest/mountain | GroundTileMap TileSet | 地图空白 |
| ui_cursor | battle_cursor.tscn | 无法看见光标 |
| ui_highlight_move/attack/heal | HighlightTileMap | 范围高亮不可见 |
| portrait_hero_001 | dialogue_box.tscn | 对话不显示立绘 |
| bgm_battle_theme | battle_scene 的 AudioAnchor | 战斗无 BGM |
| sfx_hit | combat_manager 播放 | 命中无音效 |
| NotoSansSC-* | 全部 Label | 中文乱码/缺失 |

## 6. 资源优先级说明

| 等级 | 含义 |
|---|---|
| P0 | MVP 核心体验必须，缺了就没法玩或严重损坏体验 |
| P1 | 增强体验，可先用占位替代，不影响功能验证 |
| P2 | 后续阶段补充，MVP 不要求 |

MVP 强制要求：所有 P0 资源必须到位或至少有功能等效的占位方案。

## 7. 占位替代方案汇总

| 资源类型 | 占位做法 |
|---|---|
| 单位 Sprite | ColorRect 统一大小，颜色区分阵营（蓝=玩家，红=敌方） |
| Tile 瓦片 | ColorRect + 字符（P/F/M 代表 plain/forest/mountain） |
| 立绘 | 单位 Sprite 放大，或用半透明矩形 + 角色名 |
| BGM | 静音或单音循环测试音 |
| SFX | 使用 Godot 的 AudioStreamGenerator 生成简单测试音 |
| VFX | 用 Tween 缩放/闪烁 ColorRect 替代 |
| Font | 使用 Godot 内置字体 + 找合适的免费中文字体兜底 |
