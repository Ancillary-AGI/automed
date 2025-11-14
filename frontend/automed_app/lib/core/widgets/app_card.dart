import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/text_theme_compat.dart';

/// Advanced App Card with comprehensive features for healthcare applications
/// Supports accessibility, responsive design, and healthcare-specific styling
class AppCard extends StatelessWidget {
  final Widget? child;
  final String? title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final List<Widget>? actions;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderRadius;
  final double? elevation;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool showShadow;
  final bool showBorder;
  final bool isInteractive;
  final bool isLoading;
  final String? semanticLabel;
  final String? tooltip;

  const AppCard({
    super.key,
    this.child,
    this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.actions,
    this.onTap,
    this.onLongPress,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.elevation,
    this.padding,
    this.margin,
    this.showShadow = true,
    this.showBorder = false,
    this.isInteractive = false,
    this.isLoading = false,
    this.semanticLabel,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardColor = backgroundColor ??
        (isDark ? AppColors.darkCardBackground : AppColors.cardBackground);

    final borderRadiusValue = borderRadius ?? 12.0;
    final elevationValue = elevation ?? (showShadow ? 2.0 : 0.0);

    final cardPadding = padding ?? const EdgeInsets.all(16.0);
    final cardMargin =
        margin ?? const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0);

    Widget cardContent = Container(
      padding: cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header section
          if (title != null ||
              subtitle != null ||
              leading != null ||
              trailing != null)
            _buildHeader(context),

          // Actions section
          if (actions != null && actions!.isNotEmpty) _buildActions(context),

          // Main content
          if (child != null) child!,
        ],
      ),
    );

    // Loading overlay
    if (isLoading) {
      cardContent = Stack(
        children: [
          cardContent,
          Positioned.fill(
            child: Container(
              color: cardColor.withValues(alpha: 0.8),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
        ],
      );
    }

    // Card widget
    Widget card = Card(
      color: cardColor,
      elevation: elevationValue,
      margin: cardMargin,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadiusValue),
        side: showBorder
            ? BorderSide(
                color: borderColor ?? theme.dividerColor,
                width: 1.0,
              )
            : BorderSide.none,
      ),
      clipBehavior: Clip.antiAlias,
      child: cardContent,
    );

    // Interactive wrapper
    if (isInteractive && (onTap != null || onLongPress != null)) {
      card = InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(borderRadiusValue),
        child: card,
      );
    }

    // Tooltip wrapper
    if (tooltip != null) {
      card = Tooltip(
        message: tooltip,
        child: card,
      );
    }

    // Semantics wrapper
    if (semanticLabel != null) {
      card = Semantics(
        label: semanticLabel,
        button: isInteractive,
        enabled: true,
        child: card,
      );
    }

    return card;
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Leading widget
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 12.0),
          ],

          // Title and subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  Text(
                    title!,
                    style: AppTextStyles.headline6.copyWith(
                      color: theme.textTheme.headline6?.color,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4.0),
                  Text(
                    subtitle!,
                    style: AppTextStyles.body2.copyWith(
                      color: theme.textTheme.bodyText2?.color
                          ?.withValues(alpha: 0.7),
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // Trailing widget
          if (trailing != null) ...[
            const SizedBox(width: 12.0),
            trailing!,
          ],
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children: actions!,
      ),
    );
  }
}

/// Specialized healthcare card variants

class HealthMetricCard extends AppCard {
  final String metricName;
  final String value;
  final String unit;
  final String status;
  final Color statusColor;
  final IconData icon;
  final bool showTrend;
  final String? trend;

  const HealthMetricCard({
    super.key,
    required this.metricName,
    required this.value,
    required this.unit,
    required this.status,
    required this.statusColor,
    required this.icon,
    this.showTrend = false,
    this.trend,
    super.onTap,
    super.tooltip,
  }) : super(
          title: metricName,
          isInteractive: onTap != null,
        );

