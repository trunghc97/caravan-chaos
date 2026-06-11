# Caravan Chaos Prototype

Mobile-first web prototype for a race-betting caravan game inspired by broad board-game mechanics, with original theme, wording, tokens, and UI.

## Run

Open `index.html` directly, or serve the folder:

```sh
python3 -m http.server 4173
```

Then visit `http://localhost:4173/caravan-chaos/`.

## Current loop

- Five fantasy caravans race across a 16-space trade route.
- Drawing a wind seal moves one random caravan 1-3 spaces.
- If a caravan has other caravans above it in the same space, the moving chain is pulled along.
- Stage contracts pay on the current day leader and runner-up.
- Final contracts pay at the end of the race.
- Route marks add an oasis boost or mirage penalty to a selected space.
- Event cards add small twists such as night market profit, mirage detours, or catch-up movement.

## IP direction

- No Camel Up name, logos, box art, pyramid dice, original rulebook wording, or camel race presentation.
- Theme vocabulary is trade route, wind seals, contracts, route marks, caravans, and market days.
- Tokens are custom SVG silhouettes created for this prototype.
