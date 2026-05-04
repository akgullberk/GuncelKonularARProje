import '../../domain/entities/aquarium_fish.dart';
import '../../domain/repositories/aquarium_repository.dart';

class AquariumRepositoryImpl implements AquariumRepository {
  static const List<AquariumFish> _fishes = [
    AquariumFish(
      id: 'clownfish',
      name: 'Palyaço Balığı',
      scientificName: 'Amphiprioninae',
      description:
          'Mercan resiflerinde yaşayan ve turuncu-beyaz çizgileriyle tanınan tür.',
      modelAssetPath: 'lib/assets/models/clown_fish_low_poly_animated.glb',
    ),
    AquariumFish(
      id: 'shark',
      name: 'Köpekbalığı',
      scientificName: 'Selachimorpha',
      description: 'Kıkırdak iskelete sahip, açık denizlerde yaşayan güçlü avcı.',
      modelAssetPath: 'lib/assets/models/tiger_shark.glb',
    ),
    AquariumFish(
      id: 'betta',
      name: 'Betta',
      scientificName: 'Betta splendens',
      description: 'Canlı renkleri ve yüzgeçleriyle bilinen popüler tatlı su balığı.',
      modelAssetPath: 'lib/assets/models/animated_low_poly_fish.glb',
    ),
  ];

  @override
  Future<List<AquariumFish>> getFishes() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return _fishes;
  }
}
