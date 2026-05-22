## ADDED Requirements

### Requirement: Main flow state consistency
The system SHALL maintain strict consistency between GameState.phase and the active scene. At any point, the current phase SHALL accurately reflect which scene is active.

#### Scenario: Boot to menu transition
- **WHEN** boot scene finishes initialization
- **THEN** GameState.phase SHALL change to "main_menu" and main_menu scene SHALL be active

#### Scenario: Menu to story transition
- **WHEN** player selects "New Game" from main menu
- **THEN** GameState.phase SHALL change to "story" and story_player scene SHALL be active

#### Scenario: Story to battle transition
- **WHEN** story completes or triggers battle event
- **THEN** GameState.phase SHALL change to "battle" and battle_scene SHALL be active

#### Scenario: Battle to result transition
- **WHEN** victory or defeat condition is met in battle
- **THEN** GameState.phase SHALL change to "result" and result scene SHALL be active

### Requirement: No blank states during transition
The system SHALL NOT enter a state where a scene is loaded but has no content to display. Every scene SHALL have a valid initial display state.

#### Scenario: Scene loads with content
- **WHEN** any main flow scene is loaded
- **THEN** it SHALL immediately display its primary content (menu options, story text, battle map, result screen)

### Requirement: Clear exit path from every phase
Every scene SHALL have a defined exit transition for all possible outcomes.

#### Scenario: Victory exit
- **WHEN** battle victory condition is met
- **THEN** game SHALL transition to result scene showing victory

#### Scenario: Defeat exit
- **WHEN** battle defeat condition is met
- **THEN** game SHALL transition to result scene showing defeat

#### Scenario: Return to menu
- **WHEN** player selects "Return to Menu" from result screen
- **THEN** game SHALL transition to main_menu scene and GameState.phase SHALL change to "main_menu"

### Requirement: Scene responsibility boundaries
Each scene SHALL have clearly defined responsibilities and SHALL NOT perform actions outside those boundaries.

#### Scenario: Boot only initializes and routes
- **WHEN** boot scene runs
- **THEN** it SHALL only perform initialization and route to the next appropriate scene

#### Scenario: Main menu only handles menu interaction
- **WHEN** main_menu scene is active
- **THEN** it SHALL only handle menu UI interactions and trigger scene transitions

#### Scenario: Story player only handles story display and events
- **WHEN** story_player scene is active
- **THEN** it SHALL only display story content and trigger story-defined events

#### Scenario: Battle scene assembles and starts
- **WHEN** battle_scene is loaded
- **THEN** it SHALL assemble all battle entities and start the first turn
