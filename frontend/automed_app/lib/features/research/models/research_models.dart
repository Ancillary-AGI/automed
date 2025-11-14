enum ProjectType {
  cancerResearch,
  computationalBiology,
  medicalRobotics,
  molecularSimulation,
  tissueEngineering,
  molecular,
  cancer,
  tissue,
  robotics,
  biology,
  drug,
}

enum ProjectStatus {
  planning,
  active,
  paused,
  completed,
  cancelled,
  failed,
}

enum ResultType {
  publication,
  patent,
  clinicalTrial,
  software,
  data,
  simulation,
  analysis,
  prediction,
  visualization,
}

class ResearchProject {
  final String id;
  final String title;
  final String description;
  final ProjectType type;
  final ProjectStatus status;
  final DateTime startDate;
  final DateTime? endDate;
  final List<String> researchers;
  final double budget;
  final String principalInvestigator;
  final int progress; // Add progress property

  const ResearchProject({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    required this.startDate,
    this.endDate,
    required this.researchers,
    required this.budget,
    required this.principalInvestigator,
    this.progress = 0, // Default to 0
  });

  factory ResearchProject.fromJson(Map<String, dynamic> json) {
    return ResearchProject(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: ProjectType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ProjectType.cancerResearch,
      ),
      status: ProjectStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ProjectStatus.active,
      ),
      startDate:
          DateTime.parse(json['startDate'] ?? DateTime.now().toIso8601String()),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      researchers: List<String>.from(json['researchers'] ?? []),
      budget: (json['budget'] ?? 0).toDouble(),
      principalInvestigator: json['principalInvestigator'] ?? '',
      progress: json['progress'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'status': status.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'researchers': researchers,
      'budget': budget,
      'principalInvestigator': principalInvestigator,
      'progress': progress,
    };
  }
}

class ResearchResult {
  final String id;
  final String projectId;
  final String title;
  final String description;
  final ResultType type;
  final DateTime publicationDate;
  final List<String> authors;
  final String? doi;
  final String? journal;
  final DateTime createdAt; // Add createdAt property

  const ResearchResult({
    required this.id,
    required this.projectId,
    required this.title,
    required this.description,
    required this.type,
    required this.publicationDate,
    required this.authors,
    this.doi,
    this.journal,
    required this.createdAt, // Required createdAt
  });

  factory ResearchResult.fromJson(Map<String, dynamic> json) {
    return ResearchResult(
      id: json['id'] ?? '',
      projectId: json['projectId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: ResultType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ResultType.publication,
      ),
      publicationDate: DateTime.parse(
          json['publicationDate'] ?? DateTime.now().toIso8601String()),
      authors: List<String>.from(json['authors'] ?? []),
      doi: json['doi'],
      journal: json['journal'],
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'title': title,
      'description': description,
      'type': type.name,
      'publicationDate': publicationDate.toIso8601String(),
      'authors': authors,
      'doi': doi,
      'journal': journal,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class SystemStatus {
  final bool isOnline;
  final int activeProjects;
  final int completedProjects;
  final DateTime lastUpdate;
  final String overallHealth; // Add overallHealth property
  final int gpuUsage; // Add gpuUsage property
  final int storageUsage; // Add storageUsage property
  final int activeJobs; // Add activeJobs property

  const SystemStatus({
    required this.isOnline,
    required this.activeProjects,
    required this.completedProjects,
    required this.lastUpdate,
    this.overallHealth = 'healthy', // Default to healthy
    this.gpuUsage = 0, // Default to 0
    this.storageUsage = 0, // Default to 0
    this.activeJobs = 0, // Default to 0
  });

  factory SystemStatus.fromJson(Map<String, dynamic> json) {
    return SystemStatus(
      isOnline: json['isOnline'] ?? false,
      activeProjects: json['activeProjects'] ?? 0,
      completedProjects: json['completedProjects'] ?? 0,
      lastUpdate: DateTime.parse(
          json['lastUpdate'] ?? DateTime.now().toIso8601String()),
      overallHealth: json['overallHealth'] ?? 'healthy',
      gpuUsage: json['gpuUsage'] ?? 0,
      storageUsage: json['storageUsage'] ?? 0,
      activeJobs: json['activeJobs'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isOnline': isOnline,
      'activeProjects': activeProjects,
      'completedProjects': completedProjects,
      'lastUpdate': lastUpdate.toIso8601String(),
      'overallHealth': overallHealth,
      'gpuUsage': gpuUsage,
      'storageUsage': storageUsage,
      'activeJobs': activeJobs,
    };
  }
}
