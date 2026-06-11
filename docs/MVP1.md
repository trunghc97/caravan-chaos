# MVP1 - Local Solo

MVP1 keeps the full game loop inside Flutter with plain Dart rules. The goal is a playable solo prototype before moving room state to the Go backend.

## Done

- Monorepo structure with Flutter app in `mobile/`.
- Plain Dart rules in `mobile/lib/game_rules.dart`.
- Five caravan race board with stacked chain movement.
- Wind draws, event cards, route marks, leg contracts, final contracts.
- Rival traders with coins, contracts, and route-mark reactions.
- Ordered local event ledger with sequence numbers.
- Reproducible local seed display and same-seed replay.
- Rule and widget tests for core mechanics.

## Next Before MVP2

- Add a compact end-game score breakdown.
- Add a short in-app solo setup screen for player name and bot count.
- Keep backend work limited to scaffolding until this local loop feels stable.
