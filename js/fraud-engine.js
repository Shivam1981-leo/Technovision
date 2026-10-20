// Sangini AI - Real-Time Fraud Detection & Adaptive Trust Engine
// Implements Multi-Signal Machine Learning Scoring, Anti-Luring Safeguards, and Post-Alert Classification

class FraudDetectionEngine {
  constructor() {
    this.modelWeights = {
      accountAge: 0.20,
      verificationLevel: 0.25,
      alertHistory: 0.15,
      deviceRisk: 0.20,
      locationIsolation: 0.10,
      areaCrimeContext: 0.10
    };
  }

  // Phase 1: Pre-Alert Verification
  evaluate(signals) {
    let score = 0.08; // Prior risk baseline
    const factorBreakdown = [];

    // 1. Account Age
    if (signals.accountAge < 3) {
      score += 0.28;
      factorBreakdown.push({ name: "Account Age (<3 days)", delta: "+0.28", type: "risk" });
    } else if (signals.accountAge < 14) {
      score += 0.15;
      factorBreakdown.push({ name: "Account Age (New user)", delta: "+0.15", type: "risk" });
    } else if (signals.accountAge > 60) {
      score -= 0.06;
      factorBreakdown.push({ name: "Account Maturity (>60 days)", delta: "-0.06", type: "trust" });
    }

    // 2. KYC Verification Level
    if (signals.verificationLevel === 'aadhaar_biometric') {
      score -= 0.18;
      factorBreakdown.push({ name: "Govt Aadhaar Biometric KYC", delta: "-0.18", type: "trust" });
    } else if (signals.verificationLevel === 'video_selfie') {
      score -= 0.10;
      factorBreakdown.push({ name: "Video Selfie Verified", delta: "-0.10", type: "trust" });
    } else if (signals.verificationLevel === 'unverified') {
      score += 0.25;
      factorBreakdown.push({ name: "Unverified / Anonymous User", delta: "+0.25", type: "risk" });
    }

    // 3. User Alert & False Alarm History
    if (signals.cancelledAlerts > 2) {
      score += 0.22;
      factorBreakdown.push({ name: `Multiple Prior False Alarms (${signals.cancelledAlerts})`, delta: "+0.22", type: "risk" });
    }
    if (signals.alertHistory > 3 && signals.cancelledAlerts === 0) {
      score -= 0.08;
      factorBreakdown.push({ name: "Prior Genuine Alerts Track Record", delta: "-0.08", type: "trust" });
    }

    // 4. Device Integrity & Anomaly Signals
    if (signals.rootedDevice) {
      score += 0.35;
      factorBreakdown.push({ name: "Rooted / Jailbroken OS Detected", delta: "+0.35", type: "critical_risk" });
    }
    if (signals.vpnDetection) {
      score += 0.20;
      factorBreakdown.push({ name: "Active Anonymous VPN Detected", delta: "+0.20", type: "risk" });
    }
    if (signals.isUsualArea) {
      score -= 0.04;
      factorBreakdown.push({ name: "Recognized Daily Geo-Fence", delta: "-0.04", type: "trust" });
    } else {
      score += 0.06;
      factorBreakdown.push({ name: "Unfamiliar Location Boundary", delta: "+0.06", type: "neutral" });
    }

    // 5. Environmental & Area Risk Context
    if (signals.areaRisk === 'high') {
      score -= 0.06; // Plausible in known danger zone
      factorBreakdown.push({ name: "High-Crime Historical Zone (Plausible)", delta: "-0.06", type: "trust" });
    }
    if (signals.isIsolated) {
      score += 0.14;
      factorBreakdown.push({ name: "Isolated Alleyway / Blind Spot", delta: "+0.14", type: "risk" });
    }

    // Clamp between 0.01 and 0.99
    score = Math.max(0.01, Math.min(0.99, parseFloat(score.toFixed(2))));

    // Determine Action Recommendation based on 4-tier thresholds
    let recommendation = 'IMMEDIATE_BROADCAST';
    let rationale = '';

    if (score < 0.20) {
      recommendation = 'IMMEDIATE_BROADCAST';
      rationale = 'Ultra-low fraud probability. 90/10 rule applied: prioritize speed, alert all verified women in 200m radius instantly.';
    } else if (score < 0.50) {
      recommendation = 'SEND_TO_VERIFIED_RESPONDERS';
      rationale = 'Moderate risk tier. Broadcast restricted exclusively to background-checked veteran responders and female security.';
    } else if (score < 0.70) {
      recommendation = 'VOICE_VERIFICATION_FIRST';
      rationale = 'Elevated anomaly index. Dispatches automated IVR voice check to confirm alert validity within 25 seconds before public ping.';
    } else {
      recommendation = 'HOLD_FOR_MANUAL_REVIEW';
      rationale = 'Extreme anomaly / fraud signal. Pauses public broadcast; alert routed instantly to human NGO dispatch operator.';
    }

    // Anti-Luring Protocol (Special rule for responder safety)
    const antiLuringTriggered = signals.isIsolated && (signals.accountAge < 14 || signals.verificationLevel === 'unverified');
    const antiLuringProtocols = antiLuringTriggered ? [
      "Send alert to Police 112 interceptors first",
      "Mandate paired female responders (Never dispatch solo responder)",
      "Require victim challenge verification before physical approach"
    ] : [];

    return {
      fraudScore: score,
      recommendation,
      rationale,
      factorBreakdown,
      antiLuringTriggered,
      antiLuringProtocols,
      confidence: +(0.87 + (1 - Math.abs(0.5 - score)) * 0.1).toFixed(2),
      timestamp: new Date().toLocaleTimeString()
    };
  }

