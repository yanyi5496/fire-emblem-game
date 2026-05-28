# Project Ember 5-Day MVP Handoff Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在约 5 个工作日内，把当前仓库从“可运行战斗原型”推进到“可演示的 MVP 主流程”，重点补齐治疗/技能指令、战斗运行时存档、结果流转、回合结算和回归验证。

**Architecture:** 当前项目已经具备 `主菜单 -> 剧情 -> 战斗 -> 结果页` 的主链路，以及基础地形、AI、结果页与最小战斗快照能力。后续 5 天不做大重构，采用“在现有控制器上增量补齐主路径”的策略：优先打通玩家可感知流程，再补运行时状态和回归测试，避免过早扩展内容量。

**Tech Stack:** Godot 4.6、GDScript、JSON 数据驱动、内置场景测试脚本

---

## 交接前提

- 当前关键脚本集中在：
  - `D:/godot/fegame/scripts/battle/battle_controller.gd`
  - `D:/godot/fegame/scripts/battle/combat_manager.gd`
  - `D:/godot/fegame/scripts/battle/turn_manager.gd`
  - `D:/godot/fegame/scripts/battle/ai_controller.gd`
  - `D:/godot/fegame/scripts/autoload/save_manager.gd`
  - `D:/godot/fegame/scripts/autoload/game_state.gd`
  - `D:/godot/fegame/scripts/unit/unit_actor.gd`
  - `D:/godot/fegame/scripts/unit/unit_runtime_state.gd`
- 当前已经存在：
  - 战斗结果页 `D:/godot/fegame/scenes/menu/battle_result_menu.tscn`
  - 最小战斗快照入口 `build_save_snapshot()`
  - 地形命中/防御修正与 AI 真实伤害结算
- 当前仍明显缺失：
  - 玩家治疗/技能操作链路
  - 读档后完整恢复单位运行时状态的实际场景验证
  - 结果页后的章节推进与剧情承接
  - 更完整的回合结算效果
  - 针对新增功能的回归测试矩阵

## 文件责任图

- `D:/godot/fegame/scripts/battle/battle_controller.gd`
  - 战斗主流程、玩家输入、单位生成、目标选择、战斗结束、战斗快照采集
- `D:/godot/fegame/scripts/battle/combat_manager.gd`
  - 命中/伤害/反击/追击计算，后续可扩展技能前后钩子
- `D:/godot/fegame/scripts/battle/turn_manager.gd`
  - 回合推进、Round End 结算、自动保存、持续效果/冷却处理
- `D:/godot/fegame/scripts/unit/unit_actor.gd`
  - 单位实例、受伤/治疗/死亡、运行时存档还原
- `D:/godot/fegame/scripts/unit/unit_runtime_state.gd`
  - 单位运行时属性、技能冷却、运行时状态恢复
- `D:/godot/fegame/scripts/ui/action_menu.gd`
  - 玩家操作菜单，后续需要加入治疗/技能按钮的可见性与信号
- `D:/godot/fegame/scripts/ui/battle_hud.gd`
  - 战斗 UI 容器，后续可能扩展治疗预览/提示
- `D:/godot/fegame/scripts/autoload/save_manager.gd`
  - 存档写入/读取、战斗场景快照合并
- `D:/godot/fegame/scripts/autoload/game_state.gd`
  - 全局状态、战斗快照、战斗结果和章节流转状态
- `D:/godot/fegame/scripts/menu/battle_result_menu.gd`
  - 战后按钮逻辑、下一关/重试/返回主菜单
- `D:/godot/fegame/scripts/story/story_player.gd`
  - 剧情结束和章节承接，后续需要根据章节/地图结果切换下一段剧情
- `D:/godot/fegame/test/*.gd`
  - 静态加载、场景契约、状态流与最小算法测试

---

### Task 1: 玩家治疗与技能指令打通

