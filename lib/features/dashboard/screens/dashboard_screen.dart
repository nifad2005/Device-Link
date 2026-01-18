import 'package:flutter/material.dart';
import '../../../core/widgets/premium_card.dart';
import '../../remote_control/screens/trackpad_screen.dart';
import '../../remote_control/screens/media_controller_screen.dart';
import '../../remote_control/screens/power_actions_screen.dart';
import '../../remote_control/screens/file_sharing_screen.dart';
import '../../settings/screens/settings_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workstation'),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
            icon: const Icon(Icons.settings_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(context),
            const SizedBox(height: 40),
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                    letterSpacing: 1.1,
                  ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              children: [
                _buildActionCard(
                  context,
                  icon: Icons.mouse_rounded,
                  label: 'Trackpad',
                  color: Colors.blueAccent,
                  heroTag: 'trackpad_hero',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TrackpadScreen()),
                  ),
                ),
                _buildActionCard(
                  context,
                  icon: Icons.play_circle_outline_rounded,
                  label: 'Media',
                  color: Colors.orangeAccent,
                  heroTag: 'media_hero',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MediaControllerScreen()),
                  ),
                ),
                _buildActionCard(
                  context,
                  icon: Icons.cloud_sync_rounded,
                  label: 'File Bridge',
                  color: Colors.purpleAccent,
                  heroTag: 'file_hero',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FileSharingScreen()),
                  ),
                ),
                _buildActionCard(
                  context,
                  icon: Icons.power_settings_new_rounded,
                  label: 'Power',
                  color: Colors.redAccent,
                  heroTag: 'power_hero',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PowerActionsScreen()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    return PremiumCard(
      padding: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.05),
              Colors.white.withOpacity(0.01),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.greenAccent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.laptop_windows_rounded, color: Colors.greenAccent),
            ),
            const SizedBox(width: 20),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Desktop-V82',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Connected • Low Latency',
                    style: TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(Icons.wifi_rounded, color: Colors.greenAccent, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context,
      {required IconData icon, required String label, required Color color, required String heroTag, required VoidCallback onTap}) {
    return Hero(
      tag: heroTag,
      child: PremiumCard(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(height: 16),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
