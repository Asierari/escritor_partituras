import 'dart:async';
import 'package:flutter/material.dart';
import 'package:escritor_partituras/models/recording_sesion.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';

enum RecordingStatus {
  idle,
  recording,
  stopped,
}

class RecordingProvider extends ChangeNotifier {
  RecordingStatus _status = RecordingStatus.idle;
  RecordingStatus get status => _status;

  RecordingSession? _currentSession;
  RecordingSession? get currentSession => _currentSession;

  Duration _elapsed = Duration.zero;
  Duration get elapsed => _elapsed;

  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  Timer? _timer;

  static const int sampleRate = 44100;

  Future<void> init() async {
    await _recorder.openRecorder();
    await _recorder.setSubscriptionDuration(
      const Duration(milliseconds: 100),
    );
  }

  Future<void> startRecording({
    required VoidCallback startMetronome,
  }) async {
    if (_status == RecordingStatus.recording) return;

    final filePath = await _generateFilePath();

    startMetronome();

    await _recorder.startRecorder(
      toFile: filePath,
      codec: Codec.pcm16WAV,
      sampleRate: sampleRate,
      numChannels: 1,
    );

    _currentSession = RecordingSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      filePath: filePath,
      sampleRate: sampleRate,
      startedAt: DateTime.now(),
      duration: Duration.zero,
    );

    _elapsed = Duration.zero;
    _startTimer();

    _status = RecordingStatus.recording;
    notifyListeners();
  }


  Future<void> stopRecording({
    required VoidCallback stopMetronome,
  }) async {
    if (_status != RecordingStatus.recording) return;

    stopMetronome();

    await _recorder.stopRecorder();
    _stopTimer();

    _currentSession = _currentSession?.copyWith(
      duration: _elapsed,
    );

    _status = RecordingStatus.stopped;
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(milliseconds: 100),
      (_) {
        _elapsed += const Duration(milliseconds: 100);
        notifyListeners();
      },
    );
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  Future<String> _generateFilePath() async {
    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${dir.path}/recording_$timestamp.wav';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _recorder.closeRecorder();
    super.dispose();
  }
}


