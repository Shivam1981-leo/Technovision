// Sangini AI - Tactical Live Map & Peer-to-Peer Mesh Visualizer
// Reacts dynamically to the Append-Only Incident Event Log:
// - Street Incidents: Display distress beacon, alert 200m peer mesh, pulse radar rings.
// - Home Incidents: Remain strictly HIDDEN from peer radar; displays discreet privacy shield.
// - Responders (e.g. R12) respond dynamically upon OK|<id>|<code> acceptance events.

class MeshTacticalMap {
  constructor(canvasId) {
    this.canvas = document.getElementById(canvasId);
    if (!this.canvas) return;
    this.ctx = this.canvas.getContext('2d');
    this.width = this.canvas.width = this.canvas.parentElement.clientWidth || 800;
    this.height = this.canvas.height = this.canvas.parentElement.clientHeight || 550;

    this.pulseRadius = 0;
    this.pulseAlpha = 1;
    this.isEnRoute = false;

    // Center Victim coordinates (in canvas space)
    this.center = { x: this.width * 0.48, y: this.height * 0.52 };

    // Scale factors: 200m ~ 135px radius, 1km ~ 330px radius
    this.r200m = 135;
    this.r1km = 330;

    // Responders data (including jury-targeted R12)
    this.responders = [
      {
        id: "R12",
        name: "Pooja V. (R12)",
        role: "Verified Commuter Responder",
        badge: "Aadhaar Biometric KYC",
        tier: 1,
        initialX: this.center.x - 90,
        initialY: this.center.y - 75,
        x: this.center.x - 90,
        y: this.center.y - 75,
        targetX: this.center.x - 18,
        targetY: this.center.y - 15,
        distMeters: 140,
        status: "available",
        color: "#00f0ff",
        icon: "👩"
      },
      {
        id: "RES-108",
        name: "Kavita M. (RES-108)",
        role: "Cafe Staff (Safe Haven)",
        badge: "Opted-in Shop",
        tier: 1,
        initialX: this.center.x + 85,
        initialY: this.center.y + 60,
        x: this.center.x + 85,
        y: this.center.y + 60,
        targetX: this.center.x + 15,
        targetY: this.center.y + 12,
        distMeters: 185,
        status: "available",
        color: "#00f0ff",
        icon: "👩‍💼"
      },
      {
        id: "RES-204",
        name: "Dr. Neha K. (RES-204)",
        role: "Trained NGO Responder",
        badge: "De-escalation Certified",
        tier: 2,
        initialX: this.center.x - 220,
        initialY: this.center.y + 140,
        x: this.center.x - 220,
        y: this.center.y + 140,
        targetX: this.center.x - 25,
        targetY: this.center.y + 20,
        distMeters: 560,
        status: "standby",
        color: "#ffb300",
        icon: "🎖️"
      },
      {
        id: "POLICE-112",
        name: "Patrol Unit 112",
        role: "Karnataka State Police Interceptor",
        badge: "Official CAD Dispatch",
        tier: 3,
        initialX: this.center.x + 280,
        initialY: this.center.y - 200,
        x: this.center.x + 280,
        y: this.center.y - 200,
        targetX: this.center.x + 35,
        targetY: this.center.y - 25,
        distMeters: 890,
        status: "standby",
        color: "#ff2d55",
        icon: "🚓"
      }
    ];

    this.selectedNode = null;
    this.currentIncident = null;

    this.bindEvents();
    this.subscribeToEventLog();
    this.animate();
  }

  // Subscribe directly to the Append-Only Incident Event Log
  subscribeToEventLog() {
    if (window.incidentEventLogManager) {
      window.incidentEventLogManager.subscribe((incident, event) => {
        this.syncWithEventLog(incident, event);
      });
      // Initial sync
      const inc = window.incidentEventLogManager.getActiveIncident();
      if (inc) this.syncWithEventLog(inc, null);
    } else {
      setTimeout(() => this.subscribeToEventLog(), 200);
    }
  }

