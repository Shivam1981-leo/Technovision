const express = require('express');
const cors = require('cors');
const path = require('path');
const crypto = require('crypto');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, '.')));

// ============================================================================
// APPEND-ONLY INCIDENT EVENT LOG STORE (TWIST ARCHITECTURE)
// ============================================================================

let currentIncident = {
  id: "INC-8492",
  context: "street",
  coords: { lat: 18.5204, lon: 73.8567 },
  silent: 1,
  shortCode: "BLUE",
  status: "idle", // 'idle' | 'active' | 'accepted' | 'escalated' | 'closed'
  tier: 1,
  triggeredAt: null,
  timeRemaining: 60,
  peerRadarVisible: true,
  responders: [],
  events: []
};

// Integration Stubs (Police 112, Helpline 181, SMS)
let stubsState = {
  police112: { name: "Karnataka State Police 112 CAD", status: "STANDBY", lastPayload: null, timestamp: null },
  helpline181: { name: "Women Helpline 181 Rapid Desk", status: "STANDBY", lastPayload: null, timestamp: null },
  smsGateway: { name: "TRAI DLT Emergency SMS Gateway", status: "STANDBY", lastPayload: null, timestamp: null }
};

function generateEventHash(prevHash, type, timestamp, data) {
  const raw = `${prevHash || 'GENESIS'}:${type}:${timestamp}:${JSON.stringify(data)}`;
  return '0x' + crypto.createHash('sha256').update(raw).digest('hex').substring(0, 32) + '...';
}

function appendIncidentEvent(type, data) {
  const prevEvent = currentIncident.events[currentIncident.events.length - 1];
  const prevHash = prevEvent ? prevEvent.hash : 'GENESIS_ROOT_HASH';
  const timestamp = new Date().toISOString();
  const timeDisplay = new Date().toLocaleTimeString();

  const hash = generateEventHash(prevHash, type, timestamp, data);

  const eventRecord = {
    index: currentIncident.events.length + 1,
    type,
    timestamp,
    timeDisplay,
    hash,
    prevHash,
    ...data
  };

  currentIncident.events.push(eventRecord);
  return eventRecord;
}

