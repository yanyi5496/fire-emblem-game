# MVP UI 线框文档

## 1. 概述

本文档定义 MVP 阶段所有 UI 界面的布局、交互流程和状态说明。采用纯文本 + 方框草图画法，可直接用 Godot Control 节点实现。

MVP 界面列表：
- 主菜单（MainMenu）
- 设置菜单（SettingsMenu）
- 战斗 HUD（BattleHUD）
- 行动菜单（ActionMenu）
- 攻击预览（AttackPreview）
- 回合提示（TurnIndicator）
- 对话框（DialogueBox）

## 2. 主菜单（MainMenu）

### 2.1 布局草图

```
┌─────────────────────────────────┐
│                                 │
│          ┌───────────┐          │
│          │ PROJECT   │          │
│          │  EMBER    │          │
│          │ (Logo)    │          │
│          └───────────┘          │
│                                 │
│      ┌──────────────────┐       │
│      │   新 游 戏        │       │
│      └──────────────────┘       │
│      ┌──────────────────┐       │
│      │   继 续 游 戏      │       │
│      └──────────────────┘       │
│      ┌──────────────────┐       │
│      │   设 置            │       │
│      └──────────────────┘       │
│      ┌──────────────────┐       │
│      │   退 出            │       │
│      └──────────────────┘       │
│                                 │
└─────────────────────────────────┘
```

### 2.2 节点结构

```
MainMenu (CanvasLayer)
├── VBoxContainer (居中)
│   ├── TextureRect (Logo)
│   ├── Button "新游戏"   → scene_router.goto("intro_story")
│   ├── Button "继续游戏" → save_manager.load_slot_menu()
│   ├── Button "设置"     → scene_router.goto("settings")
│   └── Button "退出"     → get_tree().quit()
├── BGM: AudioStreamPlayer (主菜单 BGM)
```

### 2.3 状态说明

| 状态 | 行为 |
|---|---|
| 无存档 | "继续游戏" 按钮灰显，不可点击 |
| 有存档 | "继续游戏" 高亮，点击进入存档选择 |
| 任何按钮点击 | 播放 UI 确认音效 |

## 3. 设置菜单（SettingsMenu）

### 3.1 布局草图

```
┌─────────────────────────────────┐
│           设 置                   │
│                                 │
│  总音量    [■■■■■■■░░░]  70%    │
│  BGM      [■■■■■■░░░░]  60%    │
│  SFX      [■■■■■■■■░░]  80%    │
│  语音     [■■■■■■■■■■] 100%    │
│                                 │
│  分辨率    [ 1920x1080 ▼  ]     │
│  全屏      [ ✓ ]                │
│  语言      [ 简体中文 ▼  ]      │
│                                 │
│      [ 返回 ]                    │
└─────────────────────────────────┘
```

### 3.2 节点结构

```
SettingsMenu (CanvasLayer)
├── VBoxContainer
│   ├── Label "设置"
│   ├── HSlider (master_volume) + Label (显示百分比)
│   ├── HSlider (bgm_volume) + Label
│   ├── HSlider (sfx_volume) + Label
│   ├── HSlider (voice_volume) + Label
│   ├── OptionButton (分辨率列表)
│   ├── CheckButton (全屏)
│   ├── OptionButton (语言列表)
│   └── Button "返回" → scene_router.back()
```

### 3.3 状态说明

- 滑块值范围 0~100，步长 5
- 更改立即写入 `audio_manager` 并保存到存档设置
- 分辨率变更实时生效

## 4. 战斗 HUD（BattleHUD）

### 4.1 布局草图

