# Project Ember 10-Day Delivery Plan

**目标：** 用约 10 个工作日，把当前仓库从“单章可玩原型”推进到“可稳定演示、可交接他人继续扩展”的 MVP 版本。计划以现有代码结构为前提，不做大重构，优先补完整体验闭环、恢复闭环和最小测试闭环。

## 计划原则

- 先补玩家直接感知的闭环，再补系统深度。
- 先稳定主流程，再扩剧情/地图内容。
- 所有任务都以“Godot 场景内可验证”为最终标准，而不是只靠静态脚本通过。
- 不在这 10 天里做大规模架构迁移；只允许局部提炼 helper 和小型服务。

## 当前基线

- 已具备：
  - `主菜单 -> 剧情 -> 战斗 -> 结果页`
  - 基础攻击、地形修正、敌方 AI、回合切换、结果页
  - 战斗内保存、自动保存、最小运行时快照
  - 结果页后的基础流转
- 仍缺：
  - 主动技能完整链路
  - 更多异常状态与回合结算闭环
  - 战后剧情/章节推进的内容化
  - 更可信的测试与真实场景回归
  - 最小交付验收文档和缺陷回收

## 10 天排期

### Day 1：技能指令入口做成完整玩家流程

**目标：** 玩家能在战斗里稳定使用主动技能，而不只是看到入口。

**主要文件：**
- `D:/godot/fegame/scripts/battle/battle_controller.gd`
- `D:/godot/fegame/scripts/ui/action_menu.gd`
- `D:/godot/fegame/scenes/battle/ui/action_menu.tscn`
- `D:/godot/fegame/scripts/unit/unit_runtime_state.gd`

**工作项：**
- 梳理 `ActionMenu` 的技能显隐规则。
- 把主动技能目标选择从“只有治疗”扩到“按 skill effect 分流”。
- 补齐取消、目标为空、技能冷却中、目标满血等边界。
- UI 上给技能选择和执行结果最小反馈。

**验收：**
- `hero_002` 可稳定使用 `heal_light`。
- 冷却中技能不能再次施放。
- 取消选择不会把单位直接锁死。

### Day 2：把非治疗主动技能链路打通

**目标：** 技能系统不再只会治疗，至少支持 1 类主动攻击技能或辅助技能。

**主要文件：**
- `D:/godot/fegame/data/skills/*.json`
- `D:/godot/fegame/scripts/battle/battle_controller.gd`
- `D:/godot/fegame/scripts/battle/combat_manager.gd`
- `D:/godot/fegame/scripts/ui/battle_hud.gd`

**工作项：**
- 给技能 effect 建立最小分派规则：`heal`、`damage`、`buff/debuff`。
- 技能攻击沿用攻击预览或最小版技能预览。
- 为技能目标范围增加独立读取逻辑，不再强绑当前武器射程。

**验收：**
- 至少 1 个非治疗主动技能可在战斗内释放并生效。
- 技能范围和武器范围可区分。

### Day 3：回合结算从“占位”提升为最小系统闭环

**目标：** `Round End` 真正驱动状态变化。

**主要文件：**
- `D:/godot/fegame/scripts/battle/turn_manager.gd`
- `D:/godot/fegame/scripts/unit/status_effect_service.gd`
- `D:/godot/fegame/scripts/unit/unit_runtime_state.gd`

**工作项：**
- 固定回合结算顺序：毒伤 -> 持续时间递减 -> 自动回复 -> 技能冷却。
- 为 `poison / sleep / silence` 建最小作用规则。
- 明确异常状态在 `can_move / can_act / can_use_skill` 上的影响。

**验收：**
- 中毒单位回合结束掉血。
- `silence` 会阻止法术或治疗技能施放。
- 冷却按回合正确递减。

### Day 4：把 AI 从“能走能打”补到“有基本战术感”

**目标：** 敌方行为不只是靠近后出手，而是更接近 PRD 优先级。

**主要文件：**
- `D:/godot/fegame/scripts/battle/ai_controller.gd`
- `D:/godot/fegame/scripts/battle/combat_manager.gd`
- `D:/godot/fegame/scripts/battle/pathfinding_service.gd`

**工作项：**
- 落地最小优先级：击杀 > 攻残血 > 攻治疗 > 最近玩家。
- 让 AI 在多个可攻击目标中真正选最优。
- 为 AI 支持“移动后技能/治疗”留接口，哪怕本轮只先实现攻击。

**验收：**
- AI 优先攻击可击杀目标。
- 无可击杀目标时，倾向打残血。
- 路径和攻击选择不再明显反直觉。

### Day 5：地图规则与关卡胜败条件补齐到数据驱动

**目标：** 地图数据字段真正决定关卡结束条件。

**主要文件：**
- `D:/godot/fegame/scripts/battle/battle_controller.gd`
- `D:/godot/fegame/data/maps/*.json`
- `D:/godot/fegame/scripts/menu/battle_result_menu.gd`