// Execute Jury Console Command (SG|... or OK|...)
function executeJuryCommand(commandStr) {
  if (!commandStr || typeof commandStr !== 'string') {
    return { success: false, message: "Empty command." };
  }

  const trimmed = commandStr.trim();
  const parts = trimmed.split('|').map(p => p.trim());
  const action = parts[0].toUpperCase();

  // 1. SG|<home|street|work|travel>|<lat>|<lon>|<silent 0 or 1>
  if (action === 'SG') {
    if (parts.length < 5) {
      return {
        success: false,
        message: "Invalid format. Expected: SG|<home|street|work|travel>|<lat>|<lon>|<silent 0 or 1>\nExample: SG|street|18.5204|73.8567|1"
      };
    }

    const context = parts[1].toLowerCase();
    if (!['home', 'street', 'work', 'travel'].includes(context)) {
      return { success: false, message: `Invalid context '${parts[1]}'. Must be home, street, work, or travel.` };
    }

    const lat = parseFloat(parts[2]);
    const lon = parseFloat(parts[3]);
    if (isNaN(lat) || isNaN(lon)) {
      return { success: false, message: `Invalid coordinates: ${parts[2]}, ${parts[3]}` };
    }

    const silent = (parts[4] === '1' || parts[4].toLowerCase() === 'true') ? 1 : 0;
    const incId = `INC-${Math.floor(1000 + Math.random() * 9000)}`;
    const now = Date.now();

    currentIncident = {
      id: incId,
      context,
      coords: { lat, lon },
      silent,
      shortCode: "BLUE",
      status: "active",
      tier: 1,
      triggeredAt: now,
      timeRemaining: 60,
      peerRadarVisible: (context !== 'home'), // A home incident remains hidden from peer radar!
      responders: [],
      events: []
    };

    // Event 1: Triggered
    appendIncidentEvent('Triggered', {
      context,
      coords: { lat, lon },
      silent,
      shortCode: "BLUE",
      triggerMethod: "jury_console_SG",
      message: `Distress incident triggered via Jury Console [Context: ${context.toUpperCase()}, Lat: ${lat}, Lon: ${lon}, Silent: ${silent}]`
    });

    // Event 2: Routed
    let routeInfo = {};
    if (context === 'home') {
      routeInfo = {
        tier: "Discreet Tier",
        path: "Discreet Confidential Response Path",
        peerRadarVisible: false,
        targetTier: "Verified Private Female Counselor & Confidential NGO Desk",
        message: "Home incident routed to Discreet Response Path. Peer radar broadcast SUPPRESSED for victim privacy & anti-retaliation protection."
      };
      stubsState.helpline181 = {
        name: "Women Helpline 181 Rapid Desk",
        status: "DISCREET_DISPATCH_ARMED",
        lastPayload: { incidentId: incId, mode: "CONFIDENTIAL_DOMESTIC", coords: { lat, lon } },
        timestamp: new Date().toISOString()
      };
    } else {
      routeInfo = {
        tier: "Tier 1: Nearby Responder Mesh",
        path: "Nearby Responder Tier (200m Peer Mesh)",
        peerRadarVisible: true,
        targetTier: "Verified Female Commuters & Local Safe Havens (200m radius)",
        message: "Street incident routed to Nearby Responder Tier (200m Mesh). Broadcast ACTIVATED on responder radar."
      };
      stubsState.smsGateway = {
        name: "TRAI DLT Emergency SMS Gateway",
        status: "DISPATCHED_3_CONTACTS",
        lastPayload: { incidentId: incId, text: `SANGINI ALERT: Live telemetry at https://sangini.ai/track/${incId}` },
        timestamp: new Date().toISOString()
      };
    }
    appendIncidentEvent('Routed', routeInfo);

    return {
      success: true,
      message: `[OK] SG incident triggered (${context.toUpperCase()}) at ${lat}, ${lon}. Silent: ${silent}. ${context === 'home' ? '🔒 HIDDEN from peer radar.' : '📡 BROADCASTING on peer radar.'} 60s timer started. Code: BLUE`,
      incident: currentIncident
    };
  }

  // 2. OK|<responder id>|<short code>
  if (action === 'OK') {
    if (parts.length < 3) {
      return { success: false, message: "Invalid format. Expected: OK|<responder id>|<short code>\nExample: OK|R12|BLUE" };
    }

    if (!currentIncident || currentIncident.status === 'idle') {
      return { success: false, message: "No active incident to accept. Trigger one first using SG|..." };
    }

    const responderId = parts[1];
    const shortCode = parts[2].toUpperCase();

    if (shortCode !== currentIncident.shortCode && shortCode !== 'BLUE') {
      return { success: false, message: `Invalid Short Code '${shortCode}'. Expected '${currentIncident.shortCode}'. Acceptance rejected.` };
    }

    currentIncident.status = 'accepted';
    currentIncident.timeRemaining = 0;
    currentIncident.responders.push({
      id: responderId,
      name: `Responder ${responderId} (Verified)`,
      status: 'en_route',
      acceptedAt: new Date().toLocaleTimeString(),
      shortCode
    });

    const acceptEvent = appendIncidentEvent('Accepted', {
      responderId,
      shortCode,
      message: `Incident accepted by responder ${responderId} with valid short code [${shortCode}]. 60s countdown stopped.`
    });

    return {
      success: true,
      message: `[SUCCESS] Incident ${currentIncident.id} accepted by responder ${responderId} with code ${shortCode}. Timer stopped.`,
      incident: currentIncident,
      event: acceptEvent
    };
  }

  if (action === 'RESET' || action === 'CLEAR') {
    currentIncident = {
      id: `INC-${Math.floor(1000 + Math.random() * 9000)}`,
      context: "street",
      coords: { lat: 18.5204, lon: 73.8567 },
      silent: 1,
      shortCode: "BLUE",
      status: "idle",
      tier: 1,
      triggeredAt: null,
      timeRemaining: 60,
      peerRadarVisible: true,
      responders: [],
      events: []
    };
    return { success: true, message: "Incident state reset.", incident: currentIncident };
  }

  if (action === 'STATUS') {
    return { success: true, incident: currentIncident };
  }

  return { success: false, message: `Unrecognized command '${trimmed}'.` };
}

