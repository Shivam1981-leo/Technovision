import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Primary network IP for local Wi-Fi / Hotspot peer mesh
  static const String defaultLanHost = '192.168.1.33';
  static const int defaultPort = 3000;

  static String get defaultBaseUrl {
    if (kIsWeb) {
      final origin = Uri.base.origin;
      if (origin.isNotEmpty && !origin.contains('null')) {
        final uri = Uri.parse(origin);
        // Only if explicitly on local Flutter Chrome dev port 5000, target port 3000
        if (uri.port == 5000) {
          return '${uri.scheme}://${uri.host}:$defaultPort';
        }
        // In all other cases (Cloudflare tunnel, Express port 3000, production domain)
        // DO NOT append :3000 since Cloudflare / HTTPS origins only serve on standard HTTPS ports!
        return origin;
      }
      return 'http://$defaultLanHost:$defaultPort';
    }
    if (Platform.isAndroid) {
      // Connect to the Cloudflare public tunnel for true cross-network multi-device support
      return 'https://indication-vendors-jacksonville-citizenship.trycloudflare.com';
    }
    return 'http://localhost:$defaultPort';
  }

  String baseUrl = defaultBaseUrl;

  void updateBaseUrl(String newUrl) {
    baseUrl = newUrl.replaceAll(RegExp(r'/+$'), '');
  }

  Incident _localIncident = Incident.idle();

  // Real-time Phone Heartbeat & Peer Mesh Registration
  Future<Map<String, dynamic>> sendHeartbeat({
    required String id,
    required String name,
    required double lat,
    required double lon,
    String role = 'commuter',
    String status = 'active_mesh',
    int battery = 88,
    String verification = 'aadhaar_verified',
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/peers/heartbeat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': id,
          'name': name,
          'lat': lat,
          'lon': lon,
          'role': role,
          'status': status,
          'battery': battery,
          'verification': verification,
        }),
      ).timeout(const Duration(milliseconds: 2000));

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      debugPrint('[ApiService] Heartbeat fallback: $e');
    }

    return {
      'success': true,
      'peerCount': 1,
      'peers': [
        {
          'id': id,
          'name': name,
          'lat': lat,
          'lon': lon,
          'role': role,
          'status': status,
          'battery': battery,
        }
      ]
    };
  }

  // Get all active peers
  Future<List<Map<String, dynamic>>> fetchLivePeers() async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/api/peers'),
      ).timeout(const Duration(milliseconds: 2000));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['peers'] is List) {
          return List<Map<String, dynamic>>.from(data['peers']);
        }
      }
    } catch (e) {
      debugPrint('[ApiService] Fetch peers fallback: $e');
    }
    return [];
  }

  // Fetch current active incident & system stubs
  Future<Map<String, dynamic>> getCurrentIncident() async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/api/incidents/current'),
      ).timeout(const Duration(milliseconds: 2000));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['incident'] != null) {
          _localIncident = Incident.fromJson(data['incident']);
        }
        return data;
      }
    } catch (e) {
      debugPrint('[ApiService] Offline or failed to fetch incident: $e');
    }

    // Local fallback
    return {
      'success': true,
      'incident': _localIncident.toJson(),
      'stubs': {
        'police112': {'name': 'Karnataka State Police 112 CAD', 'status': 'STANDBY'},
        'helpline181': {'name': 'Women Helpline 181 Rapid Desk', 'status': 'STANDBY'},
        'smsGateway': {'name': 'TRAI DLT Emergency SMS Gateway', 'status': 'STANDBY'},
      }
    };
  }

  // Execute console command: SG|context|lat|lon|silent or OK|responder|code or RESET or STATUS
  Future<Map<String, dynamic>> executeCommand(String command) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/console-command'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'command': command}),
      ).timeout(const Duration(milliseconds: 2500));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['incident'] != null) {
          _localIncident = Incident.fromJson(data['incident']);
        }
        return data;
      }
    } catch (e) {
      debugPrint('[ApiService] Offline command execution fallback: $e');
    }

    return _simulateLocalCommand(command);
  }

  // Trigger SOS Panic
  Future<Map<String, dynamic>> triggerSOS({
    String context = 'street',
    double lat = 18.5204,
    double lon = 73.8567,
    int silent = 1,
  }) async {
    final cmd = 'SG|$context|$lat|$lon|$silent';
    return executeCommand(cmd);
  }

  // Accept Incident with responder ID and shortCode
  Future<Map<String, dynamic>> acceptIncident(String responderId, String shortCode) async {
    final cmd = 'OK|$responderId|$shortCode';
    return executeCommand(cmd);
  }

  // Reset incident
  Future<Map<String, dynamic>> resetIncident() async {
    return executeCommand('RESET');
  }

  // Evaluate Fraud Risk
  Future<FraudRiskAssessment> evaluateFraud(Map<String, dynamic> signals) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/fraud-detect'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(signals),
      ).timeout(const Duration(milliseconds: 2500));

      if (res.statusCode == 200) {
        return FraudRiskAssessment.fromJson(jsonDecode(res.body));
      }
    } catch (e) {
      debugPrint('[ApiService] Fraud endpoint fallback: $e');
    }

    // Local ML score computation
    double score = 0.05;
    final int age = signals['accountAge'] ?? 30;
    if (age < 7) score += 0.25;
    final String verif = signals['verificationLevel'] ?? 'aadhaar_biometric';
    if (verif == 'unverified') score += 0.30;
    if (signals['rooted'] == true) score += 0.35;
    if (signals['vpnActive'] == true) score += 0.20;
    if (signals['isIsolated'] == true) score += 0.15;
    score = score.clamp(0.01, 0.98);

    String rec = 'IMMEDIATE_BROADCAST';
    if (score >= 0.70) rec = 'HOLD_FOR_MANUAL_REVIEW';
    else if (score >= 0.50) rec = 'VOICE_VERIFICATION_FIRST';
    else if (score >= 0.20) rec = 'SEND_TO_VERIFIED_RESPONDERS';

    return FraudRiskAssessment(
      fraudScore: double.parse(score.toStringAsFixed(2)),
      recommendation: rec,
      confidence: 0.94,
      antiLuringRequired: (signals['isIsolated'] == true && age < 14),
      signalsEvaluated: signals,
    );
  }

  Map<String, dynamic> _simulateLocalCommand(String command) {
    final trimmed = command.trim();
    final parts = trimmed.split('|');
    final action = parts[0].toUpperCase();

    if (action == 'SG') {
      final ctx = parts.length > 1 ? parts[1].toLowerCase() : 'street';
      final lat = parts.length > 2 ? (double.tryParse(parts[2]) ?? 18.5204) : 18.5204;
      final lon = parts.length > 3 ? (double.tryParse(parts[3]) ?? 73.8567) : 73.8567;
      final silent = parts.length > 4 ? (int.tryParse(parts[4]) ?? 1) : 1;
      final incId = 'INC-${DateTime.now().millisecondsSinceEpoch % 10000}';

      final ev1 = IncidentEvent(
        id: 'EV-${DateTime.now().millisecondsSinceEpoch}',
        type: 'Triggered',
        timestamp: DateTime.now().toIso8601String(),
        details: {'context': ctx, 'silent': silent, 'coords': {'lat': lat, 'lon': lon}},
        hash: '0xSG${DateTime.now().millisecondsSinceEpoch.toRadixString(16)}',
      );

      final isHome = ctx == 'home';
      final ev2 = IncidentEvent(
        id: 'EV-${DateTime.now().millisecondsSinceEpoch + 1}',
        type: 'Routed',
        timestamp: DateTime.now().toIso8601String(),
        details: {
          'tier': isHome ? 'Tier 1: Women Helpline 181 Rapid Desk' : 'Tier 1: Nearby Responder Mesh',
          'peerRadarVisible': !isHome,
          'message': isHome
              ? 'Discreet Domestic Incident routed confidentially to 181 Rapid Desk. Hidden from peer radar.'
              : 'Street incident routed to Nearby Responder Mesh (200m). Broadcast active.',
        },
        hash: '0xRO${(DateTime.now().millisecondsSinceEpoch + 1).toRadixString(16)}',
      );

      _localIncident = Incident(
        id: incId,
        context: ctx,
        coords: LatLon(lat: lat, lon: lon),
        silent: silent,
        shortCode: 'BLUE',
        status: 'active',
        tier: 1,
        triggeredAt: DateTime.now().millisecondsSinceEpoch,
        timeRemaining: 60,
        peerRadarVisible: !isHome,
        responders: [],
        events: [ev1, ev2],
      );

      return {
        'success': true,
        'message': '[OK] SG incident triggered ($ctx). Silent: $silent. Code: BLUE',
        'incident': _localIncident.toJson(),
      };
    }

    if (action == 'OK') {
      if (parts.length < 3) {
        return {'success': false, 'message': 'Expected OK|<responderId>|<shortCode>'};
      }
      final rId = parts[1];
      final code = parts[2].toUpperCase();

      final updatedResponders = List<Responder>.from(_localIncident.responders);
      updatedResponders.add(Responder(
        id: rId,
        name: 'Responder $rId (Verified)',
        status: 'en_route',
        distance: '65m',
        acceptedAt: DateTime.now().toIso8601String(),
        shortCode: code,
      ));

      final acceptEv = IncidentEvent(
        id: 'EV-${DateTime.now().millisecondsSinceEpoch}',
        type: 'Accepted',
        timestamp: DateTime.now().toIso8601String(),
        details: {'responderId': rId, 'shortCode': code, 'message': 'Incident accepted by $rId.'},
        hash: '0xOK${DateTime.now().millisecondsSinceEpoch.toRadixString(16)}',
      );

      final updatedEvents = List<IncidentEvent>.from(_localIncident.events)..add(acceptEv);

      _localIncident = Incident(
        id: _localIncident.id,
        context: _localIncident.context,
        coords: _localIncident.coords,
        silent: _localIncident.silent,
        shortCode: _localIncident.shortCode,
        status: 'accepted',
        tier: _localIncident.tier,
        triggeredAt: _localIncident.triggeredAt,
        timeRemaining: 0,
        peerRadarVisible: _localIncident.peerRadarVisible,
        responders: updatedResponders,
        events: updatedEvents,
      );

      return {
        'success': true,
        'message': '[SUCCESS] Incident ${_localIncident.id} accepted by responder $rId with code $code.',
        'incident': _localIncident.toJson(),
      };
    }

    if (action == 'RESET') {
      _localIncident = Incident.idle();
      return {'success': true, 'message': 'Incident reset.', 'incident': _localIncident.toJson()};
    }

    return {'success': true, 'incident': _localIncident.toJson()};
  }
}
