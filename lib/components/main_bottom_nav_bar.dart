// lib/components/main_bottom_nav_bar.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A barra de navegação inferior customizada do aplicativo.
/// Apresenta um indicador em formato de estrela que anima sua posição.
class MainBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const MainBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final tabWidth = screenWidth / 5;
    final indicatorXTarget = (tabWidth * currentIndex) + (tabWidth / 2);
    const starSize = 30.0;

    const gradient = LinearGradient(
      colors: [Color(0xFF0460E9), Color(0xFF0D41A9)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );

    return Container(
      // Borda superior com gradiente
      padding: const EdgeInsets.only(top: 3.0),
      decoration: const BoxDecoration(gradient: gradient),
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 84.0,
            child: Stack(
              clipBehavior: Clip.none, // Permite que a estrela saia dos limites do Stack
              children: [
                // Fila com os ícones de navegação
                _buildIconRow(),

                // Indicador de estrela animado
                _buildAnimatedStar(indicatorXTarget, starSize, screenWidth, gradient),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Constrói a fileira de ícones clicáveis.
  Widget _buildIconRow() {
    // Mapeamento de ícones para cada índice.
    final List<dynamic> icons = [
      'assets/images/jupiter_icon.svg', // 0: Início (Júputer)
      Icons.notifications_none_rounded, // 1: Avisos
      Icons.playlist_add_check_rounded, // 2: Tarefas
      Icons.calendar_today_rounded, // 3: Eventos
      Icons.person_outline_rounded, // 4: Perfil
    ];

    return Row(
      children: List.generate(5, (index) {
        final isSelected = currentIndex == index;
        final iconData = icons[index];

        return Expanded(
          child: GestureDetector(
            onTap: () => onTap(index),
            behavior: HitTestBehavior.opaque, // Garante que a área toda do GestureDetector seja clicável
            child: Center(
              child: (iconData is String)
                  ? SvgPicture.asset(
                      iconData,
                      width: 30,
                      height: 30,
                      colorFilter: isSelected ? null : const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
                    )
                  : Icon(
                      iconData as IconData,
                      color: isSelected ? const Color(0xFF0D41A9) : Colors.grey,
                      size: 30,
                    ),
            ),
          ),
        );
      }),
    );
  }

  /// Constrói o indicador de estrela que se move para a aba selecionada.
  Widget _buildAnimatedStar(double indicatorXTarget, double starSize, double screenWidth, Gradient gradient) {
    // TweenAnimationBuilder anima a posição 'left' da estrela suavemente.
    return TweenAnimationBuilder<double>(
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
      // O ShaderMask aplica o gradiente à estrela.
      child: ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (bounds) => gradient.createShader(
          Rect.fromLTWH(0, 0, bounds.width, bounds.height),
        ),
        child: CustomPaint(
          size: Size(starSize, starSize),
          painter: _StarCustomPainter(),
        ),
      ),
    );
  }
}

/// Painter customizado que desenha a forma da estrela.
class _StarCustomPainter extends CustomPainter {
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
    
    Paint paint = Paint()..style = PaintingStyle.fill;
    canvas.drawPath(path_0, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}