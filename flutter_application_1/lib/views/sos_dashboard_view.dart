import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../services/app_localizations.dart';
import '../services/sangini_controller.dart';
import '../theme/app_theme.dart';
import '../main.dart';
import 'voice_listener_dialog.dart';

class SosDashboardView extends StatefulWidget {
  final VoidCallback onNavigateToCascade;
  final VoidCallback onNavigateToRadar;

  const SosDashboardView({
    super.key,
    required this.onNavigateToCascade,
    required this.onNavigateToRadar,
  });

  @override
  State<SosDashboardView> createState() => _SosDashboardViewState();
}

class _SosDashboardViewState extends State<SosDashboardView>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isHolding = false;
  double _holdProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _triggerPanic(SanginiController controller) async {
    final res = await controller.triggerEmergencySOS();
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.primaryPink,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                res['message'] ?? 'Emergency SOS Broadcast Dispatched across Mesh!',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );

    widget.onNavigateToCascade();
  }

  void _showEditProfileDialog(SanginiController controller) {
    final nameCtrl = TextEditingController(text: controller.userName);
    final roleCtrl = TextEditingController(text: controller.userRole);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Phone Identity & Mesh Profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Your Name on Other Phones', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: roleCtrl,
              decoration: const InputDecoration(labelText: 'Role (e.g. Commuter, Responder)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            Text(
              'Device ID: ${controller.deviceId} • IP: ${ApiService().baseUrl}',
              style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.updateProfile(nameCtrl.text.trim(), roleCtrl.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text('Save Profile'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = SanginiController();

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final incident = controller.incident;
        final isActive = incident.status == 'active' || incident.status == 'escalated';

        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Status Header & Device Identity
                  _buildHeader(controller),

                  const SizedBox(height: 12),

                  // Real Phone Mesh Status Pill
                  _buildPhoneMeshBanner(controller),

                  const SizedBox(height: 14),

                  // Real Cross-Device Incoming SOS Alert Banner (from another phone)
                  if (controller.hasIncomingCrossDeviceAlert) ...[
                    _buildIncomingAlertBanner(controller),
                    const SizedBox(height: 16),
                  ],

                  // Active Alert Ribbon if this device triggered SOS
                  if (isActive) ...[
                    _buildActiveAlertBanner(incident, context),
                    const SizedBox(height: 16),
                  ],

                  // Context Routing Switcher: Street vs Home
                  _buildContextRoutingCard(controller),

                  const SizedBox(height: 20),

                  // Hero SOS Button with Hold & Tap options
                  _buildHeroSosSection(controller, isActive),

                  const SizedBox(height: 24),

                  // Live Peer Mesh & Security Badges
                  _buildSecurityBadges(controller),

                  const SizedBox(height: 18),

                  // Quick Action Triggers: Calculator Disguise & Voice Listener
                  _buildQuickActionTriggers(controller),

                  const SizedBox(height: 18),

                  // Emergency Helplines Direct Connect
                  _buildHelplinesCard(context),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(SanginiController controller) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.primaryPink.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.primaryPink.withValues(alpha: 0.4)),
          ),
          child: const Icon(Icons.shield_outlined, color: AppTheme.primaryPink, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Sangini AI',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryViolet.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppTheme.secondaryViolet.withValues(alpha: 0.4)),
                    ),
                    child: const Text(
                      'संगिनी',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.secondaryViolet,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '${controller.userName} (${controller.deviceId})',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.statusCyan),
              ),
            ],
          ),
        ),
        InkWell(
          onTap: () => showLanguageSelector(context, controller),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.statusCyan.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.language, size: 14, color: AppTheme.statusCyan),
                const SizedBox(width: 4),
                Text(
                  AppLocalizations.languageShortCodes[controller.currentLanguage] ?? 'EN',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 2),
        IconButton(
          tooltip: 'Edit Phone Identity',
          onPressed: () => _showEditProfileDialog(controller),
          icon: const Icon(Icons.badge_outlined, color: AppTheme.statusCyan),
        ),
        IconButton(
          tooltip: 'Toggle Calculator Disguise',
          onPressed: () => controller.toggleCalculatorDisguise(),
          icon: const Icon(Icons.calculate_outlined, color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  Widget _buildPhoneMeshBanner(SanginiController controller) {
    final liveCount = controller.livePeers.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: controller.isBackendConnected ? AppTheme.statusEmerald.withValues(alpha: 0.4) : AppTheme.statusAmber.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: controller.isBackendConnected ? AppTheme.statusEmerald : AppTheme.statusAmber,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              controller.isBackendConnected
                  ? 'Mesh Active • $liveCount other phone${liveCount == 1 ? '' : 's'} connected nearby'
                  : 'Offline Mesh • Connect phones to same Wi-Fi',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: controller.isBackendConnected ? AppTheme.statusEmerald : AppTheme.statusAmber,
              ),
            ),
          ),
          InkWell(
            onTap: widget.onNavigateToRadar,
            child: const Text(
              'View Radar >',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.statusCyan),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomingAlertBanner(SanginiController controller) {
    final incident = controller.incident;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.statusRose.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.statusRose, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppTheme.statusRose,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.notification_important, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🚨 REAL-TIME DISTRESS ALERT DETECTED!',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppTheme.statusRose),
                    ),
                    Text(
                      'Incident ${incident.id} • Short Code: [${incident.shortCode}]',
                      style: const TextStyle(fontSize: 11, color: AppTheme.textPrimary),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18, color: AppTheme.textMuted),
                onPressed: () => controller.dismissIncomingAlert(),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'A nearby user triggered an emergency SOS (${incident.context.toUpperCase()}). Auto-escalation countdown: ${incident.timeRemaining}s remaining.',
            style: const TextStyle(fontSize: 11.5, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final res = await controller.acceptIncomingIncident();
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppTheme.statusEmerald,
                        content: Text(res['message'] ?? 'Incident accepted! You are marked en-route.'),
                      ),
                    );
                    widget.onNavigateToCascade();
                  },
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text('Accept & Respond (OK)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.statusEmerald,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: widget.onNavigateToRadar,
                child: const Text('View on Radar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveAlertBanner(Incident incident, BuildContext context) {
    final isEscalated = incident.status == 'escalated';
    return InkWell(
      onTap: widget.onNavigateToCascade,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isEscalated
              ? AppTheme.statusAmber.withValues(alpha: 0.15)
              : AppTheme.primaryPink.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isEscalated ? AppTheme.statusAmber : AppTheme.primaryPink,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isEscalated ? AppTheme.statusAmber : AppTheme.primaryPink,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isEscalated ? Icons.notification_important : Icons.crisis_alert,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEscalated
                        ? 'TIER 2 AUTO-ESCALATED: Police 112 Interceptor'
                        : 'YOUR SOS IS ACTIVE: Code ${incident.shortCode} • Tier ${incident.tier}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    incident.timeRemaining > 0
                        ? '${incident.timeRemaining}s before Tier 2 auto-escalation • Broadcasting'
                        : 'Escalated to Pink Police Patrol • Tap for live status',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textPrimary.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildContextRoutingCard(SanginiController controller) {
    final isStreet = controller.selectedContext == 'street';

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
              const Icon(Icons.alt_route_rounded, size: 18, color: AppTheme.secondaryViolet),
              const SizedBox(width: 8),
              const Text(
                'Location Routing Mode (24h Twist)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isStreet ? AppTheme.statusCyan.withValues(alpha: 0.2) : AppTheme.statusRose.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isStreet ? 'Radar: ON' : 'Radar: HIDDEN',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isStreet ? AppTheme.statusCyan : AppTheme.statusRose,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildRoutingChoice(
                  title: controller.tr('streetMode'),
                  subtitle: controller.tr('streetModeDesc'),
                  icon: Icons.directions_walk,
                  isSelected: isStreet,
                  activeColor: AppTheme.statusCyan,
                  onTap: () => controller.setContext('street'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildRoutingChoice(
                  title: controller.tr('homeMode'),
                  subtitle: controller.tr('homeModeDesc'),
                  icon: Icons.home_rounded,
                  isSelected: !isStreet,
                  activeColor: AppTheme.secondaryViolet,
                  onTap: () => controller.setContext('home'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                isStreet ? Icons.info_outline : Icons.lock_outline,
                size: 14,
                color: AppTheme.textMuted,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  isStreet
                      ? 'Alert routes to verified nearby female peers within 200m mesh radius.'
                      : 'Protects domestic privacy: Excluded from peer radar; sent directly to Helpline 181.',
                  style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoutingChoice({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: 0.14) : AppTheme.surfaceElevated.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? activeColor : AppTheme.border,
            width: isSelected ? 1.6 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: isSelected ? activeColor : AppTheme.textSecondary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : AppTheme.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? AppTheme.textPrimary.withValues(alpha: 0.9) : AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSosSection(SanginiController controller, bool isActive) {
    return Center(
      child: Column(
        children: [
          ScaleTransition(
            scale: isActive ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer Pulse Ring
                Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryPink.withValues(alpha: isActive ? 0.45 : 0.22),
                        blurRadius: 36,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                ),
                // Hold-to-activate circular progress
                SizedBox(
                  width: 196,
                  height: 196,
                  child: CircularProgressIndicator(
                    value: _isHolding ? _holdProgress : (isActive ? 1.0 : 0.0),
                    strokeWidth: 6,
                    backgroundColor: Colors.white12,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isActive ? AppTheme.statusAmber : AppTheme.primaryPink,
                    ),
                  ),
                ),
                // Core SOS Panic Button
                GestureDetector(
                  onTap: () => _triggerPanic(controller),
                  onLongPressStart: (_) {
                    setState(() {
                      _isHolding = true;
                      _holdProgress = 0.0;
                    });
                  },
                  onLongPressEnd: (_) {
                    setState(() {
                      _isHolding = false;
                      _holdProgress = 0.0;
                    });
                  },
                  child: Container(
                    width: 170,
                    height: 170,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isActive
                            ? [const Color(0xFFEF4444), const Color(0xFF991B1B)]
                            : [const Color(0xFFF43F5E), const Color(0xFFBE123C)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryPink.withValues(alpha: 0.5),
                          offset: const Offset(0, 8),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isActive ? Icons.crisis_alert : Icons.touch_app_rounded,
                          size: 40,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          controller.tr('heroSos'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isActive ? controller.tr('sosActive') : controller.tr('holdSos'),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilterChip(
                selected: controller.silentMode,
                onSelected: (_) => controller.toggleSilentMode(),
                avatar: Icon(
                  controller.silentMode ? Icons.volume_off : Icons.volume_up,
                  size: 16,
                  color: controller.silentMode ? AppTheme.primaryPink : AppTheme.textMuted,
                ),
                label: Text(
                  controller.silentMode ? 'Stealth Silent Mode' : 'Audible Siren Mode',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: controller.silentMode ? Colors.white : AppTheme.textSecondary,
                  ),
                ),
                backgroundColor: AppTheme.surfaceCard,
                selectedColor: AppTheme.primaryPink.withValues(alpha: 0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: controller.silentMode ? AppTheme.primaryPink : AppTheme.border,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityBadges(SanginiController controller) {
    final liveCount = controller.livePeers.length;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildBadgeItem(
            icon: Icons.fingerprint,
            label: 'Aadhaar ID',
            sublabel: 'Verified Peer',
            color: AppTheme.statusEmerald,
          ),
          Container(width: 1, height: 38, color: AppTheme.border),
          _buildBadgeItem(
            icon: Icons.wifi_tethering,
            label: 'Shakti Mesh',
            sublabel: '$liveCount Real Peer${liveCount == 1 ? '' : 's'}',
            color: AppTheme.statusCyan,
          ),
          Container(width: 1, height: 38, color: AppTheme.border),
          _buildBadgeItem(
            icon: Icons.security,
            label: 'Anti-Luring',
            sublabel: 'Shield Active',
            color: AppTheme.secondaryViolet,
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeItem({
    required IconData icon,
    required String label,
    required String sublabel,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
        ),
        Text(
          sublabel,
          style: TextStyle(fontSize: 10, color: color),
        ),
      ],
    );
  }

  Widget _buildQuickActionTriggers(SanginiController controller) {
    return Row(
      children: [
        Expanded(
          child: _buildActionTile(
            title: 'Discreet Calculator',
            subtitle: 'Stealth PIN "911=" disguise',
            icon: Icons.calculate,
            color: AppTheme.accentIndigo,
            onTap: () => controller.toggleCalculatorDisguise(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionTile(
            title: 'Voice Distress Listener',
            subtitle: 'AI keyword detection',
            icon: Icons.mic,
            color: AppTheme.secondaryViolet,
            onTap: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (_) => const VoiceListenerDialog(),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 10.5, color: AppTheme.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelplinesCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rapid Emergency Dispatch',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildCallButton('112', 'Police CAD', Icons.local_police, const Color(0xFF3B82F6)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildCallButton('181', 'Women Helpline', Icons.support_agent, const Color(0xFFEC4899)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildCallButton('1091', 'Distress Desk', Icons.shield, const Color(0xFF10B981)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCallButton(String number, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 2),
          Text(
            number,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 9.5, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}
