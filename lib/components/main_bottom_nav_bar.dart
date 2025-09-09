// lib/components/main_bottom_nav_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui' as ui;

class RPSCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Path path_0 = Path();
    path_0.moveTo(size.width * 0.5127845, size.height * 0.01249518);
    path_0.lineTo(size.width * 0.6124662, size.height * 0.3282166);
    path_0.cubicTo(size.width * 0.6213927, size.height * 0.3564767, size.width * 0.6435233, size.height * 0.3786073, size.width * 0.6717834, size.height * 0.3875338);
    path_0.lineTo(size.width * 0.9875048, size.height * 0.4872155);
    path_0.cubicTo(size.width, size.height * 0.4911603, size.width, size.height * 0.5088397, size.width * 0.9875048, size.height * 0.5127845);
    path_0.lineTo(size.width * 0.6717834, size.height * 0.6124662);
    path_0.cubicTo(size.width * 0.6435233, size.height * 0.6213928, size.width * 0.6213927, size.height * 0.6435233, size.width * 0.6124662, size.height * 0.6717834);
    path_0.lineTo(size.width * 0.5127845, size.height * 0.9875048);
    path_0.cubicTo(size.width * 0.5088397, size.height, size.width * 0.4911603, size.height, size.width * 0.4872155, size.height * 0.9875048);
    path_0.lineTo(size.width * 0.3875338, size.height * 0.6717834);
    path_0.cubicTo(size.width * 0.3786073, size.height * 0.6435233, size.width * 0.3564767, size.height * 0.6213928, size.width * 0.3282166, size.height * 0.6124662);
    path_0.lineTo(size.width * 0.01249518, size.height * 0.5127845);
    path_0.cubicTo(0, size.height * 0.5088397, 0, size.height * 0.4911603, size.width * 0.01249518, size.height * 0.4872155);
    path_0.lineTo(size.width * 0.3282166, size.height * 0.3875338);
    path_0.cubicTo(size.width * 0.3564767, size.height * 0.3786073, size.width * 0.3786073, size.height * 0.3564767, size.width * 0.3875338, size.height * 0.3282166);
    path_0.lineTo(size.width * 0.4872155, size.height * 0.01249518);
    path_0.cubicTo(size.width * 0.4911603, 0, size.width * 0.5088397, 0, size.width * 0.5127845, size.height * 0.01249518);
    Paint paint_0_fill = Paint()..style = PaintingStyle.fill;
    canvas.drawPath(path_0, paint_0_fill);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MainBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const MainBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<MainBottomNavBar> createState() => _MainBottomNavBarState();
}

class _MainBottomNavBarState extends State<MainBottomNavBar> {
  final double starSize = 30.0;

  @override
  Widget build(BuildContext context) {
    final gradient = const LinearGradient(
      colors: [Color(0xFF0460E9), Color(0xFF0D41A9)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );
    
    final screenWidth = MediaQuery.of(context).size.width;
    final tabWidth = screenWidth / 5;
    final indicatorXTarget = (tabWidth * widget.currentIndex) + (tabWidth / 2);

    return Container(
      padding: const EdgeInsets.only(top: 3.0),
      decoration: BoxDecoration(gradient: gradient),
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SafeArea(
          top: false,
          bottom: true,
          child: SizedBox(
            height: 84.0,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Row(
                  children: List.generate(5, (index) {
                    final icons = ['assets/images/jupiter_icon.svg', Icons.notifications, Icons.calendar_today, Icons.settings, Icons.school];
                    final isSelected = widget.currentIndex == index;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => widget.onTap(index),
                        behavior: HitTestBehavior.opaque,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (index == 0)
                              SvgPicture.asset(
                                icons[index] as String,
                                width: 30, height: 30,
                                colorFilter: isSelected ? null : const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
                              )
                            else
                              Icon(icons[index] as IconData, color: isSelected ? Colors.blue[800] : Colors.grey, size: 30),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: indicatorXTarget, end: indicatorXTarget),
                  duration: const Duration(milliseconds: 450),
                  curve: Curves.easeOutCubic,
                  builder: (context, position, child) {
                    return Positioned(
                      top: -(starSize / 2) - 2.25,
                      left: position - (starSize / 2),
                      child: child!,
                    );
                  },
                  child: ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (bounds) => gradient.createShader(
                      Rect.fromLTWH(-indicatorXTarget, 0, screenWidth, starSize),
                    ),
                    child: CustomPaint(
                      size: Size(starSize, starSize),
                      painter: RPSCustomPainter(),
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