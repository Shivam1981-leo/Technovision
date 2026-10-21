import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/app_localizations.dart';
import '../services/sangini_controller.dart';
import '../theme/app_theme.dart';
import '../main.dart';

class PeerRadarView extends StatefulWidget {
  const PeerRadarView({super.key});

  @override
  State<PeerRadarView> createState() => _PeerRadarViewState();
}

class _PeerRadarViewState extends State<PeerRadarView>
    with SingleTickerProviderStateMixin {
  late AnimationController _sweepController;

  @override
  void initState() {
    super.initState();
    _sweepController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _sweepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = SanginiController();

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final incident = controller.incident;
        final isHome = incident.context == 'home';
        final isRadarVisible = incident.peerRadarVisible && !isHome;
        final realPeers = controller.livePeers;

        return Scaffold(
          appBar: AppBar(
            title: Text('${controller.tr('tabPeerRadar')} (200m)'),
            actions: [
              IconButton(
                tooltip: controller.tr('selectLanguage'),
                icon: const Icon(Icons.language, color: AppTheme.statusCyan),
                onPressed: () => showLanguageSelector(context, controller),
              ),
              IconButton(
                tooltip: controller.tr('renamePhone'),
                icon: const Icon(Icons.badge_outlined, color: AppTheme.statusEmerald),
                onPressed: () => _showIdentityDialog(context, controller),
              ),
              IconButton(
                tooltip: 'Switch Context',
                icon: Icon(
                  isHome ? Icons.home : Icons.directions_walk,
                  color: isHome ? AppTheme.secondaryViolet : AppTheme.statusCyan,
                ),
                onPressed: () {
                  controller.setContext(isHome ? 'street' : 'home');
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Privacy / Routing Indicator Ribbon
                if (isHome) ...[
                  _buildPrivacyShieldCard(controller),
                  const SizedBox(height: 16),
                ] else ...[
                  _buildStreetBroadcastCard(controller, realPeers.length),
                  const SizedBox(height: 16),
                ],

                // Radar Display Canvas
                Center(
                  child: Container(
                    width: 320,
                    height: 320,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF070B13),
                      border: Border.all(
                        color: isRadarVisible ? AppTheme.statusCyan.withValues(alpha: 0.4) : AppTheme.secondaryViolet.withValues(alpha: 0.4),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (isRadarVisible ? AppTheme.statusCyan : AppTheme.secondaryViolet).withValues(alpha: 0.12),
                          blurRadius: 24,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Animated Radar Canvas Painter
                        AnimatedBuilder(
                          animation: _sweepController,
                          builder: (context, _) {
                            return CustomPaint(
                              size: const Size(320, 320),
                              painter: RadarPainter(
                                sweepAngle: _sweepController.value * 2 * math.pi,
                                isVisible: isRadarVisible,
                              ),
                            );
                          },
                        ),

                        // Center User Node (This Phone)
                        _buildUserCenterNode(isHome, controller.userName),

                        // Nearby Peers (Real connected phones + default fallback)
                        if (isRadarVisible) ...[
                          if (realPeers.isNotEmpty) ...[
                            ...realPeers.asMap().entries.map((entry) {
                              final idx = entry.key;
                              final p = entry.value;
                              // Spread real connected phones radially
                              final angle = (idx * (2 * math.pi / realPeers.length)) + 0.4;
                              final radDist = (p.distanceMeters.clamp(20, 200) / 200.0) * 120.0;
                              final x = radDist * math.cos(angle);
                              final y = radDist * math.sin(angle);

                              return _buildRadarNode(
                                xOffset: x,
                                yOffset: y,
                                label: p.name,
                                distance: '${p.distanceMeters}m',
                                icon: Icons.phone_android,
                                color: AppTheme.statusEmerald,
                              );
                            }),
                          ] else ...[
                            _buildRadarNode(
                              xOffset: 45,
                              yOffset: -65,
                              label: 'Priya S.',
                              distance: '85m',
                              icon: Icons.person_pin_circle,
                              color: AppTheme.statusEmerald,
                            ),
                            _buildRadarNode(
                              xOffset: -80,
                              yOffset: -40,
                              label: 'Ananya K.',
                              distance: '145m',
                              icon: Icons.person_pin_circle,
                              color: AppTheme.statusEmerald,
                            ),
                            _buildRadarNode(
                              xOffset: 70,
                              yOffset: 85,
                              label: 'Dr. Neha',
                              distance: '190m',
                              icon: Icons.medical_services,
                              color: AppTheme.statusCyan,
                            ),
                          ],
                          // Safe Havens
                          _buildRadarNode(
                            xOffset: -60,
                            yOffset: 65,
                            label: 'Apollo 24/7',
                            distance: '140m',
                            icon: Icons.local_pharmacy,
                            color: AppTheme.statusAmber,
                          ),
                          _buildRadarNode(
                            xOffset: 100,
                            yOffset: -20,
                            label: 'Police Kiosk',
                            distance: '220m',
                            icon: Icons.local_police,
                            color: const Color(0xFF3B82F6),
                          ),
                        ] else ...[
                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppTheme.secondaryViolet),
                              ),
                              child: const Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.shield, color: AppTheme.secondaryViolet, size: 28),
                                  SizedBox(height: 6),
                                  Text(
                                    'PRIVACY SHIELD ACTIVE',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Domestic incident hidden from mesh radar',
                                    style: TextStyle(fontSize: 10, color: AppTheme.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                // Real Connected Phones List
                if (isRadarVisible && realPeers.isNotEmpty) ...[
                  _buildRealPeersSection(controller, realPeers),
                  const SizedBox(height: 18),
                ],

                // Nearby Safe Havens Directory
                _buildSafeHavensList(controller),

                const SizedBox(height: 18),

                // Mesh Peering Info
                if (isRadarVisible && realPeers.isEmpty) _buildPeersList(controller),

                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPrivacyShieldCard(SanginiController controller) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.secondaryViolet.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.secondaryViolet.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.privacy_tip_outlined, color: AppTheme.secondaryViolet, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.tr('privacyShieldActive'),
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  controller.tr('privacyShieldDesc'),
                  style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreetBroadcastCard(SanginiController controller, int realPeerCount) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.statusCyan.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.statusCyan.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.radar, color: AppTheme.statusCyan, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${controller.tr('streetRadarActive')} ($realPeerCount ${controller.tr('online')})',
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      realPeerCount > 0
                          ? '🟢 $realPeerCount ${controller.tr('realPhonesConnected')}'
                          : controller.tr('listeningOnMesh'),
                      style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Your device chip with rename button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.statusCyan.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.phone_android, size: 14, color: AppTheme.statusCyan),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${controller.tr('thisDevice')}: ${controller.userName} (${controller.deviceId})',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                InkWell(
                  onTap: () => _showIdentityDialog(context, controller),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.statusCyan.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      controller.tr('renamePhone'),
                      style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: AppTheme.statusCyan),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showIdentityDialog(BuildContext context, SanginiController controller) {
    final nameCtrl = TextEditingController(text: controller.userName);
    final roleCtrl = TextEditingController(text: controller.userRole);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceCard,
        title: Text(controller.tr('changeIdentity'), style: const TextStyle(color: Colors.white, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: '${controller.tr('renamePhone')} (e.g. Phone 1 - Victim)',
                labelStyle: const TextStyle(color: AppTheme.textSecondary),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: roleCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Role (e.g. Verified Peer / Responder)',
                labelStyle: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(controller.tr('cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.statusEmerald),
            onPressed: () {
              if (nameCtrl.text.trim().isNotEmpty) {
                controller.updateProfile(nameCtrl.text.trim(), roleCtrl.text.trim());
              }
              Navigator.pop(ctx);
            },
            child: Text(controller.tr('saveAndBroadcast'), style: const TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCenterNode(bool isHome, String myName) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isHome ? AppTheme.secondaryViolet : AppTheme.primaryPink,
            boxShadow: [
              BoxShadow(
                color: (isHome ? AppTheme.secondaryViolet : AppTheme.primaryPink).withValues(alpha: 0.6),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(
            isHome ? Icons.home : Icons.phone_android,
            size: 13,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 3),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            'YOU ($myName)',
            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildRadarNode({
    required double xOffset,
    required double yOffset,
    required String label,
    required String distance,
    required IconData icon,
    required Color color,
  }) {
    return Transform.translate(
      offset: Offset(xOffset, yOffset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 1.2),
            ),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '$label • $distance',
              style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w600, color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRealPeersSection(SanginiController controller, List<LiveMeshPeer> realPeers) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.statusEmerald.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.phonelink_ring, size: 18, color: AppTheme.statusEmerald),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  controller.tr('livePeersTitle'),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.statusEmerald.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${realPeers.length} ${controller.tr('online')}',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.statusEmerald),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...realPeers.map((p) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.statusEmerald.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.phone_android, size: 16, color: AppTheme.statusEmerald),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.name,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                          ),
                          Text(
                            '${p.role} • Battery: ${p.battery}% • ID: ${p.id}',
                            style: const TextStyle(fontSize: 10.5, color: AppTheme.textMuted),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.statusEmerald.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${p.distanceMeters}m ${controller.tr('metersAway')}',
                        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: AppTheme.statusEmerald),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildSafeHavensList(SanginiController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.storefront_outlined, size: 18, color: AppTheme.statusAmber),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  controller.tr('safeHavensTitle'),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...controller.safeHavens.map((sh) => _buildSafeHavenRow(sh)),
        ],
      ),
    );
  }

  Widget _buildSafeHavenRow(SafeHaven sh) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.statusAmber.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.shield, size: 16, color: AppTheme.statusAmber),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sh.name,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                ),
                Text(
                  '${sh.type} • ${sh.contact}',
                  style: const TextStyle(fontSize: 10.5, color: AppTheme.textMuted),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.statusEmerald.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${sh.distanceM}m',
              style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: AppTheme.statusEmerald),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeersList(SanginiController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.people_outline, size: 18, color: AppTheme.statusCyan),
              SizedBox(width: 8),
              Text(
                'Active Shakti Mesh Peer Responders',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...controller.peerMeshList.map((p) => _buildPeerRow(p)),
        ],
      ),
    );
  }

  Widget _buildPeerRow(Responder p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_user, size: 16, color: AppTheme.statusCyan),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              p.name,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
            ),
          ),
          Text(
            p.distance,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.statusCyan),
          ),
        ],
      ),
    );
  }
}

