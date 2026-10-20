// Sangini AI - Main Application Controller
// Orchestrates navigation, crisis modes, responder matching, fraud simulator, and covert disguises.

class SanginiApp {
  constructor() {
    this.activeTab = 'victim-app';
    this.isSOSActive = false;
    this.activeAlert = null;
    this.tapPowerCount = 0;
    this.tapPowerTimer = null;
    this.watchdogTimer = null;
    this.watchdogRemaining = 90; // seconds

    this.init();
  }

  init() {
    this.bindNavigation();
    this.bindVictimTriggers();
    this.bindResponderActions();
    this.bindFraudControls();
    this.bindDisguiseModes();
    this.bindPitchDeck();

    // Initialize map after DOM ready
    setTimeout(() => {
      window.tacticalMap = new window.MeshTacticalMap('tacticalMeshCanvas');
      this.runFraudEvaluation(); // initial run
    }, 200);

    // Mute toggle
    const muteBtn = document.getElementById('audioMuteBtn');
    if (muteBtn) {
      muteBtn.addEventListener('click', () => {
        const isMuted = window.soundEngine.toggleMute();
        muteBtn.innerHTML = isMuted ? '🔇 Audio Muted' : '🔊 Audio Active';
        muteBtn.classList.toggle('muted', isMuted);
      });
    }
  }

  bindNavigation() {
    const tabs = document.querySelectorAll('.nav-tab-btn');
    tabs.forEach(btn => {
      btn.addEventListener('click', () => {
        tabs.forEach(t => t.classList.remove('active'));
        btn.classList.add('active');
        const targetView = btn.dataset.view;
        this.switchView(targetView);
      });
    });
  }

  switchView(viewId) {
    this.activeTab = viewId;
    document.querySelectorAll('.view-panel').forEach(panel => {
      panel.classList.remove('active');
    });

    const activePanel = document.getElementById(viewId);
    if (activePanel) {
      activePanel.classList.add('active');
    }

    if (viewId === 'responder-map' && window.tacticalMap) {
      setTimeout(() => window.tacticalMap.resize(), 100);
    }
  }

  bindVictimTriggers() {
    // 1. Big SOS Button
    const mainSosBtn = document.getElementById('mainSosPulseBtn');
    if (mainSosBtn) {
      mainSosBtn.addEventListener('click', () => {
        this.triggerEmergencySOS({
          type: 'street_harassment',
          triggerMethod: 'main_pulse_button',
          context: 'street'
        });
      });
    }

    // 2. Shake 3x Simulator
    const shakeBtn = document.getElementById('simulateShakeBtn');
    if (shakeBtn) {
      shakeBtn.addEventListener('click', () => {
        shakeBtn.classList.add('shaking-active');
        setTimeout(() => shakeBtn.classList.remove('shaking-active'), 800);
        this.triggerEmergencySOS({
          type: 'street_harassment',
          triggerMethod: 'shake_pattern_3x',
          context: 'street_movement'
        });
      });
    }

    // 3. Power Button 5-Tap Simulator
    const powerBtn = document.getElementById('simulatePowerTapBtn');
    if (powerBtn) {
      powerBtn.addEventListener('click', () => {
        this.tapPowerCount++;
        powerBtn.innerText = `⚡ Tapped ${this.tapPowerCount}/5`;
        clearTimeout(this.tapPowerTimer);
        this.tapPowerTimer = setTimeout(() => {
          this.tapPowerCount = 0;
          powerBtn.innerText = '⚡ Tap Power (5x)';
        }, 2000);

        if (this.tapPowerCount >= 5) {
          this.tapPowerCount = 0;
          powerBtn.innerText = '⚡ TRIGGERED!';
          this.triggerEmergencySOS({
            type: 'street_harassment',
            triggerMethod: 'power_button_5x',
            context: 'rapid_panic'
          });
        }
      });
    }

    // 4. Voice Trigger Simulator
    const voiceBtn = document.getElementById('simulateVoiceSosBtn');
    if (voiceBtn) {
      voiceBtn.addEventListener('click', () => {
        voiceBtn.innerHTML = '🎙️ <em>Listening: "Hey Safety, Emergency"...</em>';
        setTimeout(() => {
          voiceBtn.innerHTML = '🎙️ "Hey Safety, Emergency" (Detected)';
          this.triggerEmergencySOS({
            type: 'street_harassment',
            triggerMethod: 'voice_command_emergency',
            context: 'hands_free'
          });
          setTimeout(() => {
            voiceBtn.innerHTML = '🎙️ Voice SOS ("Hey Safety")';
          }, 2500);
        }, 1200);
      });
    }

    // 5. Strobe & Siren Mode
    const sirenBtn = document.getElementById('strobeSirenBtn');
    if (sirenBtn) {
      sirenBtn.addEventListener('click', () => {
        this.toggleStrobeSiren();
      });
    }

    // 6. Fake Call Mode
    const fakeCallBtn = document.getElementById('fakeCallModeBtn');
    if (fakeCallBtn) {
      fakeCallBtn.addEventListener('click', () => {
        this.launchFakeCall();
      });
    }

    // 7. Walk Watchdog
    const startWatchdogBtn = document.getElementById('startWatchdogBtn');
    if (startWatchdogBtn) {
      startWatchdogBtn.addEventListener('click', () => {
        this.startWalkWatchdog();
      });
    }

    // Cancel SOS
    const cancelSosBtn = document.getElementById('cancelSosBtn');
    if (cancelSosBtn) {
      cancelSosBtn.addEventListener('click', () => {
        this.cancelSOS();
      });
    }
  }

