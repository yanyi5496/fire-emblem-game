## ADDED Requirements

### Requirement: Audio has 5 categories
The audio system SHALL support: BGM, UI, 战斗 (combat), 环境音 (ambient), 配音 (voice).

#### Scenario: BGM plays on map
- **WHEN** a battle map loads
- **THEN** the map's BGM SHALL start playing

#### Scenario: UI sound on interaction
- **WHEN** player navigates menus or confirms actions
- **THEN** the corresponding UI sound SHALL play

#### Scenario: Combat sound on attack
- **WHEN** a unit attacks
- **THEN** the combat sound effect SHALL play

### Requirement: Audio supports volume groups
Each audio category SHALL have an independent volume control.

#### Scenario: Volume per category
- **WHEN** player adjusts BGM volume
- **THEN** only BGM volume SHALL change, other categories remain unaffected

### Requirement: Audio supports fade transitions
The system SHALL support fade-in and fade-out for audio transitions.

#### Scenario: BGM crossfade
- **WHEN** transitioning between map and combat
- **THEN** the BGM SHALL fade out and the new BGM SHALL fade in

### Requirement: Audio supports dynamic switching
The system SHALL switch BGM based on game state (exploration, combat, boss, menu).

#### Scenario: Boss BGM on boss encounter
- **WHEN** a boss enemy is engaged
- **THEN** the BGM SHALL switch to boss theme
