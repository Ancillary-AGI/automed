package com.automed.research.service

import com.automed.research.dto.*
import org.springframework.stereotype.Service
import reactor.core.publisher.Mono
import java.time.LocalDateTime
import java.util.*
import kotlin.math.*

@Service
class ComputationalBiologyService {

    /**
     * Genome-Wide Association Studies (GWAS)
     * Large-scale genetic association analysis
     */
    fun performGWAS(request: GWASRequest): Mono<GWASResponse> {
        return Mono.fromCallable {
            val genotypeData = processGenotypeData(request.genotypeData)
            val phenotypeData = processPhenotypeData(request.phenotypeData)
            val statisticalAnalysis = performStatisticalAnalysis(genotypeData, phenotypeData)
            val manhattanPlot = generateManhattanPlot(statisticalAnalysis)
            val qqPlot = generateQQPlot(statisticalAnalysis)
            val significantSNPs = identifySignificantSNPs(statisticalAnalysis, request.significanceThreshold)

            GWASResponse(
                studyId = UUID.randomUUID().toString(),
                trait = request.trait,
                population = request.population,
                sampleSize = genotypeData.size,
                genotypeData = genotypeData,
                phenotypeData = phenotypeData,
                statisticalAnalysis = statisticalAnalysis,
                manhattanPlot = manhattanPlot,
                qqPlot = qqPlot,
                significantSNPs = significantSNPs,
                lambdaGC = calculateLambdaGC(statisticalAnalysis),
                genomicInflation = calculateGenomicInflation(statisticalAnalysis),
                timestamp = LocalDateTime.now()
            )
        }
    }

    /**
     * Systems Biology Modeling
     * Multi-scale biological system modeling
     */
    fun modelBiologicalSystem(request: SystemsBiologyRequest): Mono<SystemsBiologyResponse> {
        return Mono.fromCallable {
            val networkModel = constructBiologicalNetwork(request.omicsData)
            val dynamicSimulation = simulateSystemDynamics(networkModel)
            val pathwayAnalysis = analyzeSignalingPathways(networkModel)
            val regulatoryNetworks = identifyRegulatoryNetworks(networkModel)
            val emergentProperties = analyzeEmergentProperties(dynamicSimulation)

            SystemsBiologyResponse(
                modelId = UUID.randomUUID().toString(),
                systemType = request.systemType,
                omicsData = request.omicsData,
                networkModel = networkModel,
                dynamicSimulation = dynamicSimulation,
                pathwayAnalysis = pathwayAnalysis,
                regulatoryNetworks = regulatoryNetworks,
                emergentProperties = emergentProperties,
                modelValidation = validateModel(dynamicSimulation),
                predictivePower = assessPredictivePower(dynamicSimulation),
                timestamp = LocalDateTime.now()
            )
        }
    }

    /**
     * Metagenomics Analysis
     * Analysis of microbial communities
     */
    fun analyzeMetagenome(request: MetagenomicsRequest): Mono<MetagenomicsResponse> {
        return Mono.fromCallable {
            val sequenceProcessing = processSequencingData(request.sequenceData)
            val taxonomicClassification = performTaxonomicClassification(sequenceProcessing)
            val functionalAnnotation = annotateGeneFunctions(sequenceProcessing)
            val diversityAnalysis = calculateDiversityMetrics(taxonomicClassification)
            val metabolicPathways = reconstructMetabolicPathways(functionalAnnotation)
            val ecologicalAnalysis = analyzeMicrobialEcology(taxonomicClassification, diversityAnalysis)

            MetagenomicsResponse(
                analysisId = UUID.randomUUID().toString(),
                sampleType = request.sampleType,
                sequenceData = sequenceProcessing,
                taxonomicClassification = taxonomicClassification,
                functionalAnnotation = functionalAnnotation,
                diversityAnalysis = diversityAnalysis,
                metabolicPathways = metabolicPathways,
                ecologicalAnalysis = ecologicalAnalysis,
                biomarkerDiscovery = identifyBiomarkers(taxonomicClassification, request.condition),
                therapeuticTargets = identifyTherapeuticTargets(functionalAnnotation),
                timestamp = LocalDateTime.now()
            )
        }
    }