```
┌─────────────────────────────────┐
│ [回合: 玩家]                    │
│                                 │
│                    ┌────────────┤
│                    │ 艾克       │
│                    │ HP 18/18   │
│                    │ STR 7      │
│                    │ 铁剑 [40]  │
│                    │            │
│                    │ [森林: 回避+20]│
│                    └────────────┤
│                                 │
│     [移动] [攻击] [待机]        │
│                                 │
│   ┌────────────────────────┐    │
│   │ 攻击: 艾克 → 山贼      │    │
│   │ 命中 100% 伤害 8       │    │
│   │ 反击: 命中 40% 伤害 10 │    │
│   │ [执行攻击]             │    │
│   └────────────────────────┘    │
│                                 │
└─────────────────────────────────┘
```

### 4.2 节点结构

```
BattleHUD (CanvasLayer, layer=10)
├── TurnIndicator (HBoxContainer, 左上角)
│   └── Label "回合: 玩家/敌方"
├── UnitInfoPanel (VBoxContainer, 右上角)
│   ├── Label (角色名)
│   ├── Label (HP: current/max)
│   ├── Label (STR/MAG/SKL/SPD/DEF/RES)
│   ├── Label (当前武器 + 耐久)
│   └── Label (当前地形名 + 加成)
├── ActionMenu (VBoxContainer, 左下角)
│   ├── Button "移动"
│   ├── Button "攻击"
│   ├── Button "治疗/技能"
│   └── Button "待机"
├── AttackPreview (Panel, 中下)
│   ├── Label "攻击方 → 防守方"
│   ├── Label "命中 XX%  伤害 XX"
│   ├── Label "反击: 命中 XX%  伤害 XX"
│   ├── Label "追击: 有/无"
│   └── Button "执行攻击" / "取消"
└── TileInfoPanel (Panel, 右下角，可选)
    └── Label (光标所在格的地形信息)
```

### 4.3 面板显隐规则

| 场景 | 显示面板 |
|---|---|
| 首次进入战斗场景 | 光标默认聚焦首个可操作玩家单位，显示 TurnIndicator + UnitInfoPanel + TileInfoPanel |
| 无单位选中 | TurnIndicator + TileInfoPanel |
| 选中己方单位(Idle) | UnitInfoPanel + ActionMenu |
| 选中己方单位(Moved) | UnitInfoPanel + ActionMenu(攻击/技能/待机) |
| 选中己方单位(Acted) | UnitInfoPanel 只读 |
| 选中敌方单位 | UnitInfoPanel 只读（显示可查看的属性） |
| 选择攻击目标后 | AttackPreview（覆盖 ActionMenu） |
| 敌方行动中 | TurnIndicator 更新 + 所有面板锁定 |

## 5. 行动菜单（ActionMenu）

### 5.1 布局草图

```
┌──────────────┐
│  移 动       │
│  攻 击       │
│  待 机       │
└──────────────┘
```

### 5.2 菜单选项可用规则

| 选项 | 可用条件 |
|---|---|
| 移动 | action_state == Idle，且存在可移动格 |
| 攻击 | action_state 为 Idle 或 Moved，装备可用武器，射程内有目标 |
| 治疗 | 装备 Staff 且射程内有 HP 不满的友军 |
| 待机 | 始终可用，结束行动 |

### 5.3 交互流程

```
选中单位 → 弹出 ActionMenu
  ├→ 点击"移动" → 高亮移动范围 → 点击目标格 → 单位移动 → action_state=Moved → 弹回 ActionMenu
  ├→ 点击"攻击" → 高亮攻击范围 → 点击目标 → 弹出 AttackPreview
  │   ├→ "执行攻击" → CombatManager.exec() → 播放动画 → action_state=Acted
  │   └→ "取消" → 回到 ActionMenu
  ├→ 点击"治疗" → 高亮治疗范围 → 点击目标 → 执行治疗 → action_state=Acted
  └→ 点击"待机" → action_state=Acted → 菜单关闭
```

## 6. 攻击预览（AttackPreview）

### 6.1 布局草图

