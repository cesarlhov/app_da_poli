// lib/pages/disciplina_details_page.dart

import 'package:app_da_poli/models/disciplina_model.dart';
import 'package:app_da_poli/providers/disciplinas_provider.dart';
import 'package:app_da_poli/providers/user_provider.dart';
import 'package:app_da_poli/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:math_expressions/math_expressions.dart' hide Stack;

class DisciplinaDetailsPage extends StatefulWidget {
  final Disciplina disciplina;
  final String heroTag;

  static const double margemLateralPopup = 15.0; 

  const DisciplinaDetailsPage({super.key, required this.disciplina, required this.heroTag});

  static void abrir(BuildContext context, Disciplina disciplina, String heroTag) {
    Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder(
        opaque: false, 
        transitionDuration: const Duration(milliseconds: 400),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: Scaffold(
              backgroundColor: Colors.transparent, 
              resizeToAvoidBottomInset: false, // 🟢 Faz o teclado passar por cima sem esmagar o popup!
              body: GestureDetector(
                // 🟢 Tira o foco da caixa de texto ao tocar fora dela
                onTap: () => FocusScope.of(context).unfocus(), 
                behavior: HitTestBehavior.translucent, 
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Container(color: const Color(0xFF000000).withOpacity(0.64)),
                    ),
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: FractionallySizedBox(
                          heightFactor: 0.666,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter, 
                                colors: [
                                  const Color(0xFF01050D).withOpacity(0.80),
                                  const Color(0xFF010919).withOpacity(0.0),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: margemLateralPopup),
                          child: DisciplinaDetailsPage(disciplina: disciplina, heroTag: heroTag),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  State<DisciplinaDetailsPage> createState() => _DisciplinaDetailsPageState();
}

class _DisciplinaDetailsPageState extends State<DisciplinaDetailsPage> {
  // =========================================================================
  // 🎛️ PAINEL DE CONTROLE DE DESIGN (FONTES E ESPAÇAMENTOS)
  // =========================================================================
  final double _raioBordaPopup = 6.0; 
  final double _paddingInternoPopup = 17.0; 

  // 🟢 1. CABEÇALHO FIXO
  final double _tamanhoCodigoCabecalho = 16.0; 
  final double _tamanhoNomeCabecalho = 22.0; 

  // 🟢 2. TÍTULOS E AVISOS ROLÁVEIS (Docente, Turma, Carga, etc.)
  final String _fonteTitulos = 'Aristotelica';
  final double _tamanhoTitulos = 15.0; 
  final FontWeight _pesoTitulos = FontWeight.w700;

  // 🟢 3. VALORES ROLÁVEIS (Giovane Avancini, 30 horas, D1-03, etc.)
  final String _fonteValores = 'Lato';
  final double _tamanhoValores = 14.0;
  final FontWeight _pesoValores = FontWeight.w900;

  // 🟢 4. DESTAQUES (Notas P1, P2 e Porcentagem de Frequência)
  final String _fonteAnton = 'Anton';
  final double _tamanhoNotas = 19.0;       
  final double _tamanhoPorcentagem = 33.0; 

  // 🟢 5. RODAPÉ FIXO (Arquivos, Representante, Baixar)
  final double _tamanhoTextoRodape = 16.0; 

  // 🟢 6. ESPAÇAMENTO VERTICAL ENTRE TEXTOS E LINHAS
  final double _espacoAbaixoSubtitulo = 2.0; 
  final double _espacoAbaixoTituloAulas = 4.0; 
  final double _espacoAbaixoPorcentagem = 6.0;
  final double _espacoAbaixoFormula = 6.0;     
  final double _espacoEntreSecoes = 10.0;     
  final double _espacoAbaixoListaRegistro = 4.0; 
  
  final double _distanciaAcimaLinhaHorizontal = 14.0;  
  final double _distanciaAbaixoLinhaHorizontal = 14.0; 
  
  final double _alturaLinhaVertical = 45.0;

  // 🟢 7. ESPAÇAMENTOS HORIZONTAIS DE DIVISÓRIAS (ESQUERDA E DIREITA)
  final double _distanciaLateralLinhaVertical = 10.0;     
  final double _distanciaLateralLinhaPorcentagem = 16.0;  
  final double _distanciaLateralLinhaNotas = 6.0;         
  final double _espacoVerticalEntreNotas = 8.0;          

  // 🟢 8. REGISTRO DE PRESENÇA EXPANSÍVEL
  final double _tamanhoFonteDataRegistro = 14.0;
  final double _tamanhoFonteBotaoRegistro = 13.0;
  final double _alturaCaixaRegistro = 40.0;
  final double _paddingInternoCaixaRegistro = 3.0; 
  
  // 🟢 NOVA SESSÃO: LARGURAS, PROPORÇÕES E COR DO ÍCONE
  final Color _corIconeCalendarioAtivo = const Color(0xFFFFFFFF); 
  final double _larguraCaixaData = 80.0; 
  
  final int _flexBtnPresente = 32;     
  final int _flexBtnAusente = 28;      
  final int _flexBtnSemRegistro = 40;  

  // Ícones e Textos de Fora do Popup
  final double _tamanhoIconeMinimizar = 30.0;
  final double _tamanhoIconeAnexar = 26.0;
  final double _tamanhoIconeClasse = 26.0;
  final double _tamanhoIconeBaixar = 26.0;
  
  final double _tamanhoFonteEditor = 13.0;
  // =========================================================================

  bool _isRegistroExpanded = false;

  void _registrarPresenca(bool? presente, String dataIso) {
    FirestoreService().registrarPresenca(widget.disciplina.id, dataIso, presente);
    setState(() {});
  }

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

  // 🟢 AVALIADOR DE FÓRMULAS (Agora aceita vírgulas!)
  double? _calcularNF(String formula, Map<String, double?> notas) {
    if (formula.isEmpty) return null;
    try {
      // Troca vírgula por ponto para o avaliador matemático não quebrar!
      String formStr = formula.toUpperCase().replaceAll(',', '.');
      
      // Substitui apenas as variáveis ativas da disciplina
      for (var av in widget.disciplina.avaliacoesAtivas) {
        double? val = notas[av];
        if (val == null) return null; // Se faltar nota ativa, não calcula
        formStr = formStr.replaceAll(av.toUpperCase(), val.toString());
      }
      
      Parser p = Parser();
      Expression exp = p.parse(formStr);
      ContextModel cm = ContextModel();
      return exp.evaluate(EvaluationType.REAL, cm);
    } catch (e) {
      return null; // Se a fórmula estiver maluca, não quebra o app
    }
  }

  // 🟢 ACONSELHAMENTO DINÂMICO E CÁLCULO DO QUE FALTA TIRAR!
  String _gerarAconselhamentoNotas(double? nf, int notasFaltantes, String formula, Map<String, double?> notas, List<String> ativas) {
    if (notasFaltantes > 0 && formula.isNotEmpty) {
      try {
        List<String> missingAvs = ativas.where((av) => notas[av] == null).toList();
        String baseFormula = formula.toUpperCase().replaceAll(',', '.');

        for (var av in ativas) {
          if (!missingAvs.contains(av) && notas[av] != null) {
            baseFormula = baseFormula.replaceAll(av.toUpperCase(), notas[av].toString());
          }
        }

        Parser p = Parser();
        Expression exp = p.parse(baseFormula);
        ContextModel cm = ContextModel();
        
        // 🟢 MÁGICA 2.0: Loop de inteiros (0 a 100) para evitar o bug de precisão do 4.99999
        for (int step = 0; step <= 100; step++) {
          double i = step / 10.0; // Garante números como 4.8, 4.9, 5.0 perfeitos
          
          for (var missingAv in missingAvs) {
            cm.bindVariable(Variable(missingAv.toUpperCase()), Number(i));
          }
          
          double result = exp.evaluate(EvaluationType.REAL, cm);
          
          // Arredonda para 2 casas decimais para o computador não ser chato com 4.9999
          double resultadoArredondado = (result * 100).round() / 100;
          
          if (resultadoArredondado >= 5.0) {
            if (notasFaltantes == 1) {
              return 'FALTA ${i.toStringAsFixed(1)} NA ${missingAvs.first} PARA A MÉDIA 5,0.';
            } else {
              return 'VOCÊ PRECISA DE UMA MÉDIA DE ${i.toStringAsFixed(1)}\nNAS $notasFaltantes AVALIAÇÕES RESTANTES.';
            }
          }
        }
        return 'MESMO GABARITANDO TUDO, A NOTA FICA ABAIXO DE 5,0.';
      } catch (e) {
        return 'PREENCHA MAIS NOTAS PARA CALCULAR O QUE FALTA.';
      }
    }

    if (nf != null) {
      if (nf >= 5.0) {
        return 'PARABÉNS!\nVOCÊ ATINGIU A NOTA PARA APROVAÇÃO.';
      } else {
        return 'NOTA ABAIXO DA MÉDIA.\nVOCÊ PRECISARÁ DE RECUPERAÇÃO/SUB.';
      }
    }
    return '';
  }

  Widget _buildVerticalDivider({double? height, double? marginHorizontal}) {
    return Container(
      width: 1.5, 
      height: height ?? _alturaLinhaVertical, 
      color: Colors.white.withOpacity(0.4), 
      margin: EdgeInsets.symmetric(horizontal: marginHorizontal ?? _distanciaLateralLinhaVertical)
    );
  }

  Widget _buildHorizontalDivider() {
    return Container(
      height: 1.5, 
      color: Colors.white.withOpacity(0.4), 
      margin: EdgeInsets.only(top: _distanciaAcimaLinhaHorizontal, bottom: _distanciaAbaixoLinhaHorizontal), 
      width: double.infinity
    );
  }

  Widget _buildTriToggle(String dataIso, bool? statusAtual, Gradient gradiente, PaletaDisciplina paleta) {
    return Container(
      height: _alturaCaixaRegistro,
      padding: EdgeInsets.all(_paddingInternoCaixaRegistro),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(6.0),
        border: Border.all(color: const Color(0xFF969AA0), width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: _flexBtnPresente, child: _buildTriToggleOption(label: 'PRESENTE', isSelected: statusAtual == true, onTap: () => _registrarPresenca(true, dataIso), gradiente: gradiente, paleta: paleta)),
          Expanded(flex: _flexBtnAusente, child: _buildTriToggleOption(label: 'AUSENTE', isSelected: statusAtual == false, onTap: () => _registrarPresenca(false, dataIso), gradiente: gradiente, paleta: paleta)),
          Expanded(flex: _flexBtnSemRegistro, child: _buildTriToggleOption(label: 'SEM REGISTRO', isSelected: statusAtual == null, onTap: () => _registrarPresenca(null, dataIso), gradiente: gradiente, paleta: paleta)),
        ],
      ),
    );
  }

  Widget _buildTriToggleOption({required String label, required bool isSelected, required VoidCallback onTap, required Gradient gradiente, required PaletaDisciplina paleta}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: isSelected ? gradiente : null,
          borderRadius: BorderRadius.circular(4.0),
          border: isSelected ? Border.all(color: paleta.borda, width: 1.5) : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Aristotelica',
            fontWeight: FontWeight.w700,
            fontSize: _tamanhoFonteBotaoRegistro,
            color: isSelected ? Colors.white : const Color(0xFF848B97), 
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis, 
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    
    final user = context.read<UserProvider>().currentUser;
    final provider = context.watch<DisciplinasProvider>();
    final progresso = provider.progressos.where((p) => p.disciplinaId == widget.disciplina.id).firstOrNull;

    // 🟢 NOVA LÓGICA DO TEXTO DO EDITOR
    String textoEditorLinha1 = "EDITADO PELA ÚLTIMA VEZ POR DESCONHECIDO";
    String textoEditorLinha2 = "";

    if (user != null) {
      String nomeEditor = user.nomeCompleto.toUpperCase();
      // Formata "Engenharia Química" ou "Engenharia de Computação" para "ENG. QUÍMICA" e "ENG. COMPUTAÇÃO"
      String cursoEditor = user.curso.toUpperCase().replaceAll(RegExp(r'ENGENHARIA\s+(DE\s+)?'), 'ENG. ');
      
      List<String> titulos = [];
      if (user.isGremio) {
        titulos.add("DIRETOR DO GRÊMIO POLITÉCNICO DA USP");
      } else if (user.isRC) {
        titulos.add("REPRESENTANTE DE CLASSE");
      }
      
      // 🟢 MÁGICA: Só mostra o "Calouro Curioso" se a pessoa não for Grêmio nem RC!
      if (user.tituloAtual.isNotEmpty) {
        if (user.tituloAtual != 'Calouro Curioso' || titulos.isEmpty) {
          titulos.add(user.tituloAtual.toUpperCase());
        }
      }
      
      textoEditorLinha1 = "EDITADO PELA ÚLTIMA VEZ POR $nomeEditor • $cursoEditor";
      textoEditorLinha2 = titulos.join(' • '); // Junta os títulos com um pontinho charmoso!
    }

    final PaletaDisciplina paleta = Disciplina.obterPaleta(widget.disciplina.departamento);
    final Gradient gradiente = LinearGradient(colors: [paleta.fundoInicio, paleta.fundoFim], begin: Alignment.topLeft, end: Alignment.bottomRight);
    final Color corBase = Colors.white;
    final Color corLabel = Colors.white.withOpacity(0.7);

    final TextStyle labelStyle = TextStyle(fontFamily: _fonteTitulos, fontSize: _tamanhoTitulos, fontWeight: _pesoTitulos, color: corLabel, height: 1.1);
    final TextStyle valueStyle = TextStyle(fontFamily: _fonteValores, fontSize: _tamanhoValores, fontWeight: _pesoValores, color: corBase, height: 1.1);
    final TextStyle horaStyle = TextStyle(fontFamily: _fonteTitulos, fontSize: _tamanhoTitulos, fontWeight: _pesoTitulos, color: corBase, height: 1.1);
    final TextStyle notaStyle = TextStyle(fontFamily: _fonteAnton, fontSize: _tamanhoNotas, color: corBase, letterSpacing: 1.0);
    final TextStyle notaLabelStyle = TextStyle(fontFamily: _fonteAnton, fontSize: _tamanhoNotas, color: corLabel, letterSpacing: 1.0);
    final TextStyle rodapeStyle = TextStyle(fontFamily: _fonteTitulos, fontWeight: _pesoTitulos, fontSize: _tamanhoTextoRodape, color: corLabel);

    List<Turma> turmasDoAluno = widget.disciplina.turmas.where((t) => user?.turmasIds.contains(t.id) ?? false).toList();
    Turma? turmaAtual = turmasDoAluno.isNotEmpty ? turmasDoAluno.first : (widget.disciplina.turmas.isNotEmpty ? widget.disciplina.turmas.first : null);

    String docentes = turmaAtual?.professores.join(', ') ?? 'NÃO ATRIBUÍDO';
    String turmaCod = turmaAtual?.codigo ?? '--';
    
    int creditos = 0;
    if (turmaAtual != null) {
      for (var hor in turmaAtual.horarios) {
        try {
          final pI = hor.inicio.split(':');
          final pF = hor.fim.split(':');
          int start = int.parse(pI[0].trim()) * 60 + int.parse(pI[1].trim());
          int end = int.parse(pF[0].trim()) * 60 + int.parse(pF[1].trim());
          if (start > 0 && end > start) creditos += ((end - start) ~/ 50);
        } catch (_) {}
      }
    }
    String cargaHoraria = '${creditos * 15} horas';
    String tipoPeriodo = widget.disciplina.isQuadrimestral ? 'QUADRIMESTRAL' : 'SEMESTRAL';
    String dataIni = DateFormat('dd/MM/yyyy').format(widget.disciplina.dataInicio.toDate());
    String dataFim = DateFormat('dd/MM/yyyy').format(widget.disciplina.dataFim.toDate());
    
    String local = '--';
    String lab = '--';
    if (turmaAtual != null && turmaAtual.horarios.isNotEmpty) {
      local = turmaAtual.horarios.first.local;
      var horLab = turmaAtual.horarios.where((h) => h.isLaboratorio).firstOrNull;
      if (horLab != null) lab = horLab.local;
    }

    List<DateTime> aulasPassadas = [];
    int totalAulas = widget.disciplina.totalAulasEstimadas;
    if (turmaAtual != null) {
      final datas = _obterDatasDeAula(turmaAtual);
      if (datas.isNotEmpty) totalAulas = datas.length;

      DateTime hoje = DateTime.now();
      DateTime limite = DateTime(hoje.year, hoje.month, hoje.day, 23, 59, 59);
      aulasPassadas = datas.where((d) => d.isBefore(limite) || d.isAtSameMomentAs(limite)).toList();
      aulasPassadas.sort((a, b) => a.compareTo(b));
    }

    int semRegistro = 0;
    int presentes = 0;

    if (progresso != null) {
      semRegistro = progresso.historicoPresenca.values.where((v) => v == null).length;
      presentes = progresso.historicoPresenca.values.where((v) => v == true).length;
    }

    totalAulas -= semRegistro;
    if (totalAulas <= 0) totalAulas = 1;

    int aulasAteHoje = aulasPassadas.length;
    
    int aulasValidasAteHoje = aulasAteHoje - semRegistro;
    if (aulasValidasAteHoje < 0) aulasValidasAteHoje = 0;

    int faltas = aulasValidasAteHoje - presentes;
    if (faltas < 0) faltas = 0;

    double projecao = 100.0;
    if (totalAulas > 0) {
      projecao = ((totalAulas - faltas) / totalAulas) * 100.0;
    }
    if (projecao < 0) projecao = 0.0;

    String freqFinalStr = projecao.toStringAsFixed(1).replaceAll('.', ',');
    if (freqFinalStr.endsWith(',0')) freqFinalStr = freqFinalStr.substring(0, freqFinalStr.length - 2);

    final screenHeight = MediaQuery.of(context).size.height;

    // 🟢 INTELIGÊNCIA DE AVALIAÇÃO
    bool exigePresenca = widget.disciplina.contaPresenca;
    int notasFaltantes = widget.disciplina.avaliacoesAtivas.where((av) => progresso?.notasPreenchidas[av] == null).length;
    
    double? notaFinal;
    bool hasFormula = widget.disciplina.formulaFinal.isNotEmpty;

    if (notasFaltantes == 0 && hasFormula) {
      notaFinal = _calcularNF(widget.disciplina.formulaFinal, progresso!.notasPreenchidas);
    }
    
    String aconselhamentoNotas = hasFormula 
      ? _gerarAconselhamentoNotas(notaFinal, notasFaltantes, widget.disciplina.formulaFinal, progresso?.notasPreenchidas ?? {}, widget.disciplina.avaliacoesAtivas) 
      : '';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Hero(
          tag: widget.heroTag,
          flightShuttleBuilder: (flightContext, animation, flightDirection, fromHeroContext, toHeroContext) {
            final paleta = Disciplina.obterPaleta(widget.disciplina.departamento);
            return Material(
              type: MaterialType.transparency,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(_raioBordaPopup),
                  gradient: LinearGradient(
                    colors: [paleta.fundoInicio, paleta.fundoFim],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: paleta.borda, width: 2),
                ),
              ),
            );
          },
          child: Material(
            type: MaterialType.transparency,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: screenHeight * 0.72),
              child: Container(
                decoration: BoxDecoration(
                  gradient: gradiente,
                  borderRadius: BorderRadius.circular(_raioBordaPopup),
                  border: Border.all(color: paleta.borda, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(_raioBordaPopup - 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch, 
                    mainAxisSize: MainAxisSize.min, 
                    children: [
                      
                      // ==========================================
                      // 1. CABEÇALHO (FIXO NO TOPO)
                      // ==========================================
                      Padding(
                        padding: EdgeInsets.only(top: 20, left: _paddingInternoPopup, right: _paddingInternoPopup, bottom: 14),
                        child: SizedBox(
                          width: double.infinity,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: _tamanhoIconeMinimizar + 8.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(widget.disciplina.codigo, style: TextStyle(fontFamily: _fonteTitulos, fontWeight: _pesoTitulos, fontSize: _tamanhoCodigoCabecalho, color: corLabel)),
                                    Text(widget.disciplina.nome.toUpperCase(), textAlign: TextAlign.center, style: TextStyle(fontFamily: _fonteTitulos, fontSize: _tamanhoNomeCabecalho, fontWeight: _pesoTitulos, color: corBase, height: 1.1)),
                                  ],
                                ),
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Image.asset('assets/images/setaminimizar_icon.png', width: _tamanhoIconeMinimizar, height: _tamanhoIconeMinimizar, color: corBase),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      Container(height: 1.5, color: Colors.white.withOpacity(0.4), width: double.infinity),

                      // ==========================================
                      // 2. CORPO ROLÁVEL 
                      // ==========================================
                      Flexible(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.only(
                            top: 18, 
                            left: _paddingInternoPopup, 
                            right: _paddingInternoPopup, 
                            // 🟢 Cria um espaço fixo menor, apenas o suficiente para a rolagem funcionar
                            bottom: keyboardHeight > 0 ? 170.0 : 18.0, 
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('DOCENTE', style: labelStyle),
                              SizedBox(height: _espacoAbaixoSubtitulo),
                              Text(docentes.toUpperCase(), style: valueStyle),
                              SizedBox(height: _espacoEntreSecoes),

                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(flex: 3, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('TURMA', style: labelStyle), SizedBox(height: _espacoAbaixoSubtitulo), Text(turmaCod, style: valueStyle)])),
                                  _buildVerticalDivider(),
                                  Expanded(flex: 4, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('CRÉDITOS AULA', style: labelStyle), SizedBox(height: _espacoAbaixoSubtitulo), Text(creditos.toString(), style: valueStyle)])),
                                  _buildVerticalDivider(),
                                  Expanded(flex: 5, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('CARGA HORÁRIA TOTAL', style: labelStyle), SizedBox(height: _espacoAbaixoSubtitulo), Text(cargaHoraria, style: valueStyle)])),
                                ],
                              ),
                              SizedBox(height: _espacoEntreSecoes),

                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 3, 
                                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(tipoPeriodo, style: labelStyle), SizedBox(height: _espacoAbaixoSubtitulo), Text('$dataIni\n$dataFim', style: valueStyle, maxLines: 2)])
                                  ),
                                  _buildVerticalDivider(),
                                  Expanded(
                                    flex: 4, 
                                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('LOCAL', style: labelStyle), SizedBox(height: _espacoAbaixoSubtitulo), Text(local, style: valueStyle, maxLines: 2)])
                                  ),
                                  
                                  if (lab != '--') ...[
                                    _buildVerticalDivider(),
                                    Expanded(
                                      flex: 4, 
                                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('LABORATÓRIO', style: labelStyle), SizedBox(height: _espacoAbaixoSubtitulo), Text(lab, style: valueStyle, maxLines: 2)])
                                    ),
                                  ]
                                ],
                              ),

                              _buildHorizontalDivider(),
                              Text('AULAS & PRESENÇA', style: labelStyle),
                              SizedBox(height: _espacoAbaixoTituloAulas),

                              if (exigePresenca) ...[
                                Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('$freqFinalStr%', style: TextStyle(fontFamily: _fonteAnton, fontSize: _tamanhoPorcentagem, color: corBase, height: 1.0)),
                                        SizedBox(height: _espacoAbaixoPorcentagem), 
                                        Text('PRESENTE', style: labelStyle), 
                                      ],
                                    ),
                                    _buildVerticalDivider(marginHorizontal: _distanciaLateralLinhaPorcentagem),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: turmaAtual?.horarios.map((h) => Text('${h.dia.substring(0, 3)} ${h.inicio} - ${h.fim}', style: horaStyle)).toList() ?? [],
                                      ),
                                    ),
                                    _buildVerticalDivider(marginHorizontal: 12),
                                    GestureDetector(
                                      onTap: () => setState(() => _isRegistroExpanded = !_isRegistroExpanded),
                                      child: Column(
                                        children: [
                                          Text(
                                            'REGISTRO', 
                                            style: labelStyle.copyWith(
                                              color: _isRegistroExpanded ? Colors.white : corLabel
                                            )
                                          ),
                                          const SizedBox(height: 6),
                                          Image.asset(
                                            'assets/images/calendariocheck_icon.png', 
                                            width: 26, 
                                            height: 26, 
                                            color: _isRegistroExpanded ? Colors.white : corLabel,
                                            colorBlendMode: BlendMode.srcIn,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  projecao >= 70.0 ? 'PRESENÇA > 70% OK.' : 'ALERTA: PRESENÇA ABAIXO DE 70%.\nRISCO DE REPROVAÇÃO POR FALTAS!',
                                  style: labelStyle.copyWith(color: projecao >= 70.0 ? Colors.greenAccent : Colors.redAccent),
                                ),
                                
                                AnimatedSize(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOutCubic,
                                  child: !_isRegistroExpanded ? const SizedBox(width: double.infinity) : Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 16),
                                      SizedBox(height: 12, child: CustomPaint(painter: _WavyLinePainter(), size: Size.infinite)),
                                      const SizedBox(height: 16),
                                      ...aulasPassadas.map((data) {
                                        final dataIso = "${data.year}-${data.month.toString().padLeft(2, '0')}-${data.day.toString().padLeft(2, '0')}";
                                        final statusAtual = progresso?.historicoPresenca[dataIso];
                                        final dataFormatada = DateFormat('dd/MM/yyyy').format(data);
                                        
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 12.0),
                                          child: Row(
                                            children: [
                                              SizedBox(
                                                width: _larguraCaixaData, 
                                                child: Text(
                                                  dataFormatada,
                                                  style: TextStyle(fontFamily: _fonteTitulos, fontWeight: _pesoTitulos, fontSize: _tamanhoFonteDataRegistro, color: corBase)
                                                ),
                                              ),
                                              Expanded(child: _buildTriToggle(dataIso, statusAtual, gradiente, paleta)),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                      if (aulasPassadas.isEmpty)
                                        const Center(child: Text('Nenhuma aula registrada ainda.', style: TextStyle(color: Colors.white70))),
                                      
                                      SizedBox(height: _espacoAbaixoListaRegistro), 
                                    ]
                                  )
                                ),
                              ] else ...[
                                // 🟢 LAYOUT QUANDO NÃO CONTA PRESENÇA
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'NÃO HÁ CONTAGEM DE\nPRESENÇA PARA ESTA\nDISCIPLINA.',
                                        style: labelStyle,
                                      ),
                                    ),
                                    _buildVerticalDivider(marginHorizontal: _distanciaLateralLinhaPorcentagem),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: turmaAtual?.horarios.map((h) => Text('${h.dia.substring(0, 3)} ${h.inicio} - ${h.fim}', style: horaStyle)).toList() ?? [],
                                      ),
                                    ),
                                  ],
                                ),
                              ],

                              _buildHorizontalDivider(),

                              Text('CRITÉRIO DE AVALIAÇÕES', style: labelStyle),
                              SizedBox(height: _espacoAbaixoSubtitulo),
                              Text(hasFormula ? widget.disciplina.formulaFinal : 'A DEFINIR', style: labelStyle),
                              SizedBox(height: _espacoAbaixoFormula), 
                              
                              if (hasFormula)
                                Wrap(
                                  spacing: 0, 
                                  runSpacing: _espacoVerticalEntreNotas, 
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    ...widget.disciplina.avaliacoesAtivas.expand((av) {
                                      double? nota = progresso?.notasPreenchidas[av];
                                      return [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.baseline,
                                          textBaseline: TextBaseline.alphabetic,
                                          children: [
                                            Text('$av ', style: notaLabelStyle),
                                            SizedBox(
                                              width: 45,
                                              // 🟢 SUBSTITUÍDO PELO NOSSO NOVO WIDGET INTELIGENTE
                                              child: _NotaInputField(
                                                notaInicial: nota,
                                                textStyle: notaStyle,
                                                hintStyle: notaStyle.copyWith(color: corBase.withOpacity(0.5)),
                                                onSaved: (valorParsed) {
                                                  final Map<String, double?> novasNotas = Map.from(progresso?.notasPreenchidas ?? {});
                                                  novasNotas[av] = valorParsed;
                                                  FirestoreService().atualizarNotas(widget.disciplina.id, novasNotas);
                                                  setState(() {}); // Força o recalculo da NF
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                        _buildVerticalDivider(height: 24, marginHorizontal: _distanciaLateralLinhaNotas), 
                                      ];
                                    }).toList(),
                                    // 🟢 NOTA FINAL CALCULADA
                                    Row(
                                      mainAxisSize: MainAxisSize.min, 
                                      children: [
                                        Text('NF ', style: notaLabelStyle), 
                                        Text(notaFinal != null ? notaFinal.toStringAsFixed(2) : '-.--', style: notaStyle)
                                      ]
                                    ),
                                  ],
                                ),
                              if (hasFormula) SizedBox(height: _espacoEntreSecoes),
                              
                              if (hasFormula && aconselhamentoNotas.isNotEmpty)
                                Center(
                                  child: Text(
                                    aconselhamentoNotas, // 🟢 TEXTO DINÂMICO!
                                    textAlign: TextAlign.center, 
                                    style: labelStyle
                                  )
                                ),
                            ],
                          ),
                        ),
                      ),
                      
                      // ==========================================
                      // 3. RODAPÉ (FIXO NA BASE E SIMÉTRICO)
                      // ==========================================
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: _paddingInternoPopup),
                        child: _DashedDivider(),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 14, left: _paddingInternoPopup, right: _paddingInternoPopup, bottom: _paddingInternoPopup),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center, 
                                children: [Text('ARQUIVOS', style: rodapeStyle, textAlign: TextAlign.center), SizedBox(height: _espacoAbaixoSubtitulo), Image.asset('assets/images/anexar_icon.png', color: corBase, width: _tamanhoIconeAnexar, height: _tamanhoIconeAnexar)]
                              )
                            ),
                            _buildVerticalDivider(marginHorizontal: _distanciaLateralLinhaVertical),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center, 
                                children: [Text('CLASSES', style: rodapeStyle, textAlign: TextAlign.center), SizedBox(height: _espacoAbaixoSubtitulo), Image.asset('assets/images/classe_icon.png', color: corBase, width: _tamanhoIconeClasse, height: _tamanhoIconeClasse)]
                              )
                            ),
                            _buildVerticalDivider(marginHorizontal: _distanciaLateralLinhaVertical),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center, 
                                children: [Text('BAIXAR', style: rodapeStyle, textAlign: TextAlign.center), SizedBox(height: _espacoAbaixoSubtitulo), SvgPicture.asset('assets/images/baixar_icon.svg', colorFilter: ColorFilter.mode(corBase, BlendMode.srcIn), width: _tamanhoIconeBaixar, height: _tamanhoIconeBaixar)]
                              )
                            ),
                          ],
                        ),
                      )

                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        
        // ==========================================
        // TEXTO EXTERNO DO EDITOR
        // ==========================================
        const SizedBox(height: 12),
        Text(
          textoEditorLinha2.isEmpty 
              ? textoEditorLinha1 
              : '$textoEditorLinha1\n$textoEditorLinha2',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6), 
            fontSize: _tamanhoFonteEditor, 
            fontFamily: 'Aristotelica', 
            fontWeight: FontWeight.w700
          ),
        )
      ],
    );
  }
}

