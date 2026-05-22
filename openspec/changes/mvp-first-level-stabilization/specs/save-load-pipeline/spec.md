## ADDED Requirements

### Requirement: Save boundary definition
The save system SHALL clearly distinguish between global state (persistent across sessions) and battle runtime state (per-battle).

#### Scenario: Global state saved
- **WHEN** game is saved from main menu or after battle
- **THEN** global state SHALL include: player progress, unlocked chapters, settings

#### Scenario: Battle state saved separately
- **WHEN** game is saved during battle
- **THEN** battle state SHALL include: unit positions, HP/status, turn count, phase

#### Scenario: Clear separation
- **WHEN** loading a save
- **THEN** the system SHALL know whether the save is menu-level or battle-level and load accordingly

### Requirement: New game / Continue game / Mid-battle save / Post-battle save
The system SHALL support four save scenarios with distinct behavior.

#### Scenario: New game starts fresh
- **WHEN** player selects "New Game"
- **THEN** system SHALL start from the beginning, ignoring any existing save data

#### Scenario: Continue game loads last save
- **WHEN** player selects "Continue"
- **THEN** system SHALL load the most recent save and restore to the appropriate scene

#### Scenario: Mid-battle save restores battle
- **WHEN** player saves during battle and later loads
- **THEN** battle state SHALL be fully restored (units, positions, turn, phase)

#### Scenario: Post-battle save goes to menu
- **WHEN** player saves after battle completes
- **THEN** save SHALL be a menu-level save and loading it SHALL return to main menu

### Requirement: Save recovery granularity
The first version of save recovery SHALL restore game state to a playable state without data corruption.

#### Scenario: Full state restore
- **WHEN** a save is loaded
- **THEN** all saved fields SHALL be restored to their exact saved values

#### Scenario: No corrupt state after load
- **WHEN** a save is loaded
- **THEN** the game SHALL NOT enter a state where references are broken or data is inconsistent

### Requirement: Save schema versioning
The save schema SHALL include a version field and loading SHALL use version-specific migration logic.

#### Scenario: Version field exists
- **WHEN** a save file is created
- **THEN** it SHALL include a version number in the schema

#### Scenario: Version migration on load
- **WHEN** loading a save with an older version number
- **THEN** system SHALL apply version-specific migration functions before restoring

#### Scenario: Unsupported version rejected
- **WHEN** loading a save with an unsupported version number
- **THEN** system SHALL reject the save and inform the user, not attempt to load with defaults