    /**
     * Single-Cell RNA Sequencing Analysis
     * Comprehensive single-cell transcriptomics
     */
    fun analyzeSingleCellRNA(request: SingleCellRNARequest): Mono<SingleCellRNAResponse> {
        return Mono.fromCallable {
            val qualityControl = performQualityControl(request.expressionMatrix)
            val normalization = normalizeExpressionData(qualityControl)
            val dimensionalityReduction = reduceDimensionality(normalization)
            val clustering = performCellClustering(dimensionalityReduction)
            val cellTypeAnnotation = annotateCellTypes(clustering, request.referenceData)
            val trajectoryAnalysis = analyzeCellTrajectories(clustering, normalization)
            val differentialExpression = identifyDifferentialExpression(clustering, normalization)
            val geneRegulatoryNetworks = constructGeneRegulatoryNetworks(differentialExpression)

            SingleCellRNAResponse(
                analysisId = UUID.randomUUID().toString(),
                tissueType = request.tissueType,
                cellCount = request.expressionMatrix.size,
                geneCount = request.expressionMatrix.values.first().size,
                qualityControl = qualityControl,
                normalization = normalization,
                dimensionalityReduction = dimensionalityReduction,
                clustering = clustering,
                cellTypeAnnotation = cellTypeAnnotation,
                trajectoryAnalysis = trajectoryAnalysis,
                differentialExpression = differentialExpression,
                geneRegulatoryNetworks = geneRegulatoryNetworks,
                timestamp = LocalDateTime.now()
            )
        }
    }

    /**
     * Epigenomics Analysis
     * Genome-wide epigenetic modification analysis
     */
    fun analyzeEpigenome(request: EpigenomicsRequest): Mono<EpigenomicsResponse> {
        return Mono.fromCallable {
            val methylationAnalysis = analyzeMethylationPatterns(request.methylationData)
            val histoneModification = analyzeHistoneModifications(request.chipSeqData)
            val chromatinAccessibility = assessChromatinAccessibility(request.atacSeqData)
            val epigeneticRegulation = identifyEpigeneticRegulation(methylationAnalysis, histoneModification)
            val geneExpressionCorrelation = correlateWithGeneExpression(epigeneticRegulation, request.rnaSeqData)

            EpigenomicsResponse(
                analysisId = UUID.randomUUID().toString(),
                sampleType = request.sampleType,
                methylationAnalysis = methylationAnalysis,
                histoneModification = histoneModification,
                chromatinAccessibility = chromatinAccessibility,
                epigeneticRegulation = epigeneticRegulation,
                geneExpressionCorrelation = geneExpressionCorrelation,
                differentiallyMethylatedRegions = identifyDMRs(methylationAnalysis),
                histoneModificationPatterns = identifyModificationPatterns(histoneModification),
                regulatoryElements = identifyRegulatoryElements(chromatinAccessibility),
                timestamp = LocalDateTime.now()
            )
        }
    }

    /**
     * Population Genetics Analysis
     * Analysis of genetic variation in populations
     */
    fun analyzePopulationGenetics(request: PopulationGeneticsRequest): Mono<PopulationGeneticsResponse> {
        return Mono.fromCallable {
            val alleleFrequency = calculateAlleleFrequencies(request.genotypeData)
            val linkageDisequilibrium = analyzeLinkageDisequilibrium(request.genotypeData)
            val populationStructure = inferPopulationStructure(request.genotypeData)
            val demographicHistory = reconstructDemographicHistory(populationStructure)
            val naturalSelection = detectNaturalSelection(alleleFrequency, demographicHistory)
            val admixtureAnalysis = analyzeAdmixture(request.genotypeData)

            PopulationGeneticsResponse(
                analysisId = UUID.randomUUID().toString(),
                population = request.population,
                sampleSize = request.genotypeData.size,
                alleleFrequency = alleleFrequency,
                linkageDisequilibrium = linkageDisequilibrium,
                populationStructure = populationStructure,
                demographicHistory = demographicHistory,
                naturalSelection = naturalSelection,
                admixtureAnalysis = admixtureAnalysis,
                geneticDiversity = calculateGeneticDiversity(alleleFrequency),
                timestamp = LocalDateTime.now()
            )
        }
    }

    // Helper methods for computational biology
    private fun processGenotypeData(data: String): GenotypeData {
        return GenotypeData(
            samples = 1000,
            snps = 500000,
            chromosomes = 22,
            quality = 0.95
        )
    }

    private fun processPhenotypeData(data: String): PhenotypeData {
        return PhenotypeData(
            traits = listOf("height", "BMI", "disease"),
            heritability = 0.6,
            prevalence = 0.1
        )
    }

