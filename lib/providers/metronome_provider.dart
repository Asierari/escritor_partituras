import 'dart:async';
import 'package:flutter/material.dart';
import 'package:escritor_partituras/models/metronome_settings.dart';
import 'package:just_audio/just_audio.dart';

class MetronomeProvider extends ChangeNotifier {
  // Aquí puedes agregar las propiedades y métodos necesarios para el metrónomo
  MetronomeSettings settings = MetronomeSettings();
  bool isPlaying = false;

  late Stopwatch _stopwatch;
  int _tickCount = 0;
  Timer? _timer;

  int _currentBeat = -1;
  int _compas = 1;

  final AudioPlayer _player = AudioPlayer();
  final AudioPlayer _strongPlayer = AudioPlayer();

  DateTime _lastTickTime = DateTime.now();

  MetronomeProvider() {
    _player.setAsset('assets/sounds/metronome.wav');
    _strongPlayer.setAsset('assets/sounds/metronome_strong.wav');
  }
  
  Future<void> init() async {
    // Inicialización si es necesaria
  }
  // ---------------- Getters ----------------

  int get currentBeat => _currentBeat;

  int get compas => _compas;

  Duration get _interval =>
    Duration(microseconds: (60000000 / settings.bpm).round());

  DateTime get lastTickTime => _lastTickTime;

  // ---------------- Acciones ----------------

  void _scheduleNextTick() {
    final expectedTime =
        _interval.inMicroseconds * _tickCount;

    final now = _stopwatch.elapsedMicroseconds;
    final delay = expectedTime - now;

    _timer = Timer(
      Duration(microseconds: delay > 0 ? delay : 0),
      _onTick,
    );
  }

  void _onTick() {
    _lastTickTime = DateTime.now();
    _playBeat();
    _tickCount++;
    _scheduleNextTick();
  }

  Future<void> startMetronome() async {
    // Lógica para iniciar el metrónomo
    if (isPlaying) return;

    isPlaying = true;
    _currentBeat = -1;
    _compas = 1;
    _tickCount = 0;

    _stopwatch = Stopwatch()..start();

    _scheduleNextTick();
    notifyListeners();
  }

  void stopMetronome() {
    // Lógica para detener el metrónomo
    _timer?.cancel();
    _stopwatch.stop();

    isPlaying = false;
    _currentBeat = -1;
    _compas = 1;
    notifyListeners();
  }

  void _playBeat() {
    _currentBeat = (_currentBeat + 1) % settings.beatsPerMeasure;
    if (_currentBeat == 0) {
      _strongPlayer.seek(Duration.zero);
      _strongPlayer.play();
    } else {
      _player.seek(Duration.zero);
      _player.play();
    }
    
    if (_currentBeat == 0) {
      _compas = _compas == 0 ? 1 : 0;
    }
    notifyListeners();
  }


  void updateBpm(int bpm) {
    settings.bpm = bpm;
    if (isPlaying) {
      stopMetronome();
      startMetronome();
    }
    notifyListeners();
  }

  /// Actualiza el compás (numerador y denominador), por ejemplo 4/4, 3/4, 6/8
  void updateTimeSignature(int beatsPerMeasure, int beatUnit) {
    settings.beatsPerMeasure = beatsPerMeasure;
    settings.beatUnit = beatUnit;
    notifyListeners();
  }

  void updateAnimationType(String animationType) {
    settings.animationType = animationType;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _player.dispose();
    _strongPlayer.dispose();
    super.dispose();
  }
}