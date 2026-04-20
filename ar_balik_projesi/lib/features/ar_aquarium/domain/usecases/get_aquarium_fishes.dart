import '../entities/aquarium_fish.dart';
import '../repositories/aquarium_repository.dart';

class GetAquariumFishes {
  const GetAquariumFishes(this._repository);

  final AquariumRepository _repository;

  Future<List<AquariumFish>> call() {
    return _repository.getFishes();
  }
}
