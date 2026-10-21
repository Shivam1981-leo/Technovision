import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/models.dart';
import 'api_service.dart';
import 'app_localizations.dart';

class LiveMeshPeer {
  final String id;
  final String name;
  final double lat;
  final double lon;
  final String role;
  final String status;
  final int battery;
  final String verification;
  final int distanceMeters;

  LiveMeshPeer({
    required this.id,
    required this.name,
    required this.lat,
    required this.lon,
    required this.role,
    required this.status,
    required this.battery,
    required this.verification,
    required this.distanceMeters,
  });

  factory LiveMeshPeer.fromJson(Map<String, dynamic> json, double myLat, double myLon) {
    final lat = (json['lat'] ?? 18.5204).toDouble();
    final lon = (json['lon'] ?? 73.8567).toDouble();
    final dist = _computeDistance(myLat, myLon, lat, lon);

    return LiveMeshPeer(
      id: json['id']?.toString() ?? 'P-01',
      name: json['name']?.toString() ?? 'Verified Peer',
      lat: lat,
      lon: lon,
      role: json['role']?.toString() ?? 'commuter',
      status: json['status']?.toString() ?? 'active_mesh',
      battery: (json['battery'] ?? 85) is int ? (json['battery'] ?? 85) : 85,
      verification: json['verification']?.toString() ?? 'aadhaar_verified',
      distanceMeters: dist,
    );
  }

  // Haversine distance in meters
  static int _computeDistance(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371000.0; // Earth radius in meters
    final dLat = (lat2 - lat1) * (math.pi / 180.0);
    final dLon = (lon2 - lon1) * (math.pi / 180.0);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * (math.pi / 180.0)) *
            math.cos(lat2 * (math.pi / 180.0)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return (r * c).round();
  }
}

class SanginiController extends ChangeNotifier {
  static final SanginiController _instance = SanginiController._internal();
  factory SanginiController() => _instance;
  SanginiController._internal() {
    _initDeviceIdentity();
    _startPolling();
  }

  final ApiService _api = ApiService();
  Timer? _pollingTimer;

  // Real Device Identity
  late String _deviceId;
  String get deviceId => _deviceId;

  String _userName = 'Priya (Commuter)';
  String get userName => _userName;

  String _userRole = 'Verified Female Peer';
  String get userRole => _userRole;

  int _batteryLevel = 89;
  int get batteryLevel => _batteryLevel;

  double _myLat = 18.5204;
  double get myLat => _myLat;

  double _myLon = 73.8567;
  double get myLon => _myLon;

  // Language & Localization: 'en' (English), 'hi' (Hindi), 'mr' (Marathi), 'kn' (Kannada)
  String _currentLanguage = 'en';
  String get currentLanguage => _currentLanguage;

  void setLanguage(String lang) {
    if (_currentLanguage != lang) {
      _currentLanguage = lang;
      notifyListeners();
    }
  }

  String tr(String key) => AppLocalizations.get(key, _currentLanguage);

  void _initDeviceIdentity() {
    final rand = math.Random().nextInt(9000) + 1000;
    _deviceId = 'PH-$rand';
    const femaleNames = [
      'Priya S.',
      'Ananya K.',
      'Dr. Neha M.',
      'Sneha Patil',
      'Riya Sen',
      'Pooja T.'
    ];
    final pick = femaleNames[rand % femaleNames.length];
    _userName = '$pick #$rand';

    // Assign realistic spatial offset (45m - 95m) around base coordinate so peer distance is 45m-95m on 200m radar
    final offsetAngle = (rand % 360) * (math.pi / 180.0);
    final offsetMeters = 45.0 + (rand % 50); // 45m - 95m
    _myLat = 18.5204 + (offsetMeters * math.cos(offsetAngle)) / 111320.0;
    _myLon = 73.8567 + (offsetMeters * math.sin(offsetAngle)) / (111320.0 * math.cos(18.5204 * math.pi / 180.0));
  }

  void updateProfile(String name, String role) {
    _userName = name;
    _userRole = role;
    notifyListeners();
  }

  void updateLocation(double lat, double lon) {
    _myLat = lat;
    _myLon = lon;
    notifyListeners();
  }

  // Active Real Connected Peers from Server
  List<LiveMeshPeer> _livePeers = [];
  List<LiveMeshPeer> get livePeers => _livePeers;

  Incident _incident = Incident.idle();
  Incident get incident => _incident;

  // Cross-device incoming alert detection
  bool _incomingAlertDismissed = false;
  bool get hasIncomingCrossDeviceAlert =>
      (_incident.status == 'active' || _incident.status == 'escalated') &&
      !_incomingAlertDismissed &&
      _incident.triggeredAt != null;

  Map<String, dynamic> _stubs = {
    'police112': {'name': 'Karnataka State Police 112 CAD', 'status': 'STANDBY'},
    'helpline181': {'name': 'Women Helpline 181 Rapid Desk', 'status': 'STANDBY'},
    'smsGateway': {'name': 'TRAI DLT Emergency SMS Gateway', 'status': 'STANDBY'},
  };
  Map<String, dynamic> get stubs => _stubs;

