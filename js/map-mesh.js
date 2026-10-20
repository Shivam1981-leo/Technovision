// Shakti Mesh - Tactical Live Map & Peer-to-Peer Mesh Visualizer
// Renders 60 FPS animated radar rings, street grid, victim distress beacon, and live moving female responders.

class MeshTacticalMap {
  constructor(canvasId) {
    this.canvas = document.getElementById(canvasId);
    if (!this.canvas) return;
    this.ctx = this.canvas.getContext('2d');
    this.width = this.canvas.width = this.canvas.parentElement.clientWidth || 800;
    this.height = this.canvas.height = this.canvas.parentElement.clientHeight || 550;

    this.pulseRadius = 0;
    this.pulseAlpha = 1;
    this.zoom = 1;
    this.isEnRoute = false;

    // Center Victim coordinates (in canvas space)
    this.center = { x: this.width * 0.48, y: this.height * 0.52 };

    // Scale factors: 200m ~ 130px radius, 1km ~ 320px radius
    this.r200m = 135;
    this.r1km = 330;

    // Responders data
    this.responders = [
      {
        id: "RES-102",
        name: "Pooja V.",
        role: "Verified Commuter",
        badge: "Aadhaar Verified",
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
        name: "Kavita M.",
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
        name: "Dr. Neha K.",
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
        badge: "Official Dispatch",
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
    this.bindEvents();
    this.animate();
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
      // Check victim center
      const dV = Math.hypot(mouseX - this.center.x, mouseY - this.center.y);
      if (dV < 24) {
        found = { name: "Ananya S. (#V-409)", role: "Distress SOS Active", type: "victim" };
      } else {
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

    this.canvas.addEventListener('click', (e) => {
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

    // Main Avenue 1 (Diagonal / Horizontal)
    ctx.beginPath();
    ctx.moveTo(0, this.center.y + 40);
    ctx.lineTo(this.width, this.center.y - 30);
    ctx.stroke();

    // Cross Avenue 2
    ctx.beginPath();
    ctx.moveTo(this.center.x - 70, 0);
    ctx.lineTo(this.center.x + 50, this.height);
    ctx.stroke();

    // Road Labels
    ctx.fillStyle = "rgba(160, 195, 230, 0.35)";
    ctx.font = "10px Outfit, sans-serif";
    ctx.fillText("100 FT ROAD / METRO CORRIDOR", this.center.x - 180, this.center.y + 35);
    ctx.fillText("INDIRANAGAR 12TH MAIN", this.center.x + 60, this.center.y - 140);
  }

  drawPerimeters() {
    const ctx = this.ctx;

    // 1km Outer Ring (Tier 2 Volunteers)
    ctx.save();
    ctx.setLineDash([6, 8]);
    ctx.strokeStyle = "rgba(255, 179, 0, 0.4)";
    ctx.lineWidth = 1.5;
    ctx.beginPath();
    ctx.arc(this.center.x, this.center.y, this.r1km, 0, Math.PI * 2);
    ctx.stroke();

    ctx.fillStyle = "rgba(255, 179, 0, 0.7)";
    ctx.font = "11px Outfit, sans-serif";
    ctx.fillText("TIER 2 PERIMETER (1 KM - TRAINED VOLUNTEERS)", this.center.x - this.r1km + 15, this.center.y - 12);
    ctx.restore();

    // 200m Immediate Proximity Ring (Tier 1 Verified Women)
    ctx.save();
    ctx.strokeStyle = "rgba(0, 240, 255, 0.7)";
    ctx.lineWidth = 2;
    ctx.shadowColor = "rgba(0, 240, 255, 0.6)";
    ctx.shadowBlur = 10;
    ctx.beginPath();
    ctx.arc(this.center.x, this.center.y, this.r200m, 0, Math.PI * 2);
    ctx.stroke();

    // Subtle glow fill inside 200m
    const grad = ctx.createRadialGradient(this.center.x, this.center.y, 10, this.center.x, this.center.y, this.r200m);
    grad.addColorStop(0, "rgba(255, 45, 85, 0.12)");
    grad.addColorStop(0.7, "rgba(224, 36, 195, 0.05)");
    grad.addColorStop(1, "rgba(0, 240, 255, 0.02)");
    ctx.fillStyle = grad;
    ctx.fill();

    ctx.fillStyle = "#00f0ff";
    ctx.font = "bold 11px Outfit, sans-serif";
    ctx.fillText("TIER 1 MESH (200m PROXIMITY)", this.center.x - this.r200m + 12, this.center.y + this.r200m - 12);
    ctx.restore();

    // Dynamic Pulsing Ripple Waves from victim
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

    // Second offset pulse
    const p2Radius = (this.pulseRadius + 60) % this.r200m;
    const p2Alpha = Math.max(0, 1 - (p2Radius / this.r200m));
    ctx.strokeStyle = `rgba(224, 36, 195, ${p2Alpha * 0.7})`;
    ctx.beginPath();
    ctx.arc(this.center.x, this.center.y, p2Radius, 0, Math.PI * 2);
    ctx.stroke();
    ctx.restore();
  }

  drawVictimBeacon() {
    const ctx = this.ctx;
    const { x, y } = this.center;

    // Outer glow
    ctx.save();
    ctx.shadowColor = "#ff2d55";
    ctx.shadowBlur = 24;

    ctx.fillStyle = "#ff2d55";
    ctx.beginPath();
    ctx.arc(x, y, 14, 0, Math.PI * 2);
    ctx.fill();

    // Inner bright core
    ctx.fillStyle = "#ffffff";
    ctx.beginPath();
    ctx.arc(x, y, 6, 0, Math.PI * 2);
    ctx.fill();
    ctx.restore();

    // Beacon Pin Flag
    ctx.fillStyle = "#ffffff";
    ctx.font = "bold 12px Plus Jakarta Sans, sans-serif";
    ctx.fillText("📍 VICTIM SOS (#V-409)", x - 55, y - 22);

    ctx.fillStyle = "#ff2d55";
    ctx.font = "10px Outfit, sans-serif";
    ctx.fillText("Street Harassment Alert (0-2m)", x - 55, y - 8);
  }

  drawResponders() {
    const ctx = this.ctx;

    for (const r of this.responders) {
      // Update movement if en route
      if (this.isEnRoute && r.status === "en_route") {
        const dx = r.targetX - r.x;
        const dy = r.targetY - r.y;
        const dist = Math.hypot(dx, dy);

        if (dist > 2) {
          r.x += (dx / dist) * 0.45;
          r.y += (dy / dist) * 0.45;
          r.distMeters = Math.max(12, Math.round(dist * 1.3));
        } else {
          r.status = "arrived";
          r.distMeters = 5;
        }

        // Draw dotted trail towards target
        ctx.save();
        ctx.setLineDash([4, 4]);
        ctx.strokeStyle = "rgba(0, 240, 255, 0.45)";
        ctx.lineWidth = 1.5;
        ctx.beginPath();
        ctx.moveTo(r.x, r.y);
        ctx.lineTo(this.center.x, this.center.y);
        ctx.stroke();
        ctx.restore();
      }

      // Draw Responder Node
      ctx.save();
      ctx.shadowColor = r.color;
      ctx.shadowBlur = 14;

      ctx.fillStyle = r.color;
      ctx.beginPath();
      ctx.arc(r.x, r.y, 11, 0, Math.PI * 2);
      ctx.fill();

      // White inner ring
      ctx.strokeStyle = "#ffffff";
      ctx.lineWidth = 1.5;
      ctx.stroke();
      ctx.restore();

      // Label
      ctx.fillStyle = "#ffffff";
      ctx.font = "bold 11px Plus Jakarta Sans, sans-serif";
      ctx.fillText(r.name, r.x + 15, r.y - 2);

      ctx.fillStyle = r.color;
      ctx.font = "9px Outfit, sans-serif";
      const statusText = r.status === "en_route" ? `En Route (${r.distMeters}m)` : `${r.distMeters}m • ${r.role}`;
      ctx.fillText(statusText, r.x + 15, r.y + 11);
    }
  }

  drawTooltip() {
    if (!this.selectedNode) return;
    const ctx = this.ctx;
    const n = this.selectedNode;

    const x = Math.min(this.width - 220, (n.x || this.center.x) + 20);
    const y = Math.max(20, (n.y || this.center.y) - 30);

    ctx.save();
    ctx.fillStyle = "rgba(11, 15, 25, 0.92)";
    ctx.strokeStyle = "#00f0ff";
    ctx.lineWidth = 1.5;
    ctx.shadowColor = "rgba(0,0,0,0.8)";
    ctx.shadowBlur = 12;

    ctx.beginPath();
    ctx.roundRect(x, y, 200, 70, 8);
    ctx.fill();
    ctx.stroke();

    ctx.fillStyle = "#ffffff";
    ctx.font = "bold 12px Plus Jakarta Sans, sans-serif";
    ctx.fillText(n.name, x + 12, y + 22);

    ctx.fillStyle = "#00f0ff";
    ctx.font = "10px Outfit, sans-serif";
    ctx.fillText(n.role || "Mesh Node", x + 12, y + 38);

    ctx.fillStyle = "#a0c3e6";
    ctx.font = "9px Outfit, sans-serif";
    ctx.fillText(n.badge ? `Status: ${n.badge}` : "Distress Coordinates: 12.9784, 77.6408", x + 12, y + 54);
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