**目标：** 让 `hero_002` 能在战斗中使用治疗杖/治疗技能完成一次可见、可结算、可结束行动的治疗流程。

**Files:**
- Modify: `D:/godot/fegame/scripts/battle/battle_controller.gd`
- Modify: `D:/godot/fegame/scripts/ui/action_menu.gd`
- Modify: `D:/godot/fegame/scripts/ui/battle_hud.gd`
- Modify: `D:/godot/fegame/scenes/battle/ui/action_menu.tscn`
- Modify: `D:/godot/fegame/scripts/unit/unit_actor.gd`
- Modify: `D:/godot/fegame/scripts/unit/unit_runtime_state.gd`
- Modify: `D:/godot/fegame/scripts/autoload/data_manager.gd`
- Test: `D:/godot/fegame/test/test_scene_contracts.gd`
- Test: `D:/godot/fegame/test/test_scripts_load.gd`

- [ ] **Step 1: 明确治疗的最小规则并补充契约测试**

```gdscript
# 目标行为
# 1. 行动菜单出现“技能”或“治疗”入口
# 2. 仅当单位拥有 active 技能且冷却为 0 时可见
# 3. 友军在 1~2 格内且未满血时可成为治疗目标
# 4. 治疗后目标回血，施术者行动结束，技能进入冷却
```

Run: 在 `D:/godot/fegame/test/test_scene_contracts.gd` 中补对 `ActionMenu`/`BattleHUD` 新方法的存在校验  
Expected: 新方法被列入契约测试

- [ ] **Step 2: 在 `UnitRuntimeState` 中增加技能可用性辅助方法**

```gdscript
func can_use_skill(skill_id: String) -> bool:
	if not skill_cooldowns.has(skill_id):
		return true
	return int(skill_cooldowns.get(skill_id, 0)) <= 0

func trigger_skill_cooldown(skill_id: String) -> void:
	var skill_data: Dictionary = DataManager.get_skill(skill_id)
	skill_cooldowns[skill_id] = int(skill_data.get("cooldown", 0))
```

Run: 无 CLI 时至少执行 `git diff --check`  
Expected: 无格式错误

- [ ] **Step 3: 在 `ActionMenu` 中为技能入口增加显隐和信号**

```gdscript
signal skill_selected()

func show_for_unit(unit) -> void:
	var has_ready_skill := false
	for skill_id in unit.runtime_state.skills:
		var skill_data: Dictionary = DataManager.get_skill(skill_id)
		if skill_data.get("type", "") == "active" and unit.runtime_state.can_use_skill(skill_id):
			has_ready_skill = true
			break
	$VBoxContainer/SkillButton.visible = has_ready_skill
```

Run: 检查 `D:/godot/fegame/scenes/battle/ui/action_menu.tscn` 信号仍正确连接  
Expected: `SkillButton` 可触发 `_on_skill_pressed`

- [ ] **Step 4: 在 `BattleController` 中新增治疗目标选择与执行流程**

```gdscript
enum BattleInteractionState { IDLE, UNIT_SELECTED, MOVING, ACTION_MENU, TARGETING, ATTACK_PREVIEW, HEAL_TARGETING }

func _get_allies_in_skill_range(unit, skill_id: String) -> Array:
	var result: Array = []
	var skill_data: Dictionary = DataManager.get_skill(skill_id)
	var weapon_data: Dictionary = DataManager.get_weapon(unit.runtime_state.equipped_weapon)
	var min_range: int = int(weapon_data.get("min_range", 1))
	var max_range: int = int(weapon_data.get("max_range", 1))
	for tile in pathfinding.get_attack_range(unit.grid_pos, min_range, max_range, tile_map):
		var ally = get_unit_at(tile)
		if ally and ally.team == unit.team and ally.get_current_hp() < ally.get_max_hp():
			result.append(ally)
	return result

func _execute_heal(user, target, skill_id: String) -> void:
	var skill_data: Dictionary = DataManager.get_skill(skill_id)
	var amount: int = int(skill_data.get("effect", {}).get("value", 0))
	target.heal(amount)
	user.runtime_state.trigger_skill_cooldown(skill_id)
	user.wait()
```

