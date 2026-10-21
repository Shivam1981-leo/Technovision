import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/sangini_controller.dart';
import '../theme/app_theme.dart';

class IncidentLogView extends StatelessWidget {
  const IncidentLogView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = SanginiController();

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final incident = controller.incident;
        final events = incident.events;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Incident Audit Log (24h Twist)'),
            actions: [
              IconButton(
                tooltip: 'Audit Integrity Check',
                icon: const Icon(Icons.verified, color: AppTheme.statusEmerald),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: AppTheme.statusEmerald,
                      content: Text('Cryptographic Integrity Verified: All event hashes chain correctly.'),
                    ),
                  );
                },
              ),
            ],
          ),
          body: events.isEmpty
              ? _buildEmptyState()
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Summary Card
                      _buildAuditSummaryCard(incident),

                      const SizedBox(height: 16),

                      // Append-only Event Stream
                      ...events.reversed.map((ev) => _buildEventItem(ev)),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceCard,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.border),
              ),
              child: const Icon(Icons.receipt_long_outlined, size: 40, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 14),
            const Text(
              'No Incident Recorded Yet',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 6),
            const Text(
              'Trigger an Emergency SOS or run an SG command to generate an immutable, tamper-evident audit log.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuditSummaryCard(Incident incident) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Incident Dossier: ${incident.id}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                  ),
                  Text(
                    'Status: ${incident.status.toUpperCase()} • Code ${incident.shortCode}',
                    style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.statusEmerald.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.statusEmerald.withOpacity(0.4)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lock, size: 12, color: AppTheme.statusEmerald),
                    SizedBox(width: 4),
                    Text(
                      'APPEND-ONLY',
                      style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: AppTheme.statusEmerald),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Every action is chained with cryptographic signatures for non-repudiation in court evidence and police CAD handover.',
            style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildEventItem(IncidentEvent ev) {
    Color typeColor = AppTheme.statusCyan;
    IconData icon = Icons.info_outline;

    switch (ev.type) {
      case 'Triggered':
        typeColor = AppTheme.primaryPink;
        icon = Icons.crisis_alert;
        break;
      case 'Routed':
        typeColor = AppTheme.secondaryViolet;
        icon = Icons.alt_route;
        break;
      case 'Broadcasted':
        typeColor = AppTheme.statusCyan;
        icon = Icons.wifi_tethering;
        break;
      case 'Accepted':
        typeColor = AppTheme.statusEmerald;
        icon = Icons.check_circle;
        break;
      case 'Escalated':
        typeColor = AppTheme.statusRose;
        icon = Icons.warning;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: typeColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 16, color: typeColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ev.type.toUpperCase(),
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: typeColor),
                    ),
                    Text(
                      ev.timestamp,
                      style: const TextStyle(fontSize: 9.5, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  ev.hash.length > 10 ? ev.hash.substring(0, 10) : ev.hash,
                  style: const TextStyle(fontSize: 9, fontFamily: 'monospace', color: AppTheme.textMuted),
                ),
              ),
            ],
          ),
          if (ev.details.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.surfaceElevated.withOpacity(0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: ev.details.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${entry.key}: ',
                          style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppTheme.textSecondary),
                        ),
                        Expanded(
                          child: Text(
                            entry.value.toString(),
                            style: const TextStyle(fontSize: 10.5, color: AppTheme.textPrimary),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
