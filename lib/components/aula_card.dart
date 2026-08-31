// lib/components/aula_card.dart

import 'dart:async';
import 'package:app_da_poli/models/disciplina_model.dart';
import 'package:app_da_poli/models/progresso_model.dart';
import 'package:app_da_poli/pages/disciplina_details_page.dart';
import 'package:app_da_poli/providers/disciplinas_provider.dart';
import 'package:app_da_poli/providers/user_provider.dart';
import 'package:app_da_poli/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

// 🟢 NOTIFIER GLOBAL: Controla qual card está aberto
final ValueNotifier<String?> globalExpandedCardId = ValueNotifier<String?>(null);

// Conta quantos cards estão vivos na tela para zerar o estado ao mudar de aba
int _activeCardsCount = 0;

class AulaCard extends StatefulWidget {
  final Disciplina disciplina;
  final DateTime dataAlvo; // 🟢 NOVO
  final String idUnico;    // 🟢 NOVO
  
  const AulaCard({
    super.key, 
    required this.disciplina, 
    required this.dataAlvo, 
    required this.idUnico
  });

  @override
  State<AulaCard> createState() => _AulaCardState();
}

class _AulaCardState extends State<AulaCard> with SingleTickerProviderStateMixin {
  
  // =========================================================================
  // 🎛️ PAINEL DE CONTROLE - BOTÕES FLUTUANTES (Seta Branca)
  // =========================================================================
  final double _distanciaBotoesTopo = 7.0;      
  final double _distanciaBotoesDireita = 7.0;   
  final double _distanciaEntreBotoes = 10.0;    
  final double _tamanhoIconesSeta = 26.0;       

  final double _grausRotacaoNavegar = 0.0;       
  final double _grausRotacaoRecolher = 180.0;    

  // =========================================================================
  // 🎛️ PAINEL DE CONTROLE - GRADE ANIMADA
  // =========================================================================
  final int _linhasVerticaisGrade = 11;          
  final int _linhasHorizontaisGrade = 8;         
  
  final Color _corLinhasGrade = const Color(0xFFF0F0F0); 
  final double _opacidadeLinhasGrade = 0.40;     

  // =========================================================================
  // 🎛️ PAINEL DE CONTROLE - TIPOGRAFIA E ESPAÇAMENTOS INTERNOS
  // =========================================================================
  final double _tamanhoFonteAristotelica = 14.0; 
  final double _tamanhoFonteLato = 11.0;         
  final double _tamanhoFontePorcentagem = 30.0;  
  
  final double _distanciaPorcentagemTexto = 8.0; 
  final double _distanciaPorcentagemAteLinha = 25.0; 
  final double _distanciaLinhaAteDias = 16.0;        
  
  final double _raioBordaCard = 6.0; 
  final double _distanciaEntreCards = 8.0; 
  final double _paddingLateralInterno = 14.0;
  final double _paddingTopCard = 12.0;
  final double _paddingBottomCard = 14.0;
  final double _espacoHorarioETextos = 12.0; 
  
  final double _tamanhoHorario = 15.0;
  final double _tamanhoTitulo = 18.0;
  
  final Color _corTextoBase = const Color(0xFFF0F0F0);
  // =========================================================================

  late AnimationController _gridAnimController;
  late String _myCardId;
  
  // 🟢 VARIÁVEIS PARA A ANIMAÇÃO DO SEMÁFORO
  Timer? _timerFace;
  bool _mostrarFaceA = true;

  // 🟢 VARIÁVEIS PARA O CARROSSEL E TIMER DOS BOTÕES
  late PageController _pageController;
  int _currentPage = 0;
  
  Timer? _timerAcao;
  String? _acaoSelecionada;
  int? _segundosRestantes;
  bool _acaoConcluida = false; // Controla quando esconder os botões para sempre

