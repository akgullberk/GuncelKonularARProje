import 'package:equatable/equatable.dart';

/// Balık türü — ileride AR model yolu ve SQLite/API alanları eklenebilir.
class FishSpecies extends Equatable {
  const FishSpecies({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.shortDescription,
    this.modelAssetPath,
  });

  final String id;
  final String name;
  final String scientificName;
  final String shortDescription;

  /// Örn. `assets/models/clownfish.glb` — AR adımında kullanılacak.
  final String? modelAssetPath;

  @override
  List<Object?> get props => [
        id,
        name,
        scientificName,
        shortDescription,
        modelAssetPath,
      ];
}
