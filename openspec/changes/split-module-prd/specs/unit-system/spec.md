## ADDED Requirements

### Requirement: Unit has 10 core stats
Every unit SHALL have the following stats: HP, MP, STR, MAG, SKL, SPD, DEF, RES, LUK, MOV.

#### Scenario: Unit initialized with stats
- **WHEN** a unit is created from data
- **THEN** all 10 stats SHALL be initialized with values from the unit data JSON

#### Scenario: Stats affect combat
- **WHEN** combat is calculated
- **THEN** STR/MAG SHALL affect damage, SPD SHALL affect double attack, SKL/LUK SHALL affect hit/crit

### Requirement: Unit has state machine
Every unit SHALL have a state machine with states: Idle, Moved, Acted, Dead, Poison, Sleep, Paralysis, Silence.

#### Scenario: Unit starts Idle
- **WHEN** a unit's turn begins
- **THEN** its state SHALL be Idle

#### Scenario: Unit transitions to Moved after moving
- **WHEN** a unit completes movement
- **THEN** its state SHALL change to Moved

#### Scenario: Unit transitions to Acted after attacking
- **WHEN** a unit completes an attack action
- **THEN** its state SHALL change to Acted

#### Scenario: Dead state prevents all actions
- **WHEN** a unit's HP reaches 0
- **THEN** its state SHALL change to Dead and it SHALL be removed from the active unit list

#### Scenario: Poison deals damage each turn
- **WHEN** a unit is in Poison state at round end
- **THEN** it SHALL take poison damage

### Requirement: Unit has growth rates for level-up
Each unit SHALL have growth rates for HP, STR, MAG, SKL, SPD, DEF, RES, LUK that determine stat increases on level-up.

#### Scenario: Level-up grants random stat increases
- **WHEN** a unit levels up
- **THEN** each stat SHALL have a chance equal to its growth rate to increase by 1

#### Scenario: Zero growth rate
- **WHEN** a stat has growth_rate = 0
- **THEN** that stat SHALL never increase on level-up

### Requirement: Unit data is JSON-driven
Unit definitions SHALL be stored as JSON files in res://data/units/.

#### Scenario: Unit loaded from JSON
- **WHEN** the game loads a unit
- **THEN** it SHALL read the unit's JSON data and initialize the unit accordingly
