# Project Ember 下一阶段 10 天推进计划

> 基于 2026-05-25 当前工作区状态制定。该计划默认此前 5 天交接计划已完成基础链路搭建，且当前未提交改动中的 `BattleSkillService`、`BattleLifecycleService`、存档快照透传与测试补充会继续保留并收口。

## 1. 本轮目标

用下一个 10 个工作日，把项目从“单章 MVP 主流程已基本串起、但仍偏工程中间态”推进到“可稳定演示、可交接协作者并继续扩展的第一里程碑版本”。

本轮不追求大规模内容扩张，优先解决以下问题：

- 已抽出的战斗服务需要真正落稳，避免控制器继续回涨。
- 技能、AI、回合结算、存档恢复需要从“能跑”提升到“可信”。
- 章节流转、地图胜败条件、结果页承接需要从脚本分支提升到最小数据驱动。
- 测试、回归、验收文档需要和当前实现同步，不再停留在设计态。

## 2. 当前基线

### 2.1 已推进到的内容

- 主流程已具备：`主菜单 -> 剧情 -> 战斗 -> 结果页`
- 战斗技能逻辑已开始从 `battle_controller.gd` 中抽出到：
  - `scripts/battle/battle_skill_service.gd`
  - `scripts/battle/battle_lifecycle_service.gd`
- 存档写入已支持显式透传运行时快照，不再强依赖当前场景即时采集。
- AI 治疗逻辑已开始复用技能服务。
- 测试已补入：
  - `test/test_battle_skill_service.gd`
  - `test/test_save_load_flow.gd` 中的快照合并覆盖

### 2.2 当前主要缺口

- 技能服务虽然已抽出，但缺少更完整的效果类型、失败反馈与回归覆盖。
- `BattleController` 仍承担过多流程编排职责，状态切换风险依然高。
- 地图目标、章节推进、结果页承接仍偏硬编码，内容化能力不够。
- 存档恢复还需要场景级验证，尤其是“继续游戏”和“结果页恢复”。
- 回合结算与状态效果仍需要补完整规则闭环。
- 验收文档存在，但还未形成“代码-测试-场景”一致收口。

## 3. 本轮策略

- 先收口服务边界，再补玩法深度。
- 先稳单章体验，再考虑扩第二张图或更多内容。
- 每 2 天形成一次可回归节点，避免 Day 9/10 集中爆雷。
- 所有新增能力都要带上对应测试或手工验收项。
- 每新增一个测试文件，同步更新 `docs/architecture/test_coverage_matrix.md`。

## 4. 10 天详细排期

> **PRD 偏差修正说明：** 经对照 `docs/prd/TOP_PRD.md` 逐条审核，当前代码存在以下 PRD 偏差，已分配到对应 Day 中修正：
> - 战斗前/后被动技能未接入战斗流程（PRD §8.1/§9.3）→ Day 1
> - 武器耐久度运行时消耗缺失（PRD §7）→ Day 2
> - 高度差命中修正使用原始高度差而非 ±10（PRD §8.3）→ Day 4
> - 剧情结束自动存档缺失（PRD §14.2）→ Day 8
> - 成长系统未实现（PRD §5.3）→ 确认不在本轮范围（属 PRD §3.1 第三阶段），在 §7 风险中标记为遗留

### Day 1：收口技能服务，补齐当前抽离后的缺口

**目标：** 让 `BattleSkillService` 成为技能执行唯一入口，控制器只保留编排职责。

**重点文件：**

- `D:/godot/fegame/scripts/battle/battle_skill_service.gd`
- `D:/godot/fegame/scripts/battle/battle_controller.gd`
- `D:/godot/fegame/test/test_battle_skill_service.gd`

**工作项：**

- 统一技能可用性、目标筛选、执行结果结构。
- 明确失败返回：无目标、目标不合法、冷却中、效果类型缺失。
- 检查 `self / ally / enemy` 三类目标分流是否都通过同一入口。
- 把控制器里残余的技能细节判断继续下沉。
- 将**被动技能触发**（PRD §9.3: `before_combat` / `after_combat` / `on_hit` / `on_kill` / `on_death`）接入 `CombatManager` 战斗流程，使 `sword_adept`、`tough_body` 等被动技能在正确时机生效。
- 新增 `test_battle_skill_service.gd` 测试：自 Buff 执行、非法目标（team 阵营冲突、HP 满时治疗）返回 false。

**验收：**

- 控制器中不再出现重复的技能效果判断分支。
- 技能执行结果统一返回 `success/action/message`。
- `test_battle_skill_service.gd` 覆盖治疗、伤害、自 Buff、非法目标 **四类** 情况（当前缺自 Buff 和非法目标，需补齐）。

