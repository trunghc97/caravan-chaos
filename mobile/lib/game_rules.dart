import 'dart:math' as math;

const int trackSize = 16;
const int finishSpace = trackSize - 1;
const int startingCoins = 24;
const int maxLegContracts = 2;
const int maxFinalContracts = 3;

const List<String> gameCaravanIds = <String>[
  'saffron',
  'glassback',
  'manta',
  'brasswing',
  'onyx',
];

enum RouteMarkType { boost, snare }

class Contract {
  const Contract(this.caravanId, this.day);

  final String caravanId;
  final int day;
}

class Rival {
  Rival({required this.name, required this.coins});

  final String name;
  int coins;
  bool routeUsed = false;
  final List<Contract> legContracts = <Contract>[];
  final List<Contract> finalContracts = <Contract>[];
}

class LocalGameEvent {
  const LocalGameEvent({
    required this.seq,
    required this.day,
    required this.actor,
    required this.kind,
    required this.message,
  });

  final int seq;
  final int day;
  final String actor;
  final String kind;
  final String message;
}

class Standing {
  const Standing({
    required this.id,
    required this.position,
    required this.layer,
  });

  final String id;
  final int position;
  final int layer;
}

class MoveResult {
  const MoveResult({
    required this.from,
    required this.to,
    required this.movedIds,
    this.markText = '',
  });

  final int from;
  final int to;
  final List<String> movedIds;
  final String markText;
}

class FoundCaravan {
  const FoundCaravan(this.position, this.layer);

  final int position;
  final int layer;
}

List<List<String>> startingSpaces(math.Random random) {
  final List<List<String>> spaces = List<List<String>>.generate(
    trackSize,
    (_) => <String>[],
  );
  spaces[0] = shuffled(gameCaravanIds, random);
  return spaces;
}

List<String> newWindBag() => List<String>.from(gameCaravanIds);

List<String> shuffled(List<String> items, math.Random random) {
  final List<String> copy = List<String>.from(items);
  for (int i = copy.length - 1; i > 0; i--) {
    final int j = random.nextInt(i + 1);
    final String temp = copy[i];
    copy[i] = copy[j];
    copy[j] = temp;
  }
  return copy;
}

String takeRandom(List<String> items, math.Random random) {
  final int index = random.nextInt(items.length);
  return items.removeAt(index);
}

MoveResult moveChainInPlace({
  required List<List<String>> spaces,
  required Map<int, RouteMarkType> routeMarks,
  required String caravanId,
  required int delta,
}) {
  final FoundCaravan found = findCaravan(spaces, caravanId);
  final List<String> moving = List<String>.from(
    spaces[found.position].sublist(found.layer),
  );
  spaces[found.position]
      .removeRange(found.layer, spaces[found.position].length);

  int target = (found.position + delta).clamp(0, finishSpace).toInt();
  String markText = '';

  if (delta > 0 && routeMarks.containsKey(target)) {
    final RouteMarkType mark = routeMarks[target]!;
    if (mark == RouteMarkType.boost) {
      target = (target + 1).clamp(0, finishSpace).toInt();
      markText = 'qua oc dao +1';
    } else {
      target = (target - 1).clamp(0, finishSpace).toInt();
      markText = 'lac vao ao anh -1';
    }
  }

  spaces[target].addAll(moving);
  return MoveResult(
    from: found.position,
    to: target,
    movedIds: moving,
    markText: markText,
  );
}

List<Standing> standingsFor(List<List<String>> spaces) {
  final List<Standing> standings = <Standing>[];
  for (int position = 0; position < spaces.length; position++) {
    final List<String> stack = spaces[position];
    for (int layer = 0; layer < stack.length; layer++) {
      standings
          .add(Standing(id: stack[layer], position: position, layer: layer));
    }
  }
  standings.sort((Standing a, Standing b) {
    final int positionCompare = b.position.compareTo(a.position);
    if (positionCompare != 0) {
      return positionCompare;
    }
    return b.layer.compareTo(a.layer);
  });
  return standings;
}

FoundCaravan findCaravan(List<List<String>> spaces, String caravanId) {
  for (int position = 0; position < spaces.length; position++) {
    final int layer = spaces[position].indexOf(caravanId);
    if (layer != -1) {
      return FoundCaravan(position, layer);
    }
  }
  throw StateError('Missing caravan $caravanId');
}

Standing weightedPick(List<Standing> items, math.Random random) {
  final List<Standing> pool = <Standing>[];
  for (int i = 0; i < items.length; i++) {
    final int weight = math.max(1, items.length - i);
    for (int j = 0; j < weight; j++) {
      pool.add(items[i]);
    }
  }
  return pool[random.nextInt(pool.length)];
}

int legPayout(String caravanId, Standing leader, Standing second) {
  if (caravanId == leader.id) {
    return 8;
  }
  if (caravanId == second.id) {
    return 4;
  }
  return 0;
}

int finalPayout(
  String caravanId,
  Standing leader,
  Standing second,
  Standing third,
) {
  if (caravanId == leader.id) {
    return 14;
  }
  if (caravanId == second.id) {
    return 7;
  }
  if (caravanId == third.id) {
    return 3;
  }
  return 0;
}

bool isRaceFinished(List<List<String>> spaces) {
  return spaces[finishSpace].isNotEmpty;
}
