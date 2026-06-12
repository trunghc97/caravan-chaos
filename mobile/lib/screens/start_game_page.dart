import 'package:flutter/material.dart';

import 'game_page.dart';

const String _startBackgroundAsset = 'assets/market/start-background.png';
const String _startIconAsset = 'assets/market/app-icon.png';

const Color _startInk = Color(0xFF071D22);
const Color _startTeal = Color(0xFF063D47);
const Color _startGold = Color(0xFFFFC34A);
const Color _startCream = Color(0xFFFFF2C6);
const Color _startSpice = Color(0xFFE4572E);
const Color _startAqua = Color(0xFF39D3D8);
const Color _startPaper = Color(0xFFFFFAEE);
const Color _startMuted = Color(0xFF66737A);

enum _StartLanguage { vi, en }

class StartGamePage extends StatefulWidget {
  const StartGamePage({super.key});

  @override
  State<StartGamePage> createState() => _StartGamePageState();
}

class _StartGamePageState extends State<StartGamePage> {
  _StartLanguage _language = _StartLanguage.vi;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _startInk,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          const _MarketplaceBackground(),
          SafeArea(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final bool wide = constraints.maxWidth >= 760;
                final double maxWidth = wide ? 560 : 520;

                return Align(
                  alignment: wide ? Alignment.centerLeft : Alignment.center,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      wide ? 48 : 18,
                      18,
                      wide ? 18 : 18,
                      18,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxWidth),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          _HeroBrand(language: _language),
                          SizedBox(height: wide ? 28 : 18),
                          _StartActionPanel(
                            language: _language,
                            onLanguageChanged: (Set<_StartLanguage> value) {
                              setState(() => _language = value.first);
                            },
                            onPlayBot: () => _openBotGame(context),
                            onTutorials: () => _showTutorials(context),
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

  void _openBotGame(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const CaravanGamePage(),
      ),
    );
  }

  void _showTutorials(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: _startPaper,
      constraints: const BoxConstraints(maxWidth: 560),
      builder: (BuildContext context) => _TutorialSheet(language: _language),
    );
  }
}

