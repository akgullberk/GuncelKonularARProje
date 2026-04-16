import 'package:equatable/equatable.dart';

import '../../domain/entities/fish_species.dart';

class FishCatalogState extends Equatable {
  const FishCatalogState({
    this.loading = false,
    this.species = const [],
    this.selected,
    this.errorMessage,
  });

  final bool loading;
  final List<FishSpecies> species;
  final FishSpecies? selected;
  final String? errorMessage;

  FishCatalogState copyWith({
    bool? loading,
    List<FishSpecies>? species,
    FishSpecies? selected,
    String? errorMessage,
    bool clearSelected = false,
    bool clearError = false,
  }) {
    return FishCatalogState(
      loading: loading ?? this.loading,
      species: species ?? this.species,
      selected: clearSelected ? null : (selected ?? this.selected),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [loading, species, selected, errorMessage];
}