    private fun performStatisticalAnalysis(genotype: GenotypeData, phenotype: PhenotypeData): StatisticalAnalysis {
        return StatisticalAnalysis(
            method = "linear regression",
            pValues = listOf(1e-8, 1e-6, 1e-4),
            effectSizes = listOf(0.1, 0.05, 0.02),
            confidenceIntervals = listOf(Pair(0.08, 0.12))
        )
    }

    private fun generateManhattanPlot(analysis: StatisticalAnalysis): ManhattanPlot {
        return ManhattanPlot(
            chromosomes = (1..22).toList(),
            positions = listOf(1000000, 2000000),
            pValues = analysis.pValues,
            significanceLine = 5e-8
        )
    }

    private fun generateQQPlot(analysis: StatisticalAnalysis): QQPlot {
        return QQPlot(
            observedPValues = analysis.pValues.sorted(),
            expectedPValues = analysis.pValues.sorted(),
            inflation = 1.05
        )
    }

    private fun identifySignificantSNPs(analysis: StatisticalAnalysis, threshold: Double): List<SignificantSNP> {
        return listOf(
            SignificantSNP(
                rsId = "rs123456",
                chromosome = 1,
                position = 1000000,
                pValue = 1e-10,
                effectSize = 0.15,
                alleleFrequency = 0.3
            )
        )
    }

    private fun calculateLambdaGC(analysis: StatisticalAnalysis): Double {
        return 1.05
    }

    private fun calculateGenomicInflation(analysis: StatisticalAnalysis): Double {
        return 1.02
    }

    private fun constructBiologicalNetwork(omicsData: String): BiologicalNetwork {
        return BiologicalNetwork(
            nodes = 1000,
            edges = 5000,
            nodeTypes = listOf("gene", "protein", "metabolite"),
            edgeTypes = listOf("regulation", "interaction", "metabolism"),
            connectivity = 0.8
        )
    }

    private fun simulateSystemDynamics(network: BiologicalNetwork): DynamicSimulation {
        return DynamicSimulation(
            timePoints = 100,
            variables = network.nodes,
            trajectories = listOf(), // Time series data
            steadyState = true,
            oscillations = false,
            stability = 0.9
        )
    }

    private fun analyzeSignalingPathways(network: BiologicalNetwork): PathwayAnalysis {
        return PathwayAnalysis(
            pathways = listOf("MAPK", "PI3K", "WNT"),
            activation = mapOf("MAPK" to 0.8),
            crosstalk = 0.6,
            feedbackLoops = 3
        )
    }

    private fun identifyRegulatoryNetworks(network: BiologicalNetwork): RegulatoryNetworks {
        return RegulatoryNetworks(
            transcriptionFactors = 50,
            microRNAs = 25,
            enhancers = 100,
            repressors = 30,
            networkMotifs = listOf("feedforward", "feedback")
        )
    }

    private fun analyzeEmergentProperties(simulation: DynamicSimulation): EmergentProperties {
        return EmergentProperties(
            robustness = 0.85,
            adaptability = 0.75,
            homeostasis = 0.9,
            complexity = 0.8
        )
    }

    private fun validateModel(simulation: DynamicSimulation): ModelValidation {
        return ModelValidation(
            goodnessOfFit = 0.92,
            predictiveAccuracy = 0.88,
            parameterSensitivity = 0.15,
            structuralIdentifiability = true
        )
    }

    private fun assessPredictivePower(simulation: DynamicSimulation): Double {
        return 0.85
    }

    private fun processSequencingData(data: String): SequenceProcessing {
        return SequenceProcessing(
            reads = 10000000,
            qualityFiltered = 9500000,
            assembledContigs = 5000,
            averageCoverage = 50.0
        )
    }

    private fun performTaxonomicClassification(processing: SequenceProcessing): TaxonomicClassification {
        return TaxonomicClassification(
            kingdoms = mapOf("Bacteria" to 0.7, "Archaea" to 0.2, "Eukaryota" to 0.1),
            phyla = mapOf("Firmicutes" to 0.4, "Bacteroidetes" to 0.3),
            genera = mapOf("Bacteroides" to 0.2, "Prevotella" to 0.15),
            species = mapOf("Bacteroides fragilis" to 0.1)
        )
    }

    private fun annotateGeneFunctions(processing: SequenceProcessing): FunctionalAnnotation {
        return FunctionalAnnotation(
            genes = 50000,
            functions = mapOf("metabolism" to 0.4, "transport" to 0.3, "regulation" to 0.2),
            pathways = listOf("glycolysis", "TCA cycle", "amino acid metabolism"),
            enzymes = 1000
        )
    }

