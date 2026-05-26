import 'package:equatable/equatable.dart';

class DiscoveryState extends Equatable {
  const DiscoveryState({
    this.seenIds = const {},
    this.loaded = false,
  });

  final Set<String> seenIds;
  final bool loaded;

  DiscoveryState copyWith({
    Set<String>? seenIds,
    bool? loaded,
  }) {
    return DiscoveryState(
      seenIds: seenIds ?? this.seenIds,
      loaded: loaded ?? this.loaded,
    );
  }

  @override
  List<Object?> get props => [seenIds, loaded];
}
