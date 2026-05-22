# 架构约束文档

## 基本规则

1. **GameState.phase 是唯一状态源**
   - 所有场景切换必须通过 GameState.set_phase + SceneRouter.goto
   - 禁止脚本直接调用 get_tree().change_scene_to_file
   - 禁止在 phase 之外维护独立的场景状态标志

2. **场景职责不可越界**
   - boot: 只初始化和路由，不做其他业务逻辑
   - main_menu: 只处理菜单交互，不处理战斗或剧情
   - story_player: 只处理剧情表现和事件触发，不处理战斗逻辑
   - battle_scene: 只处理战斗编排，不处理菜单或剧情

3. **UI 通过信号通信**
   - UI 面板只监听来自业务层的信号
   - 业务脚本不得直接修改 UI 控件属性
   - UI 节点不应包含业务逻辑

4. **JSON 数据必须静态校验**
   - 所有 JSON 数据加载时做 schema 校验
   - 缺失关键字段必须报错，不允许静默默认值
   - 运行时状态字段必须与 JSON schema 一一对应

5. **存档版本化**
   - 存档 schema 必须包含 version 字段
   - 加载时按版本号执行迁移函数
   - 不支持的版本号直接拒绝

## 模块边界

- **scripts/autoload/**: 全局单例，可被任何脚本引用
- **scripts/battle/**: 战斗系统，依赖 DataManager, GameState, InputManager
- **scripts/menu/**: 菜单系统，依赖 SceneRouter, GameState
- **scripts/story/**: 剧情系统，依赖 StoryParser, AudioManager, InputManager
- **scripts/ui/**: UI 面板，只通过信号通信，不应直接引用业务脚本
- **scripts/unit/**: 单位系统，可被战斗系统引用
- **scripts/common/**: 通用工具，无业务依赖

## 不允许的操作

- SceneRouter.goto 以外的场景切换方式
- 在非 autoload 脚本中直接使用 Input 单例（应通过 InputManager）
- 在 UI 脚本中操作业务数据
- 在 data JSON 中使用运行时才有的字段

## 跨模块引用规则

- Autoload → 任何模块（允许）
- Battle → Unit, Common（允许）
- Battle → Menu（禁止，通过 SceneRouter 间接）
- Menu → Story（禁止，通过 SceneRouter 间接）
- UI → 业务模块（禁止，通过信号通信）
