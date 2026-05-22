## 1. Main Flow Integration

- [x] 1.1 Audit GameState.phase transitions against actual scene switching, identify all inconsistencies
- [x] 1.2 Ensure every scene has a valid initial display state (no blank pages)
- [x] 1.3 Define and enforce scene responsibility boundaries in code (boot initializes only, menu handles only menu, etc.)
- [x] 1.4 Unify exit paths for story end, victory, defeat, and return-to-menu scenarios
- [x] 1.5 Add assertion checks in scene transition code to catch phase/scene mismatches
- [ ] 1.6 Manual test: boot → menu → story → battle → result → menu full loop without blank states or hangs

## 2. Battle Core Loop

- [x] 2.1 Implement player turn operation chain: select unit → show movement range → confirm move → action menu (attack/wait)
- [x] 2.2 Implement movement range visualization (highlight valid tiles, clear on selection/confirm)
- [x] 2.3 Implement attack range check and enemy targeting from selected unit
- [x] 2.4 Implement enemy AI turn: iterate units, priority-based target selection (kill > low HP > heal > approach)
- [x] 2.5 Implement turn switching logic (player → enemy → player) with unit action state reset
- [x] 2.6 Implement victory detection (all enemies defeated) and defeat detection (all player units defeated)
- [x] 2.7 Wire victory/defeat triggers to BattleController and route to result scene
- [x] 2.8 Cut clear responsibility boundaries between UnitActor, TurnManager, and BattleController
- [ ] 2.9 Manual test: complete player turn, enemy turn, full cycle, victory and defeat outcomes

## 3. UI System MVP

- [x] 3.1 Set up 1280x720 design resolution baseline for all UI scenes (project.godot configured)
- [x] 3.2 Configure anchor/stretch strategy to prevent drift on window resize (project.godot: canvas_items + keep)
- [x] 3.3 Refactor main menu UI to follow unified layout specification
- [x] 3.4 Refactor story dialog UI to follow unified layout specification
- [x] 3.5 Refactor battle HUD (unit info, turn counter, phase indicator) to follow unified specification
- [x] 3.6 Build action menu (attack/wait) and attack preview (hit rate, damage, crit) as UI panels
- [x] 3.7 Convert all UI communication to signal-based pattern (UI listens, does not get called directly)
- [x] 3.8 Define and enforce show/hide matrix for each UI panel across game states
- [ ] 3.9 Manual test: all UI panels visible at correct times, no overlaps, resize stability

## 4. Data and Resource Closure

- [x] 4.1 Audit all first-level JSON data files (units, weapons, jobs, skills, maps, stories) for completeness
- [x] 4.2 Implement JSON schema validation on data load (field existence, type checking)
- [x] 4.3 Ensure map data and battle generation logic correspond exactly (no hardcoded fallbacks)
- [x] 4.4 Ensure unit template fields match runtime state fields one-to-one
- [x] 4.5 Ensure story event IDs match actual logic references
- [x] 4.6 Define asset placeholder rules (acceptable vs. critical missing that must halt)
- [x] 4.7 Implement audio-missing degradation strategy (skip with warning, no crash)
- [ ] 4.8 Manual test: load all first-level data, verify battle generates correctly from data only

## 5. Save/Load Pipeline

- [x] 5.1 Define save schema boundary: global state vs battle runtime state
- [x] 5.2 Add version field to save schema and implement version-specific migration logic
- [x] 5.3 Implement "New Game" clean start flow
- [x] 5.4 Implement "Continue Game" load flow with appropriate scene restoration
- [ ] 5.5 Implement mid-battle save and restore (unit positions, HP, turn, phase) — deferred, needs battle state serialization
- [x] 5.6 Implement post-battle save (menu-level save, return to main menu on load)
- [x] 5.7 Add version upgrade rules document and unsupported version rejection
- [ ] 5.8 Manual test: new game, save mid-battle, load, continue, complete battle, save again, verify all

## 6. Verification and Constraints

- [x] 6.1 Create pre-modification checklist (scene contracts, data schema, main flow impact)
- [x] 6.2 Create pre-commit verification checklist (main flow test, battle formula test, scene contract)
- [x] 6.3 Build test coverage matrix mapping tests to systems (data schema, main flow, scene contract, combat formula)
- [x] 6.4 Create scene contract tests for each main flow scene (signals, exported methods, expected states)
- [x] 6.5 Add documentation requirement rules (scene contract changes, data schema changes, main flow changes)
- [x] 6.6 Document all scene interface contracts in a structured format
- [x] 6.7 Create the architecture constraint document (what can and cannot be modified outside each module)
- [ ] 6.8 Manual test: run all verifications against existing codebase, fix any pre-existing failures
