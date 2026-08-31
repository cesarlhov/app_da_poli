// lib/pages/jupiter_page.dart

import 'dart:math';
import 'package:app_da_poli/components/aula_card.dart';
import 'package:app_da_poli/components/slidable_grade_preview.dart';
import 'package:app_da_poli/components/dotted_container.dart';
import 'package:app_da_poli/models/disciplina_model.dart';
import 'package:app_da_poli/models/user_model.dart';
import 'package:app_da_poli/providers/user_provider.dart';
import 'package:app_da_poli/providers/disciplinas_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

String _lastSeenGreeting = '';

class JupiterPage extends StatefulWidget {
  const JupiterPage({super.key});
  @override
  State<JupiterPage> createState() => _JupiterPageState();
}

class _JupiterPageState extends State<JupiterPage> with SingleTickerProviderStateMixin {
  final GlobalKey<SlidableGradePreviewState> _slidableGradeKey = GlobalKey();
  late AnimationController _shrinkController;
  bool _isGradeShrunk = false;

  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<double> _scrollOffsetNotifier = ValueNotifier<double>(0.0);

  final double _paddingLateralTela = 15.0; 
  final double _headerPaddingTop = 16.0;
  final double _headerPaddingBottom = 4.0; 
  final double _tamanhoLogoGremio = 75.0;
  final double _tamanhoAvatar = 26.0; 
  final double _tamanhoLogoChaska = 54.0; 
  final double _espacoGremioTexto = 12.0; 
  final double _espacoTextoChaska = 12.0; 
  
  final double _tamanhoSaudacao = 15.5;
  final double _espacoLetrasSaudacao = 0.4; 
  final double _alturaLinhaSaudacao = 0.9;
  final double _espacoSaudacaoNome = 0.0; 
  final double _tamanhoNome = 15.5;
  final double _espacoLetrasNome = 0.4;
  final double _alturaLinhaNome = 0.9;
  final double _espacoNomeCurso = 8.0; 
  final double _tamanhoCurso = 15.5;
  final double _espacoLetrasCurso = 0.4; 
  final double _alturaLinhaCurso = 1.0;

  final double _distanciaTetoQuandoFixado = 13.0; 
  
  final double _espacoGradeAteArraste = 6.0; 
  final double _espacoArrasteAteBase = 15.0; 
  final double _espacoBaseSemFooter = 18.0; 

  final double _distanciaMinigradeProHoje = 8.0; 
  final double _distanciaHojeProsCards = 8.0;    
  
  final double _tamanhoHoje = 16.0;
  final Color _corHoje = const Color(0xFF162038); 
  
  final double _tamanhoDiaSemana = 16.0;
  final double _distanciaHojeProDia = 4.0; 
  final Color _corDiaSemanaEClasse = const Color(0xFFBCBEBF); 
  
  final double _tamanhoAcessarClasse = 16.0;

  final double _extensaoLinhaCards = 4.0; 
  final double _espessuraLinhaCards = 4.0; 

  // =========================================================================
  // 🎛️ PAINEL DE CONTROLE - ESTADO VAZIO (NENHUMA AULA HOJE)
  // =========================================================================
  final double _alturaBlocoSemAula = 50.0; // Edite a altura do bloco pontilhado aqui
  final double _distanciaBlocoSemAulaParaBotao = 20.0; // Edite a distância do bloco até o botão aqui

  // =========================================================================
  // 🎛️ PAINEL DE CONTROLE - CARD DE INTERVALO (Estilo Minigrade)
  // =========================================================================
  final double _intervaloTamanhoTexto = 15.0;
  final double _intervaloAltura = 45.0;
  
  final double _intervaloMarginTop = 0.0; 
  final double _intervaloMarginBottom = 8.0; 
  final double _intervaloMarginLateral = 0.0; 

  final Color _intervaloCorTexto = const Color(0xFFB1B5BD);
  
  final Color _intervaloCorBorda = const Color(0xFFBFC5D1); 
  final Color _intervaloCorFundo = const Color(0xFFDEE2EC).withOpacity(0.5); 
  
