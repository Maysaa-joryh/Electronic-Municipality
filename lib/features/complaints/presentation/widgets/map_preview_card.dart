import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

class MapPreviewCard extends StatelessWidget {
  const MapPreviewCard({required this.badgeText, required this.scale, required this.onZoomIn, required this.onZoomOut, super.key});

  final String badgeText;
  final double scale;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 182,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x4CC1C8C2)),
      ),
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CustomPaint(
                painter: MapBackdropPainter(),
                child: Center(
                  child: Transform.scale(scale: scale, child: MiniMapFrame(badgeText: badgeText)),
                ),
              ),
            ),
          ),
          PositionedDirectional(
            bottom: 12,
            end: 10,
            child: Column(
              children: <Widget>[
                ZoomButton(icon: Icons.add_rounded, onTap: onZoomIn),
                const SizedBox(height: 6),
                ZoomButton(icon: Icons.remove_rounded, onTap: onZoomOut),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MiniMapFrame extends StatelessWidget {
  const MiniMapFrame({required this.badgeText, super.key});

  final String badgeText;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 152,
      height: 150,
      child: Stack(
        children: <Widget>[
          PositionedDirectional(top: 0, start: 0, child: SmallBadge(text: badgeText)),
          Center(
            child: Container(
              width: 28,
              height: 38,
              decoration: const BoxDecoration(color: AppColors.danger, shape: BoxShape.circle),
              child: const Icon(Icons.place_rounded, color: AppColors.surface, size: 18),
            ),
          ),
          PositionedDirectional(
            bottom: 0,
            end: 0,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(color: AppColors.surface, shape: BoxShape.circle, border: Border.all(color: AppColors.border)),
              child: const Icon(Icons.my_location_rounded, size: 14, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class SmallBadge extends StatelessWidget {
  const SmallBadge({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
      child: Text(text, style: const TextStyle(fontSize: 10)),
    );
  }
}

class ZoomButton extends StatelessWidget {
  const ZoomButton({required this.icon, required this.onTap, super.key});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(color: AppColors.surface, shape: BoxShape.circle, border: Border.all(color: AppColors.border), boxShadow: const <BoxShadow>[BoxShadow(color: Color(0x12000000), blurRadius: 6, offset: Offset(0, 2))]),
        child: Icon(icon, size: 15, color: AppColors.primary),
      ),
    );
  }
}

class MapBackdropPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint fillPaint = Paint()..color = const Color(0xFFF5F2EC);
    canvas.drawRect(Offset.zero & size, fillPaint);

    final Paint gridPaint = Paint()..color = const Color(0xFFC1C8C2)..strokeWidth = 1;

    for (double x = 14; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 16; y < size.height; y += 28) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final Paint routePaint = Paint()..color = Color(0xFF77B58A).withAlpha((0.22 * 255).round())..strokeWidth = 4..strokeCap = StrokeCap.round;

    canvas.drawLine(const Offset(22, 28), const Offset(132, 28), routePaint);
    canvas.drawLine(const Offset(40, 58), const Offset(120, 58), routePaint);
    canvas.drawLine(const Offset(18, 92), const Offset(136, 92), routePaint);
    canvas.drawLine(const Offset(54, 14), const Offset(54, 134), routePaint);
    canvas.drawLine(const Offset(102, 16), const Offset(102, 136), routePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
