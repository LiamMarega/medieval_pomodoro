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
                ref.read(appBlockerProvider.notifier).requestPermissions();
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

          // List of apps
          blockedAppsAsync.when(
            data: (apps) => Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: apps.length > 5 ? 5 : apps.length, // Show first 5 only
                  itemBuilder: (context, index) {
                    final app = apps[index];
                    return ListTile(
                      dense: true,
                      leading: const Icon(Icons.block, color: Colors.redAccent, size: 16),
                      title: Text(
                        app,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white54, size: 16),
                        onPressed: () {
                          ref.read(appBlockerProvider.notifier).removeBlockedApp(app);
                        },
                      ),
                    );
                  },
                ),
                if (apps.length > 5)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      '+ ${apps.length - 5} more apps',
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error: $e', style: const TextStyle(color: Colors.red)),
          ),

          const SizedBox(height: 16),
          
          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  _showAddAppDialog(context, ref);
                },
                child: const Text('+ Add Manually', style: TextStyle(color: Colors.amber)),
              ),
              TextButton(
                onPressed: () {
                  ref.read(appBlockerProvider.notifier).restoreDefaults();
                },
                child: const Text('Reset Defaults', style: TextStyle(color: Colors.white54)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddAppDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title: const Text('Add Package Name', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'e.g., com.twitter.android',
            hintStyle: TextStyle(color: Colors.white38),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref.read(appBlockerProvider.notifier).addBlockedApp(controller.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Add', style: TextStyle(color: Colors.amber)),
          ),
        ],
      ),
    );
  }
}

