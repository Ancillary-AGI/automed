import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:automed_app/core/di/injection.dart';
import '../models/research_models.dart';

// Research Dashboard Provider
final researchDashboardProvider =
    FutureProvider<ResearchDashboard>((ref) async {
  final apiService = ref.watch(apiServiceProvider);

  try {
    final apiResp = await apiService.getTyped<ResearchDashboard>(
      '/research/dashboard',
      (json) => ResearchDashboard.fromJson(json as Map<String, dynamic>),
    );
    if (apiResp.success && apiResp.data != null) {
      return apiResp.data!;
    } else {
      throw Exception(apiResp.message ?? 'Failed to load research dashboard');
    }
  } catch (e) {
    // Return mock data for now
    return ResearchDashboard(
      activeProjects: [
        ResearchProject(
          id: 'proj-001',
          title: 'Cancer Immunotherapy Development',
          description: 'Developing novel CAR-T cell therapies for solid tumors',
          type: ProjectType.cancerResearch,
          status: ProjectStatus.active,
          startDate: DateTime(2023, 1, 15),
          researchers: ['Dr. Smith', 'Dr. Johnson', 'Dr. Williams'],
          budget: 500000.0,
          principalInvestigator: 'Dr. Smith',
        ),
      ],
      recentResults: [
        ResearchResult(
          id: 'result-001',
          projectId: 'proj-001',
          title: 'Novel CAR-T Construct Shows Promise',
          description: 'Preclinical data demonstrates enhanced tumor targeting',
          type: ResultType.publication,
          publicationDate: DateTime(2024, 6, 15),
          authors: ['Smith J.', 'Johnson A.', 'Williams R.'],
          journal: 'Nature Biotechnology',
          doi: '10.1038/nbt.4567',
          createdAt: DateTime(2024, 6, 15),
        ),
      ],
      systemStatus: SystemStatus(
        isOnline: true,
        activeProjects: 5,
        completedProjects: 12,
        lastUpdate: DateTime.now(),
      ),
      completedProjects: 12,
      totalBudget: 2500000.0,
      publications: 45,
      patents: 8,
      clinicalTrials: 3,
      gpuHoursUsed: 1250,
      publicationsCount: 45,
      lastUpdate: DateTime.now(),
    );
  }
});

// Molecular Simulation Provider
final molecularSimulationProvider =
    FutureProvider.family<MolecularSimulationResult, String>(
        (ref, simulationId) async {
  final apiService = ref.watch(apiServiceProvider);

  try {
    final apiResp = await apiService.getTyped<MolecularSimulationResult>(
      '/research/simulations/$simulationId',
      (json) =>
          MolecularSimulationResult.fromJson(json as Map<String, dynamic>),
    );
    if (apiResp.success && apiResp.data != null) {
      return apiResp.data!;
    } else {
      throw Exception(apiResp.message ?? 'Failed to load molecular simulation');
    }
  } catch (e) {
    // Return mock data
    return MolecularSimulationResult(
      id: simulationId,
      moleculeName: 'Sample Molecule',
      energy: -125.5,
      trajectory: const TrajectoryData(
        frames: 1000,
        duration: 10.0,
        coordinates: [],
      ),
      energyProfile: const EnergyProfile(
        totalEnergy: -125.5,
        kineticEnergy: 45.2,
        potentialEnergy: -170.7,
      ),
      bindingSites: [
        const BindingSite(
          residue: 'ASP152',
          affinity: -8.5,
          interactions: ['Hydrogen Bond', 'Hydrophobic'],
        ),
      ],
    );
  }
});

// Cancer Research Provider
final tumorModelProvider =
    FutureProvider.family<TumorModel, String>((ref, tumorId) async {
  final apiService = ref.watch(apiServiceProvider);

  try {
    final apiResp = await apiService.getTyped<TumorModel>(
      '/research/tumors/$tumorId',
      (json) => TumorModel.fromJson(json as Map<String, dynamic>),
    );
    if (apiResp.success && apiResp.data != null) {
      return apiResp.data!;
    } else {
      throw Exception(apiResp.message ?? 'Failed to load tumor model');
    }
  } catch (e) {
    // Return mock data
    return TumorModel(
      id: tumorId,
      type: 'Adenocarcinoma',
      stage: 'IIB',
      cellularComposition: const CellularComposition(
        cancerCells: 0.75,
        stromalCells: 0.15,
        immuneCells: 0.08,
        other: 0.02,
      ),
      extracellularMatrix: const ECMComposition(
        collagen: 0.45,
        elastin: 0.15,
        proteoglycans: 0.25,
        other: 0.15,
      ),
      vascularNetwork: const VascularNetwork(
        density: 0.12,
        permeability: 0.85,
        tortuosity: 1.3,
      ),
      metabolicProfile: const MetabolicProfile(
        glycolysis: 0.78,
        oxidativePhosphorylation: 0.22,
        lactateProduction: 2.5,
      ),
    );
  }
});

