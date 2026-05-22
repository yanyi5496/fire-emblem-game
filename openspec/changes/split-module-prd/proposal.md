## Why

当前 `Godot_SRPG_PRD.md` 是一个单一文档，涵盖了项目所有模块。随着开发推进，单一 PRD 文档变得难以维护、查阅和更新。需要将其拆分为按模块独立的详细 PRD 文档，使每个模块有独立的规格说明，便于团队并行开发和后续迭代。

## What Changes

- 将主 PRD 按模块拆分为独立的详细 PRD 文档，每个文档深挖该模块的细节（数据结构、交互流程、边界条件等）
- 每个模块 PRD 保持自包含，可独立查阅
- 主 PRD 保留作为顶层概览，模块 PRD 作为其详细展开
- 严格遵循主 PRD 已有内容，不引入新功能或偏离现有设计

## Capabilities

### New Capabilities
- `map-system`: 地图系统详细 PRD — TileMap 属性、地形类型、地图功能（阻挡/传送/事件点等）
- `unit-system`: 单位系统详细 PRD — 属性定义、状态机、成长率、升级逻辑
- `job-system`: 职业系统详细 PRD — 职业分类、属性定义、转职树、地形适应
- `weapon-system`: 武器系统详细 PRD — 武器类型、属性、克制关系、耐久度
- `combat-system`: 战斗系统详细 PRD — 战斗流程、伤害/命中/暴击公式、反击/连击
- `skill-system`: 技能系统详细 PRD — 技能类型、数据结构、触发时机、效果系统
- `ai-system`: AI 系统详细 PRD — AI 类型、行为优先级、寻路逻辑、评估函数
- `turn-system`: 回合系统详细 PRD — 阶段切换、结算流程、状态 Tick
- `ui-system`: UI 系统详细 PRD — 主菜单、战斗 UI、HUD、设置界面
- `story-system`: 剧情系统详细 PRD — 剧本格式、对话框、分支剧情、立绘/CG
- `save-system`: 存档系统详细 PRD — 存档内容、自动存档、序列化格式
- `animation-system`: 动画系统详细 PRD — 动画类型、技术实现、同步机制
- `audio-system`: 音频系统详细 PRD — 音频分类、音量管理、动态切换

### Modified Capabilities
- (无 — 本次不修改已有能力定义，仅从主 PRD 拆分细化)

## Impact

- `docs/` 目录下新增 `docs/prd/` 子目录，每个模块一个 `.md` 文件
- 主 `Godot_SRPG_PRD.md` 保持不变，作为顶层概览
- 不影响任何代码、API 或数据文件
- 不影响 AGENTS.md 中定义的开发阶段和架构设计
