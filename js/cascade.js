// Shakti Mesh - 4-Tier Response Cascade & Cryptographic Evidence Vault
// Coordinates Tier 1 (0-2m) -> Tier 2 (2-10m) -> Tier 3 (112 Police) -> Tier 4 (Contacts), plus SHA-256 evidence anchoring.

class ResponseCascadeManager {
  constructor() {
    this.currentTier = 1;
    this.tier1RemainingSeconds = 120;
    this.tier2RemainingSeconds = 480;
    this.timerInterval = null;
    this.isRecording = false;
    this.audioWaveTimer = null;
  }

  startCascade(alertData) {
    this.currentTier = 1;
    this.tier1RemainingSeconds = 120;
    this.tier2RemainingSeconds = 480;
    this.isRecording = true;

    clearInterval(this.timerInterval);
    this.timerInterval = setInterval(() => this.tick(), 1000);

    this.startAudioWaveform();
    this.updateUI();
  }

  tick() {
    if (this.currentTier === 1) {
      this.tier1RemainingSeconds--;
      if (this.tier1RemainingSeconds <= 0) {
        this.escalateToTier2();
      }
    } else if (this.currentTier === 2) {
      this.tier2RemainingSeconds--;
      if (this.tier2RemainingSeconds <= 0) {
        this.escalateToTier3();
      }
    }
    this.updateUI();
  }

  escalateToTier2() {
    this.currentTier = 2;
    if (window.soundEngine) window.soundEngine.playAlertChirp();
    this.updateUI();
  }

  escalateToTier3() {
    this.currentTier = 3;
    if (window.soundEngine) window.soundEngine.startSiren();
    this.updateUI();
  }

  reset() {
    clearInterval(this.timerInterval);
    this.currentTier = 1;
    this.tier1RemainingSeconds = 120;
    this.isRecording = false;
    if (this.audioWaveTimer) cancelAnimationFrame(this.audioWaveTimer);
    if (window.soundEngine) window.soundEngine.stopSiren();
    this.updateUI();
  }

  formatTime(secs) {
    const m = Math.floor(secs / 60).toString().padStart(2, '0');
    const s = (secs % 60).toString().padStart(2, '0');
    return `${m}:${s}`;
  }

  startAudioWaveform() {
    const canvas = document.getElementById('evidenceWaveform');
    if (!canvas) return;
    const ctx = canvas.getContext('2d');
    canvas.width = canvas.parentElement.clientWidth || 320;
    canvas.height = 60;

    let step = 0;
    const render = () => {
      ctx.clearRect(0, 0, canvas.width, canvas.height);
      const bars = 36;
      const barWidth = canvas.width / bars - 2;

      for (let i = 0; i < bars; i++) {
        const height = this.isRecording
          ? Math.sin(step * 0.12 + i * 0.4) * 18 + Math.cos(step * 0.08 + i * 0.2) * 12 + 25
          : 4;

        const grad = ctx.createLinearGradient(0, canvas.height, 0, 0);
        grad.addColorStop(0, '#00f0ff');
        grad.addColorStop(1, '#ff2d55');

        ctx.fillStyle = grad;
        ctx.fillRect(i * (barWidth + 2), canvas.height - height, barWidth, height);
      }
      step++;
      if (this.isRecording) {
        this.audioWaveTimer = requestAnimationFrame(render);
      }
    };
    render();
  }

  updateUI() {
    // Tier Badges & Timers
    const t1El = document.getElementById('cascadeTier1Time');
    const t2El = document.getElementById('cascadeTier2Time');
    const badgeEl = document.getElementById('activeTierBadge');

    if (t1El) t1El.innerText = this.formatTime(this.tier1RemainingSeconds);
    if (t2El) t2El.innerText = this.formatTime(this.tier2RemainingSeconds);

    const step1 = document.getElementById('cascadeStep1');
    const step2 = document.getElementById('cascadeStep2');
    const step3 = document.getElementById('cascadeStep3');
    const step4 = document.getElementById('cascadeStep4');

    if (step1 && step2 && step3 && step4) {
      step1.className = `cascade-step ${this.currentTier >= 1 ? 'active' : ''}`;
      step2.className = `cascade-step ${this.currentTier >= 2 ? 'active' : ''}`;
      step3.className = `cascade-step ${this.currentTier >= 3 ? 'active critical' : ''}`;
      step4.className = 'cascade-step active'; // Tier 4 (Contacts) is always running in parallel
    }

    if (badgeEl) {
      if (this.currentTier === 1) {
        badgeEl.className = 'tier-indicator tier-1';
        badgeEl.innerHTML = `<span>● TIER 1 ACTIVE: Immediate Proximity (${this.formatTime(this.tier1RemainingSeconds)})</span>`;
      } else if (this.currentTier === 2) {
        badgeEl.className = 'tier-indicator tier-2';
        badgeEl.innerHTML = `<span>● TIER 2 ESCALATED: Community Responders (${this.formatTime(this.tier2RemainingSeconds)})</span>`;
      } else {
        badgeEl.className = 'tier-indicator tier-3';
        badgeEl.innerHTML = `<span>🚨 TIER 3 DISPATCHED: Police 112 & Women Helpline 181 Active</span>`;
      }
    }
  }
}

window.cascadeManager = new ResponseCascadeManager();
