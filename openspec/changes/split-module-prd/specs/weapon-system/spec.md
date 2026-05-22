## ADDED Requirements

### Requirement: Weapon has 6 core stats
Every weapon SHALL have: Might, Hit, Crit, Weight, Range, Durability.

#### Scenario: Weapon stats affect combat
- **WHEN** combat is calculated
- **THEN** Might SHALL contribute to damage, Hit to hit chance, Crit to critical chance, Weight to attack speed

#### Scenario: Weapon durability decreases on use
- **WHEN** a unit attacks with a weapon
- **THEN** the weapon's Durability SHALL decrease by 1

#### Scenario: Weapon breaks at 0 durability
- **WHEN** a weapon's Durability reaches 0
- **THEN** the weapon SHALL become unusable

### Requirement: Weapon has 6 types
The weapon system SHALL support Sword, Lance, Axe, Bow, Staff, Magic types.

#### Scenario: Weapon type determines equip eligibility
- **WHEN** a unit equips a weapon
- **THEN** the system SHALL check if the weapon type is in the unit's job's allowed weapon list

### Requirement: Weapon triangle provides bonuses
The weapon triangle SHALL be: Sword > Axe, Axe > Lance, Lance > Sword. The advantage SHALL provide hit +15 and damage +1.

#### Scenario: Advantage bonus applied
- **WHEN** attacker has weapon advantage over defender
- **THEN** attacker SHALL gain +15 hit and +1 damage

#### Scenario: Disadvantage penalty applied
- **WHEN** attacker has weapon disadvantage
- **THEN** attacker SHALL suffer -15 hit and -1 damage

#### Scenario: Neutral triangle
- **WHEN** weapons are in the same category or Bow/Staff/Magic
- **THEN** no triangle modifier SHALL be applied

### Requirement: Weapon range varies
Different weapon types SHALL have different ranges (melee=1, bow=2, magic=1-2).

#### Scenario: Unit can only attack in range
- **WHEN** a unit selects an attack target
- **THEN** the target SHALL be within the weapon's Range

### Requirement: Weapon data is JSON-driven
Weapon definitions SHALL be stored as JSON files in res://data/weapons/.

#### Scenario: Weapon loaded from JSON
- **WHEN** the game loads a weapon
- **THEN** it SHALL read the weapon's JSON data and initialize the weapon accordingly
