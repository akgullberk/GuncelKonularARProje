import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../domain/entities/fish_species.dart';
import '../cubit/fish_catalog_cubit.dart';
import '../cubit/fish_catalog_state.dart';

class FishCatalogPage extends StatelessWidget {
  const FishCatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<FishCatalogCubit>()..loadSpecies(),
      child: const _FishCatalogView(),
    );
  }
}

class _FishCatalogView extends StatelessWidget {
  const _FishCatalogView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Balık seç'),
      ),
      body: BlocBuilder<FishCatalogCubit, FishCatalogState>(
        builder: (context, state) {
          if (state.loading && state.species.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  state.errorMessage!,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: state.species.length,
                  itemBuilder: (context, index) {
                    final fish = state.species[index];
                    final selected = state.selected?.id == fish.id;
                    return ListTile(
                      selected: selected,
                      leading: Icon(
                        Icons.water,
                        color: selected
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                      title: Text(fish.name),
                      subtitle: Text(
                        fish.scientificName,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      onTap: () =>
                          context.read<FishCatalogCubit>().selectFish(fish),
                    );
                  },
                ),
              ),
              if (state.selected != null)
                _InfoCard(fish: state.selected!),
            ],
          );
        },
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.fish});

  final FishSpecies fish;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      elevation: 8,
      color: scheme.surfaceContainerHighest,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                fish.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: scheme.onSurface,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                fish.scientificName,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                fish.shortDescription,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurface,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