Run: 手动检查取消键、目标高亮和待机状态是否有明确分支  
Expected: 治疗与攻击流程互不覆盖

- [ ] **Step 5: 为治疗目标与执行结果提供最小 UI 反馈**

```gdscript
func show_status_message(text: String) -> void:
	turn_label.text = text
```

```gdscript
# 示例
battle_hud.show_status_message("%s 为 %s 恢复了 %d HP" % [user.unit_id, target.unit_id, amount])
```

Run: 复查 `battle_hud.gd` 是否只增量扩展，不破坏现有保存提示  
Expected: 文案复用 `TurnLabel` 即可，不引入额外复杂 UI

- [ ] **Step 6: 更新静态测试清单**

```gdscript
# test_scene_contracts.gd
var am_check := _check_class("ActionMenu", ["show_for_unit", "_on_move_pressed", "_on_attack_pressed", "_on_skill_pressed", "_on_wait_pressed"])
```

Run: `git diff --check`  
Expected: 通过

- [ ] **Step 7: Commit**

```bash
git add scripts/battle/battle_controller.gd scripts/ui/action_menu.gd scripts/ui/battle_hud.gd scenes/battle/ui/action_menu.tscn scripts/unit/unit_actor.gd scripts/unit/unit_runtime_state.gd test/test_scene_contracts.gd test/test_scripts_load.gd
git commit -m "feat: add basic heal skill flow"
```

---

### Task 2: 战斗存档恢复补齐到可继续游戏水平

**目标：** 确保存档不仅写入快照，还能在“继续游戏/读档后进入战斗”时恢复单位运行态、地图回合和战斗结果相关状态。

**Files:**
- Modify: `D:/godot/fegame/scripts/autoload/save_manager.gd`
- Modify: `D:/godot/fegame/scripts/autoload/game_state.gd`
- Modify: `D:/godot/fegame/scripts/battle/battle_controller.gd`
- Modify: `D:/godot/fegame/scripts/menu/main_menu.gd`
- Modify: `D:/godot/fegame/scripts/menu/save_load_menu.gd`
- Modify: `D:/godot/fegame/test/test_game_state_flow.gd`
- Test: `D:/godot/fegame/test/test_scene_contracts.gd`

- [ ] **Step 1: 扩展存档验证字段，显式接受战斗快照**

```gdscript
const REQUIRED_SAVE_FIELDS := [
	"version",
	"timestamp",
	"chapter",
	"map_id",
	"turn",
	"gold",
	"inventory",
	"story_flags",
	"completed_maps",
	"settings",
	"units",
	"map_state",
]
```

Run: 更新 `test_game_state_flow.gd` 的合法存档样本  
Expected: 新字段通过校验

- [ ] **Step 2: 保证 `load_game()` 后能根据 `map_state` 进入正确场景**

```gdscript
func _route_after_load() -> void:
	if not GameState.current_map_id.is_empty():
		SceneRouter.goto("battle")
	else:
		SceneRouter.goto("main_menu")
```

Run: 检查 `main_menu.gd` 与 `save_load_menu.gd` 是否复用同一路由逻辑  
Expected: “继续游戏”和“读档”行为一致

- [ ] **Step 3: 在 `BattleController.start_battle()` 中统一恢复快照后的光标、TileInfo 和回合 UI**

```gdscript
func start_battle(map_id: String) -> void:
	# 现有初始化后补：
	cursor.position = Vector2.ZERO
	_update_tile_info(Vector2i.ZERO)
	if battle_hud:
		battle_hud.update_turn_info("player", turn_manager.turn_number)
```