  @override
  Widget build(BuildContext context) {
    return AppCard(
      key: key,
      title: metricName,
      onTap: onTap,
      tooltip: tooltip,
      isInteractive: onTap != null,
      child: Row(
        children: [
          // Icon and value
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Icon(
                    icon,
                    color: statusColor,
                    size: 24.0,
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$value $unit',
                        style: AppTextStyles.headline5.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 2.0,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Text(
                          status,
                          style: AppTextStyles.caption.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Trend indicator
          if (showTrend && trend != null)
            Container(
              padding: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Text(
                trend!,
                style: AppTextStyles.caption.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class AppointmentCard extends AppCard {
  final String doctorName;
  final String specialty;
  final DateTime dateTime;
  final String status;
  final Color statusColor;
  final String? location;

  const AppointmentCard({
    super.key,
    required this.doctorName,
    required this.specialty,
    required this.dateTime,
    required this.status,
    required this.statusColor,
    this.location,
    super.onTap,
    super.tooltip,
  }) : super(
          title: 'Dr. $doctorName',
          subtitle: specialty,
          isInteractive: onTap != null,
        );

  @override
  Widget build(BuildContext context) {
    final timeFormat =
        MediaQuery.of(context).alwaysUse24HourFormat ? 'HH:mm' : 'h:mm a';

    return AppCard(
      key: key,
      title: 'Dr. $doctorName',
      subtitle: specialty,
      onTap: onTap,
      tooltip: tooltip,
      isInteractive: onTap != null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date and time
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16.0,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4.0),
              Text(
                '${dateTime.day}/${dateTime.month}/${dateTime.year}',
                style: AppTextStyles.body2,
              ),
              const SizedBox(width: 16.0),
              Icon(
                Icons.access_time,
                size: 16.0,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4.0),
              Text(
                timeFormat == 'HH:mm'
                    ? '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}'
                    : '${dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')} ${dateTime.hour >= 12 ? 'PM' : 'AM'}',
                style: AppTextStyles.body2,
              ),
            ],
          ),

          // Location
          if (location != null) ...[
            const SizedBox(height: 8.0),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 16.0,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4.0),
                Expanded(
                  child: Text(
                    location!,
                    style: AppTextStyles.body2,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],

          // Status
          const SizedBox(height: 8.0),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Text(
                status,
                style: AppTextStyles.caption.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MedicationInfoCard extends AppCard {
  final String medicationName;
  final String dosage;
  final String frequency;
  final bool isTaken;
  final DateTime? nextDose;
  final Color statusColor;

  const MedicationInfoCard({
    super.key,
    required this.medicationName,
    required this.dosage,
    required this.frequency,
    required this.isTaken,
    this.nextDose,
    required this.statusColor,
    super.onTap,
    super.tooltip,
  }) : super(
          title: medicationName,
          subtitle: '$dosage - $frequency',
          isInteractive: onTap != null,
        );

  @override
  Widget build(BuildContext context) {
    return AppCard(
      key: key,
      title: medicationName,
      subtitle: '$dosage - $frequency',
      onTap: onTap,
      tooltip: tooltip,
      isInteractive: onTap != null,
      child: Row(
        children: [
          // Status indicator
          Container(
            width: 12.0,
            height: 12.0,
            decoration: BoxDecoration(
              color: isTaken ? AppColors.success : statusColor,
              shape: BoxShape.circle,
            ),
          ),

          const SizedBox(width: 12.0),

          // Medication info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isTaken ? 'Taken' : 'Pending',
                  style: AppTextStyles.body2.copyWith(
                    color: isTaken ? AppColors.success : statusColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (nextDose != null) ...[
                  const SizedBox(height: 4.0),
                  Text(
                    'Next dose: ${nextDose!.hour}:${nextDose!.minute.toString().padLeft(2, '0')}',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Action button
          if (onTap != null)
            Icon(
              isTaken ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isTaken ? AppColors.success : statusColor,
            ),
        ],
      ),
    );
  }
}

class EmergencyAlertCard extends AppCard {
  final String alertType;
  final String message;
  final String severity;
  final Color severityColor;
  final DateTime timestamp;
  final List<String>? actionLabels;

  EmergencyAlertCard({
    super.key,
    required this.alertType,
    required this.message,
    required this.severity,
    required this.severityColor,
    required this.timestamp,
    this.actionLabels,
    super.onTap,
  }) : super(
          backgroundColor: severityColor.withValues(alpha: 0.05),
          borderColor: severityColor,
          showBorder: true,
        );

  @override
  Widget build(BuildContext context) {
    return AppCard(
      key: key,
      backgroundColor: severityColor.withValues(alpha: 0.05),
      borderColor: severityColor,
      showBorder: true,
      onTap: onTap,
      isInteractive: onTap != null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Alert header
          Row(
            children: [
              Icon(
                Icons.warning,
                color: severityColor,
                size: 24.0,
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  alertType,
                  style: AppTextStyles.headline6.copyWith(
                    color: severityColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                decoration: BoxDecoration(
                  color: severityColor,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Text(
                  severity.toUpperCase(),
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8.0),

          // Alert message
          Text(
            message,
            style: AppTextStyles.body1,
          ),

          const SizedBox(height: 8.0),

          // Timestamp
          Text(
            'Received: ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')} ${timestamp.day}/${timestamp.month}/${timestamp.year}',
            style: AppTextStyles.caption.copyWith(
              color: Colors.grey[600],
            ),
          ),

          // Actions (labels mapped to buttons)
          if (actionLabels != null && actionLabels!.isNotEmpty) ...[
            const SizedBox(height: 12.0),
            Wrap(
              spacing: 8.0,
              children: actionLabels!
                  .map((label) => OutlinedButton(
                        onPressed: () {
                          // Handle action
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: severityColor),
                        ),
                        child: Text(
                          label,
                          style: TextStyle(color: severityColor),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}