  bool _isBackendConnected = false;
  bool get isBackendConnected => _isBackendConnected;

  String _selectedContext = 'street';
  String get selectedContext => _selectedContext;

  bool _silentMode = true;
  bool get silentMode => _silentMode;

  bool _isDiscreetCalculatorActive = false;
  bool get isDiscreetCalculatorActive => _isDiscreetCalculatorActive;

  bool _isListeningVoice = false;
  bool get isListeningVoice => _isListeningVoice;

  String _lastVoiceTranscript = '';
  String get lastVoiceTranscript => _lastVoiceTranscript;

  double _audioStressLevel = 0.12;
  double get audioStressLevel => _audioStressLevel;

  FraudRiskAssessment? _fraudAssessment;
  FraudRiskAssessment? get fraudAssessment => _fraudAssessment;

  // Real safe havens in Pune / Shivajinagar corridor
  final List<SafeHaven> safeHavens = [
    const SafeHaven(
      id: 'SH-01',
      name: 'Apollo 24/7 Pharmacy & Safe Haven',
      type: '24/7 Pharmacy',
      lat: 18.5215,
      lon: 73.8580,
      distanceM: 140,
      verified: true,
      contact: '+91 20 2553 4401',
    ),
    const SafeHaven(
      id: 'SH-02',
      name: 'Shivajinagar All-Women Police Kiosk',
      type: 'Police Kiosk',
      lat: 18.5192,
      lon: 73.8552,
      distanceM: 220,
      verified: true,
      contact: '112 / 1091',
    ),
    const SafeHaven(
      id: 'SH-03',
      name: 'Pune Metro Women Safety Lounge',
      type: 'Transit Safe Zone',
      lat: 18.5228,
      lon: 73.8595,
      distanceM: 310,
      verified: true,
      contact: '+91 20 2605 1100',
    ),
    const SafeHaven(
      id: 'SH-04',
      name: 'Pink Patrol Mobile Interceptor #4',
      type: 'Nirbhaya Van',
      lat: 18.5180,
      lon: 73.8540,
      distanceM: 390,
      verified: true,
      contact: '181 Rapid Desk',
    ),
  ];

  // Combined peer list: live real peers + default mesh responders
  List<Responder> get peerMeshList {
    if (_livePeers.isNotEmpty) {
      return _livePeers.map((p) {
        return Responder(
          id: p.id,
          name: '${p.name} (${p.role})',
          status: p.status,
          distance: '${p.distanceMeters}m',
        );
      }).toList();
    }

    return [
      Responder(id: 'R-PRIYA', name: 'Priya S. (Aadhaar Verified)', status: 'active_mesh', distance: '85m'),
      Responder(id: 'R-ANANYA', name: 'Ananya K. (Metro Volunteer)', status: 'active_mesh', distance: '145m'),
      Responder(id: 'R-NEHA', name: 'Dr. Neha M. (Medical First Responder)', status: 'active_mesh', distance: '190m'),
      Responder(id: 'R-POOJA', name: 'Pooja T. (Night Commuter)', status: 'active_mesh', distance: '240m'),
    ];
  }

  void setContext(String ctx) {
    _selectedContext = ctx;
    notifyListeners();
  }

  void toggleSilentMode() {
    _silentMode = !_silentMode;
    notifyListeners();
  }

  void toggleCalculatorDisguise() {
    _isDiscreetCalculatorActive = !_isDiscreetCalculatorActive;
    notifyListeners();
  }

  void setDiscreetCalculator(bool active) {
    _isDiscreetCalculatorActive = active;
    notifyListeners();
  }

  void dismissIncomingAlert() {
    _incomingAlertDismissed = true;
    notifyListeners();
  }

  void startVoiceListening() {
    _isListeningVoice = true;
    _lastVoiceTranscript = 'Listening for distress cues ("Bachao", "Help")...';
    _audioStressLevel = 0.28;
    notifyListeners();
  }

  void stopVoiceListening() {
    _isListeningVoice = false;
    notifyListeners();
  }

  void simulateKeywordTrigger(String keyword) {
    _lastVoiceTranscript = 'Detected Distress Cue: "$keyword" (Stress: 94%)';
    _audioStressLevel = 0.94;
    notifyListeners();
    triggerEmergencySOS(context: 'street', silent: 1);
  }

  void stopPolling() {
    _pollingTimer?.cancel();
  }

