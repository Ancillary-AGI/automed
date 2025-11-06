import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:nfc_manager/nfc_manager.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/smart_medication_provider.dart';
import '../widgets/medication_card.dart';
import '../widgets/adherence_chart.dart';
import '../widgets/pill_reminder_widget.dart';

class SmartMedicationPage extends ConsumerStatefulWidget {
  const SmartMedicationPage({super.key});

  @override
  ConsumerState<SmartMedicationPage> createState() => _SmartMedicationPageState();
}

class _SmartMedicationPageState extends ConsumerState<SmartMedicationPage>
    with TickerProviderStateMixin {
  
  late TabController _tabController;
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? _qrController;
  bool _isNFCAvailable = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _checkNFCAvailability();
    _loadMedicationData();
  }

  @override