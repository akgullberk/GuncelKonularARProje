import 'package:get_it/get_it.dart';

import '../../features/fish_catalog/data/repositories/fish_repository_impl.dart';
import '../../features/fish_catalog/domain/repositories/fish_repository.dart';
import '../../features/fish_catalog/presentation/cubit/fish_catalog_cubit.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
  getIt.registerLazySingleton<FishRepository>(() => FishRepositoryImpl());

  getIt.registerFactory<FishCatalogCubit>(
    () => FishCatalogCubit(repository: getIt<FishRepository>()),
  );
}
