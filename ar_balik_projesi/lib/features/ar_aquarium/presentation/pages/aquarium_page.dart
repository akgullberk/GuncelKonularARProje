import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

import '../../../../core/di/injection.dart';
import '../../domain/aquarium_entry_mode.dart';
import '../../domain/entities/aquarium_fish.dart';
import '../cubit/aquarium_cubit.dart';
import '../cubit/aquarium_state.dart';
import '../cubit/discovery_cubit.dart';
import '../cubit/discovery_state.dart';
import '../cubit/fish_hunt_challenge_cubit.dart';
import '../cubit/fish_hunt_challenge_state.dart';

String _sheetModelOrientation(String fishId) {
  switch (fishId) {
    case 'clownfish':
      return '0deg 0deg 75deg';
    case 'shark':
      return '0deg 0deg 75deg';
    case 'betta':
      return '0deg 0deg 115deg';
    default:
      return '0deg 0deg 0deg';
  }
}

/// Alt sayfa onizlemesi; ana yuzmedeki olcekle ayni formulu kullanir, kutu icin kucultulur.
String _sheetModelScaleTriple(String fishId) {
  final (double realSizeRatio, double visualBoost) = switch (fishId) {
    'clownfish' => (1.0, 0.8),
    'betta' => (5.0, 0.5),
    'shark' => (100.0, 1.75),
    _ => (1.0, 1.0),
  };
  final base = realSizeRatio * 0.05 * visualBoost;
  final preview = (base * 0.42).clamp(0.22, 2.6);
  return '$preview $preview $preview';
}

class AquariumPage extends StatelessWidget {
  const AquariumPage({
    super.key,
    required this.capturedImagePath,
    required this.entryMode,
  });

  final String capturedImagePath;
  final AquariumEntryMode entryMode;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<AquariumCubit>()..loadFishes()),
        if (entryMode == AquariumEntryMode.explore)
          BlocProvider(create: (_) => getIt<DiscoveryCubit>()..load()),
        if (entryMode == AquariumEntryMode.timedHunt)
          BlocProvider(create: (_) => getIt<FishHuntChallengeCubit>()),
      ],
      child: _AquariumView(
        capturedImagePath: capturedImagePath,
        entryMode: entryMode,
      ),
    );
  }
}

class _AquariumView extends StatelessWidget {
  const _AquariumView({
    required this.capturedImagePath,
    required this.entryMode,
  });

  final String capturedImagePath;
  final AquariumEntryMode entryMode;