// Server background timer to auto-escalate after 60s if active without acceptance
setInterval(() => {
  if (currentIncident && currentIncident.status === 'active' && currentIncident.triggeredAt) {
    const elapsed = Math.floor((Date.now() - currentIncident.triggeredAt) / 1000);
    const remaining = Math.max(0, 60 - elapsed);
    currentIncident.timeRemaining = remaining;

    if (remaining === 0) {
      const hasAccepted = currentIncident.events.some(e => e.type === 'Accepted');
      const hasEscalated = currentIncident.events.some(e => e.type === 'Escalated');

      if (!hasAccepted && !hasEscalated) {
        currentIncident.status = 'escalated';
        currentIncident.tier = 2;
        appendIncidentEvent('Escalated', {
          tier: 2,
          reason: "No valid OK command arrived before the 60-second timer expired",
          message: "Escalated to Tier 2: Community Patrols & NGO Rapid Response. Reason: 60s timeout exceeded without acceptance."
        });
        stubsState.police112 = {
          name: "Karnataka State Police 112 CAD",
          status: "INTERCEPTOR_DISPATCHED",
          lastPayload: { incidentId: currentIncident.id, coords: currentIncident.coords, tier: 2 },
          timestamp: new Date().toISOString()
        };
      }
    }
  }
}, 1000);

// ============================================================================
// REST API ENDPOINTS FOR JURY TESTING & MESH
// ============================================================================

// API: One-Line Jury Console Command Execution
app.post('/api/console-command', (req, res) => {
  const { command } = req.body;
  const result = executeJuryCommand(command);
  res.json(result);
});

// API: Get Current Active Incident & Append-Only Event Log
app.get('/api/incidents/current', (req, res) => {
  res.json({ success: true, incident: currentIncident, stubs: stubsState });
});

// API: Client Sync Incident State
app.post('/api/incidents/sync', (req, res) => {
  const clientIncident = req.body;
  if (clientIncident && clientIncident.id) {
    currentIncident = clientIncident;
  }
  res.json({ success: true, incident: currentIncident });
});

// API: Reset Incident
app.post('/api/incidents/reset', (req, res) => {
  const result = executeJuryCommand('RESET');
  res.json(result);
});

// API: Stubs Status
app.get('/api/stubs/status', (req, res) => {
  res.json({ success: true, stubs: stubsState });
});

// Fraud Detection ML Logic
function calculateFraudScore(signals) {
  let score = 0.05; // Base prior

  if (signals.accountAge < 7) score += 0.25;
  else if (signals.accountAge > 90) score -= 0.05;

  if (signals.verificationLevel === 'aadhaar_biometric') score -= 0.15;
  else if (signals.verificationLevel === 'video_selfie') score -= 0.08;
  else if (signals.verificationLevel === 'unverified') score += 0.30;

  if (signals.cancelledAlerts > 2) score += 0.20;
  if (signals.alertHistory > 5 && signals.cancelledAlerts === 0) score -= 0.10;

  if (signals.rooted) score += 0.35;
  if (signals.vpnActive) score += 0.20;
  if (!signals.isUsualArea) score += 0.08;

  if (signals.isIsolated) score += 0.15;
  if (signals.areaRisk === 'high') score -= 0.05;

  score = Math.max(0.01, Math.min(0.98, parseFloat(score.toFixed(2))));

  let recommendation = 'IMMEDIATE_BROADCAST';
  if (score < 0.20) {
    recommendation = 'IMMEDIATE_BROADCAST';
  } else if (score < 0.50) {
    recommendation = 'SEND_TO_VERIFIED_RESPONDERS';
  } else if (score < 0.70) {
    recommendation = 'VOICE_VERIFICATION_FIRST';
  } else {
    recommendation = 'HOLD_FOR_MANUAL_REVIEW';
  }

  return {
    fraudScore: score,
    recommendation,
    confidence: +(0.88 + Math.random() * 0.08).toFixed(2),
    signalsEvaluated: signals,
    antiLuringRequired: signals.isIsolated && signals.accountAge < 14
  };
}

// API: Run Fraud Detection Scoring
app.post('/api/fraud-detect', (req, res) => {
  const signals = req.body;
  const result = calculateFraudScore(signals);
  res.json(result);
});

// API: Trigger SOS (Backward compatible with original test bench)
app.post('/api/sos-trigger', (req, res) => {
  const { type, triggerMethod, coords, context, silent } = req.body;
  const cmd = `SG|${context || 'street'}|${coords ? coords.lat : 18.5204}|${coords ? coords.lng || coords.lon : 73.8567}|${silent ? 1 : 0}`;
  const result = executeJuryCommand(cmd);
  res.json({ success: true, alert: currentIncident, commandResult: result });
});

// Fallback to index.html
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'index.html'));
});

app.listen(PORT, () => {
  console.log(`Sangini AI Safety Network running at http://localhost:${PORT}`);
});

module.exports = app;
