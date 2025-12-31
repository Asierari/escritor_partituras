import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:escritor_partituras/widgets/bpm_selector.dart';
import 'package:escritor_partituras/widgets/metronome_visual.dart';
import 'package:escritor_partituras/providers/metronome_provider.dart';
import 'package:escritor_partituras/providers/recording_provider.dart';

class MetronomePage extends StatefulWidget {
  const MetronomePage({super.key});

  @override
  State<MetronomePage> createState() => _MetronomePageState();
}

class _MetronomePageState extends State<MetronomePage> {
  
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MetronomeProvider>();
    final recordingProvider = context.watch<RecordingProvider>();
    final settings = provider.settings;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Metrónomo'),
      ),
      body: Column(
        children: [
          // Visualizador del metrónomo
          Expanded(
            child: settings.animationType == 'circle'
                ? MetronomeVisual(parentContext: context)
                : MetronomeStaff(height: 60,),
          ),
          // Selector de BPM
          BpmSelector(settings: settings),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                const Text('Visualizador:'),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: settings.animationType,
                  items: const [
                    DropdownMenuItem(value: 'circle', child: Text('Circle')),
                    DropdownMenuItem(value: 'bar', child: Text('Bar')),
                  ],
                  onChanged: (String? v) {
                    if (v == null) return;
                    provider.updateAnimationType(v);
                  },
                ),
              ],
            ),
          ),
          // Botón Play/Stop
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: FilledButton(
              onPressed: () {
                if (provider.isPlaying) {
                  recordingProvider.stopRecording(
                    stopMetronome: () {
                      provider.stopMetronome();
                    },
                  );
                } else {
                  recordingProvider.startRecording(
                    startMetronome: () {
                      provider.startMetronome();
                    },
                  );
                }
              },
              child: Icon(provider.isPlaying ? Icons.stop : Icons.play_arrow),
            ),
          )
        ],
      ),
    );
  }
}