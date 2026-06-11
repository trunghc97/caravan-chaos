import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'game_rules.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Caravan Chaos',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F4C5C),
        ),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const CaravanGamePage(),
    );
  }
}

class Caravan {
  const Caravan({
    required this.id,
    required this.name,
    required this.note,
    required this.color,
    required this.accent,
    required this.icon,
  });

  final String id;
  final String name;
  final String note;
  final Color color;
  final Color accent;
  final IconData icon;
}

class WindResult {
  const WindResult({
    required this.caravanId,
    required this.steps,
    this.markText = '',
  });

  final String caravanId;
  final int steps;
  final String markText;
}

const List<Caravan> caravans = <Caravan>[
  Caravan(
    id: 'saffron',
    name: 'Saffron Guild',
    note: 'gia vi',
    color: Color(0xFFE4572E),
    accent: Color(0xFFF2C14E),
    icon: Icons.spa_rounded,
  ),
  Caravan(
    id: 'glassback',
    name: 'Glassback Cart',
    note: 'kinh muoi',
    color: Color(0xFF0F4C5C),
    accent: Color(0xFF90E0EF),
    icon: Icons.diamond_outlined,
  ),
  Caravan(
    id: 'manta',
    name: 'Dune Manta',
    note: 'lua gio',
    color: Color(0xFF3D5A80),
    accent: Color(0xFFF2C14E),
    icon: Icons.air_rounded,
  ),
  Caravan(
    id: 'brasswing',
    name: 'Brasswing Wagon',
    note: 'dong ho',
    color: Color(0xFF2D936C),
    accent: Color(0xFFF2C14E),
    icon: Icons.settings_rounded,
  ),
  Caravan(
    id: 'onyx',
    name: 'Onyx Horn Cart',
    note: 'da dem',
    color: Color(0xFF5F4B8B),
    accent: Color(0xFFF7B267),
    icon: Icons.terrain_rounded,
  ),
];

const Map<int, String> routeLabels = <int, String>{
  0: 'Cho',
  3: 'Cong',
  6: 'Oc dao',
  9: 'Hem',
  12: 'Den',
  15: 'Dich',
};

const List<int> visualRouteOrder = <int>[
  15,
  14,
  13,
  12,
  8,
  9,
  10,
  11,
  7,
  6,
  5,
  4,
  0,
  1,
  2,
  3,
];

class CaravanGamePage extends StatefulWidget {
  const CaravanGamePage({super.key});

  @override
  State<CaravanGamePage> createState() => _CaravanGamePageState();
}

class _CaravanGamePageState extends State<CaravanGamePage> {
  late math.Random _random;

  int _activeTab = 0;
  int _seed = 0;
  int _coins = startingCoins;
  int _day = 1;
  int _selectedSpace = 5;
  bool _raceOver = false;
  bool _routeUsed = false;
  int _localSeq = 0;
  WindResult? _lastWind;
  String? _eventTitle;
  String? _eventText;

  late List<List<String>> _spaces;
  late List<String> _bag;
  List<Rival> _rivals = <Rival>[];
  final List<Contract> _legContracts = <Contract>[];
  final List<Contract> _finalContracts = <Contract>[];
  final List<LocalGameEvent> _log = <LocalGameEvent>[];
  Map<int, RouteMarkType> _routeMarks = <int, RouteMarkType>{};

  @override
  void initState() {
    super.initState();
    _seed = _nextSeed();
    _resetGame();
  }

