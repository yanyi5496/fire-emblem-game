# 设计与准备文档总导航

## 1. 目的

本文档作为 `docs/design/` 的总入口，帮助新成员、协作者和后续 Godot 开发者快速找到当前 MVP 所需的全部非代码准备资料。

阅读原则：

- 先看“必读顺序”
- 再按职责进入对应分组
- 若只想立即开工，直接看“最快上手路径”

## 2. 必读顺序

建议第一次进入项目时按以下顺序阅读：

1. `docs/prd/TOP_PRD.md`
2. `docs/architecture/godot-implementation-blueprint.md`
3. `docs/design/mvp-data-pack.md`
4. `docs/design/mvp-map-production-pack.md`
5. `docs/design/story-mvp-direction-sheet.md`
6. `docs/design/mvp-resource-production-plan.md`
7. `docs/design/mvp-acceptance-runbook.md`

## 3. 最快上手路径

### 策划

优先阅读：

1. `mvp-balance-baseline.md`
2. `mvp-map-production-pack.md`
3. `story-mvp-direction-sheet.md`
4. `mvp-acceptance-runbook.md`

### 美术 / UI

优先阅读：

1. `mvp-style-benchmark.md`
2. `mvp-resource-production-plan.md`
3. `reference-collection-checklist.md`
4. `resource-delivery-checklist.md`
5. `collaborator-task-pack-template.md`

### 音频

优先阅读：

1. `story-mvp-direction-sheet.md`
2. `mvp-style-benchmark.md`
3. `mvp-resource-production-plan.md`
4. `collaborator-task-pack-template.md`

### 程序

优先阅读：

1. `mvp-data-pack.md`
2. `mvp-map-production-pack.md`
3. `ui-wireframes.md`
4. `mvp-acceptance-runbook.md`
5. `mvp-content-schedule.md`

## 4. 文档分组

### 4.1 核心内容设计

| 文档 | 作用 |
|---|---|
| `mvp-data-pack.md` | 首关数据包定义 |
| `mvp-map-spec.md` | 首关地图规格 |
| `mvp-map-production-pack.md` | 首关地图制作输入 |
| `mvp-balance-notes.md` | 数值推演与风险观察 |
| `mvp-balance-baseline.md` | 第一轮数值定版口径 |
| `story-mvp-script.md` | 首关剧本文本 |
| `story-mvp-direction-sheet.md` | 首关演出执行表 |
| `ui-wireframes.md` | 界面线框与状态流 |

### 4.2 资源与风格

| 文档 | 作用 |
|---|---|
| `resource-checklist.md` | 资源总清单 |
| `mvp-resource-production-plan.md` | 资源生产计划 |
| `mvp-style-benchmark.md` | 风格基准 |
| `reference-collection-checklist.md` | 参考素材收集规范 |
| `resource-delivery-checklist.md` | 资源交付验收表 |

### 4.3 协作与执行

| 文档 | 作用 |
|---|---|
| `mvp-content-schedule.md` | 内容排期与里程碑 |
| `collaborator-task-pack-template.md` | 协作者任务包模板 |
| `mvp-acceptance-runbook.md` | MVP 验收脚本 |
| `test-checklist-mvp.md` | 测试清单原表 |
| `naming-conventions.md` | 命名规范 |

## 5. 当前推荐使用方式

如果你现在就要推进项目，建议按下面方式使用：

1. 用 `mvp-content-schedule.md` 决定先做什么
2. 用 `collaborator-task-pack-template.md` 发任务
3. 用 `mvp-style-benchmark.md` 和 `reference-collection-checklist.md` 定方向
4. 用 `resource-delivery-checklist.md` 收资源
5. 用 `mvp-acceptance-runbook.md` 做联调验收

## 6. 当前状态

`docs/design/` 当前已经覆盖：

- 数据
- 地图
- 数值
- 剧情
- UI
- 资源
- 风格
- 排期
- 协作发包
- 资源验收
- 测试验收

也就是说，非代码准备工作已经形成完整闭环。

## 7. 后续原则

从现在开始，如果没有新增需求，原则上：

- 不再继续扩写新的泛文档
- 优先复用现有模板发包、收包、验收
- 准备工作若要继续增加，必须直接服务具体执行

当第一批占位资源到位后，项目就应进入 Godot 场景与资源接线阶段。
