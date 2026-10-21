import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/sangini_controller.dart';
import 'theme/app_theme.dart';
import 'views/calculator_view.dart';
import 'views/cascade_escalation_view.dart';
import 'views/fraud_shield_view.dart';
import 'views/incident_log_view.dart';
import 'views/jury_console_view.dart';
import 'views/peer_radar_view.dart';
import 'views/sos_dashboard_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.surface,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const SanginiApp());
}

class SanginiApp extends StatelessWidget {
  const SanginiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sangini AI - Universal Women\'s Safety & Peer Response Network',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainNavigationShell(),
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  void _navigateToTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final controller = SanginiController();

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        // If discreet calculator disguise is active, show calculator full screen!
        if (controller.isDiscreetCalculatorActive) {
          return CalculatorView(
            onExitDisguise: () => controller.setDiscreetCalculator(false),
          );
        }

        final pages = [
          SosDashboardView(
            onNavigateToCascade: () => _navigateToTab(2),
            onNavigateToRadar: () => _navigateToTab(1),
          ),
          const PeerRadarView(),
          const CascadeEscalationView(),
          const FraudShieldView(),
          const JuryConsoleView(),
        ];

        final incident = controller.incident;
        final isActive = incident.status == 'active' || incident.status == 'escalated';

        return Scaffold(
          appBar: _currentIndex == 0
              ? null
              : null, // Subviews have their own dedicated AppBar
          body: IndexedStack(
            index: _currentIndex,
            children: pages,
          ),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppTheme.border, width: 1)),
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: _navigateToTab,
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.shield),
                  activeIcon: const Icon(Icons.shield, color: AppTheme.primaryPink),
                  label: controller.tr('tabSosShield'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.radar),
                  activeIcon: const Icon(Icons.radar, color: AppTheme.statusCyan),
                  label: controller.tr('tabPeerRadar'),
                ),
                BottomNavigationBarItem(
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.timer_outlined),
                      if (isActive)
                        Positioned(
                          right: -4,
                          top: -3,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.primaryPink,
                            ),
                          ),
                        ),
                    ],
                  ),
                  activeIcon: const Icon(Icons.timer, color: AppTheme.statusAmber),
                  label: controller.tr('tabCascade'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.security),
                  activeIcon: const Icon(Icons.security, color: AppTheme.secondaryViolet),
                  label: controller.tr('tabAntiLuring'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.terminal),
                  activeIcon: const Icon(Icons.terminal, color: AppTheme.textPrimary),
                  label: controller.tr('tabJuryConsole'),
                ),
              ],
            ),
          ),
          floatingActionButton: _currentIndex == 0
              ? FloatingActionButton.extended(
                  backgroundColor: AppTheme.surfaceElevated,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppTheme.border),
                  ),
                  icon: const Icon(Icons.receipt_long, color: AppTheme.statusCyan, size: 18),
                  label: Text(
                    controller.tr('auditLog'),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const IncidentLogView()),
                    );
                  },
                )
              : null,
        );
      },
    );
  }
}

void showLanguageSelector(BuildContext context, SanginiController controller) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppTheme.surfaceCard,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      const languages = [
        {'code': 'en', 'name': 'English', 'native': 'English', 'flag': '🇬🇧'},
        {'code': 'hi', 'name': 'Hindi', 'native': 'हिंदी', 'flag': '🇮🇳'},
        {'code': 'mr', 'name': 'Marathi', 'native': 'मराठी', 'flag': '🚩'},
        {'code': 'kn', 'name': 'Kannada', 'native': 'ಕನ್ನಡ', 'flag': '🟡'},
      ];

      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.translate, color: AppTheme.statusCyan, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    controller.tr('selectLanguage'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppTheme.textMuted, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...languages.map((l) {
                final isSelected = controller.currentLanguage == l['code'];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryPink.withValues(alpha: 0.15) : AppTheme.surfaceElevated,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppTheme.primaryPink : AppTheme.border,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: ListTile(
                    leading: Text(l['flag']!, style: const TextStyle(fontSize: 22)),
                    title: Text(
                      l['native']!,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? AppTheme.primaryPink : AppTheme.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      l['name']!,
                      style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: AppTheme.primaryPink)
                        : null,
                    onTap: () {
                      controller.setLanguage(l['code']!);
                      Navigator.pop(ctx);
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      );
    },
  );
}
