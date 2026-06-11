# Caravan Chaos Mobile

Flutter prototype for Caravan Chaos.

## Run

```sh
flutter pub get
flutter run
```

## Prototype Scope

- Mobile-first Flutter UI.
- Plain Dart game rules in `lib/game_rules.dart` so mechanics can be tested and mirrored by a future server.
- Five original fantasy caravans with distinct colors and icons.
- Sixteen-space trade route board.
- Wind seal draw that moves one random caravan 1-3 spaces.
- Chain movement when a caravan pulls anything stacked above it.
- Oasis and mirage route marks.
- Stage and final contracts.
- Rival traders that react with contracts and route marks during solo play.
- Ordered local event ledger that mirrors the future realtime `serverSeq` shape.
- Replayable solo seeds for debugging local playtests.
