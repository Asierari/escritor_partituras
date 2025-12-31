class RecordingSession {
  final String id;
  final String filePath;
  final int sampleRate;
  final DateTime startedAt;
  final Duration duration;

  RecordingSession({
    required this.id,
    required this.filePath,
    required this.sampleRate,
    required this.startedAt,
    required this.duration,
  });

  RecordingSession copyWith({
    Duration? duration,
  }) {
    return RecordingSession(
      id: id,
      filePath: filePath,
      sampleRate: sampleRate,
      startedAt: startedAt,
      duration: duration ?? this.duration,
    );
  }
}
