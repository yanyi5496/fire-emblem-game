## ADDED Requirements

### Requirement: Skill has 4 types
The system SHALL support 主动技能 (active), 被动技能 (passive), 光环技能 (aura), 反击技能 (counter).

#### Scenario: Active skill requires activation
- **WHEN** a unit uses an active skill
- **THEN** the unit SHALL spend MP (if applicable) and the skill effect SHALL be applied

#### Scenario: Passive skill always active
- **WHEN** a unit with a passive skill exists
- **THEN** the skill effect SHALL be permanently applied

#### Scenario: Aura skill affects allies in range
- **WHEN** an ally is within the aura's range
- **THEN** the ally SHALL receive the aura's effect

#### Scenario: Counter skill triggers on being attacked
- **WHEN** a unit with a counter skill is attacked
- **THEN** the skill effect SHALL trigger during combat

### Requirement: Skill has a defined data structure
Each skill SHALL have: id (string), name (string), trigger (string), effect (string).

#### Scenario: Skill loaded from JSON
- **WHEN** a skill is loaded
- **THEN** it SHALL initialize from the JSON data with id, name, trigger, effect

### Requirement: Skills trigger at defined timing points
Skills SHALL trigger at: 回合开始, 回合结束, 战斗前, 战斗后, 被攻击时.

#### Scenario: Turn-start skill activates
- **WHEN** a unit's turn begins
- **THEN** all skills with trigger="回合开始" SHALL activate

#### Scenario: Pre-combat skill activates
- **WHEN** combat is initiated
- **THEN** all skills with trigger="战斗前" SHALL activate before damage calculation

### Requirement: Skill data is JSON-driven
Skill definitions SHALL be stored as JSON files in res://data/skills/.

#### Scenario: Skill registry loaded
- **WHEN** the game initializes
- **THEN** all skill JSON files SHALL be loaded into a skill registry
