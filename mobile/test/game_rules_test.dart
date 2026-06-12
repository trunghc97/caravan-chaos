import 'dart:math' as math;

import 'package:caravan_chaos/game_rules.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('game rules', () {
    test('startingSpaces puts every caravan on the start space', () {
      final List<List<String>> spaces = startingSpaces(math.Random(7));

      expect(spaces, hasLength(trackSize));
      expect(spaces[0], unorderedEquals(gameCaravanIds));
      expect(
          spaces.skip(1).every((List<String> stack) => stack.isEmpty), isTrue);
    });

    test('moveChainInPlace moves the selected caravan and anything above it',
        () {
      final List<List<String>> spaces = _emptySpaces();
      spaces[2].addAll(<String>['saffron', 'manta', 'onyx']);

      final MoveResult result = moveChainInPlace(
        spaces: spaces,
        routeMarks: const <int, RouteMarkType>{},
        caravanId: 'manta',
        delta: 3,
      );

      expect(result.from, 2);
      expect(result.to, 5);
      expect(result.movedIds, <String>['manta', 'onyx']);
      expect(spaces[2], <String>['saffron']);
      expect(spaces[5], <String>['manta', 'onyx']);
      expect(standingsFor(spaces).first.id, 'onyx');
    });

    test('boost route mark advances a forward move one extra space', () {
      final List<List<String>> spaces = _emptySpaces();
      spaces[1].add('saffron');

      final MoveResult result = moveChainInPlace(
        spaces: spaces,
        routeMarks: const <int, RouteMarkType>{3: RouteMarkType.boost},
        caravanId: 'saffron',
        delta: 2,
      );

      expect(result.to, 4);
      expect(result.markText, 'qua oc dao +1');
      expect(spaces[4], <String>['saffron']);
    });

    test('snare route mark pulls a forward move back one space', () {
      final List<List<String>> spaces = _emptySpaces();
      spaces[1].add('glassback');

      final MoveResult result = moveChainInPlace(
        spaces: spaces,
        routeMarks: const <int, RouteMarkType>{3: RouteMarkType.snare},
        caravanId: 'glassback',
        delta: 2,
      );

      expect(result.to, 2);
      expect(result.markText, 'lac vao ao anh -1');
      expect(spaces[2], <String>['glassback']);
    });

    test('route marks do not trigger on backward movement', () {
      final List<List<String>> spaces = _emptySpaces();
      spaces[4].add('brasswing');

      final MoveResult result = moveChainInPlace(
        spaces: spaces,
        routeMarks: const <int, RouteMarkType>{3: RouteMarkType.boost},
        caravanId: 'brasswing',
        delta: -1,
      );

      expect(result.to, 3);
      expect(result.markText, isEmpty);
      expect(spaces[3], <String>['brasswing']);
    });

    test('forward moves land above target stack and backward moves land below',
        () {
      final List<List<String>> spaces = _emptySpaces();
      spaces[2].add('saffron');
      spaces[4].addAll(<String>['glassback', 'manta']);
      spaces[6].add('onyx');

      moveChainInPlace(
        spaces: spaces,
        routeMarks: const <int, RouteMarkType>{},
        caravanId: 'saffron',
        delta: 2,
      );

      expect(spaces[4], <String>['glassback', 'manta', 'saffron']);
      expect(standingsFor(spaces).first.id, 'onyx');

      moveChainInPlace(
        spaces: spaces,
        routeMarks: const <int, RouteMarkType>{},
        caravanId: 'onyx',
        delta: -2,
      );

      expect(spaces[4], <String>['onyx', 'glassback', 'manta', 'saffron']);
      expect(standingsFor(spaces).first.id, 'saffron');
    });

    test('stage and final payouts follow the top three standings', () {
      const Standing leader = Standing(id: 'onyx', position: 9, layer: 0);
      const Standing second = Standing(id: 'manta', position: 7, layer: 1);
      const Standing third = Standing(id: 'saffron', position: 7, layer: 0);

      expect(legPayout('onyx', leader, second), 8);
      expect(legPayout('manta', leader, second), 4);
      expect(legPayout('saffron', leader, second), 0);

      expect(finalPayout('onyx', leader, second, third), 14);
      expect(finalPayout('manta', leader, second, third), 7);
      expect(finalPayout('saffron', leader, second, third), 3);
    });
  });
}

List<List<String>> _emptySpaces() {
  return List<List<String>>.generate(trackSize, (_) => <String>[]);
}