  syncWithEventLog(incident, event) {
    this.currentIncident = incident;

    if (!incident || incident.status === 'idle') {
      this.resetPositions();
      this.updateHudLegend(null);
      return;
    }

    // Check if incident was accepted
    const hasAccepted = incident.events && incident.events.some(e => e.type === 'Accepted');
    if (hasAccepted) {
      const acceptEvt = incident.events.find(e => e.type === 'Accepted');
      const respId = acceptEvt.responderId || 'R12';
      this.markResponderAccepted(respId);
    } else if (incident.status === 'escalated') {
      // Escalated to Tier 2 / 3
      this.markEscalated(incident.tier);
    } else if (incident.status === 'active') {
      // Reset responders to available if fresh active
      if (!this.isEnRoute) {
        for (const r of this.responders) {
          if (r.tier === 1) r.status = "available";
        }
      }
    }

    this.updateHudLegend(incident);
  }

  markResponderAccepted(responderId) {
    this.isEnRoute = true;
    let targetResponder = this.responders.find(r => r.id === responderId);

    // If R12 wasn't already in list, map it or create it
    if (!targetResponder) {
      targetResponder = {
        id: responderId,
        name: `Responder ${responderId} (Verified)`,
        role: "Accepted Peer Volunteer",
        badge: "Verified Short Code OK",
        tier: 1,
        initialX: this.center.x - 70,
        initialY: this.center.y - 80,
        x: this.center.x - 70,
        y: this.center.y - 80,
        targetX: this.center.x - 15,
        targetY: this.center.y - 10,
        distMeters: 120,
        status: "en_route",
        color: "#00e676",
        icon: "👩"
      };
      this.responders.unshift(targetResponder);
    } else {
      targetResponder.status = "en_route";
      targetResponder.color = "#00e676"; // turns safe green
      targetResponder.name = `${targetResponder.name.split(' (')[0]} (${responderId} Accepted)`;
    }

    // Also auto-pair with second responder for anti-luring safety rule
    const pair = this.responders.find(r => r.id === 'RES-108' && r.id !== responderId);
    if (pair) pair.status = "en_route";
  }

  markEscalated(tier) {
    if (tier >= 2) {
      const ngo = this.responders.find(r => r.id === 'RES-204');
      if (ngo) ngo.status = "en_route";
    }
    if (tier >= 3) {
      const police = this.responders.find(r => r.id === 'POLICE-112');
      if (police) police.status = "en_route";
    }
  }

  updateHudLegend(incident) {
    const hud = document.querySelector('.map-hud-overlay');
    if (!hud) return;

    if (!incident || incident.status === 'idle') {
      hud.innerHTML = `
        <div style="font-weight: 700; color: #fff;">TACTICAL P2P MESH INTERCEPTOR</div>
        <div style="font-size: 11px; color: var(--safe-green); margin-top: 4px;">● RADAR STANDBY • SCANNING 200M MESH</div>
        <div class="map-hud-legend">
          <div class="legend-item"><span class="legend-bullet cyan"></span> 200m Commuters</div>
          <div class="legend-item"><span class="legend-bullet amber"></span> 1km Patrols</div>
        </div>
      `;
      return;
    }

    if (incident.context === 'home' || !incident.peerRadarVisible) {
      hud.innerHTML = `
        <div style="font-weight: 700; color: #fff;">TACTICAL P2P MESH INTERCEPTOR</div>
        <div style="font-size: 11px; color: var(--neon-magenta); font-weight: 700; margin-top: 4px;">
          🔒 DISCREET HOME PROTOCOL: BEACON HIDDEN FROM PEER RADAR
        </div>
        <p style="font-size: 10px; color: var(--text-dim); margin-top: 2px;">
          Zero public broadcast. Routed privately to verified counselor to prevent retaliation.
        </p>
      `;
    } else {
      hud.innerHTML = `
        <div style="font-weight: 700; color: #fff;">TACTICAL P2P MESH INTERCEPTOR</div>
        <div style="font-size: 11px; color: var(--emergency-red); font-weight: 700; margin-top: 4px;">
          🚨 STREET HARASSMENT DISTRESS BEACON BROADCASTING
        </div>
        <div style="font-size: 10px; color: var(--neon-cyan); margin-top: 2px;">
          Coords: ${incident.coords.lat.toFixed(4)}, ${incident.coords.lon.toFixed(4)} • Short Code: ${incident.shortCode}
        </div>
        <div class="map-hud-legend" style="margin-top: 6px;">
          <div class="legend-item"><span class="legend-bullet red"></span> Victim SOS (${incident.id})</div>
          <div class="legend-item"><span class="legend-bullet cyan"></span> 200m Peer Mesh</div>
          <div class="legend-item"><span class="legend-bullet green"></span> Accepted (R12)</div>
        </div>
      `;
    }
  }