```
┌──────────────────────────────────┐
│  ┌──────┐          ┌──────┐     │
│  │ 艾克 │   →→→    │ 山贼 │     │
│  │ HP18 │          │ HP20 │     │
│  └──────┘          └──────┘     │
│                                  │
│  命中 100%   暴击 3%              │
│  伤害 8                          │
│  反击: 命中 40%  伤害 10          │
│  追击: 无                        │
│  地形: 平原 → 森林               │
│                                  │
│  克制: 剑→斧  命中+15  伤害+1    │
│                                  │
│      [ 执行攻击 ]  [ 取消 ]       │
└──────────────────────────────────┘
```

### 6.2 数据来源

- AttackPreview 只显示 `CombatManager.simulate(attacker, defender, weapon)` 的返回值
- 不自行计算公式
- 模拟结果结构参考蓝图 §7.1

### 6.3 颜色编码

| 字段 | 正面 | 负面 | 中性 |
|---|---|---|---|
| 命中率 | ≥80% 绿色 | ≤50% 红色 | 其他白色 |
| 伤害 | — | — | 白色 |
| 反击 | — | ≥10 红色 | <10 白色 |

## 7. 回合提示（TurnIndicator）

### 7.1 布局草图

```
┌──────────────────────┐
│  第 2 回合 · 玩家回合  │
└──────────────────────┘
```

### 7.2 状态机

```
[玩家回合] → (玩家点击"结束回合"或全部 Acted)
    → 渐出 → [敌方回合] → (AI 全部行动完毕)
    → 渐出 → [回合结算] → (Round End 流程)
    → [玩家回合] → ...
```

### 7.3 回合切换效果

- 切换前显示提示文字 1.5 秒
- 切换音效播放
- 敌方回合期间所有玩家输入禁用

## 8. 对话框（DialogueBox）

### 8.1 布局草图

```
┌──────────────────────────────────┐
│  ┌────┐                          │
│  │立绘│  艾克                    │
│  │图  │                          │
│  │片  │  这就是山贼的营地吗？     │
│  │    │                          │
│  └────┘                          │
│                    [▼ 继续]       │
└──────────────────────────────────┘
```

### 8.2 节点结构

```
DialogueBox (CanvasLayer, layer=20)
├── TextureRect (立绘, 左侧)
├── VBoxContainer (右侧)
│   ├── Label (角色名)
│   ├── RichTextLabel (对话文本)
│   └── HBoxContainer
│       ├── TextureRect (继续指示箭头)
│       └── Button (继续/跳过)
```

### 8.3 分支选择

```
┌──────────────────────────────────┐
│  ┌────┐                          │
│  │立绘│  艾克，你打算怎么做？     │
│  │图  │                          │
│  │片  │                          │
│  └────┘                          │
│                                  │
│      ┌────────────────────┐      │
│      │ 1. 正面迎战         │      │
│      └────────────────────┘      │
│      ┌────────────────────┐      │
│      │ 2. 先侦察再行动     │      │
│      └────────────────────┘      │
└──────────────────────────────────┘
```

分支选择出现在 `[Choice]` 标记处，每个选项是一个 Button。

## 9. UI 交互约束

| 场景 | 行为 |
|---|---|
| 键盘 | 方向键移动光标，Enter 确认，ESC 取消/返回 |
| 手柄 | 左摇杆移动光标，A 确认，B 取消 |
| 鼠标 | 点击目标格/按钮操作 |
| 动画中 | 拒绝所有输入，动画队列完成后恢复 |
| 敌方回合 | 拒绝所有输入，摄像头可自由移动 |

## 10. 资源共享

| UI 元素 | 复用组件 | 出现位置 |
|---|---|---|
| HP 条 | HPBar.tscn | UnitInfoPanel, TileInfoPanel |
| 按钮样式 | theme(.tres) | 全部 Button 共用 |
| 立绘容器 | PortraitFrame.tscn | DialogueBox, UnitInfoPanel |
| 字体 | 统一 .tres 字体 | 全部 Label |
