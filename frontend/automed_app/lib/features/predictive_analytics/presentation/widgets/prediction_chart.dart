import 'package:flutter/material.dart';

class PredictionChart extends StatelessWidget {
  const PredictionChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.show_chart, color: Colors.purple),
                const SizedBox(width: 8),
                Text(
                  'Prediction Chart',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              color: Colors.grey[200],
              child: const Center(
                child: Text('Chart Placeholder'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PopulationHealthChart extends StatelessWidget {
  final dynamic data;
  const PopulationHealthChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      color: Colors.grey[200],
      child: const Center(
        child: Text('Population Health Chart'),
      ),
    );
  }
}

class PredictionCard extends StatelessWidget {
  final dynamic prediction;
  final VoidCallback? onTap;
  const PredictionCard({super.key, required this.prediction, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(prediction?.description ?? 'Prediction'),
        onTap: onTap,
      ),
    );
  }
}

class HighRiskPatientCard extends StatelessWidget {
  final dynamic patient;
  final VoidCallback? onTap;
  const HighRiskPatientCard({super.key, required this.patient, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(patient?.name ?? 'Patient'),
        subtitle: Text('Risk: ${patient?.riskScore ?? 'Unknown'}'),
        onTap: onTap,
      ),
    );
  }
}

class SeasonalPatternCard extends StatelessWidget {
  final dynamic pattern;
  const SeasonalPatternCard({super.key, required this.pattern});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(pattern?.name ?? 'Pattern'),
        subtitle: Text(pattern?.description ?? ''),
      ),
    );
  }
}

class PredictiveAlertCard extends StatelessWidget {
  final dynamic alert;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;
  const PredictiveAlertCard(
      {super.key, required this.alert, this.onTap, this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(alert?.message ?? 'Alert'),
        trailing: IconButton(
          icon: const Icon(Icons.close),
          onPressed: onDismiss,
        ),
        onTap: onTap,
      ),
    );
  }
}

class AlertHistoryCard extends StatelessWidget {
  final dynamic alert;
  const AlertHistoryCard({super.key, required this.alert});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(alert?.message ?? 'Alert'),
        subtitle: Text(alert?.timestamp?.toString() ?? ''),
      ),
    );
  }
}