  resize() {
    if (!this.canvas) return;
    this.width = this.canvas.width = this.canvas.parentElement.clientWidth || 800;
    this.height = this.canvas.height = this.canvas.parentElement.clientHeight || 550;
    this.center = { x: this.width * 0.48, y: this.height * 0.52 };
  }

  bindEvents() {
    window.addEventListener('resize', () => this.resize());

    this.canvas.addEventListener('mousemove', (e) => {
      const rect = this.canvas.getBoundingClientRect();
      const mouseX = e.clientX - rect.left;
      const mouseY = e.clientY - rect.top;

      let found = null;
      const inc = this.currentIncident;
      const isVisibleOnRadar = inc && inc.peerRadarVisible && inc.context !== 'home';

      // Check victim center (only if visible on radar!)
      if (isVisibleOnRadar) {
        const dV = Math.hypot(mouseX - this.center.x, mouseY - this.center.y);
        if (dV < 24) {
          found = {
            name: `Victim SOS (${inc.id})`,
            role: `Active Context: ${inc.context.toUpperCase()}`,
            type: "victim",
            coords: inc.coords,
            shortCode: inc.shortCode,
            status: inc.status
          };
        }
      }

      if (!found) {
        // Check responders
        for (const res of this.responders) {
          const dR = Math.hypot(mouseX - res.x, mouseY - res.y);
          if (dR < 20) {
            found = res;
            break;
          }
        }
      }
      this.selectedNode = found;
      this.canvas.style.cursor = found ? 'pointer' : 'default';
    });

    this.canvas.addEventListener('click', () => {
      if (this.selectedNode && window.onMapNodeClicked) {
        window.onMapNodeClicked(this.selectedNode);
      }
    });
  }

  startEnRouteAnimation() {
    this.isEnRoute = true;
    for (const r of this.responders) {
      if (r.tier <= 2) {
        r.status = "en_route";
      }
    }
  }

  resetPositions() {
    this.isEnRoute = false;
    for (const r of this.responders) {
      r.x = r.initialX;
      r.y = r.initialY;
      r.status = r.tier === 1 ? "available" : "standby";
      if (r.id === 'R12') r.color = "#00f0ff";
    }
  }

  drawGrid() {
    const ctx = this.ctx;
    ctx.fillStyle = "#070b14";
    ctx.fillRect(0, 0, this.width, this.height);

    // City grid roads
    ctx.lineWidth = 1;
    ctx.strokeStyle = "rgba(0, 240, 255, 0.05)";

    const step = 45;
    for (let x = 0; x < this.width; x += step) {
      ctx.beginPath();
      ctx.moveTo(x, 0);
      ctx.lineTo(x, this.height);
      ctx.stroke();
    }
    for (let y = 0; y < this.height; y += step) {
      ctx.beginPath();
      ctx.moveTo(0, y);
      ctx.lineTo(this.width, y);
      ctx.stroke();
    }

    // Major thoroughfares (Avenues)
    ctx.lineWidth = 3;
    ctx.strokeStyle = "rgba(0, 240, 255, 0.12)";

    ctx.beginPath();
    ctx.moveTo(0, this.center.y + 40);
    ctx.lineTo(this.width, this.center.y - 30);
    ctx.stroke();

    ctx.beginPath();
    ctx.moveTo(this.center.x - 70, 0);
    ctx.lineTo(this.center.x + 50, this.height);
    ctx.stroke();

    // Road Labels & City Coordinates
    ctx.fillStyle = "rgba(160, 195, 230, 0.35)";
    ctx.font = "10px Outfit, sans-serif";
    const inc = this.currentIncident;
    const latStr = inc ? `${inc.coords.lat.toFixed(4)}° N` : "18.5204° N";
    const lonStr = inc ? `${inc.coords.lon.toFixed(4)}° E` : "73.8567° E";
    ctx.fillText(`SECTOR GRID: [${latStr}, ${lonStr}]`, this.center.x - 180, this.center.y + 35);
    ctx.fillText("PEER SAFETY MESH CORRIDOR", this.center.x + 60, this.center.y - 140);
  }

