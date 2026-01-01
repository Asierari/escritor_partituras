import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:escritor_partituras/widgets/bpm_selector.dart';
import 'package:escritor_partituras/widgets/metronome_visual.dart';
import 'package:escritor_partituras/providers/metronome_provider.dart';
import 'package:escritor_partituras/providers/recording_provider.dart';
import 'package:escritor_partituras/providers/analysis_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class MetronomePage extends StatefulWidget {
  const MetronomePage({super.key});

  @override
  State<MetronomePage> createState() => _MetronomePageState();
}

class _MetronomePageState extends State<MetronomePage> {

 // ---------------- Helpers ----------------
  Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();

    return status == PermissionStatus.granted;
  }
  
  String formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final tenths = (d.inMilliseconds % 1000 ~/ 100);

    return '$minutes:$seconds.$tenths';
  }

  @override
  Widget build(BuildContext context) {
    final metronomeProvider = context.watch<MetronomeProvider>();
    final recordingProvider = context.watch<RecordingProvider>();
    final settings = metronomeProvider.settings;
    final isRecording =
    recordingProvider.status == RecordingStatus.recording;
    final analysisProvider = context.read<AnalysisProvider>();
    

    Future<void> onStartRecording() async {
      final granted = await requestMicrophonePermission();

      if (!granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permiso de micrófono denegado'),
          ),
        );
        return;
      }

      recordingProvider.startRecording();
    }

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
                    metronomeProvider.updateAnimationType(v);
                  },
                ),
              ],
            ),
          ),
          // Botón Play/Stop
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                FilledButton(
                  onPressed: () {
                    if (metronomeProvider.isPlaying) {
                      metronomeProvider.stopMetronome();
                    } else {
                      metronomeProvider.startMetronome();
                    }
                  },
                  child: Icon(metronomeProvider.isPlaying ? Icons.stop : Icons.play_arrow),
                ),
                FilledButton(
                  onPressed: () {
                    if (isRecording) {
                      recordingProvider.stopRecording();
                      final session = recordingProvider.currentSession;
                      if (session != null) {
                        analysisProvider.analyzeRecording(session.filePath);
                      }
                    } else {
                      onStartRecording();
                    }
                  },
                  child: Icon(isRecording ? Icons.stop : Icons.circle,
                      color: isRecording ? Colors.black : Colors.red),
                ),
                if (isRecording)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.fiber_manual_record,
                          color: Colors.red,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'REC ${formatDuration(recordingProvider.elapsed)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (analysisProvider.status == AnalysisStatus.loading)
            const Text('Analizando audio...'),

          if (analysisProvider.status == AnalysisStatus.ready && analysisProvider.buffer != null)
            Text(
              'Samples: ${analysisProvider.buffer!.length}\n'
              'Duración: ${analysisProvider.buffer!.durationSeconds.toStringAsFixed(2)} s',
            ),

          if (analysisProvider.status == AnalysisStatus.error)
            Text(
              'Error: ${analysisProvider.error}',
              style: const TextStyle(color: Colors.red),
            ),
          const SizedBox(width: 6),
        ],
      ),
    );
  }
}