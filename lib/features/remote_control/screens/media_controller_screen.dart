import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/widgets/premium_card.dart';
import '../../../services/connection_service.dart';
import '../../../core/models/bridge_message.dart';

class MediaControllerScreen extends StatefulWidget {
  const MediaControllerScreen({super.key});

  @override
  State<MediaControllerScreen> createState() => _MediaControllerScreenState();
}

class _MediaControllerScreenState extends State<MediaControllerScreen> {
  final ConnectionService _connectionService = ConnectionService();
  double _volume = 0.5;

  void _sendMediaCommand(String command) {
    HapticFeedback.lightImpact();
    _connectionService.sendMessage(BridgeMessage(
      type: MessageType.mediaCommand,
      data: {'command': command},
    ));
  }

  void _sendVolumeCommand(double value) {
    setState(() => _volume = value);
    _connectionService.sendMessage(BridgeMessage(
      type: MessageType.mediaCommand,
      data: {'command': 'volume', 'value': value},
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'media_hero',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Now Playing'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PremiumCard(
                padding: 0,
                color: Colors.white.withOpacity(0.05),
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Icon(
                    Icons.music_note_rounded,
                    size: 100,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),
              const SizedBox(height: 56),
              const Text(
                'No Media Active',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Start playing something on your PC',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white.withOpacity(0.4),
                ),
              ),
              const SizedBox(height: 64),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildMediaButton(
                    context,
                    icon: Icons.skip_previous_rounded,
                    onPressed: () => _sendMediaCommand('previous'),
                  ),
                  _buildPlayButton(context),
                  _buildMediaButton(
                    context,
                    icon: Icons.skip_next_rounded,
                    onPressed: () => _sendMediaCommand('next'),
                  ),
                ],
              ),
              const SizedBox(height: 64),
              Row(
                children: [
                  const Icon(Icons.volume_down_rounded, color: Colors.white24, size: 20),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 4,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                      ),
                      child: Slider(
                        value: _volume,
                        onChanged: _sendVolumeCommand,
                        activeColor: Theme.of(context).colorScheme.primary,
                        inactiveColor: Colors.white.withOpacity(0.05),
                      ),
                    ),
                  ),
                  const Icon(Icons.volume_up_rounded, color: Colors.white24, size: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMediaButton(BuildContext context,
      {required IconData icon, required VoidCallback onPressed}) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: 36, color: Colors.white.withOpacity(0.8)),
    );
  }

  Widget _buildPlayButton(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _sendMediaCommand('toggle'),
          customBorder: const CircleBorder(),
          child: const Icon(
            Icons.play_arrow_rounded,
            size: 56,
            color: Color(0xFF1A1C1E),
          ),
        ),
      ),
    );
  }
}