class _MarketplaceBackground extends StatelessWidget {
  const _MarketplaceBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Image.asset(
          _startBackgroundAsset,
          fit: BoxFit.cover,
          alignment: Alignment.centerRight,
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: <Color>[
                Color(0xC8031A21),
                Color(0x62031A21),
                Color(0x10031A21),
              ],
              stops: <double>[0, 0.42, 1],
            ),
          ),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                Color(0x85001B24),
                Color(0x00001B24),
                Color(0x84001B24),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroBrand extends StatelessWidget {
  const _HeroBrand({required this.language});

  final _StartLanguage language;

  String _t(String vi, String en) {
    return language == _StartLanguage.vi ? vi : en;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(
              height: 58,
              width: 58,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white.withOpacity(0.55)),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    blurRadius: 24,
                    color: Color(0x66000000),
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(_startIconAsset, fit: BoxFit.cover),
            ),
            const SizedBox(width: 12),
            const _MvpBadge(),
          ],
        ),
        const SizedBox(height: 22),
        const Text(
          'CARAVAN',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: _startCream,
            fontSize: 58,
            fontWeight: FontWeight.w900,
            height: 0.88,
            shadows: <Shadow>[
              Shadow(
                color: Color(0xDD001017),
                offset: Offset(4, 5),
                blurRadius: 0,
              ),
            ],
          ),
        ),
        const Text(
          'CHAOS',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: _startGold,
            fontSize: 58,
            fontWeight: FontWeight.w900,
            height: 0.96,
            shadows: <Shadow>[
              Shadow(
                color: Color(0xDD001017),
                offset: Offset(4, 5),
                blurRadius: 0,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          _t(
            'Đua lữ hành. Đặt cược. Lật kèo phiên chợ.',
            'Race caravans. Bet smart. Break the market.',
          ),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            height: 1.12,
            shadows: <Shadow>[
              Shadow(
                color: Color(0xC9001118),
                offset: Offset(2, 2),
                blurRadius: 2,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _t(
            'Bản solo MVP1 - playable prototype',
            'Solo MVP1 - playable prototype',
          ),
          style: const TextStyle(
            color: _startAqua,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            shadows: <Shadow>[
              Shadow(
                color: Color(0xCC001118),
                offset: Offset(2, 2),
                blurRadius: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MvpBadge extends StatelessWidget {
  const _MvpBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 8),
      decoration: BoxDecoration(
        color: _startGold,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            blurRadius: 12,
            color: Color(0x66000000),
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: const Text(
        'MVP1 SOLO',
        style: TextStyle(
          color: _startTeal,
          fontSize: 17,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
    );
  }
}

class _StartActionPanel extends StatelessWidget {
  const _StartActionPanel({
    required this.language,
    required this.onLanguageChanged,
    required this.onPlayBot,
    required this.onTutorials,
  });

  final _StartLanguage language;
  final ValueChanged<Set<_StartLanguage>> onLanguageChanged;
  final VoidCallback onPlayBot;
  final VoidCallback onTutorials;

  String _t(String vi, String en) {
    return language == _StartLanguage.vi ? vi : en;
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xD708252D),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.24)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            blurRadius: 32,
            color: Color(0x77000000),
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    _t('Chọn chế độ', 'Choose mode'),
                    style: const TextStyle(
                      color: _startCream,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                _StartLanguageToggle(
                  language: language,
                  onChanged: onLanguageChanged,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _StartMenuButton(
              icon: Icons.smart_toy_rounded,
              title: _t('Chơi với Bot', 'Play with Bot'),
              subtitle: _t(
                'Vào bàn solo, bot tự hành động theo lượt',
                'Solo table with turn-based AI rivals',
              ),
              color: _startSpice,
              filled: true,
              onPressed: onPlayBot,
            ),
            const SizedBox(height: 10),
            _StartMenuButton(
              icon: Icons.groups_2_rounded,
              title: _t('Chơi với Người', 'Play with Human'),
              subtitle: _t('Sắp ra mắt', 'Coming soon'),
              color: _startTeal,
            ),
            const SizedBox(height: 10),
            _StartMenuButton(
              icon: Icons.menu_book_rounded,
              title: _t('Hướng dẫn', 'Tutorials'),
              subtitle: _t(
                'Luật lượt, gió, cược và dấu đường',
                'Turns, wind, contracts, and route marks',
              ),
              color: _startAqua,
              onPressed: onTutorials,
            ),
          ],
        ),
      ),
    );
  }
}

class _StartMenuButton extends StatelessWidget {
  const _StartMenuButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.filled = false,
    this.onPressed,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool filled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null;
    final Color foreground = filled ? Colors.white : color;
    final Color background = filled
        ? color
        : enabled
            ? Colors.white.withOpacity(0.9)
            : Colors.white.withOpacity(0.28);

    return SizedBox(
      height: 74,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: enabled
              ? LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: filled
                      ? <Color>[color, const Color(0xFFFF815A)]
                      : <Color>[
                          Colors.white.withOpacity(0.94),
                          Colors.white.withOpacity(0.82),
                        ],
                )
              : LinearGradient(
                  colors: <Color>[
                    Colors.white.withOpacity(0.34),
                    Colors.white.withOpacity(0.22),
                  ],
                ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: enabled ? Colors.white.withOpacity(0.34) : Colors.white24,
          ),
          boxShadow: enabled
              ? const <BoxShadow>[
                  BoxShadow(
                    blurRadius: 22,
                    color: Color(0x55000000),
                    offset: Offset(0, 10),
                  ),
                ]
              : null,
        ),
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: background.withOpacity(0.0),
            disabledBackgroundColor: Colors.transparent,
            foregroundColor: foreground,
            disabledForegroundColor: Colors.white.withOpacity(0.52),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 0,
          ),
          child: Row(
            children: <Widget>[
              Icon(icon, size: 29),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: enabled
                            ? foreground.withOpacity(filled ? 0.84 : 0.72)
                            : Colors.white.withOpacity(0.52),
                      ),
                    ),
                  ],
                ),
              ),
              if (enabled)
                Icon(
                  filled
                      ? Icons.play_arrow_rounded
                      : Icons.chevron_right_rounded,
                  size: 29,
                )
              else
                const Icon(Icons.lock_clock_rounded, size: 23),
            ],
          ),
        ),
      ),
    );
  }
}

class _StartLanguageToggle extends StatelessWidget {
  const _StartLanguageToggle({
    required this.language,
    required this.onChanged,
  });

  final _StartLanguage language;
  final ValueChanged<Set<_StartLanguage>> onChanged;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: _startGold,
              secondaryContainer: _startGold,
              onSecondaryContainer: _startTeal,
            ),
      ),
      child: SegmentedButton<_StartLanguage>(
        segments: const <ButtonSegment<_StartLanguage>>[
          ButtonSegment<_StartLanguage>(
            value: _StartLanguage.vi,
            label: Text('VI'),
          ),
          ButtonSegment<_StartLanguage>(
            value: _StartLanguage.en,
            label: Text('EN'),
          ),
        ],
        selected: <_StartLanguage>{language},
        onSelectionChanged: onChanged,
        showSelectedIcon: false,
        style: ButtonStyle(
          visualDensity: VisualDensity.compact,
          padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
            const EdgeInsets.symmetric(horizontal: 8),
          ),
          textStyle: MaterialStateProperty.all<TextStyle>(
            const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
          ),
          side: MaterialStateProperty.all<BorderSide>(
            BorderSide(color: Colors.white.withOpacity(0.34)),
          ),
          foregroundColor: MaterialStateProperty.all<Color>(_startCream),
          backgroundColor: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.selected)) {
                return _startGold;
              }
              return Colors.white.withOpacity(0.08);
            },
          ),
        ),
      ),
    );
  }
}

