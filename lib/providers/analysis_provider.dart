import 'package:flutter/foundation.dart';
import '../models/audio_buffer.dart';
import '../services/audio_reader.dart';

enum AnalysisStatus {
  idle,
  loading,
  ready,
  error,
}

class AnalysisProvider extends ChangeNotifier {
  AnalysisStatus _status = AnalysisStatus.idle;
  AnalysisStatus get status => _status;

  AudioBuffer? _buffer;
  AudioBuffer? get buffer => _buffer;

  String? _error;
  String? get error => _error;

  // -------- Public API --------

  Future<void> analyzeRecording(String filePath) async {
    _status = AnalysisStatus.loading;
    _error = null;
    notifyListeners();

    try {
      // ⚠️ pesado → pero fuera del RecordingProvider
      final audioBuffer = await compute(
        readWavInIsolate,
        filePath,
      );

      _buffer = audioBuffer;
      _status = AnalysisStatus.ready;
    } catch (e) {
      _status = AnalysisStatus.error;
      _error = e.toString();
    }

    notifyListeners();
  }

  void reset() {
    _buffer = null;
    _status = AnalysisStatus.idle;
    _error = null;
    notifyListeners();
  }
}