  triggerEmergencySOS(details) {
    if (window.soundEngine) window.soundEngine.playAlertChirp();

    this.isSOSActive = true;
    this.activeAlert = {
      id: `ALT-${Math.floor(1000 + Math.random() * 9000)}`,
      timestamp: new Date().toLocaleTimeString(),
      status: 'active',
      ...details
    };

    // Update Victim UI banner
    const statusBanner = document.getElementById('victimStatusBanner');
    if (statusBanner) {
      statusBanner.className = 'status-banner active-emergency';
      statusBanner.innerHTML = `
        <div class="banner-pulse"></div>
        <div>
          <strong>🚨 SOS TRANSMITTED (Mesh Tier 1 Active)</strong>
          <p>Silent encrypted alert sent to 4 verified women within 200m. Cloud recording live.</p>
        </div>
      `;
    }

    const cancelBtn = document.getElementById('cancelSosBtn');
    if (cancelBtn) cancelBtn.style.display = 'inline-flex';

    // Start 4-tier Cascade
    if (window.cascadeManager) {
      window.cascadeManager.startCascade(this.activeAlert);
    }

    // Notify Responder Map
    this.updateResponderAlertCard(this.activeAlert);

    // Show floating toast
    this.showToast("🚨 Alert Broadcast: Verified female responders in 200m notified!");
  }

  handleCovertTrigger(details) {
    this.triggerEmergencySOS({
      type: 'domestic_violence_covert',
      triggerMethod: details.source,
      context: 'residential_covert',
      privacyLevel: 'maximum'
    });

    // For DV covert, do NOT make sound! Ensure silent
    if (window.soundEngine) {
      window.soundEngine.stopSiren();
    }

    this.showToast("🔒 Covert SOS Dispatched: Routed silently to verified female counselor & local NGO.");

    // Trigger Masked Counselor Callback after 4 seconds to demonstrate safe telemarketer cover!
    setTimeout(() => {
      this.triggerCounselorCall();
    }, 4000);
  }

