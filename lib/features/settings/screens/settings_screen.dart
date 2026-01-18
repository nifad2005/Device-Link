import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/widgets/premium_card.dart';
import '../../../services/settings_service.dart';
import '../../../services/connection_service.dart';
import '../../onboarding/screens/welcome_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = SettingsService();
    final connection = ConnectionService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'CONNECTION',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: Colors.white24,
              ),
            ),
            const SizedBox(height: 16),
            _buildSettingTile(
              context,
              icon: Icons.sync_rounded,
              title: 'Auto-connect',
              subtitle: 'Link to last device on startup',
              valueNotifier: settings.autoConnect,
              onChanged: settings.setAutoConnect,
            ),
            ValueListenableBuilder<String?>(
              valueListenable: settings.lastConnectedAddress,
              builder: (context, address, child) {
                if (address == null) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: PremiumCard(
                    padding: 20,
                    color: Colors.redAccent.withOpacity(0.05),
                    onTap: () => _showForgetConfirmation(context, connection),
                    child: Row(
                      children: [
                        const Icon(Icons.link_off_rounded, color: Colors.redAccent, size: 22),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Forget Device', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.redAccent)),
                              Text('Clear saved pairing data', style: TextStyle(color: Colors.white24, fontSize: 12)),
                            ],
                          ),
                        ),
                        Text(
                          address.split(':').first,
                          style: const TextStyle(color: Colors.white10, fontSize: 10, letterSpacing: 1),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            const Text(
              'EXPERIENCE',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: Colors.white24,
              ),
            ),
            const SizedBox(height: 16),
            _buildSettingTile(
              context,
              icon: Icons.notifications_active_outlined,
              title: 'Global Notifications',
              subtitle: 'Enable or disable all app alerts',
              valueNotifier: settings.globalNotifications,
              onChanged: settings.setGlobalNotifications,
            ),
            _buildSettingTile(
              context,
              icon: Icons.vibration_rounded,
              title: 'Haptic Feedback',
              subtitle: 'Tactile response for all interactions',
              valueNotifier: settings.globalVibration,
              onChanged: settings.setGlobalVibration,
            ),
            const SizedBox(height: 32),
            const Text(
              'NOTIFICATION CHANNELS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: Colors.white24,
              ),
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder<bool>(
              valueListenable: settings.globalNotifications,
              builder: (context, globalEnabled, child) {
                return Opacity(
                  opacity: globalEnabled ? 1.0 : 0.4,
                  child: AbsorbPointer(
                    absorbing: !globalEnabled,
                    child: Column(
                      children: [
                        _buildSettingTile(
                          context,
                          icon: Icons.cloud_done_outlined,
                          title: 'File Transfers',
                          subtitle: 'Notify when a file is fully received',
                          valueNotifier: settings.notifyFileTransfers,
                          onChanged: settings.setNotifyFileTransfers,
                        ),
                        _buildSettingTile(
                          context,
                          icon: Icons.link_rounded,
                          title: 'Connection Status',
                          subtitle: 'Alerts when devices link or unlink',
                          valueNotifier: settings.notifyConnections,
                          onChanged: settings.setNotifyConnections,
                        ),
                        _buildSettingTile(
                          context,
                          icon: Icons.power_settings_new_rounded,
                          title: 'Power Commands',
                          subtitle: 'Alert on remote power actions',
                          valueNotifier: settings.notifyPowerCommands,
                          onChanged: settings.setNotifyPowerCommands,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            const Text(
              'INPUT CONTROL',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: Colors.white24,
              ),
            ),
            const SizedBox(height: 16),
            PremiumCard(
              padding: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.speed_rounded, color: Colors.white38, size: 20),
                      SizedBox(width: 16),
                      Text('Trackpad Sensitivity', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ValueListenableBuilder<double>(
                    valueListenable: settings.trackpadSensitivity,
                    builder: (context, value, child) {
                      return SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 2,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                        ),
                        child: Slider(
                          value: value,
                          min: 0.5,
                          max: 2.0,
                          onChanged: (val) {
                            settings.setTrackpadSensitivity(val);
                            if (settings.globalVibration.value) {
                              HapticFeedback.selectionClick();
                            }
                          },
                          activeColor: Theme.of(context).colorScheme.primary,
                          inactiveColor: Colors.white10,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            Center(
              child: Column(
                children: [
                  const Text('Device Linker Premium', style: TextStyle(color: Colors.white10, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
                  const SizedBox(height: 4),
                  Text('v1.0.0 Stable Build', style: TextStyle(color: Colors.white.withOpacity(0.02), fontSize: 10)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showForgetConfirmation(BuildContext context, ConnectionService connection) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1C1E),
        title: const Text('Forget Device?'),
        content: const Text('This will disconnect the current bridge and clear pairing data. You will need to scan the QR code again to reconnect.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: Colors.white38)),
          ),
          TextButton(
            onPressed: () async {
              await connection.forgetAndDisconnect();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('FORGET', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required ValueNotifier<bool> valueNotifier,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ValueListenableBuilder<bool>(
        valueListenable: valueNotifier,
        builder: (context, value, child) {
          return PremiumCard(
            padding: 20,
            onTap: () {
              onChanged(!value);
              if (SettingsService().globalVibration.value) {
                HapticFeedback.lightImpact();
              }
            },
            child: Row(
              children: [
                Icon(icon, color: Colors.white38, size: 22),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                      const SizedBox(height: 2),
                      Text(subtitle, style: const TextStyle(color: Colors.white24, fontSize: 12)),
                    ],
                  ),
                ),
                Transform.scale(
                  scale: 0.8,
                  child: Switch.adaptive(
                    value: value,
                    onChanged: (val) {
                      onChanged(val);
                      if (SettingsService().globalVibration.value) {
                        HapticFeedback.lightImpact();
                      }
                    },
                    activeColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
