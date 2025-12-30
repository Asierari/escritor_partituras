import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:escritor_partituras/providers/metronome_provider.dart';
import 'package:escritor_partituras/models/metronome_settings.dart';

class BpmSelector extends StatefulWidget {
  final MetronomeSettings settings;
  const BpmSelector({super.key, required this.settings});

  @override
  State<BpmSelector> createState() => _BpmSelectorState();
}

class _BpmSelectorState extends State<BpmSelector> {
  late TextEditingController _animationTypeController;

  @override
  void initState() {
    super.initState();
    _animationTypeController = TextEditingController(text: widget.settings.animationType);
  }

  @override
  void dispose() {
    _animationTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MetronomeProvider>();
    // Opciones de compás disponibles
    final signatures = [
      {'beats': 4, 'unit': 4},
      {'beats': 3, 'unit': 4},
      {'beats': 2, 'unit': 4},
      {'beats': 6, 'unit': 8},
      {'beats': 5, 'unit': 4},
    ];

    final items = signatures.map((s) {
      final label = '${s['beats']}/${s['unit']}';
      return DropdownMenuItem<String>(
        value: label,
        child: Text(label),
      );
    }).toList();

    final currentSignature = '${widget.settings.beatsPerMeasure}/${widget.settings.beatUnit}';

    // Implementación del selector de BPM con dropdown de compases y animation type
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text('Selecciona el BPM'),
                  Slider(
                    value: widget.settings.bpm.toDouble(),
                    min: 40,
                    max: 208,
                    divisions: 168,
                    label: widget.settings.bpm.toString(),
                    onChanged: (double value) {
                            provider.updateBpm(value.toInt());
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('Compas'),
                const SizedBox(height: 4),
                DropdownButton<String>(
                  value: currentSignature,
                  items: items,
                  onChanged: (String? value) {
                    if (value == null) return;
                    final parts = value.split('/');
                    final beats = int.tryParse(parts[0]) ?? widget.settings.beatsPerMeasure;
                    final unit = int.tryParse(parts[1]) ?? widget.settings.beatUnit;
                    provider.updateTimeSignature(beats, unit);
                  },
                ),
              ],
            ),
            const SizedBox(width: 20),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}