  final double _intervaloEspessuraBorda = 1.5;
  final double _intervaloRaioBorda = 6.0;
  final double _intervaloTraco = 2.0;
  final double _intervaloEspaco = 2.0;
  // =========================================================================

  @override
  void initState() {
    super.initState();
    _shrinkController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _shrinkController.addListener(() {
      setState(() {}); 
    });
  }

  @override
  void dispose() {
    _shrinkController.dispose();
    _scrollController.dispose();
    _scrollOffsetNotifier.dispose(); 
    super.dispose();
  }

  List<int> _diasExibidos = [0]; // 🟢 Estado: Controla quais dias estamos vendo (0 = hoje, 1 = amanhã, etc)

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 0 && hour < 5) return 'BOA MADRUGADA';
    if (hour >= 5 && hour < 12) return 'BOM DIA';
    if (hour >= 12 && hour < 18) return 'BOA TARDE';
    return 'BOA NOITE';
  }

  List<Disciplina> _getAulasDoDia(List<Disciplina> todasAsDisciplinas, UserModel user, int offsetDias) {
    List<Disciplina> aulasDia = [];
    final targetDate = DateTime.now().add(Duration(days: offsetDias));
    const mapDias = {1: 'SEGUNDA', 2: 'TERÇA', 3: 'QUARTA', 4: 'QUINTA', 5: 'SEXTA', 6: 'SÁBADO', 7: 'DOMINGO'};
    final diaStr = mapDias[targetDate.weekday] ?? '';

    // 🟢 LIMITA PARA LER APENAS A TURMA EM QUE ELE ESTÁ INSCRITO NO BANCO DE DADOS
    for (var d in todasAsDisciplinas) {
      var turmasDoAluno = d.turmas.where((t) => user.turmasIds.contains(t.id)).toList();
      if (turmasDoAluno.isEmpty) continue; // Pula se não for a turma dele!

      bool temAula = false;
      for (var t in turmasDoAluno) {
        if (t.horarios.any((h) => h.dia == diaStr)) {
          temAula = true;
          break;
        }
      }
      if (temAula) aulasDia.add(d);
    }

    aulasDia.sort((a, b) {
      int getEarliest(Disciplina d) {
        int minTime = 1440; 
        var turmasDoAluno = d.turmas.where((t) => user.turmasIds.contains(t.id)).toList();
        if (turmasDoAluno.isEmpty) return minTime;

        for (var t in turmasDoAluno) {
          for (var h in t.horarios) {
            if (h.dia == diaStr) {
              // 🟢 A conversão de horas feita manualmente aqui para não dar erro
              int tMin = 0;
              try {
                final parts = h.inicio.split(':');
                tMin = int.parse(parts[0].trim()) * 60 + int.parse(parts[1].trim());
              } catch (e) {
                tMin = 0;
              }
              if (tMin < minTime) minTime = tMin;
            }
          }
        }
        return minTime;
      }

      return getEarliest(a).compareTo(getEarliest(b));
    });

    return aulasDia;
  }

  // 🟢 Varre a semana em busca do próximo dia com aula
  void _carregarProximoDiaComAula(List<Disciplina> disciplinas, UserModel user) {
    int nextDay = _diasExibidos.last + 1;
    while (nextDay < 14) { // Limite de 14 dias pra frente
      if (_getAulasDoDia(disciplinas, user, nextDay).isNotEmpty) {
        setState(() {
          if (_diasExibidos.length == 1 && _getAulasDoDia(disciplinas, user, _diasExibidos.first).isEmpty) {
            _diasExibidos = [nextDay]; // Substitui o "vazio" pelo próximo dia
          } else {
            _diasExibidos.add(nextDay); // Adiciona ao fim da lista (Carregar Mais)
          }
        });
        return;
      }
      nextDay++;
    }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nenhuma aula agendada para os próximos 14 dias.')));
  }

  String _formatUserName(String fullName) {
    final names = fullName.trim().split(' ');
    if (names.length > 1) return '${names.first} ${names.last}'.toUpperCase();
    return names.first.toUpperCase();
  }

  String _formatCourseName(String course) {
    return course.replaceAllMapped(RegExp(r'Engenharia\s(.+)', caseSensitive: false), (match) => 'ENG. ${match.group(1)!.toUpperCase()}');
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final disciplinasProvider = context.watch<DisciplinasProvider>();

    if (userProvider.isLoading || disciplinasProvider.isLoading) return const Center(child: CircularProgressIndicator());
    final user = userProvider.currentUser;
    if (user == null) return const Center(child: Text('Erro ao carregar perfil.'));

    final disciplinas = disciplinasProvider.disciplinas;
    
    String currentGreeting = _getGreeting(); 
    bool animateThisTime = false;
    if (_lastSeenGreeting != currentGreeting) {
      animateThisTime = true;
      _lastSeenGreeting = currentGreeting;
    }

    // 🟢 Volta a calcular sempre o dia de HOJE para a barra fixa no topo
    final now = DateTime.now();
    const mapDiasTitulo = {1: 'SEGUNDA-FEIRA', 2: 'TERÇA-FEIRA', 3: 'QUARTA-FEIRA', 4: 'QUINTA-FEIRA', 5: 'SEXTA-FEIRA', 6: 'SÁBADO', 7: 'DOMINGO'};
    final diaSemanaStr = mapDiasTitulo[now.weekday] ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      body: SafeArea(
        bottom: false,
        // 🟢 A MÁGICA: Ouve a tela inteira, seja toque ou mudança de layout!
        child: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification notification) {
            if (notification.metrics.axis == Axis.vertical) {
              // O addPostFrameCallback evita que o app trave se tentar atualizar a linha enquanto o card ainda está no meio da animação de encolher
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) _scrollOffsetNotifier.value = notification.metrics.pixels;
              });
            }
            return false;
          },
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(child: _buildIdentidadeHeader(user, animateThisTime, currentGreeting)),
              SliverPersistentHeader(
                pinned: true, 
                delegate: _GradeMinimalistaDelegate(
                  disciplinas: disciplinas, turmasIds: user.turmasIds, slidableGradeKey: _slidableGradeKey, onGradeEdited: () {},
                  paddingLateral: _paddingLateralTela, shrinkAnimationValue: _shrinkController.value, 
                  distanciaTeto: _distanciaTetoQuandoFixado, espacoGradeAteArraste: _espacoGradeAteArraste, 
                  espacoArrasteAteBase: _espacoArrasteAteBase, espacoBaseSemFooter: _espacoBaseSemFooter, 
                  onShrink: () { if (mounted) { _shrinkController.forward(); _isGradeShrunk = true; } },
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickyHojeDelegate(
                  paddingLateral: _paddingLateralTela, distanciaMinigradeProHoje: _distanciaMinigradeProHoje,
                  tamanhoHoje: _tamanhoHoje, corHoje: _corHoje, tamanhoDiaSemana: _tamanhoDiaSemana,
                  corDiaSemana: _corDiaSemanaEClasse, distanciaHojeProDia: _distanciaHojeProDia,
                  tamanhoAcessarClasse: _tamanhoAcessarClasse, distanciaHojeProsCards: _distanciaHojeProsCards,
                  diaSemana: diaSemanaStr, 
                  
                  // 🟢 PASSA O NOVO OUVINTE PARA A LINHA CINZA EM VEZ DO SCROLL CONTROLLER
                  scrollOffsetNotifier: _scrollOffsetNotifier, 
                  extensaoLinhaCards: _extensaoLinhaCards, espessuraLinhaCards: _espessuraLinhaCards,
                ),
              ),
              SliverToBoxAdapter(child: _buildFeedInteligente(disciplinas, user)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIdentidadeHeader(UserModel user, bool animate, String greetingText) {
    const Color corPrincipal = Color(0xFF162038); 
    const Color corCurso = Color(0xFF9FA3AD); 
    const Color corEstrela = Color(0xFF078EF5);

    return Container(
      padding: EdgeInsets.only(top: _headerPaddingTop, bottom: _headerPaddingBottom, left: _paddingLateralTela, right: _paddingLateralTela),
      child: Row(
        children: [
          SizedBox(
            width: _tamanhoLogoGremio, height: _tamanhoLogoGremio, 
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset('assets/images/gremio_logo.png', color: Colors.grey[400]), 
                CircleAvatar(
                  radius: _tamanhoAvatar, backgroundColor: Colors.grey[300],
                  backgroundImage: user.fotoUrl != null && user.fotoUrl!.isNotEmpty ? NetworkImage(user.fotoUrl!) : null,
                  child: user.fotoUrl == null || user.fotoUrl!.isEmpty ? const Icon(Icons.person, color: Colors.white) : null,
                ),
              ],
            )
          ),
          SizedBox(width: _espacoGremioTexto),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min,
              children: [
                TextRevealGradient(text: greetingText, skipAnimation: !animate, style: TextStyle(fontFamily: 'MonumentExtended', fontWeight: FontWeight.w700, fontSize: _tamanhoSaudacao, color: corPrincipal, height: _alturaLinhaSaudacao, letterSpacing: _espacoLetrasSaudacao), targetColor: corPrincipal, duration: const Duration(milliseconds: 600), delay: const Duration(milliseconds: 0)),
                SizedBox(height: _espacoSaudacaoNome), 
                TextRevealGradient(text: _formatUserName(user.nomeCompleto).split(' ').first, skipAnimation: !animate, style: TextStyle(fontFamily: 'MonumentExtended', fontWeight: FontWeight.w700, fontSize: _tamanhoNome, color: corPrincipal, height: _alturaLinhaNome, letterSpacing: _espacoLetrasNome), targetColor: corPrincipal, duration: const Duration(milliseconds: 600), delay: const Duration(milliseconds: 300)),
                SizedBox(height: _espacoNomeCurso), 
                TextRevealGradient(text: _formatCourseName(user.curso), skipAnimation: !animate, style: TextStyle(fontFamily: 'MonumentExtended', fontWeight: FontWeight.w700, fontSize: _tamanhoCurso, color: corCurso, height: _alturaLinhaCurso, letterSpacing: _espacoLetrasCurso), targetColor: corCurso, duration: const Duration(milliseconds: 600), delay: const Duration(milliseconds: 600)),
              ],
            ),
          ),
          SizedBox(width: _espacoTextoChaska),
          Image.asset('assets/images/logochaskapreechida_icon.png', width: _tamanhoLogoChaska, color: corEstrela),
        ],
      ),
    );
  }

  // 🟢 FUNÇÃO AUXILIAR: Pega o tempo de início e fim da aula do dia para calcular o intervalo
  (int, int)? _getAulaTimes(Disciplina d, UserModel user, String diaStr) {
    var turmasDoAluno = d.turmas.where((t) => user.turmasIds.contains(t.id)).toList();
    if (turmasDoAluno.isEmpty) return null;
    for (var t in turmasDoAluno) {
      for (var h in t.horarios) {
        if (h.dia == diaStr) {
          try {
            final pI = h.inicio.split(':');
            final pF = h.fim.split(':');
            int start = int.parse(pI[0].trim()) * 60 + int.parse(pI[1].trim());
            int end = int.parse(pF[0].trim()) * 60 + int.parse(pF[1].trim());
            return (start, end);
          } catch (e) { return null; }
        }
      }
    }
    return null;
  }

  // 🟢 O NOVO FEED INTELIGENTE (Design Atualizado, Estado Vazio e Intervalos)
  Widget _buildFeedInteligente(List<Disciplina> disciplinas, UserModel user) {
    return GestureDetector(
      onTap: () => _slidableGradeKey.currentState?.closeMenu(),
      child: Padding(
        // 🟢 ESPAÇO BRANCO NO TOPO (6.0) para os cards passarem suavemente debaixo da linha cinza
        padding: EdgeInsets.fromLTRB(_paddingLateralTela, 6.0, _paddingLateralTela, 115.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ..._diasExibidos.expand((offset) {
              final aulas = _getAulasDoDia(disciplinas, user, offset);
              final dataAlvo = DateTime.now().add(Duration(days: offset));
              const mapDias = {1: 'SEGUNDA', 2: 'TERÇA', 3: 'QUARTA', 4: 'QUINTA', 5: 'SEXTA', 6: 'SÁBADO', 7: 'DOMINGO'};
              final diaStr = mapDias[dataAlvo.weekday] ?? '';
              
              final isHoje = offset == 0;
              final isAmanha = offset == 1;
              String tituloBloco = isHoje ? 'HOJE' : (isAmanha ? 'AMANHÃ' : diaStr);

              // 🟢 NOVO ESTILO DOS TÍTULOS: (Aristotelica w700), mas com cor Cinza
              final estiloTituloFeed = const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w700, fontFamily: 'Aristotelica', color: Color(0xFFBCBEBF));

              // 🟢 ESTADO VAZIO: Quando não há aulas hoje
              if (aulas.isEmpty && isHoje && _diasExibidos.length == 1) {
                return [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 0.0),
                    child: Column(
                      children: [
                        SizedBox(
                          height: _alturaBlocoSemAula, // ✅ AQUI: Usando a nova variável de altura
                          width: double.infinity,
                          child: DottedContainer(
                            color: _intervaloCorFundo,
                            borderColor: _intervaloCorBorda,
                            strokeWidth: _intervaloEspessuraBorda,
                            dashPattern: const [2.0, 2.0],
                            borderRadius: BorderRadius.circular(6.0), 
                            child: const Center(
                              child: Text(
                                'NENHUMA AULA HOJE - APROVEITE PARA ESTUDAR',
                                style: TextStyle(fontFamily: 'Aristotelica', fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFFB1B5BD)),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: _distanciaBlocoSemAulaParaBotao), // ✅ AQUI: Usando a nova variável de distância
                        GestureDetector(
                          onTap: () => _carregarProximoDiaComAula(disciplinas, user),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('CARREGAR PRÓXIMOS DIAS', style: TextStyle(fontFamily: 'Aristotelica', fontSize: 16.0, fontWeight: FontWeight.w700, color: Color(0xFFBCBEBF))),
                              const SizedBox(width: 8),
                              Transform.translate(
                                offset: const Offset(0, -2),
                                child: Image.asset('assets/images/carregarseguinte_icon.png', height: 20, color: const Color(0xFFBCBEBF)),
                              ),
                            ],
                          ),
                        )
                      ]
                    )
                  )
                ];
              }

              // 🟢 FEED NORMAL DO DIA (Com Aulas e Intervalos)
              bool isHojeGrupo = tituloBloco.toUpperCase().contains('HOJE');
              List<Widget> diaWidgets = [];

              if (!isHojeGrupo) {
                 diaWidgets.add(Text(tituloBloco, style: estiloTituloFeed));
                 diaWidgets.add(const SizedBox(height: 12)); 
              }

              for (int i = 0; i < aulas.length; i++) {
                diaWidgets.add(AulaCard(
                  disciplina: aulas[i],
                  dataAlvo: dataAlvo,
                  idUnico: '${aulas[i].id}_$offset', 
                ));

                // 🟢 LÓGICA DO CARD DE INTERVALO PONTILHADO
                if (i < aulas.length - 1) {
                  var currentTimes = _getAulaTimes(aulas[i], user, diaStr);
                  var nextTimes = _getAulaTimes(aulas[i+1], user, diaStr);
                  
                  if (currentTimes != null && nextTimes != null) {
                    if (nextTimes.$1 > currentTimes.$2) {
                      diaWidgets.add(
                        Container(
                          margin: const EdgeInsets.only(bottom: 8.0),
                          height: _intervaloAltura,
                          width: double.infinity,
                          child: DottedContainer(
                            color: _intervaloCorFundo,
                            borderColor: _intervaloCorBorda,
                            strokeWidth: _intervaloEspessuraBorda,
                            dashPattern: const [2.0, 2.0],
                            borderRadius: BorderRadius.circular(6.0), 
                            child: Center(
                              child: Text(
                                'INTERVALO - APROVEITE PARA ESTUDAR',
                                style: TextStyle(fontFamily: 'Aristotelica', fontSize: 16, fontWeight: FontWeight.w700, color: _intervaloCorTexto),
                              ),
                            ),
                          ),
                        )
                      );
                    }
                  }
                }
              }
              
              // 🟢 Distância farta entre o último card do dia atual e o título do próximo dia (ex: AMANHÃ)
              diaWidgets.add(const SizedBox(height: 7.0)); 

              return diaWidgets;
            }),

            // 🟢 BOTÃO DE CARREGAR MAIS AO FINAL DA LISTA
            if (_diasExibidos.isNotEmpty && !(_diasExibidos.length == 1 && _getAulasDoDia(disciplinas, user, _diasExibidos.first).isEmpty))
              Center(
                child: GestureDetector(
                  onTap: () => _carregarProximoDiaComAula(disciplinas, user),
                  child: Padding(
                    // 🟢 Distância entre o último card e o botão
                    padding: const EdgeInsets.only(top: 12.0, bottom: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('CARREGAR PRÓXIMOS DIAS', style: TextStyle(fontFamily: 'Aristotelica', fontSize: 16.0, fontWeight: FontWeight.w700, color: Color(0xFFBCBEBF))),
                        const SizedBox(width: 8),
                        // 🟢 Símbolo deslocado 2 pixels para cima
                        Transform.translate(
                          offset: const Offset(0, -2),
                          child: Image.asset('assets/images/carregarseguinte_icon.png', height: 20, color: const Color(0xFFBCBEBF)),
                        ),
                      ],
                    ),
                  ),
                ),
              )
          ]
        )
      )
    );
  }
}

