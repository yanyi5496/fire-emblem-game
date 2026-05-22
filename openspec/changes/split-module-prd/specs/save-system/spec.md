## ADDED Requirements

### Requirement: Save contains complete game state
Save data SHALL include: map state, unit states, inventory, gold, story progress, completed missions.

#### Scenario: Save captures unit positions
- **WHEN** the game saves
- **THEN** all unit positions, HP, states, and equipment SHALL be serialized

#### Scenario: Save captures inventory
- **WHEN** the game saves
- **THEN** all items in the convoy and unit inventories SHALL be saved

#### Scenario: Save captures story progress
- **WHEN** the game saves
- **THEN** the current chapter and story flags SHALL be saved

### Requirement: Auto-save triggers at key points
Auto-save SHALL trigger at: round end, battle end, story event end.

#### Scenario: Auto-save on round end
- **WHEN** a round ends
- **THEN** the game SHALL automatically save

#### Scenario: Auto-save on battle end
- **WHEN** a battle ends
- **THEN** the game SHALL automatically save before returning to the world map

### Requirement: Save format supports versioning
Save files SHALL include a version number for forward/backward compatibility.

#### Scenario: Old save format detected
- **WHEN** loading a save with an older version
- **THEN** the system SHALL attempt migration or display an incompatibility message
