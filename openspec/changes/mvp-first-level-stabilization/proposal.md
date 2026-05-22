## Why

当前项目虽然核心战斗逻辑已有初步实现，但主流程存在多处空白页、状态跳转不一致、战斗回合未闭环、UI 耦合严重等问题，无法从"启动 → 主菜单 → 剧情 → 战斗 → 结算 → 返回"完整跑通一局。必须进行系统性稳定化，使 MVP 首关达到可玩、可测试、可扩展的状态。

## What Changes

- 打通 boot → main_menu → story → battle → result 完整主流程链路，消除空壳状态和手动干预
- 定版战斗核心循环：玩家回合操作链、敌方 AI 回合、胜负判定正式接入
- 重构 UI 系统为统一布局基线，明确各面板显隐规则
- 完成首关数据/资源闭环：地图、单位、武器、剧情 JSON 全部可加载且与运行时对应
- 定版存档/读档链路：新游戏、继续游戏、战后保存、版本升级约束
- 固化验证体系：测试覆盖、场景契约、开发检查清单

## Capabilities

### New Capabilities
- `main-flow-integration`: 主流程状态一致性，boot→story→battle→result 链路闭环
- `battle-core-loop`: 玩家/敌方回合完整操作链，胜负判定正式接入
- `ui-system-mvp`: 统一 UI 布局基线（1280x720），主菜单/剧情/战斗HUD/行动菜单显隐规范
- `data-resource-closure`: 首关 JSON 数据全部可加载校验，资源占位与缺失策略
- `save-load-pipeline`: 存档边界定义、字段表、读档恢复流程、版本升级规则
- `verification-constraints`: 测试覆盖矩阵、场景契约、开发/提交检查清单

### Modified Capabilities
<!-- 暂无已有 spec 需要修改 -->

## Impact

- **场景切换**：GameState.phase 与实际场景必须严格对应，消除 phase 残留
- **战斗系统**：UnitActor、TurnManager、BattleController 三者的权责边界需明确裁切
- **UI 层**：所有 UI 面板从"脚本顺便改状态"改为统一通信方式
- **数据层**：JSON schema 需与运行时结构严格对应，禁止临时值兜底
- **存档系统**：存档 schema 需确立版本升级规则，不再靠默认值兜底
