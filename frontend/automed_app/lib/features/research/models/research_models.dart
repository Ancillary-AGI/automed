enum ProjectType {
  molecular,
  cancer,
  tissue,
  robotics,
  biology,
  drug,
}

enum ProjectStatus {
  active,
  paused,
  completed,
  failed,
}

enum ResultType {
  simulation,
  analysis,
  prediction,
  visualization,
}

class ResearchDashboard {
  final List<ResearchProject> activeProjects;
  final List<ResearchResult> recentResults;
  final SystemStatus systemStatus;
  final int gpuHoursUsed;
  final int publicationsCount;

  const ResearchDashboard({
    required this.activeProjects,
    required this.recentResults,
    required this.systemStatus,
    required this.gpuHoursUsed,
    required this.publicationsCount,
  });

  factory ResearchDashboard.fromJson(Map<String, dynamic> json) {
    return ResearchDashboard(
      activeProjects: (json['activeProjects'] as List)
          .map((e) => ResearchProject.fromJson(e))
          .toList(),
      recentResults: (json['recentResults'] as List)
          .map((e) => ResearchResult.fromJson(e))
          .toList(),
      systemStatus: SystemStatus.fromJson(json['systemStatus']),
      gpuHoursUsed: json['gpuHoursUsed'] ?? 0,
      publicationsCount: json['publicationsCount'] ?? 0,
    );
  }
}

