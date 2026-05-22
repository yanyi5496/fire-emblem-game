# 场景契约文档

## BootScene (boot_scene.tscn / boot_controller.gd)

- **类名**: BootController
- **职责**: 初始化并路由到主菜单
- **输入信号**: 无
- **输出信号**: 无
- **依赖的 Autoload**: GameState, SceneRouter
- **状态约定**: 设置 GamePhase.TITLE, 路由到 main_menu
- **先决条件**: SceneRouter 和 GameState 已加载

## MainMenu (main_menu.tscn / main_menu.gd)

- **类名**: MainMenu
- **职责**: 主菜单交互（新游戏、继续、设置、退出）
- **输入信号**: 无
- **输出信号**: 无（通过 SceneRouter 切换场景）
- **依赖的 Autoload**: GameState, SceneRouter, SaveManager
- **状态约定**: 显示时 phase 为 TITLE；New Game 重置状态后路由到 story；Continue 加载存档后路由到 battle
- **按钮**:
  - NewGame: GameState.reset() → 设置 chapter_01/mvp_map_01 → SceneRouter.goto("story")
  - Continue: SaveManager.load_game(1) → SceneRouter.goto("battle")
  - Settings: SceneRouter.goto("settings")
  - Quit: get_tree().quit()

## StoryPlayer (story_player.tscn / story_player.gd)

- **类名**: StoryPlayer
- **职责**: 剧情播放和事件触发
- **输入信号**: InputManager.confirm_pressed
- **输出信号**: story_finished, choice_made(index)
- **依赖**: StoryParser, AudioManager, DataManager
- **状态约定**: 活跃时 phase = STORY；事件 "load_map" 路由到 battle
- **生命周期**: _ready → play_story → _advance 循环 → Event 触发切换
- **支持的事件**: load_map(→battle), chapter_clear(→finish), game_over(→finish)

## BattleScene (battle_scene.tscn / battle_controller.gd)

- **类名**: BattleController
- **职责**: 战斗编排、单位生成、光标交互、回合管理、胜负判定
- **输入信号**: InputManager.confirm_pressed, cancel_pressed, move_cursor
- **输出信号**: battle_started, battle_ended(result), unit_selected, action_executed
- **依赖**: TurnManager, CombatManager, PathfindingService, AIController
- **子节点契约**:
  - $TurnManager: 回合调度
  - $Cursor: 光标节点（位置由代码控制）
  - $Units: 单位容器
  - $MapRoot/GroundTileMap: 地面地形 TileMap
  - $MapRoot/HighlightTileMap: 高亮 TileMap
  - $PathfindingService: 寻路和范围计算
  - $UI (BattleHUD): 战斗界面

## BattleHUD (battle_hud.tscn / battle_hud.gd)

- **类名**: BattleHUD
- **职责**: 战斗界面显示（回合信息、单位信息、行动菜单、攻击预览）
- **输入信号**: end_turn_pressed
- **输出信号**: 无
- **子节点**:
  - $TurnLabel: 回合标签
  - $UnitInfoPanel: 单位信息面板
  - $ActionMenu: 行动菜单（ActionMenu 类）
  - $AttackPreview: 攻击预览（AttackPreview 类）

## ActionMenu (action_menu.tscn / action_menu.gd)

- **类名**: ActionMenu
- **信号**: move_selected, attack_selected, skill_selected, wait_selected

## AttackPreview (attack_preview.tscn / attack_preview.gd)

- **类名**: AttackPreview
- **信号**: attack_confirmed, attack_cancelled

## SettingsMenu (settings_menu.tscn / settings_menu.gd)

- **类名**: SettingsMenu
- **职责**: 设置菜单
- **状态约定**: 活跃时 phase = SETTINGS；返回路由到 main_menu

## SaveLoadMenu (save_load_menu.tscn / save_load_menu.gd)

- **类名**: SaveLoadMenu
- **职责**: 存档/读档
- **状态约定**: 活跃时 phase = SAVE_LOAD
