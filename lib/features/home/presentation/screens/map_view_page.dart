// import 'package:flutter/material.dart';

// import '../../../../app/theme/app_colors.dart';
// import '../../../../core/constants/app_sizes.dart';
// import '../../../../core/constants/app_typography.dart';
// import '../models/home_dashboard_models.dart';

// const Color _mapDeepGreen = Color(0xFF002A1C);
// const Color _mapText = Color(0xFF1B1C19);
// const Color _mapDanger = Color(0xFFBA1A1A);

// class MapViewPage extends StatefulWidget {
//   const MapViewPage({super.key, this.focusData});

//   final MapFocusData? focusData;

//   @override
//   State<MapViewPage> createState() => _MapViewPageState();
// }

// class _MapViewPageState extends State<MapViewPage> {
//   late double _zoom;

//   MapFocusData get _focusData {
//     return widget.focusData ?? const MapFocusData(
//       title: 'موقع التنبيه',
//       subtitle: 'يمكن الآن تتبع موقع التنبيه على الخريطة والتكبير والتصغير بحرية.',
//       pinLabel: 'التنبيه',
//       badgeText: 'تنبيه مباشر',
//       locationLabel: 'وسط المدينة',
//     );
//   }

//   @override
//   void initState() {
//     super.initState();
//     _zoom = _focusData.initialScale;
//   }

//   void _changeZoom(double amount) {
//     setState(() {
//       _zoom = (_zoom + amount).clamp(0.9, 1.2).toDouble();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Directionality(
//       textDirection: TextDirection.rtl,
//       child: Scaffold(
//         backgroundColor: AppColors.background,
//         body: SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.all(AppSizes.screenPadding),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: <Widget>[
//                 Row(
//                   children: <Widget>[
//                     IconButton(
//                       onPressed: () => Navigator.of(context).maybePop(),
//                       icon: const Icon(Icons.arrow_back_rounded),
//                       color: AppColors.primary,
//                     ),
//                     const SizedBox(width: 4),
//                     Expanded(
//                       child: Text(
//                         _focusData.title,
//                         style: AppTypography.sectionTitleBold18(),
//                       ),
//                     ),
//                   ],
//                 ),
//                 Text(
//                   _focusData.subtitle,
//                   style: AppTypography.bodyMedium14().copyWith(color: AppColors.muted),
//                 ),
//                 const SizedBox(height: AppSizes.sectionSpacing),
//                 Expanded(
//                   child: Center(
//                     child: ConstrainedBox(
//                       constraints: const BoxConstraints(maxWidth: 560),
//                       child: AspectRatio(
//                         aspectRatio: 1,
//                         child: _MunicipalityMapCard(
//                           badgeText: _focusData.badgeText,
//                           zoom: _zoom,
//                           onZoomChanged: _changeZoom,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _MunicipalityMapCard extends StatelessWidget {
//   const _MunicipalityMapCard({
//     required this.badgeText,
//     required this.zoom,
//     required this.onZoomChanged,
//   });

//   final String badgeText;
//   final double zoom;
//   final ValueChanged<double> onZoomChanged;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       key: const ValueKey('map_view_card'),
//       clipBehavior: Clip.antiAlias,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(24),
//         border: Border.all(
//           color: const Color(0x4DC1C8C2),
//         ),
//         boxShadow: const [
//           BoxShadow(
//             color: Color(0x1F002A1C),
//             blurRadius: 30,
//             offset: Offset(0, 8),
//           ),
//         ],
//       ),
//       child: Stack(
//         children: [
//           Positioned.fill(
//             child: AnimatedScale(
//               duration: const Duration(milliseconds: 180),
//               curve: Curves.easeOut,
//               scale: zoom,
//               child: const _MapScene(),
//             ),
//           ),
//           Positioned(
//             top: 17,
//             right: 17,
//             child: _RegionAlertPill(text: badgeText),
//           ),
//           Positioned(
//             right: 17,
//             bottom: 17,
//             child: Column(
//               children: [
//                 _MapControlButton(
//                   tooltip: 'تكبير الخريطة',
//                   icon: Icons.add_rounded,
//                   onTap: () => onZoomChanged(0.1),
//                 ),
//                 const SizedBox(height: 8),
//                 _MapControlButton(
//                   tooltip: 'تصغير الخريطة',
//                   icon: Icons.remove_rounded,
//                   onTap: () => onZoomChanged(-0.1),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _MapScene extends StatelessWidget {
//   const _MapScene();