  cancelSOS() {
    this.isSOSActive = false;
    this.activeAlert = null;

    if (window.cascadeManager) window.cascadeManager.reset();
    if (window.tacticalMap) window.tacticalMap.resetPositions();
    if (window.soundEngine) window.soundEngine.stopSiren();

    const strobeOverlay = document.getElementById('strobeOverlay');
    if (strobeOverlay) strobeOverlay.classList.remove('active');

    const statusBanner = document.getElementById('victimStatusBanner');
    if (statusBanner) {
      statusBanner.className = 'status-banner ready-standby';
      statusBanner.innerHTML = `
        <div class="banner-dot green"></div>
        <div>
          <strong>PROTECTION ACTIVE • 34 RESPONDERS NEARBY</strong>
          <p>High Accuracy GPS Locked • Mesh Relay Ready</p>
        </div>
      `;
    }

    const cancelBtn = document.getElementById('cancelSosBtn');
    if (cancelBtn) cancelBtn.style.display = 'none';

    this.showToast("✅ Alert Cancelled safely. Cloud session archived.");
  }

  toggleStrobeSiren() {
    const strobeOverlay = document.getElementById('strobeOverlay');
    if (!strobeOverlay) return;

    const isActive = strobeOverlay.classList.toggle('active');
    if (isActive) {
      if (window.soundEngine) window.soundEngine.startSiren();
      this.showToast("🚨 High-Decibel Siren & Strobe Activated to Attract Crowd");
    } else {
      if (window.soundEngine) window.soundEngine.stopSiren();
    }
  }

  launchFakeCall() {
    const fakeCallModal = document.getElementById('fakeCallModal');
    if (!fakeCallModal) return;

    fakeCallModal.classList.add('active');
    if (window.soundEngine) window.soundEngine.startRingtone();

    // Secretly arm silent SOS in the background
    this.triggerEmergencySOS({
      type: 'street_harassment',
      triggerMethod: 'fake_call_screen',
      context: 'deterrent_call'
    });
  }

  acceptFakeCall() {
    if (window.soundEngine) window.soundEngine.stopRingtone();
    const fakeCallModal = document.getElementById('fakeCallModal');
    const fakeCallContent = document.getElementById('fakeCallContent');

    if (fakeCallContent) {
      fakeCallContent.innerHTML = `
        <div class="call-in-progress">
          <div class="call-avatar pulsing">👨</div>
          <h2>Papa ❤️</h2>
          <p class="call-timer" id="fakeCallDuration">00:03</p>
          <div class="call-secret-notice">
            <span>● Secretly Recording Audio & Streaming GPS to Mesh</span>
          </div>
          <div class="call-script-helper">
            <p><strong>Suggested Script to say out loud:</strong></p>
            <p>"Haan Papa, main bas 2 minute mein chowk par pahunch rahi hoon. Aap samne hi khade ho na? Theek hai, main dikh rahi hoon."</p>
          </div>
          <button class="call-end-btn" id="endFakeCallBtn">End Call</button>
        </div>
      `;

      let sec = 3;
      const durEl = document.getElementById('fakeCallDuration');
      const timer = setInterval(() => {
        sec++;
        if (durEl) durEl.innerText = `00:${sec < 10 ? '0' + sec : sec}`;
      }, 1000);

      document.getElementById('endFakeCallBtn').addEventListener('click', () => {
        clearInterval(timer);
        fakeCallModal.classList.remove('active');
      });
    }
  }

  triggerCounselorCall() {
    const counselorModal = document.getElementById('counselorCallModal');
    if (!counselorModal) return;

    counselorModal.classList.add('active');
    if (window.soundEngine) window.soundEngine.startRingtone();
  }

  acceptCounselorCall(responseCode) {
    if (window.soundEngine) window.soundEngine.stopRingtone();
    const counselorModal = document.getElementById('counselorCallModal');

    if (responseCode === 'WRONG_NUMBER') {
      // Secret Code: "Wrong Number" means SEND HELP IMMEDIATELY
      this.showToast("🚨 Secret Code Verified ('Wrong Number'): Female Counselor & Police Rapid Unit Dispatched to Home Address!");
      if (window.cascadeManager) window.cascadeManager.escalateToTier2();
    } else {
      this.showToast("ℹ️ Safe Check-in Confirmed: Counselor initiating silent safety planning protocol.");
    }

    if (counselorModal) counselorModal.classList.remove('active');
  }

