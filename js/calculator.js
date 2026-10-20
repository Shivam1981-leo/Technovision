// Shakti Mesh - Covert Calculator Disguise
// Functional calculator with covert SOS trigger (911= or 112=) for domestic violence & home safety situations.

class DisguiseCalculator {
  constructor() {
    this.currentInput = '0';
    this.previousInput = '';
    this.operation = null;
    this.resetNext = false;
    this.secretBuffer = '';
    this.isArmed = false;
  }

  handleButton(val) {
    if (window.soundEngine) window.soundEngine.playClick();

    if (val >= '0' && val <= '9') {
      this.appendNumber(val);
    } else if (val === '.') {
      this.appendDot();
    } else if (val === 'AC') {
      this.clear();
    } else if (val === '+/-') {
      this.toggleSign();
    } else if (val === '%') {
      this.percent();
    } else if (['+', '-', '×', '÷'].includes(val)) {
      this.setOperation(val);
    } else if (val === '=') {
      this.calculate();
    }

    this.updateDisplay();
  }

  appendNumber(number) {
    if (this.currentInput === '0' || this.resetNext) {
      this.currentInput = number;
      this.resetNext = false;
    } else {
      this.currentInput += number;
    }
    this.secretBuffer += number;
  }

  appendDot() {
    if (this.resetNext) {
      this.currentInput = '0.';
      this.resetNext = false;
      return;
    }
    if (!this.currentInput.includes('.')) {
      this.currentInput += '.';
    }
  }

  clear() {
    this.currentInput = '0';
    this.previousInput = '';
    this.operation = null;
    this.secretBuffer = '';
  }

  toggleSign() {
    this.currentInput = (parseFloat(this.currentInput) * -1).toString();
  }

  percent() {
    this.currentInput = (parseFloat(this.currentInput) / 100).toString();
  }

  setOperation(op) {
    if (this.operation !== null) this.calculate();
    this.previousInput = this.currentInput;
    this.operation = op;
    this.resetNext = true;
    this.secretBuffer += op;
  }

  calculate() {
    // Check for covert SOS trigger: 911, 112, or 999
    if (this.currentInput === '911' || this.currentInput === '112' || this.secretBuffer.includes('911') || this.secretBuffer.includes('112')) {
      this.triggerCovertSOS();
      this.currentInput = '0';
      this.previousInput = '';
      this.operation = null;
      this.secretBuffer = '';
      return;
    }

    let computation;
    const prev = parseFloat(this.previousInput);
    const current = parseFloat(this.currentInput);
    if (isNaN(prev) || isNaN(current)) return;

    switch (this.operation) {
      case '+':
        computation = prev + current;
        break;
      case '-':
        computation = prev - current;
        break;
      case '×':
        computation = prev * current;
        break;
      case '÷':
        computation = current !== 0 ? prev / current : 'Error';
        break;
      default:
        return;
    }

    this.currentInput = computation.toString().slice(0, 10);
    this.operation = null;
    this.resetNext = true;
  }

  triggerCovertSOS() {
    // Subtle visual indicator (dot pulses green)
    const dotIndicator = document.getElementById('calcCovertDot');
    if (dotIndicator) {
      dotIndicator.classList.add('pulse-active');
      setTimeout(() => dotIndicator.classList.remove('pulse-active'), 3000);
    }

    // Trigger global covert alert in app
    if (window.shaktiApp) {
      window.shaktiApp.handleCovertTrigger({
        source: 'calculator_disguise',
        mode: 'domestic_violence_silent',
        privacyLevel: 'maximum_covert',
        priorityResponders: ['dv_counselor', 'local_ngo', 'trusted_contact']
      });
    }
  }

  updateDisplay() {
    const displayEl = document.getElementById('calcDisplay');
    if (displayEl) {
      displayEl.innerText = this.currentInput;
    }
  }
}

window.disguiseCalculator = new DisguiseCalculator();
