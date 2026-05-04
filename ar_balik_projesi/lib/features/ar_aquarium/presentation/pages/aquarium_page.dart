import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

import '../../../../core/di/injection.dart';
import '../../domain/entities/aquarium_fish.dart';
import '../cubit/aquarium_cubit.dart';
import '../cubit/aquarium_state.dart';

class AquariumPage extends StatelessWidget {
  const AquariumPage({
    super.key,
    required this.capturedImagePath,
  });

  final String capturedImagePath;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AquariumCubit>()..loadFishes(),
      child: _AquariumView(capturedImagePath: capturedImagePath),
    );
  }
}

class _AquariumView extends StatelessWidget {
  const _AquariumView({required this.capturedImagePath});

  final String capturedImagePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<AquariumCubit, AquariumState>(
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
                      onTap: () => _showFishInfo(context, swimmer.fish),
                    ),
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
                  child: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      'Balik modelleri ekranda yuzer. Dokununca bilgi acilir.',
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showFishInfo(BuildContext context, AquariumFish fish) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fish.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                fish.scientificName,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
              ),
              const SizedBox(height: 8),
              Text(fish.description),
              const SizedBox(height: 8),
              Text(
                'Model: ${fish.modelAssetPath}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
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

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = (_controller.value + phase) % 1.0;
        final horizontal = t;
        final sine = sin((t * 2 * pi) + _seed);
        final dy = sine * waveFactor;
        final wobbleAngle = sin((t * 2 * pi) + (_seed * 0.7)) * 0.08;

        return Align(
          alignment: Alignment(-1 + (horizontal * 2), -1 + (topFactor * 2)),
          child: Transform.translate(
            offset: Offset(0, dy),
            child: Transform.rotate(
              angle: wobbleAngle,
              child: child,
            ),
          ),
        );
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: SizedBox(
          width: size,
          height: size + 24,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: IgnorePointer(
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
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.42),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  fish.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