### Day 2：补完整主动技能最小谱系

**目标：** 技能不再只有治疗可演示，至少形成“治疗 + 主动伤害 + 自身增益”三类闭环。

**重点文件：**

- `D:/godot/fegame/data/skills/*.json`
- `D:/godot/fegame/scripts/battle/battle_skill_service.gd`
- `D:/godot/fegame/scripts/ui/battle_hud.gd`

**工作项：**

- 补 1 个可实战使用的主动伤害技能（`flame_burst` 已存在，核实可正常结算）。
- 补 1 个 **主动型** 自 Buff 技能 JSON（非 `sword_adept`/`tough_body` 那种被动触发，需战场上按需释放、持续回合后回退属性）。
- 核实 `BattleSkillService._execute_stat_bonus` 对主动自 Buff 的冷启动/回退逻辑正常。
- 为不同技能效果提供最小 UI 提示文案。
- **补武器耐久度运行时消耗**（PRD §7）：数据层已存在 `durability` 字段，补运行时消耗逻辑（攻击/治疗后耐久 -1），归零时禁止使用；写入战斗快照用于存档恢复。
- 校验技能范围与武器范围分离逻辑（`get_skill_range` 已实现在 `BattleSkillService`，确认数据生效）。

**验收：**

- 三类技能（治疗/主动伤害/主动自 Buff）都能在战斗里实际释放并结算。
- 主动自 Buff 在持续回合后属性正确回退。
- 技能范围读取优先来自技能数据，而非默认武器射程。

### Day 3：把生命周期服务做成统一存档/结束入口

**目标：** `BattleLifecycleService` 负责战斗快照、手动保存、回合检查点、结算落盘，减少流程分散。

**重点文件：**

- `D:/godot/fegame/scripts/battle/battle_lifecycle_service.gd`
- `D:/godot/fegame/scripts/battle/battle_controller.gd`
- `D:/godot/fegame/scripts/battle/turn_manager.gd`
- `D:/godot/fegame/scripts/autoload/save_manager.gd`
- `D:/godot/fegame/test/test_battle_lifecycle_service.gd`

**工作项：**

- 统一 `build_snapshot / save_checkpoint / finalize_battle` 的字段契约。
- 检查 `checkpoint_requested` 信号链是否覆盖所有回合结算路径。
- 明确 `resume_scene`、`latest_battle_result`、`completed_maps` 的写入时机。
- 为结果页保存与恢复补场景级手工验证清单。
- 新增 `test_battle_lifecycle_service.gd`：测试 `build_snapshot` 包含单位和回合、`finalize_battle` 写入 `GameState` 结果字段。

**验收：**

- 手动保存与回合结束自动保存都走生命周期服务。
- 战斗结束后结果页恢复字段完整，不依赖额外脚本补丁。
- `test_battle_lifecycle_service.gd` 覆盖快照构建与结果收口。

### Day 4：把地图胜负条件提升到最小数据驱动

**目标：** 不再只靠`rout`一种规则，至少验证两类地图条件在实战中生效。

**基线：** `VictoryJudge` 已支持 `rout / defend / survive` 三种胜利条件、`all_dead / lord_dead / turn_limit` 三种失败条件，`mvp_map_01.json` 已有 `victory_condition / defeat_condition / max_turns` 字段。本轮 Day 4 的重点是从"代码已支持"推向"有真实地图数据验证"。

**重点文件：**

- `D:/godot/fegame/data/maps/*.json`
- `D:/godot/fegame/scripts/battle/victory_judge.gd`
- `D:/godot/fegame/scripts/battle/battle_controller.gd`
- `D:/godot/fegame/scripts/menu/battle_result_menu.gd`
- `D:/godot/fegame/test/test_victory_judge_integration.gd`

**工作项：**

- 新增第二张地图 JSON（如 `mvp_map_02_defend.json`），使用 `survive` 胜利条件 + `turn_limit` 失败条件，使两类条件有别于第一章。
- 新增 `test_victory_judge_integration.gd`：用 `VictoryJudge` 同时验证两张地图条件。
- **修正高度差命中公式**（PRD §8.3）：`combat_manager.gd` 当前使用原始高度差（0/1/2），PRD 要求固定 ±10；修复后地形 height 差异直接转换为命中 ±10/±0，而非当前微弱的 ±1/±2。
- 结果页根据胜负原因显示更明确文案（区分"全灭"/"超回合"/"首领击破"）。
- 验证 `max_turns` 超限判定不会与 `rout` 胜利条件互相覆盖。

**验收：**

