import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'discovery_state.dart';

class DiscoveryCubit extends Cubit<DiscoveryState> {
  DiscoveryCubit(this._prefs) : super(const DiscoveryState());

  final SharedPreferences _prefs;

  static const String _storageKey = 'aquarium_seen_fish_v1';

  Future<void> load() async {
    final list = _prefs.getStringList(_storageKey) ?? [];
    emit(state.copyWith(seenIds: list.toSet(), loaded: true));
  }

  /// Balik bilgisine girildiğinde. [true] = ilk kez keşfedildi.
  Future<bool> discover(String fishId) async {
    if (state.seenIds.contains(fishId)) return false;
    final next = {...state.seenIds, fishId};
    await _prefs.setStringList(_storageKey, next.toList());
    emit(state.copyWith(seenIds: next));
    return true;
  }
}
