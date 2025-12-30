import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/scheduler.dart';
import 'package:escritor_partituras/providers/metronome_provider.dart';

class MetronomeVisual extends StatefulWidget {
  final BuildContext parentContext;

  const MetronomeVisual({
    super.key,
    required this.parentContext,
  });

  @override
  State<MetronomeVisual> createState() => _MetronomeVisualState();
}

class _MetronomeVisualState extends State<MetronomeVisual>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
  }

  void _initializeAnimation() {
    final provider = widget.parentContext.read<MetronomeProvider>();
    final bpm = provider.settings.bpm;
    final beatDuration = Duration(milliseconds: (60000 / bpm).toInt());

    _animationController = AnimationController(
      duration: beatDuration,
      vsync: this,
    );

    // Escucha cambios de BPM y reinicia la animación
    if (!mounted) return;
    _animationController.repeat();
  }

  @override
  void didUpdateWidget(MetronomeVisual oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si el contexto cambia, reinicializar la animación
    _reinitializeAnimation();
  }

  void _reinitializeAnimation() {
    final provider = widget.parentContext.read<MetronomeProvider>();
    final bpm = provider.settings.bpm;
    final beatDuration = Duration(milliseconds: (60000 / bpm).toInt());

    _animationController.duration = beatDuration;
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = widget.parentContext.watch<MetronomeProvider>();
    final bpm = provider.settings.bpm;
    final beatDuration = Duration(milliseconds: (60000 / bpm).toInt());

    // Controlar la animación según el estado de playing
    if (provider.isPlaying && !_animationController.isAnimating) {
      _animationController.repeat();
    } else if (!provider.isPlaying && _animationController.isAnimating) {
      _animationController.stop();
      _animationController.reset();
    }

    // Actualizar la duración de la animación si cambió el BPM
    if (_animationController.duration != beatDuration) {
      _animationController.duration = beatDuration;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Círculo pulsante
          ScaleTransition(
            scale: Tween<double>(begin: 1.0, end: 1.3).animate(
              CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
            ),
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.withValues(alpha: 0.7),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withValues(alpha: 0.5),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.music_note,
                  size: 80,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          // Mostrar el BPM actual
          Text(
            '$bpm BPM',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class StaffPainter extends CustomPainter {
  final double horizontalPadding;

  const StaffPainter({this.horizontalPadding = 16.0});

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final rectPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final spacing = size.height / 6;

    // Dibujar las 5 líneas horizontales del pentagrama
    for (int i = 1; i <= 5; i++) {
      final y = spacing * i;
      canvas.drawLine(
        Offset(horizontalPadding, y),
        Offset(size.width - horizontalPadding, y),
        linePaint,
      );
    }

    // Dibujar barras verticales más anchas al inicio y al final
    final topY = spacing * 1;
    final bottomY = spacing * 5;
    final barWidth = 6.0;

    final leftBar = Rect.fromLTWH(horizontalPadding, topY - 1.0, barWidth, bottomY - topY + 2.0);
    final middleBar = Rect.fromLTWH(
      (size.width - barWidth) / 2,
      topY - 1.0,
      barWidth,
      bottomY - topY + 2.0,
    );
    final rightBar = Rect.fromLTWH(size.width - barWidth - horizontalPadding, topY - 1.0, barWidth, bottomY - topY + 2.0);

    canvas.drawRect(leftBar, rectPaint);
    canvas.drawRect(middleBar, rectPaint);
    canvas.drawRect(rightBar, rectPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MeasureBar extends StatelessWidget {
  final int currentBeat;
  final int beatsPerMeasure;
  final double horizontalPadding;

  const MeasureBar({
    super.key,
    required this.currentBeat,
    required this.beatsPerMeasure,
    this.horizontalPadding = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MetronomeProvider>();
    return SizedBox.expand(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth - 2 * horizontalPadding;
          final step = width / (beatsPerMeasure + 1) / 2;
          final initialOffset = horizontalPadding + step;
          final compasOffset = provider.compas * width / 2;
          final beatPosition = initialOffset + currentBeat * step + compasOffset;

          return Stack(
            children: [
              AnimatedPositioned(
                
                duration: const Duration(milliseconds: 10),
                curve: Curves.easeOut,
                left: beatPosition,
                top: 0,
                bottom: 0,
                child: BeatPulse(
                  isStrongBeat: currentBeat % beatsPerMeasure == 0,
                  currentBeat: currentBeat,
                  bpm: provider.settings.bpm,
                ),
              ),
              SmoothMeasureBar(
                currentBeat: currentBeat,
                beatsPerMeasure: beatsPerMeasure,
                lastTickTime: provider.lastTickTime,
                bpm: provider.settings.bpm,
                horizontalPadding: horizontalPadding,
                compas: provider.compas,
                step: step,
                position: beatPosition,
              ),
            ],
          );
        },
      ),
    );
  }
}

class BeatPulse extends StatelessWidget {
  final int currentBeat;
  final bool isStrongBeat;
  final double size;
  final int bpm;

  const BeatPulse({
    super.key,
    required this.currentBeat,
    required this.isStrongBeat,
    required this.bpm,
    this.size = 18,
  });

  @override
  Widget build(BuildContext context) {
    final maxScale = isStrongBeat ? 2.0 : 1.3;
    final color = isStrongBeat ? Colors.red : Colors.blue;

    return AnimatedScale(
      key: ValueKey(currentBeat), // 👈 reinicia la animación
      scale: maxScale,
      duration: Duration(milliseconds: (60000 / bpm / 2).round()),
      curve: Curves.easeOut,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: maxScale, end: 1.0),
        duration: Duration(milliseconds: (60000 / bpm / 2).round()),
        curve: Curves.easeIn,
        builder: (context, scale, child) {
          return Transform.scale(scale: scale, child: child);
        },
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
      ),
    );
  }
}


class SmoothMeasureBar extends StatefulWidget {
  final int currentBeat;
  final int beatsPerMeasure;
  final DateTime lastTickTime;
  final int bpm;
  final double horizontalPadding;
  final int compas;
  final double step;
  final double position;

  const SmoothMeasureBar({
    super.key,
    required this.currentBeat,
    required this.beatsPerMeasure,
    required this.lastTickTime,
    required this.bpm,
    required this.horizontalPadding,
    required this.compas,
    required this.step,
    required this.position,
  });

  @override
  State<SmoothMeasureBar> createState() => _SmoothMeasureBarState();
}

class _SmoothMeasureBarState extends State<SmoothMeasureBar>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((_) {
      if (mounted) setState(() {});
    })..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final beatDuration =
        Duration(microseconds: (60000000 / widget.bpm).round());

    return LayoutBuilder(
      builder: (context, constraints) {
        final now = DateTime.now();
        final elapsed = now.difference(widget.lastTickTime);

        final progress = (elapsed.inMicroseconds /
                beatDuration.inMicroseconds)
            .clamp(0.0, 1.0);

        final position =
            widget.position + progress * widget.step;

        return Transform.translate(
          offset: Offset(position, 0),
          child: Container(
            width: 4,
            height: constraints.maxHeight,
            color: Colors.black,
          ),
        );
      },
    );
  }
}


class MetronomeStaff extends StatelessWidget {
  final double height;
  final double horizontalPadding;

  const MetronomeStaff({
    super.key,
    this.height = 160,
    this.horizontalPadding = 16.0});

  @override
  Widget build(BuildContext context) {
    return Consumer<MetronomeProvider>(
      builder: (context, metronome, _) {
        return SizedBox(
          height: height,
          child: Stack(
            children: [
              CustomPaint(
                size: Size.infinite,
                painter: StaffPainter(horizontalPadding: horizontalPadding),
              ),
              if (metronome.isPlaying)
                MeasureBar(
                  currentBeat: metronome.currentBeat,
                  beatsPerMeasure:
                      metronome.settings.beatsPerMeasure,
                  horizontalPadding: horizontalPadding,
                ),
            ],
          ),
        );
      },
    );
  }
}
