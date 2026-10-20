// Web Audio API Synthesizer for Sangini AI
// Generates realistic sirens, telephone rings, and alert pulses with zero external audio assets.

class AudioManager {
  constructor() {
    this.ctx = null;
    this.isMuted = false;
    this.activeSiren = null;
    this.activeRingtone = null;
  }

  init() {
    if (!this.ctx) {
      const AudioContext = window.AudioContext || window.webkitAudioContext;
      this.ctx = new AudioContext();
    }
    if (this.ctx.state === 'suspended') {
      this.ctx.resume();
    }
  }

  toggleMute() {
    this.isMuted = !this.isMuted;
    if (this.isMuted) {
      this.stopSiren();
      this.stopRingtone();
    }
    return this.isMuted;
  }

  playClick() {
    if (this.isMuted) return;
    this.init();
    try {
      const osc = this.ctx.createOscillator();
      const gain = this.ctx.createGain();
      osc.type = 'sine';
      osc.frequency.setValueAtTime(600, this.ctx.currentTime);
      osc.frequency.exponentialRampToValueAtTime(1200, this.ctx.currentTime + 0.04);
      gain.gain.setValueAtTime(0.15, this.ctx.currentTime);
      gain.gain.exponentialRampToValueAtTime(0.01, this.ctx.currentTime + 0.04);
      osc.connect(gain);
      gain.connect(this.ctx.destination);
      osc.start();
      osc.stop(this.ctx.currentTime + 0.05);
    } catch (e) {
      console.warn("Audio click error", e);
    }
  }

  playAlertChirp() {
    if (this.isMuted) return;
    this.init();
    try {
      const now = this.ctx.currentTime;
      const osc = this.ctx.createOscillator();
      const gain = this.ctx.createGain();
      osc.type = 'triangle';
      osc.frequency.setValueAtTime(880, now);
      osc.frequency.setValueAtTime(1174.66, now + 0.08); // D6
      osc.frequency.setValueAtTime(1760, now + 0.16); // A6
      gain.gain.setValueAtTime(0.25, now);
      gain.gain.exponentialRampToValueAtTime(0.001, now + 0.35);
      osc.connect(gain);
      gain.connect(this.ctx.destination);
      osc.start(now);
      osc.stop(now + 0.36);
    } catch (e) {
      console.warn("Audio chirp error", e);
    }
  }

  startSiren() {
    if (this.isMuted) return;
    this.init();
    this.stopSiren();

    try {
      const osc = this.ctx.createOscillator();
      const gain = this.ctx.createGain();
      osc.type = 'sawtooth';
      
      const now = this.ctx.currentTime;
      // Siren frequency sweep between 550Hz and 1050Hz
      osc.frequency.setValueAtTime(600, now);

      // Create an LFO to modulate siren pitch
      const lfo = this.ctx.createOscillator();
      const lfoGain = this.ctx.createGain();
      lfo.frequency.value = 1.2; // 1.2 Hz cycle
      lfoGain.gain.value = 350; // swing +-350Hz

      lfo.connect(osc.frequency);
      osc.connect(gain);
      gain.connect(this.ctx.destination);
      gain.gain.setValueAtTime(0.28, now);

      osc.start();
      lfo.start();

      this.activeSiren = { osc, lfo, gain };
    } catch (e) {
      console.warn("Siren start error", e);
    }
  }

  stopSiren() {
    if (this.activeSiren) {
      try {
        this.activeSiren.gain.gain.exponentialRampToValueAtTime(0.001, this.ctx.currentTime + 0.1);
        setTimeout(() => {
          if (this.activeSiren) {
            this.activeSiren.osc.stop();
            this.activeSiren.lfo.stop();
            this.activeSiren = null;
          }
        }, 120);
      } catch (e) {
        this.activeSiren = null;
      }
    }
  }

  startRingtone() {
    if (this.isMuted) return;
    this.init();
    this.stopRingtone();

    // Standard phone ring pattern: 2s on, 4s off
    const playRingBurst = () => {
      if (!this.activeRingtone || this.isMuted) return;
      try {
        const now = this.ctx.currentTime;
        const osc1 = this.ctx.createOscillator();
        const osc2 = this.ctx.createOscillator();
        const gain = this.ctx.createGain();

        // Dual Tone Multi-Frequency European/Indian bell (400Hz + 450Hz)
        osc1.frequency.value = 400;
        osc2.frequency.value = 450;
        osc1.type = 'sine';
        osc2.type = 'sine';

        osc1.connect(gain);
        osc2.connect(gain);
        gain.connect(this.ctx.destination);

        gain.gain.setValueAtTime(0.2, now);
        gain.gain.setValueAtTime(0.2, now + 1.8);
        gain.gain.exponentialRampToValueAtTime(0.001, now + 1.95);

        osc1.start(now);
        osc2.start(now);
        osc1.stop(now + 2.0);
        osc2.stop(now + 2.0);
      } catch (e) {
        console.warn("Ringtone error", e);
      }
    };

    playRingBurst();
    const interval = setInterval(playRingBurst, 3500);
    this.activeRingtone = { interval };
  }

  stopRingtone() {
    if (this.activeRingtone) {
      clearInterval(this.activeRingtone.interval);
      this.activeRingtone = null;
    }
  }
}

window.soundEngine = new AudioManager();
