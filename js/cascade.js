// Sangini AI - 4-Tier Response Cascade & Cryptographic Evidence Vault
// Driven directly by the Append-Only Incident Event Log:
// - Renders 60-Second Real-Time Countdown Timer for Tier 1 acceptance.
// - Renders Append-Only Event Log Stream with cryptographic SHA-256 hashes.
// - Integrates Stubs for Police 112 CAD, Women Helpline 181, and SMS Gateways.
// - Preserves all timeline events across browser refresh.

class ResponseCascadeManager {
  constructor() {
    this.currentTier = 1;
    this.isRecording = false;
    this.audioWaveTimer = null;
    this.currentIncident = null;

    this.init();
  }

  init() {
    this.subscribeToEventLog();
  }

  subscribeToEventLog() {
    if (window.incidentEventLogManager) {
      window.incidentEventLogManager.subscribe((incident, event) => {
        this.syncWithEventLog(incident, event);
      });
      const inc = window.incidentEventLogManager.getActiveIncident();
      if (inc) this.syncWithEventLog(inc, null);
    } else {
      setTimeout(() => this.subscribeToEventLog(), 200);
    }
  }

  syncWithEventLog(incident, event) {
    this.currentIncident = incident;

    if (!incident || incident.status === 'idle') {
      this.currentTier = 1;
      this.isRecording = false;
      this.updateUI();
      this.renderEventLogTable([]);
      return;
    }

    this.currentTier = incident.tier || 1;
    this.isRecording = (incident.status === 'active' || incident.status === 'escalated' || incident.status === 'accepted');

    if (this.isRecording && !this.audioWaveTimer) {
      this.startAudioWaveform();
    }

    this.updateUI();
    this.renderEventLogTable(incident.events || []);
    this.renderStubs();
  }

  startCascade(alertData) {
    // Forwarded to IncidentEventLogManager if needed
    if (window.incidentEventLogManager && (!this.currentIncident || this.currentIncident.status === 'idle')) {
      window.incidentEventLogManager.triggerIncident({
        context: alertData.context || 'street',
        lat: alertData.coords ? alertData.coords.lat : 18.5204,
        lon: alertData.coords ? alertData.coords.lon : 73.8567,
        silent: alertData.silent ? 1 : 0,
        triggerMethod: alertData.triggerMethod || 'sos_button'
      });
    }
  }

  escalateToTier2() {
    if (window.incidentEventLogManager) {
      window.incidentEventLogManager.escalateIncident("Manual Escalation to Tier 2 Community Patrols");
    }
  }

  escalateToTier3() {
    if (window.incidentEventLogManager) {
      window.incidentEventLogManager.escalateIncident("Manual Police 112 Dispatch Triggered");
    }
  }

  reset() {
    if (window.incidentEventLogManager) {
      window.incidentEventLogManager.parseAndExecuteCommand('RESET');
    }
  }

