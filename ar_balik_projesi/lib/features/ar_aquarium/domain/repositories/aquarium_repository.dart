import '../entities/aquarium_fish.dart';

abstract class AquariumRepository {
  Future<List<AquariumFish>> getFishes();
}