  // Phase 2: Responder Cross-Check Verification
  crossCheckArrivals(reports) {
    const total = reports.length;
    if (total === 0) return { status: 'PENDING_ARRIVAL', consensus: false };

    const confirmed = reports.filter(r => r.observation === 'victim_confirmed_needs_help').length;
    const nobodyHere = reports.filter(r => r.observation === 'nobody_here').length;

    if (confirmed >= 2) {
      return {
        status: 'VERIFIED_GENUINE',
        consensus: true,
        action: 'Lock alert in verified status, coordinate safe escort, store evidence.'
      };
    } else if (nobodyHere >= 2) {
      return {
        status: 'FALSE_ALARM_CONFIRMED',
        consensus: true,
        action: 'Flag account for false alarm strike, cancel cascade, debrief responders.'
      };
    } else if (confirmed >= 1 && nobodyHere >= 1) {
      return {
        status: 'CONFLICTING_REPORTS',
        consensus: false,
        action: 'Escalate to human supervisor; dispatch third backup responder.'
      };
    } else {
      return {
        status: 'PARTIAL_ARRIVAL',
        consensus: false,
        action: 'First responder on scene. Awaiting partner arrival confirmation.'
      };
    }
  }

  // Phase 4: Penalty Ladder & Progressive Consequences
  getPenaltyForOffense(offenseCount, isMalicious = false) {
    if (isMalicious) {
      return {
        tier: "LEGAL_ACTION",
        action: "Immediate Permanent Ban + Police FIR under IPC 182 / BNS (False Emergency Signal)",
        probationDays: 9999
      };
    }
    switch (offenseCount) {
      case 1:
        return {
          tier: "WARNING",
          action: "Educational Warning Popup + 24hr Cool-off (Presumes accidental trigger)",
          probationDays: 1
        };
      case 2:
        return {
          tier: "PROBATION",
          action: "7-Day Probation (All future triggers require mandatory IVR call verification)",
          probationDays: 7
        };
      case 3:
        return {
          tier: "SUSPENSION",
          action: "30-Day Account Suspension + Mandatory Safety Re-training Module",
          probationDays: 30
        };
      case 4:
      default:
        return {
          tier: "PERMANENT_BAN",
          action: "Permanent Network Blacklist + Legal Notice for emergency bandwidth obstruction",
          probationDays: 3650
        };
    }
  }
}

window.fraudEngine = new FraudDetectionEngine();
