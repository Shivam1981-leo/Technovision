import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/sangini_controller.dart';
import '../theme/app_theme.dart';
import '../main.dart';

class FraudShieldView extends StatefulWidget {
  const FraudShieldView({super.key});

  @override
  State<FraudShieldView> createState() => _FraudShieldViewState();
}

class _FraudShieldViewState extends State<FraudShieldView> {
  int _accountAge = 45;
  String _verificationLevel = 'aadhaar_biometric';
  bool _rooted = false;
  bool _vpnActive = false;
  bool _isIsolated = false;
  bool _isEvaluating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runEvaluation();
    });
  }

  void _runEvaluation() async {
    setState(() => _isEvaluating = true);
    final controller = SanginiController();
    await controller.evaluateDefaultFraudScore(
      accountAge: _accountAge,
      verificationLevel: _verificationLevel,
      rooted: _rooted,
      vpnActive: _vpnActive,
      isIsolated: _isIsolated,
    );
    if (mounted) setState(() => _isEvaluating = false);
  }

  @override
  Widget build(BuildContext context) {
    final controller = SanginiController();

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final assessment = controller.fraudAssessment;
        final score = assessment?.fraudScore ?? 0.05;
        final recommendation = assessment?.recommendation ?? 'IMMEDIATE_BROADCAST';
        final confidence = ((assessment?.confidence ?? 0.92) * 100).toInt();

        Color scoreColor = AppTheme.statusEmerald;
        if (score >= 0.70) {
          scoreColor = AppTheme.statusRose;
        } else if (score >= 0.50) {
          scoreColor = AppTheme.statusAmber;
        } else if (score >= 0.20) {
          scoreColor = AppTheme.statusCyan;
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(controller.tr('tabAntiLuring')),
            actions: [
              IconButton(
                tooltip: controller.tr('selectLanguage'),
                icon: const Icon(Icons.language, color: AppTheme.statusCyan),
                onPressed: () => showLanguageSelector(context, controller),
              ),
              IconButton(
                tooltip: 'Re-evaluate Risk',
                icon: const Icon(Icons.refresh, color: AppTheme.textSecondary),
                onPressed: _runEvaluation,
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Score Gauge Card
                _buildScoreGauge(score, scoreColor, recommendation, confidence),

                const SizedBox(height: 18),

                // Anti-Luring Trap Alert (if triggered)
                if (assessment?.antiLuringRequired == true) ...[
                  _buildAntiLuringTrapWarning(),
                  const SizedBox(height: 16),
                ],

                // Interactive Risk Signal Modifiers
                _buildSignalModifiersCard(),

                const SizedBox(height: 20),

                // Evaluation Rationale & Verification Tiers
                _buildTrustTiersCard(),

                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildScoreGauge(double score, Color color, String rec, int conf) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ML Distress Legitimacy Index',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'CONFIDENCE: $conf%',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                score.toStringAsFixed(2),
                style: TextStyle(
                  fontSize: 54,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                '/ 1.00',
                style: TextStyle(fontSize: 18, color: AppTheme.textMuted, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.18),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.4)),
            ),
            child: Text(
              rec.replaceAll('_', ' '),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: color,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            score < 0.20
                ? 'Legitimate Alert: Immediate Tier 1 broadcast to nearby female peers.'
                : (score < 0.50
                    ? 'Moderate Risk: Routed to high-trust verified responders only.'
                    : 'Suspicious / Potential Trap: Automated voice verification or hold applied.'),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11.5, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildAntiLuringTrapWarning() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.statusRose.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.statusRose),
      ),
      child: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: AppTheme.statusRose, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CRITICAL: AMBUSH / LURING PROTOCOL ARMED',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppTheme.statusRose),
                ),
                SizedBox(height: 2),
                Text(
                  'Isolated geographical zone paired with a fresh unverified account triggers anti-luring safeguards to protect female peers from criminal ambushes.',
                  style: TextStyle(fontSize: 10.5, color: AppTheme.textPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignalModifiersCard() {
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
              Icon(Icons.tune, size: 18, color: AppTheme.secondaryViolet),
              SizedBox(width: 8),
              Text(
                'Live Signal Simulator (Jury Test Bench)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Account Age Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Account Age', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              Text('$_accountAge days', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            ],
          ),
          Slider(
            value: _accountAge.toDouble(),
            min: 1,
            max: 180,
            divisions: 18,
            activeColor: AppTheme.secondaryViolet,
            onChanged: (val) {
              setState(() => _accountAge = val.toInt());
              _runEvaluation();
            },
          ),

          const SizedBox(height: 6),

          // Verification Level
          const Text('Verification Tier', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: _verificationLevel,
            decoration: const InputDecoration(
              isDense: true,
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'aadhaar_biometric', child: Text('Aadhaar Biometric (Highest Trust)')),
              DropdownMenuItem(value: 'video_selfie', child: Text('Video Liveness / DigiLocker')),
              DropdownMenuItem(value: 'unverified', child: Text('Unverified / Anonymous')),
            ],
            onChanged: (val) {
              if (val != null) {
                setState(() => _verificationLevel = val);
                _runEvaluation();
              }
            },
          ),

          const SizedBox(height: 12),

          // Rooted Device Switch
          _buildSwitchRow(
            title: 'Rooted / Jailbroken Device',
            subtitle: 'High risk spoofing indicator',
            value: _rooted,
            activeColor: AppTheme.statusRose,
            onChanged: (val) {
              setState(() => _rooted = val);
              _runEvaluation();
            },
          ),
          const SizedBox(height: 10),

          // VPN Active Switch
          _buildSwitchRow(
            title: 'Active VPN / Proxy Route',
            subtitle: 'Masks IP / carrier cell telemetry',
            value: _vpnActive,
            activeColor: AppTheme.statusAmber,
            onChanged: (val) {
              setState(() => _vpnActive = val);
              _runEvaluation();
            },
          ),
          const SizedBox(height: 10),

          // Isolated Danger Zone Switch
          _buildSwitchRow(
            title: 'Isolated / Dead-End Sector',
            subtitle: 'Ambush / anti-luring trigger factor',
            value: _isIsolated,
            activeColor: AppTheme.primaryPink,
            onChanged: (val) {
              setState(() => _isIsolated = val);
              _runEvaluation();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchRow({
    required String title,
    required String subtitle,
    required bool value,
    required Color activeColor,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
              const SizedBox(height: 1),
              Text(subtitle, style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
            ],
          ),
        ),
        Switch(
          value: value,
          activeColor: activeColor,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildTrustTiersCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.verified_outlined, size: 18, color: AppTheme.statusEmerald),
              SizedBox(width: 8),
              Text(
                'Trust Architecture',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            '• Aadhaar Biometric + Mobile OTP grants verified green status.\n'
            '• Peer responders are never routed into isolated dead-ends if the sender is unverified.\n'
            '• Cryptographic telemetry hashing prevents spoofing or false beacon replay.',
            style: TextStyle(fontSize: 11.5, color: AppTheme.textSecondary, height: 1.4),
          ),
        ],
      ),
    );
  }
}