class _WavyLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.4) 
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path();
    path.moveTo(0, size.height / 2);

    double waveWidth = 20.0;
    double waveHeight = 4.0;
    bool up = true;

    for (double i = 0; i < size.width; i += waveWidth) {
      path.quadraticBezierTo(
        i + (waveWidth / 2),
        (size.height / 2) + (up ? -waveHeight : waveHeight),
        i + waveWidth,
        size.height / 2,
      );
      up = !up;
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _DashedDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 1.5,
      child: CustomPaint(painter: _DashedLinePainter()),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double dashWidth = 5.0; 
    double dashSpace = 4.0; 
    double startX = 0.0;
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = size.height;

    while (startX < size.width) {
      canvas.drawLine(Offset(startX, size.height / 2), Offset(startX + dashWidth, size.height / 2), paint);
      startX += dashWidth + dashSpace;
    }
  }
  
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// 🟢 CAMPO DE NOTA INTELIGENTE (Formata ao sair)
class _NotaInputField extends StatefulWidget {
  final double? notaInicial;
  final TextStyle textStyle;
  final TextStyle hintStyle;
  final ValueChanged<double?> onSaved;

  const _NotaInputField({super.key, required this.notaInicial, required this.textStyle, required this.hintStyle, required this.onSaved});

  @override
  State<_NotaInputField> createState() => _NotaInputFieldState();
}