// Tissue Engineering Provider
final scaffoldDesignProvider =
    FutureProvider.family<ScaffoldDesign, String>((ref, designId) async {
  final apiService = ref.watch(apiServiceProvider);

  try {
    final apiResp = await apiService.getTyped<ScaffoldDesign>(
      '/research/scaffolds/$designId',
      (json) => ScaffoldDesign.fromJson(json as Map<String, dynamic>),
    );
    if (apiResp.success && apiResp.data != null) {
      return apiResp.data!;
    } else {
      throw Exception(apiResp.message ?? 'Failed to load scaffold design');
    }
  } catch (e) {
    // Return mock data
    return ScaffoldDesign(
      id: designId,
      material: 'PLGA',
      porosity: 0.85,
      poreSize: 150.0,
      mechanicalProperties: const MechanicalProperties(
        youngsModulus: 2.5,
        tensileStrength: 45.0,
        elongation: 0.15,
      ),
      degradation: const DegradationProfile(
        halfLife: 90,
        mechanism: 'Hydrolysis',
      ),
    );
  }
});

// Medical Robotics Provider
final surgicalPlanProvider =
    FutureProvider.family<SurgicalPlan, String>((ref, planId) async {
  final apiService = ref.watch(apiServiceProvider);

  try {
    final apiResp = await apiService.getTyped<SurgicalPlan>(
      '/research/surgical-plans/$planId',
      (json) => SurgicalPlan.fromJson(json as Map<String, dynamic>),
    );
    if (apiResp.success && apiResp.data != null) {
      return apiResp.data!;
    } else {
      throw Exception(apiResp.message ?? 'Failed to load surgical plan');
    }
  } catch (e) {
    // Return mock data
    return SurgicalPlan(
      id: planId,
      procedure: 'Robotic-assisted laparoscopy',
      targetAnatomy: 'Gallbladder',
      approach: 'Transabdominal',
      instruments: ['Endoscope', 'Grasper', 'Cautery'],
      estimatedDuration: 120,
      riskAssessment: const RiskAssessment(
        overallRisk: 'Low',
        complications: ['Bleeding', 'Infection'],
        mitigationStrategies: ['Hemostatic agents', 'Antibiotic prophylaxis'],
      ),
    );
  }
});

// Computational Biology Provider
final genomeAnalysisProvider =
    FutureProvider.family<GenomeAnalysis, String>((ref, genomeId) async {
  final apiService = ref.watch(apiServiceProvider);

  try {
    final apiResp = await apiService.getTyped<GenomeAnalysis>(
      '/research/genomes/$genomeId',
      (json) => GenomeAnalysis.fromJson(json as Map<String, dynamic>),
    );
    if (apiResp.success && apiResp.data != null) {
      return apiResp.data!;
    } else {
      throw Exception(apiResp.message ?? 'Failed to load genome analysis');
    }
  } catch (e) {
    // Return mock data
    return GenomeAnalysis(
      id: genomeId,
      organism: 'Homo sapiens',
      chromosome: '17',
      genes: 1298,
      variants: const VariantAnalysis(
        snps: 45632,
        indels: 2341,
        cnvs: 89,
      ),
      expression: const GeneExpression(
        upregulated: 234,
        downregulated: 156,
        unchanged: 908,
      ),
    );
  }
});

