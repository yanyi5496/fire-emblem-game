# 剧情系统 PRD

## 1. 概述

剧情系统驱动游戏叙事，包括对话、分支、立绘、CG 和过场动画。剧本采用文本格式，保证内容策划可以直接维护。

关联主 PRD: [TOP_PRD.md](./TOP_PRD.md)

## 2. 剧本格式

### 2.1 基本语法

```text
[Character: 艾克]
对话内容

[Choice]
1. 选项一
2. 选项二

[Condition: flag_name]
条件触发的对话

[Event: event_id]
触发游戏事件
```

### 2.2 标记列表

| 标记 | 描述 |
|---|---|
| `[Character: 名称]` | 显示角色名与立绘 |
| `[Narrator]` | 旁白 |
| `[Choice]` | 分支选项 |
| `[Condition: xxx]` | 条件触发内容 |
| `[Event: xxx]` | 触发游戏事件 |
| `[CG: xxx]` | 显示 CG |
| `[BGM: xxx]` | 切换背景音乐 |
| `[Effect: xxx]` | 屏幕特效 |

### 2.3 剧本示例

```text
[Narrator]
战争结束了。

[BGM: sad_music]

[Character: 艾克]
我们付出了太多代价。

[Character: 妮娜]
但至少，我们还活着。

[Choice]
1. 继续前进。
2. 先休整。

[Event: branch_ending_a]
```

## 3. 功能支持

- 对话框
- 分支剧情
- 立绘
- CG
- 可跳过过场动画

当前 MVP 只要求支持基础对话框和分支选择，CG 与复杂演出可后置。

## 4. Godot 实现建议

- 使用专用剧情管理器解析文本
- 分支与条件统一读写剧情标记
- 对话、立绘、BGM 通过事件驱动 UI 与音频系统

### 4.1 事件映射示例

| 剧本标记 | 目标系统 | 推荐调用 |
|---|---|---|
| `[BGM: battle_theme]` | 音频系统 | `AudioManager.play_bgm("battle_theme")` |
| `[CG: cg_001]` | UI/剧情系统 | `StoryPlayer.show_cg("cg_001")` |
| `[Effect: fade_out]` | UI/场景系统 | `SceneRouter.play_transition("fade_out")` |
| `[Event: open_gate]` | 地图/战斗系统 | `BattleController.handle_story_event("open_gate")` |
| `[Event: branch_ending_a]` | 存档/剧情系统 | 设置剧情标记并切换后续分支 |

## 5. 边界条件

| 场景 | 行为 |
|---|---|
| 剧本文件缺失 | 记录错误并阻止进入剧情段 |
| 角色数据缺失 | 显示占位名并记录警告 |
| 分支未定义 | 视为脚本错误，中止该段并记录错误 |
| CG 文件缺失 | 跳过 CG，继续文本并记录警告 |
| 语言文件缺失 | 使用默认语言 |

## 6. 依赖关系

- [存档系统](./save-system.md) — 保存剧情进度与分支
- [UI 系统](./ui-system.md) — 渲染对话框
- [音频系统](./audio-system.md) — BGM 与语音切换
