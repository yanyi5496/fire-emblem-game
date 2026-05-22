## ADDED Requirements

### Requirement: Job defines weapon proficiencies
Each job SHALL define which weapon types the unit can equip: Sword, Lance, Axe, Bow, Staff, Magic.

#### Scenario: Unit equips weapon matching job
- **WHEN** a unit attempts to equip a weapon
- **THEN** the system SHALL check that the weapon type is in the unit's job's allowed weapon list

#### Scenario: Unit cannot equip non-matching weapon
- **WHEN** a unit attempts to equip a weapon not in its job's allowed list
- **THEN** the equip action SHALL be rejected

### Requirement: Job provides growth rate modifiers
Each job SHALL define growth rate modifiers that adjust the unit's base growth rates.

#### Scenario: Job modifier applied to growth
- **WHEN** a unit gains a level
- **THEN** the job's growth modifiers SHALL be added to the unit's base growth rates before randomization

### Requirement: Job defines movement and terrain adaptation
Each job SHALL define base MOV and terrain-specific movement costs.

#### Scenario: Job affects movement range
- **WHEN** a unit's movement range is calculated
- **THEN** the job's MOV value SHALL be used as the base movement

#### Scenario: Terrain adaptation varies by job
- **WHEN** pathfinding across different terrain types
- **THEN** the job's terrain adaptation table SHALL modify movement costs

### Requirement: Job promotion system
The system SHALL support three job tiers: 初级职业, 高级职业, 特殊职业. Promotion paths SHALL be defined (e.g., 剑士→剑圣).

#### Scenario: Unit promotes to advanced job
- **WHEN** a unit meets promotion requirements (level, items)
- **THEN** the unit SHALL change to the advanced job and retain a percentage of stats

### Requirement: Job classification
The system SHALL support at least 8 job classes: 剑士, 枪兵, 斧兵, 骑士, 弓箭手, 法师, 牧师, 飞行单位.

#### Scenario: Each class has unique properties
- **WHEN** a unit is assigned a job class
- **THEN** it SHALL inherit the class-specific weapon types, movement, and growth modifiers

### Requirement: Job data is JSON-driven
Job definitions SHALL be stored as JSON files in res://data/jobs/.

#### Scenario: Job loaded from JSON
- **WHEN** the game loads a unit with a job
- **THEN** it SHALL read the job's JSON data to determine job properties