  drawPerimeters() {
    const ctx = this.ctx;
    const inc = this.currentIncident;
    const isHome = inc && (inc.context === 'home' || !inc.peerRadarVisible);

    // 1km Outer Ring (Tier 2 Volunteers)
    ctx.save();
    ctx.setLineDash([6, 8]);
    ctx.strokeStyle = isHome ? "rgba(148, 163, 184, 0.2)" : "rgba(255, 179, 0, 0.4)";
    ctx.lineWidth = 1.5;
    ctx.beginPath();
    ctx.arc(this.center.x, this.center.y, this.r1km, 0, Math.PI * 2);
    ctx.stroke();

    ctx.fillStyle = isHome ? "rgba(148, 163, 184, 0.4)" : "rgba(255, 179, 0, 0.7)";
    ctx.font = "11px Outfit, sans-serif";
    ctx.fillText("TIER 2 PERIMETER (1 KM - TRAINED VOLUNTEERS)", this.center.x - this.r1km + 15, this.center.y - 12);
    ctx.restore();

    // 200m Immediate Proximity Ring
    ctx.save();
    ctx.strokeStyle = isHome ? "rgba(224, 36, 195, 0.4)" : "rgba(0, 240, 255, 0.7)";
    ctx.lineWidth = 2;
    ctx.shadowColor = isHome ? "rgba(224, 36, 195, 0.3)" : "rgba(0, 240, 255, 0.6)";
    ctx.shadowBlur = 10;
    ctx.beginPath();
    ctx.arc(this.center.x, this.center.y, this.r200m, 0, Math.PI * 2);
    ctx.stroke();

    // Subtle glow fill inside 200m
    const grad = ctx.createRadialGradient(this.center.x, this.center.y, 10, this.center.x, this.center.y, this.r200m);
    if (isHome) {
      grad.addColorStop(0, "rgba(224, 36, 195, 0.08)");
      grad.addColorStop(1, "rgba(224, 36, 195, 0.01)");
    } else {
      grad.addColorStop(0, "rgba(255, 45, 85, 0.12)");
      grad.addColorStop(0.7, "rgba(224, 36, 195, 0.05)");
      grad.addColorStop(1, "rgba(0, 240, 255, 0.02)");
    }
    ctx.fillStyle = grad;
    ctx.fill();

    ctx.fillStyle = isHome ? "#e024c3" : "#00f0ff";
    ctx.font = "bold 11px Outfit, sans-serif";
    ctx.fillText(isHome ? "TIER 1 (CONFIDENTIAL ZONE - PEER RADAR BLOCKED)" : "TIER 1 MESH (200m PROXIMITY PEERS)", this.center.x - this.r200m + 12, this.center.y + this.r200m - 12);
    ctx.restore();

    // Dynamic Pulsing Ripple Waves (Only for street / visible radar alerts!)
    if (!isHome && inc && inc.status !== 'idle') {
      this.pulseRadius += 1.2;
      this.pulseAlpha -= 0.008;
      if (this.pulseRadius > this.r200m || this.pulseAlpha <= 0) {
        this.pulseRadius = 15;
        this.pulseAlpha = 0.9;
      }

      ctx.save();
      ctx.strokeStyle = `rgba(255, 45, 85, ${this.pulseAlpha})`;
      ctx.lineWidth = 2;
      ctx.beginPath();
      ctx.arc(this.center.x, this.center.y, this.pulseRadius, 0, Math.PI * 2);
      ctx.stroke();

      const p2Radius = (this.pulseRadius + 60) % this.r200m;
      const p2Alpha = Math.max(0, 1 - (p2Radius / this.r200m));
      ctx.strokeStyle = `rgba(224, 36, 195, ${p2Alpha * 0.7})`;
      ctx.beginPath();
      ctx.arc(this.center.x, this.center.y, p2Radius, 0, Math.PI * 2);
      ctx.stroke();
      ctx.restore();
    }
  }

