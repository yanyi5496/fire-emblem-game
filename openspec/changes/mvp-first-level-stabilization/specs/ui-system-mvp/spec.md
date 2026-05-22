## ADDED Requirements

### Requirement: Unified UI layout baseline
The UI system SHALL use a design resolution of 1280x720 with consistent anchor and stretch settings across all UI panels.

#### Scenario: Design resolution applied
- **WHEN** any UI scene is loaded
- **THEN** it SHALL be configured with 1280x720 as the design resolution

#### Scenario: Stretch strategy works
- **WHEN** window is resized to different aspect ratios
- **THEN** UI elements SHALL remain visible and properly positioned without clipping or drifting

### Requirement: Four core UI panels defined
The system SHALL have four core UI panels: main menu, story dialog, battle HUD, and action menu (including attack preview and terrain info).

#### Scenario: Main menu displays correctly
- **WHEN** main_menu scene is active
- **THEN** the menu SHALL display all main options (New Game, Continue, Settings, Quit)

#### Scenario: Story dialog displays correctly
- **WHEN** story_player scene is active
- **THEN** the story dialog SHALL display character name, dialog text, and continue prompt

#### Scenario: Battle HUD displays correctly
- **WHEN** battle_scene is active
- **THEN** battle HUD SHALL display unit info, turn counter, and phase indicator

#### Scenario: Action menu displays when unit selected
- **WHEN** player selects an actionable unit in battle
- **THEN** action menu SHALL display relevant options (Attack, Wait, etc.)

#### Scenario: Attack preview shows when targeting
- **WHEN** player selects Attack and targets an enemy
- **THEN** attack preview SHALL display hit rate, damage, and crit chance

### Requirement: UI visibility rules
Each UI panel SHALL have defined show/hide rules, and SHALL NOT overlap or conflict with other panels.

#### Scenario: Battle HUD always visible during battle
- **WHEN** battle_scene is active
- **THEN** battle HUD SHALL always be visible

#### Scenario: Action menu hides after unit acts
- **WHEN** unit completes its action (attack/wait)
- **THEN** action menu SHALL hide until next unit selection

#### Scenario: Story dialog hides during choices
- **WHEN** story player shows a choice prompt
- **THEN** story dialog SHALL remain visible and choice options SHALL appear

### Requirement: Signal-based UI communication
UI panels SHALL communicate with business logic exclusively through Godot signals, not by directly modifying UI control state from business scripts.

#### Scenario: UI listens to signals
- **WHEN** a game event occurs (unit selected, phase change, damage dealt)
- **THEN** the relevant signal SHALL be emitted and UI panels SHALL update their display in response

#### Scenario: Business logic does not touch UI directly
- **WHEN** business logic runs (combat calculation, turn management)
- **THEN** it SHALL NOT directly modify UI control properties
