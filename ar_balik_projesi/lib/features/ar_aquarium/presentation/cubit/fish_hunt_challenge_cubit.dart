import 'dart:async';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/aquarium_fish.dart';
import 'fish_hunt_challenge_state.dart';

class FishHuntChallengeCubit extends Cubit<FishHuntChallengeState> {
  FishHuntChallengeCubit() : super(const FishHuntChallengeState());

  final _random = Random();
  Timer? _timer;
  bool _started = false;

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }

  /// Katalog ilk kez dolunca bir round baslatir (sureli mod).
  void ensureStarted(List<AquariumFish> catalog) {
    if (_started || catalog.isEmpty) return;
    _started = true;
    _buildAndStartRound(catalog);
  }

  void _buildAndStartRound(List<AquariumFish> catalog) {
    final unique = <String, AquariumFish>{};
    for (final f in catalog) {
      unique[f.id] = f;
    }
    final list = unique.values.toList()..shuffle(_random);
    if (list.isEmpty) return;

    final pickCount = list.length >= 2 ? 2 : 1;
    final picked = list.take(pickCount).toList();

    final required = <String, int>{};
    final names = <String, String>{};
    var sumReq = 0;
    for (final f in picked) {
      final c = 1 + _random.nextInt(2);
      required[f.id] = c;
      names[f.id] = f.name;
      sumReq += c;
    }
    if (sumReq < 3) {
      final id = picked.first.id;
      required[id] = (required[id] ?? 0) + (3 - sumReq);
    }

    final totalSeconds = (38 + required.length * 12).clamp(35, 75);

    emit(
      FishHuntChallengeState(
        active: true,
        secondsRemaining: totalSeconds,
        totalSeconds: totalSeconds,
        requiredByFishId: Map.from(required),
        collectedByFishId: {
          for (final id in required.keys) id: 0,
        },
        displayNamesById: Map.from(names),
        outcome: HuntOutcome.none,
      ),
    );

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    if (!state.active || state.outcome != HuntOutcome.none) return;
    final next = state.secondsRemaining - 1;
    if (next <= 0) {
      _timer?.cancel();
      if (state.isQuotaComplete) {
        emit(
          state.copyWith(
            secondsRemaining: 0,
            active: false,
            outcome: HuntOutcome.won,
          ),
        );
      } else {
        emit(
          state.copyWith(
            secondsRemaining: 0,
            active: false,
            outcome: HuntOutcome.lost,
          ),
        );
      }
      return;
    }
    emit(state.copyWith(secondsRemaining: next));
  }

  void registerTap(String fishId) {
    if (!state.active || state.outcome != HuntOutcome.none) return;
    final need = state.requiredByFishId[fishId];
    if (need == null) return;

    final cur = state.collectedByFishId[fishId] ?? 0;
    if (cur >= need) return;

    final nextCollected = Map<String, int>.from(state.collectedByFishId);
    nextCollected[fishId] = cur + 1;

    var allDone = true;
    for (final e in state.requiredByFishId.entries) {
      if ((nextCollected[e.key] ?? 0) < e.value) {
        allDone = false;
        break;
      }
    }

    if (allDone) {
      _timer?.cancel();
      emit(
        state.copyWith(
          collectedByFishId: nextCollected,
          active: false,
          outcome: HuntOutcome.won,
        ),
      );
    } else {
      emit(state.copyWith(collectedByFishId: nextCollected));
    }
  }
}