  // Draw Victim Beacon OR Discreet Home Privacy Shield
  drawVictimBeacon() {
    const ctx = this.ctx;
    const { x, y } = this.center;
    const inc = this.currentIncident;

    // CASE 1: HOME INCIDENT - MUST REMAIN HIDDEN FROM PEER RADAR!
    if (inc && (inc.context === 'home' || !inc.peerRadarVisible)) {
      ctx.save();
      // Draw discreet privacy shield box in center instead of victim distress beacon
      ctx.fillStyle = "rgba(14, 21, 38, 0.92)";
      ctx.strokeStyle = "rgba(224, 36, 195, 0.7)";
      ctx.lineWidth = 1.5;
      ctx.shadowColor = "rgba(224, 36, 195, 0.4)";
      ctx.shadowBlur = 15;

      const boxW = 280;
      const boxH = 64;
      ctx.beginPath();
      ctx.roundRect(x - boxW / 2, y - boxH / 2, boxW, boxH, 10);
      ctx.fill();
      ctx.stroke();

      // Lock icon + Privacy text
      ctx.fillStyle = "#e024c3";
      ctx.font = "bold 12px Plus Jakarta Sans, sans-serif";
      ctx.fillText("🔒 DISCREET HOME PROTOCOL ACTIVE", x - boxW / 2 + 16, y - 8);

      ctx.fillStyle = "#94a3b8";
      ctx.font = "10px Outfit, sans-serif";
      ctx.fillText("Hidden from Peer Radar • Counselor Direct Route", x - boxW / 2 + 16, y + 8);
      ctx.fillText(`Protected Coordinates: [${inc.coords.lat.toFixed(4)}, ${inc.coords.lon.toFixed(4)}]`, x - boxW / 2 + 16, y + 22);

      ctx.restore();
      return;
    }

    // CASE 2: STREET INCIDENT - APPEARS ON THE RESPONDER RADAR!
    if (inc && inc.peerRadarVisible && inc.status !== 'idle') {
      ctx.save();
      ctx.shadowColor = "#ff2d55";
      ctx.shadowBlur = 24;

      ctx.fillStyle = "#ff2d55";
      ctx.beginPath();
      ctx.arc(x, y, 14, 0, Math.PI * 2);
      ctx.fill();

      // Inner bright pulsing core
      ctx.fillStyle = "#ffffff";
      ctx.beginPath();
      ctx.arc(x, y, 6, 0, Math.PI * 2);
      ctx.fill();
      ctx.restore();

      // Beacon Pin Flag & Location
      ctx.fillStyle = "#ffffff";
      ctx.font = "bold 12px Plus Jakarta Sans, sans-serif";
      ctx.fillText(`📍 VICTIM SOS (${inc.id})`, x - 55, y - 24);

      ctx.fillStyle = "#ff2d55";
      ctx.font = "bold 10px Outfit, sans-serif";
      ctx.fillText(`Street Harassment Alert (${inc.coords.lat.toFixed(4)}, ${inc.coords.lon.toFixed(4)})`, x - 55, y - 10);

      // Short Code Prompt badge
      ctx.fillStyle = "#00f0ff";
      ctx.font = "9px JetBrains Mono, monospace";
      ctx.fillText(`Acceptance Code: [${inc.shortCode}]`, x - 55, y + 26);
      return;
    }

    // CASE 3: Standby state (no active distress)
    ctx.save();
    ctx.fillStyle = "rgba(0, 240, 255, 0.4)";
    ctx.beginPath();
    ctx.arc(x, y, 6, 0, Math.PI * 2);
    ctx.fill();
    ctx.fillStyle = "rgba(148, 163, 184, 0.6)";
    ctx.font = "10px Outfit, sans-serif";
    ctx.fillText("● Mesh Center Lock", x - 45, y - 12);
    ctx.restore();
  }

