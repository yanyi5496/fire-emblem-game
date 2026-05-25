# 测试覆盖矩阵

| 系统 | 测试文件 | 覆盖内容 | 状态 |
|------|----------|----------|------|
| 数据 Schema | test_data_schema.gd | 所有 JSON 文件字段验证、交叉引用检查 | ✓ |
| 游戏状态流 | test_game_state_flow.gd | GameState.to_dict/from_dict、存档版本校验、重置、战斗快照往返 | ✓ |
| 脚本加载 | test_scripts_load.gd | 所有 .gd 脚本无编译错误 | ✓ |
| 资源加载 | test_resources_load.gd | 资源文件存在且大小合规 | ✓ |
| 战斗公式 | test_combat_formula.gd | 物理伤害、命中率、地形回避、技能加成、追击 | ✓ |
| 场景加载 | test_scenes_load.gd | 所有 .tscn 文件加载正常 | ✓ |
| 场景契约 | test_scene_contracts.gd | 各场景类和关键方法存在（含技能/治疗入口） | ✓ |
| 回合结算 | test_turn_resolution.gd | 毒伤、持续时间递减、技能冷却 | ✓ |
| 战斗寻路 | test_pathfinding_service.gd | same-position / open-field path | ✓ |
| 状态效果服务 | test_status_effects.gd | add_effect、tick_effect_durations、到期移除、毒伤计算 | ✓ |
| 单位运行时状态 | test_unit_runtime.gd | get_stats、can_use_skill、trigger_skill_cooldown、apply_saved_state | ✓ |
| 剧情解析 | test_story_parser.gd | 叙述/角色/对话/BGM/事件 标签解析、空输入 | ✓ |
| 存档读写流程 | test_save_load_flow.gd | 版本校验、字段验证、旧版迁移、to_dict/from_dict 往返、布尔标记 | ✓ |
| AI 战斗行为 | test_ai_behavior.gd | 物理/魔法伤害计算、命中率、追击检测、武器三角 | ✓ |
| 技能服务 | test_battle_skill_service.gd | 治疗/伤害/自 Buff 执行、非法目标拒绝 | ✓ |
| 战斗生命周期 | test_battle_lifecycle_service.gd | 快照构建、战斗结果收口、completed_maps 与标记写入 | ✓ |
| 胜负条件集成 | test_victory_judge_integration.gd | rout/survive/defend 三种胜利条件验证、max_turns 边界 | ✓ |
| 章节流转 | test_chapter_flow.gd | battle_result → 标记写入 → resume_scene 路由 → to_dict/from_dict 持久化 | ✓ |
| 主流程集成 | test_main_flow_integration.gd | TITLE→STORY→BATTLE→BATTLE_RESULT→TITLE phase 链字段不丢失、roundtrip | ✓ |

## 待补充

- UI 可见性验收
- 技能系统被动触发集成验证
