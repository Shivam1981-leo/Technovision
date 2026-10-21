import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/sangini_controller.dart';
import '../theme/app_theme.dart';
import '../main.dart';

class CascadeEscalationView extends StatefulWidget {
  const CascadeEscalationView({super.key});

  @override
  State<CascadeEscalationView> createState() => _CascadeEscalationViewState();
}

class _CascadeEscalationViewState extends State<CascadeEscalationView> {
  final TextEditingController _responderIdCtrl = TextEditingController(text: 'R12');
  final TextEditingController _shortCodeCtrl = TextEditingController(text: 'BLUE');
  bool _isSubmitting = false;

  @override
  void dispose() {
    _responderIdCtrl.dispose();
    _shortCodeCtrl.dispose();
    super.dispose();
  }

  void _handleAcceptance(SanginiController controller) async {
    final rId = _responderIdCtrl.text.trim();
    final code = _shortCodeCtrl.text.trim();

    if (rId.isEmpty || code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both Responder ID and Short Code.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final res = await controller.acceptIncident(rId, code);
    setState(() => _isSubmitting = false);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: res['success'] == true ? AppTheme.statusEmerald : AppTheme.statusRose,
        behavior: SnackBarBehavior.floating,
        content: Text(res['message'] ?? 'Acceptance processed.'),
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
        final isActive = incident.status == 'active';
        final isAccepted = incident.status == 'accepted';
        final isEscalated = incident.status == 'escalated';
        final isIdle = incident.status == 'idle';

        final progress = (incident.timeRemaining / 60.0).clamp(0.0, 1.0);

        return Scaffold(
          appBar: AppBar(
            title: Text(controller.tr('cascadeTitle')),
            actions: [
              IconButton(
                tooltip: controller.tr('selectLanguage'),
                icon: const Icon(Icons.language, color: AppTheme.statusCyan),
                onPressed: () => showLanguageSelector(context, controller),
              ),
              IconButton(
                tooltip: 'Reset Incident',
                icon: const Icon(Icons.refresh, color: AppTheme.textSecondary),
                onPressed: () => controller.resetAll(),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Countdown & Short Code Gauge
                _buildCountdownGauge(incident, progress, isActive, isAccepted, isEscalated, isIdle),

                const SizedBox(height: 18),

                // Responder Quick Acceptance Form
                _buildResponderAcceptanceBox(controller, incident, isAccepted),

                const SizedBox(height: 22),

                // Multi-Tier Cascade Escalation Timeline
                _buildCascadeTimeline(incident),

                const SizedBox(height: 20),

                // Integration Stubs Live Monitor
                _buildIntegrationStubsCard(controller),

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCountdownGauge(
    Incident incident,
    double progress,
    bool isActive,
    bool isAccepted,
    bool isEscalated,
    bool isIdle,
  ) {
    Color gaugeColor = AppTheme.statusCyan;
    String statusLabel = 'STANDBY (IDLE)';
    String desc = 'Trigger an SOS to start the 60s auto-escalation cascade.';

    if (isActive) {
      gaugeColor = incident.timeRemaining <= 15 ? AppTheme.statusRose : AppTheme.statusAmber;
      statusLabel = 'COUNTDOWN ACTIVE: ${incident.timeRemaining}s';
      desc = 'If not accepted within 60s, incident auto-escalates to Tier 2 (Police 112 CAD).';
    } else if (isAccepted) {
      gaugeColor = AppTheme.statusEmerald;
      statusLabel = 'ACCEPTED BY RESPONDER';
      desc = 'Cascade timer halted. Verified peer en-route.';
    } else if (isEscalated) {
      gaugeColor = AppTheme.statusRose;
      statusLabel = 'TIER 2 AUTO-ESCALATED';
      desc = '60-second window expired without acceptance. Police 112 CAD dispatched.';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: gaugeColor.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Incident ${incident.id}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Routing: ${incident.context.toUpperCase()}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: incident.context == 'home' ? AppTheme.secondaryViolet : AppTheme.statusCyan,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: gaugeColor.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: gaugeColor.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.vpn_key_outlined, size: 13, color: Colors.white70),
                    const SizedBox(width: 4),
                    Text(
                      'CODE: ${incident.shortCode}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: gaugeColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: CircularProgressIndicator(
                  value: isIdle ? 1.0 : (isAccepted ? 1.0 : progress),
                  strokeWidth: 9,
                  backgroundColor: AppTheme.surfaceElevated,
                  valueColor: AlwaysStoppedAnimation<Color>(gaugeColor),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isIdle ? '--' : (isAccepted ? 'OK' : '${incident.timeRemaining}s'),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: gaugeColor,
                    ),
                  ),
                  Text(
                    isIdle ? 'NO ALERT' : (isAccepted ? 'RESOLVED' : 'REMAINING'),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            statusLabel,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: gaugeColor,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11.5, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildResponderAcceptanceBox(SanginiController controller, Incident incident, bool isAccepted) {
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
              Icon(Icons.handshake_outlined, size: 18, color: AppTheme.statusEmerald),
              SizedBox(width: 8),
              Text(
                'Responder Incident Acceptance (OK Command)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Simulate a nearby responder accepting the incident using their verified Responder ID and Short Code.',
            style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _responderIdCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Responder ID',
                    hintText: 'e.g. R12',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _shortCodeCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Short Code',
                    hintText: 'e.g. BLUE',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 3,
                child: ElevatedButton.icon(
                  onPressed: (incident.status != 'active' && incident.status != 'escalated') || _isSubmitting
                      ? null
                      : () => _handleAcceptance(controller),
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.check_circle_outline, size: 16),
                  label: const Text('Accept (OK)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.statusEmerald,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          if (incident.responders.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'En-Route Responders:',
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 6),
            ...incident.responders.map(
              (r) => Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.statusEmerald.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified, size: 14, color: AppTheme.statusEmerald),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${r.name} • ${r.distance}',
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                      ),
                    ),
                    Text(
                      r.acceptedAt ?? 'Just now',
                      style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCascadeTimeline(Incident incident) {
    final tier = incident.tier;
    final isEscalated = incident.status == 'escalated';

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
              Icon(Icons.stairs_outlined, size: 18, color: AppTheme.secondaryViolet),
              SizedBox(width: 8),
              Text(
                'Three-Tier Escalation Hierarchy',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildTierStep(
            tierNum: 1,
            title: incident.context == 'home'
                ? 'Tier 1: Women Helpline 181 Rapid Desk'
                : 'Tier 1: Nearby Peer Mesh & Safe Havens',
            desc: incident.context == 'home'
                ? 'Domestic incident: Hidden from peer radar for victim privacy. Dispatched directly to 181 counselors.'
                : 'Street incident: 200m broadcast to verified female commuters, local pharmacy safe havens, and metro booths.',
            timeframe: '0 - 60s Window',
            isActive: incident.status != 'idle',
            isCurrent: incident.status == 'active' && tier == 1,
            color: AppTheme.statusCyan,
          ),
          _buildTierStep(
            tierNum: 2,
            title: 'Tier 2: Community Patrols & NGO Rapid Units',
            desc: 'Auto-triggered if no valid "OK" acceptance arrives in 60s. Nirbhaya Pink Mobile Patrol mobilized.',
            timeframe: '60s - 120s Window',
            isActive: isEscalated || tier >= 2,
            isCurrent: isEscalated && tier == 2,
            color: AppTheme.statusAmber,
          ),
          _buildTierStep(
            tierNum: 3,
            title: 'Tier 3: State Police 112 CAD & ERSS Dispatch',
            desc: 'Emergency response command center dispatch with live GPS telemetry, audio logs, and Aadhaar identity trace.',
            timeframe: 'Critical Dispatch',
            isActive: isEscalated,
            isCurrent: isEscalated && tier >= 3,
            color: AppTheme.statusRose,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTierStep({
    required int tierNum,
    required String title,
    required String desc,
    required String timeframe,
    required bool isActive,
    required bool isCurrent,
    required Color color,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCurrent ? color : (isActive ? color.withOpacity(0.2) : AppTheme.surfaceElevated),
                border: Border.all(
                  color: isActive ? color : AppTheme.border,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  'T$tierNum',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isCurrent ? Colors.white : (isActive ? color : AppTheme.textMuted),
                  ),
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 52,
                color: isActive ? color.withOpacity(0.5) : AppTheme.border,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: isCurrent ? color : (isActive ? AppTheme.textPrimary : AppTheme.textMuted),
                        ),
                      ),
                    ),
                    Text(
                      timeframe,
                      style: TextStyle(fontSize: 10, color: isCurrent ? color : AppTheme.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIntegrationStubsCard(SanginiController controller) {
    final stubs = controller.stubs;

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
              Icon(Icons.hub_outlined, size: 18, color: AppTheme.statusCyan),
              SizedBox(width: 8),
              Text(
                'Live Integration Stubs Status',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildStubRow('Karnataka 112 CAD', stubs['police112']?['status'] ?? 'STANDBY', Icons.local_police),
          const SizedBox(height: 8),
          _buildStubRow('Women Helpline 181 Desk', stubs['helpline181']?['status'] ?? 'STANDBY', Icons.support_agent),
          const SizedBox(height: 8),
          _buildStubRow('TRAI DLT Emergency SMS', stubs['smsGateway']?['status'] ?? 'STANDBY', Icons.sms_outlined),
        ],
      ),
    );
  }

  Widget _buildStubRow(String name, String status, IconData icon) {
    Color color = AppTheme.textMuted;
    if (status.contains('DISPATCH') || status.contains('ARMED') || status.contains('ACTIVE')) {
      color = AppTheme.statusEmerald;
    } else if (status.contains('STANDBY')) {
      color = AppTheme.statusCyan;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: color.withOpacity(0.4)),
            ),
            child: Text(
              status,
              style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: color),
            ),
          ),
        ],
      ),
    );
  }
}
