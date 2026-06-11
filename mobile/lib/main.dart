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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F4C5C)),
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
    required this.noteVi,
    required this.noteEn,
    required this.color,
    required this.accent,
    required this.icon,
  });

  final String id;
  final String name;
  final String noteVi;
  final String noteEn;
  final Color color;
  final Color accent;
  final IconData icon;
}

enum _AppLanguage { vi, en }

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
    noteVi: 'gia vị',
    noteEn: 'spices',
    color: Color(0xFFE4572E),
    accent: Color(0xFFF2C14E),
    icon: Icons.spa_rounded,
  ),
  Caravan(
    id: 'glassback',
    name: 'Glassback Cart',
    noteVi: 'kính muối',
    noteEn: 'salt glass',
    color: Color(0xFF0F4C5C),
    accent: Color(0xFF90E0EF),
    icon: Icons.diamond_outlined,
  ),
  Caravan(
    id: 'manta',
    name: 'Dune Manta',
    noteVi: 'lụa gió',
    noteEn: 'wind silk',
    color: Color(0xFF3D5A80),
    accent: Color(0xFFF2C14E),
    icon: Icons.air_rounded,
  ),
  Caravan(
    id: 'brasswing',
    name: 'Brasswing Wagon',
    noteVi: 'đồng hồ',
    noteEn: 'clockwork',
    color: Color(0xFF2D936C),
    accent: Color(0xFFF2C14E),
    icon: Icons.settings_rounded,
  ),
  Caravan(
    id: 'onyx',
    name: 'Onyx Horn Cart',
    noteVi: 'đá đêm',
    noteEn: 'night stone',
    color: Color(0xFF5F4B8B),
    accent: Color(0xFFF7B267),
    icon: Icons.terrain_rounded,
  ),
];

const Map<int, String> routeLabelsVi = <int, String>{
  0: 'Chợ',
  3: 'Cổng',
  6: 'Ốc đảo',
  9: 'Hẻm',
  12: 'Đền',
  15: 'Đích',
};

const Map<int, String> routeLabelsEn = <int, String>{
  0: 'Market',
  3: 'Gate',
  6: 'Oasis',
  9: 'Alley',
  12: 'Temple',
  15: 'Finish',
};

const int boardGridSize = 5;