Run: 确认快照恢复不会重复生成单位  
Expected: `_battle_started_once` 与 `_get_spawn_unit_data()` 逻辑保持一致

- [ ] **Step 4: 强化 `test_game_state_flow.gd`，校验 battle snapshot 往返**

```gdscript
GameState.battle_units = [{"unit_id": "hero_001", "x": 1, "y": 1, "current_hp": 18, "action_state": 2}]
var save_data := GameState.to_dict()
GameState.reset()
GameState.from_dict(save_data)
assert(GameState.battle_units.size() == 1)
assert(GameState.battle_units[0].get("current_hp", 0) == 18)
```

Run: `git diff --check`  
Expected: 通过

- [ ] **Step 5: Commit**

```bash
git add scripts/autoload/save_manager.gd scripts/autoload/game_state.gd scripts/battle/battle_controller.gd scripts/menu/main_menu.gd scripts/menu/save_load_menu.gd test/test_game_state_flow.gd
git commit -m "feat: restore battle runtime state from saves"
```

---

### Task 3: 结果页后的章节推进与剧情承接

**目标：** 让战斗结果页不只是“显示结果”，而是能基于章节/地图推进后续剧情或结束当前章节。

**Files:**
- Modify: `D:/godot/fegame/scripts/menu/battle_result_menu.gd`
- Modify: `D:/godot/fegame/scripts/story/story_player.gd`
- Modify: `D:/godot/fegame/scripts/autoload/game_state.gd`
- Modify: `D:/godot/fegame/data/stories/mvp_story_01.txt`
- Create: `D:/godot/fegame/data/stories/mvp_story_02.txt`
- Modify: `D:/godot/fegame/test/test_scene_contracts.gd`

- [ ] **Step 1: 定义最小章节推进表**

```gdscript
const CHAPTER_FLOW := {
	"chapter_01": {
		"map_id": "mvp_map_01",
		"post_battle_story": "",
		"next_chapter": "",
	}
}
```

Run: 将表定义放在 `battle_result_menu.gd` 或单独 helper 中，但先不做大拆分  
Expected: 单表即可覆盖当前 MVP

- [ ] **Step 2: 胜利后优先进入战后剧情，其次回主菜单**

```gdscript
func _on_primary_pressed() -> void:
	var flow: Dictionary = CHAPTER_FLOW.get(GameState.current_chapter, {})
	var post_story := str(flow.get("post_battle_story", ""))
	if GameState.latest_battle_result == "victory" and post_story != "":
		GameState.story_flags["post_battle_pending"] = true
		SceneRouter.goto("story")
		return
```

Run: 复查 `GameState.current_chapter` 是否在新游戏时已经赋值  
Expected: `chapter_01` 路径可直接使用

- [ ] **Step 3: 在 `StoryPlayer` 中支持根据标记切换后续剧本**

```gdscript
const STORY_BY_FLAG := {
	"chapter_01_post_battle": "res://data/stories/mvp_story_02.txt",
}

func _ready() -> void:
	if GameState.story_flags.get("chapter_01_post_battle_pending", false):
		GameState.story_flags.erase("chapter_01_post_battle_pending")
		call_deferred("play_story", STORY_BY_FLAG["chapter_01_post_battle"])
		return
```

Run: 确认不影响现有默认开场剧本  
Expected: 新游戏仍从 `mvp_story_01.txt` 开始

- [ ] **Step 4: 提供一段最小战后剧情文本**

```text
[Narrator]
山道一战结束，队伍暂时稳住了阵脚。

[Character: 艾克]
先整队，我们继续前进。

[Event: chapter_clear]
```

Run: 保存到 `D:/godot/fegame/data/stories/mvp_story_02.txt`  
Expected: 可被 `StoryPlayer` 直接读取

- [ ] **Step 5: 在结果页胜利收尾时同步章节状态**

```gdscript
if GameState.latest_battle_result == "victory":
	GameState.story_flags["%s_post_battle_pending" % GameState.current_chapter] = true
```