class RadarPainter extends CustomPainter {
  final double sweepAngle;
  final bool isVisible;

  RadarPainter({required this.sweepAngle, required this.isVisible});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final ringPaint = Paint()
      ..color = (isVisible ? const Color(0xFF06B6D4) : const Color(0xFF8B5CF6)).withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw concentric circles: 50m, 100m, 150m, 200m
    canvas.drawCircle(center, radius * 0.25, ringPaint);
    canvas.drawCircle(center, radius * 0.50, ringPaint);
    canvas.drawCircle(center, radius * 0.75, ringPaint);
    canvas.drawCircle(center, radius * 0.98, ringPaint);

    // Crosshairs
    canvas.drawLine(Offset(center.dx, 0), Offset(center.dx, size.height), ringPaint);
    canvas.drawLine(Offset(0, center.dy), Offset(size.width, center.dy), ringPaint);

    if (isVisible) {
      final sweepPaint = Paint()
        ..shader = SweepGradient(
          center: Alignment.center,
          startAngle: 0.0,
          endAngle: 2 * math.pi,
          colors: [
            const Color(0xFF06B6D4).withValues(alpha: 0.0),
            const Color(0xFF06B6D4).withValues(alpha: 0.35),
          ],
          transform: GradientRotation(sweepAngle),
        ).createShader(Rect.fromCircle(center: center, radius: radius));

      canvas.drawCircle(center, radius, sweepPaint);

      final beamX = center.dx + radius * math.cos(sweepAngle);
      final beamY = center.dy + radius * math.sin(sweepAngle);
      final beamLinePaint = Paint()
        ..color = const Color(0xFF06B6D4)
        ..strokeWidth = 1.8;
      canvas.drawLine(center, Offset(beamX, beamY), beamLinePaint);
    }
  }

  @override
  bool shouldRepaint(covariant RadarPainter oldDelegate) {
    return oldDelegate.sweepAngle != sweepAngle || oldDelegate.isVisible != isVisible;
  }
}