const List<_BoardSlot> _loopBoardSlots = <_BoardSlot>[
  _BoardSlot(space: 0, row: 4, column: 0),
  _BoardSlot(space: 1, row: 3, column: 0),
  _BoardSlot(space: 2, row: 2, column: 0),
  _BoardSlot(space: 3, row: 1, column: 0),
  _BoardSlot(space: 4, row: 0, column: 0),
  _BoardSlot(space: 5, row: 0, column: 1),
  _BoardSlot(space: 6, row: 0, column: 2),
  _BoardSlot(space: 7, row: 0, column: 3),
  _BoardSlot(space: 8, row: 0, column: 4),
  _BoardSlot(space: 9, row: 1, column: 4),
  _BoardSlot(space: 10, row: 2, column: 4),
  _BoardSlot(space: 11, row: 3, column: 4),
  _BoardSlot(space: 12, row: 4, column: 4),
  _BoardSlot(space: 13, row: 4, column: 3),
  _BoardSlot(space: 14, row: 4, column: 2),
  _BoardSlot(space: 15, row: 4, column: 1),
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

  _AppLanguage _language = _AppLanguage.vi;
  int _activeTab = 0;
  bool _infoPanelOpen = false;
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
  Map<String, int> _windRolls = <String, int>{};
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
                final bool landscape = constraints.maxWidth >= 700 &&
                    constraints.maxWidth > constraints.maxHeight;
                if (landscape) {
                  return _buildLandscapeShell(constraints, leader);
                }

                final bool wide = constraints.maxWidth >= 820;
                final double? boardMaxWidth = wide
                    ? math.max(540, math.min(760, constraints.maxHeight - 120))
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

  Widget _buildLandscapeShell(BoxConstraints constraints, Caravan leader) {
    const double railWidth = 58;
    final double panelWidth = _infoPanelOpen ? 318 : 0;
    final double boardSize = math.min(
      constraints.maxHeight - 22,
      constraints.maxWidth - railWidth - panelWidth - 34,
    );

    return Stack(
      children: <Widget>[
        Positioned(
          left: 12,
          top: 10,
          bottom: 10,
          right: railWidth + panelWidth + 18,
          child: Center(
            child: _buildBoard(leader, maxWidth: boardSize),
          ),
        ),
        Positioned(
          left: 20,
          top: 16,
          right: railWidth + panelWidth + 26,
          child: _buildGlassHeader(leader),
        ),
        Positioned(
          top: 10,
          right: panelWidth + 10,
          bottom: 10,
          width: railWidth,
          child: _buildTabRail(),
        ),
        Positioned(
          top: 10,
          right: 10,
          bottom: 10,
          width: panelWidth,
          child: _buildFloatingInfoPanel(),
        ),
      ],
    );
  }

  Widget _buildGlassHeader(Caravan leader) {
    final Widget logo = Container(
      height: 36,
      width: 36,
      decoration: BoxDecoration(
        color: _marketTeal.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.46)),
      ),
      child: const Icon(
        Icons.local_shipping_rounded,
        color: _sunGold,
        size: 20,
      ),
    );

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool tight = constraints.maxWidth < 560;
        return Row(
          children: <Widget>[
            logo,
            const SizedBox(width: 8),
            _HudPill(icon: Icons.wb_sunny_rounded, value: '$_day'),
            const SizedBox(width: 6),
            _HudPill(icon: Icons.air_rounded, value: '${_bag.length}/5'),
            const SizedBox(width: 6),
            const _HudPill(icon: Icons.flag_rounded, value: '15'),
            if (!tight) ...<Widget>[
              const SizedBox(width: 6),
              Flexible(
                child: _HudPill(
                  icon: leader.icon,
                  value: leader.name.split(' ').first,
                ),
              ),
              const Spacer(),
              _LanguageToggle(
                language: _language,
                onChanged: (Set<_AppLanguage> value) {
                  setState(() => _language = value.first);
                },
              ),
            ] else
              const Spacer(),
            const SizedBox(width: 6),
            _HudPill(icon: Icons.toll_rounded, value: '$_coins'),
          ],
        );
      },
    );
  }

  Widget _buildTabRail() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _paper.withValues(alpha: 0.38),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.42)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            blurRadius: 24,
            color: Color(0x2217202A),
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 8),
        child: Column(
          children: <Widget>[
            _RailButton(
              key: const ValueKey<String>('rail-turn'),
              icon: Icons.touch_app_rounded,
              selected: _infoPanelOpen && _activeTab == 0,
              tooltip: _t('Lượt', 'Turn'),
              onPressed: () => setState(() {
                _activeTab = 0;
                _infoPanelOpen = true;
              }),
            ),
            const SizedBox(height: 8),
            _RailButton(
              key: const ValueKey<String>('rail-contracts'),
              icon: Icons.receipt_long_rounded,
              selected: _infoPanelOpen && _activeTab == 1,
              tooltip: _t('Hợp đồng', 'Contracts'),
              onPressed: () => setState(() {
                _activeTab = 1;
                _infoPanelOpen = true;
              }),
            ),
            const SizedBox(height: 8),
            _RailButton(
              key: const ValueKey<String>('rail-ledger'),
              icon: Icons.leaderboard_rounded,
              selected: _infoPanelOpen && _activeTab == 2,
              tooltip: _t('Sổ cái', 'Ledger'),
              onPressed: () => setState(() {
                _activeTab = 2;
                _infoPanelOpen = true;
              }),
            ),
            const Spacer(),
            _RailButton(
              key: const ValueKey<String>('rail-wind'),
              icon: Icons.air_rounded,
              selected: false,
              tooltip: _t('Rút gió', 'Draw wind'),
              onPressed: _raceOver ? null : () => setState(_drawWind),
            ),
            const SizedBox(height: 8),
            _RailButton(
              key: const ValueKey<String>('rail-event'),
              icon: Icons.auto_awesome_rounded,
              selected: false,
              tooltip: _t('Sự kiện', 'Event'),
              onPressed:
                  _raceOver || _coins < 2 ? null : () => setState(_drawEvent),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingInfoPanel() {
    if (!_infoPanelOpen) {
      return const SizedBox.shrink();
    }

    return _Panel(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 8, 6),
            child: Row(
              children: <Widget>[
                Icon(
                  <IconData>[
                    Icons.touch_app_rounded,
                    Icons.receipt_long_rounded,
                    Icons.leaderboard_rounded,
                  ][_activeTab],
                  color: _marketTeal,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    <String>[
                      _t('Lượt', 'Turn'),
                      _t('Hợp đồng', 'Contracts'),
                      _t('Sổ cái', 'Ledger'),
                    ][_activeTab],
                    style: const TextStyle(
                      color: _ink,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: _t('Đóng', 'Close'),
                  onPressed: () => setState(() => _infoPanelOpen = false),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0x22B98543)),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
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

  Widget _buildHeader() {
    final Widget brand = Row(
      mainAxisSize: MainAxisSize.min,
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
        const Flexible(
          child: Text(
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
        ),
      ],
    );

    final Widget chips = Wrap(
      spacing: 6,
      runSpacing: 5,
      children: <Widget>[
        _HeaderChip(
          icon: Icons.wb_sunny_rounded,
          label: _raceOver
              ? _t('Kết thúc', 'Finished')
              : _t('Ngày $_day', 'Day $_day'),
        ),
        _HeaderChip(
          icon: Icons.air_rounded,
          label: _t('${_bag.length}/5 gió', '${_bag.length}/5 wind'),
        ),
        _HeaderChip(
          icon: Icons.flag_rounded,
          label: _t('Đích 15', 'Finish 15'),
        ),
      ],
    );

    final Widget languageToggle = _LanguageToggle(
      language: _language,
      onChanged: (Set<_AppLanguage> value) {
        setState(() => _language = value.first);
      },
    );

    final Widget coinPill = Container(
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
          Text(
            _t('dinar', 'coins'),
            style: const TextStyle(
              color: _muted,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _paper.withValues(alpha: 0.95),
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
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool compact = constraints.maxWidth < 520;
          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(child: brand),
                    const SizedBox(width: 8),
                    coinPill,
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 7,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[chips, languageToggle],
                ),
              ],
            );
          }

          return Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[brand, const SizedBox(height: 5), chips],
                ),
              ),
              const SizedBox(width: 8),
              languageToggle,
              const SizedBox(width: 8),
              coinPill,
            ],
          );
        },
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
            decoration: const BoxDecoration(color: Color(0xFFEAB86E)),
            child: AspectRatio(
              aspectRatio: 1,
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final double gap = constraints.maxWidth < 460 ? 5 : 7;
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
                            label: _routeLabel(slot.space),
                            milestone: _isRouteMilestone(slot.space),
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
                segments: <ButtonSegment<int>>[
                  ButtonSegment<int>(
                    value: 0,
                    icon: const Icon(Icons.touch_app_rounded),
                    label: Text(_t('Lượt', 'Turn')),
                  ),
                  ButtonSegment<int>(
                    value: 1,
                    icon: const Icon(Icons.receipt_long_rounded),
                    label: Text(_t('Hợp đồng', 'Contracts')),
                  ),
                  ButtonSegment<int>(
                    value: 2,
                    icon: const Icon(Icons.leaderboard_rounded),
                    label: Text(_t('Sổ cái', 'Ledger')),
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
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6D9).withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.52)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            blurRadius: 18,
            color: Color(0x2217202A),
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool compact = constraints.maxWidth < 290;
          final List<Standing> standings = _standings();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: compact ? 5 : 7,
                ),
                decoration: BoxDecoration(
                  color: _marketTeal,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0x33FFFFFF)),
                ),
                child: Row(
                  children: <Widget>[
                    const Icon(
                      Icons.storefront_rounded,
                      color: _sunGold,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _t('Chợ cược', 'Bet market'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: compact ? 12 : 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: compact ? 5 : 7),
              Expanded(
                child: GridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: compact ? 2 : 3,
                  mainAxisSpacing: 5,
                  crossAxisSpacing: 5,
                  childAspectRatio: compact ? 1.82 : 1.88,
                  children: <Widget>[
                    for (final Standing standing in standings)
                      _MarketBetCard(
                        caravan: _caravan(standing.id),
                        dice: _windRolls[standing.id],
                        rank: standings.indexOf(standing) + 1,
                        canLeg: _canSignLeg(standing.id),
                        canFinal: _canSignFinal(standing.id),
                        onLeg: () =>
                            setState(() => _signLegContract(standing.id)),
                        onFinal: () =>
                            setState(() => _signFinalContract(standing.id)),
                        legLabel: _t('Chặng', 'Leg'),
                        finalLabel: _t('Cược', 'Final'),
                      ),
                  ],
                ),
              ),
              SizedBox(height: compact ? 4 : 6),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _TinyMarketStat(
                      icon: Icons.location_on_rounded,
                      value: _routeLabel(_selectedSpace),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: _TinyMarketStat(
                      icon: Icons.air_rounded,
                      value: '${_bag.length}/5',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _MarketRouteButton(
                      icon: Icons.arrow_upward_rounded,
                      color: _oasisGreen,
                      disabled: _routeMarkDisabled,
                      onPressed: () =>
                          setState(() => _placeRouteMark(RouteMarkType.boost)),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: _MarketRouteButton(
                      icon: Icons.arrow_downward_rounded,
                      color: _spice,
                      disabled: _routeMarkDisabled,
                      onPressed: () =>
                          setState(() => _placeRouteMark(RouteMarkType.snare)),
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
      side: BorderSide(color: color.withValues(alpha: 0.45)),
      backgroundColor: const Color(0xFFFFF9EA),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      textStyle: const TextStyle(fontWeight: FontWeight.w900),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  Widget _buildActionTab() {
    final String selectedLabel = _routeLabel(_selectedSpace);

    return Column(
      key: const ValueKey<int>(0),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (_raceOver)
          _EndBanner(
            title: _t('Phiên chợ khép lại', 'Market closed'),
            summary: _finalSummary(),
          ),
        Row(
          children: <Widget>[
            Expanded(
              child: _MiniStat(
                  label: _t('Ô chọn', 'Selected'), value: selectedLabel),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MiniStat(
                  label: _t('HĐ', 'CTR'), value: '${_legContracts.length}/2'),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MiniStat(
                label: _t('Tuyến', 'Route'),
                value:
                    _routeUsed ? _t('Đã đặt', 'Placed') : _t('Trống', 'Open'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: <Widget>[
            Expanded(
              child: _MiniStat(label: 'Seed', value: '$_seed'),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MiniStat(
                  label: _t('Bot', 'Bots'), value: '${_rivals.length}'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: <Widget>[
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => setState(_startNewSeed),
                icon: const Icon(Icons.shuffle_rounded),
                label: Text(_t('Seed mới', 'New seed')),
                style: _marketButtonStyle(),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => setState(_resetGame),
                icon: const Icon(Icons.restart_alt_rounded),
                label: Text(_t('Chơi lại', 'Restart')),
                style: _marketButtonStyle(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: <Widget>[
            Expanded(
              child: FilledButton.icon(
                onPressed: _raceOver ? null : () => setState(_drawWind),
                icon: const Icon(Icons.air_rounded),
                label: Text(_t('Rút gió', 'Draw wind')),
                style: FilledButton.styleFrom(
                  backgroundColor: _spice,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontWeight: FontWeight.w900),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed:
                    _raceOver || _coins < 2 ? null : () => setState(_drawEvent),
                icon: const Icon(Icons.auto_awesome_rounded),
                label: Text(_t('Sự kiện', 'Event')),
                style: _marketButtonStyle(color: _spice),
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
      return _InfoCard(
        title: _t('Chờ phong ấn', 'Waiting for wind'),
        body: _t(
          'Thương lộ đang đợi đợt gió đầu tiên.',
          'The trade route is waiting for the first gust.',
        ),
        icon: Icons.hourglass_empty_rounded,
      );
    }

    final Caravan caravan = _caravan(last.caravanId);
    final String mark = _localizedMarkText(last.markText);
    final String body = _t(
      'Gió đẩy ${last.steps} ô${mark.isEmpty ? '' : ', $mark'}.',
      'Wind moved ${last.steps} spaces${mark.isEmpty ? '' : ', $mark'}.',
    );

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
            subtitle: _t(
              'Ô ${standing.position} - tầng ${standing.layer + 1} - ${caravan.noteVi}',
              'Space ${standing.position} - layer ${standing.layer + 1} - ${caravan.noteEn}',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _SmallAction(
                  label: _t('Chặng', 'Leg'),
                  onPressed: canLeg
                      ? () => setState(() => _signLegContract(caravan.id))
                      : null,
                ),
                const SizedBox(width: 6),
                _SmallAction(
                  label: _t('Cược', 'Bet'),
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
        name: _t('Bạn', 'You'),
        coins: _coins,
        detail: _t(
            '${_legContracts.length} chặng - ${_finalContracts.length} cược',
            '${_legContracts.length} leg - ${_finalContracts.length} final'),
      ),
      for (final Rival rival in _rivals)
        _ScoreLine(
          name: rival.name,
          coins: rival.coins,
          detail: _t(
            '${rival.legContracts.length} chặng - ${rival.finalContracts.length} cược',
            '${rival.legContracts.length} leg - ${rival.finalContracts.length} final',
          ),
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
                      _t(
                        '#${event.seq.toString().padLeft(3, '0')}  ${event.actor}  -  Ngày ${event.day}',
                        '#${event.seq.toString().padLeft(3, '0')}  ${event.actor}  -  Day ${event.day}',
                      ),
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

  String _t(String vi, String en) {
    return _language == _AppLanguage.vi ? vi : en;
  }

  String _routeLabel(int space) {
    final Map<int, String> labels =
        _language == _AppLanguage.vi ? routeLabelsVi : routeLabelsEn;
    return labels[space] ?? _t('Ô $space', 'Space $space');
  }

  bool _isRouteMilestone(int space) {
    return routeLabelsVi.containsKey(space);
  }

  String _localizedMarkText(String markText) {
    if (markText.isEmpty) {
      return '';
    }
    if (markText == 'qua oc dao +1') {
      return _t('qua ốc đảo +1', 'oasis +1');
    }
    if (markText == 'lac vao ao anh -1') {
      return _t('lạc vào ảo ảnh -1', 'mirage -1');
    }
    return markText;
  }

  String get _playerName => _t('Bạn', 'You');

  String get _systemName => _t('Hệ thống', 'System');

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
    _windRolls = <String, int>{};
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
    _addLog(
      _t(
        'Chợ mở cổng. Các đoàn buôn xuất phát từ ô 0. Seed $_seed.',
        'The market gate opens. Caravans start at space 0. Seed $_seed.',
      ),
      kind: 'game_reset',
    );
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
    _windRolls[caravanId] = steps;
    final String markText = _moveChain(caravanId, steps);
    _lastWind = WindResult(
      caravanId: caravanId,
      steps: steps,
      markText: markText,
    );
    final String markSuffix =
        markText.isEmpty ? '' : ', ${_localizedMarkText(markText)}';
    _addLog(
      _t(
        '${_caravan(caravanId).name} đi $steps ô$markSuffix.',
        '${_caravan(caravanId).name} moved $steps spaces$markSuffix.',
      ),
      actor: _playerName,
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
      _eventTitle = _t('Gia vị vỡ thùng', 'Spice spill');
      _eventText = _t(
        'Đoàn cuối được đẩy thêm 2 ô.',
        'The last caravan is pushed 2 spaces.',
      );
      final Standing last = _standings().last;
      _moveChain(last.id, 2);
      _addLog(
        _t(
          '${_caravan(last.id).name} bám mùi gia vị, tiến 2 ô.',
          '${_caravan(last.id).name} follows the spice trail, +2 spaces.',
        ),
        actor: _playerName,
        kind: 'event_card',
      );
    } else if (eventIndex == 1) {
      _eventTitle = _t('Trạm ảo ảnh', 'Mirage stop');
      _eventText = _t(
        'Đoàn dẫn đầu lùi 1 ô.',
        'The leading caravan moves back 1 space.',
      );
      final Standing first = _standings().first;
      _moveChain(first.id, -1);
      _addLog(
        _t(
          '${_caravan(first.id).name} vòng qua ảo ảnh, lùi 1 ô.',
          '${_caravan(first.id).name} circles a mirage, -1 space.',
        ),
        actor: _playerName,
        kind: 'event_card',
      );
    } else if (eventIndex == 2) {
      _eventTitle = _t('Phiên chợ đêm', 'Night market');
      _eventText = _t(
        'Bạn nhận 4 dinar, đối thủ gần nhất nhận 2.',
        'You gain 4 coins; the closest rival gains 2.',
      );
      _coins += 4;
      final List<Rival> sortedRivals = List<Rival>.from(_rivals)
        ..sort((Rival a, Rival b) => b.coins.compareTo(a.coins));
      final Rival rival = sortedRivals.first;
      rival.coins += 2;
      _addLog(
        _t(
          'Phiên chợ đêm sinh lời: bạn +4, ${rival.name} +2.',
          'Night market profit: you +4, ${rival.name} +2.',
        ),
        actor: _playerName,
        kind: 'event_card',
      );
    } else {
      _eventTitle = _t('Đường kính', 'Glass road');
      _eventText = _t(
        'Một ô trước đoàn cuối thành ốc đảo.',
        'The space ahead of the last caravan becomes an oasis.',
      );
      final Standing last = _standings().last;
      final int target = math.min(finishSpace - 1, last.position + 1);
      if (target > 0 && !_routeMarks.containsKey(target)) {
        _routeMarks[target] = RouteMarkType.boost;
        _addLog(
          _t('Đường kính mở ở ô $target.',
              'Glass road opens at space $target.'),
          actor: _playerName,
          kind: 'event_card',
        );
      } else {
        _coins += 2;
        _addLog(
          _t(
            'Đường kính đã đóng, bạn thu lại 2 dinar.',
            'The glass road is closed; you recover 2 coins.',
          ),
          actor: _playerName,
          kind: 'event_card',
        );
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
      _t(
        '${type == RouteMarkType.boost ? 'Ốc đảo' : 'Ảo ảnh'} đặt ở ô $_selectedSpace.',
        '${type == RouteMarkType.boost ? 'Oasis' : 'Mirage'} placed on space $_selectedSpace.',
      ),
      actor: _playerName,
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
    _addLog(
      _t(
        'Ký hợp đồng chặng cho ${_caravan(caravanId).name}.',
        'Signed a leg contract for ${_caravan(caravanId).name}.',
      ),
      actor: _playerName,
      kind: 'leg_contract',
    );
    _runBotMarket();
  }

  void _signFinalContract(String caravanId) {
    if (!_canSignFinal(caravanId)) {
      return;
    }
    _coins -= 1;
    _finalContracts.add(Contract(caravanId, _day));
    _addLog(
      _t(
        'Giữ hợp đồng chung cuộc cho ${_caravan(caravanId).name}.',
        'Held a final contract for ${_caravan(caravanId).name}.',
      ),
      actor: _playerName,
      kind: 'final_contract',
    );
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
        .where(
          (Standing standing) => !rival.legContracts.any(
            (Contract contract) => contract.caravanId == standing.id,
          ),
        )
        .toList();
    if (candidates.isEmpty) {
      return false;
    }

    final Standing target = weightedPick(candidates, _random);
    rival.coins -= 2;
    rival.legContracts.add(Contract(target.id, _day));
    _addLog(
      _t(
        'Ký hợp đồng chặng cho ${_caravan(target.id).name}.',
        'Signed a leg contract for ${_caravan(target.id).name}.',
      ),
      actor: rival.name,
      kind: 'bot_leg_contract',
    );
    return true;
  }

  bool _tryRivalFinalContract(Rival rival) {
    if (rival.coins < 1 || rival.finalContracts.length >= maxFinalContracts) {
      return false;
    }

    final List<Standing> candidates = _standings()
        .where(
          (Standing standing) => !rival.finalContracts.any(
            (Contract contract) => contract.caravanId == standing.id,
          ),
        )
        .toList();
    if (candidates.isEmpty) {
      return false;
    }

    final Standing target = weightedPick(candidates, _random);
    rival.coins -= 1;
    rival.finalContracts.add(Contract(target.id, _day));
    _addLog(
      _t(
        'Giữ hợp đồng chung cuộc cho ${_caravan(target.id).name}.',
        'Held a final contract for ${_caravan(target.id).name}.',
      ),
      actor: rival.name,
      kind: 'bot_final_contract',
    );
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
      _t(
        '${type == RouteMarkType.boost ? 'Ốc đảo' : 'Ảo ảnh'} đặt ở ô $space.',
        '${type == RouteMarkType.boost ? 'Oasis' : 'Mirage'} placed on space $space.',
      ),
      actor: rival.name,
      kind: 'bot_route_mark',
    );
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
      final List<int> candidates = <int>[center + offset, center - offset];
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
      _addLog(
        _t(
          'Hợp đồng chặng trả $playerPayout dinar cho bạn.',
          'Leg contracts pay you $playerPayout coins.',
        ),
        kind: 'leg_payout',
      );
    } else if (_legContracts.isNotEmpty) {
      _addLog(
        _t(
          'Hợp đồng chặng của bạn không trúng.',
          'Your leg contracts missed.',
        ),
        kind: 'leg_payout',
      );
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
      _addLog(
        _t(
          '${_caravan(leader.id).name} chạm cổng đích. Cuộc đua kết thúc.',
          '${_caravan(leader.id).name} reaches the finish gate. The race ends.',
        ),
        kind: 'race_finished',
      );
      return;
    }

    _day += 1;
    _bag = newWindBag();
    _eventTitle = null;
    _eventText = null;
    _lastWind = null;
    _windRolls = <String, int>{};
    _routeMarks = <int, RouteMarkType>{};
    _routeUsed = false;
    _legContracts.clear();
    for (final Rival rival in _rivals) {
      rival.legContracts.clear();
      rival.routeUsed = false;
    }
    _aiPrepareLeg();
    _addLog(
      _t(
        'Ngày $_day bắt đầu. Hợp đồng chặng được mở lại.',
        'Day $_day begins. Leg contracts reopen.',
      ),
      kind: 'leg_started',
    );
  }

  void _resolveFinalContracts(
    Standing leader,
    Standing second,
    Standing third,
  ) {
    final int playerPayout = _finalContracts.fold<int>(
      0,
      (int total, Contract contract) =>
          total + finalPayout(contract.caravanId, leader, second, third),
    );
    _coins += playerPayout;
    _addLog(
      _t(
        'Hợp đồng chung cuộc trả $playerPayout dinar cho bạn.',
        'Final contracts pay you $playerPayout coins.',
      ),
      kind: 'final_payout',
    );

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
        final Standing target = weightedPick(
          standings.take(4).toList(),
          _random,
        );
        rival.coins -= 2;
        rival.legContracts.add(Contract(target.id, _day));
      }

      if (rival.finalContracts.length < maxFinalContracts &&
          rival.coins >= 1 &&
          _random.nextDouble() > 0.42) {
        final Standing target = weightedPick(standings, _random);
        final bool exists = rival.finalContracts.any(
          (Contract c) => c.caravanId == target.id,
        );
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
        !_legContracts.any(
          (Contract contract) => contract.caravanId == caravanId,
        );
  }

  bool _canSignFinal(String caravanId) {
    return !_raceOver &&
        _coins >= 1 &&
        _finalContracts.length < maxFinalContracts &&
        !_finalContracts.any(
          (Contract contract) => contract.caravanId == caravanId,
        );
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
      _ScoreLine(name: _playerName, coins: _coins, detail: ''),
      for (final Rival rival in _rivals)
        _ScoreLine(name: rival.name, coins: rival.coins, detail: ''),
    ]..sort((_ScoreLine a, _ScoreLine b) => b.coins.compareTo(a.coins));
    return _t(
      '${scores.first.name} thắng phiên chợ với ${scores.first.coins} dinar.',
      '${scores.first.name} wins the market with ${scores.first.coins} coins.',
    );
  }

  void _addLog(
    String message, {
    String? actor,
    String kind = 'note',
  }) {
    _localSeq += 1;
    _log.insert(
      0,
      LocalGameEvent(
        seq: _localSeq,
        day: _day,
        actor: actor ?? _systemName,
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
      ..quadraticBezierTo(
        size.width * 0.22,
        size.height * 0.50,
        size.width * 0.46,
        size.height * 0.58,
      )
      ..quadraticBezierTo(
        size.width * 0.72,
        size.height * 0.68,
        size.width,
        size.height * 0.55,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(far, farDune);

    final Paint nearDune = Paint()..color = const Color(0x77D99043);
    final Path near = Path()
      ..moveTo(0, size.height * 0.76)
      ..quadraticBezierTo(
        size.width * 0.28,
        size.height * 0.64,
        size.width * 0.57,
        size.height * 0.75,
      )
      ..quadraticBezierTo(
        size.width * 0.82,
        size.height * 0.84,
        size.width,
        size.height * 0.72,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(near, nearDune);

    _drawBackdropOasis(canvas, size);
    _drawBackdropMarket(canvas, size);
  }

  void _drawBackdropOasis(Canvas canvas, Size size) {
    final Offset center = Offset(size.width * 0.78, size.height * 0.58);
    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: size.width * 0.16,
        height: size.height * 0.08,
      ),
      Paint()..color = const Color(0x332D936C),
    );

    for (final Offset base in <Offset>[
      center.translate(-size.width * 0.05, -size.height * 0.02),
      center.translate(size.width * 0.02, -size.height * 0.04),
    ]) {
      final Paint trunk = Paint()
        ..color = const Color(0x668E5D2B)
        ..strokeWidth = math.max(4, size.shortestSide * 0.012)
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(base, base.translate(10, -54), trunk);
      final Offset crown = base.translate(10, -58);
      final Paint leaf = Paint()
        ..color = const Color(0x662D936C)
        ..strokeWidth = math.max(5, size.shortestSide * 0.014)
        ..strokeCap = StrokeCap.round;
      for (int i = 0; i < 6; i++) {
        final double angle = -math.pi * 0.92 + i * math.pi / 5;
        canvas.drawLine(
          crown,
          crown.translate(math.cos(angle) * 44, math.sin(angle) * 34),
          leaf,
        );
      }
    }
  }

  void _drawBackdropMarket(Canvas canvas, Size size) {
    final double y = size.height * 0.78;
    final List<Color> awnings = <Color>[_spice, _marketTeal, _deepIndigo];
    for (int i = 0; i < awnings.length; i++) {
      final double x = size.width * (0.70 + i * 0.07);
      final Path tent = Path()
        ..moveTo(x, y)
        ..lineTo(x + size.width * 0.035, y - size.height * 0.08)
        ..lineTo(x + size.width * 0.075, y)
        ..close();
      canvas.drawPath(
          tent, Paint()..color = awnings[i].withValues(alpha: 0.34));
      canvas.drawRect(
        Rect.fromLTWH(x + 6, y, size.width * 0.064, size.height * 0.055),
        Paint()..color = const Color(0x338E5D2B),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TradeRoutePainter extends CustomPainter {
  const _TradeRoutePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final Paint parchment = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          Color(0xFFFFE0A0),
          Color(0xFFE7A857),
          Color(0xFFFFD28A),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, parchment);

    final Paint warmLight = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.35, -0.55),
        radius: 0.8,
        colors: <Color>[
          const Color(0xFFFFF5C7).withValues(alpha: 0.85),
          const Color(0x00FFF5C7),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, warmLight);

    final Paint borderWash = Paint()
      ..color = const Color(0x448E5D2B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(7), const Radius.circular(18)),
      borderWash,
    );

    final Paint duneLine = Paint()
      ..color = const Color(0x268E5D2B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (int i = 0; i < 7; i++) {
      final double y = size.height * (0.18 + i * 0.11);
      final Path dune = Path()..moveTo(size.width * -0.08, y);
      dune.quadraticBezierTo(
        size.width * 0.22,
        y - 24 + i % 2 * 10,
        size.width * 0.52,
        y + 4,
      );
      dune.quadraticBezierTo(
        size.width * 0.78,
        y + 28 - i % 2 * 12,
        size.width * 1.08,
        y - 2,
      );
      canvas.drawPath(dune, duneLine);
    }

    final Offset center = Offset(size.width / 2, size.height / 2);
    final Paint oasis = Paint()..color = const Color(0x332D936C);
    canvas.drawOval(
      Rect.fromCenter(
        center: center.translate(0, size.height * 0.06),
        width: size.width * 0.31,
        height: size.height * 0.12,
      ),
      oasis,
    );

    _drawMarketCards(canvas, size);
    _drawOasisPalms(canvas, size);
    _drawPyramid(canvas, size);

    final double gap = size.width < 460 ? 5 : 7;
    final double cell =
        (size.width - gap * (boardGridSize - 1)) / boardGridSize;
    final List<Offset> centers = _loopBoardSlots.map((_BoardSlot slot) {
      return Offset(
        slot.column * (cell + gap) + cell / 2,
        slot.row * (cell + gap) + cell / 2,
      );
    }).toList();

    _drawStoneRoad(canvas, centers, cell);

    final Path path = Path()..moveTo(centers.first.dx, centers.first.dy);
    for (final Offset center in centers.skip(1)) {
      path.lineTo(center.dx, center.dy);
    }
    path.close();

    final Paint shadow = Paint()
      ..color = const Color(0x338E5D2B)
      ..strokeWidth = cell * 0.55
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, shadow);

    final Paint trail = Paint()
      ..color = const Color(0x77FFFFFF)
      ..strokeWidth = cell * 0.11
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, trail);

    final Paint stitch = Paint()
      ..color = const Color(0x778E5D2B)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    for (int i = 0; i < centers.length; i++) {
      canvas.drawCircle(centers[i], cell * 0.43, stitch);
    }
  }

  void _drawStoneRoad(Canvas canvas, List<Offset> centers, double cell) {
    final Paint slabShadow = Paint()..color = const Color(0x3317202A);
    final Paint slab = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[Color(0xFFFFD991), Color(0xFFC98E4A)],
      ).createShader(Rect.fromLTWH(0, 0, cell, cell));
    final Paint tealEdge = Paint()..color = const Color(0xAA0F8C92);
    final Paint rubyEdge = Paint()..color = const Color(0x99C45142);

    for (int i = 0; i < centers.length; i++) {
      final Offset center = centers[i];
      final Rect tileRect = Rect.fromCenter(
        center: center,
        width: cell * 0.95,
        height: cell * 0.88,
      );
      final RRect shadow = RRect.fromRectAndRadius(
        tileRect.shift(Offset(0, cell * 0.08)),
        Radius.circular(cell * 0.12),
      );
      final RRect stone = RRect.fromRectAndRadius(
        tileRect,
        Radius.circular(cell * 0.12),
      );
      canvas.drawRRect(shadow, slabShadow);
      canvas.drawRRect(stone, slab);
      canvas.drawRRect(
        stone.deflate(cell * 0.06),
        Paint()
          ..color = const Color(0x66FFF6D9)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );

      final Rect colorBand = Rect.fromLTWH(
        tileRect.left + cell * 0.08,
        tileRect.bottom - cell * 0.16,
        tileRect.width - cell * 0.16,
        cell * 0.07,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(colorBand, Radius.circular(cell * 0.04)),
        i.isEven ? tealEdge : rubyEdge,
      );
    }
  }

  void _drawMarketCards(Canvas canvas, Size size) {
    final double cardWidth = size.width * 0.105;
    final double cardHeight = size.height * 0.13;
    final List<Color> colors = <Color>[
      _spice,
      _oasisGreen,
      _marketTeal,
      _sunGold,
      _deepIndigo,
    ];

    for (int i = 0; i < colors.length; i++) {
      final Offset topLeft = Offset(
        size.width * (0.25 + i * 0.09),
        size.height * 0.13 + (i.isEven ? 0 : size.height * 0.012),
      );
      final RRect card = RRect.fromRectAndRadius(
        topLeft & Size(cardWidth, cardHeight),
        const Radius.circular(5),
      );
      canvas.drawRRect(
        card.shift(const Offset(0, 5)),
        Paint()..color = const Color(0x3317202A),
      );
      canvas.drawRRect(card, Paint()..color = colors[i]);
      canvas.drawRRect(
        card.deflate(5),
        Paint()
          ..color = const Color(0xCCFFF6D9)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      canvas.drawCircle(
        topLeft + Offset(cardWidth * 0.5, cardHeight * 0.36),
        cardWidth * 0.18,
        Paint()..color = const Color(0xDDF2C14E),
      );
      canvas.drawRect(
        Rect.fromLTWH(
          topLeft.dx + cardWidth * 0.22,
          topLeft.dy + cardHeight * 0.64,
          cardWidth * 0.56,
          3,
        ),
        Paint()..color = const Color(0xAA17202A),
      );
    }
  }

  void _drawOasisPalms(Canvas canvas, Size size) {
    final Paint shrub = Paint()..color = const Color(0xAA2D936C);
    final Rect grove = Rect.fromCenter(
      center: Offset(size.width * 0.70, size.height * 0.21),
      width: size.width * 0.22,
      height: size.height * 0.14,
    );
    canvas.drawOval(grove, shrub);

    for (final Offset base in <Offset>[
      Offset(size.width * 0.67, size.height * 0.20),
      Offset(size.width * 0.73, size.height * 0.18),
      Offset(size.width * 0.78, size.height * 0.24),
    ]) {
      final Paint trunk = Paint()
        ..color = const Color(0xFF8E5D2B)
        ..strokeWidth = size.width * 0.012
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        base,
        base.translate(size.width * 0.015, -size.height * 0.075),
        trunk,
      );
      final Offset crown =
          base.translate(size.width * 0.015, -size.height * 0.08);
      final Paint leaf = Paint()
        ..color = const Color(0xDD1D6B43)
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.012
        ..strokeCap = StrokeCap.round;
      for (int i = 0; i < 6; i++) {
        final double angle = -math.pi * 0.9 + i * math.pi / 5;
        canvas.drawLine(
          crown,
          crown.translate(math.cos(angle) * size.width * 0.055,
              math.sin(angle) * size.height * 0.055),
          leaf,
        );
      }
    }
  }

  void _drawPyramid(Canvas canvas, Size size) {
    final Offset apex = Offset(size.width * 0.47, size.height * 0.38);
    final Offset left = Offset(size.width * 0.30, size.height * 0.73);
    final Offset right = Offset(size.width * 0.58, size.height * 0.72);
    final Offset back = Offset(size.width * 0.40, size.height * 0.78);

    final Path shadow = Path()
      ..moveTo(left.dx, left.dy)
      ..lineTo(right.dx + size.width * 0.035, right.dy + size.height * 0.025)
      ..lineTo(back.dx, back.dy + size.height * 0.045)
      ..close();
    canvas.drawPath(shadow, Paint()..color = const Color(0x3317202A));

    final Path litFace = Path()
      ..moveTo(apex.dx, apex.dy)
      ..lineTo(left.dx, left.dy)
      ..lineTo(back.dx, back.dy)
      ..close();
    canvas.drawPath(litFace, Paint()..color = const Color(0xFFEEC86A));

    final Path shadeFace = Path()
      ..moveTo(apex.dx, apex.dy)
      ..lineTo(back.dx, back.dy)
      ..lineTo(right.dx, right.dy)
      ..close();
    canvas.drawPath(shadeFace, Paint()..color = const Color(0xFFC98E36));

    final Paint ridge = Paint()
      ..color = const Color(0xAAFFF1C5)
      ..strokeWidth = 1.2;
    for (int i = 1; i < 7; i++) {
      final double t = i / 7;
      final Offset a = Offset.lerp(apex, left, t)!;
      final Offset b = Offset.lerp(apex, right, t)!;
      canvas.drawLine(a, b, ridge);
    }

    final Paint outline = Paint()
      ..color = const Color(0x668E5D2B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(litFace, outline);
    canvas.drawPath(shadeFace, outline);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child, this.padding = EdgeInsets.zero});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _paper.withValues(alpha: 0.94),
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
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class _HudPill extends StatelessWidget {
  const _HudPill({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: _paper.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.48)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 16, color: _marketTeal),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _ink,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RailButton extends StatelessWidget {
  const _RailButton({
    super.key,
    required this.icon,
    required this.selected,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final bool selected;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: SizedBox(
        height: 42,
        width: 42,
        child: IconButton.filledTonal(
          onPressed: onPressed,
          icon: Icon(icon, size: 19),
          style: IconButton.styleFrom(
            backgroundColor:
                selected ? _marketTeal : _paper.withValues(alpha: 0.64),
            foregroundColor: selected ? Colors.white : _marketTeal,
            disabledBackgroundColor: _paper.withValues(alpha: 0.32),
            disabledForegroundColor: _muted.withValues(alpha: 0.62),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}

class _MarketBetCard extends StatelessWidget {
  const _MarketBetCard({
    required this.caravan,
    required this.dice,
    required this.rank,
    required this.canLeg,
    required this.canFinal,
    required this.onLeg,
    required this.onFinal,
    required this.legLabel,
    required this.finalLabel,
  });

  final Caravan caravan;
  final int? dice;
  final int rank;
  final bool canLeg;
  final bool canFinal;
  final VoidCallback onLeg;
  final VoidCallback onFinal;
  final String legLabel;
  final String finalLabel;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: caravan.color.withValues(alpha: 0.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  height: 16,
                  width: 16,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: caravan.color,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    '$rank',
                    style: TextStyle(
                      color: caravan.accent,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    caravan.name.split(' ').first,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _ink,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                _DiceFace(value: dice, color: caravan.color),
              ],
            ),
            const Spacer(),
            Row(
              children: <Widget>[
                Expanded(
                  child: _MarketCardButton(
                    icon: Icons.flag_rounded,
                    tooltip: legLabel,
                    enabled: canLeg,
                    onPressed: onLeg,
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: _MarketCardButton(
                    icon: Icons.emoji_events_rounded,
                    tooltip: finalLabel,
                    enabled: canFinal,
                    onPressed: onFinal,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DiceFace extends StatelessWidget {
  const _DiceFace({required this.value, required this.color});

  final int? value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 16,
      width: 16,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: value == null ? _paper.withValues(alpha: 0.9) : color,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        value?.toString() ?? '-',
        style: TextStyle(
          color: value == null ? _muted : Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _MarketCardButton extends StatelessWidget {
  const _MarketCardButton({
    required this.icon,
    required this.tooltip,
    required this.enabled,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: SizedBox(
        height: 18,
        child: IconButton(
          padding: EdgeInsets.zero,
          onPressed: enabled ? onPressed : null,
          icon: Icon(icon, size: 13),
          style: IconButton.styleFrom(
            backgroundColor: _paper.withValues(alpha: 0.82),
            foregroundColor: _marketTeal,
            disabledForegroundColor: _muted.withValues(alpha: 0.45),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(7),
            ),
          ),
        ),
      ),
    );
  }
}

class _TinyMarketStat extends StatelessWidget {
  const _TinyMarketStat({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 26,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.52),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 13, color: _marketTeal),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _ink,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MarketRouteButton extends StatelessWidget {
  const _MarketRouteButton({
    required this.icon,
    required this.color,
    required this.disabled,
    required this.onPressed,
  });

  final IconData icon;
  final Color color;
  final bool disabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 25,
      child: IconButton(
        padding: EdgeInsets.zero,
        onPressed: disabled ? null : onPressed,
        icon: Icon(icon, size: 15),
        style: IconButton.styleFrom(
          foregroundColor: color,
          backgroundColor: Colors.white.withValues(alpha: 0.58),
          disabledForegroundColor: _muted.withValues(alpha: 0.42),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
        ),
      ),
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

class _LanguageToggle extends StatelessWidget {
  const _LanguageToggle({required this.language, required this.onChanged});

  final _AppLanguage language;
  final ValueChanged<Set<_AppLanguage>> onChanged;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: _marketTeal,
              secondaryContainer: const Color(0xFFFFE8AF),
              onSecondaryContainer: _ink,
            ),
      ),
      child: SegmentedButton<_AppLanguage>(
        segments: const <ButtonSegment<_AppLanguage>>[
          ButtonSegment<_AppLanguage>(
              value: _AppLanguage.vi, label: Text('VI')),
          ButtonSegment<_AppLanguage>(
              value: _AppLanguage.en, label: Text('EN')),
        ],
        selected: <_AppLanguage>{language},
        onSelectionChanged: onChanged,
        showSelectedIcon: false,
        style: SegmentedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
          side: const BorderSide(color: Color(0x55B98543)),
        ),
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
    required this.milestone,
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
  final bool milestone;
  final VoidCallback onTap;
  final Caravan Function(String id) caravanFor;

  @override
  Widget build(BuildContext context) {
    final List<Color> fill = isFinish
        ? <Color>[_deepIndigo, _marketTeal]
        : isStart
            ? const <Color>[Color(0xFFE1F4CA), Color(0xFFF7E6A8)]
            : const <Color>[Color(0xFFFFF4CC), Color(0xFFE7B768)];
    final Color foreground = isFinish ? Colors.white : _ink;
    final double angle = ((index % 5) - 2) * 0.012;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Transform.rotate(
          angle: angle,
          child: Stack(
            children: <Widget>[
              Positioned(
                left: 3,
                right: 3,
                bottom: 0,
                height: 9,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: isFinish
                        ? const Color(0xFF17202A)
                        : const Color(0xFFB98543),
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
              ),
              Positioned.fill(
                bottom: 5,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 140),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: fill,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: selected ? _spice : const Color(0xAA8E5D2B),
                      width: selected ? 2.6 : 1.2,
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        blurRadius: selected ? 14 : 7,
                        color: selected
                            ? const Color(0x66E4572E)
                            : const Color(0x2817202A),
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                        left: 4,
                        right: 4,
                        bottom: 5,
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: foreground.withValues(
                              alpha: isFinish ? 0.28 : 0.18,
                            ),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Container(
                                height: 24,
                                width: 24,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isFinish
                                      ? Colors.white.withValues(alpha: 0.14)
                                      : const Color(0xEFFFF9E8),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: foreground.withValues(alpha: 0.18),
                                  ),
                                ),
                                child: Text(
                                  '$index',
                                  style: TextStyle(
                                    color: foreground,
                                    fontSize: 12,
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
                                    color: foreground.withValues(
                                      alpha:
                                          milestone || isFinish ? 0.86 : 0.58,
                                    ),
                                    fontSize: milestone ? 10.5 : 9.5,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              if (routeMark != null)
                                _RouteBadge(type: routeMark!),
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
                      if (milestone)
                        Positioned(
                          right: 1,
                          bottom: 0,
                          child: Icon(
                            isFinish
                                ? Icons.flag_rounded
                                : isStart
                                    ? Icons.storefront_rounded
                                    : Icons.location_on_rounded,
                            color: foreground.withValues(
                              alpha: isFinish ? 0.74 : 0.36,
                            ),
                            size: 16,
                          ),
                        ),
                      if (selected)
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.72),
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                    ],
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
        final bool crowded = ids.length > 3;
        final double overlap = crowded ? 4.5 : 9;
        final double maxSizeForHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight - overlap * (ids.length - 1)
            : 34;
        final double size = crowded
            ? math.max(18, math.min(24, maxSizeForHeight))
            : math.min(34, math.max(26, constraints.maxHeight));
        final double height = math.min(
          constraints.maxHeight,
          size + overlap * (ids.length - 1),
        );
        final double width = size * 1.45 + 16;

        return SizedBox(
          height: height,
          width: width,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: <Widget>[
              for (int i = 0; i < ids.length; i++)
                Positioned(
                  bottom: math.min(height - size, i * overlap),
                  left: 8 + (i.isEven ? -4 : 4),
                  child: _CaravanToken(caravan: caravanFor(ids[i]), size: size),
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
    return SizedBox(
      height: size,
      width: size * 1.45,
      child: CustomPaint(
        painter: _CaravanWagonPainter(caravan: caravan),
      ),
    );
  }
}

class _CaravanWagonPainter extends CustomPainter {
  const _CaravanWagonPainter({required this.caravan});

  final Caravan caravan;

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final Paint shadow = Paint()..color = const Color(0x4017202A);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.52, h * 0.83),
        width: w * 0.82,
        height: h * 0.24,
      ),
      shadow,
    );

    final RRect cargo = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.12, h * 0.36, w * 0.72, h * 0.32),
      Radius.circular(h * 0.08),
    );
    canvas.drawRRect(cargo, Paint()..color = const Color(0xFF9B642F));
    canvas.drawRRect(
      cargo.deflate(1.4),
      Paint()
        ..color = const Color(0xAAFFF0BD)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    final Path canopy = Path()
      ..moveTo(w * 0.16, h * 0.43)
      ..cubicTo(w * 0.22, h * 0.12, w * 0.72, h * 0.10, w * 0.82, h * 0.42)
      ..lineTo(w * 0.78, h * 0.56)
      ..cubicTo(w * 0.64, h * 0.42, w * 0.34, h * 0.42, w * 0.20, h * 0.56)
      ..close();
    canvas.drawPath(
      canopy,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            caravan.color.withValues(alpha: 0.98),
            caravan.color.withValues(alpha: 0.72),
          ],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      canopy,
      Paint()
        ..color = caravan.accent.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.2, h * 0.06),
    );

    for (final double x in <double>[0.31, 0.50, 0.69]) {
      canvas.drawLine(
        Offset(w * x, h * 0.23),
        Offset(w * x, h * 0.56),
        Paint()
          ..color = const Color(0x88FFF6D9)
          ..strokeWidth = math.max(1, h * 0.025),
      );
    }

    final RRect frontCrate = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.05, h * 0.48, w * 0.25, h * 0.21),
      Radius.circular(h * 0.04),
    );
    final RRect rearCrate = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.67, h * 0.48, w * 0.25, h * 0.21),
      Radius.circular(h * 0.04),
    );
    final Paint cratePaint = Paint()..color = const Color(0xFFC58A43);
    canvas.drawRRect(frontCrate, cratePaint);
    canvas.drawRRect(rearCrate, cratePaint);

    final Paint wheelPaint = Paint()..color = const Color(0xFF4B2C1D);
    final Paint hubPaint = Paint()..color = caravan.accent;
    for (final double x in <double>[0.23, 0.73]) {
      canvas.drawCircle(Offset(w * x, h * 0.75), h * 0.15, wheelPaint);
      canvas.drawCircle(Offset(w * x, h * 0.75), h * 0.075, hubPaint);
      canvas.drawCircle(
        Offset(w * x, h * 0.75),
        h * 0.14,
        Paint()
          ..color = const Color(0x99D99A3A)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
    }

    canvas.drawLine(
      Offset(w * 0.14, h * 0.66),
      Offset(w * 0.86, h * 0.66),
      Paint()
        ..color = const Color(0xFF5D3923)
        ..strokeWidth = math.max(1.2, h * 0.045),
    );
  }

  @override
  bool shouldRepaint(covariant _CaravanWagonPainter oldDelegate) {
    return oldDelegate.caravan != caravan;
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
        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
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
                  style: const TextStyle(fontWeight: FontWeight.w900),
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
  const _EndBanner({required this.title, required this.summary});

  final String title;
  final String summary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: _InfoCard(
        title: title,
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
          if (leading != null) ...<Widget>[leading!, const SizedBox(width: 9)],
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