  // =========================================================================
  // 🧠 LÓGICA INTELIGENTE DE CÁLCULO DE AULAS E FREQUÊNCIA ATÉ ENTÃO
  // =========================================================================
  List<DateTime> _obterDatasDeAula(Turma turma) {
    List<DateTime> datas = [];
    DateTime inicio = widget.disciplina.dataInicio.toDate();
    DateTime fim = widget.disciplina.dataFim.toDate();
    
    const mapDias = {'SEGUNDA': 1, 'TERÇA': 2, 'QUARTA': 3, 'QUINTA': 4, 'SEXTA': 5, 'SÁBADO': 6, 'DOMINGO': 7};
    Set<int> diasValidos = {};
    for (var h in turma.horarios) {
      if (mapDias.containsKey(h.dia.toUpperCase())) {
        diasValidos.add(mapDias[h.dia.toUpperCase()]!);
      }
    }

    if (diasValidos.isEmpty) return datas;

    DateTime atual = DateTime(inicio.year, inicio.month, inicio.day);
    DateTime limite = DateTime(fim.year, fim.month, fim.day, 23, 59, 59);

    // Varre o período inteiro e separa só os dias que caem no dia da semana da aula
    while (atual.isBefore(limite) || atual.isAtSameMomentAs(limite)) {
      if (diasValidos.contains(atual.weekday)) {
        datas.add(atual);
      }
      atual = atual.add(const Duration(days: 1));
    }
    return datas;
  }

  int _calcularAulasAteHoje(List<DateTime> datas) {
    DateTime hoje = DateTime.now();
    DateTime limite = DateTime(hoje.year, hoje.month, hoje.day, 23, 59, 59);
    return datas.where((d) => d.isBefore(limite) || d.isAtSameMomentAs(limite)).length;
  }

  @override
  void initState() {
    super.initState();
    _myCardId = widget.idUnico; // Usa o RG único gerado pelo Feed!
    if (_activeCardsCount == 0) globalExpandedCardId.value = null;
    _activeCardsCount++; 

    _gridAnimController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
    _timerFace = Timer.periodic(const Duration(seconds: 7), (timer) {
      if (mounted) setState(() => _mostrarFaceA = !_mostrarFaceA);
    });

    _pageController = PageController();
  }

  @override
  void dispose() {
    _activeCardsCount--;
    if (_activeCardsCount <= 0) {
      _activeCardsCount = 0;
      globalExpandedCardId.value = null;
    }
    _gridAnimController.dispose();
    _timerFace?.cancel();
    _pageController.dispose();
    _timerAcao?.cancel();
    super.dispose();
  }

  (HorarioAula?, Turma?) _getDadosExibicao(BuildContext context) {
    if (widget.disciplina.turmas.isEmpty) return (null, null);
    final user = context.read<UserProvider>().currentUser;
    const mapDias = {1: 'SEGUNDA', 2: 'TERÇA', 3: 'QUARTA', 4: 'QUINTA', 5: 'SEXTA', 6: 'SÁBADO', 7: 'DOMINGO'};
    
    final diaStr = mapDias[widget.dataAlvo.weekday] ?? '';

    List<Turma> turmasDoAluno = widget.disciplina.turmas.where((t) => user?.turmasIds.contains(t.id) ?? false).toList();
    if (turmasDoAluno.isEmpty) return (null, null);

    for (var turma in turmasDoAluno) {
      for (var hor in turma.horarios) {
        if (hor.dia == diaStr) return (hor, turma);
      }
    }
    return (turmasDoAluno.first.horarios.firstOrNull, turmasDoAluno.first);
  }

  bool _isAulaAcontecendo(HorarioAula? hor) {
    if (hor == null) return false;
    final now = DateTime.now();

    // Trava de Tempo: Se o card não for de HOJE, a aula não está acontecendo!
    if (widget.dataAlvo.year != now.year || widget.dataAlvo.month != now.month || widget.dataAlvo.day != now.day) {
      return false;
    }

    const mapDias = {1: 'SEGUNDA', 2: 'TERÇA', 3: 'QUARTA', 4: 'QUINTA', 5: 'SEXTA', 6: 'SÁBADO', 7: 'DOMINGO'};
    final hojeStr = mapDias[now.weekday] ?? '';

    if (hor.dia != hojeStr) return false;

    try {
      final minutosAtual = now.hour * 60 + now.minute;
      final inicioStr = hor.inicio.split(':');
      final fimStr = hor.fim.split(':');
      
      final minutosInicio = int.parse(inicioStr[0]) * 60 + int.parse(inicioStr[1]);
      final minutosFim = int.parse(fimStr[0]) * 60 + int.parse(fimStr[1]);

      return minutosAtual >= (minutosInicio - 15) && minutosAtual <= minutosFim;
    } catch (e) { return false; }
  }

