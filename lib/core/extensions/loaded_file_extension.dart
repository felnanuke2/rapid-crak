import 'dart:typed_data';

import '../domain/entities/attack_entities.dart' as core;
import '../../features/password_cracker/domain/entities/attack_entities.dart' as feature;

/// Extension to convert core LoadedFile to feature LoadedFile
extension LoadedFileExtension on core.LoadedFile {
  /// Converts core domain LoadedFile to feature domain LoadedFile
  feature.LoadedFile toFeatureLoadedFile(Uint8List bytes) {
    return feature.LoadedFile(
      path: path,
      name: name,
      sizeInBytes: sizeInBytes,
      loadedAt: loadedAt,
      bytes: bytes,
    );
  }
}