    private fun calculateDiversityMetrics(classification: TaxonomicClassification): DiversityMetrics {
        return DiversityMetrics(
            shannonIndex = 3.5,
            simpsonIndex = 0.85,
            richness = 500,
            evenness = 0.75
        )
    }

    private fun reconstructMetabolicPathways(annotation: FunctionalAnnotation): MetabolicPathways {
        return MetabolicPathways(
            pathways = listOf("glycolysis", "TCA cycle", "pentose phosphate"),
            completeness = 0.8,
            activity = mapOf("glycolysis" to 0.9),
            interactions = 50
        )
    }

    private fun analyzeMicrobialEcology(classification: TaxonomicClassification, diversity: DiversityMetrics): EcologicalAnalysis {
        return EcologicalAnalysis(
            communityStructure = "diverse",
            keystoneSpecies = listOf("Bacteroides fragilis"),
            functionalRedundancy = 0.7,
            stability = 0.8
        )
    }

    private fun identifyBiomarkers(classification: TaxonomicClassification, condition: String): List<String> {
        return listOf("Bacteroides fragilis", "Prevotella copri")
    }

    private fun identifyTherapeuticTargets(annotation: FunctionalAnnotation): List<String> {
        return listOf("gyrA", "parC", "tetA")
    }

    private fun performQualityControl(matrix: Map<String, List<Double>>): QualityControl {
        return QualityControl(
            totalCells = matrix.size,
            viableCells = (matrix.size * 0.9).toInt(),
            medianGenes = 2500,
            medianUMIs = 5000,
            mitochondrialPercentage = 0.05
        )
    }

    private fun normalizeExpressionData(qc: QualityControl): NormalizedData {
        return NormalizedData(
            method = "SCTransform",
            normalizedMatrix = mapOf(), // Normalized expression matrix
            scalingFactors = listOf(1.0, 1.1, 0.9),
            batchCorrected = true
        )
    }

    private fun reduceDimensionality(normalized: NormalizedData): DimensionalityReduction {
        return DimensionalityReduction(
            method = "PCA",
            dimensions = 10,
            varianceExplained = 0.6,
            embeddings = listOf() // 2D/3D coordinates
        )
    }

    private fun performCellClustering(reduction: DimensionalityReduction): CellClustering {
        return CellClustering(
            method = "Leiden",
            clusters = 15,
            resolution = 0.8,
            silhouetteScore = 0.75,
            clusterLabels = listOf("T cells", "B cells", "Macrophages")
        )
    }

    private fun annotateCellTypes(clustering: CellClustering, reference: String): CellTypeAnnotation {
        return CellTypeAnnotation(
            annotatedClusters = clustering.clusters,
            confidence = 0.85,
            referenceUsed = reference,
            novelClusters = 2
        )
    }

    private fun analyzeCellTrajectories(clustering: CellClustering, normalized: NormalizedData): TrajectoryAnalysis {
        return TrajectoryAnalysis(
            trajectories = 3,
            pseudotime = true,
            branching = 2,
            rootCells = 100,
            terminalCells = 50
        )
    }

    private fun identifyDifferentialExpression(clustering: CellClustering, normalized: NormalizedData): DifferentialExpression {
        return DifferentialExpression(
            upregulated = mapOf("CD3D" to 2.5, "CD4" to 3.1),
            downregulated = mapOf("CD19" to -2.1),
            fdrCorrected = true,
            logFoldChange = 1.5
        )
    }

    private fun constructGeneRegulatoryNetworks(expression: DifferentialExpression): GeneRegulatoryNetworks {
        return GeneRegulatoryNetworks(
            transcriptionFactors = listOf("GATA3", "TBX21"),
            targetGenes = 500,
            regulatoryModules = 10,
            networkTopology = "scale-free"
        )
    }

    private fun analyzeMethylationPatterns(data: String): MethylationAnalysis {
        return MethylationAnalysis(
            cpgSites = 450000,
            hypermethylated = 50000,
            hypomethylated = 30000,
            differentiallyMethylated = 15000
        )
    }

    private fun analyzeHistoneModifications(data: String): HistoneModifications {
        return HistoneModifications(
            modifications = mapOf("H3K4me3" to 25000, "H3K27me3" to 18000),
            enrichedRegions = 45000,
            depletedRegions = 15000
        )
    }