  startWalkWatchdog() {
    const watchdogModal = document.getElementById('watchdogModal');
    if (!watchdogModal) return;

    watchdogModal.classList.add('active');
    this.watchdogRemaining = 45; // 45 sec demo
    const timeEl = document.getElementById('watchdogTimeLeft');

    clearInterval(this.watchdogTimer);
    this.watchdogTimer = setInterval(() => {
      this.watchdogRemaining--;
      if (timeEl) timeEl.innerText = `${this.watchdogRemaining}s`;

      if (this.watchdogRemaining <= 0) {
        clearInterval(this.watchdogTimer);
        watchdogModal.classList.remove('active');
        this.triggerEmergencySOS({
          type: 'travel_watchdog_timeout',
          triggerMethod: 'failed_eta_checkin',
          context: 'unfamiliar_walk'
        });
        this.showToast("⚠️ Watchdog ETA Expired: Auto-alerting nearby female mesh and emergency contacts!");
      }
    }, 1000);
  }

  checkinSafeWatchdog() {
    clearInterval(this.watchdogTimer);
    const watchdogModal = document.getElementById('watchdogModal');
    if (watchdogModal) watchdogModal.classList.remove('active');
    this.showToast("✅ Safe Arrival Checked In. Watchdog disarmed.");
  }

  bindDisguiseModes() {
    // Sub-mode tabs inside Victim phone: Standard SOS | Calculator Disguise | Rural IVR | Trip Guard
    const subModeBtns = document.querySelectorAll('.submode-btn');
    subModeBtns.forEach(btn => {
      btn.addEventListener('click', () => {
        subModeBtns.forEach(b => b.classList.remove('active'));
        btn.classList.add('active');

        const mode = btn.dataset.submode;
        document.querySelectorAll('.phone-subscreen').forEach(s => s.classList.remove('active'));
        const targetScreen = document.getElementById(`subscreen-${mode}`);
        if (targetScreen) targetScreen.classList.add('active');
      });
    });

    // Calculator buttons
    const calcBtns = document.querySelectorAll('.calc-btn');
    calcBtns.forEach(btn => {
      btn.addEventListener('click', () => {
        const val = btn.dataset.val;
        if (window.disguiseCalculator) {
          window.disguiseCalculator.handleButton(val);
        }
      });
    });

    // Covert Quick-Exit Button
    const quickExitBtns = document.querySelectorAll('.btn-quick-exit');
    quickExitBtns.forEach(btn => {
      btn.addEventListener('click', () => {
        // Swap to neutral screen
        document.querySelectorAll('.phone-subscreen').forEach(s => s.classList.remove('active'));
        const weatherScreen = document.getElementById('subscreen-innocent-weather');
        if (weatherScreen) weatherScreen.classList.add('active');
        this.showToast("🛡️ Quick Exit: Screen swapped to innocent Weather App.");
      });
    });

    // Rural IVR Missed Call trigger demo
    const ruralMissedCallBtn = document.getElementById('triggerRuralMissedCallBtn');
    if (ruralMissedCallBtn) {
      ruralMissedCallBtn.addEventListener('click', () => {
        this.handleCovertTrigger({
          source: 'rural_ivr_missed_call',
          mode: 'feature_phone_silent',
          priorityResponders: ['anganwadi_worker', 'asha_supervisor', 'local_ngo']
        });
      });
    }

    // Rural WhatsApp Emoji trigger demo
    const ruralEmojiBtns = document.querySelectorAll('.whatsapp-coded-emoji');
    ruralEmojiBtns.forEach(btn => {
      btn.addEventListener('click', () => {
        const emoji = btn.innerText;
        this.handleCovertTrigger({
          source: `whatsapp_coded_emoji_${emoji}`,
          mode: 'chat_emoji_trigger',
          priorityResponders: ['trusted_contact', 'dv_counselor']
        });
      });
    });
  }