// Drug Discovery Provider
final drugCandidateProvider =
    FutureProvider.family<DrugCandidate, String>((ref, compoundId) async {
  final apiService = ref.watch(apiServiceProvider);

  try {
    final apiResp = await apiService.getTyped<DrugCandidate>(
      '/research/drugs/$compoundId',
      (json) => DrugCandidate.fromJson(json as Map<String, dynamic>),
    );
    if (apiResp.success && apiResp.data != null) {
      return apiResp.data!;
    } else {
      throw Exception(apiResp.message ?? 'Failed to load drug candidate');
    }
  } catch (e) {
    // Return mock data
    return DrugCandidate(
      id: compoundId,
      name: 'Compound-001',
      molecularWeight: 345.2,
      logP: 2.8,
      solubility: 15.6,
      target: 'EGFR',
      ic50: 0.023,
      toxicity: const ToxicityProfile(
        ld50: 125.0,
        hepatotoxicity: 'Low',
        cardiotoxicity: 'Moderate',
      ),
    );
  }
});

// Research Projects Provider
final researchProjectsProvider =
    FutureProvider<List<ResearchProject>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);

  try {
    final apiResp = await apiService.getTyped<List<ResearchProject>>(
      '/research/projects',
      (json) {
        final List<dynamic> projectsJson =
            (json as Map<String, dynamic>)['projects'] ?? [];
        return projectsJson
            .map((item) =>
                ResearchProject.fromJson(item as Map<String, dynamic>))
            .toList();
      },
    );
    if (apiResp.success && apiResp.data != null) {
      return apiResp.data!;
    } else {
      throw Exception(apiResp.message ?? 'Failed to load research projects');
    }
  } catch (e) {
    // Return mock data
    return [
      ResearchProject(
        id: 'proj-001',
        title: 'Cancer Immunotherapy Development',
        description: 'Developing novel CAR-T cell therapies for solid tumors',
        type: ProjectType.cancerResearch,
        status: ProjectStatus.active,
        startDate: DateTime(2023, 1, 15),
        researchers: ['Dr. Smith', 'Dr. Johnson', 'Dr. Williams'],
        budget: 500000.0,
        principalInvestigator: 'Dr. Smith',
      ),
      ResearchProject(
        id: 'proj-002',
        title: 'Molecular Dynamics Simulation',
        description: 'High-throughput screening of drug-protein interactions',
        type: ProjectType.computationalBiology,
        status: ProjectStatus.active,
        startDate: DateTime(2023, 3, 1),
        researchers: ['Dr. Davis', 'Dr. Miller'],
        budget: 300000.0,
        principalInvestigator: 'Dr. Davis',
      ),
    ];
  }
});

// Research Results Provider
final researchResultsProvider =
    FutureProvider<List<ResearchResult>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);

  try {
    final apiResp = await apiService.getTyped<List<ResearchResult>>(
      '/research/results',
      (json) {
        final List<dynamic> resultsJson =
            (json as Map<String, dynamic>)['results'] ?? [];
        return resultsJson
            .map(
                (item) => ResearchResult.fromJson(item as Map<String, dynamic>))
            .toList();
      },
    );
    if (apiResp.success && apiResp.data != null) {
      return apiResp.data!;
    } else {
      throw Exception(apiResp.message ?? 'Failed to load research results');
    }
  } catch (e) {
    // Return mock data
    return [
      ResearchResult(
        id: 'result-001',
        projectId: 'proj-001',
        title: 'Novel CAR-T Construct Shows Promise',
        description: 'Preclinical data demonstrates enhanced tumor targeting',
        type: ResultType.publication,
        publicationDate: DateTime(2024, 6, 15),
        authors: ['Smith J.', 'Johnson A.', 'Williams R.'],
        journal: 'Nature Biotechnology',
        doi: '10.1038/nbt.4567',
        createdAt: DateTime(2024, 6, 15),
      ),
    ];
  }
});

// System Status Provider
final researchSystemStatusProvider = FutureProvider<SystemStatus>((ref) async {
  final apiService = ref.watch(apiServiceProvider);

  try {
    final apiResp = await apiService.getTyped<SystemStatus>(
      '/research/system/status',
      (json) => SystemStatus.fromJson(json as Map<String, dynamic>),
    );
    if (apiResp.success && apiResp.data != null) {
      return apiResp.data!;
    } else {
      throw Exception(apiResp.message ?? 'Failed to load system status');
    }
  } catch (e) {
    // Return mock data
    return SystemStatus(
      isOnline: true,
      activeProjects: 5,
      completedProjects: 12,
      lastUpdate: DateTime.now(),
    );
  }
});

// Mock classes for missing types
class ResearchDashboard {
  final List<ResearchProject> activeProjects;
  final List<ResearchResult> recentResults;
  final SystemStatus systemStatus;
  final int completedProjects;
  final double totalBudget;
  final int publications;
  final int patents;
  final int clinicalTrials;
  final int gpuHoursUsed;
  final int publicationsCount;
  final DateTime lastUpdate;

