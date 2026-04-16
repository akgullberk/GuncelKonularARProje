import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/fish_species.dart';
import '../../domain/repositories/fish_repository.dart';
import 'fish_catalog_state.dart';

class FishCatalogCubit extends Cubit<FishCatalogState> {
  FishCatalogCubit({required FishRepository repository})
      : _repository = repository,
        super(const FishCatalogState());

  final FishRepository _repository;

  Future<void> loadSpecies() async {
    emit(state.copyWith(loading: true, clearError: true));
    try {
      final list = await _repository.getAllSpecies();
      emit(
        state.copyWith(
          loading: false,
          species: list,
          selected: list.isNotEmpty ? list.first : null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          loading: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void selectFish(FishSpecies fish) {
    emit(state.copyWith(selected: fish));
  }
}
