## ADDED Requirements

### Requirement: Combat follows defined flow
Combat SHALL follow this flow: 攻击声明 → 命中判定 → 暴击判定 → 伤害计算 → 反击 → 连击 → 死亡结算.

#### Scenario: Full combat sequence
- **WHEN** attacker initiates combat
- **THEN** the system SHALL execute the full combat flow in order

### Requirement: Damage formula is Attack - Defense
Damage SHALL be calculated as: Attack stat (STR for physical, MAG for magical) + Weapon Might - target's Defense (DEF for physical, RES for magical).

#### Scenario: Physical damage calculation
- **WHEN** attacker uses physical weapon
- **THEN** damage = attacker.STR + weapon.Might - target.DEF

#### Scenario: Magical damage calculation
- **WHEN** attacker uses magic weapon
- **THEN** damage = attacker.MAG + weapon.Might - target.RES

#### Scenario: Minimum damage is 0
- **WHEN** calculated damage would be negative
- **THEN** damage SHALL be set to 0

### Requirement: Hit formula is WeaponHit + SKL*2 + LUK
Hit rate SHALL be calculated as: weapon.Hit + attacker.SKL * 2 + attacker.LUK - terrain avoid_bonus - target avoid stats.

#### Scenario: Hit rate calculation
- **WHEN** hit rate is calculated
- **THEN** it SHALL include weapon hit, unit skill, and luck

#### Scenario: Hit rate capped at 100
- **WHEN** calculated hit rate exceeds 100
- **THEN** hit rate SHALL be capped at 100

### Requirement: Crit formula is SKL/2 + WeaponCrit
Critical rate SHALL be calculated as: attacker.SKL / 2 + weapon.Crit.

#### Scenario: Critical rate calculation
- **WHEN** critical rate is calculated
- **THEN** it SHALL include unit skill and weapon crit

#### Scenario: Critical hit doubles damage
- **WHEN** a critical hit lands
- **THEN** damage SHALL be multiplied by 3

### Requirement: Counterattack mechanics
If the defender survives and has a weapon with range matching the attacker's range, the defender SHALL counterattack.

#### Scenario: Defender counterattacks
- **WHEN** defender survives and is in range
- **THEN** defender SHALL execute a counterattack against the attacker

### Requirement: Double attack (follow-up) mechanics
If attacker's SPD >= defender's SPD + 4, the attacker SHALL attack twice.

#### Scenario: Double attack triggered
- **WHEN** attacker SPD >= defender SPD + 4
- **THEN** attacker SHALL attack an additional time

### Requirement: Death resolution
When a unit's HP reaches 0 after combat, the unit SHALL be set to Dead state and removed from the map.

#### Scenario: Unit dies in combat
- **WHEN** defender HP <= 0 after damage
- **THEN** unit state SHALL change to Dead
