# 测试覆盖矩阵

| 系统 | 测试文件 | 覆盖内容 | 状态 |
|------|----------|----------|------|
| 数据 Schema | test_data_schema.gd | 所有 JSON 文件字段验证、交叉引用检查 | ✓ |
| 游戏状态流 | test_game_state_flow.gd | GameState.to_dict/from_dict、存档版本校验、重置 | ✓ |
| 脚本加载 | test_scripts_load.gd | 所有 .gd 脚本无编译错误 | ✓ |
| 资源加载 | test_resources_load.gd | 资源文件存在且大小合规 | ✓ |
| 战斗公式 | test_combat_formula.gd | 物理伤害、命中率、地形回避、技能加成、追击 | ✓ |
| 场景加载 | test_scenes_load.gd | 所有 .tscn 文件加载正常 | ✓ |
| 场景契约 | test_scene_contracts.gd | 各场景类和关键方法存在 | ✓ |

## 待补充

- 主流程集成测试（自动检测 phase 转换链路）
- 战斗 AI 决策验证
- UI 可见性验收
