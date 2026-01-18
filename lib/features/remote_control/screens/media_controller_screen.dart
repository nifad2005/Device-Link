import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/widgets/premium_card.dart';

class MediaControllerScreen extends StatelessWidget {
  const MediaControllerScreen({super.key});

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
              // Media Art Placeholder
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
              // Playback Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildMediaButton(
                    context,
                    icon: Icons.skip_previous_rounded,
                    onPressed: () => HapticFeedback.lightImpact(),
                  ),
                  _buildPlayButton(context),
                  _buildMediaButton(
                    context,
                    icon: Icons.skip_next_rounded,
                    onPressed: () => HapticFeedback.lightImpact(),
                  ),
                ],
              ),
              const SizedBox(height: 64),
              // Volume Slider
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
                        value: 0.5,
                        onChanged: (val) {
                          // Haptic feedback for slider movement can be noisy, 
                          // maybe only on start/end or specific intervals
                        },
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
          onTap: () => HapticFeedback.mediumImpact(),
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