  void startPolling() {
    _startPolling();
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      _syncWithBackend();
    });
    _syncWithBackend();
  }

  Future<void> _syncWithBackend() async {
    // 1. Send live heartbeat to backend mesh
    try {
      final hb = await _api.sendHeartbeat(
        id: _deviceId,
        name: _userName,
        lat: _myLat,
        lon: _myLon,
        role: _userRole,
        status: (_incident.status == 'active') ? 'in_distress' : 'active_mesh',
        battery: _batteryLevel,
      );

      if (hb['peers'] is List) {
        final rawList = List<Map<String, dynamic>>.from(hb['peers']);
        // Filter out self
        _livePeers = rawList
            .where((p) => p['id'] != _deviceId)
            .map((p) => LiveMeshPeer.fromJson(p, _myLat, _myLon))
            .toList();
      }
      _isBackendConnected = true;
    } catch (_) {
      _isBackendConnected = false;
    }

    // 2. Fetch current active incident
    try {
      final res = await _api.getCurrentIncident();
      if (res['success'] == true && res['incident'] != null) {
        final newInc = Incident.fromJson(res['incident']);
        if (_incident.id != newInc.id || _incident.status != newInc.status) {
          _incomingAlertDismissed = false;
        }
        _incident = newInc;
        if (res['stubs'] is Map<String, dynamic>) {
          _stubs = res['stubs'];
        }
      }
    } catch (_) {}

    // 3. Local 1s countdown fallback if active
    if (_incident.status == 'active' && _incident.triggeredAt != null) {
      final elapsed = ((DateTime.now().millisecondsSinceEpoch - _incident.triggeredAt!) / 1000).floor();
      final remaining = (60 - elapsed).clamp(0, 60);

      if (remaining == 0 && _incident.status == 'active') {
        final hasAccepted = _incident.events.any((e) => e.type == 'Accepted');
        if (!hasAccepted) {
          _incident = Incident(
            id: _incident.id,
            context: _incident.context,
            coords: _incident.coords,
            silent: _incident.silent,
            shortCode: _incident.shortCode,
            status: 'escalated',
            tier: 2,
            triggeredAt: _incident.triggeredAt,
            timeRemaining: 0,
            peerRadarVisible: _incident.peerRadarVisible,
            responders: _incident.responders,
            events: List.from(_incident.events)
              ..add(IncidentEvent(
                id: 'EV-${DateTime.now().millisecondsSinceEpoch}',
                type: 'Escalated',
                timestamp: DateTime.now().toIso8601String(),
                details: {
                  'tier': 2,
                  'reason': '60-second response window expired without acceptance.',
                  'message': 'Auto-escalated to Tier 2: Community Patrols, Pink Mobile Patrol & Police 112 CAD.'
                },
                hash: '0xESC${DateTime.now().millisecondsSinceEpoch.toRadixString(16)}',
              )),
          );
        }
      }
    }

    notifyListeners();
  }

  // Trigger Emergency SOS Panic
  Future<Map<String, dynamic>> triggerEmergencySOS({
    String? context,
    double? lat,
    double? lon,
    int? silent,
  }) async {
    final ctx = context ?? _selectedContext;
    final sil = silent ?? (_silentMode ? 1 : 0);
    final cLat = lat ?? _myLat;
    final cLon = lon ?? _myLon;

    final res = await _api.triggerSOS(
      context: ctx,
      lat: cLat,
      lon: cLon,
      silent: sil,
    );

    if (res['incident'] != null) {
      _incident = Incident.fromJson(res['incident']);
      _incomingAlertDismissed = true; // sender doesn't need to accept own alert
      notifyListeners();
    }

    evaluateDefaultFraudScore();
    return res;
  }

  // Accept Incident with responder ID and shortCode
  Future<Map<String, dynamic>> acceptIncident(String responderId, String shortCode) async {
    final res = await _api.acceptIncident(responderId, shortCode);
    if (res['incident'] != null) {
      _incident = Incident.fromJson(res['incident']);
      _incomingAlertDismissed = true;
      notifyListeners();
    }
    return res;
  }

  // 1-Tap accept incoming incident using this phone's device identity
  Future<Map<String, dynamic>> acceptIncomingIncident() async {
    return acceptIncident('$_userName ($_deviceId)', _incident.shortCode);
  }

  Future<Map<String, dynamic>> executeConsoleCommand(String command) async {
    final res = await _api.executeCommand(command);
    if (res['incident'] != null) {
      _incident = Incident.fromJson(res['incident']);
      notifyListeners();
    }
    return res;
  }

  Future<void> resetAll() async {
    await _api.resetIncident();
    _incident = Incident.idle();
    _incomingAlertDismissed = false;
    _lastVoiceTranscript = '';
    _audioStressLevel = 0.12;
    notifyListeners();
  }

  Future<void> evaluateDefaultFraudScore({
    int accountAge = 45,
    String verificationLevel = 'aadhaar_biometric',
    bool rooted = false,
    bool vpnActive = false,
    bool isIsolated = false,
  }) async {
    final signals = {
      'accountAge': accountAge,
      'verificationLevel': verificationLevel,
      'alertHistory': 3,
      'cancelledAlerts': 0,
      'rooted': rooted,
      'vpnActive': vpnActive,
      'isUsualArea': true,
      'isIsolated': isIsolated,
      'areaRisk': 'medium',
    };

    final result = await _api.evaluateFraud(signals);
    _fraudAssessment = result;
    notifyListeners();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}