class ResearchProject {
  final String id;
  final String name;
  final String description;
  final ProjectType type;
  final ProjectStatus status;
  final int progress;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ResearchProject({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.status,
    required this.progress,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ResearchProject.fromJson(Map<String, dynamic> json) {
    return ResearchProject(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type: ProjectType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ProjectType.molecular,
      ),
      status: ProjectStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ProjectStatus.active,
      ),
      progress: json['progress'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class ResearchResult {
  final String id;
  final String title;
  final String description;
  final ResultType type;
  final DateTime createdAt;
  final Map<String, dynamic> metadata;

  const ResearchResult({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.createdAt,
    required this.metadata,
  });

  factory ResearchResult.fromJson(Map<String, dynamic> json) {
    return ResearchResult(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: ResultType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ResultType.analysis,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      metadata: json['metadata'] ?? {},
    );
  }
}

class SystemStatus {
  final String overallHealth;
  final double gpuUsage;
  final double storageUsage;
  final int activeJobs;
  final Map<String, String> serviceStatus;

  const SystemStatus({
    required this.overallHealth,
    required this.gpuUsage,
    required this.storageUsage,
    required this.activeJobs,
    required this.serviceStatus,
  });

  factory SystemStatus.fromJson(Map<String, dynamic> json) {
    return SystemStatus(
      overallHealth: json['overallHealth'] ?? 'unknown',
      gpuUsage: (json['gpuUsage'] ?? 0.0).toDouble(),
      storageUsage: (json['storageUsage'] ?? 0.0).toDouble(),
      activeJobs: json['activeJobs'] ?? 0,
      serviceStatus: Map<String, String>.from(json['serviceStatus'] ?? {}),
    );
  }
}

// Molecular Simulation Models
class MolecularSimulationResult {
  final String simulationId;
  final String molecule;
  final TrajectoryData trajectory;
  final EnergyProfile energyProfile;
  final List<BindingSite> bindingSites;
  final double stabilityScore;
  final double simulationTime;

  const MolecularSimulationResult({
    required this.simulationId,
    required this.molecule,
    required this.trajectory,
    required this.energyProfile,
    required this.bindingSites,
    required this.stabilityScore,
    required this.simulationTime,
  });
}

class TrajectoryData {
  final List<List<double>> coordinates;
  final List<double> timestamps;
  final int totalFrames;

  const TrajectoryData({
    required this.coordinates,
    required this.timestamps,
    required this.totalFrames,
  });
}

class EnergyProfile {
  final double potentialEnergy;
  final double kineticEnergy;
  final double totalEnergy;

  const EnergyProfile({
    required this.potentialEnergy,
    required this.kineticEnergy,
    required this.totalEnergy,
  });
}

class BindingSite {
  final List<String> residues;
  final double affinity;
  final double probability;

  const BindingSite({
    required this.residues,
    required this.affinity,
    required this.probability,
  });
}

// Cancer Research Models
class TumorModel {
  final String tumorId;
  final String type;
  final CellularComposition cellularComposition;
  final ECMComposition extracellularMatrix;
  final VascularNetwork vascularNetwork;
  final MetabolicProfile metabolicProfile;
  final double hypoxiaLevel;
  final double phGradient;

  const TumorModel({
    required this.tumorId,
    required this.type,
    required this.cellularComposition,
    required this.extracellularMatrix,
    required this.vascularNetwork,
    required this.metabolicProfile,
    required this.hypoxiaLevel,
    required this.phGradient,
  });
}

class CellularComposition {
  final double cancerCells;
  final double stromalCells;
  final double immuneCells;
  final double endothelialCells;

  const CellularComposition({
    required this.cancerCells,
    required this.stromalCells,
    required this.immuneCells,
    required this.endothelialCells,
  });
}

class ECMComposition {
  final double collagen;
  final double hyaluronicAcid;
  final double fibronectin;
  final double laminin;
  final double stiffness;

  const ECMComposition({
    required this.collagen,
    required this.hyaluronicAcid,
    required this.fibronectin,
    required this.laminin,
    required this.stiffness,
  });
}

class VascularNetwork {
  final double vesselDensity;
  final double tortuosity;
  final double perfusion;
  final double leakiness;

  const VascularNetwork({
    required this.vesselDensity,
    required this.tortuosity,
    required this.perfusion,
    required this.leakiness,
  });
}

class MetabolicProfile {
  final double glycolysis;
  final double oxidativePhosphorylation;
  final double lactateProduction;
  final double glutamineConsumption;

  const MetabolicProfile({
    required this.glycolysis,
    required this.oxidativePhosphorylation,
    required this.lactateProduction,
    required this.glutamineConsumption,
  });
}

// Tissue Engineering Models
class ScaffoldDesign {
  final String structure;
  final List<String> materials;
  final double porosity;
  final String fabricationMethod;
  final double optimizationScore;

  const ScaffoldDesign({
    required this.structure,
    required this.materials,
    required this.porosity,
    required this.fabricationMethod,
    required this.optimizationScore,
  });
}

class MechanicalProperties {
  final double youngsModulus;
  final double tensileStrength;
  final double compressiveStrength;
  final double elasticity;

  const MechanicalProperties({
    required this.youngsModulus,
    required this.tensileStrength,
    required this.compressiveStrength,
    required this.elasticity,
  });
}

// Medical Robotics Models
class SurgicalPlan {
  final String planId;
  final String procedureType;
  final List<double> trajectory;
  final List<int> waypoints;
  final double safetyMargins;
  final double precision;

  const SurgicalPlan({
    required this.planId,
    required this.procedureType,
    required this.trajectory,
    required this.waypoints,
    required this.safetyMargins,
    required this.precision,
  });
}

class RoboticCapabilities {
  final int degreesOfFreedom;
  final double precision;
  final double forceControl;
  final bool hapticFeedback;
  final bool realTimeImaging;

  const RoboticCapabilities({
    required this.degreesOfFreedom,
    required this.precision,
    required this.forceControl,
    required this.hapticFeedback,
    required this.realTimeImaging,
  });
}

// Computational Biology Models
class GenomeAnalysis {
  final String genomeId;
  final int totalVariants;
  final int codingVariants;
  final int pathogenicVariants;
  final double heterozygosity;
  final List<String> diseaseGenes;

  const GenomeAnalysis({
    required this.genomeId,
    required this.totalVariants,
    required this.codingVariants,
    required this.pathogenicVariants,
    required this.heterozygosity,
    required this.diseaseGenes,
  });
}

class ProteomeAnalysis {
  final String proteomeId;
  final int totalProteins;
  final int differentiallyExpressed;
  final List<String> upregulated;
  final List<String> downregulated;
  final Map<String, double> pathwayEnrichment;

  const ProteomeAnalysis({
    required this.proteomeId,
    required this.totalProteins,
    required this.differentiallyExpressed,
    required this.upregulated,
    required this.downregulated,
    required this.pathwayEnrichment,
  });
}

// Drug Development Models
class DrugCandidate {
  final String compoundId;
  final String smiles;
  final String name;
  final double molecularWeight;
  final double logP;
  final double bindingAffinity;
  final Map<String, double> admetProperties;

  const DrugCandidate({
    required this.compoundId,
    required this.smiles,
    required this.name,
    required this.molecularWeight,
    required this.logP,
    required this.bindingAffinity,
    required this.admetProperties,
  });
}

class VirtualScreeningResult {
  final String screeningId;
  final List<DrugCandidate> hits;
  final int totalCompounds;
  final double enrichmentFactor;
  final double hitRate;

  const VirtualScreeningResult({
    required this.screeningId,
    required this.hits,
    required this.totalCompounds,
    required this.enrichmentFactor,
    required this.hitRate,
  });
}
