import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/sangini_controller.dart';
import '../theme/app_theme.dart';
import '../main.dart';

class JuryConsoleView extends StatefulWidget {
  const JuryConsoleView({super.key});

  @override
  State<JuryConsoleView> createState() => _JuryConsoleViewState();
}

class _JuryConsoleViewState extends State<JuryConsoleView> {
  final TextEditingController _cmdCtrl = TextEditingController(text: 'SG|street|18.5204|73.8567|1');
  final TextEditingController _serverUrlCtrl = TextEditingController(text: ApiService().baseUrl);
  String _outputLog = 'Ready. Execute a one-line jury command or tap a preset button.';
  bool _isLoading = false;

  @override
  void dispose() {
    _cmdCtrl.dispose();
    _serverUrlCtrl.dispose();
    super.dispose();
  }

  void _runCommand(String command) async {
    setState(() {
      _isLoading = true;
      _outputLog = 'Executing: $command...\n$_outputLog';
    });

    final controller = SanginiController();
    final res = await controller.executeConsoleCommand(command);

    setState(() {
      _isLoading = false;
      _outputLog = '>>> [$command]\n${res['message'] ?? res.toString()}\n\n$_outputLog';
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = SanginiController();

    return Scaffold(
      appBar: AppBar(
        title: Text(controller.tr('tabJuryConsole')),
        actions: [
          IconButton(
            tooltip: controller.tr('selectLanguage'),
            icon: const Icon(Icons.language, color: AppTheme.statusCyan),
            onPressed: () => showLanguageSelector(context, controller),
          ),
          IconButton(
            tooltip: 'Clear Output',
            icon: const Icon(Icons.clear_all, color: AppTheme.textSecondary),
            onPressed: () {
              setState(() => _outputLog = 'Console output cleared.');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Backend URL Config Card
            _buildServerConfigCard(),

            const SizedBox(height: 14),

            // One-Line Command Input Box
            _buildCommandInputBox(),

            const SizedBox(height: 14),

            // 1-Tap Quick Presets for Hackathon Judges
            _buildPresetsCard(),

            const SizedBox(height: 16),

            // Terminal Output Console
            _buildTerminalOutput(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildServerConfigCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.dns_outlined, size: 18, color: AppTheme.statusCyan),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _serverUrlCtrl,
              decoration: const InputDecoration(
                isDense: true,
                labelText: 'Backend REST API URL',
                hintText: 'http://localhost:3000',
                border: InputBorder.none,
              ),
              style: const TextStyle(fontSize: 12),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              backgroundColor: AppTheme.surfaceElevated,
            ),
            onPressed: () {
              ApiService().updateBaseUrl(_serverUrlCtrl.text.trim());
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Target URL set to: ${_serverUrlCtrl.text.trim()}')),
              );
            },
            child: const Text('Save', style: TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }

  Widget _buildCommandInputBox() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.secondaryViolet.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'One-Line Jury Command Input',
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _cmdCtrl,
                  decoration: const InputDecoration(
                    hintText: 'SG|street|18.5204|73.8567|1',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : () => _runCommand(_cmdCtrl.text.trim()),
                icon: _isLoading
                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.play_arrow, size: 16),
                label: const Text('Run'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.secondaryViolet,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPresetsCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '1-Tap Judge Evaluation Presets',
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildPresetChip(
                label: 'SG (Street 200m Mesh)',
                cmd: 'SG|street|18.5204|73.8567|1',
                color: AppTheme.statusCyan,
              ),
              _buildPresetChip(
                label: 'SG (Home Discreet 181)',
                cmd: 'SG|home|18.5204|73.8567|1',
                color: AppTheme.secondaryViolet,
              ),
              _buildPresetChip(
                label: 'OK (Accept Code BLUE)',
                cmd: 'OK|R12|BLUE',
                color: AppTheme.statusEmerald,
              ),
              _buildPresetChip(
                label: 'RESET System',
                cmd: 'RESET',
                color: AppTheme.statusRose,
              ),
              _buildPresetChip(
                label: 'STATUS Query',
                cmd: 'STATUS',
                color: AppTheme.statusAmber,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPresetChip({
    required String label,
    required String cmd,
    required Color color,
  }) {
    return ActionChip(
      backgroundColor: color.withOpacity(0.14),
      side: BorderSide(color: color.withOpacity(0.5)),
      avatar: Icon(Icons.flash_on, size: 14, color: color),
      label: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
      onPressed: () {
        _cmdCtrl.text = cmd;
        _runCommand(cmd);
      },
    );
  }

  Widget _buildTerminalOutput() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.terminal, size: 16, color: Colors.white70),
              SizedBox(width: 6),
              Text(
                'LIVE CONSOLE OUTPUT',
                style: TextStyle(
                  fontSize: 11,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w700,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 180,
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF0D1117),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SingleChildScrollView(
              child: Text(
                _outputLog,
                style: const TextStyle(
                  fontSize: 11,
                  fontFamily: 'monospace',
                  color: Color(0xFF58A6FF),
                  height: 1.35,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