  formatTime(secs) {
    const s = Math.max(0, parseInt(secs) || 0);
    const m = Math.floor(s / 60).toString().padStart(2, '0');
    const remainingS = (s % 60).toString().padStart(2, '0');
    return `${m}:${remainingS}`;
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
      } else {
        this.audioWaveTimer = null;
      }
    };
    render();
  }

  updateUI() {
    const inc = this.currentIncident;
    const t1El = document.getElementById('cascadeTier1Time');
    const t2El = document.getElementById('cascadeTier2Time');
    const badgeEl = document.getElementById('activeTierBadge');

    const remainingSecs = inc ? inc.timeRemaining : 60;

    // Display 60-second timer on Tier 1
    if (t1El) {
      if (inc && inc.status === 'accepted') {
        t1El.innerText = "ACCEPTED ✓";
        t1El.style.color = "var(--safe-green)";
      } else if (inc && inc.status === 'escalated') {
        t1El.innerText = "TIMEOUT (00:00)";
        t1El.style.color = "var(--emergency-red)";
      } else if (inc && inc.status === 'active') {
        t1El.innerText = this.formatTime(remainingSecs);
        t1El.style.color = remainingSecs <= 15 ? "var(--emergency-red)" : "var(--neon-cyan)";
      } else {
        t1El.innerText = "01:00";
        t1El.style.color = "var(--text-muted)";
      }
    }

    if (t2El) {
      t2El.innerText = this.currentTier >= 2 ? "08:00 (ACTIVE)" : "08:00 (STANDBY)";
    }

    const step1 = document.getElementById('cascadeStep1');
    const step2 = document.getElementById('cascadeStep2');
    const step3 = document.getElementById('cascadeStep3');
    const step4 = document.getElementById('cascadeStep4');

    if (step1 && step2 && step3 && step4) {
      step1.className = `cascade-step ${this.currentTier === 1 && inc && inc.status === 'active' ? 'active pulsing-border' : (this.currentTier >= 1 ? 'active' : '')}`;
      step2.className = `cascade-step ${this.currentTier >= 2 ? 'active escalated-border' : ''}`;
      step3.className = `cascade-step ${this.currentTier >= 3 ? 'active critical' : ''}`;
      step4.className = 'cascade-step active'; // Tier 4 trusted contacts parallel
    }

    if (badgeEl) {
      if (!inc || inc.status === 'idle') {
        badgeEl.className = 'tier-indicator';
        badgeEl.innerHTML = `<span>● STANDBY: No Active Distress Incident</span>`;
      } else if (inc.status === 'accepted') {
        badgeEl.className = 'tier-indicator tier-safe';
        badgeEl.innerHTML = `<span>✓ TIER 1 ACCEPTED: Verified Responder En Route (Short Code: ${inc.shortCode})</span>`;
      } else if (this.currentTier === 1) {
        const isDiscreet = inc.context === 'home';
        badgeEl.className = 'tier-indicator tier-1';
        badgeEl.innerHTML = `<span>● ${isDiscreet ? 'DISCREET HOME TIER' : 'TIER 1 PROXIMITY'} ACTIVE (60s Timer: ${this.formatTime(remainingSecs)})</span>`;
      } else if (this.currentTier === 2) {
        badgeEl.className = 'tier-indicator tier-2';
        badgeEl.innerHTML = `<span>● TIER 2 ESCALATED: Community Patrols & NGO Rapid Response Engaged</span>`;
      } else {
        badgeEl.className = 'tier-indicator tier-3';
        badgeEl.innerHTML = `<span>🚨 TIER 3 POLICE DISPATCH: Karnataka State Police 112 Interceptor CAD Active</span>`;
      }
    }

    // Update dedicated 60-second widget if present
    const bigTimerEl = document.getElementById('incidentBigTimer');
    const bigTimerStatusEl = document.getElementById('incidentBigTimerStatus');
    const bigTimerBar = document.getElementById('incidentTimerProgress');

    if (bigTimerEl) {
      bigTimerEl.innerText = `${remainingSecs}s`;
    }
    if (bigTimerBar) {
      const pct = Math.max(0, Math.min(100, Math.round((remainingSecs / 60) * 100)));
      bigTimerBar.style.width = `${pct}%`;
      if (pct <= 25) bigTimerBar.style.backgroundColor = 'var(--emergency-red)';
      else if (pct <= 50) bigTimerBar.style.backgroundColor = 'var(--warn-amber)';
      else bigTimerBar.style.backgroundColor = 'var(--neon-cyan)';
    }
    if (bigTimerStatusEl && inc) {
      if (inc.status === 'accepted') {
        bigTimerStatusEl.innerHTML = `<span style="color: var(--safe-green);">✓ Responder Accepted. 60s Timer Stopped.</span>`;
      } else if (inc.status === 'escalated') {
        bigTimerStatusEl.innerHTML = `<span style="color: var(--emergency-red);">⚠️ 60s Expired with no OK acceptance. Advanced to Tier 2.</span>`;
      } else if (inc.status === 'active') {
        bigTimerStatusEl.innerHTML = `<span>Awaiting <code>OK|${inc.responders[0]?.id || 'R12'}|${inc.shortCode}</code> before timeout...</span>`;
      }
    }
  }

  // Render the Append-Only Event Log Stream
  renderEventLogTable(events) {
    const container = document.getElementById('incidentEventLogContainer');
    if (!container) return;

    if (!events || events.length === 0) {
      container.innerHTML = `
        <div style="text-align: center; padding: 24px; color: var(--text-dim); font-size: 13px;">
          <em>Append-only event log is empty. Trigger an incident using the Jury Console (e.g. <code>SG|street|18.5204|73.8567|1</code>) to begin recording.</em>
        </div>
      `;
      return;
    }

    const typeColors = {
      'Triggered': { bg: 'rgba(255, 45, 85, 0.15)', border: '#ff2d55', text: '#ff2d55', icon: '🚨' },
      'Routed': { bg: 'rgba(0, 240, 255, 0.15)', border: '#00f0ff', text: '#00f0ff', icon: '📡' },
      'Accepted': { bg: 'rgba(0, 230, 118, 0.15)', border: '#00e676', text: '#00e676', icon: '🤝' },
      'Escalated': { bg: 'rgba(255, 179, 0, 0.15)', border: '#ffb300', text: '#ffb300', icon: '⚡' },
      'Closed': { bg: 'rgba(148, 163, 184, 0.15)', border: '#94a3b8', text: '#94a3b8', icon: '🔒' }
    };

    container.innerHTML = events.map(evt => {
      const cfg = typeColors[evt.type] || { bg: 'rgba(255,255,255,0.1)', border: '#fff', text: '#fff', icon: '📝' };
      return `
        <div class="event-log-entry" style="border-left: 3px solid ${cfg.border}; background: ${cfg.bg}; margin-bottom: 10px; padding: 12px 14px; border-radius: 6px;">
          <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 6px;">
            <div style="display: flex; align-items: center; gap: 8px;">
              <span style="font-size: 15px;">${cfg.icon}</span>
              <strong style="color: ${cfg.text}; font-size: 13px; text-transform: uppercase; letter-spacing: 0.5px;">${evt.type}</strong>
              <span style="font-size: 11px; background: rgba(0,0,0,0.4); padding: 2px 6px; border-radius: 4px; color: var(--text-dim);">#${evt.index}</span>
            </div>
            <span style="font-size: 11px; font-family: var(--font-mono); color: var(--text-muted);">${evt.timeDisplay || ''}</span>
          </div>
          <p style="font-size: 12px; color: var(--text-main); line-height: 1.4; margin-bottom: 6px;">${evt.message || ''}</p>
          <div style="display: flex; justify-content: space-between; align-items: center; font-size: 10px; color: var(--text-dim); font-family: var(--font-mono);">
            <span>Chain Hash: <span style="color: var(--neon-cyan);">${evt.hash || '0x...'}</span></span>
            <span>Sec 65B Immutable</span>
          </div>
        </div>
      `;
    }).reverse().join('');
  }

  // Render Integration Stubs for 112, 181, and SMS
  renderStubs() {
    const stubsBox = document.getElementById('integrationStubsContainer');
    if (!stubsBox || !window.incidentEventLogManager) return;

    const stubs = window.incidentEventLogManager.stubs;
    stubsBox.innerHTML = `
      <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 12px; margin-top: 10px;">
        <!-- 112 CAD Stub -->
        <div class="stub-card">
          <div style="display: flex; justify-content: space-between; align-items: center;">
            <strong style="color: var(--emergency-red); font-size: 12px;">🚓 Police 112 CAD [STUB]</strong>
            <span class="stub-badge ${stubs.police112.status === 'INTERCEPTOR_DISPATCHED' ? 'active-red' : 'standby'}">
              ${stubs.police112.status}
            </span>
          </div>
          <p style="font-size: 11px; color: var(--text-muted); margin-top: 4px;">
            Karnataka State Police Direct XML CAD Gateway. Dispatches patrol interceptor upon Tier 3 escalation.
          </p>
          <div style="background: rgba(0,0,0,0.5); padding: 6px 8px; border-radius: 4px; font-family: var(--font-mono); font-size: 10px; color: var(--text-dim); margin-top: 6px;">
            Endpoint: POST /ksp-cad/v2/dispatch<br>
            Payload: ${stubs.police112.lastPayload ? JSON.stringify(stubs.police112.lastPayload).slice(0, 48) + '...' : 'Idle (Standby)'}
          </div>
        </div>

        <!-- 181 Helpline Stub -->
        <div class="stub-card">
          <div style="display: flex; justify-content: space-between; align-items: center;">
            <strong style="color: var(--neon-magenta); font-size: 12px;">📞 Women Helpline 181 [STUB]</strong>
            <span class="stub-badge ${stubs.helpline181.status.includes('DISPATCH') ? 'active-magenta' : 'standby'}">
              ${stubs.helpline181.status}
            </span>
          </div>
          <p style="font-size: 11px; color: var(--text-muted); margin-top: 4px;">
            Ministry of Women & Child Development Rapid Domestic Violence Desk. Dedicated confidential line.
          </p>
          <div style="background: rgba(0,0,0,0.5); padding: 6px 8px; border-radius: 4px; font-family: var(--font-mono); font-size: 10px; color: var(--text-dim); margin-top: 6px;">
            Endpoint: POST /wcd-181/v1/helpline<br>
            Payload: ${stubs.helpline181.lastPayload ? JSON.stringify(stubs.helpline181.lastPayload).slice(0, 48) + '...' : 'Idle (Standby)'}
          </div>
        </div>

        <!-- SMS Gateway Stub -->
        <div class="stub-card">
          <div style="display: flex; justify-content: space-between; align-items: center;">
            <strong style="color: var(--safe-green); font-size: 12px;">📱 TRAI DLT Emergency SMS [STUB]</strong>
            <span class="stub-badge ${stubs.smsGateway.status.includes('DISPATCHED') ? 'active-green' : 'standby'}">
              ${stubs.smsGateway.status}
            </span>
          </div>
          <p style="font-size: 11px; color: var(--text-muted); margin-top: 4px;">
            CDAC Emergency Priority Gateway with encrypted live telemetry link for trusted family contacts.
          </p>
          <div style="background: rgba(0,0,0,0.5); padding: 6px 8px; border-radius: 4px; font-family: var(--font-mono); font-size: 10px; color: var(--text-dim); margin-top: 6px;">
            Endpoint: POST /trai-dlt/v3/sms-priority<br>
            Payload: ${stubs.smsGateway.lastPayload ? JSON.stringify(stubs.smsGateway.lastPayload).slice(0, 48) + '...' : 'Idle (Standby)'}
          </div>
        </div>
      </div>
    `;
  }
}

window.cascadeManager = new ResponseCascadeManager();
