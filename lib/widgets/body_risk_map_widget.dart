import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/ml_prediction_model.dart';
import '../config/app_colors.dart';

/// Enum for body regions that can show health risks
enum BodyRegion {
  head,
  chest,
  abdomen,
  leftArm,
  rightArm,
  leftLeg,
  rightLeg,
}

/// Maps health risks to specific body regions
class RiskRegionMapper {
  static Map<BodyRegion, List<String>> getRiskRegionMapping() {
    return {
      BodyRegion.head: ['cancer_risk'],
      BodyRegion.chest: ['heart_risk', 'high_cholesterol_risk'],
      BodyRegion.abdomen: ['obesity_risk', 'diabetes_risk', 'high_sugar_risk'],
      BodyRegion.leftArm: ['low_activity_risk'],
      BodyRegion.rightArm: ['low_activity_risk'],
      BodyRegion.leftLeg: ['low_activity_risk'],
      BodyRegion.rightLeg: ['low_activity_risk'],
    };
  }

  /// Calculate the maximum risk level for a given body region
  static double getRegionRiskLevel(
    BodyRegion region,
    Map<String, MlPredictionResult> results,
  ) {
    final mapping = getRiskRegionMapping();
    final riskKeys = mapping[region] ?? [];

    double maxRisk = 0.0;
    for (final key in riskKeys) {
      final result = results[key];
      if (result != null) {
        maxRisk = maxRisk > result.probability ? maxRisk : result.probability;
      }
    }

    return maxRisk;
  }

  /// Get all risks associated with a body region
  static List<MlPredictionResult> getRegionRisks(
    BodyRegion region,
    Map<String, MlPredictionResult> results,
  ) {
    final mapping = getRiskRegionMapping();
    final riskKeys = mapping[region] ?? [];

    return riskKeys
        .where((key) => results.containsKey(key))
        .map((key) => results[key]!)
        .toList();
  }

  /// Get human-readable name for body region
  static String getRegionName(BodyRegion region) {
    switch (region) {
      case BodyRegion.head:
        return 'Baş';
      case BodyRegion.chest:
        return 'Göğüs';
      case BodyRegion.abdomen:
        return 'Karın';
      case BodyRegion.leftArm:
        return 'Sol Kol';
      case BodyRegion.rightArm:
        return 'Sağ Kol';
      case BodyRegion.leftLeg:
        return 'Sol Bacak';
      case BodyRegion.rightLeg:
        return 'Sağ Bacak';
    }
  }
}

/// Interactive 2D body map widget showing health risk visualization
class BodyRiskMapWidget extends StatefulWidget {
  final Map<String, MlPredictionResult> riskResults;
  final bool isLoading;

  const BodyRiskMapWidget({
    super.key,
    required this.riskResults,
    this.isLoading = false,
  });

  @override
  State<BodyRiskMapWidget> createState() => _BodyRiskMapWidgetState();
}