//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final width = constraints.maxWidth;
//         final height = constraints.maxHeight;

//         return Stack(
//           children: [
//             const Positioned.fill(
//               child: CustomPaint(
//                 painter: _StreetMapPainter(
//                   background: Color(0xFF7F8E89),
//                   street: Color(0x66768782),
//                   minorStreet: Color(0x33768782),
//                 ),
//               ),
//             ),
//             Align(
//               alignment: const Alignment(0, 0.08),
//               child: FractionallySizedBox(
//                 widthFactor: 0.54,
//                 heightFactor: 0.84,
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFF7F6F2),
//                     borderRadius: BorderRadius.circular(24),
//                     border: Border.all(
//                       color: const Color(0xFF817D76),
//                       width: 2,
//                     ),
//                     boxShadow: const [
//                       BoxShadow(
//                         color: Color(0x33000000),
//                         blurRadius: 8,
//                         offset: Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   child: Stack(
//                     children: [
//                       Positioned(
//                         top: 30,
//                         left: 12,
//                         right: 12,
//                         bottom: 28,
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(2),
//                           child: const CustomPaint(
//                             painter: _StreetMapPainter(
//                               background: Color(0xFFCBD7D1),
//                               street: Color(0x99F4F5F1),
//                               minorStreet: Color(0x66F4F5F1),
//                             ),
//                           ),
//                         ),
//                       ),
//                       Positioned(
//                         top: 11,
//                         left: 0,
//                         right: 0,
//                         child: Center(
//                           child: Container(
//                             width: 24,
//                             height: 3,
//                             decoration: BoxDecoration(
//                               color: const Color(0xFF6A6965),
//                               borderRadius: BorderRadius.circular(99),
//                             ),
//                           ),
//                         ),
//                       ),
//                       Positioned(
//                         bottom: 9,
//                         left: 0,
//                         right: 0,
//                         child: Center(
//                           child: Container(
//                             width: 36,
//                             height: 2,
//                             decoration: BoxDecoration(
//                               color: const Color(0xFF6A6965),
//                               borderRadius: BorderRadius.circular(99),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             Positioned(
//               left: width * 0.48 - 20,
//               top: height * 0.30 - 20,
//               child: const _MapPin(
//                 color: _mapDanger,
//                 icon: Icons.construction_rounded,
//               ),
//             ),
//             Positioned(
//               left: width * 0.68 - 20,
//               top: height * 0.60 - 20,
//               child: const _MapPin(
//                 color: _mapDeepGreen,
//                 icon: Icons.park_outlined,
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }

// class _MapPin extends StatelessWidget {
//   const _MapPin({
//     required this.color,
//     required this.icon,
//   });

//   final Color color;
//   final IconData icon;

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: 40,
//       height: 46,
//       child: Stack(
//         clipBehavior: Clip.none,
//         alignment: Alignment.topCenter,
//         children: [
//           Positioned(
//             top: 31,
//             child: Transform.rotate(
//               angle: 0.785398,
//               child: Container(
//                 width: 12,
//                 height: 12,
//                 decoration: BoxDecoration(
//                   color: color,
//                   border: Border.all(color: Colors.white, width: 2),
//                 ),
//               ),
//             ),
//           ),
//           Container(
//             width: 40,
//             height: 40,
//             decoration: BoxDecoration(
//               color: color,
//               shape: BoxShape.circle,
//               border: Border.all(color: Colors.white, width: 2),
//               boxShadow: const [
//                 BoxShadow(
//                   color: Color(0x24000000),
//                   blurRadius: 10,
//                   offset: Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: Icon(icon, color: Colors.white, size: 17),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _RegionAlertPill extends StatelessWidget {
//   const _RegionAlertPill({required this.text});

