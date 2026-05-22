## ADDED Requirements

### Requirement: Tile has terrain properties
Every tile on the map SHALL have the following terrain properties: move_cost (int), avoid_bonus (int), defense_bonus (int), walkable (bool), height (int).

#### Scenario: Tile property defined
- **WHEN** a tile is placed on the map
- **THEN** it SHALL have all five terrain properties with valid values

#### Scenario: Non-walkable tile blocks movement
- **WHEN** a unit attempts to pathfind through a tile with walkable=false
- **THEN** the path SHALL exclude that tile

### Requirement: Map supports multiple terrain types
The system SHALL support at least 8 terrain types: 平原, 森林, 山地, 河流, 城堡, 室内, 火山, 雪地.

#### Scenario: Terrain type affects movement cost
- **WHEN** a unit moves across different terrain types
- **THEN** the move_cost SHALL be applied to movement calculation

### Requirement: Map supports special features
The map SHALL support blocking, terrain bonuses, height differences, destructible terrain, event points, teleport points, and extraction points.

#### Scenario: Unit receives terrain bonus
- **WHEN** a unit stands on a tile with avoid_bonus > 0 or defense_bonus > 0
- **THEN** the bonus SHALL be applied to combat calculations

#### Scenario: Teleport point transports unit
- **WHEN** a unit moves onto a teleport point
- **THEN** the unit SHALL be relocated to the linked destination tile

#### Scenario: Destructible terrain can be destroyed
- **WHEN** an attack hits destructible terrain
- **THEN** the terrain SHALL change to a destroyed state (walkable=true, no bonuses)

### Requirement: Map size supports up to 64x64
The map system SHALL support grid sizes up to 64x64 tiles.

#### Scenario: Large map loads correctly
- **WHEN** a 64x64 map is loaded
- **THEN** all tiles SHALL be rendered at 60 FPS

### Requirement: Map system uses Godot TileMap
The map SHALL be implemented using Godot's TileMap node.

#### Scenario: Tilemap renders tiles
- **WHEN** the battle scene loads
- **THEN** the TileMap SHALL render all tiles according to their assigned terrain types

### Requirement: Height differences affect combat
When attacking a target at a different height, the system SHALL apply height-based combat modifiers.

#### Scenario: Height advantage
- **WHEN** attacker height > defender height
- **THEN** attacker SHALL gain a hit bonus
