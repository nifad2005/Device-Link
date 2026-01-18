import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../connection/screens/pairing_screen.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import '../../../core/widgets/premium_card.dart';
import '../../../services/connection_service.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final ConnectionService _connectionService = ConnectionService();

  @override
  void initState() {
    super.initState();
    // Monitor connection status to auto-navigate to dashboard if auto-connect succeeds
    _connectionService.status.addListener(_onStatusChanged);
  }

  @override
  void dispose() {
    _connectionService.status.removeListener(_onStatusChanged);
    super.dispose();
  }

  void _onStatusChanged() {
    if (_connectionService.status.value == ConnectionStatus.connected && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background subtle gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topRight,
                  radius: 1.5,
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 80),
                  const Text(
                    'Device',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w300,
                      letterSpacing: -1,
                    ),
                  ),
                  Text(
                    'Linker',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1,
                      color: Theme.of(context).colorScheme.primary,
                      height: 0.9,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'The premium bridge between your mobile device and workstation.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.4),
                      height: 1.5,
                    ),
                  ),
                  const Spacer(),
                  ValueListenableBuilder<ConnectionStatus>(
                    valueListenable: _connectionService.status,
                    builder: (context, status, child) {
                      if (status == ConnectionStatus.connecting) {
                        return Center(
                          child: Column(
                            children: [
                              CircularProgressIndicator(
                                color: Theme.of(context).colorScheme.primary,
                                strokeWidth: 2,
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                'Reconnecting to your PC...',
                                style: TextStyle(color: Colors.white30, fontSize: 13),
                              ),
                            ],
                          ),
                        );
                      }
                      
                      return Column(
                        children: [
                          PremiumCard(
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const PairingScreen()),
                              );
                            },
                            padding: 24,
                            color: Theme.of(context).colorScheme.primary,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Link New Device',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Icon(Icons.qr_code_scanner_rounded, color: Colors.black),
                              ],
                            ),
                          ),
                          const SizedBox(height: 48),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
