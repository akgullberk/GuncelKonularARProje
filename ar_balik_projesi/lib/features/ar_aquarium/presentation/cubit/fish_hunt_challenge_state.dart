import 'package:equatable/equatable.dart';

enum HuntOutcome { none, won, lost }

class FishHuntChallengeState extends Equatable {
  const FishHuntChallengeState({
    this.active = false,
    this.secondsRemaining = 0,
    this.totalSeconds = 0,
    this.requiredByFishId = const {},
    this.collectedByFishId = const {},
    this.displayNamesById = const {},
    this.outcome = HuntOutcome.none,
  });

  final bool active;
  final int secondsRemaining;
  final int totalSeconds;
  final Map<String, int> requiredByFishId;
  final Map<String, int> collectedByFishId;
  final Map<String, String> displayNamesById;
  final HuntOutcome outcome;

  bool get isQuotaComplete {
    if (requiredByFishId.isEmpty) return false;
    for (final e in requiredByFishId.entries) {
      if ((collectedByFishId[e.key] ?? 0) < e.value) return false;
    }
    return true;
  }

  FishHuntChallengeState copyWith({
    bool? active,
    int? secondsRemaining,
    int? totalSeconds,
    Map<String, int>? requiredByFishId,
    Map<String, int>? collectedByFishId,
    Map<String, String>? displayNamesById,
    HuntOutcome? outcome,
  }) {
    return FishHuntChallengeState(
      active: active ?? this.active,
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      requiredByFishId: requiredByFishId ?? this.requiredByFishId,
      collectedByFishId: collectedByFishId ?? this.collectedByFishId,
      displayNamesById: displayNamesById ?? this.displayNamesById,
      outcome: outcome ?? this.outcome,
    );
  }

  @override
  List<Object?> get props => [
        active,
        secondsRemaining,
        totalSeconds,
        requiredByFishId,
        collectedByFishId,
        displayNamesById,
        outcome,
      ];
}
