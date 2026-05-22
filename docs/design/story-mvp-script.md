# MVP 剧情剧本 —— 山道遭遇战

## 1. 概述

本文档提供 MVP 阶段唯一关卡「山道遭遇战」的完整剧情剧本，采用 `story-system.md` 定义的文本格式。剧本包含开战前剧情、战斗内对话、战后结算三部分。

## 2. 剧本文件

路径：`res://data/stories/mvp_story_01.txt`

### 2.1 开场剧情 — 接任务

```text
[Narrator]
边境小镇传来急报——一伙山贼占据了北方的山道，
抢劫过往商旅。

[BGM: serious_prepare]

[Character: 艾克]
又是山贼……这几个月他们已经第三次拦路了。

[Character: 琳娜]
这次不能再让他们跑了。艾克，我们去吧。

[Character: 艾克]
嗯。你负责治疗，别冲太前。

[Character: 琳娜]
知道啦知道啦。你才是，别又一个人往前冲。

[Narrator]
两人向北方的山道出发。

[BGM: battle_preparation]

[Event: load_map]
```

触发 `[Event: load_map]` 后，剧情播放器应加载 `mvp_map_01` 并切换到战斗场景；具体场景跳转接口由运行时实现决定。

### 2.2 战斗内触发对话（事件格）

以下对话在特定条件触发时显示，通过 EventTileMap 或单位位置检测触发。

**触发条件：** 艾克到达 (4,4) 附近（山地边缘）

```text
[Character: 艾克]
前面就是山道了……等等，有人。

[Character: 琳娜]
是山贼！他们好像也发现我们了。

[Character: 艾克]
准备战斗！

[BGM: battle_theme]
```

**触发条件：** 山贼头目 HP 首次低于 50%（<=14 HP）

```text
[Character: 山贼头目]
哼，没想到你们还有点本事……

[Character: 山贼头目]
但这改变不了什么！给我上！

[Event: enemy_berserk]
// 可选效果：头目周围所有敌方单位获得 +2 STR 增益
```

**触发条件：** 山贼头目死亡

```text
[Character: 山贼头目]
呃……可恶……不过是、刚开始……

[Character: 艾克]
威胁解除了。

[Character: 琳娜]
嗯。先回去吧，镇上的人该担心了。
```

### 2.3 胜利结算

```text
[Narrator]
山道的山贼被清剿了。

[BGM: victory]

[Character: 艾克]
呼……还算顺利。

[Character: 琳娜]
你的肩膀……受伤了？
让我看看。

[Character: 艾克]
小伤而已。倒是你，魔法消耗不小吧。

[Character: 琳娜]
我没事。回镇上好好休息就行了。

[Narrator]
两人踏上了返回小镇的路。
虽然这场战斗只是开始，
但至少今天的胜利属于他们。

[Event: chapter_clear]
```

### 2.4 败北结算

```text
[Narrator]
战场上恢复了寂静。

[Character: ???]
已经……结束了吗……

[BGM: sad_defeat]

[Narrator]
黑暗吞没了视野。

[Event: game_over]
```

## 3. 角色立绘关联

| 角色名 | 剧情标记中的名称 | 立绘资源 ID | 表情 |
|---|---|---|---|
| 艾克 | 艾克 | portrait_hero_001 | normal, angry, injured |
| 琳娜 | 琳娜 | portrait_hero_002 | normal, worried, smile |
| 山贼头目 | 山贼头目 | portrait_enemy_002 | angry |

## 4. BGM 切换表

| 剧情段 | BGM ID | 淡入时间 |
|---|---|---|
| 开场旁白 | serious_prepare | 0.5s |
| 出发前进 | battle_preparation | 0.5s |
| 战斗开始 | battle_theme | 0.3s |
| 胜利 | victory | 0.5s |
| 败北 | sad_defeat | 1.0s |

## 5. 剧本标记使用说明

| 行 | 作用 | 动画/UI 表现 |
|---|---|---|
| `[Narrator]` | 旁白，不显示立绘 | 立绘区域用暗色背景，文字居中 |
| `[Character: 名称]` | 角色对话 | 立绘 + 名称标签 + 打字机文本 |
| `[BGM: id]` | 切换背景音乐 | 无 UI 表现，音频管理器切换 |
| `[Event: id]` | 触发游戏事件 | 场景路由或战斗控制器处理 |
| `[Choice]` | 分支选项 | 弹出选项按钮 |

## 6. 分支预留

MVP 阶段不要求使用 `[Choice]` 分支选择。如果开发时间充裕，可在开场加入一个对话选择：

```text
[Choice]
1. 直接进攻（无变化，进入战斗）
2. 先侦察（跳过开场对话）

[Condition: choice_2]
[Event: skip_intro]
```

## 7. 文本量统计

| 段 | 角色行数 | 旁白行数 | 总字数 |
|---|---|---|---|
| 开场 | 8 | 3 | ~180 字 |
| 战斗内 | 6 | 0 | ~90 字 |
| 胜利结算 | 8 | 3 | ~160 字 |
| 败北结算 | 1 | 3 | ~30 字 |
| **合计** | **23** | **9** | **~460 字** |

## 8. 与数据包的对应关系

| 剧情元素 | 对应数据 |
|---|---|
| 战斗地图 | `maps/mvp_map_01.json` |
| 艾克 | `units/hero_001.json` |
| 琳娜 | `units/hero_002.json` |
| 山贼 | `units/enemy_001.json` |
| 山贼头目 | `units/enemy_002.json` |
| BGM 列表 | 见 `resource-checklist.md` 音频清单 |
| 立绘 | 见 `resource-checklist.md` 美术清单 |
