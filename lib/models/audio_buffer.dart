class AudioBuffer {
  final List<double> samples; // normalizados [-1.0, 1.0]
  final int sampleRate;

  AudioBuffer({
    required this.samples,
    required this.sampleRate,
  });

  int get length => samples.length;
  double get durationSeconds => samples.length / sampleRate;
}