  String get _hintText {
    switch (entryMode) {
      case AquariumEntryMode.explore:
        return 'Balik modelleri ekranda yuzer. Modele dokununca bilgi acilir.';
      case AquariumEntryMode.timedHunt:
        return 'Soldaki gorevde istenen turlere dokun. Sure bitmeden tamamla.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final stack = BlocBuilder<AquariumCubit, AquariumState>(
      builder: (context, state) {
        if (state.loading && state.fishes.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.errorMessage != null) {
          return Center(child: Text(state.errorMessage!));
        }
        final swimmers = _buildSwimmers(state.fishes);

        return Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: Image.file(
                File(capturedImagePath),
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.16),
                ),
              ),
            ),
            ...swimmers.map(
                  (swimmer) => _SwimmingFishModel(
                    swimmer: swimmer,
                    onTap: () {
                      if (entryMode == AquariumEntryMode.timedHunt) {
                        context
                            .read<FishHuntChallengeCubit>()
                            .registerTap(swimmer.fish.id);
                      }
                      _showFishInfo(context, swimmer.fish);
                    },
                  ),
                ),
            if (entryMode == AquariumEntryMode.timedHunt)
              const Positioned(
                top: 112,
                left: 12,
                right: 12,
                child: _TimedHuntHud(),
              ),
            if (entryMode == AquariumEntryMode.explore)
              const Positioned(
                top: 120,
                right: 16,
                width: 172,
                child: _AquariumDiscoveryChip(),
              ),
            Positioned(
              top: 48,
              left: 16,
              right: 16,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    _hintText,
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    final body = entryMode == AquariumEntryMode.timedHunt
        ? MultiBlocListener(
            listeners: [
              BlocListener<AquariumCubit, AquariumState>(
                listener: (context, s) {
                  if (s.fishes.isNotEmpty) {
                    context
                        .read<FishHuntChallengeCubit>()
                        .ensureStarted(s.fishes);
                  }
                },
              ),
              BlocListener<FishHuntChallengeCubit, FishHuntChallengeState>(
                listenWhen: (p, n) =>
                    p.outcome != n.outcome && n.outcome != HuntOutcome.none,
                listener: (context, s) async {
                  final won = s.outcome == HuntOutcome.won;
                  await showDialog<void>(
                    context: context,
                    barrierDismissible: false,
                    builder: (ctx) => AlertDialog(
                      title: Text(won ? 'Tebrikler!' : 'Sure bitti'),
                      content: Text(
                        won
                            ? 'Gorevi basariyla tamamladin.'
                            : 'Istenen baliklara yetisemedin. Tekrar dene!',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('Tamam'),
                        ),
                      ],
                    ),
                  );
                  if (context.mounted) {
                    Navigator.of(context)
                        .popUntil((route) => route.isFirst);
                  }
                },
              ),
            ],
            child: stack,
          )
        : stack;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black.withValues(alpha: 0.38),
        foregroundColor: Colors.white,
        title: Text(
          entryMode == AquariumEntryMode.explore ? 'Kesif' : 'Balik bul',
        ),
      ),
      body: body,
    );
  }

  void _showFishInfo(BuildContext context, AquariumFish fish) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    if (entryMode == AquariumEntryMode.explore) {
      context.read<DiscoveryCubit>().discover(fish.id).then((newly) {
        if (!context.mounted) return;
        if (newly) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Yeni kesif: ${fish.name}'),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      });
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: scheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        final bottomInset = MediaQuery.paddingOf(ctx).bottom;
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(24, 4, 24, bottomInset + 20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: ColoredBox(
                      color: scheme.surfaceContainerHighest
                          .withValues(alpha: 0.45),
                      child: SizedBox(
                        height: 200,
                        width: double.infinity,
                        child: IgnorePointer(
                          child: ModelViewer(
                            src: fish.modelAssetPath,
                            alt: fish.name,
                            autoRotate: true,
                            autoPlay: true,
                            cameraControls: false,
                            disableZoom: true,
                            interactionPrompt: InteractionPrompt.none,
                            orientation: _sheetModelOrientation(fish.id),
                            scale: _sheetModelScaleTriple(fish.id),
                            ar: false,
                            backgroundColor: Colors.transparent,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    fish.name,
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    fish.scientificName,
                    style: textTheme.titleSmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: scheme.onSurfaceVariant,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 22),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest
                          .withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: scheme.outlineVariant.withValues(alpha: 0.45),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                      child: Text(
                        fish.description,
                        style: textTheme.bodyLarge?.copyWith(
                          height: 1.55,
                          color: scheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<_FishSwimmer> _buildSwimmers(List<AquariumFish> fishes) {
    final swimmers = <_FishSwimmer>[];
    for (var i = 0; i < fishes.length; i++) {
      final fish = fishes[i];
      final random = Random(fish.id.hashCode);
      final count = 2 + random.nextInt(3);
      for (var clone = 0; clone < count; clone++) {
        swimmers.add(
          _FishSwimmer(
            fish: fish,
            seed: (i * 100) + clone,
          ),
        );
      }
    }
    return swimmers;
  }
}

class _AquariumDiscoveryChip extends StatelessWidget {
  const _AquariumDiscoveryChip();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AquariumCubit, AquariumState>(
      builder: (context, aq) {
        return BlocBuilder<DiscoveryCubit, DiscoveryState>(
          builder: (context, d) {
            if (!d.loaded || aq.fishes.isEmpty) {
              return const SizedBox.shrink();
            }
            final catalogIds = aq.fishes.map((f) => f.id).toSet();
            final seenInCatalog = d.seenIds.intersection(catalogIds).length;
            final total = catalogIds.length;
            final progress = total == 0 ? 0.0 : seenInCatalog / total;

            return DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.52),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.12),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.travel_explore_rounded,
                          size: 18,
                          color: Colors.amber.shade200,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Kesif $seenInCatalog/$total',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        minHeight: 5,
                        backgroundColor: Colors.white.withValues(alpha: 0.15),
                        color: Colors.amber.shade200,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _TimedHuntHud extends StatelessWidget {
  const _TimedHuntHud();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FishHuntChallengeCubit, FishHuntChallengeState>(
      builder: (context, h) {
        if (h.requiredByFishId.isEmpty) {
          return const SizedBox.shrink();
        }
        final total = h.totalSeconds <= 0 ? 1 : h.totalSeconds;
        final timeFrac = (h.secondsRemaining / total).clamp(0.0, 1.0);

        return DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white24),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(Icons.timer_outlined,
                        color: Colors.orange.shade200, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      '${h.secondsRemaining} sn',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Gorev',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: timeFrac,
                    minHeight: 6,
                    backgroundColor: Colors.white24,
                    color: Colors.orange.shade200,
                  ),
                ),
                const SizedBox(height: 10),
                ...h.requiredByFishId.entries.map((e) {
                  final name = h.displayNamesById[e.key] ?? e.key;
                  final cur = h.collectedByFishId[e.key] ?? 0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '$cur/${e.value}',
                          style: TextStyle(
                            color: cur >= e.value
                                ? Colors.lightGreenAccent
                                : Colors.amber.shade100,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FishSwimmer {
  const _FishSwimmer({
    required this.fish,
    required this.seed,
  });

  final AquariumFish fish;
  final int seed;
}

class _SwimmingFishModel extends StatefulWidget {
  const _SwimmingFishModel({
    required this.swimmer,
    required this.onTap,
  });

  final _FishSwimmer swimmer;
  final VoidCallback onTap;

  @override
  State<_SwimmingFishModel> createState() => _SwimmingFishModelState();
}

class _SwimmingFishModelState extends State<_SwimmingFishModel>
    with SingleTickerProviderStateMixin {
  late final int _seed = widget.swimmer.seed;
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: 7000 + ((_seed % 7) * 800)),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fish = widget.swimmer.fish;
    final realSizeRatio = _realSizeRatioForFish(fish.id);
    final visualBoost = _visualBoostForFish(fish.id);
    final random = Random(_seed + fish.id.hashCode);
    final topFactor = 0.18 + (random.nextDouble() * 0.62);
    final waveFactor = 10 + random.nextDouble() * 18;
    final phase = random.nextDouble();
    final size = _cardSizeForRatio(realSizeRatio, visualBoost);
    final modelScale = _normalizedModelScale(realSizeRatio, visualBoost);
    final screenW = MediaQuery.sizeOf(context).width;
    final swimH = _swimHorizontalForFish(
      fish.id,
      cardWidth: size,
      screenWidth: screenW,
    );

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final u = (_controller.value + phase) % 1.0;
        // repeat() 1->0: sagda dar soluk. Kopekbaligi solda baslangicta gorunmez, easeIn ile yavas kadraj girisi.
        final swimParam =
            swimH.swimMin + u * (swimH.swimMax - swimH.swimMin);
        final alignmentX = -1 + (2 * swimParam);
        final sine = sin((u * 2 * pi) + _seed);
        final dy = sine * waveFactor;
        final wobbleAngle = sin((u * 2 * pi) + (_seed * 0.7)) * 0.08;

        final leftFadeEnd = swimH.swimMin + swimH.leftFadeBand;
        var leftOp = 1.0;
        if (swimH.sharkLeftRevealEnd != null) {
          final revealEnd = swimH.sharkLeftRevealEnd!;
          if (swimParam <= swimH.swimMin) {
            leftOp = 0.0;
          } else if (swimParam < revealEnd) {
            final raw = (swimParam - swimH.swimMin) / (revealEnd - swimH.swimMin);
            leftOp = Curves.easeIn.transform(raw.clamp(0.0, 1.0));
          } else {
            leftOp = 1.0;
          }
        } else if (swimParam < leftFadeEnd) {
          leftOp = ((swimParam - swimH.swimMin) / swimH.leftFadeBand)
              .clamp(0.0, 1.0);
        }
        final rightFadeStart = swimH.swimMax - swimH.rightFadeBand;
        var rightOp = 1.0;
        if (swimParam > rightFadeStart) {
          rightOp = ((swimH.swimMax - swimParam) / swimH.rightFadeBand)
              .clamp(0.0, 1.0);
        }
        final opacity = min(leftOp, rightOp);

        return Align(
          alignment: Alignment(alignmentX, -1 + (topFactor * 2)),
          child: Transform.translate(
            offset: Offset(0, dy),
            child: Transform.rotate(
              angle: wobbleAngle,
              child: Opacity(
                opacity: opacity,
                child: child,
              ),
            ),
          ),
        );
      },
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          fit: StackFit.expand,
          children: [
            IgnorePointer(
              child: ModelViewer(
                src: fish.modelAssetPath,
                alt: fish.name,
                autoRotate: false,
                autoPlay: true,
                cameraControls: false,
                disableZoom: true,
                interactionPrompt: InteractionPrompt.none,
                orientation: _orientationForFish(fish.id),
                scale: '$modelScale $modelScale $modelScale',
                ar: false,
                backgroundColor: Colors.transparent,
              ),
            ),
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: widget.onTap,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// [sharkLeftRevealEnd]: null degilse kopekbaligi swimMin'de opak 0, bu esige kadar Curves.easeIn ile artar.
  ({
    double swimMin,
    double swimMax,
    double leftFadeBand,
    double rightFadeBand,
    double? sharkLeftRevealEnd,
  }) _swimHorizontalForFish(
    String fishId, {
    required double cardWidth,
    required double screenWidth,
  }) {
    switch (fishId) {
      case 'shark':
        final sw = screenWidth > 1 ? screenWidth : 400.0;
        final frac = (cardWidth / sw).clamp(0.12, 0.92);
        // swimParam==1: kart sag kadraj; mesh kuyrugu icin swimParam 1 sonrasi uzun tam opak yol.
        final pastOne = 1.55 + frac * 5.8;
        return (
          swimMin: -7.38,
          swimMax: (1 + pastOne).clamp(2.85, 3.55),
          leftFadeBand: 0.07,
          rightFadeBand: 0.07,
          sharkLeftRevealEnd: 0.46,
        );
      case 'betta':
        const m = 0.22;
        return (
          swimMin: -m,
          swimMax: 1 + m,
          leftFadeBand: 0.07,
          rightFadeBand: 0.06,
          sharkLeftRevealEnd: null,
        );
      default:
        const m = 0.26;
        return (
          swimMin: -m,
          swimMax: 1 + m,
          leftFadeBand: 0.07,
          rightFadeBand: 0.065,
          sharkLeftRevealEnd: null,
        );
    }
  }

  String _orientationForFish(String fishId) {
    switch (fishId) {
      case 'clownfish':
        return '0deg 0deg 75deg';
      case 'shark':
        return '0deg 0deg 75deg';
      case 'betta':
        return '0deg 0deg 115deg';
      default:
        return '0deg 0deg 0deg';
    }
  }

  double _realSizeRatioForFish(String fishId) {
    switch (fishId) {
      case 'clownfish':
        return 1.0; // 10 cm referans
      case 'betta':
        return 5.0; // Sazan ~60 cm
      case 'shark':
        return 100.0; // Buyuk beyaz kopekbaligi ~450 cm
      default:
        return 1.0;
    }
  }

  double _normalizedModelScale(double realSizeRatio, double visualBoost) {
    // Gercek oran korunur, tum modeller ekrana sigmasi icin ortak katsayi uygulanir.
    return realSizeRatio * 0.05 * visualBoost;
  }

  double _cardSizeForRatio(double realSizeRatio, double visualBoost) {
    final raw = 92.0 * sqrt(realSizeRatio) * visualBoost;
    return raw.clamp(50.0, 300.0);
  }

  double _visualBoostForFish(String fishId) {
    switch (fishId) {
      case 'clownfish':
        return 0.8; // Palyaco biraz daha kucuk
      case 'shark':
        return 1.75; // Kopekbaligi belirgin sekilde buyuk
      case 'betta':
        return 0.5;
      default:
        return 1.0;
    }
  }
}
