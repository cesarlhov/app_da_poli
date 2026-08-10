// lib/components/main_bottom_nav_bar.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MainBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const MainBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  // =======================================================================
  // 🎛️ PAINEL DE CONTROLE - BARRA DE NAVEGAÇÃO
  // =======================================================================
  final double _alturaBarra = 86.0;
  final double _espessuraLinhaGradient = 3.0;
  
  // Estrela Deslizante
  final String _caminhoIconeEstrela = 'assets/images/estrela_icon.png';
  final double _tamanhoEstrela = 26.0;
  final double _deslocamentoEstrelaY = -1.0; 

  // Controle dos Ícones e Espaçamentos Laterais
  final double _tamanhoIcones = 32.0;
  final double _paddingLateralBarra = 11.0; 

  // 🟢 NOVAS CORES PADRONIZADAS
  final Color _corIconeAtivo = const Color(0xFF0891F4); // Azul claro para os botões normais quando selecionados
  final Color _corIconeInativo = const Color(0xFFB3B3BE); // Cinza para botões não selecionados
  
  final Gradient _gradienteLinha = const LinearGradient(
    colors: [Color(0xFF0460E9), Color(0xFF0D41A9)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Ordem das 5 abas atualizada: Eventos, Tarefas, Júpiter (SVG), Classe, Perfil
  List<String> get _iconesDasAbas => [
    'assets/images/eventos_icon.png',  // 0: Eventos
    'assets/images/tarefas_icon.png',  // 1: Tarefas
    'assets/images/jupiter_icon.svg',  // 2: Júpiter (Início) - Retornado para SVG
    'assets/images/classe_icon.png',   // 3: Classe
    'assets/images/perfil_icon.png',   // 4: Perfil
  ];
  // =======================================================================

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    final areaNavegacaoWidth = screenWidth - (_paddingLateralBarra * 2);
    final tabWidth = areaNavegacaoWidth / 5;
    final indicatorXTarget = _paddingLateralBarra + (tabWidth * currentIndex) + (tabWidth / 2);

    return Container(
      padding: EdgeInsets.only(top: _espessuraLinhaGradient),
      decoration: BoxDecoration(gradient: _gradienteLinha),
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: _alturaBarra,
            child: Stack(
              clipBehavior: Clip.none, 
              children: [
                _buildIconRow(),
                _buildAnimatedStar(indicatorXTarget, screenWidth),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconRow() {
    final icons = _iconesDasAbas;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: _paddingLateralBarra),
      child: Row(
        children: List.generate(5, (index) {
          final isSelected = currentIndex == index;
          final iconPath = icons[index];

          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(index),
              behavior: HitTestBehavior.opaque,
              child: Center(
                child: _buildIconWidget(iconPath, isSelected),
              ),
            ),
          );
        }),
      ),
    );
  }

  // 🟢 LÓGICA DE CORES INTELIGENTE (SVG ou PNG)
  Widget _buildIconWidget(String path, bool isSelected) {
    // Flag para identificar se o ícone atual é o Júpiter
    final bool isJupiter = path.contains('jupiter');

    if (path.endsWith('.svg')) {
      return SvgPicture.asset(
        path,
        width: _tamanhoIcones,
        height: _tamanhoIcones,
        colorFilter: isSelected 
            ? (isJupiter ? null : ColorFilter.mode(_corIconeAtivo, BlendMode.srcIn)) // Se Júpiter selecionado, remove o filtro. Senão, azul ativo.
            : ColorFilter.mode(_corIconeInativo, BlendMode.srcIn), // Se não selecionado, fica cinza
      );
    } else {
      return Image.asset(
        path,
        width: _tamanhoIcones,
        height: _tamanhoIcones,
        color: isSelected 
            ? (isJupiter ? null : _corIconeAtivo) // Funciona idêntico aos SVGs
            : _corIconeInativo,
      );
    }
  }

  Widget _buildAnimatedStar(double indicatorXTarget, double screenWidth) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: indicatorXTarget, end: indicatorXTarget),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
      builder: (context, position, child) {
        return Positioned(
          top: -(_tamanhoEstrela / 2) + _deslocamentoEstrelaY,
          left: position - (_tamanhoEstrela / 2),
          child: ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) {
              return _gradienteLinha.createShader(
                Rect.fromLTWH(
                  -(position - (_tamanhoEstrela / 2)), 
                  0, 
                  screenWidth, 
                  bounds.height,
                ),
              );
            },
            child: Image.asset(
              _caminhoIconeEstrela,
              width: _tamanhoEstrela,
              height: _tamanhoEstrela,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}