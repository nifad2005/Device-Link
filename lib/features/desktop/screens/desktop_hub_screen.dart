import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:file_picker/file_picker.dart';
import '../../../services/connection_service.dart';
import '../../../core/widgets/premium_card.dart';
import '../../../services/file_transfer_service.dart';
import 'dart:io';
import 'package:open_filex/open_filex.dart';

class DesktopHubScreen extends StatefulWidget {
  const DesktopHubScreen({super.key});

  @override
  State<DesktopHubScreen> createState() => _DesktopHubScreenState();
}

class _DesktopHubScreenState extends State<DesktopHubScreen> {
  final List<FileTransferProgress> _transfers = [];
  final FileTransferService _fileTransferService = FileTransferService();

  @override
  void initState() {
    super.initState();
    _fileTransferService.progressStream.listen((progress) {
      if (mounted) {
        setState(() {
          final index = _transfers.indexWhere((t) => t.fileName == progress.fileName);
          if (index >= 0) {
            _transfers[index] = progress;
          } else {
            _transfers.insert(0, progress);
          }
        });
      }
    });
  }

  Future<void> _pickAndSendFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      await _fileTransferService.sendFile(file);
    }
  }

  @override
  Widget build(BuildContext context) {
    final connectionService = ConnectionService();

    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 320,
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
                  'SYSTEM STATUS',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.white24),
                ),
                const SizedBox(height: 16),
                _buildStatusIndicator(connectionService),
                const SizedBox(height: 32),
                const Text(
                  'CONNECTED CLIENTS',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.white24),
                ),
                const SizedBox(height: 16),
                ValueListenableBuilder<int>(
                  valueListenable: connectionService.connectedClientsCount,
                  builder: (context, count, child) {
                    if (count == 0) return const Text('Waiting for connection...', style: TextStyle(color: Colors.white10, fontSize: 12));
                    return Column(
                      children: List.generate(count, (i) => _buildClientTile('Mobile Device ${i+1}')),
                    );
                  },
                ),
                const Spacer(),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: ValueListenableBuilder<int>(
              valueListenable: connectionService.connectedClientsCount,
              builder: (context, count, child) {
                if (count == 0) {
                  return _buildPairingView(connectionService);
                } else {
                  return _buildActiveDashboard();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(ConnectionService service) {
    return ValueListenableBuilder<String?>(
      valueListenable: service.serverAddress,
      builder: (context, address, child) {
        return Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: address != null ? Colors.greenAccent : Colors.redAccent,
                shape: BoxShape.circle,
                boxShadow: [
                  if (address != null) BoxShadow(color: Colors.greenAccent.withOpacity(0.5), blurRadius: 8)
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              address != null ? 'Online at $address' : 'Offline',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        );
      }
    );
  }

  Widget _buildClientTile(String name) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: PremiumCard(
        padding: 12,
        color: Colors.white.withOpacity(0.05),
        child: Row(
          children: [
            const Icon(Icons.smartphone_rounded, color: Colors.greenAccent, size: 16),
            const SizedBox(width: 12),
            Text(name, style: const TextStyle(fontSize: 13, color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  Widget _buildPairingView(ConnectionService service) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ValueListenableBuilder<String?>(
              valueListenable: service.serverAddress,
              builder: (context, address, child) {
                if (address == null) return const CircularProgressIndicator();
                return PremiumCard(
                  padding: 40,
                  child: Column(
                    children: [
                      const Text('Link Mobile Device', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      const Text('Scan to establish bridge', textAlign: TextAlign.center, style: TextStyle(color: Colors.white38)),
                      const SizedBox(height: 40),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                        child: QrImageView(data: address, size: 200),
                      ),
                      const SizedBox(height: 40),
                      Text(address, style: const TextStyle(color: Colors.white24, fontSize: 12, letterSpacing: 2)),
                    ],
                  ),
                );
              }
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveDashboard() {
    return Padding(
      padding: const EdgeInsets.all(48.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bridge Active', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  Text('Your workstation is now being controlled remotely', style: TextStyle(color: Colors.white38)),
                ],
              ),
              Row(
                children: [
                  FilledButton.icon(
                    onPressed: _pickAndSendFile,
                    icon: const Icon(Icons.send_to_mobile_rounded),
                    label: const Text('Send File to Mobile'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    onPressed: () => ConnectionService().disconnect(),
                    icon: const Icon(Icons.power_settings_new_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.redAccent.withOpacity(0.1),
                      foregroundColor: Colors.redAccent,
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 48),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Transfers Section
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('FILE TRANSFERS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.white24)),
                      const SizedBox(height: 24),
                      Expanded(
                        child: _transfers.isEmpty 
                          ? const Center(child: Text('No transfers yet', style: TextStyle(color: Colors.white10)))
                          : ListView.builder(
                              itemCount: _transfers.length,
                              itemBuilder: (context, index) {
                                final transfer = _transfers[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: PremiumCard(
                                    onTap: (transfer.isIncoming && transfer.isComplete) ? () => OpenFilex.open(transfer.fileName) : null,
                                    child: Row(
                                      children: [
                                        Icon(
                                          transfer.isIncoming ? Icons.download_rounded : Icons.upload_rounded,
                                          color: Colors.white30,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(transfer.fileName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                              const SizedBox(height: 8),
                                              LinearProgressIndicator(
                                                value: transfer.progress,
                                                minHeight: 2,
                                                backgroundColor: Colors.white10,
                                                color: transfer.isIncoming ? Colors.greenAccent : Theme.of(context).colorScheme.primary,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        if (transfer.isComplete) const Icon(Icons.check_circle, color: Colors.greenAccent, size: 18)
                                        else Text('${(transfer.progress * 100).toInt()}%', style: const TextStyle(fontSize: 12, color: Colors.white38)),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 48),
                // Feature Status section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('ACTIVE SESSIONS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.white24)),
                      const SizedBox(height: 24),
                      _buildFeatureStatusTile(Icons.mouse_rounded, 'Trackpad Control', 'Active', Colors.blueAccent),
                      _buildFeatureStatusTile(Icons.play_circle_fill, 'Media Bridge', 'Standby', Colors.orangeAccent),
                      _buildFeatureStatusTile(Icons.power_settings_new, 'System Power', 'Linked', Colors.redAccent),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureStatusTile(IconData icon, String title, String status, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: PremiumCard(
        padding: 16,
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                Text(status, style: TextStyle(fontSize: 12, color: color.withOpacity(0.7))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
