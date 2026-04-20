import 'package:equatable/equatable.dart';

import '../../domain/entities/aquarium_fish.dart';

class AquariumState extends Equatable {
  const AquariumState({
    this.loading = false,
    this.fishes = const [],
    this.errorMessage,
  });

  final bool loading;
  final List<AquariumFish> fishes;
  final String? errorMessage;

  AquariumState copyWith({
    bool? loading,
    List<AquariumFish>? fishes,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AquariumState(
      loading: loading ?? this.loading,
      fishes: fishes ?? this.fishes,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [loading, fishes, errorMessage];
}
