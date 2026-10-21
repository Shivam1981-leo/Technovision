// Sangini AI - Main Application Controller
// Orchestrates:
// 1. One-Line Jury Console (SG|... & OK|... commands)
// 2. Append-Only Incident Event Log Engine & 60-Second Real-Time Countdown
// 3. Location-Based Response Routing (Street = Peer Mesh Radar | Home = Discreet Confidential Path)
// 4. Silent Mode Enforcement (silent 1 = quiet alarm, silent 0 = audible)
// 5. Existing SOS triggers, Covert Calculator disguise, AI Fraud Engine & Evidence Vault.

class SanginiApp {
  constructor() {
    this.activeTab = 'victim-app';
    this.tapPowerCount = 0;
    this.tapPowerTimer = null;
    this.watchdogTimer = null;
    this.watchdogRemaining = 45;

    this.init();
  }

  init() {
    this.bindNavigation();
    this.bindJuryConsole();
    this.bindVictimTriggers();
    this.bindResponderActions();
    this.bindFraudControls();
    this.bindDisguiseModes();
    this.bindPitchDeck();
    this.subscribeToEventLog();

    // Initialize radar map after DOM ready
    setTimeout(() => {
      if (!window.tacticalMap && window.MeshTacticalMap) {
        window.tacticalMap = new window.MeshTacticalMap('tacticalMeshCanvas');
      }
      this.runFraudEvaluation();
    }, 200);

    // Audio Mute toggle
    const muteBtn = document.getElementById('audioMuteBtn');
    if (muteBtn) {
      muteBtn.addEventListener('click', () => {
        const isMuted = window.soundEngine ? window.soundEngine.toggleMute() : true;
        muteBtn.innerHTML = isMuted ? '🔇 Audio Muted' : '🔊 Audio Active';
        muteBtn.classList.toggle('muted', isMuted);
      });
    }
  }

  // Subscribe directly to the Append-Only Incident Event Log
  subscribeToEventLog() {
    if (window.incidentEventLogManager) {
      window.incidentEventLogManager.subscribe((incident, event) => {
        this.onIncidentStateChange(incident, event);
      });
      const current = window.incidentEventLogManager.getActiveIncident();
      if (current) this.onIncidentStateChange(current, null);
    } else {
      setTimeout(() => this.subscribeToEventLog(), 150);
    }
  }

  // Handle Event Log state updates
  onIncidentStateChange(incident, event) {
    if (!incident) return;

    // Update Console Bar Indicators
    this.updateConsoleBarStatus(incident);

    // Update Victim UI Banner
    this.updateVictimStatusBanner(incident);

    // Update Responder Alert Sidebar
    this.updateResponderSidebar(incident);

    // Enforce Silent Mode: when silent is set to 1, the alarm must remain quiet
    if (incident.status === 'active' || incident.status === 'escalated') {
      if (incident.silent === 1) {
        // Quiet mode: stop any loud sirens or chirps
        if (window.soundEngine) window.soundEngine.stopSiren();
      } else {
        // Audible mode
        if (event && event.type === 'Triggered' && window.soundEngine) {
          window.soundEngine.playAlertChirp();
        }
      }
    }
  }

