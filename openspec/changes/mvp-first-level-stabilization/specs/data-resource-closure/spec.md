## ADDED Requirements

### Requirement: All first-level JSON data loadable
All JSON data files for the first level (units, weapons, jobs, skills, maps, stories) SHALL be loadable without errors.

#### Scenario: Unit data loads
- **WHEN** unit data JSON is loaded
- **THEN** all fields SHALL exist and types SHALL match runtime expectations

#### Scenario: Weapon data loads
- **WHEN** weapon data JSON is loaded
- **THEN** all fields SHALL exist and types SHALL match runtime expectations

#### Scenario: Job data loads
- **WHEN** job data JSON is loaded
- **THEN** all fields SHALL exist and types SHALL match runtime expectations

#### Scenario: Skill data loads
- **WHEN** skill data JSON is loaded
- **THEN** all fields SHALL exist and types SHALL match runtime expectations

#### Scenario: Map data loads and generates correctly
- **WHEN** map data JSON is loaded
- **THEN** the tile map SHALL be generated exactly as defined, with correct terrain properties

#### Scenario: Story data loads
- **WHEN** story data JSON is loaded
- **THEN** all story events, dialog lines, and triggers SHALL be parsed correctly

### Requirement: Unit template and runtime state correspondence
Unit data template fields SHALL correspond exactly to runtime state fields, with no fields that exist in only one representation.

#### Scenario: Template fields match runtime
- **WHEN** a unit is instantiated from template data
- **THEN** ALL template fields SHALL have corresponding runtime fields, and ALL runtime fields SHALL have corresponding template fields (or be explicitly runtime-only)

#### Scenario: No silent default values
- **WHEN** a template field is missing or invalid
- **THEN** the system SHALL report an error, not silently apply a default value

### Requirement: Asset placeholder rules
The project SHALL define clear rules for when placeholder assets are acceptable vs when their absence must cause an error.

#### Scenario: Acceptable placeholder
- **WHEN** a formal asset has not been created yet
- **THEN** a placeholder (colored rectangle, temporary sprite) MAY be used AND SHALL be clearly marked as placeholder

#### Scenario: Missing critical asset fails
- **WHEN** a critical asset (unit sprite, map tileset) is missing
- **THEN** the system SHALL report an error and halt, not proceed with broken visuals

### Requirement: Audio missing degradation
When audio files are missing, the system SHALL degrade gracefully without crashing.

#### Scenario: Missing BGM
- **WHEN** a BGM audio file is missing
- **THEN** the system SHALL skip the audio without crashing and (optionally) log a warning

#### Scenario: Missing SFX
- **WHEN** an SFX audio file is missing
- **THEN** the system SHALL skip the audio without crashing and (optionally) log a warning
