import 'dart:io';
import 'dart:typed_data';
import '../models/audio_buffer.dart';
import 'package:flutter/foundation.dart';

// ⚠️ FUNCIÓN TOP-LEVEL
Future<AudioBuffer> readWavInIsolate(String filePath) async {
  return AudioReader.readWav(filePath);
}

class AudioReader {
  static Future<AudioBuffer> readWav(String path) async {
    final bytes = await File(path).readAsBytes();
    final data = ByteData.sublistView(bytes);

    // --- WAV HEADER ---
    final sampleRate = data.getUint32(24, Endian.little);
    final bitsPerSample = data.getUint16(34, Endian.little);
    final dataSize = data.getUint32(40, Endian.little);

    if (bitsPerSample != 16) {
      throw Exception('Solo WAV PCM 16-bit soportado');
    }

    final pcmStart = 44;
    final pcmBytes = bytes.sublist(pcmStart, pcmStart + dataSize);

    final samples = <double>[];

    for (int i = 0; i < pcmBytes.length; i += 2) {
      final sample = ByteData.sublistView(
        Uint8List.fromList(pcmBytes),
        i,
        i + 2,
      ).getInt16(0, Endian.little);

      samples.add(sample / 32768.0);
    }

    return AudioBuffer(
      samples: samples,
      sampleRate: sampleRate,
    );
  }
}