Run: 检查命名与 `StoryPlayer` 读取逻辑一致  
Expected: 标记名完全一致

- [ ] **Step 6: Commit**

```bash
git add scripts/menu/battle_result_menu.gd scripts/story/story_player.gd scripts/autoload/game_state.gd data/stories/mvp_story_01.txt data/stories/mvp_story_02.txt test/test_scene_contracts.gd
git commit -m "feat: add post-battle chapter flow"
```

---

### Task 4: 回合结算扩展到“异常 + 冷却 + 被动治疗”最小闭环

**目标：** 把当前已经存在的 Round End 占位逻辑扩展到可以支撑异常状态演示和主动技能冷却循环。

**Files:**
- Modify: `D:/godot/fegame/scripts/battle/turn_manager.gd`
- Modify: `D:/godot/fegame/scripts/unit/status_effect_service.gd`
- Modify: `D:/godot/fegame/scripts/unit/unit_runtime_state.gd`
- Modify: `D:/godot/fegame/data/skills/heal_light.json`
- Create: `D:/godot/fegame/test/test_turn_resolution.gd`
- Modify: `D:/godot/fegame/test/test_runner.gd`
- Modify: `D:/godot/fegame/test/test_scripts_load.gd`

- [ ] **Step 1: 给 `heal_light` 的冷却加入可验证路径**

```json
{
  "id": "heal_light",
  "type": "active",
  "cooldown": 1
}
```

Run: 确认数据文件维持现有结构  
Expected: 不新增 schema 字段

- [ ] **Step 2: 将回合结算顺序固定为“毒伤 -> 状态递减 -> 自动回复 -> 冷却递减”**

```gdscript
func _execute_round_end() -> void:
	_process_poison_damage()
	_process_debuff_ticks()
	_process_auto_heal()
	_process_skill_cooldowns()
```

Run: 检查不要重复调用 `tick_all()` 两次  
Expected: 每个状态每回合只递减 1

- [ ] **Step 3: 在 `StatusEffectService` 里提供独立的 tick 和效果应用接口**

```gdscript
func tick_effect_durations(unit) -> void:
	var updated: Array[Dictionary] = []
	for effect in unit.runtime_state.status_effects:
		var dur := int(effect.get("duration", 1)) - 1
		if dur > 0:
			effect["duration"] = dur
			updated.append(effect)
	unit.runtime_state.status_effects = updated
```

Run: `TurnManager` 改为按单位调用，而不是大而化之地批处理  
Expected: 毒伤和递减分离

- [ ] **Step 4: 新增一个回合结算测试脚本**

```gdscript
func run() -> Dictionary:
	var details: Array[String] = []
	var runtime = preload("res://scripts/unit/unit_runtime_state.gd").new()
	runtime.max_hp = 20
	runtime.current_hp = 20
	runtime.status_effects = [{"id": "poison", "duration": 2}]
	runtime.skill_cooldowns = {"heal_light": 1}
	# 断言毒伤后 HP 下降，tick 后 duration 递减，cooldown 归零
```

Run: 将新测试接入 `test_runner.gd` 与 `test_scripts_load.gd`  
Expected: 测试脚本能被加载

- [ ] **Step 5: Commit**

```bash
git add scripts/battle/turn_manager.gd scripts/unit/status_effect_service.gd scripts/unit/unit_runtime_state.gd data/skills/heal_light.json test/test_turn_resolution.gd test/test_runner.gd test/test_scripts_load.gd
git commit -m "feat: expand round-end resolution loop"
```

---

### Task 5: 5 天收尾回归与交付清单

**目标：** 对前 4 个任务做统一回归、文档补齐和演示清单整理，确保其他人交付后你能快速验收。