  @override
  Widget build(BuildContext context) {
    final List<Standing> standings = _standings();
    final Caravan leader = _caravan(standings.first.id);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F4EC),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool wide = constraints.maxWidth >= 820;
            final Widget board = _buildBoard(leader);
            final Widget controls = _buildControls();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(14),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1120),
                  child: Column(
                    children: <Widget>[
                      _buildHeader(),
                      const SizedBox(height: 12),
                      if (wide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(child: board),
                            const SizedBox(width: 12),
                            SizedBox(width: 390, child: controls),
                          ],
                        )
                      else
                        Column(
                          children: <Widget>[
                            board,
                            const SizedBox(height: 12),
                            controls,
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: <Widget>[
        Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF0F4C5C),
            borderRadius: BorderRadius.circular(10),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                blurRadius: 24,
                color: Color(0x260F4C5C),
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.local_shipping_rounded,
            color: Colors.white,
            size: 27,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Caravan Chaos',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _raceOver ? 'Ket thuc' : 'Ngay $_day',
                style: const TextStyle(
                  color: Color(0xFF61717C),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0x1F17202A)),
          ),
          child: Row(
            children: <Widget>[
              Text(
                '$_coins',
                style: const TextStyle(
                  color: Color(0xFF0F4C5C),
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 5),
              const Text(
                'dinar',
                style: TextStyle(
                  color: Color(0xFF61717C),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBoard(Caravan leader) {
    return _Panel(
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[Color(0xFF0F4C5C), Color(0xFF3D5A80)],
              ),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                    child: _StripStat(label: 'Dan dau', value: leader.name)),
                Expanded(
                    child: _StripStat(label: 'Gio', value: '${_bag.length}/5')),
                const Expanded(child: _StripStat(label: 'Dich', value: 'O 15')),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: AspectRatio(
              aspectRatio: 1,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: trackSize,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemBuilder: (BuildContext context, int visualIndex) {
                  final int spaceIndex = visualRouteOrder[visualIndex];
                  return _SpaceTile(
                    index: spaceIndex,
                    label: routeLabels[spaceIndex] ?? 'O $spaceIndex',
                    stack: _spaces[spaceIndex],
                    routeMark: _routeMarks[spaceIndex],
                    selected: _selectedSpace == spaceIndex,
                    isStart: spaceIndex == 0,
                    isFinish: spaceIndex == finishSpace,
                    onTap: () => setState(() => _selectedSpace = spaceIndex),
                    caravanFor: _caravan,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return _Panel(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8),
            child: SegmentedButton<int>(
              segments: const <ButtonSegment<int>>[
                ButtonSegment<int>(value: 0, label: Text('Luot')),
                ButtonSegment<int>(value: 1, label: Text('Hop dong')),
                ButtonSegment<int>(value: 2, label: Text('So cai')),
              ],
              selected: <int>{_activeTab},
              onSelectionChanged: (Set<int> value) {
                setState(() => _activeTab = value.first);
              },
              showSelectedIcon: false,
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: <Widget>[
                _buildActionTab(),
                _buildContractsTab(),
                _buildLedgerTab(),
              ][_activeTab],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTab() {
    final String selectedLabel =
        routeLabels[_selectedSpace] ?? 'O $_selectedSpace';
    final bool routeDisabled = _raceOver ||
        _routeUsed ||
        _coins < 1 ||
        _selectedSpace <= 0 ||
        _selectedSpace >= finishSpace ||
        _routeMarks.containsKey(_selectedSpace);

    return Column(
      key: const ValueKey<int>(0),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (_raceOver) _EndBanner(summary: _finalSummary()),
        FilledButton.icon(
          onPressed: _raceOver ? null : () => setState(_drawWind),
          icon: const Icon(Icons.air_rounded),
          label: const Text('Rut gio'),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            textStyle: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
        const SizedBox(height: 9),
        Row(
          children: <Widget>[
            Expanded(
              child: OutlinedButton.icon(
                onPressed:
                    _raceOver || _coins < 2 ? null : () => setState(_drawEvent),
                icon: const Icon(Icons.auto_awesome_rounded),
                label: const Text('Su kien'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => setState(_resetGame),
                icon: const Icon(Icons.restart_alt_rounded),
                label: const Text('Choi lai'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: <Widget>[
            Expanded(child: _MiniStat(label: 'O chon', value: selectedLabel)),
            const SizedBox(width: 8),
            Expanded(
                child:
                    _MiniStat(label: 'HD', value: '${_legContracts.length}/2')),
            const SizedBox(width: 8),
            Expanded(
                child: _MiniStat(
                    label: 'Tuyen', value: _routeUsed ? 'Da dat' : 'Trong')),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: <Widget>[
            Expanded(child: _MiniStat(label: 'Seed', value: '$_seed')),
            const SizedBox(width: 8),
            Expanded(
                child: _MiniStat(label: 'Bot', value: '${_rivals.length}')),
          ],
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => setState(_startNewSeed),
          icon: const Icon(Icons.shuffle_rounded),
          label: const Text('Seed moi'),
        ),
        const SizedBox(height: 10),
        Row(
          children: <Widget>[
            Expanded(
              child: OutlinedButton.icon(
                onPressed: routeDisabled
                    ? null
                    : () =>
                        setState(() => _placeRouteMark(RouteMarkType.boost)),
                icon: const Icon(Icons.arrow_upward_rounded),
                label: const Text('Oc dao'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: routeDisabled
                    ? null
                    : () =>
                        setState(() => _placeRouteMark(RouteMarkType.snare)),
                icon: const Icon(Icons.arrow_downward_rounded),
                label: const Text('Ao anh'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildLastWind(),
        if (_eventTitle != null && _eventText != null) ...<Widget>[
          const SizedBox(height: 10),
          _InfoCard(
            title: _eventTitle!,
            body: _eventText!,
            icon: Icons.auto_awesome_rounded,
          ),
        ],
      ],
    );
  }

  Widget _buildLastWind() {
    final WindResult? last = _lastWind;
    if (last == null) {
      return const _InfoCard(
        title: 'Cho phong an',
        body: 'Thuong lo dang doi dot gio dau tien.',
        icon: Icons.hourglass_empty_rounded,
      );
    }

    final Caravan caravan = _caravan(last.caravanId);
    final String body = 'Gio day ${last.steps} o'
        '${last.markText.isEmpty ? '' : ', ${last.markText}'}.';

    return _InfoCard(
      title: caravan.name,
      body: body,
      icon: caravan.icon,
      color: caravan.color,
    );
  }

  Widget _buildContractsTab() {
    return Column(
      key: const ValueKey<int>(1),
      children: _standings().map((Standing standing) {
        final Caravan caravan = _caravan(standing.id);
        final bool canLeg = _canSignLeg(caravan.id);
        final bool canFinal = _canSignFinal(caravan.id);

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _RowCard(
            leading: _CaravanToken(caravan: caravan, size: 34),
            title: caravan.name,
            subtitle:
                'O ${standing.position} - tang ${standing.layer + 1} - ${caravan.note}',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _SmallAction(
                  label: 'Chang',
                  onPressed: canLeg
                      ? () => setState(() => _signLegContract(caravan.id))
                      : null,
                ),
                const SizedBox(width: 6),
                _SmallAction(
                  label: 'Cuoc',
                  filled: true,
                  onPressed: canFinal
                      ? () => setState(() => _signFinalContract(caravan.id))
                      : null,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLedgerTab() {
    final List<_ScoreLine> scores = <_ScoreLine>[
      _ScoreLine(
        name: 'Ban',
        coins: _coins,
        detail:
            '${_legContracts.length} chang - ${_finalContracts.length} cuoc',
      ),
      for (final Rival rival in _rivals)
        _ScoreLine(
          name: rival.name,
          coins: rival.coins,
          detail:
              '${rival.legContracts.length} chang - ${rival.finalContracts.length} cuoc',
        ),
    ]..sort((_ScoreLine a, _ScoreLine b) => b.coins.compareTo(a.coins));

    return Column(
      key: const ValueKey<int>(2),
      children: <Widget>[
        for (int i = 0; i < scores.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _RowCard(
              title: '${i + 1}. ${scores[i].name}',
              subtitle: scores[i].detail,
              trailing: Text(
                '${scores[i].coins}',
                style: const TextStyle(
                  color: Color(0xFF0F4C5C),
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        const SizedBox(height: 4),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 220),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: _log.length,
            separatorBuilder: (_, __) => const SizedBox(height: 6),
            itemBuilder: (BuildContext context, int index) {
              final LocalGameEvent event = _log[index];
              return Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0x0F0F4C5C),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '#${event.seq.toString().padLeft(3, '0')}  ${event.actor}  -  Ngay ${event.day}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF0F4C5C),
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      event.message,
                      style: const TextStyle(
                        color: Color(0xFF61717C),
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  int _nextSeed() {
    return DateTime.now().microsecondsSinceEpoch.remainder(999999);
  }

  void _startNewSeed() {
    _seed = _nextSeed();
    _resetGame();
  }

  void _resetGame() {
    _random = math.Random(_seed);
    _activeTab = 0;
    _coins = startingCoins;
    _day = 1;
    _selectedSpace = 5;
    _raceOver = false;
    _routeUsed = false;
    _localSeq = 0;
    _lastWind = null;
    _eventTitle = null;
    _eventText = null;
    _routeMarks = <int, RouteMarkType>{};
    _legContracts.clear();
    _finalContracts.clear();
    _log.clear();
    _spaces = startingSpaces(_random);
    _bag = newWindBag();
    _rivals = <Rival>[
      Rival(name: 'Nira', coins: 22),
      Rival(name: 'Bahir', coins: 22),
      Rival(name: 'Tala', coins: 22),
    ];
    _addLog('Cho mo cong. Cac doan buon xuat phat tu o 0. Seed $_seed.',
        kind: 'game_reset');
    _aiPrepareLeg();
  }

  void _drawWind() {
    if (_raceOver) {
      return;
    }
    if (_bag.isEmpty) {
      _resolveLeg(false);
      return;
    }

    final String caravanId = takeRandom(_bag, _random);
    final int steps = _random.nextInt(3) + 1;
    final String markText = _moveChain(caravanId, steps);
    _lastWind = WindResult(
      caravanId: caravanId,
      steps: steps,
      markText: markText,
    );
    _addLog(
      '${_caravan(caravanId).name} di $steps o'
      '${markText.isEmpty ? '' : ', $markText'}.',
      actor: 'Ban',
      kind: 'draw_wind',
    );

    if (_isRaceFinished()) {
      _resolveLeg(true);
    } else if (_bag.isEmpty) {
      _resolveLeg(false);
    } else {
      _runBotMarket();
    }
  }

  void _drawEvent() {
    if (_raceOver || _coins < 2) {
      return;
    }
    _coins -= 2;
    final int eventIndex = _random.nextInt(4);

    if (eventIndex == 0) {
      _eventTitle = 'Gia vi vo thung';
      _eventText = 'Doan cuoi duoc day them 2 o.';
      final Standing last = _standings().last;
      _moveChain(last.id, 2);
      _addLog('${_caravan(last.id).name} bam mui gia vi, tien 2 o.',
          actor: 'Ban', kind: 'event_card');
    } else if (eventIndex == 1) {
      _eventTitle = 'Tram ao anh';
      _eventText = 'Doan dan dau lui 1 o.';
      final Standing first = _standings().first;
      _moveChain(first.id, -1);
      _addLog('${_caravan(first.id).name} vong qua ao anh, lui 1 o.',
          actor: 'Ban', kind: 'event_card');
    } else if (eventIndex == 2) {
      _eventTitle = 'Phien cho dem';
      _eventText = 'Ban nhan 4 dinar, doi thu gan nhat nhan 2.';
      _coins += 4;
      final List<Rival> sortedRivals = List<Rival>.from(_rivals)
        ..sort((Rival a, Rival b) => b.coins.compareTo(a.coins));
      final Rival rival = sortedRivals.first;
      rival.coins += 2;
      _addLog('Phien cho dem sinh loi: ban +4, ${rival.name} +2.',
          actor: 'Ban', kind: 'event_card');
    } else {
      _eventTitle = 'Duong kinh';
      _eventText = 'Mot o truoc doan cuoi thanh oc dao.';
      final Standing last = _standings().last;
      final int target = math.min(finishSpace - 1, last.position + 1);
      if (target > 0 && !_routeMarks.containsKey(target)) {
        _routeMarks[target] = RouteMarkType.boost;
        _addLog('Duong kinh mo o o $target.', actor: 'Ban', kind: 'event_card');
      } else {
        _coins += 2;
        _addLog('Duong kinh da dong, ban thu lai 2 dinar.',
            actor: 'Ban', kind: 'event_card');
      }
    }

    if (_isRaceFinished()) {
      _resolveLeg(true);
    } else {
      _runBotMarket();
    }
  }

  void _placeRouteMark(RouteMarkType type) {
    _coins -= 1;
    _routeUsed = true;
    _routeMarks[_selectedSpace] = type;
    _addLog(
      '${type == RouteMarkType.boost ? 'Oc dao' : 'Ao anh'} dat o o $_selectedSpace.',
      actor: 'Ban',
      kind: 'route_mark',
    );
    _runBotMarket();
  }

  void _signLegContract(String caravanId) {
    if (!_canSignLeg(caravanId)) {
      return;
    }
    _coins -= 2;
    _legContracts.add(Contract(caravanId, _day));
    _addLog('Ky hop dong chang cho ${_caravan(caravanId).name}.',
        actor: 'Ban', kind: 'leg_contract');
    _runBotMarket();
  }

  void _signFinalContract(String caravanId) {
    if (!_canSignFinal(caravanId)) {
      return;
    }
    _coins -= 1;
    _finalContracts.add(Contract(caravanId, _day));
    _addLog('Giu hop dong chung cuoc cho ${_caravan(caravanId).name}.',
        actor: 'Ban', kind: 'final_contract');
    _runBotMarket();
  }

  void _runBotMarket() {
    if (_raceOver) {
      return;
    }

    for (final Rival rival in _rivals) {
      if (_random.nextDouble() > 0.58) {
        continue;
      }

      final double roll = _random.nextDouble();
      final List<bool Function()> actions = roll < 0.42
          ? <bool Function()>[
              () => _tryRivalLegContract(rival),
              () => _tryRivalRouteMark(rival),
              () => _tryRivalFinalContract(rival),
            ]
          : roll < 0.74
              ? <bool Function()>[
                  () => _tryRivalFinalContract(rival),
                  () => _tryRivalRouteMark(rival),
                  () => _tryRivalLegContract(rival),
                ]
              : <bool Function()>[
                  () => _tryRivalRouteMark(rival),
                  () => _tryRivalLegContract(rival),
                  () => _tryRivalFinalContract(rival),
                ];

      for (final bool Function() action in actions) {
        if (action()) {
          break;
        }
      }
    }
  }

  bool _tryRivalLegContract(Rival rival) {
    if (rival.coins < 2 || rival.legContracts.length >= maxLegContracts) {
      return false;
    }

    final List<Standing> candidates = _standings()
        .take(4)
        .where((Standing standing) => !rival.legContracts
            .any((Contract contract) => contract.caravanId == standing.id))
        .toList();
    if (candidates.isEmpty) {
      return false;
    }

    final Standing target = weightedPick(candidates, _random);
    rival.coins -= 2;
    rival.legContracts.add(Contract(target.id, _day));
    _addLog('Ky hop dong chang cho ${_caravan(target.id).name}.',
        actor: rival.name, kind: 'bot_leg_contract');
    return true;
  }

  bool _tryRivalFinalContract(Rival rival) {
    if (rival.coins < 1 || rival.finalContracts.length >= maxFinalContracts) {
      return false;
    }

    final List<Standing> candidates = _standings()
        .where((Standing standing) => !rival.finalContracts
            .any((Contract contract) => contract.caravanId == standing.id))
        .toList();
    if (candidates.isEmpty) {
      return false;
    }

    final Standing target = weightedPick(candidates, _random);
    rival.coins -= 1;
    rival.finalContracts.add(Contract(target.id, _day));
    _addLog('Giu hop dong chung cuoc cho ${_caravan(target.id).name}.',
        actor: rival.name, kind: 'bot_final_contract');
    return true;
  }

  bool _tryRivalRouteMark(Rival rival) {
    if (rival.routeUsed || rival.coins < 1) {
      return false;
    }

    final List<Standing> standings = _standings();
    final Standing? favorite = _standingForRivalTarget(rival, standings);
    final RouteMarkType type =
        favorite == null ? RouteMarkType.snare : RouteMarkType.boost;
    final int preferred =
        favorite == null ? standings.first.position + 1 : favorite.position + 1;
    final int? space = _nearestOpenRouteSpace(preferred);
    if (space == null) {
      return false;
    }

    rival.coins -= 1;
    rival.routeUsed = true;
    _routeMarks[space] = type;
    _addLog(
        '${type == RouteMarkType.boost ? 'Oc dao' : 'Ao anh'} dat o o $space.',
        actor: rival.name,
        kind: 'bot_route_mark');
    return true;
  }

  Standing? _standingForRivalTarget(Rival rival, List<Standing> standings) {
    final List<Contract> targets = <Contract>[
      ...rival.legContracts,
      ...rival.finalContracts,
    ];
    for (final Contract contract in targets) {
      for (final Standing standing in standings) {
        if (standing.id == contract.caravanId) {
          return standing;
        }
      }
    }
    return null;
  }

  int? _nearestOpenRouteSpace(int preferred) {
    final int center = preferred.clamp(1, finishSpace - 1).toInt();
    for (int offset = 0; offset < finishSpace; offset++) {
      final List<int> candidates = <int>[
        center + offset,
        center - offset,
      ];
      for (final int candidate in candidates) {
        if (candidate > 0 &&
            candidate < finishSpace &&
            !_routeMarks.containsKey(candidate)) {
          return candidate;
        }
      }
    }
    return null;
  }

  String _moveChain(String caravanId, int delta) {
    final MoveResult result = moveChainInPlace(
      spaces: _spaces,
      routeMarks: _routeMarks,
      caravanId: caravanId,
      delta: delta,
    );
    return result.markText;
  }

  void _resolveLeg(bool isFinal) {
    final List<Standing> standings = _standings();
    final Standing leader = standings[0];
    final Standing second = standings[1];
    final Standing third = standings[2];

    final int playerPayout = _legContracts.fold<int>(
      0,
      (int total, Contract contract) =>
          total + legPayout(contract.caravanId, leader, second),
    );
    if (playerPayout > 0) {
      _coins += playerPayout;
      _addLog('Hop dong chang tra $playerPayout dinar cho ban.',
          kind: 'leg_payout');
    } else if (_legContracts.isNotEmpty) {
      _addLog('Hop dong chang cua ban khong trung.', kind: 'leg_payout');
    }

    for (final Rival rival in _rivals) {
      rival.coins += rival.legContracts.fold<int>(
        0,
        (int total, Contract contract) =>
            total + legPayout(contract.caravanId, leader, second),
      );
    }

    if (isFinal) {
      _resolveFinalContracts(leader, second, third);
      _raceOver = true;
      _activeTab = 2;
      _addLog('${_caravan(leader.id).name} cham cong dich. Cuoc dua ket thuc.',
          kind: 'race_finished');
      return;
    }

    _day += 1;
    _bag = newWindBag();
    _eventTitle = null;
    _eventText = null;
    _lastWind = null;
    _routeMarks = <int, RouteMarkType>{};
    _routeUsed = false;
    _legContracts.clear();
    for (final Rival rival in _rivals) {
      rival.legContracts.clear();
      rival.routeUsed = false;
    }
    _aiPrepareLeg();
    _addLog('Ngay $_day bat dau. Hop dong chang duoc mo lai.',
        kind: 'leg_started');
  }

  void _resolveFinalContracts(
      Standing leader, Standing second, Standing third) {
    final int playerPayout = _finalContracts.fold<int>(
      0,
      (int total, Contract contract) =>
          total + finalPayout(contract.caravanId, leader, second, third),
    );
    _coins += playerPayout;
    _addLog('Hop dong chung cuoc tra $playerPayout dinar cho ban.',
        kind: 'final_payout');

    for (final Rival rival in _rivals) {
      rival.coins += rival.finalContracts.fold<int>(
        0,
        (int total, Contract contract) =>
            total + finalPayout(contract.caravanId, leader, second, third),
      );
    }
  }

  void _aiPrepareLeg() {
    final List<Standing> standings = _standings();
    for (final Rival rival in _rivals) {
      if (rival.coins >= 2) {
        final Standing target =
            weightedPick(standings.take(4).toList(), _random);
        rival.coins -= 2;
        rival.legContracts.add(Contract(target.id, _day));
      }

      if (rival.finalContracts.length < maxFinalContracts &&
          rival.coins >= 1 &&
          _random.nextDouble() > 0.42) {
        final Standing target = weightedPick(standings, _random);
        final bool exists =
            rival.finalContracts.any((Contract c) => c.caravanId == target.id);
        if (!exists) {
          rival.coins -= 1;
          rival.finalContracts.add(Contract(target.id, _day));
        }
      }
    }
  }

  bool _canSignLeg(String caravanId) {
    return !_raceOver &&
        _coins >= 2 &&
        _legContracts.length < maxLegContracts &&
        !_legContracts
            .any((Contract contract) => contract.caravanId == caravanId);
  }

  bool _canSignFinal(String caravanId) {
    return !_raceOver &&
        _coins >= 1 &&
        _finalContracts.length < maxFinalContracts &&
        !_finalContracts
            .any((Contract contract) => contract.caravanId == caravanId);
  }

  List<Standing> _standings() {
    return standingsFor(_spaces);
  }

  Caravan _caravan(String id) {
    return caravans.firstWhere((Caravan caravan) => caravan.id == id);
  }

  bool _isRaceFinished() {
    return isRaceFinished(_spaces);
  }

  String _finalSummary() {
    final List<_ScoreLine> scores = <_ScoreLine>[
      _ScoreLine(name: 'Ban', coins: _coins, detail: ''),
      for (final Rival rival in _rivals)
        _ScoreLine(name: rival.name, coins: rival.coins, detail: ''),
    ]..sort((_ScoreLine a, _ScoreLine b) => b.coins.compareTo(a.coins));
    return '${scores.first.name} thang phien cho voi ${scores.first.coins} dinar.';
  }

  void _addLog(
    String message, {
    String actor = 'He thong',
    String kind = 'note',
  }) {
    _localSeq += 1;
    _log.insert(
      0,
      LocalGameEvent(
        seq: _localSeq,
        day: _day,
        actor: actor,
        kind: kind,
        message: message,
      ),
    );
    if (_log.length > 30) {
      _log.removeRange(30, _log.length);
    }
  }
}

class _ScoreLine {
  const _ScoreLine({
    required this.name,
    required this.coins,
    required this.detail,
  });

  final String name;
  final int coins;
  final String detail;
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x1A17202A)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            blurRadius: 36,
            color: Color(0x240F4C5C),
            offset: Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: child,
      ),
    );
  }
}

class _StripStat extends StatelessWidget {
  const _StripStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xB3FFFFFF),
            fontSize: 10,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _SpaceTile extends StatelessWidget {
  const _SpaceTile({
    required this.index,
    required this.label,
    required this.stack,
    required this.selected,
    required this.isStart,
    required this.isFinish,
    required this.onTap,
    required this.caravanFor,
    this.routeMark,
  });

  final int index;
  final String label;
  final List<String> stack;
  final RouteMarkType? routeMark;
  final bool selected;
  final bool isStart;
  final bool isFinish;
  final VoidCallback onTap;
  final Caravan Function(String id) caravanFor;

  @override
  Widget build(BuildContext context) {
    final Color background = isFinish
        ? const Color(0xFF0F4C5C)
        : isStart
            ? const Color(0xFFE9F6EF)
            : const Color(0xFFF9FBFA);
    final Color foreground = isFinish ? Colors.white : const Color(0xFF17202A);

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        borderRadius: BorderRadius.circular(9),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color:
                  selected ? const Color(0xFF0F4C5C) : const Color(0x1F17202A),
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(
                    '$index',
                    style: TextStyle(
                      color: foreground,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: foreground.withOpacity(0.68),
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  if (routeMark != null) _RouteBadge(type: routeMark!),
                ],
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: _TokenStack(
                    ids: stack,
                    caravanFor: caravanFor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TokenStack extends StatelessWidget {
  const _TokenStack({required this.ids, required this.caravanFor});

  final List<String> ids;
  final Caravan Function(String id) caravanFor;

  @override
  Widget build(BuildContext context) {
    if (ids.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double size = ids.length > 3 ? 23 : 28;
        final double overlap = ids.length > 3 ? 7 : 9;
        final double height = math.min(
          constraints.maxHeight,
          size + overlap * (ids.length - 1),
        );

        return SizedBox(
          height: height,
          width: size + 8,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: <Widget>[
              for (int i = 0; i < ids.length; i++)
                Positioned(
                  bottom: math.min(height - size, i * overlap),
                  child: _CaravanToken(
                    caravan: caravanFor(ids[i]),
                    size: size,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _CaravanToken extends StatelessWidget {
  const _CaravanToken({required this.caravan, required this.size});

  final Caravan caravan;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: caravan.color,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: Colors.white, width: 1.6),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            blurRadius: 8,
            color: Color(0x2617202A),
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        caravan.icon,
        color: caravan.accent,
        size: size * 0.62,
      ),
    );
  }
}

class _RouteBadge extends StatelessWidget {
  const _RouteBadge({required this.type});

  final RouteMarkType type;

  @override
  Widget build(BuildContext context) {
    final bool boost = type == RouteMarkType.boost;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: boost ? const Color(0xFF2D936C) : const Color(0xFFE4572E),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        boost ? '+1' : '-1',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: const Color(0x0F0F4C5C),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0x120F4C5C)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF61717C),
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF17202A),
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.body,
    required this.icon,
    this.color = const Color(0xFF0F4C5C),
  });

  final String title;
  final String body;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0x1F17202A)),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: const TextStyle(
                    color: Color(0xFF61717C),
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EndBanner extends StatelessWidget {
  const _EndBanner({required this.summary});

  final String summary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: _InfoCard(
        title: 'Phien cho khep lai',
        body: summary,
        icon: Icons.flag_rounded,
        color: const Color(0xFFE4572E),
      ),
    );
  }
}

class _RowCard extends StatelessWidget {
  const _RowCard({
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.leading,
  });

  final Widget? leading;
  final String title;
  final String subtitle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0x1F17202A)),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        children: <Widget>[
          if (leading != null) ...<Widget>[
            leading!,
            const SizedBox(width: 9),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF61717C),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          trailing,
        ],
      ),
    );
  }
}

class _SmallAction extends StatelessWidget {
  const _SmallAction({
    required this.label,
    required this.onPressed,
    this.filled = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    if (filled) {
      return FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          minimumSize: const Size(58, 34),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
        ),
        child: Text(label),
      );
    }

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(58, 34),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
      ),
      child: Text(label),
    );
  }
}
