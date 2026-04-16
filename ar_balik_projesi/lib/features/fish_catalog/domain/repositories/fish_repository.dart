import '../entities/fish_species.dart';

abstract class FishRepository {
  Future<List<FishSpecies>> getAllSpecies();
}