class _GradeMinimalistaDelegate extends SliverPersistentHeaderDelegate {
  final List<Disciplina> disciplinas;
  final List<String> turmasIds; // 🟢 NOVO: Recebe as turmas do aluno
  final GlobalKey<SlidableGradePreviewState> slidableGradeKey;
  final VoidCallback onGradeEdited;
  final double paddingLateral;
  final double shrinkAnimationValue; 
  final double distanciaTeto; 
  final double espacoGradeAteArraste; 
  final double espacoArrasteAteBase; 
  final double espacoBaseSemFooter; 
  final VoidCallback onShrink;

  _GradeMinimalistaDelegate({
    required this.disciplinas, 
    required this.turmasIds, // 🟢 NOVO
    required this.slidableGradeKey, 
    required this.onGradeEdited,
    required this.paddingLateral,
    required this.shrinkAnimationValue,
    required this.distanciaTeto,
    required this.espacoGradeAteArraste,
    required this.espacoArrasteAteBase,
    required this.espacoBaseSemFooter,
    required this.onShrink,
  });

  // 🟢 LENTE INTELIGENTE: Puxa o menor e o maior horário vasculhando APENAS suas Turmas
  double _calculateHeight(double scrollPercentage) {
    int minMins = 450; 
    int maxMins = 1000; 
    bool hasLunchAny = false;

    for (var d in disciplinas) {
      // 🟢 CORREÇÃO: Filtra para calcular o tamanho usando apenas a sua turma!
      var turmasValidas = d.turmas.where((t) => turmasIds.contains(t.id)).toList();
      if (turmasValidas.isEmpty) turmasValidas = d.turmas;

      for (var t in turmasValidas) {
        for (var h in t.horarios) {
          if (h.inicio.isEmpty || !h.inicio.contains(':') || h.fim.isEmpty || !h.fim.contains(':')) continue;

          try {
            final pI = h.inicio.split(':');
            int start = int.parse(pI[0].trim()) * 60 + int.parse(pI[1].trim());
            if (start > 0 && start < minMins) minMins = start;

            final pF = h.fim.split(':');
            int end = int.parse(pF[0].trim()) * 60 + int.parse(pF[1].trim());
            if (end > 0 && end > maxMins) maxMins = end;

            bool isMorning = end <= 750; 
            bool isAfternoon = start >= 750; 
            bool isLunch = !isMorning && !isAfternoon; 
            if (isLunch) hasLunchAny = true;
          } catch (_) {}
        }
      }
    }

    double extraTop = (450 - minMins) > 0 ? (450 - minMins).toDouble() : 0.0;
    double extraBottom = (maxMins > 1000) ? (maxMins - 1000).toDouble() : 0.0;

    double escalaScroll = (1.0 - scrollPercentage * 0.5).clamp(0.5, 1.0); 
    double pixelsPorMinutoAtual = (64.0 / 210.0) * escalaScroll; 

    double gradeBase = (extraTop + 210 + 210 + extraBottom) * pixelsPorMinutoAtual;
    double alturaAlmoco = hasLunchAny ? (130 * pixelsPorMinutoAtual) : (6.0 + 4.0 + 6.0); 

    double espacoHeader = 12.0 + 20.0 + 4.0; 
    double alturaTextoArraste = 14.0; 
    double espacoFooterOriginal = (espacoGradeAteArraste + alturaTextoArraste + espacoArrasteAteBase); 
    double espacoFooterAtual = (espacoFooterOriginal * (1.0 - shrinkAnimationValue)) + (espacoBaseSemFooter * shrinkAnimationValue);

    return espacoHeader + gradeBase + alturaAlmoco + espacoFooterAtual + 2.0; 
  }

