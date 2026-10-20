const express = require('express');
const cors = require('cors');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, '.')));

// In-memory state for demonstration
let activeAlerts = [
  {
    id: "ALT-8492",
    type: "street_harassment",
    title: "Street Harassment - Followed by Unknown Individual",
    victimName: "Ananya S. (Anonymous ID: #V-409)",
    locationName: "Near Metro Gate 3, Indiranagar, Bangalore",
    coords: { lat: 12.9784, lng: 77.6408 },
    timestamp: new Date().toISOString(),
    status: "active",
    tier: 1,
    timeRemainingTier1: 85, // seconds
    fraudScore: 0.12,
    recommendation: "IMMEDIATE_BROADCAST",
    respondersNotified: 4,
    respondersAccepted: 1,
    assignedResponders: [
      { id: "RES-102", name: "Pooja V. (Verified Female Commuter)", distance: "140m", eta: "1.8 min", status: "en_route", pairedWith: "RES-108" },
      { id: "RES-108", name: "Kavita M. (Opted-in Cafe Staff)", distance: "190m", eta: "2.3 min", status: "matching_pair", pairedWith: "RES-102" }
    ],
    secretCodePrompt: "What is your secret verification word?",
    secretCodeAnswer: "LOTUS",
    evidence: {
      audioRecorded: true,
      audioDuration: "00:42",
      fileHash: "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
      blockchainTx: "0x7f9a2b8e4c1d6a3f...verified",
      policeCellNotified: true
    }
  }
];

// Fraud Detection ML Logic
function calculateFraudScore(signals) {
  let score = 0.05; // Base prior

  // User Signals
  if (signals.accountAge < 7) score += 0.25;
  else if (signals.accountAge > 90) score -= 0.05;

  if (signals.verificationLevel === 'aadhaar_biometric') score -= 0.15;
  else if (signals.verificationLevel === 'video_selfie') score -= 0.08;
  else if (signals.verificationLevel === 'unverified') score += 0.30;

  if (signals.cancelledAlerts > 2) score += 0.20;
  if (signals.alertHistory > 5 && signals.cancelledAlerts === 0) score -= 0.10;

  // Behavioral & Device Signals
  if (signals.rooted) score += 0.35;
  if (signals.vpnActive) score += 0.20;
  if (!signals.isUsualArea) score += 0.08;

  // Contextual Signals
  if (signals.isIsolated) score += 0.15; // requires caution (anti-luring)
  if (signals.areaRisk === 'high') score -= 0.05; // High crime area makes alert more plausible

  // Clamp 0.0 to 0.99
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

// API: Trigger SOS
app.post('/api/sos-trigger', (req, res) => {
  const { type, triggerMethod, coords, disguiseMode, context, userSignals } = req.body;

  const fraudEval = calculateFraudScore(userSignals || {
    accountAge: 120,
    verificationLevel: 'aadhaar_biometric',
    cancelledAlerts: 0,
    alertHistory: 1,
    rooted: false,
    vpnActive: false,
    isUsualArea: true,
    isIsolated: false,
    areaRisk: 'medium'
  });

  const newAlert = {
    id: `ALT-${Math.floor(1000 + Math.random() * 9000)}`,
    type: type || 'street_harassment',
    triggerMethod: triggerMethod || 'panic_button',
    disguiseMode: disguiseMode || null,
    context: context || 'street',
    coords: coords || { lat: 12.9716, lng: 77.5946 },
    timestamp: new Date().toISOString(),
    status: 'active',
    tier: 1,
    timeRemainingTier1: 120,
    fraudScore: fraudEval.fraudScore,
    recommendation: fraudEval.recommendation,
    antiLuringRequired: fraudEval.antiLuringRequired,
    respondersNotified: fraudEval.recommendation === 'IMMEDIATE_BROADCAST' ? 6 : 2,
    respondersAccepted: 0,
    assignedResponders: [],
    evidence: {
      audioRecorded: true,
      audioDuration: "00:15",
      fileHash: "a4f89d" + Math.random().toString(16).substring(2, 10) + "8c41bf284",
      blockchainTx: "0x" + Math.random().toString(16).substring(2, 18) + "...anchored",
      policeCellNotified: true
    }
  };

  activeAlerts.unshift(newAlert);
  res.json({ success: true, alert: newAlert });
});

// API: Get Active Alerts
app.get('/api/active-alerts', (req, res) => {
  res.json({ success: true, alerts: activeAlerts });
});

// API: Responder Action (Accept / Walk / Police / Siren)
app.post('/api/responder-action', (req, res) => {
  const { alertId, action, responderId, responderName } = req.body;
  const alert = activeAlerts.find(a => a.id === alertId);

  if (!alert) {
    return res.status(404).json({ success: false, message: "Alert not found" });
  }

  if (action === 'accept_walk') {
    alert.respondersAccepted += 1;
    alert.assignedResponders.push({
      id: responderId || `RES-${Math.floor(100 + Math.random() * 900)}`,
      name: responderName || "Dr. Neha K. (Verified Responder)",
      distance: "160m",
      eta: "2.1 min",
      status: "en_route",
      pairedWith: alert.assignedResponders.length > 0 ? alert.assignedResponders[0].id : "Searching partner..."
    });
  } else if (action === 'escalate_police') {
    alert.tier = 3;
    alert.policeDispatched = true;
  }

  res.json({ success: true, alert });
});

// API: Verify Arrival (Cross Check)
app.post('/api/verify-crosscheck', (req, res) => {
  const { alertId, responderId, observation } = req.body;
  res.json({
    success: true,
    message: "Observation recorded.",
    crossCheckStatus: observation === 'victim_confirmed' ? 'VERIFIED_GENUINE' : 'FLAGGED_INSPECTION'
  });
});

// Fallback to index.html
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'index.html'));
});

app.listen(PORT, () => {
  console.log(`Shakti Mesh Safety Network running at http://localhost:${PORT}`);
});

module.exports = app;