  updateConsoleBarStatus(incident) {
    const ctxPill = document.getElementById('juryStatusContext');
    const radarPill = document.getElementById('juryStatusRadar');
    const timerPill = document.getElementById('juryStatusTimer');
    const codePill = document.getElementById('juryStatusCode');
    const silentPill = document.getElementById('juryStatusSilent');

    if (!incident || incident.status === 'idle') {
      if (ctxPill) ctxPill.innerHTML = `Context: <strong style="color: var(--text-dim);">STANDBY</strong>`;
      if (radarPill) radarPill.innerHTML = `Peer Radar: <strong style="color: var(--safe-green);">READY</strong>`;
      if (timerPill) timerPill.innerHTML = `60s Timer: <strong style="color: var(--text-dim);">--</strong>`;
      if (codePill) codePill.innerHTML = `Code: <strong style="color: var(--neon-cyan);">BLUE</strong>`;
      if (silentPill) silentPill.innerHTML = `Mode: <strong style="color: var(--text-dim);">STANDBY</strong>`;
      return;
    }

    if (ctxPill) {
      const isHome = incident.context === 'home';
      ctxPill.innerHTML = `Context: <strong style="color: ${isHome ? 'var(--neon-magenta)' : 'var(--neon-cyan)'};">${incident.context.toUpperCase()}</strong>`;
    }

    if (radarPill) {
      if (incident.context === 'home' || !incident.peerRadarVisible) {
        radarPill.innerHTML = `Peer Radar: <strong style="color: var(--neon-magenta);">🔒 HIDDEN (DISCREET)</strong>`;
      } else {
        radarPill.innerHTML = `Peer Radar: <strong style="color: var(--emergency-red);">📡 BROADCASTING</strong>`;
      }
    }

    if (timerPill) {
      if (incident.status === 'accepted') {
        timerPill.innerHTML = `60s Timer: <strong style="color: var(--safe-green);">✓ ACCEPTED</strong>`;
      } else if (incident.status === 'escalated') {
        timerPill.innerHTML = `60s Timer: <strong style="color: var(--emergency-red);">TIMEOUT (TIER 2)</strong>`;
      } else {
        timerPill.innerHTML = `60s Timer: <strong style="color: ${incident.timeRemaining <= 15 ? 'var(--emergency-red)' : 'var(--neon-cyan)'};">${incident.timeRemaining}s</strong>`;
      }
    }

    if (codePill) {
      codePill.innerHTML = `Code: <strong style="color: var(--neon-cyan);">${incident.shortCode}</strong>`;
    }

    if (silentPill) {
      silentPill.innerHTML = incident.silent === 1
        ? `Alarm: <strong style="color: var(--warn-amber);">🔇 SILENT (QUIET)</strong>`
        : `Alarm: <strong style="color: var(--emergency-red);">🔊 AUDIBLE</strong>`;
    }
  }

  updateVictimStatusBanner(incident) {
    const statusBanner = document.getElementById('victimStatusBanner');
    const cancelBtn = document.getElementById('cancelSosBtn');

    if (!statusBanner) return;

    if (!incident || incident.status === 'idle') {
      statusBanner.className = 'status-banner ready-standby';
      statusBanner.innerHTML = `
        <div class="banner-pulse" style="background: var(--safe-green); box-shadow: 0 0 10px var(--safe-green);"></div>
        <div>
          <strong>PROTECTION ACTIVE • 34 RESPONDERS NEARBY</strong>
          <p>High Accuracy GPS Locked • Mesh Relay Ready • Standby</p>
        </div>
      `;
      if (cancelBtn) cancelBtn.style.display = 'none';
      return;
    }

    if (cancelBtn) cancelBtn.style.display = 'inline-flex';

    if (incident.status === 'accepted') {
      statusBanner.className = 'status-banner accepted-safe';
      statusBanner.innerHTML = `
        <div class="banner-pulse" style="background: var(--safe-green); box-shadow: 0 0 14px var(--safe-green);"></div>
        <div>
          <strong style="color: var(--safe-green);">🤝 RESPONDER EN ROUTE (${incident.responders[0]?.name || 'R12'})</strong>
          <p>Accepted with Verification Code [${incident.shortCode}]. Keep phone in hand.</p>
        </div>
      `;
    } else if (incident.status === 'escalated') {
      statusBanner.className = 'status-banner active-emergency';
      statusBanner.innerHTML = `
        <div class="banner-pulse" style="background: var(--warn-amber); box-shadow: 0 0 14px var(--warn-amber);"></div>
        <div>
          <strong style="color: var(--warn-amber);">⚡ TIER 2 ESCALATION ENGAGED (60s Timeout)</strong>
          <p>Community Patrols & Police 112 Gateway Alerted with Cryptographic Evidence Hash.</p>
        </div>
      `;
    } else if (incident.context === 'home') {
      // Home incident discreet mode
      statusBanner.className = 'status-banner home-discreet';
      statusBanner.innerHTML = `
        <div class="banner-pulse" style="background: var(--neon-magenta); box-shadow: 0 0 14px var(--neon-magenta);"></div>
        <div>
          <strong style="color: var(--neon-magenta);">🔒 DISCREET HOME PROTOCOL ACTIVE (PEER RADAR BLOCKED)</strong>
          <p>Zero public alarm • Routed secretly to verified female counselor. Alarm is silent.</p>
        </div>
      `;
    } else {
      // Street incident active mode
      statusBanner.className = 'status-banner active-emergency';
      statusBanner.innerHTML = `
        <div class="banner-pulse"></div>
        <div>
          <strong>🚨 SOS TRANSMITTED (${incident.context.toUpperCase()} • TIER 1 MESH ACTIVE)</strong>
          <p>Alert broadcast to 4 verified female peers in 200m. 60s Acceptance countdown running.</p>
        </div>
      `;
    }
  }

