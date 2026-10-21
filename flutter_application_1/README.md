# 📱 Sangini AI (संगिनी) - Real Multi-Phone Peer-to-Peer Deployment Guide

> **Live Local Network Host IP**: `http://192.168.1.33:3000`  
> **Mobile App URL (Open on any phone)**: `http://192.168.1.33:3000/app`

---

## 🚀 How to Run on Real Phones & Test Live Multi-Device Communication

You can connect **2 or more real phones** (Android, iPhone, iPad, laptop) right now and watch them interact in real-time.

### Step 1: Connect to the Same Network
- Make sure all phones and this computer are connected to the **same Wi-Fi router** (or turn on **Mobile Hotspot** on one phone and connect the laptop to it).
- Computer IP address: `192.168.1.33`

---

### Step 2: Open the App on Phone 1 (Victim / Commuter)
1. On **Phone 1**, open Chrome or Safari and visit:
   ```
   http://192.168.1.33:3000/app
   ```
2. *(Optional)* Tap the browser menu (`⋮` or Share) and select **"Add to Home Screen"** or **"Install App"** to run it full-screen just like a native app.
3. Tap the **ID badge icon** in the top bar to set your name: e.g. `"Ananya (Phone 1)"`.

---

### Step 3: Open the App on Phone 2 (Responder / Helper)
1. On **Phone 2**, open Chrome or Safari and visit:
   ```
   http://192.168.1.33:3000/app
   ```
2. Tap the **ID badge icon** in the top bar to set your name: e.g. `"Priya (Responder - Phone 2)"`.

---

### Step 4: Verify Real-Time Peer Discovery
1. On both phones, tap the **Peer Radar** tab.
2. Watch the animated radar sweep:
   - **Phone 1** automatically sees **Phone 2 (Priya)** on its radar with live distance (e.g. `85m`) and battery percentage!
   - **Phone 2** automatically sees **Phone 1 (Ananya)** on its radar!
   - Heartbeats sync every 1.5 seconds through the central mesh server.

---

### Step 5: Test Real Cross-Phone SOS & Acceptance
1. On **Phone 1**:
   - Tap the large red **EMERGENCY SOS** panic button (or type `911=` in the stealth Calculator disguise).
   - Phone 1 enters distress mode and starts the **60-Second Auto-Escalation Countdown** (Code: `BLUE`).
2. On **Phone 2**:
   - **Within 1 second**, Phone 2's screen sounds and displays a high-priority red alert:
     > **🚨 REAL-TIME DISTRESS ALERT DETECTED!**  
     > *Incident INC-XXXX • Short Code: [BLUE] • Ananya (Phone 1) is in distress!*
   - Phone 2 has a large green button: **"Accept & Respond (OK)"**.
3. On **Phone 2**, tap **"Accept & Respond (OK)"**:
   - Phone 2 accepts the distress call using its verified ID.
   - **Instantly on Phone 1**:
     - The 60-second auto-escalation timer **HALTS**!
     - Phone 1's status updates: `"Incident accepted by Responder Priya (Phone 2) • En-Route (85m away)"`!
   - **On Phone 2**:
     - Status updates to `"You accepted the incident! Safe navigation beacon active."`

---

### Step 6: Test 60-Second Auto-Escalation
1. On **Phone 1**, trigger SOS again.
2. On **Phone 2**, do **not** accept for 60 seconds.
3. Watch the countdown timer reach `0s`:
   - Both phones will witness the automatic escalation to **Tier 2: Community Patrols, Pink Mobile Patrol & State Police 112 CAD**!
   - The append-only audit trail logs the escalation event with cryptographic signatures.

---

### Step 7: Test Home / Domestic Privacy Routing
1. On **Phone 1**, toggle the location mode to **"Home / Domestic"**.
2. Trigger the SOS.
3. Observe on **Phone 2**: The incident is strictly **HIDDEN from Phone 2's peer radar** to protect the victim's domestic privacy, and is routed confidentially directly to the **Women Helpline 181 Rapid Desk**.

---

## 📦 Native Android APK Status
The native Android build configuration with `android.permission.INTERNET`, `ACCESS_FINE_LOCATION`, and `android:usesCleartextTraffic="true"` is enabled in:
`android/app/src/main/AndroidManifest.xml`
Gradle is building the standalone APK in the background. Once finished, `app-debug.apk` will be in:
`build/app/outputs/flutter-apk/app-debug.apk`
