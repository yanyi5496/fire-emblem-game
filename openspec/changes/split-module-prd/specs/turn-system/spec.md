## ADDED Requirements

### Requirement: Turn has 4 phases
The turn system SHALL support Player Turn, Enemy Turn, NPC Turn, Round End phases.

#### Scenario: Turn order is fixed
- **WHEN** a new round begins
- **THEN** the turn order SHALL be: Player → Enemy → NPC → Round End

#### Scenario: Player phase allows unit control
- **WHEN** it is Player Turn
- **THEN** the player SHALL be able to select and command their units

#### Scenario: Enemy phase activates AI
- **WHEN** it is Enemy Turn
- **THEN** all enemy units SHALL act according to their AI

#### Scenario: NPC phase activates NPC AI
- **WHEN** it is NPC Turn
- **THEN** all NPC units SHALL act according to their AI

### Requirement: Round End performs settlement
At Round End, the system SHALL process: Buff Tick, Debuff Tick, poison damage, auto-heal, skill cooldown.

#### Scenario: Poison damage at round end
- **WHEN** Round End phase executes
- **THEN** any unit with Poison state SHALL take poison damage

#### Scenario: Auto-heal at round end
- **WHEN** Round End phase executes
- **THEN** units with auto-heal effects SHALL recover HP

#### Scenario: Skill cooldown decrements
- **WHEN** Round End phase executes
- **THEN** all skill cooldown timers SHALL decrement by 1

### Requirement: Turn phase transition is controlled
The system SHALL only advance to the next phase after all units in the current phase have completed their actions.

#### Scenario: Phase waits for all units
- **WHEN** all player units have finished actions
- **THEN** the turn SHALL advance to Enemy phase

### Requirement: Victory/defeat checked each turn
The system SHALL check victory conditions (all enemies defeated) and defeat conditions (all player units dead) at the start of each phase.

#### Scenario: Victory condition met
- **WHEN** all enemy units are defeated
- **THEN** the battle SHALL end with a victory screen

#### Scenario: Defeat condition met
- **WHEN** all player units are dead
- **THEN** the battle SHALL end with a defeat screen