  updateResponderSidebar(incident) {
    const cardTitle = document.getElementById('respAlertTitle');
    const cardType = document.getElementById('respAlertType');
    const cardDist = document.getElementById('respAlertDist');
    const walkOverBtn = document.getElementById('respWalkOverBtn');

    if (!cardTitle) return;

    if (!incident || incident.status === 'idle') {
      cardTitle.innerText = "NO ACTIVE DISTRESS ALERT";
      if (cardType) cardType.innerText = "System in standby patrol scan";
      if (cardDist) cardDist.innerText = "0 active alerts in 200m range";
      if (walkOverBtn) {
        walkOverBtn.disabled = true;
        walkOverBtn.innerHTML = "🚶‍♀️ Standby (No Active Alert)";
      }
      return;
    }

    if (walkOverBtn) {
      walkOverBtn.disabled = false;
      if (incident.status === 'accepted') {
        walkOverBtn.innerHTML = `🚶‍♀️ En Route (Accepted as R12 - Code ${incident.shortCode})`;
        walkOverBtn.disabled = true;
      } else {
        walkOverBtn.innerHTML = `🚶‍♀️ Accept as R12 (OK|R12|${incident.shortCode})`;
      }
    }

    if (incident.context === 'home' || !incident.peerRadarVisible) {
      cardTitle.innerHTML = `<span style="color: var(--neon-magenta);">🔒 HOME DISCREET ALERT (CONFIDENTIAL)</span>`;
      if (cardType) cardType.innerHTML = `Peer radar broadcast: <strong style="color: var(--neon-magenta);">SUPPRESSED</strong> (Victim Safety)`;
      if (cardDist) cardDist.innerHTML = `Direct Confidential Counselor Dispatch • Code: <strong>${incident.shortCode}</strong>`;
    } else {
      cardTitle.innerText = `${incident.context.toUpperCase()} HARASSMENT ALERT (${incident.id})`;
      if (cardType) cardType.innerText = `Trigger: ${incident.events[0]?.triggerMethod || 'Jury Console'} • Lat: ${incident.coords.lat}, Lon: ${incident.coords.lon}`;
      if (cardDist) cardDist.innerText = `140m away • Verification Code: [${incident.shortCode}]`;
    }
  }

