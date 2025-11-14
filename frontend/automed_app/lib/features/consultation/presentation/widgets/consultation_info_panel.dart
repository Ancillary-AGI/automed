import 'package:flutter/material.dart';

// Consultation info panel widget
class ConsultationInfoPanel extends StatelessWidget {
  final dynamic consultation;
  final VoidCallback onClose;

  const ConsultationInfoPanel({
    super.key,
    required this.consultation,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey)),
            ),
            child: Row(
              children: [
                const Text(
                  'Consultation Info',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onClose,
                ),
              ],
            ),
          ),

          // Info Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Doctor', consultation.doctorName ?? 'Unknown'),
                  _buildInfoRow('Type', consultation.type ?? 'Regular'),
                  _buildInfoRow('Status', consultation.status ?? 'Unknown'),
                  _buildInfoRow(
                      'Patient', consultation.patientName ?? 'Unknown'),
                  if (consultation.scheduledTime != null)
                    _buildInfoRow(
                        'Time', consultation.scheduledTime.toString()),
                  if (consultation.notes != null &&
                      consultation.notes.isNotEmpty)
                    _buildInfoRow('Notes', consultation.notes),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