  void _iniciarContagemAcao(String acaoId, bool? valorFb, String dataHojeStr) {
    _timerAcao?.cancel(); 
    setState(() {
      _acaoSelecionada = acaoId;
      _segundosRestantes = 4;
    });

    _timerAcao = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_segundosRestantes! > 1) {
        if (mounted) setState(() => _segundosRestantes = _segundosRestantes! - 1);
      } else if (_segundosRestantes == 1) {
        if (mounted) setState(() => _segundosRestantes = 0); // REGISTRANDO
        
        await FirestoreService().registrarPresenca(widget.disciplina.id, dataHojeStr, valorFb);
        await Future.delayed(const Duration(milliseconds: 800));
        
        if (mounted) {
          if (globalExpandedCardId.value == _myCardId && _pageController.hasClients) {
            await _pageController.animateToPage(1, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
          }
          if (mounted) setState(() => _acaoConcluida = true);
        }
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DisciplinasProvider>();
    final progresso = provider.progressos.where((p) => p.disciplinaId == widget.disciplina.id).firstOrNull;

    final dataFormatadaStr = "${widget.dataAlvo.year}-${widget.dataAlvo.month.toString().padLeft(2, '0')}-${widget.dataAlvo.day.toString().padLeft(2, '0')}";
    
    final dados = _getDadosExibicao(context);
    final horarioAtual = dados.$1;
    final turmaAtual = dados.$2;

    final bool mostrarBotoes = _isAulaAcontecendo(horarioAtual);
    final String avisoEspecial = widget.disciplina.departamento == 'PQI' ? 'NÃO DEIXE DE LEVAR JALECO E ÓCULOS DE PROTEÇÃO' : '';

    final PaletaDisciplina paleta = Disciplina.obterPaleta(widget.disciplina.departamento);
    final Gradient gradienteDinamico = LinearGradient(colors: [paleta.fundoInicio, paleta.fundoFim], begin: Alignment.centerLeft, end: Alignment.centerRight);

    return ValueListenableBuilder<String?>(
      valueListenable: globalExpandedCardId,
      builder: (context, expandedId, child) {
        final bool isExpanded = expandedId == _myCardId;

        return GestureDetector(
          onTap: () {
            if (!isExpanded) {
              globalExpandedCardId.value = _myCardId; 
              Future.delayed(const Duration(milliseconds: 150), () {
                if (context.mounted) {
                  Scrollable.ensureVisible(
                    context,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOutCubic,
                    alignment: 0.25, 
                  );
                }
              });
            }
          },
          // 🟢 A MÁGICA FLUIDA: O Hero abraça o Material e ele voa perfeitamente
          child: Hero(
            tag: 'hero_card_$_myCardId',
            flightShuttleBuilder: (flightContext, animation, flightDirection, fromHeroContext, toHeroContext) {
              return Material(type: MaterialType.transparency, child: toHeroContext.widget);
            },
            child: Material(
              type: MaterialType.transparency,
              child: Container(
                margin: EdgeInsets.only(bottom: _distanciaEntreCards),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(_raioBordaCard),
                  border: Border.all(color: paleta.borda, width: 2.0),
                ),
                child: ClipRRect(
                  borderRadius: avisoEspecial.isNotEmpty 
                      ? BorderRadius.only(bottomLeft: Radius.circular(_raioBordaCard - 2.0), bottomRight: Radius.circular(_raioBordaCard - 2.0)) 
                      : BorderRadius.circular(_raioBordaCard - 2.0),
                  child: Stack(
                    children: [
                      Positioned.fill(child: Container(decoration: BoxDecoration(gradient: gradienteDinamico))),
                      
                      Positioned.fill(
                        child: AnimatedOpacity(
                          opacity: isExpanded ? 1.0 : 0.0,
                          duration: Duration(milliseconds: isExpanded ? 300 : 100), 
                          curve: isExpanded ? Curves.easeInExpo : Curves.easeOut,
                          child: AnimatedBuilder(
                            animation: _gridAnimController,
                            builder: (context, child) {
                              return CustomPaint(
                                painter: _GridPainter(
                                  progress: _gridAnimController.value,
                                  color: _corLinhasGrade.withOpacity(_opacidadeLinhasGrade),
                                  vLines: _linhasVerticaisGrade,
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      Positioned.fill(
                        child: AnimatedOpacity(
                          opacity: isExpanded ? 1.0 : 0.0,
                          duration: Duration(milliseconds: isExpanded ? 300 : 100),
                          child: Stack(
                            children: [
                              Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [paleta.fundoInicio, paleta.fundoInicio.withOpacity(0.0)]))),
                              Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [paleta.fundoFim, paleta.fundoFim.withOpacity(0.0)]))),
                            ],
                          ),
                        ),
                      ),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (avisoEspecial.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                              decoration: const BoxDecoration(color: Colors.white),
                              child: Text(avisoEspecial, style: const TextStyle(fontFamily: 'Aristotelica', fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF9FA3AD))),
                            ),
                          
                          Padding(
                            padding: EdgeInsets.only(left: _paddingLateralInterno, right: _paddingLateralInterno, top: _paddingTopCard, bottom: _paddingBottomCard),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IntrinsicHeight(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.stretch, 
                                    children: [
                                      _buildHorarioColumn(horarioAtual),
                                      SizedBox(width: _espacoHorarioETextos),
                                      
                                      Expanded(
                                        child: SingleChildScrollView( 
                                          physics: const NeverScrollableScrollPhysics(),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(right: isExpanded ? (_tamanhoIconesSeta * 2 + _distanciaEntreBotoes + 10) : 0),
                                                child: _buildInfoColumnFixed(horarioAtual, turmaAtual),
                                              ),
                                              
                                              AnimatedSize(
                                                duration: const Duration(milliseconds: 300),
                                                curve: Curves.fastOutSlowIn,
                                                alignment: Alignment.topCenter,
                                                clipBehavior: Clip.hardEdge, 
                                                child: isExpanded 
                                                    ? _buildExpandedLatos(turmaAtual)
                                                    : const SizedBox(width: double.infinity, height: 0),
                                              ),
                                            ],
                                          ),
                                        )
                                      ),
                                    ],
                                  ),
                                ),
                                
                                AnimatedSize(
                                  duration: const Duration(milliseconds: 400), 
                                  curve: Curves.easeInOutCubic, 
                                  alignment: Alignment.topCenter,
                                  clipBehavior: Clip.hardEdge, 
                                  child: AnimatedOpacity(
                                    duration: const Duration(milliseconds: 200),
                                    opacity: (!mostrarBotoes && !isExpanded) || (_acaoConcluida && !isExpanded) ? 0.0 : 1.0,
                                    child: Builder(
                                      builder: (context) {
                                        if (mostrarBotoes && !_acaoConcluida && !isExpanded) {
                                          return Column(
                                            children: [
                                              const SizedBox(height: 12),
                                              Divider(color: Colors.white.withOpacity(0.8), height: 1, thickness: 1.5),
                                              const SizedBox(height: 12),
                                              _buildBotoesPresencaOnly(dataFormatadaStr, paleta, gradienteDinamico),
                                            ],
                                          );
                                        } else if (mostrarBotoes && !_acaoConcluida && isExpanded) {
                                          return Column(
                                            children: [
                                              const SizedBox(height: 12),
                                              Divider(color: Colors.white.withOpacity(0.8), height: 1, thickness: 1.5),
                                              const SizedBox(height: 12),
                                              SizedBox(
                                                height: 75, 
                                                child: LayoutBuilder(
                                                  builder: (context, constraints) {
                                                    return OverflowBox(
                                                      maxWidth: constraints.maxWidth + 20, 
                                                      child: PageView(
                                                        controller: _pageController,
                                                        onPageChanged: (idx) => setState(() => _currentPage = idx),
                                                        children: [
                                                          Padding(
                                                            padding: const EdgeInsets.symmetric(horizontal: 10),
                                                            child: _buildBotoesPresencaOnly(dataFormatadaStr, paleta, gradienteDinamico),
                                                          ),
                                                          Padding(
                                                            padding: const EdgeInsets.symmetric(horizontal: 10),
                                                            child: _buildSecaoFrequenciaOnly(turmaAtual, progresso),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  }
                                                )
                                              ),
                                              const SizedBox(height: 12),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [_buildDot(0), const SizedBox(width: 6), _buildDot(1)],
                                              ),
                                            ],
                                          );
                                        } else if (isExpanded) {
                                          return Column(
                                            children: [
                                              const SizedBox(height: 12),
                                              Divider(color: Colors.white.withOpacity(0.8), height: 1, thickness: 1.5),
                                              const SizedBox(height: 12),
                                              _buildSecaoFrequenciaOnly(turmaAtual, progresso),
                                            ],
                                          );
                                        } else {
                                          return const SizedBox(width: double.infinity, height: 0);
                                        }
                                      }
                                    )
                                  )
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      Positioned(
                        top: avisoEspecial.isNotEmpty ? _distanciaBotoesTopo + 30 : _distanciaBotoesTopo,
                        right: _distanciaBotoesDireita,
                        child: IgnorePointer(
                          ignoring: !isExpanded,
                          child: AnimatedOpacity(
                            opacity: isExpanded ? 1.0 : 0.0,
                            duration: Duration(milliseconds: isExpanded ? 300 : 100),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () => globalExpandedCardId.value = null,
                                  child: Transform.rotate(
                                    angle: _grausRotacaoRecolher * math.pi / 180,
                                    child: Image.asset('assets/images/setabranca_icon.png', width: _tamanhoIconesSeta, height: _tamanhoIconesSeta),
                                  ),
                                ),
                                SizedBox(width: _distanciaEntreBotoes),
                                GestureDetector(
                                  // 🟢 A CHAVE DO POPUP! Ao clicar, expande em tela cheia usando a mesma Tag do Card
                                  onTap: () => DisciplinaDetailsPage.abrir(context, widget.disciplina, 'hero_card_$_myCardId'),
                                  child: Transform.rotate(
                                    angle: _grausRotacaoNavegar * math.pi / 180,
                                    child: Image.asset('assets/images/setabranca_icon.png', width: _tamanhoIconesSeta, height: _tamanhoIconesSeta),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }
    );
  }

  // 🟢 MÉTODOS DE CONSTRUÇÃO DE WIDGETS INTERNOS DA CLASSE _AulaCardState

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 6,
      width: _currentPage == index ? 16 : 6,
      decoration: BoxDecoration(
        color: _currentPage == index ? Colors.white : Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  Widget _buildSecaoFrequenciaOnly(Turma? turma, ProgressoDisciplina? progresso) {
    int totalAulas = widget.disciplina.totalAulasEstimadas;
    if (turma != null) {
      final datas = _obterDatasDeAula(turma);
      if (datas.isNotEmpty) totalAulas = datas.length;
    }

    int semRegistro = 0;
    int presentes = 0;

    if (progresso != null) {
      semRegistro = progresso.historicoPresenca.values.where((v) => v == null).length;
      presentes = progresso.historicoPresenca.values.where((v) => v == true).length;
    }

    totalAulas -= semRegistro;
    if (totalAulas <= 0) totalAulas = 1;

    int aulasAteHoje = 0;
    if (turma != null) {
      aulasAteHoje = _calcularAulasAteHoje(_obterDatasDeAula(turma));
    }
    
    int aulasValidasAteHoje = aulasAteHoje - semRegistro;
    if (aulasValidasAteHoje < 0) aulasValidasAteHoje = 0;

    int faltas = aulasValidasAteHoje - presentes;
    if (faltas < 0) faltas = 0;

    int limiteFaltas = (totalAulas * 0.3).floor();
    int cortesRestantes = limiteFaltas - faltas;

    double projecao = 100.0;
    if (totalAulas > 0) {
      projecao = ((totalAulas - faltas) / totalAulas) * 100.0;
    }
    if (projecao < 0) projecao = 0.0;

    String projecaoFormatada = projecao.toStringAsFixed(1).replaceAll('.', ',');
    if (projecaoFormatada.endsWith(',0')) projecaoFormatada = projecaoFormatada.substring(0, projecaoFormatada.length - 2);

    String emoji = '🟢';
    String textoPluralCortes = cortesRestantes != 1 ? 'S' : '';
    String textoFaceA = 'RESTAM $cortesRestantes FALTA$textoPluralCortes';

    if (cortesRestantes < 0) {
      emoji = '💀';
      textoFaceA = 'REPROVADO POR FALTA';
    } else if (cortesRestantes == 0) {
      emoji = '🚨';
      textoFaceA = 'LIMITE ATINGIDO • NÃO FALTE';
    } else if (cortesRestantes <= (limiteFaltas / 2).ceil()) {
      emoji = '🟡';
      textoFaceA = 'ATENÇÃO • RESTAM $cortesRestantes FALTA$textoPluralCortes';
    }

    String textoPluralFaltas = faltas != 1 ? 'S' : '';
    String valorGrandeAtual = _mostrarFaceA ? '$faltas FALTA$textoPluralFaltas' : '$projecaoFormatada%';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: ScramblingText(
                  text: valorGrandeAtual,
                  style: TextStyle(fontFamily: 'Anton', fontSize: _tamanhoFontePorcentagem, color: Colors.white, height: 1.0, letterSpacing: 0.5),
                ),
              ),
              SizedBox(height: _distanciaPorcentagemTexto), 
              
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 400),
                crossFadeState: _mostrarFaceA ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                alignment: Alignment.centerLeft,
                layoutBuilder: (topChild, topChildKey, bottomChild, bottomChildKey) {
                  return Stack(clipBehavior: Clip.none, alignment: Alignment.centerLeft, children: [Positioned(top: 0, bottom: 0, left: 0, right: 0, child: bottomChild), topChild]);
                },
                firstChild: Row(
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Expanded(child: Text(textoFaceA, style: TextStyle(fontFamily: 'Aristotelica', fontSize: _tamanhoFonteAristotelica, color: _corTextoBase.withOpacity(0.8), fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.visible)),
                  ],
                ),
                secondChild: Row(
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Expanded(child: Text('FREQUÊNCIA PROJETADA', style: TextStyle(fontFamily: 'Aristotelica', fontSize: _tamanhoFonteAristotelica, color: _corTextoBase.withOpacity(0.8), fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.visible)),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        SizedBox(width: _distanciaPorcentagemAteLinha), 
        Container(width: 1.5, height: 45, color: Colors.white.withOpacity(0.8)), 
        SizedBox(width: _distanciaLinhaAteDias),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: (turma?.horarios ?? []).map((h) {
            return Text(
              '${h.dia.substring(0, 3)} ${h.inicio} - ${h.fim}',
              style: TextStyle(fontFamily: 'Aristotelica', fontSize: _tamanhoFonteAristotelica, color: _corTextoBase.withOpacity(0.8), fontWeight: FontWeight.w700, height: 1.2),
            );
          }).toList(),
        )
      ],
    );
  }

  Widget _buildBotoesPresencaOnly(String dataHojeStr, PaletaDisciplina paleta, Gradient gradiente) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text('AGORA > VOCÊ ESTÁ PRESENTE?', style: TextStyle(fontFamily: 'Aristotelica', color: _corTextoBase, fontWeight: FontWeight.w700, fontSize: 15.0)),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildPresenceButton(label: 'PRESENTE', acaoId: 'PRESENTE', valorFb: true, dataHojeStr: dataHojeStr, paleta: paleta, gradiente: gradiente)),
            const SizedBox(width: 6),
            Expanded(child: _buildPresenceButton(label: 'AUSENTE', acaoId: 'AUSENTE', valorFb: false, dataHojeStr: dataHojeStr, paleta: paleta, gradiente: gradiente)),
            const SizedBox(width: 6),
            Expanded(child: _buildPresenceButton(label: 'SEM REGISTRO', acaoId: 'SEM REGISTRO', valorFb: null, dataHojeStr: dataHojeStr, paleta: paleta, gradiente: gradiente)),
          ],
        )
      ],
    );
  }

  Widget _buildPresenceButton({
    required String label, 
    required String acaoId, 
    required bool? valorFb, 
    required String dataHojeStr, 
    required PaletaDisciplina paleta, 
    required Gradient gradiente
  }) {
    bool isSelected = _acaoSelecionada == acaoId;
    
    String displayLabel = label;
    if (isSelected && _segundosRestantes != null) {
      if (_segundosRestantes! > 0) {
        displayLabel = '${_segundosRestantes}s';
      } else {
        displayLabel = 'REGISTRANDO';
      }
    }

    return GestureDetector(
      onTap: () => _iniciarContagemAcao(acaoId, valorFb, dataHojeStr),
      child: SizedBox(
        height: 38,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(6.7),
              ),
            ),
            
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isSelected ? 1.0 : 0.0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: gradiente,
                  borderRadius: BorderRadius.circular(6.7),
                ),
              ),
            ),

            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6.7),
                border: Border.all(
                  color: isSelected ? paleta.borda : const Color(0xFF969AA0), 
                  width: 1.5
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(top: 2.0, left: 4.0, right: 4.0), 
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontFamily: 'Aristotelica', 
                    color: isSelected ? const Color(0xFFF0F0F0) : const Color(0xFFBCBEBF), 
                    fontSize: _tamanhoFonteAristotelica, 
                    fontWeight: FontWeight.w700
                  ),
                  child: Text(displayLabel),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumnFixed(HorarioAula? hor, Turma? turma) {
    String localAula = hor?.local ?? 'A definir';
    
    String textoAula = "AULA --/--";
    if (turma != null) {
      List<DateTime> todasAsAulas = _obterDatasDeAula(turma);
      int total = todasAsAulas.length;
      int dadas = _calcularAulasAteHoje(todasAsAulas);
      if (total > 0) {
        textoAula = "AULA $dadas/$total"; 
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${widget.disciplina.codigo} – ${widget.disciplina.nome}'.toUpperCase(), style: TextStyle(fontFamily: 'Aristotelica', fontWeight: FontWeight.w700, fontSize: _tamanhoTitulo, color: _corTextoBase, height: 1.1), maxLines: 2, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 3),
        Text(localAula.toUpperCase(), style: TextStyle(fontFamily: 'Aristotelica', fontSize: _tamanhoFonteAristotelica, color: _corTextoBase.withOpacity(0.8), fontWeight: FontWeight.w700, height: 1.0), maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 3),
        Text(textoAula, style: TextStyle(fontFamily: 'Aristotelica', fontSize: _tamanhoFonteAristotelica, color: _corTextoBase.withOpacity(0.8), fontWeight: FontWeight.w700, height: 1.0), maxLines: 1, overflow: TextOverflow.ellipsis), 
      ],
    );
  }

