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

class StartGamePage extends StatelessWidget {
  const StartGamePage({super.key});

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
                          const _HeroBrand(),
                          SizedBox(height: wide ? 28 : 18),
                          _StartActionPanel(
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
      builder: (BuildContext context) => const _TutorialSheet(),
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
  const _HeroBrand();

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
        const Text(
          'Đua lữ hành. Đặt cược. Lật kèo phiên chợ.',
          style: TextStyle(
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
        const Text(
          'Bản solo MVP1 - playable prototype',
          style: TextStyle(
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
    required this.onPlayBot,
    required this.onTutorials,
  });

  final VoidCallback onPlayBot;
  final VoidCallback onTutorials;

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
            _StartMenuButton(
              icon: Icons.smart_toy_rounded,
              title: 'Play with Bot',
              subtitle: 'Solo race with 3 AI rivals',
              color: _startSpice,
              filled: true,
              onPressed: onPlayBot,
            ),
            const SizedBox(height: 10),
            const _StartMenuButton(
              icon: Icons.groups_2_rounded,
              title: 'Play with Human',
              subtitle: 'Coming soon',
              color: _startTeal,
            ),
            const SizedBox(height: 10),
            _StartMenuButton(
              icon: Icons.menu_book_rounded,
              title: 'Tutorials',
              subtitle: 'Learn movement, betting, and route marks',
              color: _startAqua,
              onPressed: onTutorials,
            ),
            const SizedBox(height: 12),
            const Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                _StartChip(icon: Icons.flag_rounded, label: '16 spaces'),
                _StartChip(icon: Icons.casino_rounded, label: 'Bot MVP'),
                _StartChip(icon: Icons.toll_rounded, label: 'Bet market'),
              ],
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
    final Color background = filled ? color : _startPaper.withOpacity(0.94);

    return SizedBox(
      height: 76,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: enabled ? background : _startPaper.withOpacity(0.64),
          disabledBackgroundColor: _startPaper.withOpacity(0.64),
          foregroundColor: foreground,
          disabledForegroundColor: Colors.white.withOpacity(0.52),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(
              color: enabled
                  ? color.withOpacity(0.64)
                  : Colors.white.withOpacity(0.14),
            ),
          ),
          elevation: filled ? 6 : 0,
          shadowColor: const Color(0x77000000),
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
                filled ? Icons.play_arrow_rounded : Icons.chevron_right_rounded,
                size: 29,
              )
            else
              const Icon(Icons.lock_clock_rounded, size: 23),
          ],
        ),
      ),
    );
  }
}

class _StartChip extends StatelessWidget {
  const _StartChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: _startGold.withOpacity(0.92),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 14, color: _startTeal),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: _startTeal,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _TutorialSheet extends StatelessWidget {
  const _TutorialSheet();

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 4, 20, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Tutorials',
              style: TextStyle(
                color: _startInk,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 12),
            _TutorialStep(
              icon: Icons.air_rounded,
              title: 'Draw wind',
              body:
                  'Each wind draw moves one caravan. Stacked caravans ride together.',
            ),
            _TutorialStep(
              icon: Icons.receipt_long_rounded,
              title: 'Sign contracts',
              body: 'Pick leg or final winners before the market shifts.',
            ),
            _TutorialStep(
              icon: Icons.swap_vert_rounded,
              title: 'Mark the route',
              body:
                  'Oasis boosts a move by 1. Mirage pulls a forward move back by 1.',
            ),
          ],
        ),
      ),
    );
  }
}

class _TutorialStep extends StatelessWidget {
  const _TutorialStep({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: _startSpice),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                    color: _startInk,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  body,
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
