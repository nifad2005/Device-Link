import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/widgets/premium_card.dart';

class TrackpadScreen extends StatefulWidget {
  const TrackpadScreen({super.key});

  @override
  State<TrackpadScreen> createState() => _TrackpadScreenState();
}

class _TrackpadScreenState extends State<TrackpadScreen> {
  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'trackpad_hero',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Trackpad'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              onPressed: () {
                HapticFeedback.selectionClick();
              },
              icon: const Icon(Icons.tune_rounded),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: GestureDetector(
                  onPanUpdate: (details) {
                    // Send delta to PC service
                  },
                  onTap: () {
                    HapticFeedback.lightImpact();
                  },
                  onDoubleTap: () {
                    HapticFeedback.mediumImpact();
                  },
                  onLongPress: () {
                    HapticFeedback.heavyImpact();
                  },
                  child: PremiumCard(
                    padding: 0,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.touch_app_outlined,
                            size: 64,
                            color: Colors.white.withOpacity(0.05),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Precision Touch Surface',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.2),
                              fontSize: 16,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildMouseButton(
                        context,
                        label: 'LEFT',
                        onPressed: () {
                          HapticFeedback.lightImpact();
                        },
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _buildMouseButton(
                        context,
                        label: 'RIGHT',
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildMouseButton(BuildContext context, {required String label, required VoidCallback onPressed}) {
    return PremiumCard(
      padding: 0,
      onTap: onPressed,
      child: Container(
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: Colors.white38,
          ),
        ),
      ),
    );
  }
}