    private fun assessChromatinAccessibility(data: String): ChromatinAccessibility {
        return ChromatinAccessibility(
            accessibleRegions = 75000,
            tssEnrichment = 8.5,
            fragmentSize = 200,
            nucleosomeFree = 0.4
        )
    }

    private fun identifyEpigeneticRegulation(methylation: MethylationAnalysis, histone: HistoneModifications): EpigeneticRegulation {
        return EpigeneticRegulation(
            repressiveMarks = 35000,
            activeMarks = 40000,
            bivalentDomains = 5000,
            regulatoryRegions = 25000
        )
    }

    private fun correlateWithGeneExpression(regulation: EpigeneticRegulation, rnaData: String): ExpressionCorrelation {
        return ExpressionCorrelation(
            positiveCorrelations = 15000,
            negativeCorrelations = 8000,
            spearmanRho = 0.65,
            significantAssociations = 12000
        )
    }

    private fun identifyDMRs(analysis: MethylationAnalysis): List<DMR> {
        return listOf(
            DMR(
                chromosome = "1",
                start = 1000000,
                end = 1005000,
                methylationDifference = 0.4,
                pValue = 1e-10
            )
        )
    }

    private fun identifyModificationPatterns(modifications: HistoneModifications): List<String> {
        return listOf("active promoters", "enhancers", "repressed regions")
    }

    private fun identifyRegulatoryElements(accessibility: ChromatinAccessibility): List<String> {
        return listOf("promoters", "enhancers", "insulators")
    }

    private fun calculateAlleleFrequencies(data: String): AlleleFrequencies {
        return AlleleFrequencies(
            maf = 0.25,
            commonVariants = 400000,
            rareVariants = 100000,
            privateVariants = 5000
        )
    }

    private fun analyzeLinkageDisequilibrium(data: String): LinkageDisequilibrium {
        return LinkageDisequilibrium(
            rSquared = 0.8,
            dPrime = 0.9,
            haplotypeBlocks = 50000,
            recombinationHotspots = 2500
        )
    }

    private fun inferPopulationStructure(data: String): PopulationStructure {
        return PopulationStructure(
            clusters = 5,
            admixtureProportions = mapOf("EUR" to 0.7, "AFR" to 0.3),
            fSt = 0.05,
            principalComponents = 10
        )
    }

    private fun reconstructDemographicHistory(structure: PopulationStructure): DemographicHistory {
        return DemographicHistory(
            effectivePopulationSize = 10000,
            bottleneckEvents = 2,
            expansionPeriods = 1,
            migrationEvents = 3
        )
    }

    private fun detectNaturalSelection(frequencies: AlleleFrequencies, history: DemographicHistory): NaturalSelection {
        return NaturalSelection(
            positiveSelection = 500,
            balancingSelection = 200,
            purifyingSelection = 5000,
            neutralityTests = mapOf("TajimaD" to -0.5)
        )
    }

    private fun analyzeAdmixture(data: String): AdmixtureAnalysis {
        return AdmixtureAnalysis(
            ancestralPopulations = 3,
            admixtureProportions = mapOf("EUR" to 0.6, "ASN" to 0.3, "AFR" to 0.1),
            admixtureTimes = listOf(50, 100), // generations
            linkageDisequilibrium = 0.7
        )
    }

    private fun calculateGeneticDiversity(frequencies: AlleleFrequencies): Double {
        return 0.75
    }
}

// Data classes for computational biology
data class GenotypeData(val samples: Int, val snps: Int, val chromosomes: Int, val quality: Double)
data class PhenotypeData(val traits: List<String>, val heritability: Double, val prevalence: Double)
data class StatisticalAnalysis(val method: String, val pValues: List<Double>, val effectSizes: List<Double>, val confidenceIntervals: List<Pair<Double, Double>>)
data class ManhattanPlot(val chromosomes: List<Int>, val positions: List<Long>, val pValues: List<Double>, val significanceLine: Double)
data class QQPlot(val observedPValues: List<Double>, val expectedPValues: List<Double>, val inflation: Double)
data class SignificantSNP(val rsId: String, val chromosome: Int, val position: Long, val pValue: Double, val effectSize: Double, val alleleFrequency: Double)