**工作项：**
- 扩展 `victory_condition / defeat_condition / max_turns` 的实际消费。
- 若需要，补最小“守住目标/坚持回合数/击破首领”规则。
- 结果页根据关卡结果显示更明确文案。

**验收：**
- 至少 2 种胜负条件可真实触发。
- 超回合数的胜败判断稳定。

### Day 6：章节推进、战后剧情和下一关入口内容化

**目标：** 从“单页结果菜单”变成“章节完成流”。

**主要文件：**
- `D:/godot/fegame/scripts/menu/battle_result_menu.gd`
- `D:/godot/fegame/scripts/story/story_player.gd`
- `D:/godot/fegame/data/stories/*.txt`
- `D:/godot/fegame/scripts/autoload/game_state.gd`

**工作项：**
- 明确 `CHAPTER_FLOW` 数据结构。
- 补 1 段战后剧情和 1 个下一关入口。
- 保证 `story_flags`、`completed_maps`、`current_chapter` 一致。

**验收：**
- 胜利后可进战后剧情。
- 剧情结束后能正确回主菜单或进入下一关。
- 相关标记可被存档恢复。

### Day 7：存档系统做一次完整恢复性补强

**目标：** 读档后恢复的不只是“场景”，而是“当时能继续玩”。

**主要文件：**
- `D:/godot/fegame/scripts/autoload/save_manager.gd`
- `D:/godot/fegame/scripts/autoload/game_state.gd`
- `D:/godot/fegame/scripts/battle/battle_controller.gd`
- `D:/godot/fegame/scripts/unit/unit_actor.gd`

**工作项：**
- 检查并补齐 `action_state`、异常状态、技能冷却、战斗结果元数据的恢复。
- 明确不同场景下的 `resume_scene` 写入时机。
- 用几组手工样本覆盖旧存档迁移。

**验收：**
- 战斗中保存后读档，单位位置、HP、行动状态正确。
- 结果页保存后读档，回到结果页而不是战斗。
- 剧情中保存后读档，回到剧情。

### Day 8：把测试从“骨架”补到“能抓回归”

**目标：** 让关键逻辑至少有最低限度的真实生产代码覆盖。

**主要文件：**
- `D:/godot/fegame/test/test_runner.gd`
- `D:/godot/fegame/test/test_pathfinding_service.gd`
- `D:/godot/fegame/test/test_save_load_flow.gd`
- `D:/godot/fegame/test/test_game_state_flow.gd`
- `D:/godot/fegame/test/test_turn_resolution.gd`

**工作项：**
- 把手写公式测试尽量替换为真实类调用。
- 为迁移、恢复路由、AI 移动后攻击增加回归用例。
- 更新 `test_coverage_matrix.md`。

**验收：**
- 新增测试至少能覆盖：
  - 存档迁移
  - 结果页恢复
  - AI 移动后攻击
  - 回合结算状态变化

### Day 9：做一轮真实场景回归与缺陷回收

**目标：** 用 Godot 场景实际走流程，把静态看不出来的问题打掉。

**主要文件：**
- 以修复为主，不预设单一文件
- 同步更新 `D:/godot/fegame/docs/review/`

**工作项：**
- 走 3 条主路径：
  - 新游戏 -> 剧情 -> 战斗 -> 结果页
  - 战斗中保存 -> 读档 -> 继续战斗
  - 结果页保存 -> 读档 -> 承接后续流程
- 记录问题清单并当天回收高优先级问题。

**验收：**
- 三条主路径都能跑通。
- P1/P2 不留到 Day 10。

### Day 10：交付整理、演示清单和 handoff 文档

**目标：** 把代码、测试、验收、遗留风险整理成可交接包。

**主要文件：**
- `D:/godot/fegame/docs/review/`
- `D:/godot/fegame/docs/architecture/test_coverage_matrix.md`
- `D:/godot/fegame/RUNNING.md`

**工作项：**
- 写最终验收清单。
- 写已知遗留问题和建议后续路线。
- 如果有 CLI 环境，跑最终测试；没有就至少附手工验收结果。

**验收：**
- 有一份非开发也能照着走的验收清单。
- 有一份开发接手后能直接排期的遗留清单。

## 建议分工

- 玩法/战斗脚本：
  - Day 1-5 为主
- 剧情与流转：
  - Day 6 为主
- 存档与状态恢复：
  - Day 7 为主
- 测试与回归：
  - Day 8-10 为主

## 交付标准

- 主流程至少可完整演示 1 章。
- 战斗、剧情、结果页三种场景都可从存档恢复。
- 至少有 2 类主动技能效果。
- 至少有 2 类地图胜负条件。
- 有可执行的测试/验收文档，而不是只有代码改动。

## 风险提示

- 当前环境没有稳定的 Godot CLI 时，测试质量会高度依赖人工回归。
- `GameState` 已承载较多运行时职责，继续扩展时要警惕“万能状态桶”失控。
- 如果中途临时新增第二章完整内容，10 天计划会被明显稀释；建议先守住单章质量。
