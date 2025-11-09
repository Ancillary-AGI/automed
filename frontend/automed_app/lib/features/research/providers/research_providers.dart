import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../../../core/di/injection.dart';
import '../models/research_models.dart';

// Research Dashboard Provider
final researchDashboardProvider =
    FutureProvider<ResearchDashboard>((ref) async {
  final dio = ref.watch(dioProvider);
  final appConfig = ref.watch(appConfigProvider);

  try {
    final response = await dio.get(
      '${appConfig.apiBaseUrl}/research/dashboard',
    );
    return ResearchDashboard.fromJson(response.data);
  } catch (e) {
    throw Exception('Failed to load research dashboard: $e');
  }
});

// Molecular Simulation Providers
final molecularSimulationProvider =
    FutureProvider.family<MolecularSimulationResult, String>(
        (ref, simulationId) async {
  final dio = ref.watch(dioProvider);
  final appConfig = ref.watch(appConfigProvider);

  try {
    final response = await dio.get(
      '${appConfig.apiBaseUrl}/research/molecular/simulation/$simulationId',
    );
    return MolecularSimulationResult(
      simulationId: response.data['simulationId'],
      molecule: response.data['molecule'],
      trajectory: TrajectoryData(
        coordinates: (response.data['trajectory']['coordinates'] as List)
            .map((e) => (e as List).map((c) => c as double).toList())
            .toList(),
        timestamps: (response.data['trajectory']['timestamps'] as List)
            .map((e) => e as double)
            .toList(),
        totalFrames: response.data['trajectory']['totalFrames'],
      ),
      energyProfile: EnergyProfile(
        potentialEnergy: response.data['energyProfile']['potentialEnergy'],
        kineticEnergy: response.data['energyProfile']['kineticEnergy'],
        totalEnergy: response.data['energyProfile']['totalEnergy'],
      ),
      bindingSites: (response.data['bindingSites'] as List)
          .map((e) => BindingSite(
                residues:
                    (e['residues'] as List).map((r) => r as String).toList(),
                affinity: e['affinity'],
                probability: e['probability'],
              ))
          .toList(),
      stabilityScore: response.data['stabilityScore'],
      simulationTime: response.data['simulationTime'],
    );
  } catch (e) {
    throw Exception('Failed to load molecular simulation: $e');
  }
});

// Cancer Research Providers
final tumorModelProvider =
    FutureProvider.family<TumorModel, String>((ref, tumorId) async {
  final dio = ref.watch(dioProvider);
  final appConfig = ref.watch(appConfigProvider);

  try {
    final response = await dio.get(
      '${appConfig.apiBaseUrl}/research/cancer/tumor/$tumorId',
    );
    return TumorModel(
      tumorId: response.data['tumorId'],
      type: response.data['type'],
      cellularComposition: CellularComposition(
        cancerCells: response.data['cellularComposition']['cancerCells'],
        stromalCells: response.data['cellularComposition']['stromalCells'],
        immuneCells: response.data['cellularComposition']['immuneCells'],
        endothelialCells: response.data['cellularComposition']
            ['endothelialCells'],
      ),
      extracellularMatrix: ECMComposition(
        collagen: response.data['extracellularMatrix']['collagen'],
        hyaluronicAcid: response.data['extracellularMatrix']['hyaluronicAcid'],
        fibronectin: response.data['extracellularMatrix']['fibronectin'],
        laminin: response.data['extracellularMatrix']['laminin'],
        stiffness: response.data['extracellularMatrix']['stiffness'],
      ),
      vascularNetwork: VascularNetwork(
        vesselDensity: response.data['vascularNetwork']['vesselDensity'],
        tortuosity: response.data['vascularNetwork']['tortuosity'],
        perfusion: response.data['vascularNetwork']['perfusion'],
        leakiness: response.data['vascularNetwork']['leakiness'],
      ),
      metabolicProfile: MetabolicProfile(
        glycolysis: response.data['metabolicProfile']['glycolysis'],
        oxidativePhosphorylation: response.data['metabolicProfile']
            ['oxidativePhosphorylation'],
        lactateProduction: response.data['metabolicProfile']
            ['lactateProduction'],
        glutamineConsumption: response.data['metabolicProfile']
            ['glutamineConsumption'],
      ),
      hypoxiaLevel: response.data['hypoxiaLevel'],
      phGradient: response.data['phGradient'],
    );
  } catch (e) {
    throw Exception('Failed to load tumor model: $e');
  }
});

// Tissue Engineering Providers
final scaffoldDesignProvider =
    FutureProvider.family<ScaffoldDesign, String>((ref, designId) async {
  final dio = ref.watch(dioProvider);
  final appConfig = ref.watch(appConfigProvider);

  try {
    final response = await dio.get(
      '${appConfig.apiBaseUrl}/research/tissue/scaffold/$designId',
    );
    return ScaffoldDesign(
      structure: response.data['structure'],
      materials:
          (response.data['materials'] as List).map((e) => e as String).toList(),
      porosity: response.data['porosity'],
      fabricationMethod: response.data['fabricationMethod'],
      optimizationScore: response.data['optimizationScore'],
    );
  } catch (e) {
    throw Exception('Failed to load scaffold design: $e');
  }
});

