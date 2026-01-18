import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/widgets/premium_card.dart';
import '../../../services/connection_service.dart';
import '../../../core/models/bridge_message.dart';

class PowerActionsScreen extends StatelessWidget {
  const PowerActionsScreen({super.key});

  void _sendPowerCommand(String command) {
    ConnectionService().sendMessage(BridgeMessage(
      type: MessageType.powerCommand,
      data: {'command': command},
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'power_hero',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Power Management'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quick Commands',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                      letterSpacing: 1.1,
                    ),
              ),
              const SizedBox(height: 24),
              _buildPowerOption(
                context,
                icon: Icons.brightness_4_rounded,
                title: 'Sleep',
                subtitle: 'Put the workstation into low-power mode.',
                color: Colors.orangeAccent,
                onTap: () => _confirmAction(context, 'sleep'),
              ),
              const SizedBox(height: 16),
              _buildPowerOption(
                context,
                icon: Icons.restart_alt_rounded,
                title: 'Restart',
                subtitle: 'Reboot the system immediately.',
                color: Colors.blueAccent,
                onTap: () => _confirmAction(context, 'restart'),
              ),
              const SizedBox(height: 16),
              _buildPowerOption(
                context,
                icon: Icons.power_settings_new_rounded,
                title: 'Shut Down',
                subtitle: 'Close all apps and turn off the PC.',
                color: Colors.redAccent,
                onTap: () => _confirmAction(context, 'shutdown'),
              ),
              const Spacer(),
              PremiumCard(
                color: Colors.white.withOpacity(0.02),
                padding: 20,
                child: const Row(
                  children: [
                    Icon(Icons.info_outline_rounded, color: Colors.white24),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Power actions require administrative privileges on the host PC.',
                        style: TextStyle(color: Colors.white38, fontSize: 13),
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

  Widget _buildPowerOption(BuildContext context,
      {required IconData icon,
      required String title,
      required String subtitle,
      required Color color,
      required VoidCallback onTap}) {
    return PremiumCard(
      padding: 0,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white10),
          ],
        ),
      ),
    );
  }

  void _confirmAction(BuildContext context, String action) {
    HapticFeedback.heavyImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1C1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(32, 16, 32, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Confirm ${action.toUpperCase()}',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  'Are you sure you want to $action your PC? Any unsaved work may be lost.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white54, fontSize: 15, height: 1.5),
                ),
                const SizedBox(height: 40),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Cancel', style: TextStyle(color: Colors.white70, fontSize: 16)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          HapticFeedback.vibrate();
                          _sendPowerCommand(action);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Command $action sent to workstation')),
                          );
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text(action.toUpperCase(), style: const TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
