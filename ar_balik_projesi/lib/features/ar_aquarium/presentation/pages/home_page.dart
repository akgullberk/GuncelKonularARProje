import 'package:flutter/material.dart';

import '../../domain/aquarium_entry_mode.dart';
import 'camera_capture_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AR Balik'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Ne yapmak istersin?',
                style: textTheme.titleMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: _ModeCard(
                        icon: Icons.explore_rounded,
                        title: 'Baliklari kesfet',
                        subtitle:
                            'Kamerayla zemin cek, modelleri serbestce incele ve koleksiyonunu doldur.',
                        color: scheme.primaryContainer,
                        onPrimary: scheme.onPrimaryContainer,
                        onTap: () => _openCamera(
                          context,
                          AquariumEntryMode.explore,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: _ModeCard(
                        icon: Icons.timer_outlined,
                        title: 'Balik bul oyunu',
                        subtitle:
                            'Sure icinde gosterilen turlerden istenen sayida dokun. Gorev bitince veya sure bitince oyun biter.',
                        color: scheme.tertiaryContainer,
                        onPrimary: scheme.onTertiaryContainer,
                        onTap: () => _openCamera(
                          context,
                          AquariumEntryMode.timedHunt,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openCamera(BuildContext context, AquariumEntryMode mode) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => CameraCapturePage(entryMode: mode),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onPrimary,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color onPrimary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 40, color: onPrimary),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: onPrimary,
                      height: 1.15,
                    ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: onPrimary.withValues(alpha: 0.92),
                        height: 1.4,
                      ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Icon(Icons.arrow_forward_rounded, color: onPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
