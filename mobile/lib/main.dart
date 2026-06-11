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

const int boardGridSize = 5;

const List<_BoardSlot> _loopBoardSlots = <_BoardSlot>[
  _BoardSlot(space: 0, row: 4, column: 0),
  _BoardSlot(space: 1, row: 4, column: 1),
  _BoardSlot(space: 2, row: 4, column: 2),
  _BoardSlot(space: 3, row: 4, column: 3),
  _BoardSlot(space: 4, row: 4, column: 4),
  _BoardSlot(space: 5, row: 3, column: 4),
  _BoardSlot(space: 6, row: 2, column: 4),
  _BoardSlot(space: 7, row: 1, column: 4),
  _BoardSlot(space: 8, row: 0, column: 4),
  _BoardSlot(space: 9, row: 0, column: 3),
  _BoardSlot(space: 10, row: 0, column: 2),
  _BoardSlot(space: 11, row: 0, column: 1),
  _BoardSlot(space: 12, row: 0, column: 0),
  _BoardSlot(space: 13, row: 1, column: 0),
  _BoardSlot(space: 14, row: 2, column: 0),
  _BoardSlot(space: 15, row: 3, column: 0),
];

const Color _ink = Color(0xFF17202A);
const Color _muted = Color(0xFF66737A);
const Color _marketTeal = Color(0xFF0F4C5C);
const Color _deepIndigo = Color(0xFF263858);
const Color _spice = Color(0xFFE4572E);
const Color _sunGold = Color(0xFFF2C14E);
const Color _oasisGreen = Color(0xFF2D936C);
const Color _sandLight = Color(0xFFF9E8C7);
const Color _paper = Color(0xFFFFFAEE);

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
      backgroundColor: _sandLight,
      body: Stack(
        children: <Widget>[
          const Positioned.fill(
            child: CustomPaint(painter: _DesertBackdropPainter()),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final bool wide = constraints.maxWidth >= 820;
                final double? boardMaxWidth = wide
                    ? math.max(
                        440,
                        math.min(620, constraints.maxHeight - 200),
                      )
                    : null;
                final Widget board = _buildBoard(
                  leader,
                  maxWidth: boardMaxWidth,
                );
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
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.topLeft,
                                    child: board,
                                  ),
                                ),
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
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _paper.withOpacity(0.95),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x33B98543)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            blurRadius: 28,
            color: Color(0x2917202A),
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[_marketTeal, _deepIndigo],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  blurRadius: 20,
                  color: Color(0x330F4C5C),
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.local_shipping_rounded,
              color: _sunGold,
              size: 28,
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
                    color: _ink,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 5),
                Wrap(
                  spacing: 6,
                  runSpacing: 5,
                  children: <Widget>[
                    _HeaderChip(
                      icon: Icons.wb_sunny_rounded,
                      label: _raceOver ? 'Ket thuc' : 'Ngay $_day',
                    ),
                    _HeaderChip(
                      icon: Icons.air_rounded,
                      label: '${_bag.length}/5 gio',
                    ),
                    const _HeaderChip(
                      icon: Icons.flag_rounded,
                      label: 'Dich 15',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3C7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0x55B98543)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(Icons.toll_rounded, color: _spice, size: 19),
                const SizedBox(width: 6),
                Text(
                  '$_coins',
                  style: const TextStyle(
                    color: _marketTeal,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 5),
                const Text(
                  'dinar',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoard(Caravan leader, {double? maxWidth}) {
    final Widget board = _Panel(
      padding: EdgeInsets.zero,
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: <Color>[_marketTeal, _deepIndigo],
              ),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: _StripStat(
                    label: 'Dan dau',
                    value: leader.name,
                    icon: leader.icon,
                  ),
                ),
                Expanded(
                  child: _StripStat(
                    label: 'Phong an',
                    value: '${_bag.length}/5',
                    icon: Icons.air_rounded,
                  ),
                ),
                const Expanded(
                  child: _StripStat(
                    label: 'Cong dich',
                    value: 'O 15',
                    icon: Icons.flag_rounded,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[Color(0xFFFFE2A6), Color(0xFFF5C16F)],
              ),
            ),
            child: AspectRatio(
              aspectRatio: 1,
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final double gap = constraints.maxWidth < 460 ? 6 : 8;
                  final double cell =
                      (constraints.maxWidth - gap * (boardGridSize - 1)) /
                          boardGridSize;
                  final double centerOffset = cell + gap;
                  final double centerSize = cell * 3 + gap * 2;

                  return Stack(
                    children: <Widget>[
                      const Positioned.fill(
                        child: CustomPaint(painter: _TradeRoutePainter()),
                      ),
                      Positioned(
                        left: centerOffset,
                        top: centerOffset,
                        width: centerSize,
                        height: centerSize,
                        child: _buildBoardActionHub(),
                      ),
                      for (final _BoardSlot slot in _loopBoardSlots)
                        Positioned(
                          left: slot.column * (cell + gap),
                          top: slot.row * (cell + gap),
                          width: cell,
                          height: cell,
                          child: _SpaceTile(
                            index: slot.space,
                            label: routeLabels[slot.space] ?? 'O ${slot.space}',
                            stack: _spaces[slot.space],
                            routeMark: _routeMarks[slot.space],
                            selected: _selectedSpace == slot.space,
                            isStart: slot.space == 0,
                            isFinish: slot.space == finishSpace,
                            onTap: () =>
                                setState(() => _selectedSpace = slot.space),
                            caravanFor: _caravan,
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );

    if (maxWidth == null) {
      return board;
    }

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: board,
    );
  }

  Widget _buildControls() {
    return _Panel(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
            child: Theme(
              data: Theme.of(context).copyWith(
                colorScheme: Theme.of(context).colorScheme.copyWith(
                      primary: _marketTeal,
                      secondaryContainer: const Color(0xFFFFE8AF),
                      onSecondaryContainer: _ink,
                    ),
              ),
              child: SegmentedButton<int>(
                segments: const <ButtonSegment<int>>[
                  ButtonSegment<int>(
                    value: 0,
                    icon: Icon(Icons.touch_app_rounded),
                    label: Text('Luot'),
                  ),
                  ButtonSegment<int>(
                    value: 1,
                    icon: Icon(Icons.receipt_long_rounded),
                    label: Text('Hop dong'),
                  ),
                  ButtonSegment<int>(
                    value: 2,
                    icon: Icon(Icons.leaderboard_rounded),
                    label: Text('So cai'),
                  ),
                ],
                selected: <int>{_activeTab},
                onSelectionChanged: (Set<int> value) {
                  setState(() => _activeTab = value.first);
                },
                showSelectedIcon: false,
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0x22B98543)),
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

  Widget _buildBoardActionHub() {
    final String selectedLabel =
        routeLabels[_selectedSpace] ?? 'O $_selectedSpace';
    final bool routeDisabled = _routeMarkDisabled;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _paper.withOpacity(0.96),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x55B98543), width: 1.2),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            blurRadius: 22,
            color: Color(0x2B17202A),
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool compact = constraints.maxWidth < 290;
          final double buttonHeight = compact ? 34 : 40;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const Icon(Icons.explore_rounded, color: _spice, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Lenh thuong lo',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _ink,
                        fontSize: compact ? 12 : 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: compact ? 6 : 8),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _BoardMiniStat(
                      label: 'O chon',
                      value: selectedLabel,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _BoardMiniStat(
                      label: 'Gio',
                      value: '${_bag.length}/5',
                    ),
                  ),
                ],
              ),
              SizedBox(height: compact ? 7 : 9),
              SizedBox(
                height: buttonHeight + 6,
                child: FilledButton.icon(
                  onPressed: _raceOver ? null : () => setState(_drawWind),
                  icon: const Icon(Icons.air_rounded),
                  label: const Text('Rut gio'),
                  style: FilledButton.styleFrom(
                    backgroundColor: _spice,
                    foregroundColor: Colors.white,
                    textStyle: TextStyle(
                      fontSize: compact ? 13 : 15,
                      fontWeight: FontWeight.w900,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              SizedBox(height: compact ? 6 : 8),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _BoardActionButton(
                      icon: Icons.auto_awesome_rounded,
                      label: 'Su kien',
                      color: _marketTeal,
                      height: buttonHeight,
                      onPressed: _raceOver || _coins < 2
                          ? null
                          : () => setState(_drawEvent),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _BoardActionButton(
                      icon: Icons.restart_alt_rounded,
                      label: 'Lai',
                      color: _marketTeal,
                      height: buttonHeight,
                      onPressed: () => setState(_resetGame),
                    ),
                  ),
                ],
              ),
              SizedBox(height: compact ? 6 : 8),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _BoardActionButton(
                      icon: Icons.arrow_upward_rounded,
                      label: 'Oc dao',
                      color: _oasisGreen,
                      height: buttonHeight,
                      onPressed: routeDisabled
                          ? null
                          : () => setState(
                              () => _placeRouteMark(RouteMarkType.boost)),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _BoardActionButton(
                      icon: Icons.arrow_downward_rounded,
                      label: 'Ao anh',
                      color: _spice,
                      height: buttonHeight,
                      onPressed: routeDisabled
                          ? null
                          : () => setState(
                              () => _placeRouteMark(RouteMarkType.snare)),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  ButtonStyle _marketButtonStyle({Color color = _marketTeal}) {
    return OutlinedButton.styleFrom(
      foregroundColor: color,
      side: BorderSide(color: color.withOpacity(0.45)),
      backgroundColor: const Color(0xFFFFF9EA),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      textStyle: const TextStyle(fontWeight: FontWeight.w900),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  Widget _buildActionTab() {
    final String selectedLabel =
        routeLabels[_selectedSpace] ?? 'O $_selectedSpace';

    return Column(
      key: const ValueKey<int>(0),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (_raceOver) _EndBanner(summary: _finalSummary()),
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
        Row(
          children: <Widget>[
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => setState(_startNewSeed),
                icon: const Icon(Icons.shuffle_rounded),
                label: const Text('Seed moi'),
                style: _marketButtonStyle(),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => setState(_resetGame),
                icon: const Icon(Icons.restart_alt_rounded),
                label: const Text('Choi lai'),
                style: _marketButtonStyle(),
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

  bool get _routeMarkDisabled {
    return _raceOver ||
        _routeUsed ||
        _coins < 1 ||
        _selectedSpace <= 0 ||
        _selectedSpace >= finishSpace ||
        _routeMarks.containsKey(_selectedSpace);
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
                  color: const Color(0xFFFFF4D3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0x22B98543)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '#${event.seq.toString().padLeft(3, '0')}  ${event.actor}  -  Ngay ${event.day}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _marketTeal,
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

class _BoardSlot {
  const _BoardSlot({
    required this.space,
    required this.row,
    required this.column,
  });

  final int space;
  final int row;
  final int column;
}

class _DesertBackdropPainter extends CustomPainter {
  const _DesertBackdropPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final Paint sky = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          Color(0xFFFFE7AD),
          Color(0xFFF5C987),
          Color(0xFFFFF6DE),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, sky);

    final Paint sun = Paint()..color = const Color(0x88F2C14E);
    canvas.drawCircle(Offset(size.width * 0.84, size.height * 0.12), 58, sun);

    final Paint farDune = Paint()..color = const Color(0x55E8AD59);
    final Path far = Path()
      ..moveTo(0, size.height * 0.58)
      ..quadraticBezierTo(size.width * 0.22, size.height * 0.50,
          size.width * 0.46, size.height * 0.58)
      ..quadraticBezierTo(
          size.width * 0.72, size.height * 0.68, size.width, size.height * 0.55)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(far, farDune);

    final Paint nearDune = Paint()..color = const Color(0x77D99043);
    final Path near = Path()
      ..moveTo(0, size.height * 0.76)
      ..quadraticBezierTo(size.width * 0.28, size.height * 0.64,
          size.width * 0.57, size.height * 0.75)
      ..quadraticBezierTo(
          size.width * 0.82, size.height * 0.84, size.width, size.height * 0.72)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(near, nearDune);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TradeRoutePainter extends CustomPainter {
  const _TradeRoutePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double gap = size.width < 460 ? 6 : 8;
    final double cell =
        (size.width - gap * (boardGridSize - 1)) / boardGridSize;
    final List<Offset> centers = _loopBoardSlots.map((_BoardSlot slot) {
      return Offset(
        slot.column * (cell + gap) + cell / 2,
        slot.row * (cell + gap) + cell / 2,
      );
    }).toList();

    final Path path = Path()..moveTo(centers.first.dx, centers.first.dy);
    for (final Offset center in centers.skip(1)) {
      path.lineTo(center.dx, center.dy);
    }
    path.close();

    final Paint shadow = Paint()
      ..color = const Color(0x33B98543)
      ..strokeWidth = 15
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, shadow);

    final Paint trail = Paint()
      ..color = const Color(0xAAFFF6DB)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, trail);

    final Paint dots = Paint()..color = const Color(0x55E4572E);
    for (final Offset center in centers) {
      canvas.drawCircle(center, 4, dots);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.child,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _paper.withOpacity(0.94),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x33B98543)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            blurRadius: 30,
            color: Color(0x2417202A),
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

class _StripStat extends StatelessWidget {
  const _StripStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, color: _sunGold, size: 18),
        const SizedBox(width: 7),
        Expanded(
          child: Column(
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
          ),
        ),
      ],
    );
  }
}

class _HeaderChip extends StatelessWidget {
  const _HeaderChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1C6),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x33B98543)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 13, color: _spice),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: _ink,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
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
    final List<Color> fill = isFinish
        ? <Color>[_marketTeal, _deepIndigo]
        : isStart
            ? const <Color>[Color(0xFFE8F7D9), Color(0xFFCBEFBD)]
            : const <Color>[Color(0xFFFFF5D7), Color(0xFFEEC477)];
    final Color foreground = isFinish ? Colors.white : _ink;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: fill,
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? _spice : const Color(0x44B98543),
              width: selected ? 2.4 : 1,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                blurRadius: selected ? 16 : 7,
                color: selected
                    ? const Color(0x55E4572E)
                    : const Color(0x1D17202A),
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    height: 20,
                    width: 20,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isFinish
                          ? Colors.white.withOpacity(0.16)
                          : Colors.white.withOpacity(0.62),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '$index',
                      style: TextStyle(
                        color: foreground,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[caravan.color.withOpacity(0.95), caravan.color],
        ),
        shape: BoxShape.circle,
        border: Border.all(color: _paper, width: 1.8),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            blurRadius: 10,
            color: Color(0x3317202A),
            offset: Offset(0, 5),
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
        color: boost ? _oasisGreen : _spice,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
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

class _BoardMiniStat extends StatelessWidget {
  const _BoardMiniStat({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1C6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0x33B98543)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _muted,
              fontSize: 9,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _ink,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _BoardActionButton extends StatelessWidget {
  const _BoardActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.height,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final Color color;
  final double height;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 17),
        label: FittedBox(child: Text(label)),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          backgroundColor: const Color(0xFFFFF9EA),
          side: BorderSide(color: color.withOpacity(0.42)),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          textStyle: const TextStyle(fontWeight: FontWeight.w900),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
        color: const Color(0xFFFFF4CF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0x33B98543)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _muted,
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
              color: _ink,
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
        color: const Color(0xFFFFF6DB),
        border: Border.all(color: const Color(0x33B98543)),
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
        color: const Color(0xFFFFF8E6),
        border: Border.all(color: const Color(0x33B98543)),
        borderRadius: BorderRadius.circular(9),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            blurRadius: 8,
            color: Color(0x1217202A),
            offset: Offset(0, 4),
          ),
        ],
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
                    color: _ink,
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
                    color: _muted,
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
          backgroundColor: _marketTeal,
          foregroundColor: Colors.white,
          minimumSize: const Size(58, 34),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
        ),
        child: Text(label),
      );
    }

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: _spice,
        side: const BorderSide(color: Color(0x66E4572E)),
        backgroundColor: const Color(0xFFFFF9EA),
        minimumSize: const Size(58, 34),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
      ),
      child: Text(label),
    );
  }
}
