import 'dart:convert';

class LatLon {
  final double lat;
  final double lon;

  const LatLon({required this.lat, required this.lon});

  factory LatLon.fromJson(Map<String, dynamic> json) {
    return LatLon(
      lat: (json['lat'] ?? 18.5204).toDouble(),
      lon: (json['lon'] ?? json['lng'] ?? 73.8567).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {'lat': lat, 'lon': lon};
}

class IncidentEvent {
  final String id;
  final String type;
  final String timestamp;
  final Map<String, dynamic> details;
  final String hash;

  IncidentEvent({
    required this.id,
    required this.type,
    required this.timestamp,
    required this.details,
    required this.hash,
  });

  factory IncidentEvent.fromJson(Map<String, dynamic> json) {
    return IncidentEvent(
      id: json['id']?.toString() ?? 'EV-${DateTime.now().millisecondsSinceEpoch}',
      type: json['type']?.toString() ?? 'Event',
      timestamp: json['timestamp']?.toString() ?? DateTime.now().toIso8601String(),
      details: json['details'] is Map<String, dynamic> ? json['details'] : <String, dynamic>{},
      hash: json['hash']?.toString() ?? '0x${json['type'].hashCode.toRadixString(16).padLeft(8, '0')}',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'timestamp': timestamp,
    'details': details,
    'hash': hash,
  };
}

class Responder {
  final String id;
  final String name;
  final String status;
  final String distance;
  final String? acceptedAt;
  final String? shortCode;

  Responder({
    required this.id,
    required this.name,
    required this.status,
    required this.distance,
    this.acceptedAt,
    this.shortCode,
  });

  factory Responder.fromJson(Map<String, dynamic> json) {
    return Responder(
      id: json['id']?.toString() ?? 'R-01',
      name: json['name']?.toString() ?? 'Verified Peer Responder',
      status: json['status']?.toString() ?? 'notified',
      distance: json['distance']?.toString() ?? '110m',
      acceptedAt: json['acceptedAt']?.toString(),
      shortCode: json['shortCode']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'status': status,
    'distance': distance,
    'acceptedAt': acceptedAt,
    'shortCode': shortCode,
  };
}

class SafeHaven {
  final String id;
  final String name;
  final String type; // Police Kiosk, Metro Station, Pharmacy, Pink Booth
  final double lat;
  final double lon;
  final int distanceM;
  final bool verified;
  final String contact;

  const SafeHaven({
    required this.id,
    required this.name,
    required this.type,
    required this.lat,
    required this.lon,
    required this.distanceM,
    required this.verified,
    required this.contact,
  });
}

class Incident {
  final String id;
  final String context; // 'street' or 'home'
  final LatLon coords;
  final int silent;
  final String shortCode;
  final String status; // 'idle', 'active', 'accepted', 'escalated'
  final int tier;
  final int? triggeredAt;
  final int timeRemaining;
  final bool peerRadarVisible;
  final List<Responder> responders;
  final List<IncidentEvent> events;

  Incident({
    required this.id,
    required this.context,
    required this.coords,
    required this.silent,
    required this.shortCode,
    required this.status,
    required this.tier,
    this.triggeredAt,
    required this.timeRemaining,
    required this.peerRadarVisible,
    required this.responders,
    required this.events,
  });

  factory Incident.idle() {
    return Incident(
      id: 'INC-IDLE',
      context: 'street',
      coords: const LatLon(lat: 18.5204, lon: 73.8567),
      silent: 1,
      shortCode: 'BLUE',
      status: 'idle',
      tier: 1,
      triggeredAt: null,
      timeRemaining: 60,
      peerRadarVisible: true,
      responders: [],
      events: [],
    );
  }

  factory Incident.fromJson(Map<String, dynamic> json) {
    List<Responder> resList = [];
    if (json['responders'] is List) {
      resList = (json['responders'] as List)
          .map((item) => Responder.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    List<IncidentEvent> evList = [];
    if (json['events'] is List) {
      evList = (json['events'] as List)
          .map((item) => IncidentEvent.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return Incident(
      id: json['id']?.toString() ?? 'INC-${DateTime.now().millisecondsSinceEpoch % 10000}',
      context: json['context']?.toString() ?? 'street',
      coords: json['coords'] is Map<String, dynamic>
          ? LatLon.fromJson(json['coords'] as Map<String, dynamic>)
          : const LatLon(lat: 18.5204, lon: 73.8567),
      silent: (json['silent'] is int) ? json['silent'] : (json['silent'] == true ? 1 : 0),
      shortCode: json['shortCode']?.toString() ?? 'BLUE',
      status: json['status']?.toString() ?? 'idle',
      tier: (json['tier'] ?? 1) is int ? (json['tier'] ?? 1) : 1,
      triggeredAt: json['triggeredAt'] is int ? json['triggeredAt'] : null,
      timeRemaining: (json['timeRemaining'] ?? 60) is int ? (json['timeRemaining'] ?? 60) : 60,
      peerRadarVisible: json['peerRadarVisible'] ?? true,
      responders: resList,
      events: evList,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'context': context,
    'coords': coords.toJson(),
    'silent': silent,
    'shortCode': shortCode,
    'status': status,
    'tier': tier,
    'triggeredAt': triggeredAt,
    'timeRemaining': timeRemaining,
    'peerRadarVisible': peerRadarVisible,
    'responders': responders.map((r) => r.toJson()).toList(),
    'events': events.map((e) => e.toJson()).toList(),
  };
}

class FraudRiskAssessment {
  final double fraudScore;
  final String recommendation;
  final double confidence;
  final bool antiLuringRequired;
  final Map<String, dynamic> signalsEvaluated;

  FraudRiskAssessment({
    required this.fraudScore,
    required this.recommendation,
    required this.confidence,
    required this.antiLuringRequired,
    required this.signalsEvaluated,
  });

  factory FraudRiskAssessment.fromJson(Map<String, dynamic> json) {
    return FraudRiskAssessment(
      fraudScore: (json['fraudScore'] ?? 0.05).toDouble(),
      recommendation: json['recommendation']?.toString() ?? 'IMMEDIATE_BROADCAST',
      confidence: (json['confidence'] ?? 0.92).toDouble(),
      antiLuringRequired: json['antiLuringRequired'] ?? false,
      signalsEvaluated: json['signalsEvaluated'] is Map<String, dynamic>
          ? json['signalsEvaluated']
          : <String, dynamic>{},
    );
  }
}

class StubStatus {
  final String name;
  final String status;
  final dynamic lastPayload;
  final String? timestamp;

  StubStatus({
    required this.name,
    required this.status,
    this.lastPayload,
    this.timestamp,
  });

  factory StubStatus.fromJson(Map<String, dynamic> json) {
    return StubStatus(
      name: json['name']?.toString() ?? 'Service Stub',
      status: json['status']?.toString() ?? 'STANDBY',
      lastPayload: json['lastPayload'],
      timestamp: json['timestamp']?.toString(),
    );
  }
}