class _NotaInputFieldState extends State<_NotaInputField> {
  late TextEditingController _ctrl;
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.notaInicial != null ? widget.notaInicial!.toStringAsFixed(2) : '');
    
    // Quando perder o foco, formata o número e avisa o Firebase
    _focus.addListener(() {
      if (_focus.hasFocus) {
        // 🟢 Quando o teclado abrir, joga a tela para cima para revelar o campo!
        Future.delayed(const Duration(milliseconds: 300), () {
          if (_focus.context != null && mounted) {
            Scrollable.ensureVisible(
              _focus.context!,
              alignment: 0.4, // Tenta colocar o campo bem no meio da tela visível
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
            );
          }
        });
      } else {
        if (_ctrl.text.isNotEmpty) {
          final val = double.tryParse(_ctrl.text.replaceAll(',', '.'));
          if (val != null) {
            _ctrl.text = val.toStringAsFixed(2);
            widget.onSaved(val);
          }
        } else {
          widget.onSaved(null); // Apagou a nota
        }
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _ctrl,
      focusNode: _focus,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: widget.textStyle,
      decoration: InputDecoration(
        isDense: true, 
        contentPadding: EdgeInsets.zero, 
        border: InputBorder.none,
        hintText: '-.--', 
        hintStyle: widget.hintStyle,
      ),
    );
  }
}