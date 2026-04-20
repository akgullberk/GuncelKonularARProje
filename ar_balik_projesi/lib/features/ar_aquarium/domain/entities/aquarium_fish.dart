import 'package:equatable/equatable.dart';

class AquariumFish extends Equatable {
  const AquariumFish({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.description,
    required this.modelAssetPath,
  });

  final String id;
  final String name;
  final String scientificName;
  final String description;
  final String modelAssetPath;

  @override
  List<Object?> get props => [
        id,
        name,
        scientificName,
        description,
        modelAssetPath,
      ];
}
