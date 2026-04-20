import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
                    color: Colors.blue.withValues(alpha: 0.14),
                  ),
                ),
              ),
              ...state.fishes.asMap().entries.map(
                    (entry) => _SwimmingFish(
                      fish: entry.value,
                      index: entry.key,
                      onTap: () => _showFishInfo(context, entry.value),
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
                      'Balığa dokunarak detayları gör.',
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
}

class _SwimmingFish extends StatefulWidget {
  const _SwimmingFish({
    required this.fish,
    required this.index,
    required this.onTap,
  });

  final AquariumFish fish;
  final int index;
  final VoidCallback onTap;

  @override
  State<_SwimmingFish> createState() => _SwimmingFishState();
}

class _SwimmingFishState extends State<_SwimmingFish>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: Duration(seconds: 7 + widget.index),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final random = Random(widget.fish.id.hashCode);
    final topFactor = 0.2 + (random.nextDouble() * 0.6);
    final waveFactor = 20 + random.nextDouble() * 24;
    final reverse = widget.index.isOdd;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        final horizontal = reverse ? (1 - t) : t;
        final sine = sin((t * 2 * pi) + widget.index);
        final dy = sine * waveFactor;

        return Align(
          alignment: Alignment(-1 + (horizontal * 2), -1 + (topFactor * 2)),
          child: Transform.translate(
            offset: Offset(0, dy),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(999),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  reverse ? Icons.set_meal : Icons.phishing,
                  color: Colors.blueGrey.shade700,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.fish.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
