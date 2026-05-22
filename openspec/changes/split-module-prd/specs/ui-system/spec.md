## ADDED Requirements

### Requirement: Main menu has 4 options
The main menu SHALL display: 新游戏, 继续游戏, 设置, 退出.

#### Scenario: New game starts
- **WHEN** player selects "新游戏"
- **THEN** the game SHALL start a new game from the first chapter

#### Scenario: Continue loads save
- **WHEN** player selects "继续游戏"
- **THEN** the game SHALL load the most recent save file

#### Scenario: Continue unavailable without save
- **WHEN** no save file exists and player selects "继续游戏"
- **THEN** the option SHALL be grayed out or display "无存档"

#### Scenario: Settings opens settings screen
- **WHEN** player selects "设置"
- **THEN** the settings screen SHALL open

#### Scenario: Exit closes game
- **WHEN** player selects "退出"
- **THEN** the game SHALL close

### Requirement: Battle UI shows unit info
During battle, the UI SHALL display unit attributes, attack preview, turn indicator, skill menu, minimap.

#### Scenario: Unit selected shows attributes
- **WHEN** player selects a unit
- **THEN** the UI SHALL display that unit's stats (HP, MP, STR, etc.)

#### Scenario: Attack preview before confirming
- **WHEN** player selects an attack target
- **THEN** the UI SHALL show a damage/hit/crit preview

#### Scenario: Turn indicator shows current phase
- **WHEN** turn phase changes
- **THEN** the UI SHALL display the current phase name (Player/Enemy/NPC)

### Requirement: Settings UI has 4 sections
The settings screen SHALL allow adjusting: resolution, volume, language, key bindings.

#### Scenario: Volume slider changes volume
- **WHEN** player adjusts the volume slider
- **THEN** the game's audio volume SHALL change in real time

#### Scenario: Language change requires restart
- **WHEN** player changes language
- **THEN** the game SHALL prompt for restart or apply immediately
