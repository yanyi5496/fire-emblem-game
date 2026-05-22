## ADDED Requirements

### Requirement: AI has 5 behavior types
The AI system SHALL support Aggressive, Defensive, Support, Boss, Patrol types.

#### Scenario: Aggressive AI prioritizes attacking
- **WHEN** an Aggressive AI unit acts
- **THEN** it SHALL prioritize moving toward and attacking the nearest enemy

#### Scenario: Defensive AI holds position
- **WHEN** a Defensive AI unit acts
- **THEN** it SHALL prioritize staying near its starting position and attacking enemies that enter range

#### Scenario: Support AI heals allies
- **WHEN** a Support AI unit acts
- **THEN** it SHALL prioritize healing injured allies over attacking

#### Scenario: Boss AI uses special skills
- **WHEN** a Boss AI unit acts
- **THEN** it SHALL use special skills when available

#### Scenario: Patrol AI follows a path
- **WHEN** a Patrol AI unit acts
- **THEN** it SHALL follow a predefined patrol route

### Requirement: AI follows priority-based decision
AI evaluation SHALL use this priority order: kill target > attack injured > attack healer > capture point > approach player.

#### Scenario: Kill target prioritized
- **WHEN** an enemy unit can kill a player unit in one attack
- **THEN** that action SHALL be selected over other options

#### Scenario: Low HP target preferred
- **WHEN** no kill is possible
- **THEN** AI SHALL target the player unit with the lowest HP percentage

### Requirement: AI follows defined flow
AI action flow SHALL be: 搜索目标 → 评估收益 → 计算路径 → 选择行动 → 执行.

#### Scenario: AI completes full flow
- **WHEN** an AI unit is activated
- **THEN** it SHALL search for targets, evaluate options, calculate paths, select the best action, and execute

### Requirement: AI pathfinds to target
The AI SHALL calculate the optimal path to its chosen target using movement costs.

#### Scenario: AI moves toward enemy
- **WHEN** AI selects a target
- **THEN** it SHALL calculate the shortest walkable path to attack range