  drawResponders() {
    const ctx = this.ctx;
    const inc = this.currentIncident;
    const isHome = inc && (inc.context === 'home' || !inc.peerRadarVisible);

    for (const r of this.responders) {
      // If home incident, commuters are not called, stay in patrol/standby
      if (isHome && r.tier === 1) {
        r.status = "standby";
      }

      // Update movement if en route
      if (this.isEnRoute && r.status === "en_route") {
        const dx = r.targetX - r.x;
        const dy = r.targetY - r.y;
        const dist = Math.hypot(dx, dy);

        if (dist > 3) {
          r.x += (dx / dist) * 0.45;
          r.y += (dy / dist) * 0.45;
          r.distMeters = Math.max(12, Math.round(dist * 1.3));
        } else {
          r.status = "arrived";
          r.distMeters = 5;
        }

        // Draw dotted trail towards victim target
        ctx.save();
        ctx.setLineDash([4, 4]);
        ctx.strokeStyle = r.color || "rgba(0, 240, 255, 0.45)";
        ctx.lineWidth = 1.8;
        ctx.beginPath();
        ctx.moveTo(r.x, r.y);
        ctx.lineTo(this.center.x, this.center.y);
        ctx.stroke();
        ctx.restore();
      }

      // Draw Responder Node
      ctx.save();
      ctx.shadowColor = r.color;
      ctx.shadowBlur = (r.status === "en_route" || r.status === "arrived") ? 20 : 10;

      ctx.fillStyle = r.color;
      ctx.beginPath();
      ctx.arc(r.x, r.y, 11, 0, Math.PI * 2);
      ctx.fill();

      // White inner ring
      ctx.strokeStyle = "#ffffff";
      ctx.lineWidth = 1.5;
      ctx.stroke();
      ctx.restore();

      // Label & Status
      ctx.fillStyle = "#ffffff";
      ctx.font = "bold 11px Plus Jakarta Sans, sans-serif";
      ctx.fillText(r.name, r.x + 15, r.y - 2);

      ctx.fillStyle = r.color;
      ctx.font = "9px Outfit, sans-serif";
      let statusText = `${r.distMeters}m • ${r.role}`;
      if (r.status === "en_route") statusText = `🚶‍♀️ En Route (${r.distMeters}m)`;
      else if (r.status === "arrived") statusText = `✓ Arrived at Scene`;
      else if (isHome) statusText = `Patrol Standby (Private Route Active)`;
      ctx.fillText(statusText, r.x + 15, r.y + 11);
    }
  }

  drawTooltip() {
    if (!this.selectedNode) return;
    const ctx = this.ctx;
    const n = this.selectedNode;

    const x = Math.min(this.width - 240, (n.x || this.center.x) + 20);
    const y = Math.max(20, (n.y || this.center.y) - 30);

    ctx.save();
    ctx.fillStyle = "rgba(11, 15, 25, 0.94)";
    ctx.strokeStyle = n.color || "#00f0ff";
    ctx.lineWidth = 1.5;
    ctx.shadowColor = "rgba(0,0,0,0.8)";
    ctx.shadowBlur = 12;

    ctx.beginPath();
    ctx.roundRect(x, y, 220, 75, 8);
    ctx.fill();
    ctx.stroke();

    ctx.fillStyle = "#ffffff";
    ctx.font = "bold 12px Plus Jakarta Sans, sans-serif";
    ctx.fillText(n.name, x + 12, y + 20);

    ctx.fillStyle = n.color || "#00f0ff";
    ctx.font = "10px Outfit, sans-serif";
    ctx.fillText(n.role || "Peer Mesh Node", x + 12, y + 36);

    ctx.fillStyle = "#94a3b8";
    ctx.font = "9px Outfit, sans-serif";
    if (n.type === "victim") {
      ctx.fillText(`GPS: ${n.coords.lat.toFixed(4)}, ${n.coords.lon.toFixed(4)}`, x + 12, y + 52);
      ctx.fillText(`Verification Code: ${n.shortCode}`, x + 12, y + 66);
    } else {
      ctx.fillText(n.badge ? `KYC: ${n.badge}` : `Distance: ${n.distMeters}m`, x + 12, y + 52);
      ctx.fillText(`Status: ${n.status.toUpperCase()}`, x + 12, y + 66);
    }
    ctx.restore();
  }

  animate() {
    this.ctx.clearRect(0, 0, this.width, this.height);
    this.drawGrid();
    this.drawPerimeters();
    this.drawVictimBeacon();
    this.drawResponders();
    this.drawTooltip();
    requestAnimationFrame(() => this.animate());
  }
}

window.MeshTacticalMap = MeshTacticalMap;