- 至少两类地图条件（`rout + survive`）可以在数据中切换并生效。
- 超回合数判定独立工作，不因敌方全灭而跳过。

### Day 5：章节承接和结果页流转做内容化收口

**目标：** 结果页不只是"结束页面"，而是章节推进路由节点。

**基线：** `BattleResultMenu.gd` 已有 `CHAPTER_FLOW` 常量（含 `post_battle_story` / `next_chapter` 字段），`StoryPlayer` 已有战后剧情标记（`chapter_01_post_battle_pending`）和 `STORY_BY_FLAG` 路由。但战后故事播完后 `story_finished` 信号 **无人监听** → 章节推进断裂。

**重点文件：**

- `D:/godot/fegame/scripts/menu/battle_result_menu.gd`
- `D:/godot/fegame/scripts/story/story_player.gd`
- `D:/godot/fegame/scripts/autoload/game_state.gd`
- `D:/godot/fegame/data/stories/*.txt`

**工作项：**

- 补全 `story_finished` 信号监听（`GameState` 或 `SceneRouter` 级联），战后故事结束后自动推进到下一章或回主菜单。
- 打通战后剧情标记 → 剧情播放 → 章节完成收尾全链路。
- 明确胜利、失败、重试、返回主菜单四种收尾路径的存档恢复行为。
- 新增 `test_chapter_flow.gd`：模拟 battle_result = victory → `record_battle_result` → `story_flags` 设置 → `resume_scene` 验证。

**验收：**

- 胜利后能进入战后剧情或下一步承接（`story_finished` 信号被消费）。
- 失败后重试和返回主菜单行为一致且可解释。
- 相关标记存档后可恢复。

### Day 6：回合结算补到可持续扩展的最小闭环

**目标：** 回合结束真正驱动状态变化，不再只是占位流程。

**重点文件：**

- `D:/godot/fegame/scripts/battle/turn_manager.gd`
- `D:/godot/fegame/scripts/unit/status_effect_service.gd`
- `D:/godot/fegame/scripts/unit/unit_runtime_state.gd`
- `D:/godot/fegame/test/test_turn_resolution.gd`

**基线：** `test_turn_resolution.gd` 已存在（测试毒伤/递减/冷却），`StatusEffectService` 已有 `poison` 伤害、`sleep/paralysis` 控制替换、`stat_buff` 到期回退。但 `silence` 仅有枚举无行为（`_is_control_type` 不含 `silence`），且无 `silence` 的 unit test。

**工作项：**

- 固定结算顺序：毒伤 -> 持续时间递减 -> 自动恢复 -> 技能冷却。
- 为 `silence` 补全行为：`_is_control_type` 包含它，`can_use_skill` 检查 `silence` 状态。
- 补全 `paralysis` 最小行为（已有 `_is_control_type` 和 `_replace_control_effect`，需确认生效），确认 `sleep/paralysis/silence` 三者逻辑一致。
- 检查 Buff 到期后的属性回退策略（`_revert_expired_buff` 已实现，验证生效）。
- 扩展 `test_turn_resolution.gd`：增加 `silence` 单元测试（标记后 `can_use_skill` 返回 false）。

**验收：**

- 中毒会扣血。
- `silence` 会限制技能使用（与 `sleep/paralysis` 一样可标记、可移除）。
- Buff/DeBuff 的持续时间与冷却递减不串线。

### Day 7：AI 从“能出手”提升到“选择更合理”

**目标：** 敌方单位在攻击、治疗、技能使用之间做出基础优先级判断。

**重点文件：**

- `D:/godot/fegame/scripts/battle/ai_controller.gd`
- `D:/godot/fegame/scripts/battle/battle_skill_service.gd`
- `D:/godot/fegame/scripts/battle/combat_manager.gd`
- `D:/godot/fegame/test/test_ai_behavior.gd`

**工作项：**

- 落地优先级：击杀 > 攻残血 > 攻治疗角色 > 最近威胁。
- AI 治疗逻辑继续和技能服务统一。
- 为 AI 选择目标增加最小测试数据。

**验收：**

- AI 会优先击杀可击杀目标。
- 有治疗需求时会优先治疗低血友军。
- AI 不会明显选择无收益目标。

### Day 8：存档恢复做一轮真实回归

**目标：** 确保读档后不是“能进场景”，而是“能继续玩”。

**重点文件：**

- `D:/godot/fegame/scripts/autoload/save_manager.gd`
- `D:/godot/fegame/scripts/autoload/game_state.gd`
- `D:/godot/fegame/scripts/menu/main_menu.gd`
- `D:/godot/fegame/scripts/menu/save_load_menu.gd`
- `D:/godot/fegame/test/test_save_load_flow.gd`

