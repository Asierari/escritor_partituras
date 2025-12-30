class MetronomeSettings {
  int bpm;
  String soundType;
  /// Número de pulsos por compás (ej. 4 en 4/4, 3 en 3/4)
  int beatsPerMeasure;
  /// Unidad de pulso (denominador del compás, ej. 4 para negra en 4/4)
  int beatUnit;
  String animationType;

  MetronomeSettings({
    this.bpm = 120,
    this.animationType = 'bar',
    this.soundType = 'click',
    this.beatsPerMeasure = 4,
    this.beatUnit = 4,
  });
}