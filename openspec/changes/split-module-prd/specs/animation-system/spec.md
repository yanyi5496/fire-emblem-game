## ADDED Requirements

### Requirement: Animation supports 6 types
The animation system SHALL support: 待机 (idle), 行走 (walk), 攻击 (attack), 暴击 (critical), 死亡 (death), 技能 (skill).

#### Scenario: Idle animation plays when waiting
- **WHEN** a unit has not taken any action
- **THEN** the idle animation SHALL loop

#### Scenario: Walk animation during movement
- **WHEN** a unit moves along a path
- **THEN** the walk animation SHALL play

#### Scenario: Attack animation on combat
- **WHEN** a unit attacks
- **THEN** the attack animation SHALL play

#### Scenario: Death animation on death
- **WHEN** a unit's HP reaches 0
- **THEN** the death animation SHALL play before the unit is removed

### Requirement: Implementation uses AnimationPlayer and AnimatedSprite2D
Animations SHALL be implemented using Godot's AnimationPlayer and AnimatedSprite2D nodes, with Tween for transitions.

#### Scenario: AnimationPlayer controls animation
- **WHEN** an animation is triggered
- **THEN** the AnimationPlayer SHALL play the corresponding animation

#### Scenario: Tween used for smooth movement
- **WHEN** a unit moves between tiles
- **THEN** Tween SHALL interpolate the unit's position smoothly

### Requirement: Animation synchronization
Combat animations SHALL be synchronized so that hit frames align with damage calculation.

#### Scenario: Hit frame sync
- **WHEN** attack animation reaches the hit frame
- **THEN** the damage calculation SHALL execute at that moment