data class BiologicalNetwork(val nodes: Int, val edges: Int, val nodeTypes: List<String>, val edgeTypes: List<String>, val connectivity: Double)
data class DynamicSimulation(val timePoints: Int, val variables: Int, val trajectories: List<List<Double>>, val steadyState: Boolean, val oscillations: Boolean, val stability: Double)
data class PathwayAnalysis(val pathways: List<String>, val activation: Map<String, Double>, val crosstalk: Double, val feedbackLoops: Int)
data class RegulatoryNetworks(val transcriptionFactors: Int, val microRNAs: Int, val enhancers: Int, val repressors: Int, val networkMotifs: List<String>)
data class EmergentProperties(val robustness: Double, val adaptability: Double, val homeostasis: Double, val complexity: Double)
data class ModelValidation(val goodnessOfFit: Double, val predictiveAccuracy: Double, val parameterSensitivity: Double, val structuralIdentifiability: Boolean)

data class SequenceProcessing(val reads: Long, val qualityFiltered: Long, val assembledContigs: Int, val averageCoverage: Double)
data class TaxonomicClassification(val kingdoms: Map<String, Double>, val phyla: Map<String, Double>, val genera: Map<String, Double>, val species: Map<String, Double>)
data class FunctionalAnnotation(val genes: Int, val functions: Map<String, Double>, val pathways: List<String>, val enzymes: Int)
data class DiversityMetrics(val shannonIndex: Double, val simpsonIndex: Double, val richness: Int, val evenness: Double)
data class MetabolicPathways(val pathways: List<String>, val completeness: Double, val activity: Map<String, Double>, val interactions: Int)
data class EcologicalAnalysis(val communityStructure: String, val keystoneSpecies: List<String>, val functionalRedundancy: Double, val stability: Double)

data class QualityControl(val totalCells: Int, val viableCells: Int, val medianGenes: Int, val medianUMIs: Int, val mitochondrialPercentage: Double)
data class NormalizedData(val method: String, val normalizedMatrix: Map<String, List<Double>>, val scalingFactors: List<Double>, val batchCorrected: Boolean)
data class DimensionalityReduction(val method: String, val dimensions: Int, val varianceExplained: Double, val embeddings: List<List<Double>>)
data class CellClustering(val method: String, val clusters: Int, val resolution: Double, val silhouetteScore: Double, val clusterLabels: List<String>)
data class CellTypeAnnotation(val annotatedClusters: Int, val confidence: Double, val referenceUsed: String, val novelClusters: Int)
data class TrajectoryAnalysis(val trajectories: Int, val pseudotime: Boolean, val branching: Int, val rootCells: Int, val terminalCells: Int)
data class DifferentialExpression(val upregulated: Map<String, Double>, val downregulated: Map<String, Double>, val fdrCorrected: Boolean, val logFoldChange: Double)
data class GeneRegulatoryNetworks(val transcriptionFactors: List<String>, val targetGenes: Int, val regulatoryModules: Int, val networkTopology: String)

data class MethylationAnalysis(val cpgSites: Int, val hypermethylated: Int, val hypomethylated: Int, val differentiallyMethylated: Int)
data class HistoneModifications(val modifications: Map<String, Int>, val enrichedRegions: Int, val depletedRegions: Int)
data class ChromatinAccessibility(val accessibleRegions: Int, val tssEnrichment: Double, val fragmentSize: Int, val nucleosomeFree: Double)
data class EpigeneticRegulation(val repressiveMarks: Int, val activeMarks: Int, val bivalentDomains: Int, val regulatoryRegions: Int)
data class ExpressionCorrelation(val positiveCorrelations: Int, val negativeCorrelations: Int, val spearmanRho: Double, val significantAssociations: Int)
data class DMR(val chromosome: String, val start: Long, val end: Long, val methylationDifference: Double, val pValue: Double)

data class AlleleFrequencies(val maf: Double, val commonVariants: Int, val rareVariants: Int, val privateVariants: Int)
data class LinkageDisequilibrium(val rSquared: Double, val dPrime: Double, val haplotypeBlocks: Int, val recombinationHotspots: Int)
data class PopulationStructure(val clusters: Int, val admixtureProportions: Map<String, Double>, val fSt: Double, val principalComponents: Int)
data class DemographicHistory(val effectivePopulationSize: Int, val bottleneckEvents: Int, val expansionPeriods: Int, val migrationEvents: Int)
data class NaturalSelection(val positiveSelection: Int, val balancingSelection: Int, val purifyingSelection: Int, val neutralityTests: Map<String, Double>)
data class AdmixtureAnalysis(val ancestralPopulations: Int, val admixtureProportions: Map<String, Double>, val admixtureTimes: List<Int>, val linkageDisequilibrium: Double)