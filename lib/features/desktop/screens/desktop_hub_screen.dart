import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../services/connection_service.dart';
import '../../../core/widgets/premium_card.dart';

class DesktopHubScreen extends StatelessWidget {
  const DesktopHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final connectionService = ConnectionService();

    return Scaffold(
      body: Row(
        children: [
          // Sidebar / Status Area
          Container(
            width: 300,
            color: Colors.black.withOpacity(0.2),
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Device Linker',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 24,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Workstation Hub',
                  style: TextStyle(color: Colors.white38, fontSize: 14),
                ),
                const Spacer(),
                const Text(
                  'CONNECTED DEVICES',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: Colors.white24,
                  ),
                ),
                const SizedBox(height: 16),
                ValueListenableBuilder<int>(
                  valueListenable: connectionService.connectedClientsCount,
                  builder: (context, count, child) {
                    if (count == 0) {
                      return const Text(
                        'No devices linked',
                        style: TextStyle(color: Colors.white10, fontStyle: FontStyle.italic),
                      );
                    }
                    return Column(
                      children: List.generate(count, (index) => Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: PremiumCard(
                          padding: 12,
                          color: Colors.white.withOpacity(0.05),
                          child: Row(
                            children: [
                              const Icon(Icons.smartphone_rounded, color: Colors.greenAccent, size: 16),
                              const SizedBox(width: 12),
                              Text(
                                'Remote Device ${index + 1}',
                                style: const TextStyle(fontSize: 13, color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      )),
                    );
                  },
                ),
                const Spacer(),
                ValueListenableBuilder<String?>(
                  valueListenable: connectionService.serverAddress,
                  builder: (context, address, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SERVER STATUS',
                          style: TextStyle(fontSize: 10, color: Colors.white24),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: address != null ? Colors.greenAccent : Colors.redAccent,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              address != null ? 'Running on $address' : 'Offline',
                              style: const TextStyle(color: Colors.white54, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          // Main Content Area
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ValueListenableBuilder<String?>(
                      valueListenable: connectionService.serverAddress,
                      builder: (context, address, child) {
                        if (address == null) {
                          return const CircularProgressIndicator();
                        }
                        return PremiumCard(
                          padding: 40,
                          child: Column(
                            children: [
                              const Text(
                                'Link New Device',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Scan this code with the Device Linker mobile app to establish a secure bridge.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white54),
                              ),
                              const SizedBox(height: 40),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: QrImageView(
                                  data: address,
                                  version: QrVersions.auto,
                                  size: 240.0,
                                  gapless: false,
                                ),
                              ),
                              const SizedBox(height: 40),
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.security_rounded, color: Colors.greenAccent, size: 16),
                                  SizedBox(width: 8),
                                  Text(
                                    'End-to-end local encryption active',
                                    style: TextStyle(color: Colors.white24, fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