//   final String text;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 34,
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.82),
//         borderRadius: BorderRadius.circular(999),
//         border: Border.all(color: Colors.white.withOpacity(0.5)),
//         boxShadow: const [
//           BoxShadow(
//             color: Color(0x1A000000),
//             blurRadius: 15,
//             offset: Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           const SizedBox(
//             width: 12,
//             height: 12,
//             child: DecoratedBox(
//               decoration: BoxDecoration(
//                 color: _mapDanger,
//                 shape: BoxShape.circle,
//               ),
//             ),
//           ),
//           const SizedBox(width: 8),
//           Text(
//             text,
//             style: const TextStyle(
//               color: _mapText,
//               fontSize: 12,
//               height: 1.33,
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _MapControlButton extends StatelessWidget {
//   const _MapControlButton({
//     required this.tooltip,
//     required this.icon,
//     required this.onTap,
//   });

//   final String tooltip;
//   final IconData icon;
//   final VoidCallback onTap;

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Colors.white.withOpacity(0.82),
//       shape: const CircleBorder(
//         side: BorderSide(color: Color(0x80FFFFFF)),
//       ),
//       elevation: 2,
//       shadowColor: Colors.black.withOpacity(0.16),
//       child: InkWell(
//         customBorder: const CircleBorder(),
//         onTap: onTap,
//         child: Tooltip(
//           message: tooltip,
//           child: SizedBox(
//             width: 44,
//             height: 44,
//             child: Icon(icon, color: _mapDeepGreen, size: 24),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _StreetMapPainter extends CustomPainter {
//   const _StreetMapPainter({
//     required this.background,
//     required this.street,
//     required this.minorStreet,
//   });

//   final Color background;
//   final Color street;
//   final Color minorStreet;

//   @override
//   void paint(Canvas canvas, Size size) {
//     canvas.drawRect(
//       Offset.zero & size,
//       Paint()..color = background,
//     );

//     final minorPaint = Paint()
//       ..color = minorStreet
//       ..strokeWidth = 1
//       ..style = PaintingStyle.stroke;

//     for (double x = -size.height; x < size.width; x += 24) {
//       canvas.drawLine(
//         Offset(x, 0),
//         Offset(x + size.height, size.height),
//         minorPaint,
//       );
//     }

//     for (double y = 18; y < size.height; y += 27) {
//       canvas.drawLine(
//         Offset(0, y),
//         Offset(size.width, y + (y % 3) * 5),
//         minorPaint,
//       );
//     }

//     final streetPaint = Paint()
//       ..color = street
//       ..strokeWidth = 2.2
//       ..style = PaintingStyle.stroke
//       ..strokeCap = StrokeCap.round;

//     final firstStreet = Path()
//       ..moveTo(-10, size.height * 0.22)
//       ..cubicTo(
//         size.width * 0.22,
//         size.height * 0.05,
//         size.width * 0.42,
//         size.height * 0.38,
//         size.width * 1.05,
//         size.height * 0.18,
//       );

//     final secondStreet = Path()
//       ..moveTo(size.width * 0.08, size.height * 1.05)
//       ..cubicTo(
//         size.width * 0.35,
//         size.height * 0.72,
//         size.width * 0.58,
//         size.height * 0.78,
//         size.width * 0.9,
//         -8,
//       );

//     final thirdStreet = Path()
//       ..moveTo(-8, size.height * 0.64)
//       ..cubicTo(
//         size.width * 0.28,
//         size.height * 0.48,
//         size.width * 0.7,
//         size.height * 0.72,
//         size.width * 1.08,
//         size.height * 0.52,
//       );

//     canvas.drawPath(firstStreet, streetPaint);
//     canvas.drawPath(secondStreet, streetPaint);
//     canvas.drawPath(thirdStreet, streetPaint);

//     canvas.drawCircle(
//       Offset(size.width * 0.22, size.height * 0.34),
//       size.shortestSide * 0.065,
//       streetPaint,
//     );
//   }

//   @override
//   bool shouldRepaint(covariant _StreetMapPainter oldDelegate) {
//     return background != oldDelegate.background ||
//         street != oldDelegate.street ||
//         minorStreet != oldDelegate.minorStreet;
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_typography.dart';
import '../models/home_dashboard_models.dart';

const Color _mapDeepGreen = Color(0xFF002A1C);
const Color _mapText = Color(0xFF1B1C19);
const Color _mapDanger = Color(0xFFBA1A1A);

class MapViewPage extends StatefulWidget {
  const MapViewPage({super.key, this.focusData});

  final MapFocusData? focusData;

  @override
  State<MapViewPage> createState() => _MapViewPageState();
}

class _MapViewPageState extends State<MapViewPage> {
  // إنشاء MapController للتحكم بالزوم والتحريك برمجيًا
  final MapController _mapController = MapController();
  double _currentZoom = 13.0; // قيمة الزوم الافتراضية للخريطة الحقيقية

  MapFocusData get _focusData {
    return widget.focusData ??
        const MapFocusData(
          title: 'موقع التنبيه',
          subtitle: 'يمكن الآن تتبع موقع التنبيه على الخريطة والتكبير والتصغير بحرية.',
          pinLabel: 'التنبيه',
          badgeText: 'تنبيه مباشر',
          locationLabel: 'وسط المدينة',
        );
  }

  // تغيير الزوم عند الضغط على أزرار التحكم
  void _changeZoom(double amount) {
    setState(() {
      _currentZoom = (_currentZoom + amount).clamp(3.0, 18.0);
      _mapController.move(_mapController.camera.center, _currentZoom);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _focusData.title,
                        style: AppTypography.sectionTitleBold18(),
                      ),
                    ),
                  ],
                ),
                Text(
                  _focusData.subtitle,
                  style: AppTypography.bodyMedium14().copyWith(color: AppColors.muted),
                ),
                const SizedBox(height: AppSizes.sectionSpacing),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 560),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: _MunicipalityMapCard(
                          badgeText: _focusData.badgeText,
                          mapController: _mapController,
                          initialZoom: _currentZoom,
                          onZoomChanged: _changeZoom,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MunicipalityMapCard extends StatelessWidget {
  const _MunicipalityMapCard({
    required this.badgeText,
    required this.mapController,
    required this.initialZoom,
    required this.onZoomChanged,
  });

  final String badgeText;
  final MapController mapController;
  final double initialZoom;
  final ValueChanged<double> onZoomChanged;

  @override
  Widget build(BuildContext context) {
    // إحداثيات أمثلة لموقع التنبيه والحديقة (يمكنك استبدالها ببيانات حقيقية من focusData)
    final LatLng alertLocation = const LatLng(33.5138, 36.2765); // مثال: إحداثيات دمشق/الرياض...
    final LatLng parkLocation = const LatLng(33.5180, 36.2820);

    return Container(
      key: const ValueKey('map_view_card'),
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
          // 1. الخريطة التفاعلية الحقيقية
          Positioned.fill(
            child: FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: alertLocation, // نقطة المنتصف
                initialZoom: initialZoom,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all, // للسماح بالسحب والتكبير باليد
                ),
              ),
              children: [
                // جلب بلاطات الخريطة المجانية من OpenStreetMap
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app', // اسم الباكيج لتطبيقك
                ),
                // إضافة الدبابيس (Markers)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: alertLocation,
                      width: 40,
                      height: 46,
                      child: const _MapPin(
                        color: _mapDanger,
                        icon: Icons.construction_rounded,
                      ),
                    ),
                    Marker(
                      point: parkLocation,
                      width: 40,
                      height: 46,
                      child: const _MapPin(
                        color: _mapDeepGreen,
                        icon: Icons.park_outlined,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 2. شارة التنبيه المباشر في الأعلى
          Positioned(
            top: 17,
            right: 17,
            child: _RegionAlertPill(text: badgeText),
          ),

          // 3. أزرار التحكم في الزوم أسفل اليمين
          Positioned(
            right: 17,
            bottom: 17,
            child: Column(
              children: [
                _MapControlButton(
                  tooltip: 'تكبير الخريطة',
                  icon: Icons.add_rounded,
                  onTap: () => onZoomChanged(1.0), // زيادة الزوم بمقدار 1
                ),
                const SizedBox(height: 8),
                _MapControlButton(
                  tooltip: 'تصغير الخريطة',
                  icon: Icons.remove_rounded,
                  onTap: () => onZoomChanged(-1.0), // إنقاص الزوم بمقدار 1
                ),
              ],
            ),
          ),
        ],
      ),
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
  const _RegionAlertPill({required this.text});

  final String text;

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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 12,
            height: 12,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: _mapDanger,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: _mapText,
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
            child: Icon(icon, color: _mapDeepGreen, size: 24),
          ),
        ),
      ),
    );
  }
}