class _BodyRiskMapWidgetState extends State<BodyRiskMapWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  BodyRegion? _hoveredRegion;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getRiskColor(double riskLevel) {
    if (riskLevel < 0.3) {
      // Low risk - Green
      return AppColors.success;
    } else if (riskLevel < 0.5) {
      // Medium risk - Yellow/Warning
      return AppColors.warning;
    } else if (riskLevel < 0.7) {
      // High risk - Orange
      return AppColors.alertOrange;
    } else {
      // Very high risk - Red
      return AppColors.error;
    }
  }

  void _onRegionTapped(BodyRegion region) {
    HapticFeedback.lightImpact();

    final risks = RiskRegionMapper.getRegionRisks(region, widget.riskResults);

    if (risks.isEmpty) {
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildRegionDetailsSheet(region, risks),
    );
  }

  Widget _buildRegionDetailsSheet(
    BodyRegion region,
    List<MlPredictionResult> risks,
  ) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.health_and_safety,
                color: AppColors.primaryTeal,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                RiskRegionMapper.getRegionName(region),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...risks.map((risk) => _buildRiskDetailCard(risk)),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildRiskDetailCard(MlPredictionResult risk) {
    final riskColor = _getRiskColor(risk.probability);
    final riskName = _getRiskDisplayName(risk.modelName);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: riskColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: riskColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  riskName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: riskColor,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: riskColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '%${(risk.probability * 100).toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _getRiskDescription(risk.modelName, risk.probability),
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _getRiskDisplayName(String modelName) {
    switch (modelName) {
      case 'diabetes_risk':
        return 'Diyabet Riski';
      case 'heart_risk':
        return 'Kalp Hastalığı Riski';
      case 'obesity_risk':
        return 'Obezite Riski';
      case 'high_sugar_risk':
        return 'Yüksek Kan Şekeri';
      case 'high_cholesterol_risk':
        return 'Yüksek Kolesterol';
      case 'low_activity_risk':
        return 'Düşük Aktivite';
      case 'cancer_risk':
        return 'Kanser Riski';
      default:
        return modelName;
    }
  }

  String _getRiskDescription(String modelName, double probability) {
    if (probability < 0.3) {
      return 'Risk seviyeniz düşük. Mevcut sağlık alışkanlıklarınızı sürdürün.';
    } else if (probability < 0.5) {
      return 'Orta seviye risk tespit edildi. Yaşam tarzınızda küçük değişiklikler faydalı olabilir.';
    } else if (probability < 0.7) {
      return 'Yüksek risk seviyesi. Doktorunuzla görüşmeniz önerilir.';
    } else {
      return 'Çok yüksek risk! Lütfen en kısa sürede bir sağlık profesyoneli ile görüşün.';
    }
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildLegendItem('Düşük', AppColors.success),
          _buildLegendItem('Orta', AppColors.warning),
          _buildLegendItem('Yüksek', AppColors.alertOrange),
          _buildLegendItem('Çok Yüksek', AppColors.error),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color.withOpacity(0.8),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Analiz ediliyor...'),
          ],
        ),
      );
    }

    if (widget.riskResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 16),
            const Text(
              'Henüz analiz yapılmadı',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Sağlık risk haritanızı görmek için analiz edin',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      );
    }

    return FadeTransition(
      opacity: _animationController,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Legend
          _buildLegend(),
          const SizedBox(height: 16),
          // Body Map
          Center(
            child: SizedBox(
              height: 500,
              child: CustomPaint(
                painter: BodyMapPainter(
                  riskResults: widget.riskResults,
                  getRiskColor: _getRiskColor,
                  hoveredRegion: _hoveredRegion,
                ),
                child: GestureDetector(
                  onTapUp: (details) {
                    final region = _getRegionFromPosition(
                      details.localPosition,
                      context.size!,
                    );
                    if (region != null) {
                      _onRegionTapped(region);
                    }
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bölgelere dokunarak detayları görebilirsiniz',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textTertiary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  BodyRegion? _getRegionFromPosition(Offset position, Size size) {
    // Convert position to relative coordinates (0-1)
    final relX = position.dx / size.width;
    final relY = position.dy / size.height;

    // Simple hit detection based on body proportions
    if (relY < 0.15) {
      return BodyRegion.head;
    } else if (relY < 0.35) {
      return BodyRegion.chest;
    } else if (relY < 0.55) {
      return BodyRegion.abdomen;
    } else {
      if (relX < 0.4) {
        return BodyRegion.leftLeg;
      } else if (relX > 0.6) {
        return BodyRegion.rightLeg;
      } else {
        return BodyRegion.leftLeg; // Default to left leg for center
      }
    }
  }
}

/// Custom painter for drawing the body map with risk colors
class BodyMapPainter extends CustomPainter {
  final Map<String, MlPredictionResult> riskResults;
  final Color Function(double) getRiskColor;
  final BodyRegion? hoveredRegion;

  BodyMapPainter({
    required this.riskResults,
    required this.getRiskColor,
    this.hoveredRegion,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final scale = size.width / 200; // Base scale for 200px wide design

    // Draw each body region
    _drawHead(canvas, centerX, 40 * scale, scale);
    _drawNeck(canvas, centerX, 65 * scale, scale);
    _drawChest(canvas, centerX, 112.5 * scale, scale);
    _drawAbdomen(canvas, centerX, 190 * scale, scale);
    _drawArm(canvas, centerX - 47.5 * scale, 132.5 * scale, scale, true); // Left
    _drawArm(canvas, centerX + 47.5 * scale, 132.5 * scale, scale, false); // Right
    _drawLeg(canvas, centerX - 16.5 * scale, 312.5 * scale, scale, true); // Left
    _drawLeg(canvas, centerX + 16.5 * scale, 312.5 * scale, scale, false); // Right
  }

  void _drawHead(Canvas canvas, double centerX, double centerY, double scale) {
    final region = BodyRegion.head;
    final riskLevel = RiskRegionMapper.getRegionRiskLevel(region, riskResults);
    final color = riskLevel > 0 ? getRiskColor(riskLevel) : Colors.grey[300]!;

    final paint = Paint()
      ..color = color.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.grey[700]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX, centerY),
        width: 50 * scale,
        height: 60 * scale,
      ),
      paint,
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX, centerY),
        width: 50 * scale,
        height: 60 * scale,
      ),
      borderPaint,
    );
  }

  void _drawNeck(Canvas canvas, double centerX, double centerY, double scale) {
    final paint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(centerX, centerY),
        width: 20 * scale,
        height: 15 * scale,
      ),
      paint,
    );
  }

  void _drawChest(Canvas canvas, double centerX, double centerY, double scale) {
    final region = BodyRegion.chest;
    final riskLevel = RiskRegionMapper.getRegionRiskLevel(region, riskResults);
    final color = riskLevel > 0 ? getRiskColor(riskLevel) : Colors.grey[300]!;

    final paint = Paint()
      ..color = color.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.grey[700]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path()
      ..moveTo(centerX - 30 * scale, centerY - 32.5 * scale)
      ..lineTo(centerX + 30 * scale, centerY - 32.5 * scale)
      ..lineTo(centerX + 35 * scale, centerY + 32.5 * scale)
      ..lineTo(centerX - 35 * scale, centerY + 32.5 * scale)
      ..close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  void _drawAbdomen(Canvas canvas, double centerX, double centerY, double scale) {
    final region = BodyRegion.abdomen;
    final riskLevel = RiskRegionMapper.getRegionRiskLevel(region, riskResults);
    final color = riskLevel > 0 ? getRiskColor(riskLevel) : Colors.grey[300]!;

    final paint = Paint()
      ..color = color.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.grey[700]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path()
      ..moveTo(centerX - 35 * scale, centerY - 45 * scale)
      ..lineTo(centerX + 35 * scale, centerY - 45 * scale)
      ..lineTo(centerX + 30 * scale, centerY + 45 * scale)
      ..lineTo(centerX - 30 * scale, centerY + 45 * scale)
      ..close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  void _drawArm(Canvas canvas, double centerX, double centerY, double scale, bool isLeft) {
    final region = isLeft ? BodyRegion.leftArm : BodyRegion.rightArm;
    final riskLevel = RiskRegionMapper.getRegionRiskLevel(region, riskResults);
    final color = riskLevel > 0 ? getRiskColor(riskLevel) : Colors.grey[300]!;

    final paint = Paint()
      ..color = color.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.grey[700]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final width = 12 * scale;
    final height = 95 * scale;

    final rect = Rect.fromCenter(
      center: Offset(centerX, centerY),
      width: width,
      height: height,
    );

    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(6 * scale),
    );

    canvas.drawRRect(rrect, paint);
    canvas.drawRRect(rrect, borderPaint);
  }

  void _drawLeg(Canvas canvas, double centerX, double centerY, double scale, bool isLeft) {
    final region = isLeft ? BodyRegion.leftLeg : BodyRegion.rightLeg;
    final riskLevel = RiskRegionMapper.getRegionRiskLevel(region, riskResults);
    final color = riskLevel > 0 ? getRiskColor(riskLevel) : Colors.grey[300]!;

    final paint = Paint()
      ..color = color.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.grey[700]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final width = 17 * scale;
    final height = 155 * scale;

    final rect = Rect.fromCenter(
      center: Offset(centerX, centerY),
      width: width,
      height: height,
    );

    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(8 * scale),
    );

    canvas.drawRRect(rrect, paint);
    canvas.drawRRect(rrect, borderPaint);
  }

  @override
  bool shouldRepaint(BodyMapPainter oldDelegate) {
    return oldDelegate.riskResults != riskResults ||
        oldDelegate.hoveredRegion != hoveredRegion;
  }
}