class _TutorialSheet extends StatelessWidget {
  const _TutorialSheet({required this.language});

  final _StartLanguage language;

  String _t(String vi, String en) {
    return language == _StartLanguage.vi ? vi : en;
  }

  @override
  Widget build(BuildContext context) {
    final List<_TutorialData> steps = <_TutorialData>[
      _TutorialData(
        icon: Icons.person_pin_circle_rounded,
        title: _t('1. Lượt chơi', '1. Turn order'),
        body: _t(
          'Đầu trận, hệ thống xáo ngẫu nhiên thứ tự giữa bạn và các bot. Trên bàn luôn hiện ai đang đến lượt. Chỉ người đang giữ lượt mới được bấm hành động.',
          'At the start, the game shuffles the order between you and the bots. The board always shows whose turn it is. Only the active player can act.',
        ),
      ),
      _TutorialData(
        icon: Icons.touch_app_rounded,
        title: _t('2. Mỗi lượt chỉ một hành động', '2. One action per turn'),
        body: _t(
          'Bạn có thể rút gió, ký hợp đồng, đặt ốc đảo/ảo ảnh, hoặc dùng sự kiện. Khi hành động xong, lượt tự chuyển cho người tiếp theo.',
          'You may draw wind, sign a contract, place an oasis/mirage, or trigger an event. After one action, the turn passes to the next player.',
        ),
      ),
      _TutorialData(
        icon: Icons.air_rounded,
        title: _t('3. Rút gió và di chuyển', '3. Wind and movement'),
        body: _t(
          'Rút gió chọn ngẫu nhiên một đoàn chưa di chuyển trong ngày và đẩy 1-3 ô. Nếu đoàn đang chồng lên nhau, các đoàn phía trên đi theo cùng.',
          'Drawing wind selects one caravan that has not moved this day and pushes it 1-3 spaces. If caravans are stacked, the ones above ride along.',
        ),
      ),
      _TutorialData(
        icon: Icons.swap_vert_rounded,
        title: _t('4. Dấu đường', '4. Route marks'),
        body: _t(
          'Ốc đảo tăng thêm 1 ô khi đoàn đi tới. Ảo ảnh kéo lùi 1 ô. Mỗi người chỉ đặt được một dấu đường mỗi chặng, nên hãy chọn ô thật kỹ.',
          'An oasis boosts a caravan by 1 when it lands there. A mirage pulls it back by 1. Each player can place one route mark per leg.',
        ),
      ),
      _TutorialData(
        icon: Icons.receipt_long_rounded,
        title: _t('5. Hợp đồng và điểm', '5. Contracts and scoring'),
        body: _t(
          'Hợp đồng chặng trả thưởng khi hết ngày. Hợp đồng chung cuộc trả thưởng lúc có đoàn về đích. Bạn thắng phiên chợ bằng cách giữ nhiều dinar nhất.',
          'Leg contracts pay at the end of a day. Final contracts pay when a caravan reaches the finish. Win the market by ending with the most coins.',
        ),
      ),
      _TutorialData(
        icon: Icons.visibility_rounded,
        title: _t('6. Theo dõi realtime', '6. Realtime board state'),
        body: _t(
          'Mỗi thao tác của bot được cập nhật trực tiếp trên bàn và trong sổ cái. Khi lên multiplayer, các thao tác này sẽ được broadcast cho mọi người xem cùng lúc.',
          'Every bot action updates the board and ledger immediately. In multiplayer, these actions will be broadcast so everyone sees the same table.',
        ),
      ),
    ];

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              _t('Hướng dẫn', 'Tutorials'),
              style: const TextStyle(
                color: _startInk,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _t(
                'Nắm vòng lượt trước, rồi hãy đặt cược.',
                'Learn the turn loop first, then start betting.',
              ),
              style: const TextStyle(
                color: _startMuted,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            for (final _TutorialData step in steps) _TutorialStep(data: step),
          ],
        ),
      ),
    );
  }
}

class _TutorialData {
  const _TutorialData({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;
}

class _TutorialStep extends StatelessWidget {
  const _TutorialStep({required this.data});

  final _TutorialData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4CF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x22B98543)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 34,
            width: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _startTeal,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(data.icon, color: _startGold, size: 19),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  data.title,
                  style: const TextStyle(
                    color: _startInk,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  data.body,
                  style: const TextStyle(
                    color: _startMuted,
                    fontSize: 13,
                    height: 1.35,
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
