import 'package:flutter/material.dart';


const Color _homeDeepGreen = Color(0xFF002A1C);
const Color _homeText = Color(0xFF1B1C19);

const Color _homeDanger = Color(0xFFBA1A1A);

class MunicipalityMapCard extends StatefulWidget {
  const MunicipalityMapCard({super.key});

  @override
  State<MunicipalityMapCard> createState() => _MunicipalityMapCardState();
}

class _MunicipalityMapCardState extends State<MunicipalityMapCard> {
  double _zoom = 1;

  void _changeZoom(double amount) {
    setState(() {
      _zoom = (_zoom + amount).clamp(0.9, 1.2).toDouble();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        key: const ValueKey('home_map_card'),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0x4DC1C8C2),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1F002A1C),
              blurRadius: 30,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: AnimatedScale(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                scale: _zoom,
                child: const _MapScene(),
              ),
            ),
            Positioned(
              top: 17,
              right: 17,
              child: _RegionAlertPill(),
            ),
            Positioned(
              right: 17,
              bottom: 17,
              child: Column(
                children: [
                  _MapControlButton(
                    tooltip: 'تكبير الخريطة',
                    icon: Icons.add_rounded,
                    onTap: () => _changeZoom(0.1),
                  ),
                  const SizedBox(height: 8),
                  _MapControlButton(
                    tooltip: 'تصغير الخريطة',
                    icon: Icons.remove_rounded,
                    onTap: () => _changeZoom(-0.1),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapScene extends StatelessWidget {
  const _MapScene();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        return Stack(
          children: [
            const Positioned.fill(
              child: CustomPaint(
                painter: _StreetMapPainter(
                  background: Color(0xFF7F8E89),
                  street: Color(0x66768782),
                  minorStreet: Color(0x33768782),
                ),
              ),
            ),
            Align(
              alignment: const Alignment(0, 0.08),
              child: FractionallySizedBox(
                widthFactor: 0.54,
                heightFactor: 0.84,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F6F2),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFF817D76),
                      width: 2,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 30,
                        left: 12,
                        right: 12,
                        bottom: 28,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: const CustomPaint(
                            painter: _StreetMapPainter(
                              background: Color(0xFFCBD7D1),
                              street: Color(0x99F4F5F1),
                              minorStreet: Color(0x66F4F5F1),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 11,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            width: 24,
                            height: 3,
                            decoration: BoxDecoration(
                              color: const Color(0xFF6A6965),
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 9,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            width: 36,
                            height: 2,
                            decoration: BoxDecoration(
                              color: const Color(0xFF6A6965),
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: width * 0.48 - 20,
              top: height * 0.30 - 20,
              child: const _MapPin(
                color: _homeDanger,
                icon: Icons.construction_rounded,
              ),
            ),
            Positioned(
              left: width * 0.68 - 20,
              top: height * 0.60 - 20,
              child: const _MapPin(
                color: _homeDeepGreen,
                icon: Icons.park_outlined,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MapPin extends StatelessWidget {
  const _MapPin({
    required this.color,
    required this.icon,
  });

  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 46,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: 31,
            child: Transform.rotate(
              angle: 0.785398,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x24000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 17),
          ),
        ],
      ),
    );
  }
}

class _RegionAlertPill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.82),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 15,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: _homeDanger,
                shape: BoxShape.circle,
              ),
            ),
          ),
          SizedBox(width: 8),
          Text(
            'تنبيهات المنطقة',
            style: TextStyle(
              color: _homeText,
              fontSize: 12,
              height: 1.33,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MapControlButton extends StatelessWidget {
  const _MapControlButton({
    required this.tooltip,
    required this.icon,
    required this.onTap,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.82),
      shape: const CircleBorder(
        side: BorderSide(color: Color(0x80FFFFFF)),
      ),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.16),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Tooltip(
          message: tooltip,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(icon, color: _homeDeepGreen, size: 24),
          ),
        ),
      ),
    );
  }
}

class _StreetMapPainter extends CustomPainter {
  const _StreetMapPainter({
    required this.background,
    required this.street,
    required this.minorStreet,
  });

  final Color background;
  final Color street;
  final Color minorStreet;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = background,
    );

    final minorPaint = Paint()
      ..color = minorStreet
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (double x = -size.height; x < size.width; x += 24) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height, size.height),
        minorPaint,
      );
    }

    for (double y = 18; y < size.height; y += 27) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y + (y % 3) * 5),
        minorPaint,
      );
    }

    final streetPaint = Paint()
      ..color = street
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final firstStreet = Path()
      ..moveTo(-10, size.height * 0.22)
      ..cubicTo(
        size.width * 0.22,
        size.height * 0.05,
        size.width * 0.42,
        size.height * 0.38,
        size.width * 1.05,
        size.height * 0.18,
      );

    final secondStreet = Path()
      ..moveTo(size.width * 0.08, size.height * 1.05)
      ..cubicTo(
        size.width * 0.35,
        size.height * 0.72,
        size.width * 0.58,
        size.height * 0.78,
        size.width * 0.9,
        -8,
      );

    final thirdStreet = Path()
      ..moveTo(-8, size.height * 0.64)
      ..cubicTo(
        size.width * 0.28,
        size.height * 0.48,
        size.width * 0.7,
        size.height * 0.72,
        size.width * 1.08,
        size.height * 0.52,
      );

    canvas.drawPath(firstStreet, streetPaint);
    canvas.drawPath(secondStreet, streetPaint);
    canvas.drawPath(thirdStreet, streetPaint);

    canvas.drawCircle(
      Offset(size.width * 0.22, size.height * 0.34),
      size.shortestSide * 0.065,
      streetPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _StreetMapPainter oldDelegate) {
    return background != oldDelegate.background ||
        street != oldDelegate.street ||
        minorStreet != oldDelegate.minorStreet;
  }
}
