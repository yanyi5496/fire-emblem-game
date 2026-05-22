## ADDED Requirements

### Requirement: Pre-modification checklist
Before making any code modification, the developer SHALL check whether the change affects scene contracts, data schema, or main flow state.

#### Scenario: Checklist exists
- **WHEN** a developer starts working on a change
- **THEN** they SHALL consult the pre-modification checklist to assess risk scope

#### Scenario: Contract check required
- **WHEN** a change modifies a scene script
- **THEN** developer SHALL verify that scene contract (signals, exported methods, expected state) is preserved or explicitly updated

### Requirement: Pre-commit verification checklist
Before committing, the developer SHALL run a defined set of verifications.

#### Scenario: Main flow test passes
- **WHEN** changes affect main flow scenes
- **THEN** main flow test SHALL pass before commit

#### Scenario: Battle formula test passes
- **WHEN** changes affect combat system
- **THEN** battle formula tests SHALL pass before commit

#### Scenario: Scene contract intact
- **WHEN** committing scene changes
- **THEN** the corresponding scene contract SHALL be verified

### Requirement: Test coverage matrix
The project SHALL maintain a test coverage matrix identifying which tests cover which systems.

#### Scenario: Data schema tests exist
- **WHEN** JSON data files are modified
- **THEN** corresponding schema validation tests SHALL exist and pass

#### Scenario: Main flow tests exist
- **WHEN** main flow scenes are modified
- **THEN** main flow state transition tests SHALL exist and pass

#### Scenario: Scene contract tests exist
- **WHEN** scene interfaces are modified
- **THEN** scene contract tests SHALL exist and pass

#### Scenario: Combat formula tests exist
- **WHEN** combat calculation logic is modified
- **THEN** combat formula tests SHALL exist and pass

### Requirement: Documentation required for specific changes
Certain types of changes SHALL require documentation updates before commit.

#### Scenario: Scene contract change requires doc
- **WHEN** a scene's public interface (signals, methods, expected states) changes
- **THEN** developer SHALL update or create the corresponding scene contract document

#### Scenario: Data schema change requires doc
- **WHEN** a JSON data schema changes (field added/removed/renamed)
- **THEN** developer SHALL update the corresponding data schema document

#### Scenario: Main flow change requires doc
- **WHEN** GameState.phase transitions or scene routing changes
- **THEN** developer SHALL update the main flow state diagram document
