import 'package:flutter/material.dart';

import 'game_page.dart';

const Color _startInk = Color(0xFF17202A);
const Color _startMuted = Color(0xFF66737A);
const Color _startMarketTeal = Color(0xFF0F4C5C);
const Color _startDeepIndigo = Color(0xFF263858);
const Color _startSpice = Color(0xFFE4572E);
const Color _startSunGold = Color(0xFFF2C14E);
const Color _startOasisGreen = Color(0xFF2D936C);
const Color _startSandLight = Color(0xFFF9E8C7);
const Color _startPaper = Color(0xFFFFFAEE);

class StartGamePage extends StatelessWidget {
  const StartGamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _startSandLight,
      body: Stack(
        children: <Widget>[
          const Positioned.fill(child: _StartBackdrop()),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const _StartHeader(),
                      const SizedBox(height: 18),
                      _StartMenuButton(
                        icon: Icons.smart_toy_rounded,
                        title: 'Play with Bot',
                        subtitle: 'Solo race with 3 AI rivals',
                        color: _startSpice,
                        filled: true,
                        onPressed: () => _openBotGame(context),
                      ),
                      const SizedBox(height: 10),
                      const _StartMenuButton(
                        icon: Icons.groups_2_rounded,
                        title: 'Play with Human',
                        subtitle: 'Coming soon',
                        color: _startMarketTeal,
                      ),
                      const SizedBox(height: 10),
                      _StartMenuButton(
                        icon: Icons.menu_book_rounded,
                        title: 'Tutorials',
                        subtitle: 'Learn movement, betting, and route marks',
                        color: _startOasisGreen,
                        onPressed: () => _showTutorials(context),
                      ),
                    ],
                  ),
                ),
              ),
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
      builder: (BuildContext context) {
        return const _TutorialSheet();
      },
    );
  }
}

class _StartHeader extends StatelessWidget {
  const _StartHeader();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _startPaper.withOpacity(0.95),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x33B98543)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            blurRadius: 30,
            color: Color(0x2417202A),
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  height: 58,
                  width: 58,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[_startMarketTeal, _startDeepIndigo],
                    ),
                    borderRadius: BorderRadius.circular(16),
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
                    color: _startSunGold,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Caravan Chaos',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _startInk,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Desert racing, stacked caravans, risky contracts.',
                        style: TextStyle(
                          color: _startMuted,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
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
    final Color background = filled ? color : _startPaper.withOpacity(0.9);

    return SizedBox(
      height: 78,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: enabled ? background : _startPaper.withOpacity(0.72),
          disabledBackgroundColor: _startPaper.withOpacity(0.72),
          foregroundColor: foreground,
          disabledForegroundColor: _startMuted.withOpacity(0.68),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color:
                  enabled ? color.withOpacity(0.44) : const Color(0x22B98543),
            ),
          ),
          elevation: filled ? 3 : 0,
        ),
        child: Row(
          children: <Widget>[
            Icon(icon, size: 28),
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
                      fontSize: 17,
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
                      fontWeight: FontWeight.w700,
                      color: enabled
                          ? foreground.withOpacity(filled ? 0.82 : 0.74)
                          : _startMuted.withOpacity(0.68),
                    ),
                  ),
                ],
              ),
            ),
            if (enabled)
              Icon(
                filled ? Icons.play_arrow_rounded : Icons.chevron_right_rounded,
                size: 28,
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
        color: const Color(0xFFFFF1C6),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x33B98543)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 14, color: _startSpice),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: _startInk,
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

class _StartBackdrop extends StatelessWidget {
  const _StartBackdrop();

  @override
  Widget build(BuildContext context) {
    return const CustomPaint(painter: _StartBackdropPainter());
  }
}

class _StartBackdropPainter extends CustomPainter {
  const _StartBackdropPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Paint sky = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[Color(0xFFFFEAB6), Color(0xFFF1C076)],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, sky);

    final Paint farDune = Paint()..color = const Color(0x55FFF4D2);
    final Path farPath = Path()
      ..moveTo(0, size.height * 0.55)
      ..quadraticBezierTo(
        size.width * 0.35,
        size.height * 0.44,
        size.width,
        size.height * 0.54,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(farPath, farDune);

    final Paint nearDune = Paint()..color = const Color(0x44A8612E);
    final Path nearPath = Path()
      ..moveTo(0, size.height * 0.72)
      ..quadraticBezierTo(
        size.width * 0.54,
        size.height * 0.6,
        size.width,
        size.height * 0.72,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(nearPath, nearDune);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
