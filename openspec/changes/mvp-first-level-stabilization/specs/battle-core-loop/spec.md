## ADDED Requirements

### Requirement: Player turn operation chain
The player SHALL be able to complete a full turn action sequence: select unit, display movement range, execute movement, choose attack or wait, and mark unit as acted.

#### Scenario: Select unit shows movement range
- **WHEN** player selects an actionable unit with cursor
- **THEN** system SHALL display the unit's movement range on the tile map

#### Scenario: Move unit to valid tile
- **WHEN** player confirms movement to a tile within the movement range
- **THEN** unit SHALL move to that tile and the movement range overlay SHALL clear

#### Scenario: Attack or wait after movement
- **WHEN** unit has moved and still has action available
- **THEN** system SHALL present attack (if enemy in range) or wait options

#### Scenario: Unit state updated after action
- **WHEN** unit attacks or waits
- **THEN** unit SHALL be marked as acted and SHALL NOT be selectable again this turn

### Requirement: Enemy turn automation
The enemy side SHALL automatically complete actions for all controllable units during the enemy turn.

#### Scenario: Enemy AI iterates over units
- **WHEN** enemy turn starts
- **THEN** system SHALL iterate all enemy units with remaining actions

#### Scenario: Enemy decides target
- **WHEN** enemy unit has an action
- **THEN** AI SHALL select a target based on priority: kill > damage low HP > heal > move toward player

#### Scenario: Enemy executes attack
- **WHEN** enemy AI selects an attack target
- **THEN** enemy unit SHALL move into range and execute the attack

#### Scenario: Enemy waits if no valid action
- **WHEN** enemy unit cannot attack or heal
- **THEN** enemy unit SHALL wait and be marked as acted

### Requirement: Turn switch with state refresh
The system SHALL correctly switch between player and enemy turns and refresh all unit states appropriately.

#### Scenario: Turn advances to next phase
- **WHEN** all units on current side have acted
- **THEN** turn SHALL advance to the next phase (player → enemy → player)

#### Scenario: Unit states reset on new turn
- **WHEN** a new turn begins for a side
- **THEN** all units on that side SHALL have their action state reset to available

#### Scenario: Turn counter increments
- **WHEN** a full player+enemy cycle completes
- **THEN** turn counter SHALL increment by 1

### Requirement: Victory and defeat detection
The system SHALL correctly detect and trigger victory and defeat conditions during battle.

#### Scenario: Victory on defeating all enemies
- **WHEN** all enemy units are defeated (HP <= 0)
- **THEN** victory condition SHALL be triggered

#### Scenario: Defeat on losing all player units
- **WHEN** all player units are defeated (HP <= 0)
- **THEN** defeat condition SHALL be triggered

### Requirement: UnitActor / TurnManager / BattleController responsibility separation
The three battle management components SHALL have clearly defined responsibilities.

#### Scenario: UnitActor handles single unit operations
- **WHEN** a unit needs to move, attack, or use a skill
- **THEN** UnitActor SHALL execute the operation without making tactical decisions

#### Scenario: TurnManager handles turn scheduling
- **WHEN** turn phase changes
- **THEN** TurnManager SHALL manage the turn queue, player/enemy/NPC switching, and action order

#### Scenario: BattleController handles battle orchestration
- **WHEN** battle state changes (turn end, unit defeated)
- **THEN** BattleController SHALL check victory/defeat conditions and report results to the main flow