**工作项：**

- 验证战斗中、结果页、剧情中三类存档恢复。
- **补剧情结束自动存档**（PRD §14.2）：监听 `story_player.story_finished` 信号，触发 `SaveManager.save_game`，补入对应测试。
- 补齐 `action_state`、技能冷却、状态效果、当前章节与结果元数据恢复。
- 若旧存档迁移仍有缺口，当天补齐兼容逻辑。

**验收：**

- 战斗中读档后位置、HP、行动状态正确。
- 结果页读档后不会被错误送回战斗。
- 剧情中读档后不会丢失章节上下文。

### Day 9：做一次完整主流程回归与缺陷回收

**目标：** 用真实路径发现静态测试抓不到的问题。

**重点文件：**

- 以缺陷修复为主，不预设单一文件
- `D:/godot/fegame/docs/review/`
- `D:/godot/fegame/docs/architecture/test_coverage_matrix.md`

**工作项：**

- 走三条主路径（手工）：
  - 新游戏 -> 剧情 -> 战斗 -> 结果页 -> 战后剧情
  - 战斗中保存 -> 读档 -> 完成战斗
  - 结果页保存 -> 读档 -> 返回后续流程
- 新增 `test_main_flow_integration.gd`（自动化）：
  - 模拟 `GameState` phase 链：`TITLE -> STORY -> BATTLE -> BATTLE_RESULT -> TITLE`
  - 验证每个阶段 `resume_scene` / `current_map_id` / 结果字段在转换中不被丢失。
- 记录 P1/P2 问题并当天回收。
- 更新覆盖矩阵与验收清单。

**验收：**

- 三条主路径全部走通。
- 不把高优先级问题留到最后一天。

### Day 10：交付整理、协作发包和后续路线图

**目标：** 把本轮成果整理成可验收、可继续开发的交接包。

**重点文件：**

- `D:/godot/fegame/docs/review/`
- `D:/godot/fegame/docs/architecture/test_coverage_matrix.md`
- `D:/godot/fegame/docs/design/`
- `D:/godot/fegame/RUNNING.md`

**工作项：**

- 更新最终验收清单。
- 输出已知遗留风险与下一轮建议排期。
- 形成可发给协作者的拆任务包：玩法、剧情、资源、测试四条线。

**验收：**

- 非开发同学可以照清单走完一次验证。
- 新接手开发可以直接按文档继续排期。

## 5. 分工建议

- 玩法/战斗线：Day 1-4、Day 6-7
- 流转/存档线：Day 3、Day 5、Day 8
- 测试/验收线：Day 8-10
- 协作发包与文档线：Day 9-10

## 6. 本轮完成标准

- 技能系统至少稳定支持三类主动效果：
  - 治疗
  - 主动伤害
  - 自身增益
- 地图至少支持两类真实胜负条件。
- 战斗、剧情、结果页三类场景都能从存档恢复。
- 回合结算真实驱动异常、持续时间和冷却变化。
- AI 的攻击与治疗选择符合最小优先级规则。
- 测试、手工验收、文档三者一致，不出现“文档写了但代码没落”的情况。

## 7. 风险提示

- 当前环境下 Godot 场景级自动回归能力有限，仍需保留手工流程验证。
- `BattleController` 虽已开始瘦身，但仍是主风险点；本轮必须避免把新逻辑重新堆回去。
- 如果中途突然追加第二章完整内容，本计划会被明显稀释，建议先守住单章质量。
- **`DataManager` 冷启动风险**：`get_skill` / `get_weapon` 在 JSON 未加载时返回空字典，建议 Day 1-2 补入防御校验。
- **成长系统本轮不涉及**（PRD §5.3）：数据层已具备成长率，但升级/等级提升属第三阶段开发范围，本轮不安排实现，在 §6 完成标准中同步标记为已知遗留。
- **Headless 限制**：`unit.tscn` 含视觉节点，`--headless` 下可能 `SCRIPT ERROR`，测试尽量 mock 避免场景依赖。
- Buff/DeBuff 若继续扩类型，后续可能需要从“直接改属性”转为“动态汇总属性”，本轮先不提前大改。

## 8. 与旧计划的关系

- `2026-05-25-5day-mvp-handoff-plan.md`：偏“把 MVP 主路径搭起来”
- `2026-05-25-10day-next-plan.md`：偏“从评审视角补齐关键闭环”
- 本文档：偏“基于当前已抽服务与未提交改动，继续向稳定交付推进”

如果需要继续派发给协作者，建议以后续本文档为主，旧两份计划作为背景参考，不再并列执行。
