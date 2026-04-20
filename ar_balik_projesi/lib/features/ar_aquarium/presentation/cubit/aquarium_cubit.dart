import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_aquarium_fishes.dart';
import 'aquarium_state.dart';

class AquariumCubit extends Cubit<AquariumState> {
  AquariumCubit({
    required GetAquariumFishes getAquariumFishes,
  })  : _getAquariumFishes = getAquariumFishes,
        super(const AquariumState());

  final GetAquariumFishes _getAquariumFishes;

  Future<void> loadFishes() async {
    emit(state.copyWith(loading: true, clearError: true));
    try {
      final fishes = await _getAquariumFishes();
      emit(state.copyWith(loading: false, fishes: fishes));
    } catch (e) {
      emit(state.copyWith(loading: false, errorMessage: e.toString()));
    }
  }
}