// Medical Robotics Providers
final surgicalPlanProvider =
    FutureProvider.family<SurgicalPlan, String>((ref, planId) async {
  final dio = ref.watch(dioProvider);
  final appConfig = ref.watch(appConfigProvider);

  try {
    final response = await dio.get(
      '${appConfig.apiBaseUrl}/research/robotics/plan/$planId',
    );
    return SurgicalPlan(
      planId: response.data['planId'],
      procedureType: response.data['procedureType'],
      trajectory: (response.data['trajectory'] as List)
          .map((e) => e as double)
          .toList(),
      waypoints:
          (response.data['waypoints'] as List).map((e) => e as int).toList(),
      safetyMargins: response.data['safetyMargins'],
      precision: response.data['precision'],
    );
  } catch (e) {
    throw Exception('Failed to load surgical plan: $e');
  }
});

// Computational Biology Providers
final genomeAnalysisProvider =
    FutureProvider.family<GenomeAnalysis, String>((ref, genomeId) async {
  final dio = ref.watch(dioProvider);
  final appConfig = ref.watch(appConfigProvider);

  try {
    final response = await dio.get(
      '${appConfig.apiBaseUrl}/research/biology/genome/$genomeId',
    );
    return GenomeAnalysis(
      genomeId: response.data['genomeId'],
      totalVariants: response.data['totalVariants'],
      codingVariants: response.data['codingVariants'],
      pathogenicVariants: response.data['pathogenicVariants'],
      heterozygosity: response.data['heterozygosity'],
      diseaseGenes: (response.data['diseaseGenes'] as List)
          .map((e) => e as String)
          .toList(),
    );
  } catch (e) {
    throw Exception('Failed to load genome analysis: $e');
  }
});

// Drug Development Providers
final drugCandidateProvider =
    FutureProvider.family<DrugCandidate, String>((ref, compoundId) async {
  final dio = ref.watch(dioProvider);
  final appConfig = ref.watch(appConfigProvider);

  try {
    final response = await dio.get(
      '${appConfig.apiBaseUrl}/research/drug/candidate/$compoundId',
    );
    return DrugCandidate(
      compoundId: response.data['compoundId'],
      smiles: response.data['smiles'],
      name: response.data['name'],
      molecularWeight: response.data['molecularWeight'],
      logP: response.data['logP'],
      bindingAffinity: response.data['bindingAffinity'],
      admetProperties:
          Map<String, double>.from(response.data['admetProperties']),
    );
  } catch (e) {
    throw Exception('Failed to load drug candidate: $e');
  }
});

// Virtual Screening Provider
final virtualScreeningProvider =
    FutureProvider.family<VirtualScreeningResult, String>(
        (ref, screeningId) async {
  final dio = ref.watch(dioProvider);
  final appConfig = ref.watch(appConfigProvider);

  try {
    final response = await dio.get(
      '${appConfig.apiBaseUrl}/research/drug/screening/$screeningId',
    );
    return VirtualScreeningResult(
      screeningId: response.data['screeningId'],
      hits: (response.data['hits'] as List)
          .map((e) => DrugCandidate(
                compoundId: e['compoundId'],
                smiles: e['smiles'],
                name: e['name'],
                molecularWeight: e['molecularWeight'],
                logP: e['logP'],
                bindingAffinity: e['bindingAffinity'],
                admetProperties: Map<String, double>.from(e['admetProperties']),
              ))
          .toList(),
      totalCompounds: response.data['totalCompounds'],
      enrichmentFactor: response.data['enrichmentFactor'],
      hitRate: response.data['hitRate'],
    );
  } catch (e) {
    throw Exception('Failed to load virtual screening results: $e');
  }
});

// Research Projects Provider
final researchProjectsProvider =
    FutureProvider<List<ResearchProject>>((ref) async {
  final dio = ref.watch(dioProvider);
  final appConfig = ref.watch(appConfigProvider);

  try {
    final response = await dio.get(
      '${appConfig.apiBaseUrl}/research/projects',
    );
    return (response.data as List)
        .map((e) => ResearchProject.fromJson(e))
        .toList();
  } catch (e) {
    throw Exception('Failed to load research projects: $e');
  }
});

// Research Results Provider
final researchResultsProvider =
    FutureProvider<List<ResearchResult>>((ref) async {
  final dio = ref.watch(dioProvider);
  final appConfig = ref.watch(appConfigProvider);

  try {
    final response = await dio.get(
      '${appConfig.apiBaseUrl}/research/results',
    );
    return (response.data as List)
        .map((e) => ResearchResult.fromJson(e))
        .toList();
  } catch (e) {
    throw Exception('Failed to load research results: $e');
  }
});

// System Status Provider
final systemStatusProvider = FutureProvider<SystemStatus>((ref) async {
  final dio = ref.watch(dioProvider);
  final appConfig = ref.watch(appConfigProvider);

  try {
    final response = await dio.get(
      '${appConfig.apiBaseUrl}/research/system/status',
    );
    return SystemStatus.fromJson(response.data);
  } catch (e) {
    throw Exception('Failed to load system status: $e');
  }
});