  @override
  double get maxExtent => _calculateHeight(0.0) + distanciaTeto; 
  @override
  double get minExtent => _calculateHeight(1.0) + distanciaTeto; 

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final double scrollShrinkPercentage = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);

    return Container(
      color: const Color(0xFFF0F0F0), 
      padding: EdgeInsets.only(top: distanciaTeto, left: paddingLateral, right: paddingLateral), 
      alignment: Alignment.topCenter, 
      child: SlidableGradePreview(
        key: slidableGradeKey,
        disciplinas: disciplinas,
        onGradeEdited: onGradeEdited,
        onShrink: onShrink, 
        scrollProgress: scrollShrinkPercentage, 
        shrinkValue: shrinkAnimationValue, 
        espacoGradeAteArraste: espacoGradeAteArraste, 
        espacoArrasteAteBase: espacoArrasteAteBase, 
        espacoBaseSemFooter: espacoBaseSemFooter, 
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _GradeMinimalistaDelegate oldDelegate) => 
      disciplinas != oldDelegate.disciplinas || 
      turmasIds != oldDelegate.turmasIds || // 🟢 NOVO
      paddingLateral != oldDelegate.paddingLateral || 
      shrinkAnimationValue != oldDelegate.shrinkAnimationValue;
}

class _StickyHojeDelegate extends SliverPersistentHeaderDelegate {
  final double paddingLateral;
  final double distanciaMinigradeProHoje;
  final double tamanhoHoje;
  final Color corHoje;
  final double tamanhoDiaSemana;
  final Color corDiaSemana;
  final double distanciaHojeProDia;
  final double tamanhoAcessarClasse;
  final double distanciaHojeProsCards;
  final String diaSemana; 

