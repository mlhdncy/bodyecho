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
                      'Günlük İlerleme',
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
                                'Puan',
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

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: iconColor.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  iconData,
                  color: iconColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      insight.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: iconColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      insight.message,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade800,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Kaynak bilgisi (varsa)
          if (insight.source != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: iconColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified_rounded,
                        size: 12,
                        color: iconColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        insight.source!,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: iconColor,
                        ),
                      ),
                    ],
                  ),
                ),
                // Referans URL varsa info ikonu ekle
                if (insight.referenceUrl != null) ...[
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => _openReferenceUrl(insight.referenceUrl!),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.info_outline,
                        size: 16,
                        color: iconColor.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
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
              'Henüz tavsiye yok',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Verileriniz analiz ediliyor',
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
