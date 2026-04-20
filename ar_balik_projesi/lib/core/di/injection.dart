import 'package:get_it/get_it.dart';

import '../../features/ar_aquarium/data/repositories/aquarium_repository_impl.dart';
import '../../features/ar_aquarium/domain/repositories/aquarium_repository.dart';
import '../../features/ar_aquarium/domain/usecases/get_aquarium_fishes.dart';
import '../../features/ar_aquarium/presentation/cubit/aquarium_cubit.dart';
import '../../features/fish_catalog/data/repositories/fish_repository_impl.dart';
import '../../features/fish_catalog/domain/repositories/fish_repository.dart';
import '../../features/fish_catalog/presentation/cubit/fish_catalog_cubit.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
  getIt.registerLazySingleton<AquariumRepository>(() => AquariumRepositoryImpl());
  getIt.registerLazySingleton<GetAquariumFishes>(
    () => GetAquariumFishes(getIt<AquariumRepository>()),
  );
  getIt.registerFactory<AquariumCubit>(
    () => AquariumCubit(getAquariumFishes: getIt<GetAquariumFishes>()),
  );

  getIt.registerLazySingleton<FishRepository>(() => FishRepositoryImpl());

  getIt.registerFactory<FishCatalogCubit>(
    () => FishCatalogCubit(repository: getIt<FishRepository>()),
  );
}