  // 🟢 A classe agora recebe o nosso Ouvinte de Tela inteligente!
  final ValueNotifier<double> scrollOffsetNotifier; 
  final double extensaoLinhaCards;
  final double espessuraLinhaCards;

  _StickyHojeDelegate({
    required this.paddingLateral,
    required this.distanciaMinigradeProHoje,
    required this.tamanhoHoje,
    required this.corHoje,
    required this.tamanhoDiaSemana,
    required this.corDiaSemana,
    required this.distanciaHojeProDia,
    required this.tamanhoAcessarClasse,
    required this.distanciaHojeProsCards,
    required this.diaSemana,
    required this.scrollOffsetNotifier, // 🟢 Atualizado aqui
    required this.extensaoLinhaCards,
    required this.espessuraLinhaCards,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: const Color(0xFFF0F0F0), 
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(height: distanciaMinigradeProHoje),
          
          SizedBox(
            height: 24.0, 
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: paddingLateral),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                crossAxisAlignment: CrossAxisAlignment.end, 
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text('HOJE', style: TextStyle(fontFamily: 'LeagueSpartan', fontSize: tamanhoHoje, fontWeight: FontWeight.w900, color: corHoje, height: 1.0)),
                      SizedBox(width: distanciaHojeProDia),
                      Text('/ $diaSemana', style: TextStyle(fontFamily: 'Aristotelica', fontSize: tamanhoDiaSemana, fontWeight: FontWeight.w700, color: corDiaSemana, height: 1.0)),
                    ],
                  ),
                  Text('ACESSAR CLASSE >', style: TextStyle(fontFamily: 'Aristotelica', fontSize: tamanhoAcessarClasse, fontWeight: FontWeight.w700, color: corDiaSemana, height: 1.0)),
                ],
              ),
            ),
          ),
          
          SizedBox(height: distanciaHojeProsCards),
          
          // 🟢 MÁGICA FINAL: Reage frame a frame ao ouvinte enquanto o card encolhe!
          ValueListenableBuilder<double>(
            valueListenable: scrollOffsetNotifier,
            builder: (context, scrollVal, child) {
              double val = scrollVal;
              if (val < 0) val = 0.0; // Continua protegendo contra o "pulo" elástico

              double inicioFade = 95.0; 
              double fimFade = inicioFade + 90.0; 
              
              double opacidadeFadeIn = ((val - inicioFade) / (fimFade - inicioFade)).clamp(0.0, 1.0);
              
              return Opacity(
                opacity: opacidadeFadeIn,
                child: Container(
                  height: espessuraLinhaCards,
                  margin: EdgeInsets.symmetric(horizontal: max(0.0, paddingLateral - extensaoLinhaCards)),
                  decoration: BoxDecoration(
                    color: const Color(0xFFBFC5D1), 
                    borderRadius: BorderRadius.circular(espessuraLinhaCards / 2),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  
  @override
  double get maxExtent => distanciaMinigradeProHoje + 24.0 + distanciaHojeProsCards + espessuraLinhaCards;
  @override
  double get minExtent => maxExtent;
  
  @override
  bool shouldRebuild(covariant _StickyHojeDelegate oldDelegate) => 
      diaSemana != oldDelegate.diaSemana || scrollOffsetNotifier != oldDelegate.scrollOffsetNotifier;
}

class TextRevealGradient extends StatefulWidget {
  final String text; final TextStyle style; final Color targetColor; final Duration duration; final Duration delay; 
  final bool skipAnimation; 
  const TextRevealGradient({super.key, required this.text, required this.style, required this.targetColor, this.duration = const Duration(milliseconds: 1200), this.delay = Duration.zero, this.skipAnimation = false});
  @override
  State<TextRevealGradient> createState() => _TextRevealGradientState();
}

class _TextRevealGradientState extends State<TextRevealGradient> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    if (widget.skipAnimation) {
      _controller.value = 1.0; 
    } else {
      if (widget.delay == Duration.zero) { _controller.forward(); } else { Future.delayed(widget.delay, () { if (mounted) _controller.forward(); }); }
    }
  }
  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double value = _controller.value;
        final Widget textoFinal = Text(widget.text, style: widget.style.copyWith(color: widget.targetColor));
        if (_controller.isCompleted) return textoFinal;
        if (value == 0.0) return Opacity(opacity: 0.0, child: textoFinal);

        return Stack(
          clipBehavior: Clip.none, alignment: Alignment.centerLeft,
          children: [
            Opacity(opacity: 0.0, child: textoFinal),
            Positioned(
              top: -8.0, bottom: -8.0, left: 0, right: 0,
              child: ShaderMask(
                shaderCallback: (bounds) {
                  const double nevoaWidth = 0.35; 
                  final double shift = (value * (1.0 + nevoaWidth * 2)) - nevoaWidth;
                  return LinearGradient(
                    begin: Alignment.centerLeft, end: Alignment.centerRight,
                    colors: [widget.targetColor, widget.targetColor, Colors.transparent, Colors.transparent],
                    stops: [0.0, (shift - nevoaWidth).clamp(0.0, 1.0), shift.clamp(0.0, 1.0), 1.0],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.srcIn,
                child: Container(alignment: Alignment.centerLeft, child: Text(widget.text, style: widget.style.copyWith(color: Colors.white))),
              ),
            ),
          ],
        );
      },
    );
  }
}