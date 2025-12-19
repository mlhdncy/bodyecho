import 'package:flutter/material.dart';
import 'package:bodyecho/config/app_colors.dart';
import 'package:bodyecho/models/daily_metric_model.dart';
import 'package:bodyecho/services/insights_service.dart';
import 'package:bodyecho/widgets/circular_progress_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class DailyProgressWithInsights extends StatefulWidget {
  final DailyMetricModel? metrics;
  final List<Insight> insights;

  const DailyProgressWithInsights({
    super.key,
    required this.metrics,
    required this.insights,
  });

  @override
  State<DailyProgressWithInsights> createState() =>
      _DailyProgressWithInsightsState();
}

class _DailyProgressWithInsightsState extends State<DailyProgressWithInsights> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.metrics?.overallProgress ?? 0.0;
    final score = (progress * 100).round();

    return Container(
      height: 210,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryTeal,
            AppColors.primaryTealLight,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryTeal.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Main content area
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with title and mini score badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Daily Progress',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    // Mini score badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 30,
                            height: 30,
                            child: CircularProgressWidget(
                              progress: progress,
                              size: 30,
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$score',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  height: 1,
                                ),
                              ),
                              const Text(
                                'Score',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.white70,
                                  height: 1,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Insights slider
                Expanded(
                  child: widget.insights.isEmpty
                      ? _buildEmptyState()
                      : Column(
                          children: [
                            Expanded(
                              child: PageView.builder(
                                controller: _pageController,
                                onPageChanged: (index) {
                                  setState(() {
                                    _currentPage = index;
                                  });
                                },
                                itemCount: widget.insights.length,
                                itemBuilder: (context, index) {
                                  return _buildInsightCard(
                                      widget.insights[index]);
                                },
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Dots indicator
                            if (widget.insights.length > 1)
                              _buildDotsIndicator(),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(Insight insight) {
    Color backgroundColor;
    Color iconColor;
    IconData iconData;

    switch (insight.type) {
      case 'risk':
        backgroundColor = Colors.red.shade50;
        iconColor = Colors.red.shade700;
        iconData = Icons.warning_rounded;
        break;
      case 'warning':
        backgroundColor = Colors.orange.shade50;
        iconColor = Colors.orange.shade700;
        iconData = Icons.info_rounded;
        break;
      case 'success':
        backgroundColor = Colors.green.shade50;
        iconColor = Colors.green.shade700;
        iconData = Icons.check_circle_rounded;
        break;
      case 'info':
      default:
        backgroundColor = Colors.blue.shade50;
        iconColor = Colors.blue.shade700;
        iconData = Icons.lightbulb_rounded;
    }

    return GestureDetector(
      onTap: () => _showInsightBottomSheet(insight, backgroundColor, iconColor, iconData),
      child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: iconColor.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              iconData,
              color: iconColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        insight.title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: iconColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (insight.source != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: iconColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          insight.source!,
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: iconColor,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Flexible(
                  child: Text(
                    insight.message,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade800,
                      height: 1.2,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  void _showInsightBottomSheet(Insight insight, Color backgroundColor, Color iconColor, IconData iconData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(iconData, color: iconColor, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          insight.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: iconColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getInsightTypeLabel(insight.type),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      insight.message,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[800],
                        height: 1.5,
                      ),
                    ),
                    if (insight.source != null) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.verified_rounded, color: iconColor, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Source',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    insight.source!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: iconColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (insight.referenceUrl != null)
                              IconButton(
                                onPressed: () => _openReferenceUrl(insight.referenceUrl!),
                                icon: Icon(Icons.open_in_new, color: iconColor),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            // Close button
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: iconColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getInsightTypeLabel(String type) {
    switch (type) {
      case 'risk':
        return 'Health Risk';
      case 'warning':
        return 'Warning';
      case 'success':
        return 'Achievement';
      case 'info':
      default:
        return 'Information';
    }
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.insights_rounded,
              color: Colors.white.withValues(alpha: 0.7),
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'No insights yet',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Analyzing your data',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDotsIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.insights.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: _currentPage == index ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? Colors.white
                : Colors.white.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  /// Kaynak URL'yi tarayıcıda aç
  Future<void> _openReferenceUrl(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        debugPrint('URL açılamadı: $url');
      }
    } catch (e) {
      debugPrint('URL açılırken hata: $e');
    }
  }
}
