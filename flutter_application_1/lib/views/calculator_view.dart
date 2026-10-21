import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/sangini_controller.dart';
import '../theme/app_theme.dart';

class CalculatorView extends StatefulWidget {
  final VoidCallback? onExitDisguise;

  const CalculatorView({super.key, this.onExitDisguise});

  @override
  State<CalculatorView> createState() => _CalculatorViewState();
}

class _CalculatorViewState extends State<CalculatorView> {
  String _display = '0';
  String _history = '';
  double _num1 = 0;
  String _operator = '';
  bool _shouldResetDisplay = false;
  String _inputSequence = '';
  bool _secretTriggered = false;

  void _onDigitPress(String digit) {
    _inputSequence += digit;
    setState(() {
      if (_display == '0' || _shouldResetDisplay) {
        _display = digit;
        _shouldResetDisplay = false;
      } else {
        _display += digit;
      }
    });
  }

  void _onOperatorPress(String op) {
    _inputSequence += op;
    setState(() {
      _num1 = double.tryParse(_display) ?? 0;
      _operator = op;
      _history = '$_display $op';
      _shouldResetDisplay = true;
    });
  }

  void _onClear() {
    _inputSequence = '';
    setState(() {
      _display = '0';
      _history = '';
      _num1 = 0;
      _operator = '';
      _shouldResetDisplay = false;
    });
  }

  void _onEquals() {
    // Secret Emergency Trigger Check: "911", "999", or "112"
    if (_display == '911' ||
        _display == '999' ||
        _display == '112' ||
        _inputSequence.contains('911') ||
        _inputSequence.contains('999')) {
      _triggerSecretDistress();
      return;
    }

    if (_operator.isEmpty) return;

    final num2 = double.tryParse(_display) ?? 0;
    double result = 0;

    switch (_operator) {
      case '+':
        result = _num1 + num2;
        break;
      case '-':
        result = _num1 - num2;
        break;
      case '×':
        result = _num1 * num2;
        break;
      case '÷':
        result = num2 != 0 ? _num1 / num2 : 0;
        break;
    }

    setState(() {
      _history = '$_num1 $_operator $num2 =';
      _display = (result % 1 == 0) ? result.toInt().toString() : result.toStringAsFixed(2);
      _operator = '';
      _shouldResetDisplay = true;
    });
  }

  void _triggerSecretDistress() {
    HapticFeedback.heavyImpact();
    final controller = SanginiController();
    controller.triggerEmergencySOS(context: 'street', silent: 1);

    setState(() {
      _secretTriggered = true;
      // Pretend to be a normal calculation output so attacker suspects nothing
      _display = '911.00';
      _history = 'Secret Distress Beacon Sent!';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.statusRose,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        content: const Row(
          children: [
            Icon(Icons.shield, color: Colors.white),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Discreet Distress Beacon Activated via PIN "911="!',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = SanginiController();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Calculator',
          style: TextStyle(fontSize: 16, color: Colors.white70, fontWeight: FontWeight.w500),
        ),
        actions: [
          IconButton(
            tooltip: 'Secret PIN: Type 911 then press =',
            icon: const Icon(Icons.help_outline, color: Colors.white30, size: 20),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Stealth Mode: Type "911=" or "999=" to silently trigger SOS.'),
                  duration: Duration(seconds: 3),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Exit Calculator Disguise',
            icon: const Icon(Icons.close, color: Colors.white70),
            onPressed: widget.onExitDisguise ?? () => controller.toggleCalculatorDisguise(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Secret distress indicator badge
            if (_secretTriggered)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.statusRose.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.statusRose),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock, size: 14, color: AppTheme.statusRose),
                    SizedBox(width: 6),
                    Text(
                      'DISCREET BEACON SENT • SANGINI MESH ARMED',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.statusRose),
                    ),
                  ],
                ),
              ),

            // Calculator Screen Display
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(24),
                alignment: Alignment.bottomRight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _history,
                      style: const TextStyle(fontSize: 18, color: Colors.white38),
                    ),
                    const SizedBox(height: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        _display,
                        style: const TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.w300,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Calculator Keypad Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildCalcButton('C', color: Colors.grey.shade800, textColor: Colors.white, onTap: _onClear),
                      _buildCalcButton('±', color: Colors.grey.shade800, textColor: Colors.white, onTap: () {}),
                      _buildCalcButton('%', color: Colors.grey.shade800, textColor: Colors.white, onTap: () {}),
                      _buildCalcButton('÷', color: const Color(0xFFF59E0B), textColor: Colors.white, onTap: () => _onOperatorPress('÷')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildCalcButton('7', onTap: () => _onDigitPress('7')),
                      _buildCalcButton('8', onTap: () => _onDigitPress('8')),
                      _buildCalcButton('9', onTap: () => _onDigitPress('9')),
                      _buildCalcButton('×', color: const Color(0xFFF59E0B), textColor: Colors.white, onTap: () => _onOperatorPress('×')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildCalcButton('4', onTap: () => _onDigitPress('4')),
                      _buildCalcButton('5', onTap: () => _onDigitPress('5')),
                      _buildCalcButton('6', onTap: () => _onDigitPress('6')),
                      _buildCalcButton('-', color: const Color(0xFFF59E0B), textColor: Colors.white, onTap: () => _onOperatorPress('-')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildCalcButton('1', onTap: () => _onDigitPress('1')),
                      _buildCalcButton('2', onTap: () => _onDigitPress('2')),
                      _buildCalcButton('3', onTap: () => _onDigitPress('3')),
                      _buildCalcButton('+', color: const Color(0xFFF59E0B), textColor: Colors.white, onTap: () => _onOperatorPress('+')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildCalcButton('0', flex: 2, onTap: () => _onDigitPress('0')),
                      _buildCalcButton('.', onTap: () => _onDigitPress('.')),
                      _buildCalcButton(
                        '=',
                        color: const Color(0xFFE11D48),
                        textColor: Colors.white,
                        onTap: _onEquals,
                        onLongPress: _triggerSecretDistress,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalcButton(
    String label, {
    Color? color,
    Color? textColor,
    int flex = 1,
    required VoidCallback onTap,
    VoidCallback? onLongPress,
  }) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: AspectRatio(
          aspectRatio: flex == 2 ? 2.1 : 1.0,
          child: Material(
            color: color ?? Colors.grey.shade900,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(36)),
            child: InkWell(
              onTap: onTap,
              onLongPress: onLongPress,
              borderRadius: BorderRadius.circular(36),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w500,
                    color: textColor ?? Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