  Widget _buildExpandedLatos(Turma? turma) {
    String nomeProfessor = turma != null && turma.professores.isNotEmpty ? turma.professores.join(', ') : 'NÃO ATRIBUÍDO';
    String codTurma = turma?.codigo ?? 'NÃO ATRIBUÍDA';

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("TURMA:  ", style: TextStyle(fontFamily: 'Aristotelica', fontSize: _tamanhoFonteAristotelica, color: _corTextoBase.withOpacity(0.8), fontWeight: FontWeight.w700)),
              Expanded(child: Text(codTurma, style: TextStyle(fontFamily: 'Lato', fontSize: _tamanhoFonteLato, color: _corTextoBase, fontWeight: FontWeight.w900))),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("DOCENTE:  ", style: TextStyle(fontFamily: 'Aristotelica', fontSize: _tamanhoFonteAristotelica, color: _corTextoBase.withOpacity(0.8), fontWeight: FontWeight.w700)),
              Expanded(child: Text(nomeProfessor.toUpperCase(), style: TextStyle(fontFamily: 'Lato', fontSize: _tamanhoFonteLato, color: _corTextoBase, fontWeight: FontWeight.w900, height: 1.1), maxLines: 3, overflow: TextOverflow.ellipsis)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHorarioColumn(HorarioAula? hor) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 46), 
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, 
        children: [
          Text(hor?.inicio ?? '--:--', style: TextStyle(fontFamily: 'Aristotelica', color: _corTextoBase, fontWeight: FontWeight.w700, fontSize: _tamanhoHorario, height: 1.0)),
          Expanded(child: Container(margin: const EdgeInsets.symmetric(vertical: 6), width: 1.5, color: _corTextoBase)),
          Text(hor?.fim ?? '--:--', style: TextStyle(fontFamily: 'Aristotelica', color: _corTextoBase, fontWeight: FontWeight.w700, fontSize: _tamanhoHorario, height: 1.0)),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final double progress;
  final Color color;
  final int vLines;

  _GridPainter({required this.progress, required this.color, required this.vLines});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = 1.0; 

    final double cellSize = size.width / vLines;

    for (int i = 1; i < vLines; i++) {
      canvas.drawLine(Offset(i * cellSize, 0), Offset(i * cellSize, size.height), paint);
    }

    double offsetY = progress * cellSize;
    for (double y = offsetY - cellSize; y <= size.height + cellSize; y += cellSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class ScramblingText extends StatefulWidget {
  final String text;
  final TextStyle style;
  const ScramblingText({super.key, required this.text, required this.style});

  @override
  State<ScramblingText> createState() => _ScramblingTextState();
}

class _ScramblingTextState extends State<ScramblingText> with SingleTickerProviderStateMixin {
  late String _currentText;
  late String _targetText;
  late AnimationController _controller;
  
  List<List<String>> _randomSteps = []; 
  final String _chars = '0123456789%#-'; 
  final math.Random _rnd = math.Random();

  @override
  void initState() {
    super.initState();
    _targetText = widget.text;
    _currentText = widget.text;
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _controller.addListener(_updateText);
  }

  void _generateSteps(String newText) {
    _randomSteps.clear();
    for (int i = 0; i < newText.length; i++) {
      if (newText[i] == ' ') {
        _randomSteps.add([' ', ' ', ' ']);
      } else {
        _randomSteps.add([
          _chars[_rnd.nextInt(_chars.length)],
          _chars[_rnd.nextInt(_chars.length)],
          _chars[_rnd.nextInt(_chars.length)],
        ]);
      }
    }
  }

  @override
  void didUpdateWidget(ScramblingText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _targetText = widget.text;
      _generateSteps(_targetText);
      _controller.forward(from: 0.0);
    }
  }

  void _updateText() {
    if (_controller.isCompleted) {
      if (_currentText != _targetText) setState(() => _currentText = _targetText);
      return;
    }

    String tempText = '';
    for (int i = 0; i < _targetText.length; i++) {
      double resolveTime = (i + 1) / _targetText.length;
      double progress = _controller.value / resolveTime;

      if (progress >= 1.0) {
        tempText += _targetText[i]; 
      } else {
        int step = (progress * 3).floor().clamp(0, 2);
        tempText += _randomSteps[i][step];
      }
    }
    
    if (_currentText != tempText) {
      setState(() => _currentText = tempText);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(_currentText, style: widget.style);
  }
}