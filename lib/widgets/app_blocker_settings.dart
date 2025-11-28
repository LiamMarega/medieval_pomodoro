import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_blocker_provider.dart';

class AppBlockerSettingsWidget extends ConsumerWidget {
  const AppBlockerSettingsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blockedAppsAsync = ref.watch(appBlockerProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shield, color: Colors.amber),
              const SizedBox(width: 8),
              const Text(
                'Blocked Apps (Shield)',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'These apps will be blocked during your Focus Session.',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 16),

          // Permissions Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                ref.read(appBlockerProvider.notifier).requestPermission();
              },
              icon: const Icon(Icons.lock_open, size: 18),
              label: const Text('Grant Permissions'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber.withOpacity(0.2),
                foregroundColor: Colors.amber,
                side: const BorderSide(color: Colors.amber),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // App selection status
          blockedAppsAsync.when(
            data: (appsSelected) => appsSelected
                ? Column(
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.check_circle,
                              color: Colors.green, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Apps have been selected',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ref
                                .read(appBlockerProvider.notifier)
                                .selectAppsToBlock();
                          },
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text('Change Selection'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.withOpacity(0.2),
                            foregroundColor: Colors.blue,
                            side: const BorderSide(color: Colors.blue),
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: Colors.amber, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'No apps selected yet. Select apps to block during focus sessions.',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ref
                                .read(appBlockerProvider.notifier)
                                .selectAppsToBlock();
                          },
                          icon: const Icon(Icons.add_circle, size: 18),
                          label: const Text('Select Apps to Block'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber.withOpacity(0.2),
                            foregroundColor: Colors.amber,
                            side: const BorderSide(color: Colors.amber),
                          ),
                        ),
                      ),
                    ],
                  ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) =>
                Text('Error: $e', style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