  const ResearchDashboard({
    required this.activeProjects,
    required this.recentResults,
    required this.systemStatus,
    required this.completedProjects,
    required this.totalBudget,
    required this.publications,
    required this.patents,
    required this.clinicalTrials,
    required this.gpuHoursUsed,
    required this.publicationsCount,
    required this.lastUpdate,
  });

  factory ResearchDashboard.fromJson(Map<String, dynamic> json) {
    return ResearchDashboard(
      activeProjects: (json['activeProjects'] as List<dynamic>? ?? [])
          .map((e) => ResearchProject.fromJson(e))
          .toList(),
      recentResults: (json['recentResults'] as List<dynamic>? ?? [])
          .map((e) => ResearchResult.fromJson(e))
          .toList(),
      systemStatus: SystemStatus.fromJson(json['systemStatus'] ?? {}),
      completedProjects: json['completedProjects'] ?? 0,
      totalBudget: (json['totalBudget'] ?? 0).toDouble(),
      publications: json['publications'] ?? 0,
      patents: json['patents'] ?? 0,
      clinicalTrials: json['clinicalTrials'] ?? 0,
      gpuHoursUsed: json['gpuHoursUsed'] ?? 0,
      publicationsCount: json['publicationsCount'] ?? 0,
      lastUpdate: DateTime.parse(
          json['lastUpdate'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class MolecularSimulationResult {
  final String id;
  final String moleculeName;
  final double energy;
  final TrajectoryData trajectory;
  final EnergyProfile energyProfile;
  final List<BindingSite> bindingSites;

  const MolecularSimulationResult({
    required this.id,
    required this.moleculeName,
    required this.energy,
    required this.trajectory,
    required this.energyProfile,
    required this.bindingSites,
  });

  factory MolecularSimulationResult.fromJson(Map<String, dynamic> json) {
    return MolecularSimulationResult(
      id: json['id'],
      moleculeName: json['moleculeName'],
      energy: json['energy'].toDouble(),
      trajectory: TrajectoryData.fromJson(json['trajectory']),
      energyProfile: EnergyProfile.fromJson(json['energyProfile']),
      bindingSites: (json['bindingSites'] as List)
          .map((e) => BindingSite.fromJson(e))
          .toList(),
    );
  }
}

class TrajectoryData {
  final int frames;
  final double duration;
  final List<dynamic> coordinates;

  const TrajectoryData({
    required this.frames,
    required this.duration,
    required this.coordinates,
  });

  factory TrajectoryData.fromJson(Map<String, dynamic> json) {
    return TrajectoryData(
      frames: json['frames'],
      duration: json['duration'].toDouble(),
      coordinates: json['coordinates'] ?? [],
    );
  }
}

class EnergyProfile {
  final double totalEnergy;
  final double kineticEnergy;
  final double potentialEnergy;

  const EnergyProfile({
    required this.totalEnergy,
    required this.kineticEnergy,
    required this.potentialEnergy,
  });

  factory EnergyProfile.fromJson(Map<String, dynamic> json) {
    return EnergyProfile(
      totalEnergy: json['totalEnergy'].toDouble(),
      kineticEnergy: json['kineticEnergy'].toDouble(),
      potentialEnergy: json['potentialEnergy'].toDouble(),
    );
  }
}

class BindingSite {
  final String residue;
  final double affinity;
  final List<String> interactions;

  const BindingSite({
    required this.residue,
    required this.affinity,
    required this.interactions,
  });

  factory BindingSite.fromJson(Map<String, dynamic> json) {
    return BindingSite(
      residue: json['residue'],
      affinity: json['affinity'].toDouble(),
      interactions: List<String>.from(json['interactions']),
    );
  }
}

class TumorModel {
  final String id;
  final String type;
  final String stage;
  final CellularComposition cellularComposition;
  final ECMComposition extracellularMatrix;
  final VascularNetwork vascularNetwork;
  final MetabolicProfile metabolicProfile;

  const TumorModel({
    required this.id,
    required this.type,
    required this.stage,
    required this.cellularComposition,
    required this.extracellularMatrix,
    required this.vascularNetwork,
    required this.metabolicProfile,
  });

  factory TumorModel.fromJson(Map<String, dynamic> json) {
    return TumorModel(
      id: json['id'],
      type: json['type'],
      stage: json['stage'],
      cellularComposition:
          CellularComposition.fromJson(json['cellularComposition']),
      extracellularMatrix: ECMComposition.fromJson(json['extracellularMatrix']),
      vascularNetwork: VascularNetwork.fromJson(json['vascularNetwork']),
      metabolicProfile: MetabolicProfile.fromJson(json['metabolicProfile']),
    );
  }
}

class CellularComposition {
  final double cancerCells;
  final double stromalCells;
  final double immuneCells;
  final double other;

  const CellularComposition({
    required this.cancerCells,
    required this.stromalCells,
    required this.immuneCells,
    required this.other,
  });

  factory CellularComposition.fromJson(Map<String, dynamic> json) {
    return CellularComposition(
      cancerCells: json['cancerCells'].toDouble(),
      stromalCells: json['stromalCells'].toDouble(),
      immuneCells: json['immuneCells'].toDouble(),
      other: json['other'].toDouble(),
    );
  }
}

class ECMComposition {
  final double collagen;
  final double elastin;
  final double proteoglycans;
  final double other;

  const ECMComposition({
    required this.collagen,
    required this.elastin,
    required this.proteoglycans,
    required this.other,
  });

  factory ECMComposition.fromJson(Map<String, dynamic> json) {
    return ECMComposition(
      collagen: json['collagen'].toDouble(),
      elastin: json['elastin'].toDouble(),
      proteoglycans: json['proteoglycans'].toDouble(),
      other: json['other'].toDouble(),
    );
  }
}

class VascularNetwork {
  final double density;
  final double permeability;
  final double tortuosity;

  const VascularNetwork({
    required this.density,
    required this.permeability,
    required this.tortuosity,
  });

  factory VascularNetwork.fromJson(Map<String, dynamic> json) {
    return VascularNetwork(
      density: json['density'].toDouble(),
      permeability: json['permeability'].toDouble(),
      tortuosity: json['tortuosity'].toDouble(),
    );
  }
}

class MetabolicProfile {
  final double glycolysis;
  final double oxidativePhosphorylation;
  final double lactateProduction;

  const MetabolicProfile({
    required this.glycolysis,
    required this.oxidativePhosphorylation,
    required this.lactateProduction,
  });

  factory MetabolicProfile.fromJson(Map<String, dynamic> json) {
    return MetabolicProfile(
      glycolysis: json['glycolysis'].toDouble(),
      oxidativePhosphorylation: json['oxidativePhosphorylation'].toDouble(),
      lactateProduction: json['lactateProduction'].toDouble(),
    );
  }
}

class ScaffoldDesign {
  final String id;
  final String material;
  final double porosity;
  final double poreSize;
  final MechanicalProperties mechanicalProperties;
  final DegradationProfile degradation;

  const ScaffoldDesign({
    required this.id,
    required this.material,
    required this.porosity,
    required this.poreSize,
    required this.mechanicalProperties,
    required this.degradation,
  });

  factory ScaffoldDesign.fromJson(Map<String, dynamic> json) {
    return ScaffoldDesign(
      id: json['id'],
      material: json['material'],
      porosity: json['porosity'].toDouble(),
      poreSize: json['poreSize'].toDouble(),
      mechanicalProperties:
          MechanicalProperties.fromJson(json['mechanicalProperties']),
      degradation: DegradationProfile.fromJson(json['degradation']),
    );
  }
}

class MechanicalProperties {
  final double youngsModulus;
  final double tensileStrength;
  final double elongation;

  const MechanicalProperties({
    required this.youngsModulus,
    required this.tensileStrength,
    required this.elongation,
  });

  factory MechanicalProperties.fromJson(Map<String, dynamic> json) {
    return MechanicalProperties(
      youngsModulus: json['youngsModulus'].toDouble(),
      tensileStrength: json['tensileStrength'].toDouble(),
      elongation: json['elongation'].toDouble(),
    );
  }
}

class DegradationProfile {
  final int halfLife;
  final String mechanism;

  const DegradationProfile({
    required this.halfLife,
    required this.mechanism,
  });

  factory DegradationProfile.fromJson(Map<String, dynamic> json) {
    return DegradationProfile(
      halfLife: json['halfLife'],
      mechanism: json['mechanism'],
    );
  }
}

class SurgicalPlan {
  final String id;
  final String procedure;
  final String targetAnatomy;
  final String approach;
  final List<String> instruments;
  final int estimatedDuration;
  final RiskAssessment riskAssessment;

  const SurgicalPlan({
    required this.id,
    required this.procedure,
    required this.targetAnatomy,
    required this.approach,
    required this.instruments,
    required this.estimatedDuration,
    required this.riskAssessment,
  });

  factory SurgicalPlan.fromJson(Map<String, dynamic> json) {
    return SurgicalPlan(
      id: json['id'],
      procedure: json['procedure'],
      targetAnatomy: json['targetAnatomy'],
      approach: json['approach'],
      instruments: List<String>.from(json['instruments']),
      estimatedDuration: json['estimatedDuration'],
      riskAssessment: RiskAssessment.fromJson(json['riskAssessment']),
    );
  }
}

class RiskAssessment {
  final String overallRisk;
  final List<String> complications;
  final List<String> mitigationStrategies;

  const RiskAssessment({
    required this.overallRisk,
    required this.complications,
    required this.mitigationStrategies,
  });

  factory RiskAssessment.fromJson(Map<String, dynamic> json) {
    return RiskAssessment(
      overallRisk: json['overallRisk'],
      complications: List<String>.from(json['complications']),
      mitigationStrategies: List<String>.from(json['mitigationStrategies']),
    );
  }
}

class GenomeAnalysis {
  final String id;
  final String organism;
  final String chromosome;
  final int genes;
  final VariantAnalysis variants;
  final GeneExpression expression;

  const GenomeAnalysis({
    required this.id,
    required this.organism,
    required this.chromosome,
    required this.genes,
    required this.variants,
    required this.expression,
  });

  factory GenomeAnalysis.fromJson(Map<String, dynamic> json) {
    return GenomeAnalysis(
      id: json['id'],
      organism: json['organism'],
      chromosome: json['chromosome'],
      genes: json['genes'],
      variants: VariantAnalysis.fromJson(json['variants']),
      expression: GeneExpression.fromJson(json['expression']),
    );
  }
}

class VariantAnalysis {
  final int snps;
  final int indels;
  final int cnvs;

  const VariantAnalysis({
    required this.snps,
    required this.indels,
    required this.cnvs,
  });

  factory VariantAnalysis.fromJson(Map<String, dynamic> json) {
    return VariantAnalysis(
      snps: json['snps'],
      indels: json['indels'],
      cnvs: json['cnvs'],
    );
  }
}

class GeneExpression {
  final int upregulated;
  final int downregulated;
  final int unchanged;

  const GeneExpression({
    required this.upregulated,
    required this.downregulated,
    required this.unchanged,
  });

  factory GeneExpression.fromJson(Map<String, dynamic> json) {
    return GeneExpression(
      upregulated: json['upregulated'],
      downregulated: json['downregulated'],
      unchanged: json['unchanged'],
    );
  }
}

class DrugCandidate {
  final String id;
  final String name;
  final double molecularWeight;
  final double logP;
  final double solubility;
  final String target;
  final double ic50;
  final ToxicityProfile toxicity;

  const DrugCandidate({
    required this.id,
    required this.name,
    required this.molecularWeight,
    required this.logP,
    required this.solubility,
    required this.target,
    required this.ic50,
    required this.toxicity,
  });

  factory DrugCandidate.fromJson(Map<String, dynamic> json) {
    return DrugCandidate(
      id: json['id'],
      name: json['name'],
      molecularWeight: json['molecularWeight'].toDouble(),
      logP: json['logP'].toDouble(),
      solubility: json['solubility'].toDouble(),
      target: json['target'],
      ic50: json['ic50'].toDouble(),
      toxicity: ToxicityProfile.fromJson(json['toxicity']),
    );
  }
}

class ToxicityProfile {
  final double ld50;
  final String hepatotoxicity;
  final String cardiotoxicity;

  const ToxicityProfile({
    required this.ld50,
    required this.hepatotoxicity,
    required this.cardiotoxicity,
  });

  factory ToxicityProfile.fromJson(Map<String, dynamic> json) {
    return ToxicityProfile(
      ld50: json['ld50'].toDouble(),
      hepatotoxicity: json['hepatotoxicity'],
      cardiotoxicity: json['cardiotoxicity'],
    );
  }
}