  // =========================================================================
  // JURY TESTING CONSOLE BINDINGS
  // =========================================================================
  bindJuryConsole() {
    const input = document.getElementById('juryConsoleInput');
    const submitBtn = document.getElementById('juryConsoleSubmitBtn');
    const outputEl = document.getElementById('juryConsoleOutput');

    const executeCommand = (cmdText) => {
      if (!cmdText || !window.incidentEventLogManager) return;
      const res = window.incidentEventLogManager.parseAndExecuteCommand(cmdText);

      if (outputEl) {
        outputEl.innerText = res.message;
        outputEl.className = res.success ? 'jury-console-output success' : 'jury-console-output error';
      }

      this.showToast(res.message);

      // Best effort send to server API
      if (window.fetch) {
        fetch('/api/console-command', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ command: cmdText })
        }).catch(() => {});
      }
    };

    if (submitBtn && input) {
      submitBtn.addEventListener('click', () => {
        executeCommand(input.value);
        input.value = '';
      });

      input.addEventListener('keydown', (e) => {
        if (e.key === 'Enter') {
          executeCommand(input.value);
          input.value = '';
        }
      });
    }

    // Quick-Preset Chips for Jury
    document.querySelectorAll('.jury-chip-btn').forEach(btn => {
      btn.addEventListener('click', () => {
        const cmd = btn.dataset.cmd;
        if (input) input.value = cmd;
        executeCommand(cmd);
      });
    });
  }

  // Navigation
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

  // Victim Smartphone Triggers
  bindVictimTriggers() {
    // 1. Big SOS Button (Opens incident with street context)
    const mainSosBtn = document.getElementById('mainSosPulseBtn');
    if (mainSosBtn) {
      mainSosBtn.addEventListener('click', () => {
        if (window.incidentEventLogManager) {
          window.incidentEventLogManager.triggerIncident({
            context: 'street',
            lat: 18.5204,
            lon: 73.8567,
            silent: 0,
            shortCode: 'BLUE',
            triggerMethod: 'main_pulse_button'
          });
        }
      });
    }

    // 2. Shake 3x Simulator
    const shakeBtn = document.getElementById('simulateShakeBtn');
    if (shakeBtn) {
      shakeBtn.addEventListener('click', () => {
        shakeBtn.classList.add('shaking-active');
        setTimeout(() => shakeBtn.classList.remove('shaking-active'), 800);
        if (window.incidentEventLogManager) {
          window.incidentEventLogManager.triggerIncident({
            context: 'street',
            lat: 18.5204,
            lon: 73.8567,
            silent: 0,
            shortCode: 'BLUE',
            triggerMethod: 'shake_pattern_3x'
          });
        }
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
          if (window.incidentEventLogManager) {
            window.incidentEventLogManager.triggerIncident({
              context: 'street',
              lat: 18.5204,
              lon: 73.8567,
              silent: 0,
              shortCode: 'BLUE',
              triggerMethod: 'power_button_5x'
            });
          }
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
          if (window.incidentEventLogManager) {
            window.incidentEventLogManager.triggerIncident({
              context: 'street',
              lat: 18.5204,
              lon: 73.8567,
              silent: 0,
              shortCode: 'BLUE',
              triggerMethod: 'voice_command_emergency'
            });
          }
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
        if (window.incidentEventLogManager) {
          window.incidentEventLogManager.parseAndExecuteCommand('RESET');
        }
        if (window.soundEngine) window.soundEngine.stopSiren();
        const strobeOverlay = document.getElementById('strobeOverlay');
        if (strobeOverlay) strobeOverlay.classList.remove('active');
        this.showToast("✅ Incident Reset safely. Ready for new commands.");
      });
    }
  }

  // Covert trigger (e.g. from Covert Calculator 911= or Rural IVR)
  handleCovertTrigger(details) {
    if (window.incidentEventLogManager) {
      window.incidentEventLogManager.triggerIncident({
        context: 'home',
        lat: 18.5204,
        lon: 73.8567,
        silent: 1, // discreet home mode MUST remain quiet
        shortCode: 'BLUE',
        triggerMethod: details.source || 'calculator_disguise'
      });
    }

    if (window.soundEngine) window.soundEngine.stopSiren();
    this.showToast("🔒 Covert SOS Dispatched: Routed silently to verified female counselor. Hidden from peer radar.");

    // Trigger Masked Counselor Callback after 4 seconds
    setTimeout(() => {
      this.triggerCounselorCall();
    }, 4000);
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

    if (window.incidentEventLogManager) {
      window.incidentEventLogManager.triggerIncident({
        context: 'street',
        lat: 18.5204,
        lon: 73.8567,
        silent: 1,
        shortCode: 'BLUE',
        triggerMethod: 'fake_call_screen'
      });
    }
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
      this.showToast("🚨 Secret Code Verified ('Wrong Number'): Female Counselor & Police Rapid Unit Dispatched to Home Address!");
      if (window.incidentEventLogManager) {
        window.incidentEventLogManager.escalateIncident("Domestic Violence Secret Code Verified");
      }
    } else {
      this.showToast("ℹ️ Safe Check-in Confirmed: Counselor initiating silent safety planning protocol.");
    }

    if (counselorModal) counselorModal.classList.remove('active');
  }

  startWalkWatchdog() {
    const watchdogModal = document.getElementById('watchdogModal');
    if (!watchdogModal) return;

    watchdogModal.classList.add('active');
    this.watchdogRemaining = 45;
    const timeEl = document.getElementById('watchdogTimeLeft');

    clearInterval(this.watchdogTimer);
    this.watchdogTimer = setInterval(() => {
      this.watchdogRemaining--;
      if (timeEl) timeEl.innerText = `${this.watchdogRemaining}s`;

      if (this.watchdogRemaining <= 0) {
        clearInterval(this.watchdogTimer);
        watchdogModal.classList.remove('active');
        if (window.incidentEventLogManager) {
          window.incidentEventLogManager.triggerIncident({
            context: 'travel',
            lat: 18.5204,
            lon: 73.8567,
            silent: 0,
            shortCode: 'BLUE',
            triggerMethod: 'failed_eta_checkin'
          });
        }
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

    const calcBtns = document.querySelectorAll('.calc-btn');
    calcBtns.forEach(btn => {
      btn.addEventListener('click', () => {
        const val = btn.dataset.val;
        if (window.disguiseCalculator) {
          window.disguiseCalculator.handleButton(val);
        }
      });
    });

    const quickExitBtns = document.querySelectorAll('.btn-quick-exit');
    quickExitBtns.forEach(btn => {
      btn.addEventListener('click', () => {
        document.querySelectorAll('.phone-subscreen').forEach(s => s.classList.remove('active'));
        const weatherScreen = document.getElementById('subscreen-innocent-weather');
        if (weatherScreen) weatherScreen.classList.add('active');
        this.showToast("🛡️ Quick Exit: Screen swapped to innocent Weather App.");
      });
    });

    const ruralMissedCallBtn = document.getElementById('triggerRuralMissedCallBtn');
    if (ruralMissedCallBtn) {
      ruralMissedCallBtn.addEventListener('click', () => {
        this.handleCovertTrigger({
          source: 'rural_ivr_missed_call',
          mode: 'feature_phone_silent'
        });
      });
    }

    const ruralEmojiBtns = document.querySelectorAll('.whatsapp-coded-emoji');
    ruralEmojiBtns.forEach(btn => {
      btn.addEventListener('click', () => {
        const emoji = btn.innerText;
        this.handleCovertTrigger({
          source: `whatsapp_coded_emoji_${emoji}`,
          mode: 'chat_emoji_trigger'
        });
      });
    });
  }

  bindResponderActions() {
    // "I'm Walking Toward Her Location" -> Executes OK|R12|BLUE
    const walkOverBtn = document.getElementById('respWalkOverBtn');
    if (walkOverBtn) {
      walkOverBtn.addEventListener('click', () => {
        if (window.incidentEventLogManager) {
          const res = window.incidentEventLogManager.acceptIncident('R12', 'BLUE');
          if (res.success) {
            walkOverBtn.innerHTML = '🚶‍♀️ En Route (Accepted as R12 - 140m)';
            walkOverBtn.disabled = true;
            this.showToast("🤝 Acceptance Verified: Responder R12 en route with verification code BLUE!");
            setTimeout(() => {
              this.openArrivalVerificationModal();
            }, 5000);
          } else {
            this.showToast(res.message);
          }
        }
      });
    }

    const videoCallBtn = document.getElementById('respVideoCallBtn');
    if (videoCallBtn) {
      videoCallBtn.addEventListener('click', () => {
        this.openCompanionVideoModal();
      });
    }

    const respCallPoliceBtn = document.getElementById('respCallPoliceBtn');
    if (respCallPoliceBtn) {
      respCallPoliceBtn.addEventListener('click', () => {
        if (window.incidentEventLogManager) {
          window.incidentEventLogManager.escalateIncident("Responder Police 112 Dispatch Call");
        }
        this.showToast("🚓 Police 112 Gateway Alerted: Patrol Unit dispatched to coordinates!");
      });
    }

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

    const reports = [
      { responderId: "R12", observation: observation },
      { responderId: "RES-108", observation: observation }
    ];

    const result = window.fraudEngine ? window.fraudEngine.crossCheckArrivals(reports) : { status: "VERIFIED", action: "Confirmed" };
    this.showToast(`🛡️ Anti-Scam Cross-Check: ${result.status} — ${result.action}`);

    if (observation === 'victim_confirmed_needs_help' && window.incidentEventLogManager) {
      window.incidentEventLogManager.closeIncident("Safe arrival verified by peer responders");
    }
  }

  bindFraudControls() {
    const inputs = ['fraudAccountAge', 'fraudKycLevel', 'fraudCancelledAlerts', 'fraudAlertHistory', 'fraudDeviceRooted', 'fraudVpnActive', 'fraudAreaRisk', 'fraudIsIsolated'];
    inputs.forEach(id => {
      const el = document.getElementById(id);
      if (el) {
        el.addEventListener('input', () => this.runFraudEvaluation());
      }
    });

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
    if (!window.fraudEngine) return;
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

  const closeVideoBtn = document.getElementById('closeCompanionVideoBtn');
  if (closeVideoBtn) {
    closeVideoBtn.addEventListener('click', () => window.sanginiApp.closeCompanionVideoModal());
  }

  const watchdogSafeBtn = document.getElementById('watchdogSafeCheckinBtn');
  if (watchdogSafeBtn) {
    watchdogSafeBtn.addEventListener('click', () => window.sanginiApp.checkinSafeWatchdog());
  }

  const verifyConfirmBtn = document.getElementById('arrivalVerifyConfirmBtn');
  if (verifyConfirmBtn) {
    verifyConfirmBtn.addEventListener('click', () => window.sanginiApp.submitArrivalCrossCheck('victim_confirmed_needs_help'));
  }

  const verifyNobodyBtn = document.getElementById('arrivalVerifyNobodyBtn');
  if (verifyNobodyBtn) {
    verifyNobodyBtn.addEventListener('click', () => window.sanginiApp.submitArrivalCrossCheck('nobody_here'));
  }
});