  bindResponderActions() {
    // "I'm Walking Over" button
    const walkOverBtn = document.getElementById('respWalkOverBtn');
    if (walkOverBtn) {
      walkOverBtn.addEventListener('click', () => {
        if (window.tacticalMap) {
          window.tacticalMap.startEnRouteAnimation();
        }
        walkOverBtn.innerHTML = '🚶‍♀️ En Route (Paired with Kavita M. - 140m)';
        walkOverBtn.disabled = true;

        this.showToast("🤝 Safety Rule Enforced: Paired with nearby verified responder Kavita M. Walking together!");

        // Open Cross-Check arrival verification after 5 seconds
        setTimeout(() => {
          this.openArrivalVerificationModal();
        }, 5000);
      });
    }

    // "Initiate Discreet Video Call"
    const videoCallBtn = document.getElementById('respVideoCallBtn');
    if (videoCallBtn) {
      videoCallBtn.addEventListener('click', () => {
        this.openCompanionVideoModal();
      });
    }

    // "Call 112 on her behalf"
    const respCallPoliceBtn = document.getElementById('respCallPoliceBtn');
    if (respCallPoliceBtn) {
      respCallPoliceBtn.addEventListener('click', () => {
        if (window.cascadeManager) window.cascadeManager.escalateToTier3();
        this.showToast("🚓 Police 112 Gateway Alerted: Patrol Unit dispatched to coordinates!");
      });
    }

    // "Remote Siren"
    const respRemoteSirenBtn = document.getElementById('respRemoteSirenBtn');
    if (respRemoteSirenBtn) {
      respRemoteSirenBtn.addEventListener('click', () => {
        this.toggleStrobeSiren();
      });
    }
  }

  openCompanionVideoModal() {
    const modal = document.getElementById('companionVideoModal');
    if (modal) modal.classList.add('active');
  }

  closeCompanionVideoModal() {
    const modal = document.getElementById('companionVideoModal');
    if (modal) modal.classList.remove('active');
  }

  openArrivalVerificationModal() {
    const modal = document.getElementById('arrivalCrossCheckModal');
    if (modal) modal.classList.add('active');
  }

  submitArrivalCrossCheck(observation) {
    const modal = document.getElementById('arrivalCrossCheckModal');
    if (modal) modal.classList.remove('active');

    // Simulate cross check
    const reports = [
      { responderId: "RES-102", observation: observation },
      { responderId: "RES-108", observation: observation }
    ];

    const result = window.fraudEngine.crossCheckArrivals(reports);
    this.showToast(`🛡️ Anti-Scam Cross-Check: ${result.status} — ${result.action}`);
  }

  updateResponderAlertCard(alert) {
    const cardTitle = document.getElementById('respAlertTitle');
    const cardType = document.getElementById('respAlertType');
    const cardDistance = document.getElementById('respAlertDist');

    if (cardTitle) cardTitle.innerText = alert.type.replace(/_/g, ' ').toUpperCase();
    if (cardType) cardType.innerText = `Trigger: ${alert.triggerMethod}`;
    if (cardDistance) cardDistance.innerText = '140m away • MG Road Indiranagar';
  }

  bindFraudControls() {
    const inputs = ['fraudAccountAge', 'fraudKycLevel', 'fraudCancelledAlerts', 'fraudAlertHistory', 'fraudDeviceRooted', 'fraudVpnActive', 'fraudAreaRisk', 'fraudIsIsolated'];
    inputs.forEach(id => {
      const el = document.getElementById(id);
      if (el) {
        el.addEventListener('input', () => this.runFraudEvaluation());
      }
    });

    // Preset test scenario buttons
    const presetA = document.getElementById('presetLegitStudent');
    const presetB = document.getElementById('presetSuspiciousLure');
    const presetC = document.getElementById('presetCovertRural');

    if (presetA) {
      presetA.addEventListener('click', () => {
        this.setFraudFormValues({
          accountAge: 180,
          kyc: 'aadhaar_biometric',
          cancelled: 0,
          history: 2,
          rooted: false,
          vpn: false,
          areaRisk: 'high',
          isolated: false
        });
      });
    }

    if (presetB) {
      presetB.addEventListener('click', () => {
        this.setFraudFormValues({
          accountAge: 2,
          kyc: 'unverified',
          cancelled: 3,
          history: 0,
          rooted: true,
          vpn: true,
          areaRisk: 'low',
          isolated: true
        });
      });
    }

    if (presetC) {
      presetC.addEventListener('click', () => {
        this.setFraudFormValues({
          accountAge: 45,
          kyc: 'video_selfie',
          cancelled: 0,
          history: 0,
          rooted: false,
          vpn: false,
          areaRisk: 'medium',
          isolated: false
        });
      });
    }
  }

