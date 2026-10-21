import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/sangini_controller.dart';
import '../theme/app_theme.dart';

class VoiceListenerDialog extends StatefulWidget {
  const VoiceListenerDialog({super.key});

  @override
  State<VoiceListenerDialog> createState() => _VoiceListenerDialogState();
}

class _VoiceListenerDialogState extends State<VoiceListenerDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    final controller = SanginiController();
    controller.startVoiceListening();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = SanginiController();

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final stress = controller.audioStressLevel;
        final transcript = controller.lastVoiceTranscript;

        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.surfaceCard,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.mic, color: AppTheme.secondaryViolet, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'Voice Distress Keyword Listener',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () {
                      controller.stopVoiceListening();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Animated Soundwave Visualizer
              Container(
                height: 90,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.secondaryViolet.withOpacity(0.3)),
                ),
                child: AnimatedBuilder(
                  animation: _waveController,
                  builder: (context, _) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(16, (index) {
                        final factor = math.sin((index / 16.0) * math.pi) * (0.3 + stress * 0.7);
                        final h = 10.0 + (factor * 60.0 * _waveController.value);
                        return Container(
                          width: 4,
                          height: h.clamp(6.0, 75.0),
                          decoration: BoxDecoration(
                            color: stress > 0.8
                                ? AppTheme.primaryPink
                                : (stress > 0.4 ? AppTheme.statusAmber : AppTheme.secondaryViolet),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    );
                  },
                ),
              ),

              const SizedBox(height: 14),

              // Decibel / Stress Level Gauge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Vocal Stress Metric:', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                  Text(
                    '${(stress * 100).toInt()}% Stress Index',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: stress > 0.8 ? AppTheme.statusRose : AppTheme.statusEmerald,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: stress,
                  minHeight: 6,
                  backgroundColor: AppTheme.surfaceElevated,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    stress > 0.8 ? AppTheme.statusRose : AppTheme.secondaryViolet,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Live Detection Transcript
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  transcript.isEmpty ? 'Listening for distress cries...' : transcript,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontStyle: FontStyle.italic,
                    color: stress > 0.8 ? AppTheme.statusRose : AppTheme.textSecondary,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Simulate Distress Trigger (Test Keywords):',
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                ),
              ),
              const SizedBox(height: 8),

              // Keyword Simulation Chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildKeywordChip('Bachao! (बचाओ)', controller),
                  _buildKeywordChip('Help me!', controller),
                  _buildKeywordChip('Chhodo mujhe!', controller),
                  _buildKeywordChip('High Pitch Scream (95dB)', controller),
                ],
              ),

              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildKeywordChip(String keyword, SanginiController controller) {
    return ActionChip(
      backgroundColor: AppTheme.primaryPink.withOpacity(0.15),
      side: BorderSide(color: AppTheme.primaryPink.withOpacity(0.5)),
      avatar: const Icon(Icons.record_voice_over, size: 14, color: AppTheme.primaryPink),
      label: Text(
        keyword,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.primaryPink),
      ),
      onPressed: () {
        controller.simulateKeywordTrigger(keyword);
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) Navigator.pop(context);
        });
      },
    );
  }
}
