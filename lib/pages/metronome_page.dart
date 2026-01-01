import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:escritor_partituras/widgets/bpm_selector.dart';
import 'package:escritor_partituras/widgets/metronome_visual.dart';
import 'package:escritor_partituras/providers/metronome_provider.dart';
import 'package:escritor_partituras/providers/recording_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class MetronomePage extends StatefulWidget {
  const MetronomePage({super.key});

  @override
  State<MetronomePage> createState() => _MetronomePageState();
}

class _MetronomePageState extends State<MetronomePage> {

  Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();

    return status == PermissionStatus.granted;
  }
  
  @override
  Widget build(BuildContext context) {
    final metronomeProvider = context.watch<MetronomeProvider>();
    final recordingProvider = context.watch<RecordingProvider>();
    final settings = metronomeProvider.settings;
    final isRecording =
    recordingProvider.status == RecordingStatus.recording;


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
                    } else {
                      onStartRecording();
                    }
                  },
                  child: Icon(isRecording ? Icons.stop : Icons.circle),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}