**Files:**
- Modify: `D:/godot/fegame/docs/architecture/test_coverage_matrix.md`
- Create: `D:/godot/fegame/docs/review/2026-05-30-mvp-handoff-checklist.md`
- Modify: `D:/godot/fegame/test/test_scene_contracts.gd`
- Modify: `D:/godot/fegame/test/test_scenes_load.gd`
- Modify: `D:/godot/fegame/test/test_runner.gd`

- [ ] **Step 1: 更新测试覆盖矩阵**

```markdown
| 回合结算 | test_turn_resolution.gd | 毒伤、持续时间、技能冷却 | ✓ |
| 战斗寻路 | test_pathfinding_service.gd | same-position / open-field path | ✓ |
| 结果流转 | scene/script contract | 结果页脚本与场景存在 | ✓ |
```

Run: 手动检查矩阵与真实测试文件一致  
Expected: 无失配

- [ ] **Step 2: 写一份可交付验收清单**

```markdown
# MVP 交接验收清单

- 新游戏进入开场剧情
- 剧情切入战斗
- 玩家可攻击
- 敌军会移动并攻击
- 可手动保存
- 回合结束自动保存
- 读档恢复单位位置与 HP
- 结果页可重试/返回
- 治疗技能可执行并进入冷却
```

Run: 保存为 `D:/godot/fegame/docs/review/2026-05-30-mvp-handoff-checklist.md`  
Expected: 供非开发同学按清单验收

- [ ] **Step 3: 做最终静态核对**

```bash
git diff --check
```

Expected: 无输出

- [ ] **Step 4: 若本机可用 Godot CLI，则执行测试 Runner**

```bash
godot4 --headless --path D:/godot/fegame --scene res://test/test_runner.tscn --quit
```

Expected: `Project Ember - MVP Test Suite` 输出中不出现 `FAILED to load`

- [ ] **Step 5: Commit**

```bash
git add docs/architecture/test_coverage_matrix.md docs/review/2026-05-30-mvp-handoff-checklist.md test/test_scene_contracts.gd test/test_scenes_load.gd test/test_runner.gd
git commit -m "docs: finalize 5-day mvp handoff checklist"
```

---

## 5 天建议排期

### Day 1

- 完成 Task 1
- 目标产出：玩家治疗/技能指令可跑通

### Day 2

- 完成 Task 2
- 目标产出：继续游戏/读档恢复最小战斗运行态

### Day 3

- 完成 Task 3
- 目标产出：战后结果页可承接剧情或章节完成

### Day 4

- 完成 Task 4
- 目标产出：Round End 具备毒伤、状态递减、冷却循环

### Day 5

- 完成 Task 5
- 目标产出：回归、交付文档、最终验收清单

---

## 验收标准

- 战斗内至少有 1 个可用主动技能，并能产生真实效果
- `SaveManager` 存档包含战斗单位快照，读档后恢复位置、HP、行动状态
- 结果页不会直接把玩家丢回主菜单，而是提供可解释的后续路径
- Round End 会真实改变至少 3 类运行时状态：
  - 毒伤
  - 状态持续时间
  - 技能冷却
- 测试清单覆盖新增场景、脚本和关键状态流

## 风险与注意事项

- 当前环境未必有 Godot CLI，执行者需要优先确认本机测试方式。
- 不要在这 5 天里引入大规模架构重构；现阶段目标是交付可演示主流程，不是打造长期最优结构。
- `GameState` 已逐渐承担运行时存档职责，继续扩展时要避免和 `SaveManager` 职责重叠。
- 如果执行者想做“真正的下一关”，需要先补数据与剧本；本计划默认只保证单章 MVP 路径完整。

## 自检结论

- 计划覆盖了当前 review 后剩余最关键的 5 个可分派子系统。
- 每个任务都给出了明确文件、实施顺序、最低代码骨架和验收方式。
- 没有故意留 `TODO/TBD` 占位；个别“若本机可用 Godot CLI”步骤已明确标出为环境依赖。