  setFraudFormValues(data) {
    const setVal = (id, val) => {
      const el = document.getElementById(id);
      if (el) {
        if (el.type === 'checkbox') el.checked = val;
        else el.value = val;
      }
    };

    setVal('fraudAccountAge', data.accountAge);
    setVal('fraudKycLevel', data.kyc);
    setVal('fraudCancelledAlerts', data.cancelled);
    setVal('fraudAlertHistory', data.history);
    setVal('fraudDeviceRooted', data.rooted);
    setVal('fraudVpnActive', data.vpn);
    setVal('fraudAreaRisk', data.areaRisk);
    setVal('fraudIsIsolated', data.isolated);

    this.runFraudEvaluation();
  }

  runFraudEvaluation() {
    const getVal = id => {
      const el = document.getElementById(id);
      return el ? (el.type === 'checkbox' ? el.checked : el.value) : null;
    };

    const signals = {
      accountAge: parseInt(getVal('fraudAccountAge') || 90),
      verificationLevel: getVal('fraudKycLevel') || 'aadhaar_biometric',
      cancelledAlerts: parseInt(getVal('fraudCancelledAlerts') || 0),
      alertHistory: parseInt(getVal('fraudAlertHistory') || 1),
      rootedDevice: getVal('fraudDeviceRooted') || false,
      vpnDetection: getVal('fraudVpnActive') || false,
      isUsualArea: true,
      areaRisk: getVal('fraudAreaRisk') || 'medium',
      isIsolated: getVal('fraudIsIsolated') || false
    };

    const ageLabel = document.getElementById('fraudAccountAgeVal');
    if (ageLabel) ageLabel.innerText = `${signals.accountAge} days`;

    const result = window.fraudEngine.evaluate(signals);

    // Update UI elements
    const scoreVal = document.getElementById('fraudScoreDisplay');
    const gaugeFill = document.getElementById('fraudGaugeFill');
    const recBadge = document.getElementById('fraudRecBadge');
    const rationaleEl = document.getElementById('fraudRationaleText');
    const breakdownEl = document.getElementById('fraudFactorList');
    const antiLuringBox = document.getElementById('antiLuringNotice');

    if (scoreVal) scoreVal.innerText = result.fraudScore.toFixed(2);
    if (gaugeFill) gaugeFill.style.width = `${Math.round(result.fraudScore * 100)}%`;

    if (recBadge) {
      recBadge.innerText = result.recommendation.replace(/_/g, ' ');
      recBadge.className = `rec-badge rec-${result.recommendation.toLowerCase()}`;
    }

    if (rationaleEl) rationaleEl.innerText = result.rationale;

    if (breakdownEl) {
      breakdownEl.innerHTML = result.factorBreakdown.map(f => `
        <div class="factor-item ${f.type}">
          <span>${f.name}</span>
          <strong>${f.delta}</strong>
        </div>
      `).join('');
    }

    if (antiLuringBox) {
      if (result.antiLuringTriggered) {
        antiLuringBox.style.display = 'block';
        antiLuringBox.innerHTML = `
          <strong>🛡️ ANTI-LURING SAFEGUARDS TRIGGERED</strong>
          <p>Isolated location + Unverified account detected. System enforces: ${result.antiLuringProtocols.join(' • ')}</p>
        `;
      } else {
        antiLuringBox.style.display = 'none';
      }
    }
  }

