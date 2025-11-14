// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'analytics_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AnalyticsDashboardData _$AnalyticsDashboardDataFromJson(
    Map<String, dynamic> json) {
  return _AnalyticsDashboardData.fromJson(json);
}

/// @nodoc
mixin _$AnalyticsDashboardData {
  int get activePatients => throw _privateConstructorUsedError;
  double get patientGrowth => throw _privateConstructorUsedError;
  int get criticalAlerts => throw _privateConstructorUsedError;
  double get alertTrend => throw _privateConstructorUsedError;
  double get bedOccupancy => throw _privateConstructorUsedError;
  double get occupancyTrend => throw _privateConstructorUsedError;
  double get avgResponseTime => throw _privateConstructorUsedError;
  double get responseTrend => throw _privateConstructorUsedError;
  RealTimeMetrics get realTimeMetrics => throw _privateConstructorUsedError;
  PredictiveInsights get predictiveInsights =>
      throw _privateConstructorUsedError;
  PerformanceKpis get performanceKpis => throw _privateConstructorUsedError;
  PopulationHealth get populationHealth => throw _privateConstructorUsedError;
  List<SystemService> get systemServices => throw _privateConstructorUsedError;
  DateTime get lastUpdated => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AnalyticsDashboardDataCopyWith<AnalyticsDashboardData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AnalyticsDashboardDataCopyWith<$Res> {
  factory $AnalyticsDashboardDataCopyWith(AnalyticsDashboardData value,
          $Res Function(AnalyticsDashboardData) then) =
      _$AnalyticsDashboardDataCopyWithImpl<$Res, AnalyticsDashboardData>;
  @useResult
  $Res call(
      {int activePatients,
      double patientGrowth,
      int criticalAlerts,
      double alertTrend,
      double bedOccupancy,
      double occupancyTrend,
      double avgResponseTime,
      double responseTrend,
      RealTimeMetrics realTimeMetrics,
      PredictiveInsights predictiveInsights,
      PerformanceKpis performanceKpis,
      PopulationHealth populationHealth,
      List<SystemService> systemServices,
      DateTime lastUpdated});

  $RealTimeMetricsCopyWith<$Res> get realTimeMetrics;
  $PredictiveInsightsCopyWith<$Res> get predictiveInsights;
  $PerformanceKpisCopyWith<$Res> get performanceKpis;
  $PopulationHealthCopyWith<$Res> get populationHealth;
}

/// @nodoc
class _$AnalyticsDashboardDataCopyWithImpl<$Res,
        $Val extends AnalyticsDashboardData>
    implements $AnalyticsDashboardDataCopyWith<$Res> {
  _$AnalyticsDashboardDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? activePatients = null,
    Object? patientGrowth = null,
    Object? criticalAlerts = null,
    Object? alertTrend = null,
    Object? bedOccupancy = null,
    Object? occupancyTrend = null,
    Object? avgResponseTime = null,
    Object? responseTrend = null,
    Object? realTimeMetrics = null,
    Object? predictiveInsights = null,
    Object? performanceKpis = null,
    Object? populationHealth = null,
    Object? systemServices = null,
    Object? lastUpdated = null,
  }) {
    return _then(_value.copyWith(
      activePatients: null == activePatients
          ? _value.activePatients
          : activePatients // ignore: cast_nullable_to_non_nullable
              as int,
      patientGrowth: null == patientGrowth
          ? _value.patientGrowth
          : patientGrowth // ignore: cast_nullable_to_non_nullable
              as double,
      criticalAlerts: null == criticalAlerts
          ? _value.criticalAlerts
          : criticalAlerts // ignore: cast_nullable_to_non_nullable
              as int,
      alertTrend: null == alertTrend
          ? _value.alertTrend
          : alertTrend // ignore: cast_nullable_to_non_nullable
              as double,
      bedOccupancy: null == bedOccupancy
          ? _value.bedOccupancy
          : bedOccupancy // ignore: cast_nullable_to_non_nullable
              as double,
      occupancyTrend: null == occupancyTrend
          ? _value.occupancyTrend
          : occupancyTrend // ignore: cast_nullable_to_non_nullable
              as double,
      avgResponseTime: null == avgResponseTime
          ? _value.avgResponseTime
          : avgResponseTime // ignore: cast_nullable_to_non_nullable
              as double,
      responseTrend: null == responseTrend
          ? _value.responseTrend
          : responseTrend // ignore: cast_nullable_to_non_nullable
              as double,
      realTimeMetrics: null == realTimeMetrics
          ? _value.realTimeMetrics
          : realTimeMetrics // ignore: cast_nullable_to_non_nullable
              as RealTimeMetrics,
      predictiveInsights: null == predictiveInsights
          ? _value.predictiveInsights
          : predictiveInsights // ignore: cast_nullable_to_non_nullable
              as PredictiveInsights,
      performanceKpis: null == performanceKpis
          ? _value.performanceKpis
          : performanceKpis // ignore: cast_nullable_to_non_nullable
              as PerformanceKpis,
      populationHealth: null == populationHealth
          ? _value.populationHealth
          : populationHealth // ignore: cast_nullable_to_non_nullable
              as PopulationHealth,
      systemServices: null == systemServices
          ? _value.systemServices
          : systemServices // ignore: cast_nullable_to_non_nullable
              as List<SystemService>,
      lastUpdated: null == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $RealTimeMetricsCopyWith<$Res> get realTimeMetrics {
    return $RealTimeMetricsCopyWith<$Res>(_value.realTimeMetrics, (value) {
      return _then(_value.copyWith(realTimeMetrics: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $PredictiveInsightsCopyWith<$Res> get predictiveInsights {
    return $PredictiveInsightsCopyWith<$Res>(_value.predictiveInsights,
        (value) {
      return _then(_value.copyWith(predictiveInsights: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $PerformanceKpisCopyWith<$Res> get performanceKpis {
    return $PerformanceKpisCopyWith<$Res>(_value.performanceKpis, (value) {
      return _then(_value.copyWith(performanceKpis: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $PopulationHealthCopyWith<$Res> get populationHealth {
    return $PopulationHealthCopyWith<$Res>(_value.populationHealth, (value) {
      return _then(_value.copyWith(populationHealth: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AnalyticsDashboardDataImplCopyWith<$Res>
    implements $AnalyticsDashboardDataCopyWith<$Res> {
  factory _$$AnalyticsDashboardDataImplCopyWith(
          _$AnalyticsDashboardDataImpl value,
          $Res Function(_$AnalyticsDashboardDataImpl) then) =
      __$$AnalyticsDashboardDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int activePatients,
      double patientGrowth,
      int criticalAlerts,
      double alertTrend,
      double bedOccupancy,
      double occupancyTrend,
      double avgResponseTime,
      double responseTrend,
      RealTimeMetrics realTimeMetrics,
      PredictiveInsights predictiveInsights,
      PerformanceKpis performanceKpis,
      PopulationHealth populationHealth,
      List<SystemService> systemServices,
      DateTime lastUpdated});

  @override
  $RealTimeMetricsCopyWith<$Res> get realTimeMetrics;
  @override
  $PredictiveInsightsCopyWith<$Res> get predictiveInsights;
  @override
  $PerformanceKpisCopyWith<$Res> get performanceKpis;
  @override
  $PopulationHealthCopyWith<$Res> get populationHealth;
}

/// @nodoc
class __$$AnalyticsDashboardDataImplCopyWithImpl<$Res>
    extends _$AnalyticsDashboardDataCopyWithImpl<$Res,
        _$AnalyticsDashboardDataImpl>
    implements _$$AnalyticsDashboardDataImplCopyWith<$Res> {
  __$$AnalyticsDashboardDataImplCopyWithImpl(
      _$AnalyticsDashboardDataImpl _value,
      $Res Function(_$AnalyticsDashboardDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? activePatients = null,
    Object? patientGrowth = null,
    Object? criticalAlerts = null,
    Object? alertTrend = null,
    Object? bedOccupancy = null,
    Object? occupancyTrend = null,
    Object? avgResponseTime = null,
    Object? responseTrend = null,
    Object? realTimeMetrics = null,
    Object? predictiveInsights = null,
    Object? performanceKpis = null,
    Object? populationHealth = null,
    Object? systemServices = null,
    Object? lastUpdated = null,
  }) {
    return _then(_$AnalyticsDashboardDataImpl(
      activePatients: null == activePatients
          ? _value.activePatients
          : activePatients // ignore: cast_nullable_to_non_nullable
              as int,
      patientGrowth: null == patientGrowth
          ? _value.patientGrowth
          : patientGrowth // ignore: cast_nullable_to_non_nullable
              as double,
      criticalAlerts: null == criticalAlerts
          ? _value.criticalAlerts
          : criticalAlerts // ignore: cast_nullable_to_non_nullable
              as int,
      alertTrend: null == alertTrend
          ? _value.alertTrend
          : alertTrend // ignore: cast_nullable_to_non_nullable
              as double,
      bedOccupancy: null == bedOccupancy
          ? _value.bedOccupancy
          : bedOccupancy // ignore: cast_nullable_to_non_nullable
              as double,
      occupancyTrend: null == occupancyTrend
          ? _value.occupancyTrend
          : occupancyTrend // ignore: cast_nullable_to_non_nullable
              as double,
      avgResponseTime: null == avgResponseTime
          ? _value.avgResponseTime
          : avgResponseTime // ignore: cast_nullable_to_non_nullable
              as double,
      responseTrend: null == responseTrend
          ? _value.responseTrend
          : responseTrend // ignore: cast_nullable_to_non_nullable
              as double,
      realTimeMetrics: null == realTimeMetrics
          ? _value.realTimeMetrics
          : realTimeMetrics // ignore: cast_nullable_to_non_nullable
              as RealTimeMetrics,
      predictiveInsights: null == predictiveInsights
          ? _value.predictiveInsights
          : predictiveInsights // ignore: cast_nullable_to_non_nullable
              as PredictiveInsights,
      performanceKpis: null == performanceKpis
          ? _value.performanceKpis
          : performanceKpis // ignore: cast_nullable_to_non_nullable
              as PerformanceKpis,
      populationHealth: null == populationHealth
          ? _value.populationHealth
          : populationHealth // ignore: cast_nullable_to_non_nullable
              as PopulationHealth,
      systemServices: null == systemServices
          ? _value._systemServices
          : systemServices // ignore: cast_nullable_to_non_nullable
              as List<SystemService>,
      lastUpdated: null == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AnalyticsDashboardDataImpl implements _AnalyticsDashboardData {
  const _$AnalyticsDashboardDataImpl(
      {required this.activePatients,
      required this.patientGrowth,
      required this.criticalAlerts,
      required this.alertTrend,
      required this.bedOccupancy,
      required this.occupancyTrend,
      required this.avgResponseTime,
      required this.responseTrend,
      required this.realTimeMetrics,
      required this.predictiveInsights,
      required this.performanceKpis,
      required this.populationHealth,
      required final List<SystemService> systemServices,
      required this.lastUpdated})
      : _systemServices = systemServices;

  factory _$AnalyticsDashboardDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$AnalyticsDashboardDataImplFromJson(json);

  @override
  final int activePatients;
  @override
  final double patientGrowth;
  @override
  final int criticalAlerts;
  @override
  final double alertTrend;
  @override
  final double bedOccupancy;
  @override
  final double occupancyTrend;
  @override
  final double avgResponseTime;
  @override
  final double responseTrend;
  @override
  final RealTimeMetrics realTimeMetrics;
  @override
  final PredictiveInsights predictiveInsights;
  @override
  final PerformanceKpis performanceKpis;
  @override
  final PopulationHealth populationHealth;
  final List<SystemService> _systemServices;
  @override
  List<SystemService> get systemServices {
    if (_systemServices is EqualUnmodifiableListView) return _systemServices;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_systemServices);
  }

  @override
  final DateTime lastUpdated;

  @override
  String toString() {
    return 'AnalyticsDashboardData(activePatients: $activePatients, patientGrowth: $patientGrowth, criticalAlerts: $criticalAlerts, alertTrend: $alertTrend, bedOccupancy: $bedOccupancy, occupancyTrend: $occupancyTrend, avgResponseTime: $avgResponseTime, responseTrend: $responseTrend, realTimeMetrics: $realTimeMetrics, predictiveInsights: $predictiveInsights, performanceKpis: $performanceKpis, populationHealth: $populationHealth, systemServices: $systemServices, lastUpdated: $lastUpdated)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AnalyticsDashboardDataImpl &&
            (identical(other.activePatients, activePatients) ||
                other.activePatients == activePatients) &&
            (identical(other.patientGrowth, patientGrowth) ||
                other.patientGrowth == patientGrowth) &&
            (identical(other.criticalAlerts, criticalAlerts) ||
                other.criticalAlerts == criticalAlerts) &&
            (identical(other.alertTrend, alertTrend) ||
                other.alertTrend == alertTrend) &&
            (identical(other.bedOccupancy, bedOccupancy) ||
                other.bedOccupancy == bedOccupancy) &&
            (identical(other.occupancyTrend, occupancyTrend) ||
                other.occupancyTrend == occupancyTrend) &&
            (identical(other.avgResponseTime, avgResponseTime) ||
                other.avgResponseTime == avgResponseTime) &&
            (identical(other.responseTrend, responseTrend) ||
                other.responseTrend == responseTrend) &&
            (identical(other.realTimeMetrics, realTimeMetrics) ||
                other.realTimeMetrics == realTimeMetrics) &&
            (identical(other.predictiveInsights, predictiveInsights) ||
                other.predictiveInsights == predictiveInsights) &&
            (identical(other.performanceKpis, performanceKpis) ||
                other.performanceKpis == performanceKpis) &&
            (identical(other.populationHealth, populationHealth) ||
                other.populationHealth == populationHealth) &&
            const DeepCollectionEquality()
                .equals(other._systemServices, _systemServices) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      activePatients,
      patientGrowth,
      criticalAlerts,
      alertTrend,
      bedOccupancy,
      occupancyTrend,
      avgResponseTime,
      responseTrend,
      realTimeMetrics,
      predictiveInsights,
      performanceKpis,
      populationHealth,
      const DeepCollectionEquality().hash(_systemServices),
      lastUpdated);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AnalyticsDashboardDataImplCopyWith<_$AnalyticsDashboardDataImpl>
      get copyWith => __$$AnalyticsDashboardDataImplCopyWithImpl<
          _$AnalyticsDashboardDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AnalyticsDashboardDataImplToJson(
      this,
    );
  }
}

abstract class _AnalyticsDashboardData implements AnalyticsDashboardData {
  const factory _AnalyticsDashboardData(
      {required final int activePatients,
      required final double patientGrowth,
      required final int criticalAlerts,
      required final double alertTrend,
      required final double bedOccupancy,
      required final double occupancyTrend,
      required final double avgResponseTime,
      required final double responseTrend,
      required final RealTimeMetrics realTimeMetrics,
      required final PredictiveInsights predictiveInsights,
      required final PerformanceKpis performanceKpis,
      required final PopulationHealth populationHealth,
      required final List<SystemService> systemServices,
      required final DateTime lastUpdated}) = _$AnalyticsDashboardDataImpl;

  factory _AnalyticsDashboardData.fromJson(Map<String, dynamic> json) =
      _$AnalyticsDashboardDataImpl.fromJson;

  @override
  int get activePatients;
  @override
  double get patientGrowth;
  @override
  int get criticalAlerts;
  @override
  double get alertTrend;
  @override
  double get bedOccupancy;
  @override
  double get occupancyTrend;
  @override
  double get avgResponseTime;
  @override
  double get responseTrend;
  @override
  RealTimeMetrics get realTimeMetrics;
  @override
  PredictiveInsights get predictiveInsights;
  @override
  PerformanceKpis get performanceKpis;
  @override
  PopulationHealth get populationHealth;
  @override
  List<SystemService> get systemServices;
  @override
  DateTime get lastUpdated;
  @override
  @JsonKey(ignore: true)
  _$$AnalyticsDashboardDataImplCopyWith<_$AnalyticsDashboardDataImpl>
      get copyWith => throw _privateConstructorUsedError;
}

RealTimeMetrics _$RealTimeMetricsFromJson(Map<String, dynamic> json) {
  return _RealTimeMetrics.fromJson(json);
}

/// @nodoc
mixin _$RealTimeMetrics {
  List<MetricDataPoint> get vitalSigns => throw _privateConstructorUsedError;
  List<MetricDataPoint> get patientFlow => throw _privateConstructorUsedError;
  List<MetricDataPoint> get resourceUtilization =>
      throw _privateConstructorUsedError;
  List<AlertMetric> get activeAlerts => throw _privateConstructorUsedError;
  double get systemLoad => throw _privateConstructorUsedError;
  int get connectedDevices => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RealTimeMetricsCopyWith<RealTimeMetrics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RealTimeMetricsCopyWith<$Res> {
  factory $RealTimeMetricsCopyWith(
          RealTimeMetrics value, $Res Function(RealTimeMetrics) then) =
      _$RealTimeMetricsCopyWithImpl<$Res, RealTimeMetrics>;
  @useResult
  $Res call(
      {List<MetricDataPoint> vitalSigns,
      List<MetricDataPoint> patientFlow,
      List<MetricDataPoint> resourceUtilization,
      List<AlertMetric> activeAlerts,
      double systemLoad,
      int connectedDevices});
}

/// @nodoc
class _$RealTimeMetricsCopyWithImpl<$Res, $Val extends RealTimeMetrics>
    implements $RealTimeMetricsCopyWith<$Res> {
  _$RealTimeMetricsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? vitalSigns = null,
    Object? patientFlow = null,
    Object? resourceUtilization = null,
    Object? activeAlerts = null,
    Object? systemLoad = null,
    Object? connectedDevices = null,
  }) {
    return _then(_value.copyWith(
      vitalSigns: null == vitalSigns
          ? _value.vitalSigns
          : vitalSigns // ignore: cast_nullable_to_non_nullable
              as List<MetricDataPoint>,
      patientFlow: null == patientFlow
          ? _value.patientFlow
          : patientFlow // ignore: cast_nullable_to_non_nullable
              as List<MetricDataPoint>,
      resourceUtilization: null == resourceUtilization
          ? _value.resourceUtilization
          : resourceUtilization // ignore: cast_nullable_to_non_nullable
              as List<MetricDataPoint>,
      activeAlerts: null == activeAlerts
          ? _value.activeAlerts
          : activeAlerts // ignore: cast_nullable_to_non_nullable
              as List<AlertMetric>,
      systemLoad: null == systemLoad
          ? _value.systemLoad
          : systemLoad // ignore: cast_nullable_to_non_nullable
              as double,
      connectedDevices: null == connectedDevices
          ? _value.connectedDevices
          : connectedDevices // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RealTimeMetricsImplCopyWith<$Res>
    implements $RealTimeMetricsCopyWith<$Res> {
  factory _$$RealTimeMetricsImplCopyWith(_$RealTimeMetricsImpl value,
          $Res Function(_$RealTimeMetricsImpl) then) =
      __$$RealTimeMetricsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<MetricDataPoint> vitalSigns,
      List<MetricDataPoint> patientFlow,
      List<MetricDataPoint> resourceUtilization,
      List<AlertMetric> activeAlerts,
      double systemLoad,
      int connectedDevices});
}

/// @nodoc
class __$$RealTimeMetricsImplCopyWithImpl<$Res>
    extends _$RealTimeMetricsCopyWithImpl<$Res, _$RealTimeMetricsImpl>
    implements _$$RealTimeMetricsImplCopyWith<$Res> {
  __$$RealTimeMetricsImplCopyWithImpl(
      _$RealTimeMetricsImpl _value, $Res Function(_$RealTimeMetricsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? vitalSigns = null,
    Object? patientFlow = null,
    Object? resourceUtilization = null,
    Object? activeAlerts = null,
    Object? systemLoad = null,
    Object? connectedDevices = null,
  }) {
    return _then(_$RealTimeMetricsImpl(
      vitalSigns: null == vitalSigns
          ? _value._vitalSigns
          : vitalSigns // ignore: cast_nullable_to_non_nullable
              as List<MetricDataPoint>,
      patientFlow: null == patientFlow
          ? _value._patientFlow
          : patientFlow // ignore: cast_nullable_to_non_nullable
              as List<MetricDataPoint>,
      resourceUtilization: null == resourceUtilization
          ? _value._resourceUtilization
          : resourceUtilization // ignore: cast_nullable_to_non_nullable
              as List<MetricDataPoint>,
      activeAlerts: null == activeAlerts
          ? _value._activeAlerts
          : activeAlerts // ignore: cast_nullable_to_non_nullable
              as List<AlertMetric>,
      systemLoad: null == systemLoad
          ? _value.systemLoad
          : systemLoad // ignore: cast_nullable_to_non_nullable
              as double,
      connectedDevices: null == connectedDevices
          ? _value.connectedDevices
          : connectedDevices // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RealTimeMetricsImpl implements _RealTimeMetrics {
  const _$RealTimeMetricsImpl(
      {required final List<MetricDataPoint> vitalSigns,
      required final List<MetricDataPoint> patientFlow,
      required final List<MetricDataPoint> resourceUtilization,
      required final List<AlertMetric> activeAlerts,
      required this.systemLoad,
      required this.connectedDevices})
      : _vitalSigns = vitalSigns,
        _patientFlow = patientFlow,
        _resourceUtilization = resourceUtilization,
        _activeAlerts = activeAlerts;

  factory _$RealTimeMetricsImpl.fromJson(Map<String, dynamic> json) =>
      _$$RealTimeMetricsImplFromJson(json);

  final List<MetricDataPoint> _vitalSigns;
  @override
  List<MetricDataPoint> get vitalSigns {
    if (_vitalSigns is EqualUnmodifiableListView) return _vitalSigns;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_vitalSigns);
  }

  final List<MetricDataPoint> _patientFlow;
  @override
  List<MetricDataPoint> get patientFlow {
    if (_patientFlow is EqualUnmodifiableListView) return _patientFlow;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_patientFlow);
  }

  final List<MetricDataPoint> _resourceUtilization;
  @override
  List<MetricDataPoint> get resourceUtilization {
    if (_resourceUtilization is EqualUnmodifiableListView)
      return _resourceUtilization;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_resourceUtilization);
  }

  final List<AlertMetric> _activeAlerts;
  @override
  List<AlertMetric> get activeAlerts {
    if (_activeAlerts is EqualUnmodifiableListView) return _activeAlerts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_activeAlerts);
  }

  @override
  final double systemLoad;
  @override
  final int connectedDevices;

  @override
  String toString() {
    return 'RealTimeMetrics(vitalSigns: $vitalSigns, patientFlow: $patientFlow, resourceUtilization: $resourceUtilization, activeAlerts: $activeAlerts, systemLoad: $systemLoad, connectedDevices: $connectedDevices)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RealTimeMetricsImpl &&
            const DeepCollectionEquality()
                .equals(other._vitalSigns, _vitalSigns) &&
            const DeepCollectionEquality()
                .equals(other._patientFlow, _patientFlow) &&
            const DeepCollectionEquality()
                .equals(other._resourceUtilization, _resourceUtilization) &&
            const DeepCollectionEquality()
                .equals(other._activeAlerts, _activeAlerts) &&
            (identical(other.systemLoad, systemLoad) ||
                other.systemLoad == systemLoad) &&
            (identical(other.connectedDevices, connectedDevices) ||
                other.connectedDevices == connectedDevices));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_vitalSigns),
      const DeepCollectionEquality().hash(_patientFlow),
      const DeepCollectionEquality().hash(_resourceUtilization),
      const DeepCollectionEquality().hash(_activeAlerts),
      systemLoad,
      connectedDevices);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RealTimeMetricsImplCopyWith<_$RealTimeMetricsImpl> get copyWith =>
      __$$RealTimeMetricsImplCopyWithImpl<_$RealTimeMetricsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RealTimeMetricsImplToJson(
      this,
    );
  }
}

abstract class _RealTimeMetrics implements RealTimeMetrics {
  const factory _RealTimeMetrics(
      {required final List<MetricDataPoint> vitalSigns,
      required final List<MetricDataPoint> patientFlow,
      required final List<MetricDataPoint> resourceUtilization,
      required final List<AlertMetric> activeAlerts,
      required final double systemLoad,
      required final int connectedDevices}) = _$RealTimeMetricsImpl;

  factory _RealTimeMetrics.fromJson(Map<String, dynamic> json) =
      _$RealTimeMetricsImpl.fromJson;

  @override
  List<MetricDataPoint> get vitalSigns;
  @override
  List<MetricDataPoint> get patientFlow;
  @override
  List<MetricDataPoint> get resourceUtilization;
  @override
  List<AlertMetric> get activeAlerts;
  @override
  double get systemLoad;
  @override
  int get connectedDevices;
  @override
  @JsonKey(ignore: true)
  _$$RealTimeMetricsImplCopyWith<_$RealTimeMetricsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PredictiveInsights _$PredictiveInsightsFromJson(Map<String, dynamic> json) {
  return _PredictiveInsights.fromJson(json);
}

/// @nodoc
mixin _$PredictiveInsights {
  List<PredictionModel> get healthOutcomes =>
      throw _privateConstructorUsedError;
  List<RiskAssessment> get riskAssessments =>
      throw _privateConstructorUsedError;
  List<TrendAnalysis> get trends => throw _privateConstructorUsedError;
  List<Recommendation> get recommendations =>
      throw _privateConstructorUsedError;
  double get accuracyScore => throw _privateConstructorUsedError;
  DateTime get lastModelUpdate => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PredictiveInsightsCopyWith<PredictiveInsights> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PredictiveInsightsCopyWith<$Res> {
  factory $PredictiveInsightsCopyWith(
          PredictiveInsights value, $Res Function(PredictiveInsights) then) =
      _$PredictiveInsightsCopyWithImpl<$Res, PredictiveInsights>;
  @useResult
  $Res call(
      {List<PredictionModel> healthOutcomes,
      List<RiskAssessment> riskAssessments,
      List<TrendAnalysis> trends,
      List<Recommendation> recommendations,
      double accuracyScore,
      DateTime lastModelUpdate});
}

/// @nodoc
class _$PredictiveInsightsCopyWithImpl<$Res, $Val extends PredictiveInsights>
    implements $PredictiveInsightsCopyWith<$Res> {
  _$PredictiveInsightsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? healthOutcomes = null,
    Object? riskAssessments = null,
    Object? trends = null,
    Object? recommendations = null,
    Object? accuracyScore = null,
    Object? lastModelUpdate = null,
  }) {
    return _then(_value.copyWith(
      healthOutcomes: null == healthOutcomes
          ? _value.healthOutcomes
          : healthOutcomes // ignore: cast_nullable_to_non_nullable
              as List<PredictionModel>,
      riskAssessments: null == riskAssessments
          ? _value.riskAssessments
          : riskAssessments // ignore: cast_nullable_to_non_nullable
              as List<RiskAssessment>,
      trends: null == trends
          ? _value.trends
          : trends // ignore: cast_nullable_to_non_nullable
              as List<TrendAnalysis>,
      recommendations: null == recommendations
          ? _value.recommendations
          : recommendations // ignore: cast_nullable_to_non_nullable
              as List<Recommendation>,
      accuracyScore: null == accuracyScore
          ? _value.accuracyScore
          : accuracyScore // ignore: cast_nullable_to_non_nullable
              as double,
      lastModelUpdate: null == lastModelUpdate
          ? _value.lastModelUpdate
          : lastModelUpdate // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PredictiveInsightsImplCopyWith<$Res>
    implements $PredictiveInsightsCopyWith<$Res> {
  factory _$$PredictiveInsightsImplCopyWith(_$PredictiveInsightsImpl value,
          $Res Function(_$PredictiveInsightsImpl) then) =
      __$$PredictiveInsightsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<PredictionModel> healthOutcomes,
      List<RiskAssessment> riskAssessments,
      List<TrendAnalysis> trends,
      List<Recommendation> recommendations,
      double accuracyScore,
      DateTime lastModelUpdate});
}

/// @nodoc
class __$$PredictiveInsightsImplCopyWithImpl<$Res>
    extends _$PredictiveInsightsCopyWithImpl<$Res, _$PredictiveInsightsImpl>
    implements _$$PredictiveInsightsImplCopyWith<$Res> {
  __$$PredictiveInsightsImplCopyWithImpl(_$PredictiveInsightsImpl _value,
      $Res Function(_$PredictiveInsightsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? healthOutcomes = null,
    Object? riskAssessments = null,
    Object? trends = null,
    Object? recommendations = null,
    Object? accuracyScore = null,
    Object? lastModelUpdate = null,
  }) {
    return _then(_$PredictiveInsightsImpl(
      healthOutcomes: null == healthOutcomes
          ? _value._healthOutcomes
          : healthOutcomes // ignore: cast_nullable_to_non_nullable
              as List<PredictionModel>,
      riskAssessments: null == riskAssessments
          ? _value._riskAssessments
          : riskAssessments // ignore: cast_nullable_to_non_nullable
              as List<RiskAssessment>,
      trends: null == trends
          ? _value._trends
          : trends // ignore: cast_nullable_to_non_nullable
              as List<TrendAnalysis>,
      recommendations: null == recommendations
          ? _value._recommendations
          : recommendations // ignore: cast_nullable_to_non_nullable
              as List<Recommendation>,
      accuracyScore: null == accuracyScore
          ? _value.accuracyScore
          : accuracyScore // ignore: cast_nullable_to_non_nullable
              as double,
      lastModelUpdate: null == lastModelUpdate
          ? _value.lastModelUpdate
          : lastModelUpdate // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PredictiveInsightsImpl implements _PredictiveInsights {
  const _$PredictiveInsightsImpl(
      {required final List<PredictionModel> healthOutcomes,
      required final List<RiskAssessment> riskAssessments,
      required final List<TrendAnalysis> trends,
      required final List<Recommendation> recommendations,
      required this.accuracyScore,
      required this.lastModelUpdate})
      : _healthOutcomes = healthOutcomes,
        _riskAssessments = riskAssessments,
        _trends = trends,
        _recommendations = recommendations;

  factory _$PredictiveInsightsImpl.fromJson(Map<String, dynamic> json) =>
      _$$PredictiveInsightsImplFromJson(json);

  final List<PredictionModel> _healthOutcomes;
  @override
  List<PredictionModel> get healthOutcomes {
    if (_healthOutcomes is EqualUnmodifiableListView) return _healthOutcomes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_healthOutcomes);
  }

  final List<RiskAssessment> _riskAssessments;
  @override
  List<RiskAssessment> get riskAssessments {
    if (_riskAssessments is EqualUnmodifiableListView) return _riskAssessments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_riskAssessments);
  }

  final List<TrendAnalysis> _trends;
  @override
  List<TrendAnalysis> get trends {
    if (_trends is EqualUnmodifiableListView) return _trends;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_trends);
  }

  final List<Recommendation> _recommendations;
  @override
  List<Recommendation> get recommendations {
    if (_recommendations is EqualUnmodifiableListView) return _recommendations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recommendations);
  }

  @override
  final double accuracyScore;
  @override
  final DateTime lastModelUpdate;

  @override
  String toString() {
    return 'PredictiveInsights(healthOutcomes: $healthOutcomes, riskAssessments: $riskAssessments, trends: $trends, recommendations: $recommendations, accuracyScore: $accuracyScore, lastModelUpdate: $lastModelUpdate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PredictiveInsightsImpl &&
            const DeepCollectionEquality()
                .equals(other._healthOutcomes, _healthOutcomes) &&
            const DeepCollectionEquality()
                .equals(other._riskAssessments, _riskAssessments) &&
            const DeepCollectionEquality().equals(other._trends, _trends) &&
            const DeepCollectionEquality()
                .equals(other._recommendations, _recommendations) &&
            (identical(other.accuracyScore, accuracyScore) ||
                other.accuracyScore == accuracyScore) &&
            (identical(other.lastModelUpdate, lastModelUpdate) ||
                other.lastModelUpdate == lastModelUpdate));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_healthOutcomes),
      const DeepCollectionEquality().hash(_riskAssessments),
      const DeepCollectionEquality().hash(_trends),
      const DeepCollectionEquality().hash(_recommendations),
      accuracyScore,
      lastModelUpdate);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PredictiveInsightsImplCopyWith<_$PredictiveInsightsImpl> get copyWith =>
      __$$PredictiveInsightsImplCopyWithImpl<_$PredictiveInsightsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PredictiveInsightsImplToJson(
      this,
    );
  }
}

abstract class _PredictiveInsights implements PredictiveInsights {
  const factory _PredictiveInsights(
      {required final List<PredictionModel> healthOutcomes,
      required final List<RiskAssessment> riskAssessments,
      required final List<TrendAnalysis> trends,
      required final List<Recommendation> recommendations,
      required final double accuracyScore,
      required final DateTime lastModelUpdate}) = _$PredictiveInsightsImpl;

  factory _PredictiveInsights.fromJson(Map<String, dynamic> json) =
      _$PredictiveInsightsImpl.fromJson;

  @override
  List<PredictionModel> get healthOutcomes;
  @override
  List<RiskAssessment> get riskAssessments;
  @override
  List<TrendAnalysis> get trends;
  @override
  List<Recommendation> get recommendations;
  @override
  double get accuracyScore;
  @override
  DateTime get lastModelUpdate;
  @override
  @JsonKey(ignore: true)
  _$$PredictiveInsightsImplCopyWith<_$PredictiveInsightsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PerformanceKpis _$PerformanceKpisFromJson(Map<String, dynamic> json) {
  return _PerformanceKpis.fromJson(json);
}

/// @nodoc
mixin _$PerformanceKpis {
  double get patientSatisfaction => throw _privateConstructorUsedError;
  double get staffEfficiency => throw _privateConstructorUsedError;
  double get costPerPatient => throw _privateConstructorUsedError;
  double get readmissionRate => throw _privateConstructorUsedError;
  double get mortalityRate => throw _privateConstructorUsedError;
  double get infectionRate => throw _privateConstructorUsedError;
  List<KpiTrend> get trends => throw _privateConstructorUsedError;
  List<Benchmark> get benchmarks => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PerformanceKpisCopyWith<PerformanceKpis> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PerformanceKpisCopyWith<$Res> {
  factory $PerformanceKpisCopyWith(
          PerformanceKpis value, $Res Function(PerformanceKpis) then) =
      _$PerformanceKpisCopyWithImpl<$Res, PerformanceKpis>;
  @useResult
  $Res call(
      {double patientSatisfaction,
      double staffEfficiency,
      double costPerPatient,
      double readmissionRate,
      double mortalityRate,
      double infectionRate,
      List<KpiTrend> trends,
      List<Benchmark> benchmarks});
}

/// @nodoc
class _$PerformanceKpisCopyWithImpl<$Res, $Val extends PerformanceKpis>
    implements $PerformanceKpisCopyWith<$Res> {
  _$PerformanceKpisCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? patientSatisfaction = null,
    Object? staffEfficiency = null,
    Object? costPerPatient = null,
    Object? readmissionRate = null,
    Object? mortalityRate = null,
    Object? infectionRate = null,
    Object? trends = null,
    Object? benchmarks = null,
  }) {
    return _then(_value.copyWith(
      patientSatisfaction: null == patientSatisfaction
          ? _value.patientSatisfaction
          : patientSatisfaction // ignore: cast_nullable_to_non_nullable
              as double,
      staffEfficiency: null == staffEfficiency
          ? _value.staffEfficiency
          : staffEfficiency // ignore: cast_nullable_to_non_nullable
              as double,
      costPerPatient: null == costPerPatient
          ? _value.costPerPatient
          : costPerPatient // ignore: cast_nullable_to_non_nullable
              as double,
      readmissionRate: null == readmissionRate
          ? _value.readmissionRate
          : readmissionRate // ignore: cast_nullable_to_non_nullable
              as double,
      mortalityRate: null == mortalityRate
          ? _value.mortalityRate
          : mortalityRate // ignore: cast_nullable_to_non_nullable
              as double,
      infectionRate: null == infectionRate
          ? _value.infectionRate
          : infectionRate // ignore: cast_nullable_to_non_nullable
              as double,
      trends: null == trends
          ? _value.trends
          : trends // ignore: cast_nullable_to_non_nullable
              as List<KpiTrend>,
      benchmarks: null == benchmarks
          ? _value.benchmarks
          : benchmarks // ignore: cast_nullable_to_non_nullable
              as List<Benchmark>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PerformanceKpisImplCopyWith<$Res>
    implements $PerformanceKpisCopyWith<$Res> {
  factory _$$PerformanceKpisImplCopyWith(_$PerformanceKpisImpl value,
          $Res Function(_$PerformanceKpisImpl) then) =
      __$$PerformanceKpisImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double patientSatisfaction,
      double staffEfficiency,
      double costPerPatient,
      double readmissionRate,
      double mortalityRate,
      double infectionRate,
      List<KpiTrend> trends,
      List<Benchmark> benchmarks});
}

/// @nodoc
class __$$PerformanceKpisImplCopyWithImpl<$Res>
    extends _$PerformanceKpisCopyWithImpl<$Res, _$PerformanceKpisImpl>
    implements _$$PerformanceKpisImplCopyWith<$Res> {
  __$$PerformanceKpisImplCopyWithImpl(
      _$PerformanceKpisImpl _value, $Res Function(_$PerformanceKpisImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? patientSatisfaction = null,
    Object? staffEfficiency = null,
    Object? costPerPatient = null,
    Object? readmissionRate = null,
    Object? mortalityRate = null,
    Object? infectionRate = null,
    Object? trends = null,
    Object? benchmarks = null,
  }) {
    return _then(_$PerformanceKpisImpl(
      patientSatisfaction: null == patientSatisfaction
          ? _value.patientSatisfaction
          : patientSatisfaction // ignore: cast_nullable_to_non_nullable
              as double,
      staffEfficiency: null == staffEfficiency
          ? _value.staffEfficiency
          : staffEfficiency // ignore: cast_nullable_to_non_nullable
              as double,
      costPerPatient: null == costPerPatient
          ? _value.costPerPatient
          : costPerPatient // ignore: cast_nullable_to_non_nullable
              as double,
      readmissionRate: null == readmissionRate
          ? _value.readmissionRate
          : readmissionRate // ignore: cast_nullable_to_non_nullable
              as double,
      mortalityRate: null == mortalityRate
          ? _value.mortalityRate
          : mortalityRate // ignore: cast_nullable_to_non_nullable
              as double,
      infectionRate: null == infectionRate
          ? _value.infectionRate
          : infectionRate // ignore: cast_nullable_to_non_nullable
              as double,
      trends: null == trends
          ? _value._trends
          : trends // ignore: cast_nullable_to_non_nullable
              as List<KpiTrend>,
      benchmarks: null == benchmarks
          ? _value._benchmarks
          : benchmarks // ignore: cast_nullable_to_non_nullable
              as List<Benchmark>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PerformanceKpisImpl implements _PerformanceKpis {
  const _$PerformanceKpisImpl(
      {required this.patientSatisfaction,
      required this.staffEfficiency,
      required this.costPerPatient,
      required this.readmissionRate,
      required this.mortalityRate,
      required this.infectionRate,
      required final List<KpiTrend> trends,
      required final List<Benchmark> benchmarks})
      : _trends = trends,
        _benchmarks = benchmarks;

  factory _$PerformanceKpisImpl.fromJson(Map<String, dynamic> json) =>
      _$$PerformanceKpisImplFromJson(json);

  @override
  final double patientSatisfaction;
  @override
  final double staffEfficiency;
  @override
  final double costPerPatient;
  @override
  final double readmissionRate;
  @override
  final double mortalityRate;
  @override
  final double infectionRate;
  final List<KpiTrend> _trends;
  @override
  List<KpiTrend> get trends {
    if (_trends is EqualUnmodifiableListView) return _trends;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_trends);
  }

  final List<Benchmark> _benchmarks;
  @override
  List<Benchmark> get benchmarks {
    if (_benchmarks is EqualUnmodifiableListView) return _benchmarks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_benchmarks);
  }

  @override
  String toString() {
    return 'PerformanceKpis(patientSatisfaction: $patientSatisfaction, staffEfficiency: $staffEfficiency, costPerPatient: $costPerPatient, readmissionRate: $readmissionRate, mortalityRate: $mortalityRate, infectionRate: $infectionRate, trends: $trends, benchmarks: $benchmarks)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PerformanceKpisImpl &&
            (identical(other.patientSatisfaction, patientSatisfaction) ||
                other.patientSatisfaction == patientSatisfaction) &&
            (identical(other.staffEfficiency, staffEfficiency) ||
                other.staffEfficiency == staffEfficiency) &&
            (identical(other.costPerPatient, costPerPatient) ||
                other.costPerPatient == costPerPatient) &&
            (identical(other.readmissionRate, readmissionRate) ||
                other.readmissionRate == readmissionRate) &&
            (identical(other.mortalityRate, mortalityRate) ||
                other.mortalityRate == mortalityRate) &&
            (identical(other.infectionRate, infectionRate) ||
                other.infectionRate == infectionRate) &&
            const DeepCollectionEquality().equals(other._trends, _trends) &&
            const DeepCollectionEquality()
                .equals(other._benchmarks, _benchmarks));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      patientSatisfaction,
      staffEfficiency,
      costPerPatient,
      readmissionRate,
      mortalityRate,
      infectionRate,
      const DeepCollectionEquality().hash(_trends),
      const DeepCollectionEquality().hash(_benchmarks));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PerformanceKpisImplCopyWith<_$PerformanceKpisImpl> get copyWith =>
      __$$PerformanceKpisImplCopyWithImpl<_$PerformanceKpisImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PerformanceKpisImplToJson(
      this,
    );
  }
}

abstract class _PerformanceKpis implements PerformanceKpis {
  const factory _PerformanceKpis(
      {required final double patientSatisfaction,
      required final double staffEfficiency,
      required final double costPerPatient,
      required final double readmissionRate,
      required final double mortalityRate,
      required final double infectionRate,
      required final List<KpiTrend> trends,
      required final List<Benchmark> benchmarks}) = _$PerformanceKpisImpl;

  factory _PerformanceKpis.fromJson(Map<String, dynamic> json) =
      _$PerformanceKpisImpl.fromJson;

  @override
  double get patientSatisfaction;
  @override
  double get staffEfficiency;
  @override
  double get costPerPatient;
  @override
  double get readmissionRate;
  @override
  double get mortalityRate;
  @override
  double get infectionRate;
  @override
  List<KpiTrend> get trends;
  @override
  List<Benchmark> get benchmarks;
  @override
  @JsonKey(ignore: true)
  _$$PerformanceKpisImplCopyWith<_$PerformanceKpisImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PopulationHealth _$PopulationHealthFromJson(Map<String, dynamic> json) {
  return _PopulationHealth.fromJson(json);
}

/// @nodoc
mixin _$PopulationHealth {
  List<DemographicData> get demographics => throw _privateConstructorUsedError;
  List<DiseasePrevalence> get diseasePrevalence =>
      throw _privateConstructorUsedError;
  List<OutbreakAlert> get outbreakAlerts => throw _privateConstructorUsedError;
  List<HealthTrend> get healthTrends => throw _privateConstructorUsedError;
  double get communityHealthScore => throw _privateConstructorUsedError;
  List<PreventiveCareMetric> get preventiveCare =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PopulationHealthCopyWith<PopulationHealth> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PopulationHealthCopyWith<$Res> {
  factory $PopulationHealthCopyWith(
          PopulationHealth value, $Res Function(PopulationHealth) then) =
      _$PopulationHealthCopyWithImpl<$Res, PopulationHealth>;
  @useResult
  $Res call(
      {List<DemographicData> demographics,
      List<DiseasePrevalence> diseasePrevalence,
      List<OutbreakAlert> outbreakAlerts,
      List<HealthTrend> healthTrends,
      double communityHealthScore,
      List<PreventiveCareMetric> preventiveCare});
}

/// @nodoc
class _$PopulationHealthCopyWithImpl<$Res, $Val extends PopulationHealth>
    implements $PopulationHealthCopyWith<$Res> {
  _$PopulationHealthCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? demographics = null,
    Object? diseasePrevalence = null,
    Object? outbreakAlerts = null,
    Object? healthTrends = null,
    Object? communityHealthScore = null,
    Object? preventiveCare = null,
  }) {
    return _then(_value.copyWith(
      demographics: null == demographics
          ? _value.demographics
          : demographics // ignore: cast_nullable_to_non_nullable
              as List<DemographicData>,
      diseasePrevalence: null == diseasePrevalence
          ? _value.diseasePrevalence
          : diseasePrevalence // ignore: cast_nullable_to_non_nullable
              as List<DiseasePrevalence>,
      outbreakAlerts: null == outbreakAlerts
          ? _value.outbreakAlerts
          : outbreakAlerts // ignore: cast_nullable_to_non_nullable
              as List<OutbreakAlert>,
      healthTrends: null == healthTrends
          ? _value.healthTrends
          : healthTrends // ignore: cast_nullable_to_non_nullable
              as List<HealthTrend>,
      communityHealthScore: null == communityHealthScore
          ? _value.communityHealthScore
          : communityHealthScore // ignore: cast_nullable_to_non_nullable
              as double,
      preventiveCare: null == preventiveCare
          ? _value.preventiveCare
          : preventiveCare // ignore: cast_nullable_to_non_nullable
              as List<PreventiveCareMetric>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PopulationHealthImplCopyWith<$Res>
    implements $PopulationHealthCopyWith<$Res> {
  factory _$$PopulationHealthImplCopyWith(_$PopulationHealthImpl value,
          $Res Function(_$PopulationHealthImpl) then) =
      __$$PopulationHealthImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<DemographicData> demographics,
      List<DiseasePrevalence> diseasePrevalence,
      List<OutbreakAlert> outbreakAlerts,
      List<HealthTrend> healthTrends,
      double communityHealthScore,
      List<PreventiveCareMetric> preventiveCare});
}

/// @nodoc
class __$$PopulationHealthImplCopyWithImpl<$Res>
    extends _$PopulationHealthCopyWithImpl<$Res, _$PopulationHealthImpl>
    implements _$$PopulationHealthImplCopyWith<$Res> {
  __$$PopulationHealthImplCopyWithImpl(_$PopulationHealthImpl _value,
      $Res Function(_$PopulationHealthImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? demographics = null,
    Object? diseasePrevalence = null,
    Object? outbreakAlerts = null,
    Object? healthTrends = null,
    Object? communityHealthScore = null,
    Object? preventiveCare = null,
  }) {
    return _then(_$PopulationHealthImpl(
      demographics: null == demographics
          ? _value._demographics
          : demographics // ignore: cast_nullable_to_non_nullable
              as List<DemographicData>,
      diseasePrevalence: null == diseasePrevalence
          ? _value._diseasePrevalence
          : diseasePrevalence // ignore: cast_nullable_to_non_nullable
              as List<DiseasePrevalence>,
      outbreakAlerts: null == outbreakAlerts
          ? _value._outbreakAlerts
          : outbreakAlerts // ignore: cast_nullable_to_non_nullable
              as List<OutbreakAlert>,
      healthTrends: null == healthTrends
          ? _value._healthTrends
          : healthTrends // ignore: cast_nullable_to_non_nullable
              as List<HealthTrend>,
      communityHealthScore: null == communityHealthScore
          ? _value.communityHealthScore
          : communityHealthScore // ignore: cast_nullable_to_non_nullable
              as double,
      preventiveCare: null == preventiveCare
          ? _value._preventiveCare
          : preventiveCare // ignore: cast_nullable_to_non_nullable
              as List<PreventiveCareMetric>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PopulationHealthImpl implements _PopulationHealth {
  const _$PopulationHealthImpl(
      {required final List<DemographicData> demographics,
      required final List<DiseasePrevalence> diseasePrevalence,
      required final List<OutbreakAlert> outbreakAlerts,
      required final List<HealthTrend> healthTrends,
      required this.communityHealthScore,
      required final List<PreventiveCareMetric> preventiveCare})
      : _demographics = demographics,
        _diseasePrevalence = diseasePrevalence,
        _outbreakAlerts = outbreakAlerts,
        _healthTrends = healthTrends,
        _preventiveCare = preventiveCare;

  factory _$PopulationHealthImpl.fromJson(Map<String, dynamic> json) =>
      _$$PopulationHealthImplFromJson(json);

  final List<DemographicData> _demographics;
  @override
  List<DemographicData> get demographics {
    if (_demographics is EqualUnmodifiableListView) return _demographics;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_demographics);
  }

  final List<DiseasePrevalence> _diseasePrevalence;
  @override
  List<DiseasePrevalence> get diseasePrevalence {
    if (_diseasePrevalence is EqualUnmodifiableListView)
      return _diseasePrevalence;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_diseasePrevalence);
  }

  final List<OutbreakAlert> _outbreakAlerts;
  @override
  List<OutbreakAlert> get outbreakAlerts {
    if (_outbreakAlerts is EqualUnmodifiableListView) return _outbreakAlerts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_outbreakAlerts);
  }

  final List<HealthTrend> _healthTrends;
  @override
  List<HealthTrend> get healthTrends {
    if (_healthTrends is EqualUnmodifiableListView) return _healthTrends;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_healthTrends);
  }

  @override
  final double communityHealthScore;
  final List<PreventiveCareMetric> _preventiveCare;
  @override
  List<PreventiveCareMetric> get preventiveCare {
    if (_preventiveCare is EqualUnmodifiableListView) return _preventiveCare;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_preventiveCare);
  }

  @override
  String toString() {
    return 'PopulationHealth(demographics: $demographics, diseasePrevalence: $diseasePrevalence, outbreakAlerts: $outbreakAlerts, healthTrends: $healthTrends, communityHealthScore: $communityHealthScore, preventiveCare: $preventiveCare)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PopulationHealthImpl &&
            const DeepCollectionEquality()
                .equals(other._demographics, _demographics) &&
            const DeepCollectionEquality()
                .equals(other._diseasePrevalence, _diseasePrevalence) &&
            const DeepCollectionEquality()
                .equals(other._outbreakAlerts, _outbreakAlerts) &&
            const DeepCollectionEquality()
                .equals(other._healthTrends, _healthTrends) &&
            (identical(other.communityHealthScore, communityHealthScore) ||
                other.communityHealthScore == communityHealthScore) &&
            const DeepCollectionEquality()
                .equals(other._preventiveCare, _preventiveCare));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_demographics),
      const DeepCollectionEquality().hash(_diseasePrevalence),
      const DeepCollectionEquality().hash(_outbreakAlerts),
      const DeepCollectionEquality().hash(_healthTrends),
      communityHealthScore,
      const DeepCollectionEquality().hash(_preventiveCare));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PopulationHealthImplCopyWith<_$PopulationHealthImpl> get copyWith =>
      __$$PopulationHealthImplCopyWithImpl<_$PopulationHealthImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PopulationHealthImplToJson(
      this,
    );
  }
}

abstract class _PopulationHealth implements PopulationHealth {
  const factory _PopulationHealth(
          {required final List<DemographicData> demographics,
          required final List<DiseasePrevalence> diseasePrevalence,
          required final List<OutbreakAlert> outbreakAlerts,
          required final List<HealthTrend> healthTrends,
          required final double communityHealthScore,
          required final List<PreventiveCareMetric> preventiveCare}) =
      _$PopulationHealthImpl;

  factory _PopulationHealth.fromJson(Map<String, dynamic> json) =
      _$PopulationHealthImpl.fromJson;

  @override
  List<DemographicData> get demographics;
  @override
  List<DiseasePrevalence> get diseasePrevalence;
  @override
  List<OutbreakAlert> get outbreakAlerts;
  @override
  List<HealthTrend> get healthTrends;
  @override
  double get communityHealthScore;
  @override
  List<PreventiveCareMetric> get preventiveCare;
  @override
  @JsonKey(ignore: true)
  _$$PopulationHealthImplCopyWith<_$PopulationHealthImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MetricDataPoint _$MetricDataPointFromJson(Map<String, dynamic> json) {
  return _MetricDataPoint.fromJson(json);
}

/// @nodoc
mixin _$MetricDataPoint {
  DateTime get timestamp => throw _privateConstructorUsedError;
  double get value => throw _privateConstructorUsedError;
  String get metric => throw _privateConstructorUsedError;
  String? get unit => throw _privateConstructorUsedError;
  String? get category => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MetricDataPointCopyWith<MetricDataPoint> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MetricDataPointCopyWith<$Res> {
  factory $MetricDataPointCopyWith(
          MetricDataPoint value, $Res Function(MetricDataPoint) then) =
      _$MetricDataPointCopyWithImpl<$Res, MetricDataPoint>;
  @useResult
  $Res call(
      {DateTime timestamp,
      double value,
      String metric,
      String? unit,
      String? category});
}

/// @nodoc
class _$MetricDataPointCopyWithImpl<$Res, $Val extends MetricDataPoint>
    implements $MetricDataPointCopyWith<$Res> {
  _$MetricDataPointCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timestamp = null,
    Object? value = null,
    Object? metric = null,
    Object? unit = freezed,
    Object? category = freezed,
  }) {
    return _then(_value.copyWith(
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as double,
      metric: null == metric
          ? _value.metric
          : metric // ignore: cast_nullable_to_non_nullable
              as String,
      unit: freezed == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String?,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MetricDataPointImplCopyWith<$Res>
    implements $MetricDataPointCopyWith<$Res> {
  factory _$$MetricDataPointImplCopyWith(_$MetricDataPointImpl value,
          $Res Function(_$MetricDataPointImpl) then) =
      __$$MetricDataPointImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime timestamp,
      double value,
      String metric,
      String? unit,
      String? category});
}

/// @nodoc
class __$$MetricDataPointImplCopyWithImpl<$Res>
    extends _$MetricDataPointCopyWithImpl<$Res, _$MetricDataPointImpl>
    implements _$$MetricDataPointImplCopyWith<$Res> {
  __$$MetricDataPointImplCopyWithImpl(
      _$MetricDataPointImpl _value, $Res Function(_$MetricDataPointImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timestamp = null,
    Object? value = null,
    Object? metric = null,
    Object? unit = freezed,
    Object? category = freezed,
  }) {
    return _then(_$MetricDataPointImpl(
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as double,
      metric: null == metric
          ? _value.metric
          : metric // ignore: cast_nullable_to_non_nullable
              as String,
      unit: freezed == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String?,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MetricDataPointImpl implements _MetricDataPoint {
  const _$MetricDataPointImpl(
      {required this.timestamp,
      required this.value,
      required this.metric,
      this.unit,
      this.category});

  factory _$MetricDataPointImpl.fromJson(Map<String, dynamic> json) =>
      _$$MetricDataPointImplFromJson(json);

  @override
  final DateTime timestamp;
  @override
  final double value;
  @override
  final String metric;
  @override
  final String? unit;
  @override
  final String? category;

  @override
  String toString() {
    return 'MetricDataPoint(timestamp: $timestamp, value: $value, metric: $metric, unit: $unit, category: $category)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MetricDataPointImpl &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.metric, metric) || other.metric == metric) &&
            (identical(other.unit, unit) || other.unit == unit) &&
            (identical(other.category, category) ||
                other.category == category));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, timestamp, value, metric, unit, category);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MetricDataPointImplCopyWith<_$MetricDataPointImpl> get copyWith =>
      __$$MetricDataPointImplCopyWithImpl<_$MetricDataPointImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MetricDataPointImplToJson(
      this,
    );
  }
}

abstract class _MetricDataPoint implements MetricDataPoint {
  const factory _MetricDataPoint(
      {required final DateTime timestamp,
      required final double value,
      required final String metric,
      final String? unit,
      final String? category}) = _$MetricDataPointImpl;

  factory _MetricDataPoint.fromJson(Map<String, dynamic> json) =
      _$MetricDataPointImpl.fromJson;

  @override
  DateTime get timestamp;
  @override
  double get value;
  @override
  String get metric;
  @override
  String? get unit;
  @override
  String? get category;
  @override
  @JsonKey(ignore: true)
  _$$MetricDataPointImplCopyWith<_$MetricDataPointImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AlertMetric _$AlertMetricFromJson(Map<String, dynamic> json) {
  return _AlertMetric.fromJson(json);
}

/// @nodoc
mixin _$AlertMetric {
  String get id => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String get severity => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  String get patientId => throw _privateConstructorUsedError;
  String? get department => throw _privateConstructorUsedError;
  bool? get acknowledged => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AlertMetricCopyWith<AlertMetric> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AlertMetricCopyWith<$Res> {
  factory $AlertMetricCopyWith(
          AlertMetric value, $Res Function(AlertMetric) then) =
      _$AlertMetricCopyWithImpl<$Res, AlertMetric>;
  @useResult
  $Res call(
      {String id,
      String type,
      String severity,
      String message,
      DateTime timestamp,
      String patientId,
      String? department,
      bool? acknowledged});
}

/// @nodoc
class _$AlertMetricCopyWithImpl<$Res, $Val extends AlertMetric>
    implements $AlertMetricCopyWith<$Res> {
  _$AlertMetricCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? severity = null,
    Object? message = null,
    Object? timestamp = null,
    Object? patientId = null,
    Object? department = freezed,
    Object? acknowledged = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      severity: null == severity
          ? _value.severity
          : severity // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      patientId: null == patientId
          ? _value.patientId
          : patientId // ignore: cast_nullable_to_non_nullable
              as String,
      department: freezed == department
          ? _value.department
          : department // ignore: cast_nullable_to_non_nullable
              as String?,
      acknowledged: freezed == acknowledged
          ? _value.acknowledged
          : acknowledged // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AlertMetricImplCopyWith<$Res>
    implements $AlertMetricCopyWith<$Res> {
  factory _$$AlertMetricImplCopyWith(
          _$AlertMetricImpl value, $Res Function(_$AlertMetricImpl) then) =
      __$$AlertMetricImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String type,
      String severity,
      String message,
      DateTime timestamp,
      String patientId,
      String? department,
      bool? acknowledged});
}

/// @nodoc
class __$$AlertMetricImplCopyWithImpl<$Res>
    extends _$AlertMetricCopyWithImpl<$Res, _$AlertMetricImpl>
    implements _$$AlertMetricImplCopyWith<$Res> {
  __$$AlertMetricImplCopyWithImpl(
      _$AlertMetricImpl _value, $Res Function(_$AlertMetricImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? severity = null,
    Object? message = null,
    Object? timestamp = null,
    Object? patientId = null,
    Object? department = freezed,
    Object? acknowledged = freezed,
  }) {
    return _then(_$AlertMetricImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      severity: null == severity
          ? _value.severity
          : severity // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      patientId: null == patientId
          ? _value.patientId
          : patientId // ignore: cast_nullable_to_non_nullable
              as String,
      department: freezed == department
          ? _value.department
          : department // ignore: cast_nullable_to_non_nullable
              as String?,
      acknowledged: freezed == acknowledged
          ? _value.acknowledged
          : acknowledged // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AlertMetricImpl implements _AlertMetric {
  const _$AlertMetricImpl(
      {required this.id,
      required this.type,
      required this.severity,
      required this.message,
      required this.timestamp,
      required this.patientId,
      this.department,
      this.acknowledged});

  factory _$AlertMetricImpl.fromJson(Map<String, dynamic> json) =>
      _$$AlertMetricImplFromJson(json);

  @override
  final String id;
  @override
  final String type;
  @override
  final String severity;
  @override
  final String message;
  @override
  final DateTime timestamp;
  @override
  final String patientId;
  @override
  final String? department;
  @override
  final bool? acknowledged;

  @override
  String toString() {
    return 'AlertMetric(id: $id, type: $type, severity: $severity, message: $message, timestamp: $timestamp, patientId: $patientId, department: $department, acknowledged: $acknowledged)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AlertMetricImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.severity, severity) ||
                other.severity == severity) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.patientId, patientId) ||
                other.patientId == patientId) &&
            (identical(other.department, department) ||
                other.department == department) &&
            (identical(other.acknowledged, acknowledged) ||
                other.acknowledged == acknowledged));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, type, severity, message,
      timestamp, patientId, department, acknowledged);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AlertMetricImplCopyWith<_$AlertMetricImpl> get copyWith =>
      __$$AlertMetricImplCopyWithImpl<_$AlertMetricImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AlertMetricImplToJson(
      this,
    );
  }
}

abstract class _AlertMetric implements AlertMetric {
  const factory _AlertMetric(
      {required final String id,
      required final String type,
      required final String severity,
      required final String message,
      required final DateTime timestamp,
      required final String patientId,
      final String? department,
      final bool? acknowledged}) = _$AlertMetricImpl;

  factory _AlertMetric.fromJson(Map<String, dynamic> json) =
      _$AlertMetricImpl.fromJson;

  @override
  String get id;
  @override
  String get type;
  @override
  String get severity;
  @override
  String get message;
  @override
  DateTime get timestamp;
  @override
  String get patientId;
  @override
  String? get department;
  @override
  bool? get acknowledged;
  @override
  @JsonKey(ignore: true)
  _$$AlertMetricImplCopyWith<_$AlertMetricImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PredictionModel _$PredictionModelFromJson(Map<String, dynamic> json) {
  return _PredictionModel.fromJson(json);
}

/// @nodoc
mixin _$PredictionModel {
  String get modelType => throw _privateConstructorUsedError;
  String get prediction => throw _privateConstructorUsedError;
  double get confidence => throw _privateConstructorUsedError;
  DateTime get predictionDate => throw _privateConstructorUsedError;
  String get patientId => throw _privateConstructorUsedError;
  List<String> get riskFactors => throw _privateConstructorUsedError;
  String? get recommendedAction => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PredictionModelCopyWith<PredictionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PredictionModelCopyWith<$Res> {
  factory $PredictionModelCopyWith(
          PredictionModel value, $Res Function(PredictionModel) then) =
      _$PredictionModelCopyWithImpl<$Res, PredictionModel>;
  @useResult
  $Res call(
      {String modelType,
      String prediction,
      double confidence,
      DateTime predictionDate,
      String patientId,
      List<String> riskFactors,
      String? recommendedAction});
}

/// @nodoc
class _$PredictionModelCopyWithImpl<$Res, $Val extends PredictionModel>
    implements $PredictionModelCopyWith<$Res> {
  _$PredictionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? modelType = null,
    Object? prediction = null,
    Object? confidence = null,
    Object? predictionDate = null,
    Object? patientId = null,
    Object? riskFactors = null,
    Object? recommendedAction = freezed,
  }) {
    return _then(_value.copyWith(
      modelType: null == modelType
          ? _value.modelType
          : modelType // ignore: cast_nullable_to_non_nullable
              as String,
      prediction: null == prediction
          ? _value.prediction
          : prediction // ignore: cast_nullable_to_non_nullable
              as String,
      confidence: null == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double,
      predictionDate: null == predictionDate
          ? _value.predictionDate
          : predictionDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      patientId: null == patientId
          ? _value.patientId
          : patientId // ignore: cast_nullable_to_non_nullable
              as String,
      riskFactors: null == riskFactors
          ? _value.riskFactors
          : riskFactors // ignore: cast_nullable_to_non_nullable
              as List<String>,
      recommendedAction: freezed == recommendedAction
          ? _value.recommendedAction
          : recommendedAction // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PredictionModelImplCopyWith<$Res>
    implements $PredictionModelCopyWith<$Res> {
  factory _$$PredictionModelImplCopyWith(_$PredictionModelImpl value,
          $Res Function(_$PredictionModelImpl) then) =
      __$$PredictionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String modelType,
      String prediction,
      double confidence,
      DateTime predictionDate,
      String patientId,
      List<String> riskFactors,
      String? recommendedAction});
}

/// @nodoc
class __$$PredictionModelImplCopyWithImpl<$Res>
    extends _$PredictionModelCopyWithImpl<$Res, _$PredictionModelImpl>
    implements _$$PredictionModelImplCopyWith<$Res> {
  __$$PredictionModelImplCopyWithImpl(
      _$PredictionModelImpl _value, $Res Function(_$PredictionModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? modelType = null,
    Object? prediction = null,
    Object? confidence = null,
    Object? predictionDate = null,
    Object? patientId = null,
    Object? riskFactors = null,
    Object? recommendedAction = freezed,
  }) {
    return _then(_$PredictionModelImpl(
      modelType: null == modelType
          ? _value.modelType
          : modelType // ignore: cast_nullable_to_non_nullable
              as String,
      prediction: null == prediction
          ? _value.prediction
          : prediction // ignore: cast_nullable_to_non_nullable
              as String,
      confidence: null == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double,
      predictionDate: null == predictionDate
          ? _value.predictionDate
          : predictionDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      patientId: null == patientId
          ? _value.patientId
          : patientId // ignore: cast_nullable_to_non_nullable
              as String,
      riskFactors: null == riskFactors
          ? _value._riskFactors
          : riskFactors // ignore: cast_nullable_to_non_nullable
              as List<String>,
      recommendedAction: freezed == recommendedAction
          ? _value.recommendedAction
          : recommendedAction // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PredictionModelImpl implements _PredictionModel {
  const _$PredictionModelImpl(
      {required this.modelType,
      required this.prediction,
      required this.confidence,
      required this.predictionDate,
      required this.patientId,
      required final List<String> riskFactors,
      this.recommendedAction})
      : _riskFactors = riskFactors;

  factory _$PredictionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PredictionModelImplFromJson(json);

  @override
  final String modelType;
  @override
  final String prediction;
  @override
  final double confidence;
  @override
  final DateTime predictionDate;
  @override
  final String patientId;
  final List<String> _riskFactors;
  @override
  List<String> get riskFactors {
    if (_riskFactors is EqualUnmodifiableListView) return _riskFactors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_riskFactors);
  }

  @override
  final String? recommendedAction;

  @override
  String toString() {
    return 'PredictionModel(modelType: $modelType, prediction: $prediction, confidence: $confidence, predictionDate: $predictionDate, patientId: $patientId, riskFactors: $riskFactors, recommendedAction: $recommendedAction)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PredictionModelImpl &&
            (identical(other.modelType, modelType) ||
                other.modelType == modelType) &&
            (identical(other.prediction, prediction) ||
                other.prediction == prediction) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence) &&
            (identical(other.predictionDate, predictionDate) ||
                other.predictionDate == predictionDate) &&
            (identical(other.patientId, patientId) ||
                other.patientId == patientId) &&
            const DeepCollectionEquality()
                .equals(other._riskFactors, _riskFactors) &&
            (identical(other.recommendedAction, recommendedAction) ||
                other.recommendedAction == recommendedAction));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      modelType,
      prediction,
      confidence,
      predictionDate,
      patientId,
      const DeepCollectionEquality().hash(_riskFactors),
      recommendedAction);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PredictionModelImplCopyWith<_$PredictionModelImpl> get copyWith =>
      __$$PredictionModelImplCopyWithImpl<_$PredictionModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PredictionModelImplToJson(
      this,
    );
  }
}

abstract class _PredictionModel implements PredictionModel {
  const factory _PredictionModel(
      {required final String modelType,
      required final String prediction,
      required final double confidence,
      required final DateTime predictionDate,
      required final String patientId,
      required final List<String> riskFactors,
      final String? recommendedAction}) = _$PredictionModelImpl;

  factory _PredictionModel.fromJson(Map<String, dynamic> json) =
      _$PredictionModelImpl.fromJson;

  @override
  String get modelType;
  @override
  String get prediction;
  @override
  double get confidence;
  @override
  DateTime get predictionDate;
  @override
  String get patientId;
  @override
  List<String> get riskFactors;
  @override
  String? get recommendedAction;
  @override
  @JsonKey(ignore: true)
  _$$PredictionModelImplCopyWith<_$PredictionModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RiskAssessment _$RiskAssessmentFromJson(Map<String, dynamic> json) {
  return _RiskAssessment.fromJson(json);
}

/// @nodoc
mixin _$RiskAssessment {
  String get patientId => throw _privateConstructorUsedError;
  String get riskType => throw _privateConstructorUsedError;
  String get riskLevel => throw _privateConstructorUsedError;
  double get riskScore => throw _privateConstructorUsedError;
  List<String> get riskFactors => throw _privateConstructorUsedError;
  DateTime get assessmentDate => throw _privateConstructorUsedError;
  String? get mitigation => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RiskAssessmentCopyWith<RiskAssessment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RiskAssessmentCopyWith<$Res> {
  factory $RiskAssessmentCopyWith(
          RiskAssessment value, $Res Function(RiskAssessment) then) =
      _$RiskAssessmentCopyWithImpl<$Res, RiskAssessment>;
  @useResult
  $Res call(
      {String patientId,
      String riskType,
      String riskLevel,
      double riskScore,
      List<String> riskFactors,
      DateTime assessmentDate,
      String? mitigation});
}

/// @nodoc
class _$RiskAssessmentCopyWithImpl<$Res, $Val extends RiskAssessment>
    implements $RiskAssessmentCopyWith<$Res> {
  _$RiskAssessmentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? patientId = null,
    Object? riskType = null,
    Object? riskLevel = null,
    Object? riskScore = null,
    Object? riskFactors = null,
    Object? assessmentDate = null,
    Object? mitigation = freezed,
  }) {
    return _then(_value.copyWith(
      patientId: null == patientId
          ? _value.patientId
          : patientId // ignore: cast_nullable_to_non_nullable
              as String,
      riskType: null == riskType
          ? _value.riskType
          : riskType // ignore: cast_nullable_to_non_nullable
              as String,
      riskLevel: null == riskLevel
          ? _value.riskLevel
          : riskLevel // ignore: cast_nullable_to_non_nullable
              as String,
      riskScore: null == riskScore
          ? _value.riskScore
          : riskScore // ignore: cast_nullable_to_non_nullable
              as double,
      riskFactors: null == riskFactors
          ? _value.riskFactors
          : riskFactors // ignore: cast_nullable_to_non_nullable
              as List<String>,
      assessmentDate: null == assessmentDate
          ? _value.assessmentDate
          : assessmentDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      mitigation: freezed == mitigation
          ? _value.mitigation
          : mitigation // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RiskAssessmentImplCopyWith<$Res>
    implements $RiskAssessmentCopyWith<$Res> {
  factory _$$RiskAssessmentImplCopyWith(_$RiskAssessmentImpl value,
          $Res Function(_$RiskAssessmentImpl) then) =
      __$$RiskAssessmentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String patientId,
      String riskType,
      String riskLevel,
      double riskScore,
      List<String> riskFactors,
      DateTime assessmentDate,
      String? mitigation});
}

/// @nodoc
class __$$RiskAssessmentImplCopyWithImpl<$Res>
    extends _$RiskAssessmentCopyWithImpl<$Res, _$RiskAssessmentImpl>
    implements _$$RiskAssessmentImplCopyWith<$Res> {
  __$$RiskAssessmentImplCopyWithImpl(
      _$RiskAssessmentImpl _value, $Res Function(_$RiskAssessmentImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? patientId = null,
    Object? riskType = null,
    Object? riskLevel = null,
    Object? riskScore = null,
    Object? riskFactors = null,
    Object? assessmentDate = null,
    Object? mitigation = freezed,
  }) {
    return _then(_$RiskAssessmentImpl(
      patientId: null == patientId
          ? _value.patientId
          : patientId // ignore: cast_nullable_to_non_nullable
              as String,
      riskType: null == riskType
          ? _value.riskType
          : riskType // ignore: cast_nullable_to_non_nullable
              as String,
      riskLevel: null == riskLevel
          ? _value.riskLevel
          : riskLevel // ignore: cast_nullable_to_non_nullable
              as String,
      riskScore: null == riskScore
          ? _value.riskScore
          : riskScore // ignore: cast_nullable_to_non_nullable
              as double,
      riskFactors: null == riskFactors
          ? _value._riskFactors
          : riskFactors // ignore: cast_nullable_to_non_nullable
              as List<String>,
      assessmentDate: null == assessmentDate
          ? _value.assessmentDate
          : assessmentDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      mitigation: freezed == mitigation
          ? _value.mitigation
          : mitigation // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RiskAssessmentImpl implements _RiskAssessment {
  const _$RiskAssessmentImpl(
      {required this.patientId,
      required this.riskType,
      required this.riskLevel,
      required this.riskScore,
      required final List<String> riskFactors,
      required this.assessmentDate,
      this.mitigation})
      : _riskFactors = riskFactors;

  factory _$RiskAssessmentImpl.fromJson(Map<String, dynamic> json) =>
      _$$RiskAssessmentImplFromJson(json);

  @override
  final String patientId;
  @override
  final String riskType;
  @override
  final String riskLevel;
  @override
  final double riskScore;
  final List<String> _riskFactors;
  @override
  List<String> get riskFactors {
    if (_riskFactors is EqualUnmodifiableListView) return _riskFactors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_riskFactors);
  }

  @override
  final DateTime assessmentDate;
  @override
  final String? mitigation;

  @override
  String toString() {
    return 'RiskAssessment(patientId: $patientId, riskType: $riskType, riskLevel: $riskLevel, riskScore: $riskScore, riskFactors: $riskFactors, assessmentDate: $assessmentDate, mitigation: $mitigation)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RiskAssessmentImpl &&
            (identical(other.patientId, patientId) ||
                other.patientId == patientId) &&
            (identical(other.riskType, riskType) ||
                other.riskType == riskType) &&
            (identical(other.riskLevel, riskLevel) ||
                other.riskLevel == riskLevel) &&
            (identical(other.riskScore, riskScore) ||
                other.riskScore == riskScore) &&
            const DeepCollectionEquality()
                .equals(other._riskFactors, _riskFactors) &&
            (identical(other.assessmentDate, assessmentDate) ||
                other.assessmentDate == assessmentDate) &&
            (identical(other.mitigation, mitigation) ||
                other.mitigation == mitigation));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      patientId,
      riskType,
      riskLevel,
      riskScore,
      const DeepCollectionEquality().hash(_riskFactors),
      assessmentDate,
      mitigation);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RiskAssessmentImplCopyWith<_$RiskAssessmentImpl> get copyWith =>
      __$$RiskAssessmentImplCopyWithImpl<_$RiskAssessmentImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RiskAssessmentImplToJson(
      this,
    );
  }
}

abstract class _RiskAssessment implements RiskAssessment {
  const factory _RiskAssessment(
      {required final String patientId,
      required final String riskType,
      required final String riskLevel,
      required final double riskScore,
      required final List<String> riskFactors,
      required final DateTime assessmentDate,
      final String? mitigation}) = _$RiskAssessmentImpl;

  factory _RiskAssessment.fromJson(Map<String, dynamic> json) =
      _$RiskAssessmentImpl.fromJson;

  @override
  String get patientId;
  @override
  String get riskType;
  @override
  String get riskLevel;
  @override
  double get riskScore;
  @override
  List<String> get riskFactors;
  @override
  DateTime get assessmentDate;
  @override
  String? get mitigation;
  @override
  @JsonKey(ignore: true)
  _$$RiskAssessmentImplCopyWith<_$RiskAssessmentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TrendAnalysis _$TrendAnalysisFromJson(Map<String, dynamic> json) {
  return _TrendAnalysis.fromJson(json);
}

/// @nodoc
mixin _$TrendAnalysis {
  String get metric => throw _privateConstructorUsedError;
  String get trendDirection => throw _privateConstructorUsedError;
  double get changePercentage => throw _privateConstructorUsedError;
  List<MetricDataPoint> get dataPoints => throw _privateConstructorUsedError;
  String get timeframe => throw _privateConstructorUsedError;
  String? get significance => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TrendAnalysisCopyWith<TrendAnalysis> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrendAnalysisCopyWith<$Res> {
  factory $TrendAnalysisCopyWith(
          TrendAnalysis value, $Res Function(TrendAnalysis) then) =
      _$TrendAnalysisCopyWithImpl<$Res, TrendAnalysis>;
  @useResult
  $Res call(
      {String metric,
      String trendDirection,
      double changePercentage,
      List<MetricDataPoint> dataPoints,
      String timeframe,
      String? significance});
}

/// @nodoc
class _$TrendAnalysisCopyWithImpl<$Res, $Val extends TrendAnalysis>
    implements $TrendAnalysisCopyWith<$Res> {
  _$TrendAnalysisCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? metric = null,
    Object? trendDirection = null,
    Object? changePercentage = null,
    Object? dataPoints = null,
    Object? timeframe = null,
    Object? significance = freezed,
  }) {
    return _then(_value.copyWith(
      metric: null == metric
          ? _value.metric
          : metric // ignore: cast_nullable_to_non_nullable
              as String,
      trendDirection: null == trendDirection
          ? _value.trendDirection
          : trendDirection // ignore: cast_nullable_to_non_nullable
              as String,
      changePercentage: null == changePercentage
          ? _value.changePercentage
          : changePercentage // ignore: cast_nullable_to_non_nullable
              as double,
      dataPoints: null == dataPoints
          ? _value.dataPoints
          : dataPoints // ignore: cast_nullable_to_non_nullable
              as List<MetricDataPoint>,
      timeframe: null == timeframe
          ? _value.timeframe
          : timeframe // ignore: cast_nullable_to_non_nullable
              as String,
      significance: freezed == significance
          ? _value.significance
          : significance // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TrendAnalysisImplCopyWith<$Res>
    implements $TrendAnalysisCopyWith<$Res> {
  factory _$$TrendAnalysisImplCopyWith(
          _$TrendAnalysisImpl value, $Res Function(_$TrendAnalysisImpl) then) =
      __$$TrendAnalysisImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String metric,
      String trendDirection,
      double changePercentage,
      List<MetricDataPoint> dataPoints,
      String timeframe,
      String? significance});
}

/// @nodoc
class __$$TrendAnalysisImplCopyWithImpl<$Res>
    extends _$TrendAnalysisCopyWithImpl<$Res, _$TrendAnalysisImpl>
    implements _$$TrendAnalysisImplCopyWith<$Res> {
  __$$TrendAnalysisImplCopyWithImpl(
      _$TrendAnalysisImpl _value, $Res Function(_$TrendAnalysisImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? metric = null,
    Object? trendDirection = null,
    Object? changePercentage = null,
    Object? dataPoints = null,
    Object? timeframe = null,
    Object? significance = freezed,
  }) {
    return _then(_$TrendAnalysisImpl(
      metric: null == metric
          ? _value.metric
          : metric // ignore: cast_nullable_to_non_nullable
              as String,
      trendDirection: null == trendDirection
          ? _value.trendDirection
          : trendDirection // ignore: cast_nullable_to_non_nullable
              as String,
      changePercentage: null == changePercentage
          ? _value.changePercentage
          : changePercentage // ignore: cast_nullable_to_non_nullable
              as double,
      dataPoints: null == dataPoints
          ? _value._dataPoints
          : dataPoints // ignore: cast_nullable_to_non_nullable
              as List<MetricDataPoint>,
      timeframe: null == timeframe
          ? _value.timeframe
          : timeframe // ignore: cast_nullable_to_non_nullable
              as String,
      significance: freezed == significance
          ? _value.significance
          : significance // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TrendAnalysisImpl implements _TrendAnalysis {
  const _$TrendAnalysisImpl(
      {required this.metric,
      required this.trendDirection,
      required this.changePercentage,
      required final List<MetricDataPoint> dataPoints,
      required this.timeframe,
      this.significance})
      : _dataPoints = dataPoints;

  factory _$TrendAnalysisImpl.fromJson(Map<String, dynamic> json) =>
      _$$TrendAnalysisImplFromJson(json);

  @override
  final String metric;
  @override
  final String trendDirection;
  @override
  final double changePercentage;
  final List<MetricDataPoint> _dataPoints;
  @override
  List<MetricDataPoint> get dataPoints {
    if (_dataPoints is EqualUnmodifiableListView) return _dataPoints;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_dataPoints);
  }

  @override
  final String timeframe;
  @override
  final String? significance;

  @override
  String toString() {
    return 'TrendAnalysis(metric: $metric, trendDirection: $trendDirection, changePercentage: $changePercentage, dataPoints: $dataPoints, timeframe: $timeframe, significance: $significance)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrendAnalysisImpl &&
            (identical(other.metric, metric) || other.metric == metric) &&
            (identical(other.trendDirection, trendDirection) ||
                other.trendDirection == trendDirection) &&
            (identical(other.changePercentage, changePercentage) ||
                other.changePercentage == changePercentage) &&
            const DeepCollectionEquality()
                .equals(other._dataPoints, _dataPoints) &&
            (identical(other.timeframe, timeframe) ||
                other.timeframe == timeframe) &&
            (identical(other.significance, significance) ||
                other.significance == significance));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      metric,
      trendDirection,
      changePercentage,
      const DeepCollectionEquality().hash(_dataPoints),
      timeframe,
      significance);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TrendAnalysisImplCopyWith<_$TrendAnalysisImpl> get copyWith =>
      __$$TrendAnalysisImplCopyWithImpl<_$TrendAnalysisImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TrendAnalysisImplToJson(
      this,
    );
  }
}

abstract class _TrendAnalysis implements TrendAnalysis {
  const factory _TrendAnalysis(
      {required final String metric,
      required final String trendDirection,
      required final double changePercentage,
      required final List<MetricDataPoint> dataPoints,
      required final String timeframe,
      final String? significance}) = _$TrendAnalysisImpl;

  factory _TrendAnalysis.fromJson(Map<String, dynamic> json) =
      _$TrendAnalysisImpl.fromJson;

  @override
  String get metric;
  @override
  String get trendDirection;
  @override
  double get changePercentage;
  @override
  List<MetricDataPoint> get dataPoints;
  @override
  String get timeframe;
  @override
  String? get significance;
  @override
  @JsonKey(ignore: true)
  _$$TrendAnalysisImplCopyWith<_$TrendAnalysisImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Recommendation _$RecommendationFromJson(Map<String, dynamic> json) {
  return _Recommendation.fromJson(json);
}

/// @nodoc
mixin _$Recommendation {
  String get id => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get priority => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  String? get category => throw _privateConstructorUsedError;
  String? get targetAudience => throw _privateConstructorUsedError;
  bool? get implemented => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RecommendationCopyWith<Recommendation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecommendationCopyWith<$Res> {
  factory $RecommendationCopyWith(
          Recommendation value, $Res Function(Recommendation) then) =
      _$RecommendationCopyWithImpl<$Res, Recommendation>;
  @useResult
  $Res call(
      {String id,
      String type,
      String title,
      String description,
      String priority,
      DateTime createdAt,
      String? category,
      String? targetAudience,
      bool? implemented});
}

/// @nodoc
class _$RecommendationCopyWithImpl<$Res, $Val extends Recommendation>
    implements $RecommendationCopyWith<$Res> {
  _$RecommendationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? title = null,
    Object? description = null,
    Object? priority = null,
    Object? createdAt = null,
    Object? category = freezed,
    Object? targetAudience = freezed,
    Object? implemented = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      targetAudience: freezed == targetAudience
          ? _value.targetAudience
          : targetAudience // ignore: cast_nullable_to_non_nullable
              as String?,
      implemented: freezed == implemented
          ? _value.implemented
          : implemented // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RecommendationImplCopyWith<$Res>
    implements $RecommendationCopyWith<$Res> {
  factory _$$RecommendationImplCopyWith(_$RecommendationImpl value,
          $Res Function(_$RecommendationImpl) then) =
      __$$RecommendationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String type,
      String title,
      String description,
      String priority,
      DateTime createdAt,
      String? category,
      String? targetAudience,
      bool? implemented});
}

/// @nodoc
class __$$RecommendationImplCopyWithImpl<$Res>
    extends _$RecommendationCopyWithImpl<$Res, _$RecommendationImpl>
    implements _$$RecommendationImplCopyWith<$Res> {
  __$$RecommendationImplCopyWithImpl(
      _$RecommendationImpl _value, $Res Function(_$RecommendationImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? title = null,
    Object? description = null,
    Object? priority = null,
    Object? createdAt = null,
    Object? category = freezed,
    Object? targetAudience = freezed,
    Object? implemented = freezed,
  }) {
    return _then(_$RecommendationImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      targetAudience: freezed == targetAudience
          ? _value.targetAudience
          : targetAudience // ignore: cast_nullable_to_non_nullable
              as String?,
      implemented: freezed == implemented
          ? _value.implemented
          : implemented // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RecommendationImpl implements _Recommendation {
  const _$RecommendationImpl(
      {required this.id,
      required this.type,
      required this.title,
      required this.description,
      required this.priority,
      required this.createdAt,
      this.category,
      this.targetAudience,
      this.implemented});

  factory _$RecommendationImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecommendationImplFromJson(json);

  @override
  final String id;
  @override
  final String type;
  @override
  final String title;
  @override
  final String description;
  @override
  final String priority;
  @override
  final DateTime createdAt;
  @override
  final String? category;
  @override
  final String? targetAudience;
  @override
  final bool? implemented;

  @override
  String toString() {
    return 'Recommendation(id: $id, type: $type, title: $title, description: $description, priority: $priority, createdAt: $createdAt, category: $category, targetAudience: $targetAudience, implemented: $implemented)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecommendationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.targetAudience, targetAudience) ||
                other.targetAudience == targetAudience) &&
            (identical(other.implemented, implemented) ||
                other.implemented == implemented));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, type, title, description,
      priority, createdAt, category, targetAudience, implemented);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RecommendationImplCopyWith<_$RecommendationImpl> get copyWith =>
      __$$RecommendationImplCopyWithImpl<_$RecommendationImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RecommendationImplToJson(
      this,
    );
  }
}

abstract class _Recommendation implements Recommendation {
  const factory _Recommendation(
      {required final String id,
      required final String type,
      required final String title,
      required final String description,
      required final String priority,
      required final DateTime createdAt,
      final String? category,
      final String? targetAudience,
      final bool? implemented}) = _$RecommendationImpl;

  factory _Recommendation.fromJson(Map<String, dynamic> json) =
      _$RecommendationImpl.fromJson;

  @override
  String get id;
  @override
  String get type;
  @override
  String get title;
  @override
  String get description;
  @override
  String get priority;
  @override
  DateTime get createdAt;
  @override
  String? get category;
  @override
  String? get targetAudience;
  @override
  bool? get implemented;
  @override
  @JsonKey(ignore: true)
  _$$RecommendationImplCopyWith<_$RecommendationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

KpiTrend _$KpiTrendFromJson(Map<String, dynamic> json) {
  return _KpiTrend.fromJson(json);
}

/// @nodoc
mixin _$KpiTrend {
  String get kpiName => throw _privateConstructorUsedError;
  double get currentValue => throw _privateConstructorUsedError;
  double get previousValue => throw _privateConstructorUsedError;
  double get changePercentage => throw _privateConstructorUsedError;
  String get trendDirection => throw _privateConstructorUsedError;
  String get timeframe => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $KpiTrendCopyWith<KpiTrend> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $KpiTrendCopyWith<$Res> {
  factory $KpiTrendCopyWith(KpiTrend value, $Res Function(KpiTrend) then) =
      _$KpiTrendCopyWithImpl<$Res, KpiTrend>;
  @useResult
  $Res call(
      {String kpiName,
      double currentValue,
      double previousValue,
      double changePercentage,
      String trendDirection,
      String timeframe});
}

/// @nodoc
class _$KpiTrendCopyWithImpl<$Res, $Val extends KpiTrend>
    implements $KpiTrendCopyWith<$Res> {
  _$KpiTrendCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? kpiName = null,
    Object? currentValue = null,
    Object? previousValue = null,
    Object? changePercentage = null,
    Object? trendDirection = null,
    Object? timeframe = null,
  }) {
    return _then(_value.copyWith(
      kpiName: null == kpiName
          ? _value.kpiName
          : kpiName // ignore: cast_nullable_to_non_nullable
              as String,
      currentValue: null == currentValue
          ? _value.currentValue
          : currentValue // ignore: cast_nullable_to_non_nullable
              as double,
      previousValue: null == previousValue
          ? _value.previousValue
          : previousValue // ignore: cast_nullable_to_non_nullable
              as double,
      changePercentage: null == changePercentage
          ? _value.changePercentage
          : changePercentage // ignore: cast_nullable_to_non_nullable
              as double,
      trendDirection: null == trendDirection
          ? _value.trendDirection
          : trendDirection // ignore: cast_nullable_to_non_nullable
              as String,
      timeframe: null == timeframe
          ? _value.timeframe
          : timeframe // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$KpiTrendImplCopyWith<$Res>
    implements $KpiTrendCopyWith<$Res> {
  factory _$$KpiTrendImplCopyWith(
          _$KpiTrendImpl value, $Res Function(_$KpiTrendImpl) then) =
      __$$KpiTrendImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String kpiName,
      double currentValue,
      double previousValue,
      double changePercentage,
      String trendDirection,
      String timeframe});
}

/// @nodoc
class __$$KpiTrendImplCopyWithImpl<$Res>
    extends _$KpiTrendCopyWithImpl<$Res, _$KpiTrendImpl>
    implements _$$KpiTrendImplCopyWith<$Res> {
  __$$KpiTrendImplCopyWithImpl(
      _$KpiTrendImpl _value, $Res Function(_$KpiTrendImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? kpiName = null,
    Object? currentValue = null,
    Object? previousValue = null,
    Object? changePercentage = null,
    Object? trendDirection = null,
    Object? timeframe = null,
  }) {
    return _then(_$KpiTrendImpl(
      kpiName: null == kpiName
          ? _value.kpiName
          : kpiName // ignore: cast_nullable_to_non_nullable
              as String,
      currentValue: null == currentValue
          ? _value.currentValue
          : currentValue // ignore: cast_nullable_to_non_nullable
              as double,
      previousValue: null == previousValue
          ? _value.previousValue
          : previousValue // ignore: cast_nullable_to_non_nullable
              as double,
      changePercentage: null == changePercentage
          ? _value.changePercentage
          : changePercentage // ignore: cast_nullable_to_non_nullable
              as double,
      trendDirection: null == trendDirection
          ? _value.trendDirection
          : trendDirection // ignore: cast_nullable_to_non_nullable
              as String,
      timeframe: null == timeframe
          ? _value.timeframe
          : timeframe // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$KpiTrendImpl implements _KpiTrend {
  const _$KpiTrendImpl(
      {required this.kpiName,
      required this.currentValue,
      required this.previousValue,
      required this.changePercentage,
      required this.trendDirection,
      required this.timeframe});

  factory _$KpiTrendImpl.fromJson(Map<String, dynamic> json) =>
      _$$KpiTrendImplFromJson(json);

  @override
  final String kpiName;
  @override
  final double currentValue;
  @override
  final double previousValue;
  @override
  final double changePercentage;
  @override
  final String trendDirection;
  @override
  final String timeframe;

  @override
  String toString() {
    return 'KpiTrend(kpiName: $kpiName, currentValue: $currentValue, previousValue: $previousValue, changePercentage: $changePercentage, trendDirection: $trendDirection, timeframe: $timeframe)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$KpiTrendImpl &&
            (identical(other.kpiName, kpiName) || other.kpiName == kpiName) &&
            (identical(other.currentValue, currentValue) ||
                other.currentValue == currentValue) &&
            (identical(other.previousValue, previousValue) ||
                other.previousValue == previousValue) &&
            (identical(other.changePercentage, changePercentage) ||
                other.changePercentage == changePercentage) &&
            (identical(other.trendDirection, trendDirection) ||
                other.trendDirection == trendDirection) &&
            (identical(other.timeframe, timeframe) ||
                other.timeframe == timeframe));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, kpiName, currentValue,
      previousValue, changePercentage, trendDirection, timeframe);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$KpiTrendImplCopyWith<_$KpiTrendImpl> get copyWith =>
      __$$KpiTrendImplCopyWithImpl<_$KpiTrendImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$KpiTrendImplToJson(
      this,
    );
  }
}

abstract class _KpiTrend implements KpiTrend {
  const factory _KpiTrend(
      {required final String kpiName,
      required final double currentValue,
      required final double previousValue,
      required final double changePercentage,
      required final String trendDirection,
      required final String timeframe}) = _$KpiTrendImpl;

  factory _KpiTrend.fromJson(Map<String, dynamic> json) =
      _$KpiTrendImpl.fromJson;

  @override
  String get kpiName;
  @override
  double get currentValue;
  @override
  double get previousValue;
  @override
  double get changePercentage;
  @override
  String get trendDirection;
  @override
  String get timeframe;
  @override
  @JsonKey(ignore: true)
  _$$KpiTrendImplCopyWith<_$KpiTrendImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Benchmark _$BenchmarkFromJson(Map<String, dynamic> json) {
  return _Benchmark.fromJson(json);
}

/// @nodoc
mixin _$Benchmark {
  String get metric => throw _privateConstructorUsedError;
  double get ourValue => throw _privateConstructorUsedError;
  double get industryAverage => throw _privateConstructorUsedError;
  double get bestPractice => throw _privateConstructorUsedError;
  String get comparison => throw _privateConstructorUsedError;
  String? get unit => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BenchmarkCopyWith<Benchmark> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BenchmarkCopyWith<$Res> {
  factory $BenchmarkCopyWith(Benchmark value, $Res Function(Benchmark) then) =
      _$BenchmarkCopyWithImpl<$Res, Benchmark>;
  @useResult
  $Res call(
      {String metric,
      double ourValue,
      double industryAverage,
      double bestPractice,
      String comparison,
      String? unit});
}

/// @nodoc
class _$BenchmarkCopyWithImpl<$Res, $Val extends Benchmark>
    implements $BenchmarkCopyWith<$Res> {
  _$BenchmarkCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? metric = null,
    Object? ourValue = null,
    Object? industryAverage = null,
    Object? bestPractice = null,
    Object? comparison = null,
    Object? unit = freezed,
  }) {
    return _then(_value.copyWith(
      metric: null == metric
          ? _value.metric
          : metric // ignore: cast_nullable_to_non_nullable
              as String,
      ourValue: null == ourValue
          ? _value.ourValue
          : ourValue // ignore: cast_nullable_to_non_nullable
              as double,
      industryAverage: null == industryAverage
          ? _value.industryAverage
          : industryAverage // ignore: cast_nullable_to_non_nullable
              as double,
      bestPractice: null == bestPractice
          ? _value.bestPractice
          : bestPractice // ignore: cast_nullable_to_non_nullable
              as double,
      comparison: null == comparison
          ? _value.comparison
          : comparison // ignore: cast_nullable_to_non_nullable
              as String,
      unit: freezed == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BenchmarkImplCopyWith<$Res>
    implements $BenchmarkCopyWith<$Res> {
  factory _$$BenchmarkImplCopyWith(
          _$BenchmarkImpl value, $Res Function(_$BenchmarkImpl) then) =
      __$$BenchmarkImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String metric,
      double ourValue,
      double industryAverage,
      double bestPractice,
      String comparison,
      String? unit});
}

/// @nodoc
class __$$BenchmarkImplCopyWithImpl<$Res>
    extends _$BenchmarkCopyWithImpl<$Res, _$BenchmarkImpl>
    implements _$$BenchmarkImplCopyWith<$Res> {
  __$$BenchmarkImplCopyWithImpl(
      _$BenchmarkImpl _value, $Res Function(_$BenchmarkImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? metric = null,
    Object? ourValue = null,
    Object? industryAverage = null,
    Object? bestPractice = null,
    Object? comparison = null,
    Object? unit = freezed,
  }) {
    return _then(_$BenchmarkImpl(
      metric: null == metric
          ? _value.metric
          : metric // ignore: cast_nullable_to_non_nullable
              as String,
      ourValue: null == ourValue
          ? _value.ourValue
          : ourValue // ignore: cast_nullable_to_non_nullable
              as double,
      industryAverage: null == industryAverage
          ? _value.industryAverage
          : industryAverage // ignore: cast_nullable_to_non_nullable
              as double,
      bestPractice: null == bestPractice
          ? _value.bestPractice
          : bestPractice // ignore: cast_nullable_to_non_nullable
              as double,
      comparison: null == comparison
          ? _value.comparison
          : comparison // ignore: cast_nullable_to_non_nullable
              as String,
      unit: freezed == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BenchmarkImpl implements _Benchmark {
  const _$BenchmarkImpl(
      {required this.metric,
      required this.ourValue,
      required this.industryAverage,
      required this.bestPractice,
      required this.comparison,
      this.unit});

  factory _$BenchmarkImpl.fromJson(Map<String, dynamic> json) =>
      _$$BenchmarkImplFromJson(json);

  @override
  final String metric;
  @override
  final double ourValue;
  @override
  final double industryAverage;
  @override
  final double bestPractice;
  @override
  final String comparison;
  @override
  final String? unit;

  @override
  String toString() {
    return 'Benchmark(metric: $metric, ourValue: $ourValue, industryAverage: $industryAverage, bestPractice: $bestPractice, comparison: $comparison, unit: $unit)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BenchmarkImpl &&
            (identical(other.metric, metric) || other.metric == metric) &&
            (identical(other.ourValue, ourValue) ||
                other.ourValue == ourValue) &&
            (identical(other.industryAverage, industryAverage) ||
                other.industryAverage == industryAverage) &&
            (identical(other.bestPractice, bestPractice) ||
                other.bestPractice == bestPractice) &&
            (identical(other.comparison, comparison) ||
                other.comparison == comparison) &&
            (identical(other.unit, unit) || other.unit == unit));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, metric, ourValue,
      industryAverage, bestPractice, comparison, unit);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BenchmarkImplCopyWith<_$BenchmarkImpl> get copyWith =>
      __$$BenchmarkImplCopyWithImpl<_$BenchmarkImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BenchmarkImplToJson(
      this,
    );
  }
}

abstract class _Benchmark implements Benchmark {
  const factory _Benchmark(
      {required final String metric,
      required final double ourValue,
      required final double industryAverage,
      required final double bestPractice,
      required final String comparison,
      final String? unit}) = _$BenchmarkImpl;

  factory _Benchmark.fromJson(Map<String, dynamic> json) =
      _$BenchmarkImpl.fromJson;

  @override
  String get metric;
  @override
  double get ourValue;
  @override
  double get industryAverage;
  @override
  double get bestPractice;
  @override
  String get comparison;
  @override
  String? get unit;
  @override
  @JsonKey(ignore: true)
  _$$BenchmarkImplCopyWith<_$BenchmarkImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DemographicData _$DemographicDataFromJson(Map<String, dynamic> json) {
  return _DemographicData.fromJson(json);
}

/// @nodoc
mixin _$DemographicData {
  String get category => throw _privateConstructorUsedError;
  String get subcategory => throw _privateConstructorUsedError;
  int get count => throw _privateConstructorUsedError;
  double get percentage => throw _privateConstructorUsedError;
  String? get ageGroup => throw _privateConstructorUsedError;
  String? get gender => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DemographicDataCopyWith<DemographicData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DemographicDataCopyWith<$Res> {
  factory $DemographicDataCopyWith(
          DemographicData value, $Res Function(DemographicData) then) =
      _$DemographicDataCopyWithImpl<$Res, DemographicData>;
  @useResult
  $Res call(
      {String category,
      String subcategory,
      int count,
      double percentage,
      String? ageGroup,
      String? gender});
}

/// @nodoc
class _$DemographicDataCopyWithImpl<$Res, $Val extends DemographicData>
    implements $DemographicDataCopyWith<$Res> {
  _$DemographicDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? category = null,
    Object? subcategory = null,
    Object? count = null,
    Object? percentage = null,
    Object? ageGroup = freezed,
    Object? gender = freezed,
  }) {
    return _then(_value.copyWith(
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      subcategory: null == subcategory
          ? _value.subcategory
          : subcategory // ignore: cast_nullable_to_non_nullable
              as String,
      count: null == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
      percentage: null == percentage
          ? _value.percentage
          : percentage // ignore: cast_nullable_to_non_nullable
              as double,
      ageGroup: freezed == ageGroup
          ? _value.ageGroup
          : ageGroup // ignore: cast_nullable_to_non_nullable
              as String?,
      gender: freezed == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DemographicDataImplCopyWith<$Res>
    implements $DemographicDataCopyWith<$Res> {
  factory _$$DemographicDataImplCopyWith(_$DemographicDataImpl value,
          $Res Function(_$DemographicDataImpl) then) =
      __$$DemographicDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String category,
      String subcategory,
      int count,
      double percentage,
      String? ageGroup,
      String? gender});
}

/// @nodoc
class __$$DemographicDataImplCopyWithImpl<$Res>
    extends _$DemographicDataCopyWithImpl<$Res, _$DemographicDataImpl>
    implements _$$DemographicDataImplCopyWith<$Res> {
  __$$DemographicDataImplCopyWithImpl(
      _$DemographicDataImpl _value, $Res Function(_$DemographicDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? category = null,
    Object? subcategory = null,
    Object? count = null,
    Object? percentage = null,
    Object? ageGroup = freezed,
    Object? gender = freezed,
  }) {
    return _then(_$DemographicDataImpl(
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      subcategory: null == subcategory
          ? _value.subcategory
          : subcategory // ignore: cast_nullable_to_non_nullable
              as String,
      count: null == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
      percentage: null == percentage
          ? _value.percentage
          : percentage // ignore: cast_nullable_to_non_nullable
              as double,
      ageGroup: freezed == ageGroup
          ? _value.ageGroup
          : ageGroup // ignore: cast_nullable_to_non_nullable
              as String?,
      gender: freezed == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DemographicDataImpl implements _DemographicData {
  const _$DemographicDataImpl(
      {required this.category,
      required this.subcategory,
      required this.count,
      required this.percentage,
      this.ageGroup,
      this.gender});

  factory _$DemographicDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$DemographicDataImplFromJson(json);

  @override
  final String category;
  @override
  final String subcategory;
  @override
  final int count;
  @override
  final double percentage;
  @override
  final String? ageGroup;
  @override
  final String? gender;

  @override
  String toString() {
    return 'DemographicData(category: $category, subcategory: $subcategory, count: $count, percentage: $percentage, ageGroup: $ageGroup, gender: $gender)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DemographicDataImpl &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.subcategory, subcategory) ||
                other.subcategory == subcategory) &&
            (identical(other.count, count) || other.count == count) &&
            (identical(other.percentage, percentage) ||
                other.percentage == percentage) &&
            (identical(other.ageGroup, ageGroup) ||
                other.ageGroup == ageGroup) &&
            (identical(other.gender, gender) || other.gender == gender));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, category, subcategory, count, percentage, ageGroup, gender);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DemographicDataImplCopyWith<_$DemographicDataImpl> get copyWith =>
      __$$DemographicDataImplCopyWithImpl<_$DemographicDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DemographicDataImplToJson(
      this,
    );
  }
}

abstract class _DemographicData implements DemographicData {
  const factory _DemographicData(
      {required final String category,
      required final String subcategory,
      required final int count,
      required final double percentage,
      final String? ageGroup,
      final String? gender}) = _$DemographicDataImpl;

  factory _DemographicData.fromJson(Map<String, dynamic> json) =
      _$DemographicDataImpl.fromJson;

  @override
  String get category;
  @override
  String get subcategory;
  @override
  int get count;
  @override
  double get percentage;
  @override
  String? get ageGroup;
  @override
  String? get gender;
  @override
  @JsonKey(ignore: true)
  _$$DemographicDataImplCopyWith<_$DemographicDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DiseasePrevalence _$DiseasePrevalenceFromJson(Map<String, dynamic> json) {
  return _DiseasePrevalence.fromJson(json);
}

/// @nodoc
mixin _$DiseasePrevalence {
  String get disease => throw _privateConstructorUsedError;
  int get cases => throw _privateConstructorUsedError;
  double get prevalenceRate => throw _privateConstructorUsedError;
  String get timeframe => throw _privateConstructorUsedError;
  double get changeFromPrevious => throw _privateConstructorUsedError;
  String? get severity => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DiseasePrevalenceCopyWith<DiseasePrevalence> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DiseasePrevalenceCopyWith<$Res> {
  factory $DiseasePrevalenceCopyWith(
          DiseasePrevalence value, $Res Function(DiseasePrevalence) then) =
      _$DiseasePrevalenceCopyWithImpl<$Res, DiseasePrevalence>;
  @useResult
  $Res call(
      {String disease,
      int cases,
      double prevalenceRate,
      String timeframe,
      double changeFromPrevious,
      String? severity});
}

/// @nodoc
class _$DiseasePrevalenceCopyWithImpl<$Res, $Val extends DiseasePrevalence>
    implements $DiseasePrevalenceCopyWith<$Res> {
  _$DiseasePrevalenceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? disease = null,
    Object? cases = null,
    Object? prevalenceRate = null,
    Object? timeframe = null,
    Object? changeFromPrevious = null,
    Object? severity = freezed,
  }) {
    return _then(_value.copyWith(
      disease: null == disease
          ? _value.disease
          : disease // ignore: cast_nullable_to_non_nullable
              as String,
      cases: null == cases
          ? _value.cases
          : cases // ignore: cast_nullable_to_non_nullable
              as int,
      prevalenceRate: null == prevalenceRate
          ? _value.prevalenceRate
          : prevalenceRate // ignore: cast_nullable_to_non_nullable
              as double,
      timeframe: null == timeframe
          ? _value.timeframe
          : timeframe // ignore: cast_nullable_to_non_nullable
              as String,
      changeFromPrevious: null == changeFromPrevious
          ? _value.changeFromPrevious
          : changeFromPrevious // ignore: cast_nullable_to_non_nullable
              as double,
      severity: freezed == severity
          ? _value.severity
          : severity // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DiseasePrevalenceImplCopyWith<$Res>
    implements $DiseasePrevalenceCopyWith<$Res> {
  factory _$$DiseasePrevalenceImplCopyWith(_$DiseasePrevalenceImpl value,
          $Res Function(_$DiseasePrevalenceImpl) then) =
      __$$DiseasePrevalenceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String disease,
      int cases,
      double prevalenceRate,
      String timeframe,
      double changeFromPrevious,
      String? severity});
}

/// @nodoc
class __$$DiseasePrevalenceImplCopyWithImpl<$Res>
    extends _$DiseasePrevalenceCopyWithImpl<$Res, _$DiseasePrevalenceImpl>
    implements _$$DiseasePrevalenceImplCopyWith<$Res> {
  __$$DiseasePrevalenceImplCopyWithImpl(_$DiseasePrevalenceImpl _value,
      $Res Function(_$DiseasePrevalenceImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? disease = null,
    Object? cases = null,
    Object? prevalenceRate = null,
    Object? timeframe = null,
    Object? changeFromPrevious = null,
    Object? severity = freezed,
  }) {
    return _then(_$DiseasePrevalenceImpl(
      disease: null == disease
          ? _value.disease
          : disease // ignore: cast_nullable_to_non_nullable
              as String,
      cases: null == cases
          ? _value.cases
          : cases // ignore: cast_nullable_to_non_nullable
              as int,
      prevalenceRate: null == prevalenceRate
          ? _value.prevalenceRate
          : prevalenceRate // ignore: cast_nullable_to_non_nullable
              as double,
      timeframe: null == timeframe
          ? _value.timeframe
          : timeframe // ignore: cast_nullable_to_non_nullable
              as String,
      changeFromPrevious: null == changeFromPrevious
          ? _value.changeFromPrevious
          : changeFromPrevious // ignore: cast_nullable_to_non_nullable
              as double,
      severity: freezed == severity
          ? _value.severity
          : severity // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DiseasePrevalenceImpl implements _DiseasePrevalence {
  const _$DiseasePrevalenceImpl(
      {required this.disease,
      required this.cases,
      required this.prevalenceRate,
      required this.timeframe,
      required this.changeFromPrevious,
      this.severity});

  factory _$DiseasePrevalenceImpl.fromJson(Map<String, dynamic> json) =>
      _$$DiseasePrevalenceImplFromJson(json);

  @override
  final String disease;
  @override
  final int cases;
  @override
  final double prevalenceRate;
  @override
  final String timeframe;
  @override
  final double changeFromPrevious;
  @override
  final String? severity;

  @override
  String toString() {
    return 'DiseasePrevalence(disease: $disease, cases: $cases, prevalenceRate: $prevalenceRate, timeframe: $timeframe, changeFromPrevious: $changeFromPrevious, severity: $severity)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DiseasePrevalenceImpl &&
            (identical(other.disease, disease) || other.disease == disease) &&
            (identical(other.cases, cases) || other.cases == cases) &&
            (identical(other.prevalenceRate, prevalenceRate) ||
                other.prevalenceRate == prevalenceRate) &&
            (identical(other.timeframe, timeframe) ||
                other.timeframe == timeframe) &&
            (identical(other.changeFromPrevious, changeFromPrevious) ||
                other.changeFromPrevious == changeFromPrevious) &&
            (identical(other.severity, severity) ||
                other.severity == severity));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, disease, cases, prevalenceRate,
      timeframe, changeFromPrevious, severity);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DiseasePrevalenceImplCopyWith<_$DiseasePrevalenceImpl> get copyWith =>
      __$$DiseasePrevalenceImplCopyWithImpl<_$DiseasePrevalenceImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DiseasePrevalenceImplToJson(
      this,
    );
  }
}

abstract class _DiseasePrevalence implements DiseasePrevalence {
  const factory _DiseasePrevalence(
      {required final String disease,
      required final int cases,
      required final double prevalenceRate,
      required final String timeframe,
      required final double changeFromPrevious,
      final String? severity}) = _$DiseasePrevalenceImpl;

  factory _DiseasePrevalence.fromJson(Map<String, dynamic> json) =
      _$DiseasePrevalenceImpl.fromJson;

  @override
  String get disease;
  @override
  int get cases;
  @override
  double get prevalenceRate;
  @override
  String get timeframe;
  @override
  double get changeFromPrevious;
  @override
  String? get severity;
  @override
  @JsonKey(ignore: true)
  _$$DiseasePrevalenceImplCopyWith<_$DiseasePrevalenceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

OutbreakAlert _$OutbreakAlertFromJson(Map<String, dynamic> json) {
  return _OutbreakAlert.fromJson(json);
}

/// @nodoc
mixin _$OutbreakAlert {
  String get id => throw _privateConstructorUsedError;
  String get disease => throw _privateConstructorUsedError;
  String get location => throw _privateConstructorUsedError;
  int get affectedCount => throw _privateConstructorUsedError;
  String get severity => throw _privateConstructorUsedError;
  DateTime get detectedAt => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $OutbreakAlertCopyWith<OutbreakAlert> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OutbreakAlertCopyWith<$Res> {
  factory $OutbreakAlertCopyWith(
          OutbreakAlert value, $Res Function(OutbreakAlert) then) =
      _$OutbreakAlertCopyWithImpl<$Res, OutbreakAlert>;
  @useResult
  $Res call(
      {String id,
      String disease,
      String location,
      int affectedCount,
      String severity,
      DateTime detectedAt,
      String status,
      String? description});
}

/// @nodoc
class _$OutbreakAlertCopyWithImpl<$Res, $Val extends OutbreakAlert>
    implements $OutbreakAlertCopyWith<$Res> {
  _$OutbreakAlertCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? disease = null,
    Object? location = null,
    Object? affectedCount = null,
    Object? severity = null,
    Object? detectedAt = null,
    Object? status = null,
    Object? description = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      disease: null == disease
          ? _value.disease
          : disease // ignore: cast_nullable_to_non_nullable
              as String,
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String,
      affectedCount: null == affectedCount
          ? _value.affectedCount
          : affectedCount // ignore: cast_nullable_to_non_nullable
              as int,
      severity: null == severity
          ? _value.severity
          : severity // ignore: cast_nullable_to_non_nullable
              as String,
      detectedAt: null == detectedAt
          ? _value.detectedAt
          : detectedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OutbreakAlertImplCopyWith<$Res>
    implements $OutbreakAlertCopyWith<$Res> {
  factory _$$OutbreakAlertImplCopyWith(
          _$OutbreakAlertImpl value, $Res Function(_$OutbreakAlertImpl) then) =
      __$$OutbreakAlertImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String disease,
      String location,
      int affectedCount,
      String severity,
      DateTime detectedAt,
      String status,
      String? description});
}

/// @nodoc
class __$$OutbreakAlertImplCopyWithImpl<$Res>
    extends _$OutbreakAlertCopyWithImpl<$Res, _$OutbreakAlertImpl>
    implements _$$OutbreakAlertImplCopyWith<$Res> {
  __$$OutbreakAlertImplCopyWithImpl(
      _$OutbreakAlertImpl _value, $Res Function(_$OutbreakAlertImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? disease = null,
    Object? location = null,
    Object? affectedCount = null,
    Object? severity = null,
    Object? detectedAt = null,
    Object? status = null,
    Object? description = freezed,
  }) {
    return _then(_$OutbreakAlertImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      disease: null == disease
          ? _value.disease
          : disease // ignore: cast_nullable_to_non_nullable
              as String,
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String,
      affectedCount: null == affectedCount
          ? _value.affectedCount
          : affectedCount // ignore: cast_nullable_to_non_nullable
              as int,
      severity: null == severity
          ? _value.severity
          : severity // ignore: cast_nullable_to_non_nullable
              as String,
      detectedAt: null == detectedAt
          ? _value.detectedAt
          : detectedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$OutbreakAlertImpl implements _OutbreakAlert {
  const _$OutbreakAlertImpl(
      {required this.id,
      required this.disease,
      required this.location,
      required this.affectedCount,
      required this.severity,
      required this.detectedAt,
      required this.status,
      this.description});

  factory _$OutbreakAlertImpl.fromJson(Map<String, dynamic> json) =>
      _$$OutbreakAlertImplFromJson(json);

  @override
  final String id;
  @override
  final String disease;
  @override
  final String location;
  @override
  final int affectedCount;
  @override
  final String severity;
  @override
  final DateTime detectedAt;
  @override
  final String status;
  @override
  final String? description;

  @override
  String toString() {
    return 'OutbreakAlert(id: $id, disease: $disease, location: $location, affectedCount: $affectedCount, severity: $severity, detectedAt: $detectedAt, status: $status, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OutbreakAlertImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.disease, disease) || other.disease == disease) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.affectedCount, affectedCount) ||
                other.affectedCount == affectedCount) &&
            (identical(other.severity, severity) ||
                other.severity == severity) &&
            (identical(other.detectedAt, detectedAt) ||
                other.detectedAt == detectedAt) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, disease, location,
      affectedCount, severity, detectedAt, status, description);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$OutbreakAlertImplCopyWith<_$OutbreakAlertImpl> get copyWith =>
      __$$OutbreakAlertImplCopyWithImpl<_$OutbreakAlertImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OutbreakAlertImplToJson(
      this,
    );
  }
}

abstract class _OutbreakAlert implements OutbreakAlert {
  const factory _OutbreakAlert(
      {required final String id,
      required final String disease,
      required final String location,
      required final int affectedCount,
      required final String severity,
      required final DateTime detectedAt,
      required final String status,
      final String? description}) = _$OutbreakAlertImpl;

  factory _OutbreakAlert.fromJson(Map<String, dynamic> json) =
      _$OutbreakAlertImpl.fromJson;

  @override
  String get id;
  @override
  String get disease;
  @override
  String get location;
  @override
  int get affectedCount;
  @override
  String get severity;
  @override
  DateTime get detectedAt;
  @override
  String get status;
  @override
  String? get description;
  @override
  @JsonKey(ignore: true)
  _$$OutbreakAlertImplCopyWith<_$OutbreakAlertImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

HealthTrend _$HealthTrendFromJson(Map<String, dynamic> json) {
  return _HealthTrend.fromJson(json);
}

/// @nodoc
mixin _$HealthTrend {
  String get indicator => throw _privateConstructorUsedError;
  String get trendDirection => throw _privateConstructorUsedError;
  double get changeRate => throw _privateConstructorUsedError;
  String get timeframe => throw _privateConstructorUsedError;
  List<MetricDataPoint> get dataPoints => throw _privateConstructorUsedError;
  String? get significance => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $HealthTrendCopyWith<HealthTrend> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HealthTrendCopyWith<$Res> {
  factory $HealthTrendCopyWith(
          HealthTrend value, $Res Function(HealthTrend) then) =
      _$HealthTrendCopyWithImpl<$Res, HealthTrend>;
  @useResult
  $Res call(
      {String indicator,
      String trendDirection,
      double changeRate,
      String timeframe,
      List<MetricDataPoint> dataPoints,
      String? significance});
}

/// @nodoc
class _$HealthTrendCopyWithImpl<$Res, $Val extends HealthTrend>
    implements $HealthTrendCopyWith<$Res> {
  _$HealthTrendCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? indicator = null,
    Object? trendDirection = null,
    Object? changeRate = null,
    Object? timeframe = null,
    Object? dataPoints = null,
    Object? significance = freezed,
  }) {
    return _then(_value.copyWith(
      indicator: null == indicator
          ? _value.indicator
          : indicator // ignore: cast_nullable_to_non_nullable
              as String,
      trendDirection: null == trendDirection
          ? _value.trendDirection
          : trendDirection // ignore: cast_nullable_to_non_nullable
              as String,
      changeRate: null == changeRate
          ? _value.changeRate
          : changeRate // ignore: cast_nullable_to_non_nullable
              as double,
      timeframe: null == timeframe
          ? _value.timeframe
          : timeframe // ignore: cast_nullable_to_non_nullable
              as String,
      dataPoints: null == dataPoints
          ? _value.dataPoints
          : dataPoints // ignore: cast_nullable_to_non_nullable
              as List<MetricDataPoint>,
      significance: freezed == significance
          ? _value.significance
          : significance // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HealthTrendImplCopyWith<$Res>
    implements $HealthTrendCopyWith<$Res> {
  factory _$$HealthTrendImplCopyWith(
          _$HealthTrendImpl value, $Res Function(_$HealthTrendImpl) then) =
      __$$HealthTrendImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String indicator,
      String trendDirection,
      double changeRate,
      String timeframe,
      List<MetricDataPoint> dataPoints,
      String? significance});
}

/// @nodoc
class __$$HealthTrendImplCopyWithImpl<$Res>
    extends _$HealthTrendCopyWithImpl<$Res, _$HealthTrendImpl>
    implements _$$HealthTrendImplCopyWith<$Res> {
  __$$HealthTrendImplCopyWithImpl(
      _$HealthTrendImpl _value, $Res Function(_$HealthTrendImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? indicator = null,
    Object? trendDirection = null,
    Object? changeRate = null,
    Object? timeframe = null,
    Object? dataPoints = null,
    Object? significance = freezed,
  }) {
    return _then(_$HealthTrendImpl(
      indicator: null == indicator
          ? _value.indicator
          : indicator // ignore: cast_nullable_to_non_nullable
              as String,
      trendDirection: null == trendDirection
          ? _value.trendDirection
          : trendDirection // ignore: cast_nullable_to_non_nullable
              as String,
      changeRate: null == changeRate
          ? _value.changeRate
          : changeRate // ignore: cast_nullable_to_non_nullable
              as double,
      timeframe: null == timeframe
          ? _value.timeframe
          : timeframe // ignore: cast_nullable_to_non_nullable
              as String,
      dataPoints: null == dataPoints
          ? _value._dataPoints
          : dataPoints // ignore: cast_nullable_to_non_nullable
              as List<MetricDataPoint>,
      significance: freezed == significance
          ? _value.significance
          : significance // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HealthTrendImpl implements _HealthTrend {
  const _$HealthTrendImpl(
      {required this.indicator,
      required this.trendDirection,
      required this.changeRate,
      required this.timeframe,
      required final List<MetricDataPoint> dataPoints,
      this.significance})
      : _dataPoints = dataPoints;

  factory _$HealthTrendImpl.fromJson(Map<String, dynamic> json) =>
      _$$HealthTrendImplFromJson(json);

  @override
  final String indicator;
  @override
  final String trendDirection;
  @override
  final double changeRate;
  @override
  final String timeframe;
  final List<MetricDataPoint> _dataPoints;
  @override
  List<MetricDataPoint> get dataPoints {
    if (_dataPoints is EqualUnmodifiableListView) return _dataPoints;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_dataPoints);
  }

  @override
  final String? significance;

  @override
  String toString() {
    return 'HealthTrend(indicator: $indicator, trendDirection: $trendDirection, changeRate: $changeRate, timeframe: $timeframe, dataPoints: $dataPoints, significance: $significance)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HealthTrendImpl &&
            (identical(other.indicator, indicator) ||
                other.indicator == indicator) &&
            (identical(other.trendDirection, trendDirection) ||
                other.trendDirection == trendDirection) &&
            (identical(other.changeRate, changeRate) ||
                other.changeRate == changeRate) &&
            (identical(other.timeframe, timeframe) ||
                other.timeframe == timeframe) &&
            const DeepCollectionEquality()
                .equals(other._dataPoints, _dataPoints) &&
            (identical(other.significance, significance) ||
                other.significance == significance));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      indicator,
      trendDirection,
      changeRate,
      timeframe,
      const DeepCollectionEquality().hash(_dataPoints),
      significance);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$HealthTrendImplCopyWith<_$HealthTrendImpl> get copyWith =>
      __$$HealthTrendImplCopyWithImpl<_$HealthTrendImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HealthTrendImplToJson(
      this,
    );
  }
}

abstract class _HealthTrend implements HealthTrend {
  const factory _HealthTrend(
      {required final String indicator,
      required final String trendDirection,
      required final double changeRate,
      required final String timeframe,
      required final List<MetricDataPoint> dataPoints,
      final String? significance}) = _$HealthTrendImpl;

  factory _HealthTrend.fromJson(Map<String, dynamic> json) =
      _$HealthTrendImpl.fromJson;

  @override
  String get indicator;
  @override
  String get trendDirection;
  @override
  double get changeRate;
  @override
  String get timeframe;
  @override
  List<MetricDataPoint> get dataPoints;
  @override
  String? get significance;
  @override
  @JsonKey(ignore: true)
  _$$HealthTrendImplCopyWith<_$HealthTrendImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PreventiveCareMetric _$PreventiveCareMetricFromJson(Map<String, dynamic> json) {
  return _PreventiveCareMetric.fromJson(json);
}

/// @nodoc
mixin _$PreventiveCareMetric {
  String get careType => throw _privateConstructorUsedError;
  int get eligiblePopulation => throw _privateConstructorUsedError;
  int get completedScreenings => throw _privateConstructorUsedError;
  double get completionRate => throw _privateConstructorUsedError;
  double get targetRate => throw _privateConstructorUsedError;
  String? get timeframe => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PreventiveCareMetricCopyWith<PreventiveCareMetric> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PreventiveCareMetricCopyWith<$Res> {
  factory $PreventiveCareMetricCopyWith(PreventiveCareMetric value,
          $Res Function(PreventiveCareMetric) then) =
      _$PreventiveCareMetricCopyWithImpl<$Res, PreventiveCareMetric>;
  @useResult
  $Res call(
      {String careType,
      int eligiblePopulation,
      int completedScreenings,
      double completionRate,
      double targetRate,
      String? timeframe});
}

/// @nodoc
class _$PreventiveCareMetricCopyWithImpl<$Res,
        $Val extends PreventiveCareMetric>
    implements $PreventiveCareMetricCopyWith<$Res> {
  _$PreventiveCareMetricCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? careType = null,
    Object? eligiblePopulation = null,
    Object? completedScreenings = null,
    Object? completionRate = null,
    Object? targetRate = null,
    Object? timeframe = freezed,
  }) {
    return _then(_value.copyWith(
      careType: null == careType
          ? _value.careType
          : careType // ignore: cast_nullable_to_non_nullable
              as String,
      eligiblePopulation: null == eligiblePopulation
          ? _value.eligiblePopulation
          : eligiblePopulation // ignore: cast_nullable_to_non_nullable
              as int,
      completedScreenings: null == completedScreenings
          ? _value.completedScreenings
          : completedScreenings // ignore: cast_nullable_to_non_nullable
              as int,
      completionRate: null == completionRate
          ? _value.completionRate
          : completionRate // ignore: cast_nullable_to_non_nullable
              as double,
      targetRate: null == targetRate
          ? _value.targetRate
          : targetRate // ignore: cast_nullable_to_non_nullable
              as double,
      timeframe: freezed == timeframe
          ? _value.timeframe
          : timeframe // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PreventiveCareMetricImplCopyWith<$Res>
    implements $PreventiveCareMetricCopyWith<$Res> {
  factory _$$PreventiveCareMetricImplCopyWith(_$PreventiveCareMetricImpl value,
          $Res Function(_$PreventiveCareMetricImpl) then) =
      __$$PreventiveCareMetricImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String careType,
      int eligiblePopulation,
      int completedScreenings,
      double completionRate,
      double targetRate,
      String? timeframe});
}

/// @nodoc
class __$$PreventiveCareMetricImplCopyWithImpl<$Res>
    extends _$PreventiveCareMetricCopyWithImpl<$Res, _$PreventiveCareMetricImpl>
    implements _$$PreventiveCareMetricImplCopyWith<$Res> {
  __$$PreventiveCareMetricImplCopyWithImpl(_$PreventiveCareMetricImpl _value,
      $Res Function(_$PreventiveCareMetricImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? careType = null,
    Object? eligiblePopulation = null,
    Object? completedScreenings = null,
    Object? completionRate = null,
    Object? targetRate = null,
    Object? timeframe = freezed,
  }) {
    return _then(_$PreventiveCareMetricImpl(
      careType: null == careType
          ? _value.careType
          : careType // ignore: cast_nullable_to_non_nullable
              as String,
      eligiblePopulation: null == eligiblePopulation
          ? _value.eligiblePopulation
          : eligiblePopulation // ignore: cast_nullable_to_non_nullable
              as int,
      completedScreenings: null == completedScreenings
          ? _value.completedScreenings
          : completedScreenings // ignore: cast_nullable_to_non_nullable
              as int,
      completionRate: null == completionRate
          ? _value.completionRate
          : completionRate // ignore: cast_nullable_to_non_nullable
              as double,
      targetRate: null == targetRate
          ? _value.targetRate
          : targetRate // ignore: cast_nullable_to_non_nullable
              as double,
      timeframe: freezed == timeframe
          ? _value.timeframe
          : timeframe // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PreventiveCareMetricImpl implements _PreventiveCareMetric {
  const _$PreventiveCareMetricImpl(
      {required this.careType,
      required this.eligiblePopulation,
      required this.completedScreenings,
      required this.completionRate,
      required this.targetRate,
      this.timeframe});

  factory _$PreventiveCareMetricImpl.fromJson(Map<String, dynamic> json) =>
      _$$PreventiveCareMetricImplFromJson(json);

  @override
  final String careType;
  @override
  final int eligiblePopulation;
  @override
  final int completedScreenings;
  @override
  final double completionRate;
  @override
  final double targetRate;
  @override
  final String? timeframe;

  @override
  String toString() {
    return 'PreventiveCareMetric(careType: $careType, eligiblePopulation: $eligiblePopulation, completedScreenings: $completedScreenings, completionRate: $completionRate, targetRate: $targetRate, timeframe: $timeframe)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PreventiveCareMetricImpl &&
            (identical(other.careType, careType) ||
                other.careType == careType) &&
            (identical(other.eligiblePopulation, eligiblePopulation) ||
                other.eligiblePopulation == eligiblePopulation) &&
            (identical(other.completedScreenings, completedScreenings) ||
                other.completedScreenings == completedScreenings) &&
            (identical(other.completionRate, completionRate) ||
                other.completionRate == completionRate) &&
            (identical(other.targetRate, targetRate) ||
                other.targetRate == targetRate) &&
            (identical(other.timeframe, timeframe) ||
                other.timeframe == timeframe));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, careType, eligiblePopulation,
      completedScreenings, completionRate, targetRate, timeframe);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PreventiveCareMetricImplCopyWith<_$PreventiveCareMetricImpl>
      get copyWith =>
          __$$PreventiveCareMetricImplCopyWithImpl<_$PreventiveCareMetricImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PreventiveCareMetricImplToJson(
      this,
    );
  }
}

abstract class _PreventiveCareMetric implements PreventiveCareMetric {
  const factory _PreventiveCareMetric(
      {required final String careType,
      required final int eligiblePopulation,
      required final int completedScreenings,
      required final double completionRate,
      required final double targetRate,
      final String? timeframe}) = _$PreventiveCareMetricImpl;

  factory _PreventiveCareMetric.fromJson(Map<String, dynamic> json) =
      _$PreventiveCareMetricImpl.fromJson;

  @override
  String get careType;
  @override
  int get eligiblePopulation;
  @override
  int get completedScreenings;
  @override
  double get completionRate;
  @override
  double get targetRate;
  @override
  String? get timeframe;
  @override
  @JsonKey(ignore: true)
  _$$PreventiveCareMetricImplCopyWith<_$PreventiveCareMetricImpl>
      get copyWith => throw _privateConstructorUsedError;
}

SystemService _$SystemServiceFromJson(Map<String, dynamic> json) {
  return _SystemService.fromJson(json);
}

/// @nodoc
mixin _$SystemService {
  String get name => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  int get responseTime => throw _privateConstructorUsedError;
  double get uptime => throw _privateConstructorUsedError;
  DateTime get lastCheck => throw _privateConstructorUsedError;
  String? get version => throw _privateConstructorUsedError;
  String? get endpoint => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SystemServiceCopyWith<SystemService> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SystemServiceCopyWith<$Res> {
  factory $SystemServiceCopyWith(
          SystemService value, $Res Function(SystemService) then) =
      _$SystemServiceCopyWithImpl<$Res, SystemService>;
  @useResult
  $Res call(
      {String name,
      String status,
      int responseTime,
      double uptime,
      DateTime lastCheck,
      String? version,
      String? endpoint});
}

/// @nodoc
class _$SystemServiceCopyWithImpl<$Res, $Val extends SystemService>
    implements $SystemServiceCopyWith<$Res> {
  _$SystemServiceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? status = null,
    Object? responseTime = null,
    Object? uptime = null,
    Object? lastCheck = null,
    Object? version = freezed,
    Object? endpoint = freezed,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      responseTime: null == responseTime
          ? _value.responseTime
          : responseTime // ignore: cast_nullable_to_non_nullable
              as int,
      uptime: null == uptime
          ? _value.uptime
          : uptime // ignore: cast_nullable_to_non_nullable
              as double,
      lastCheck: null == lastCheck
          ? _value.lastCheck
          : lastCheck // ignore: cast_nullable_to_non_nullable
              as DateTime,
      version: freezed == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as String?,
      endpoint: freezed == endpoint
          ? _value.endpoint
          : endpoint // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SystemServiceImplCopyWith<$Res>
    implements $SystemServiceCopyWith<$Res> {
  factory _$$SystemServiceImplCopyWith(
          _$SystemServiceImpl value, $Res Function(_$SystemServiceImpl) then) =
      __$$SystemServiceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name,
      String status,
      int responseTime,
      double uptime,
      DateTime lastCheck,
      String? version,
      String? endpoint});
}

/// @nodoc
class __$$SystemServiceImplCopyWithImpl<$Res>
    extends _$SystemServiceCopyWithImpl<$Res, _$SystemServiceImpl>
    implements _$$SystemServiceImplCopyWith<$Res> {
  __$$SystemServiceImplCopyWithImpl(
      _$SystemServiceImpl _value, $Res Function(_$SystemServiceImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? status = null,
    Object? responseTime = null,
    Object? uptime = null,
    Object? lastCheck = null,
    Object? version = freezed,
    Object? endpoint = freezed,
  }) {
    return _then(_$SystemServiceImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      responseTime: null == responseTime
          ? _value.responseTime
          : responseTime // ignore: cast_nullable_to_non_nullable
              as int,
      uptime: null == uptime
          ? _value.uptime
          : uptime // ignore: cast_nullable_to_non_nullable
              as double,
      lastCheck: null == lastCheck
          ? _value.lastCheck
          : lastCheck // ignore: cast_nullable_to_non_nullable
              as DateTime,
      version: freezed == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as String?,
      endpoint: freezed == endpoint
          ? _value.endpoint
          : endpoint // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SystemServiceImpl implements _SystemService {
  const _$SystemServiceImpl(
      {required this.name,
      required this.status,
      required this.responseTime,
      required this.uptime,
      required this.lastCheck,
      this.version,
      this.endpoint});

  factory _$SystemServiceImpl.fromJson(Map<String, dynamic> json) =>
      _$$SystemServiceImplFromJson(json);

  @override
  final String name;
  @override
  final String status;
  @override
  final int responseTime;
  @override
  final double uptime;
  @override
  final DateTime lastCheck;
  @override
  final String? version;
  @override
  final String? endpoint;

  @override
  String toString() {
    return 'SystemService(name: $name, status: $status, responseTime: $responseTime, uptime: $uptime, lastCheck: $lastCheck, version: $version, endpoint: $endpoint)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SystemServiceImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.responseTime, responseTime) ||
                other.responseTime == responseTime) &&
            (identical(other.uptime, uptime) || other.uptime == uptime) &&
            (identical(other.lastCheck, lastCheck) ||
                other.lastCheck == lastCheck) &&
            (identical(other.version, version) || other.version == version) &&
            (identical(other.endpoint, endpoint) ||
                other.endpoint == endpoint));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, name, status, responseTime,
      uptime, lastCheck, version, endpoint);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SystemServiceImplCopyWith<_$SystemServiceImpl> get copyWith =>
      __$$SystemServiceImplCopyWithImpl<_$SystemServiceImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SystemServiceImplToJson(
      this,
    );
  }
}

abstract class _SystemService implements SystemService {
  const factory _SystemService(
      {required final String name,
      required final String status,
      required final int responseTime,
      required final double uptime,
      required final DateTime lastCheck,
      final String? version,
      final String? endpoint}) = _$SystemServiceImpl;

  factory _SystemService.fromJson(Map<String, dynamic> json) =
      _$SystemServiceImpl.fromJson;

  @override
  String get name;
  @override
  String get status;
  @override
  int get responseTime;
  @override
  double get uptime;
  @override
  DateTime get lastCheck;
  @override
  String? get version;
  @override
  String? get endpoint;
  @override
  @JsonKey(ignore: true)
  _$$SystemServiceImplCopyWith<_$SystemServiceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