  bindPitchDeck() {
    let currentSlide = 0;
    const slides = document.querySelectorAll('.pitch-slide');
    const prevBtn = document.getElementById('pitchPrevBtn');
    const nextBtn = document.getElementById('pitchNextBtn');
    const dotsContainer = document.getElementById('pitchDotsContainer');

    if (!slides.length) return;

    // Generate dots
    if (dotsContainer) {
      dotsContainer.innerHTML = Array.from(slides).map((_, i) => `
        <span class="pitch-dot ${i === 0 ? 'active' : ''}" data-index="${i}"></span>
      `).join('');

      dotsContainer.querySelectorAll('.pitch-dot').forEach(dot => {
        dot.addEventListener('click', () => {
          showSlide(parseInt(dot.dataset.index));
        });
      });
    }

    const showSlide = (index) => {
      slides.forEach((s, i) => s.classList.toggle('active', i === index));
      if (dotsContainer) {
        dotsContainer.querySelectorAll('.pitch-dot').forEach((d, i) => d.classList.toggle('active', i === index));
      }
      currentSlide = index;
    };

    if (prevBtn) {
      prevBtn.addEventListener('click', () => {
        const next = (currentSlide - 1 + slides.length) % slides.length;
        showSlide(next);
      });
    }

    if (nextBtn) {
      nextBtn.addEventListener('click', () => {
        const next = (currentSlide + 1) % slides.length;
        showSlide(next);
      });
    }
  }

  showToast(message) {
    let toast = document.getElementById('appToast');
    if (!toast) {
      toast = document.createElement('div');
      toast.id = 'appToast';
      document.body.appendChild(toast);
    }
    toast.innerText = message;
    toast.className = 'app-toast active';
    setTimeout(() => {
      toast.className = 'app-toast';
    }, 4500);
  }
}

// Global initialization
window.addEventListener('DOMContentLoaded', () => {
  window.sanginiApp = window.shaktiApp = new SanginiApp();

  // Fake call buttons setup
  const acceptFakeBtn = document.getElementById('acceptFakeCallBtn');
  if (acceptFakeBtn) {
    acceptFakeBtn.addEventListener('click', () => window.sanginiApp.acceptFakeCall());
  }

  const declineFakeBtn = document.getElementById('declineFakeCallBtn');
  if (declineFakeBtn) {
    declineFakeBtn.addEventListener('click', () => {
      const modal = document.getElementById('fakeCallModal');
      if (modal) modal.classList.remove('active');
      if (window.soundEngine) window.soundEngine.stopRingtone();
    });
  }

  // Counselor Call Responses
  const counselorWrongNumBtn = document.getElementById('counselorWrongNumBtn');
  if (counselorWrongNumBtn) {
    counselorWrongNumBtn.addEventListener('click', () => {
      window.sanginiApp.acceptCounselorCall('WRONG_NUMBER');
    });
  }

  const counselorSafeBtn = document.getElementById('counselorSafeBtn');
  if (counselorSafeBtn) {
    counselorSafeBtn.addEventListener('click', () => {
      window.sanginiApp.acceptCounselorCall('SAFE');
    });
  }

  // Close companion video
  const closeVideoBtn = document.getElementById('closeCompanionVideoBtn');
  if (closeVideoBtn) {
    closeVideoBtn.addEventListener('click', () => window.sanginiApp.closeCompanionVideoModal());
  }

  // Watchdog Safe Button
  const watchdogSafeBtn = document.getElementById('watchdogSafeCheckinBtn');
  if (watchdogSafeBtn) {
    watchdogSafeBtn.addEventListener('click', () => window.sanginiApp.checkinSafeWatchdog());
  }

  // Arrival verification options
  const verifyConfirmBtn = document.getElementById('arrivalVerifyConfirmBtn');
  if (verifyConfirmBtn) {
    verifyConfirmBtn.addEventListener('click', () => window.sanginiApp.submitArrivalCrossCheck('victim_confirmed_needs_help'));
  }

  const verifyNobodyBtn = document.getElementById('arrivalVerifyNobodyBtn');
  if (verifyNobodyBtn) {
    verifyNobodyBtn.addEventListener('click', () => window.sanginiApp.submitArrivalCrossCheck('nobody_here'));
  }
});
