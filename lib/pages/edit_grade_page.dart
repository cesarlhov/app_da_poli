// lib/views/edit_grade_page.dart

import 'dart:async';
import 'dart:math' as math;
import 'package:app_da_poli/models/disciplina_model.dart';
import 'package:app_da_poli/components/dotted_container.dart';
import 'package:flutter/gestures.dart'; 
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EditGradePage extends StatefulWidget {
  final List<Disciplina> initialDisciplinas;
  final Map<String, double> gradeMetrics;

  const EditGradePage({
    super.key,
    required this.initialDisciplinas,
    required this.gradeMetrics,
  });

  @override
  State<EditGradePage> createState() => _EditGradePageState();
}

class _EditGradePageState extends State<EditGradePage> with SingleTickerProviderStateMixin {
  late List<Disciplina> _disciplinas;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  Disciplina? _disciplinaPreview;
  Turma? _turmaPreview;
  bool _teveAlteracao = false;

  // =========================================================================
  // 🎛️ PAINEL DE CONTROLE - O MOTOR MATEMÁTICO DA GRADE
  // =========================================================================
  final double _distanciaTetoTela = 16.0; 
  final double _margemLateralExterna = 14.6; 
  final double _larguraMaximaParaTablets = 500.0; 

  // 🟢 A DISTÂNCIA INTOCÁVEL: As linhas das horas sempre terão esse tamanho
  final double _tamanhoLinhaHora = 38.0; 
  
  // 🟢 RESPIROS INTERNOS DA GRADE
  final double _espacoTopoAntesDo7 = 10.0; 
  final double _margemExtraFimGrade = 20.0; 

  // 🟢 A MOLA DA BUSCA: O quanto o painel de ferramentas sobe quando o teclado abre
  final double _ajusteSubidaTeclado = 200.0; 
  
  // 🟢 LIMITES DA SANFONA
  // O mínimo que a grade aceita ser esmagada quando o teclado sobe (para não sumir)
  final double _minAlturaDaGrade = 120.0; 
  // Limite da lista de pesquisa para ela não tentar devorar a tela toda
  final double _maxAlturaListaPesquisa = 130.0; 

  // =========================================================================
  // 🎛️ PAINEL DE CONTROLE - DESIGN DA GRADE E SETA VERMELHA
  // =========================================================================
  final double _espessuraBordaHero = 1.5;
  final double _raioBordaHero = 8.0;
  final Color _corBordaInicio = const Color(0xFF0460E9);
  final Color _corBordaFim = const Color(0xFF0D41A9);
  final Color _corFundoGrade = const Color(0xFFF0F0F0); 

  final double _paddingTopInterno = 12.0;
  final double _paddingLateralInterno = 12.0;
  final double _espacoTituloGrade = 2.0;
  final double _tamanhoTitulo = 19.0;
  final Color _corTitulo = const Color(0xFF0460E9);

  final double _tamanhoFonteDias = 19.0;  
  final double _tamanhoFonteHoras = 19.0; 
  final double _distanciaNumerosEsquerda = 8.0; 
  final double _larguraColunaHoras = 28.0; 
  final double _distanciaHoraLinha = 4.0;
  final double _ajusteVerticalLinhaHora = 8.5; 
  final double _espessuraLinhaHorizontal = 2.0; 
  final double _raioBordaLinha = 2.0; 
  final Color _corLinhaHorizontal = const Color(0xFFBFC5D1); 

  final double _distanciaSetaNumeros = 0.0; 
  final double _tamanhoSetaVermelha = 12.0; 
  final double _avancoLinhaVermelha = 3.0; 

  // =========================================================================
  // 🎛️ PAINEL DE CONTROLE - BOTÕES E BARRA INFERIOR
  // =========================================================================
  final Color _corFundoInput = const Color(0xFFF0F0F0); 
  final Color _corBordaInativa = const Color(0xFF848B97); 
  final Color _corBordaFocada = const Color(0xFF0460E9); 
  final Color _corTextoDigitado = const Color(0xFF5A5F62); 
  final Color _corDicaInput = const Color(0xFFBCBEBF); 
  
  final double _tamanhoTextoBotoes = 18.0; 
  final double _tamanhoTextoDicaBotoes = 18.0; 
  final double _tamanhoFonteAvisos = 13.0; 

  final double _alturaCaixaDisciplina = 50.0;
  final double _larguraCaixaUpload = 54.0; 
  final double _tamanhoIconeUpload = 26.0; 

  final double _alturaBarraInferior = 85.0; 
  final double _espessuraLinhaBarra = 3.0;  
  final Color _corLinhaBarra = const Color(0xFFBFC5D1); 
  
  final double _margemEsquerdaBarraInferior = 20.0;
  final double _margemDireitaBarraInferior = 20.0;
  final double _tamanhoTextoAjuda = 16.0;
  final double _tamanhoEstrelaAjuda = 30.0; 
  final Color _corEstrelaAjuda = const Color(0xFF0851CB); 
  
  final double _espacoBotaoAteReset = 16.0; 
  final double _tamanhoIconeReset = 28.0; 

  // =========================================================================
  // 🧠 ENGINE DE CASCATA E DEPENDÊNCIA (ESTADOS)
  // =========================================================================
  bool _isDisciplinaExpanded = false;
  final TextEditingController _buscaDiscCtrl = TextEditingController();
  final FocusNode _buscaFocus = FocusNode();

  final TextEditingController _instCtrl = TextEditingController();
  final TextEditingController _deptCtrl = TextEditingController();
  final TextEditingController _turmaCtrl = TextEditingController();

  final FocusNode _instFocus = FocusNode();
  final FocusNode _deptFocus = FocusNode();
  final FocusNode _turmaFocus = FocusNode();

  bool _isInstTyping = false;
  bool _isDeptTyping = false;
  bool _isTurmaTyping = false;

  FixedExtentScrollController _instScroll = FixedExtentScrollController();
  FixedExtentScrollController _deptScroll = FixedExtentScrollController();
  FixedExtentScrollController _turmaScroll = FixedExtentScrollController();

  final List<String> _masterInstitutos = ['POLI', 'IME', 'IF', 'IQ'];
  final Map<String, List<String>> _masterDeptos = {
    'POLI': ['PME', 'PQI', 'PCS', 'PTC', 'PMT', 'PMI', 'PMR', 'PNV', 'PHA', 'PCC', 'PEF', 'PTR', 'PEA', 'PRO'],
    'IME': ['MAC', 'MAT', 'MAE'],
    'IF': ['FAP', 'FGE'],
    'IQ': ['QBQ', 'QFL'],
  };

  late List<Disciplina> _mockDisciplinasList;

  Color _getColorForDepto(String dept) {
    switch (dept.toUpperCase()) {
      case 'PQI': case 'PEA': case 'PTC': case 'PSI': case 'PCS': return const Color(0xFF1F4AB7); 
      case 'PME': case 'PMR': case 'PMT': case 'PMI': return const Color(0xFF722F37); 
      case 'PNV': return const Color(0xFF1A1A1D); 
      case 'PHA': return const Color(0xFF6A0DAD); 
      case 'PCC': case 'PEF': case 'PTR': return const Color(0xFFE1AD01); 
      case 'PRO': return const Color(0xFF3E8E41); 
      case 'MAC': case 'MAT': case 'MAE': return const Color(0xFF008080); 
      case 'FAP': case 'FGE': return const Color(0xFF2E8B57); 
      case 'QBQ': case 'QFL': return const Color(0xFFD2691E); 
      default: return const Color(0xFF848B97); 
    }
  }

  @override
  void initState() {
    super.initState();
    _disciplinas = List.from(widget.initialDisciplinas);
    
    _mockDisciplinasList = [
      Disciplina(id: '1', codigo: 'PQI3305', nome: 'FENÔMENOS DE TRANSPORTE', instituto: 'POLI', departamento: 'PQI', ementa: '', isQuadrimestral: false, isEstagio: false, contaPresenca: true, avaliacoesAtivas: [], formulaFinal: '', avisosGerais: '', cor: _getColorForDepto('PQI'), turmas: [
        Turma(id: 't1', codigo: 'T10', professores: [], horarios: [HorarioAula(dia: 'TERÇA', inicio: '07:30', fim: '11:00', local: '', isLaboratorio: false, frequenciaLab: 0, datasCustomizadas: [], precisaEpi: false, epis: [])]),
      ]),
      Disciplina(id: '2', codigo: 'PME3100', nome: 'MECÂNICA DOS SÓLIDOS', instituto: 'POLI', departamento: 'PME', ementa: '', isQuadrimestral: false, isEstagio: false, contaPresenca: true, avaliacoesAtivas: [], formulaFinal: '', avisosGerais: '', cor: _getColorForDepto('PME'), turmas: [
        Turma(id: 't3', codigo: 'TA', professores: [], horarios: [HorarioAula(dia: 'QUINTA', inicio: '19:10', fim: '20:50', local: '', isLaboratorio: false, frequenciaLab: 0, datasCustomizadas: [], precisaEpi: false, epis: [])]),
      ]),
      Disciplina(id: '3', codigo: 'MAC0110', nome: 'INTRODUÇÃO À COMPUTAÇÃO', instituto: 'IME', departamento: 'MAC', ementa: '', isQuadrimestral: false, isEstagio: false, contaPresenca: true, avaliacoesAtivas: [], formulaFinal: '', avisosGerais: '', cor: _getColorForDepto('MAC'), turmas: [
        Turma(id: 't4', codigo: 'T45', professores: [], horarios: [HorarioAula(dia: 'SEXTA', inicio: '07:30', fim: '09:10', local: '', isLaboratorio: false, frequenciaLab: 0, datasCustomizadas: [], precisaEpi: false, epis: [])]),
      ]),
    ];

    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) _fadeController.forward(); });

    _instFocus.addListener(() {
      if (!_instFocus.hasFocus) {
        setState(() {
          _isInstTyping = false;
          _verificarEAtualizarRoleta(_instCtrl.text, _currInstitutos, (idx) { _instScroll.jumpToItem(idx); _aplicarCascataInst(_currInstitutos[idx]); }, () => _instCtrl.text = _currInstitutos.isNotEmpty ? _currInstitutos[_instScroll.selectedItem] : '');
        });
      }
    });

    _deptFocus.addListener(() {
      if (!_deptFocus.hasFocus) {
        setState(() {
          _isDeptTyping = false;
          _verificarEAtualizarRoleta(_deptCtrl.text, _currDeptos, (idx) { _deptScroll.jumpToItem(idx); _aplicarCascataDept(_currDeptos[idx]); }, () => _deptCtrl.text = _currDeptos.isNotEmpty ? _currDeptos[_deptScroll.selectedItem] : '');
        });
      }
    });

    _turmaFocus.addListener(() {
      if (!_turmaFocus.hasFocus) {
        setState(() {
          _isTurmaTyping = false;
          _verificarEAtualizarRoleta(_turmaCtrl.text, _currTurmasStr, (idx) { _turmaScroll.jumpToItem(idx); _aplicarCascataTurma(_currTurmasStr[idx]); }, () => _turmaCtrl.text = _currTurmasStr.isNotEmpty ? _currTurmasStr[_turmaScroll.selectedItem] : '');
        });
      }
    });
  }

  void _verificarEAtualizarRoleta(String typedText, List<String> list, Function(int) onSuccess, Function() onFail) {
    int index = list.indexWhere((item) => item.toUpperCase() == typedText.toUpperCase().trim());
    if (index != -1) { onSuccess(index); } else { onFail(); }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _instCtrl.dispose(); _deptCtrl.dispose(); _turmaCtrl.dispose(); _buscaDiscCtrl.dispose();
    _instFocus.dispose(); _deptFocus.dispose(); _turmaFocus.dispose(); _buscaFocus.dispose();
    _instScroll.dispose(); _deptScroll.dispose(); _turmaScroll.dispose();
    super.dispose();
  }

  Widget _safeImage(String assetPath, {double? width, double? height, Color? color}) {
    return Image.asset(
      assetPath, width: width, height: height, color: color,
      errorBuilder: (context, error, stackTrace) => SizedBox(width: width ?? 24, height: height ?? 24),
    );
  }

  List<String> get _currInstitutos => _masterInstitutos;
  List<String> get _currDeptos {
    if (_instCtrl.text.isNotEmpty && _masterDeptos.containsKey(_instCtrl.text)) return _masterDeptos[_instCtrl.text]!;
    return _masterDeptos.values.expand((e) => e).toList();
  }
  List<Disciplina> get _currDisciplinas {
    return _mockDisciplinasList.where((d) {
      bool matchInst = _instCtrl.text.isEmpty || d.instituto.toUpperCase() == _instCtrl.text.toUpperCase();
      bool matchDept = _deptCtrl.text.isEmpty || d.departamento.toUpperCase() == _deptCtrl.text.toUpperCase();
      bool matchBusca = _buscaDiscCtrl.text.isEmpty || d.nome.toLowerCase().contains(_buscaDiscCtrl.text.toLowerCase()) || d.codigo.toLowerCase().contains(_buscaDiscCtrl.text.toLowerCase());
      return matchInst && matchDept && matchBusca;
    }).toList();
  }
  List<String> get _currTurmasStr {
    if (_disciplinaPreview != null) return _disciplinaPreview!.turmas.map((t) => t.codigo).toList();
    return [];
  }

  void _marcarAlteracao() {
    if (!_teveAlteracao) setState(() => _teveAlteracao = true);
  }

  void _aplicarCascataInst(String inst) {
    if (_instCtrl.text == inst) return;
    _marcarAlteracao();
    _instCtrl.text = inst;
    _deptCtrl.clear();
    _disciplinaPreview = null; _turmaPreview = null; _turmaCtrl.clear();
    if (_deptScroll.hasClients) _deptScroll.jumpToItem(0);
    setState(() {});
  }

  void _aplicarCascataDept(String dept) {
    if (_deptCtrl.text == dept) return;
    _marcarAlteracao();
    _deptCtrl.text = dept;
    if (_instCtrl.text.isEmpty) {
      for (var entry in _masterDeptos.entries) {
        if (entry.value.contains(dept)) {
          _instCtrl.text = entry.key;
          if (_instScroll.hasClients) _instScroll.jumpToItem(_currInstitutos.indexOf(entry.key));
          break;
        }
      }
    }
    _disciplinaPreview = null; _turmaPreview = null; _turmaCtrl.clear();
    if (_turmaScroll.hasClients) _turmaScroll.jumpToItem(0);
    setState(() {});
  }

  void _selecionarDisciplinaDaLista(Disciplina d) {
    _marcarAlteracao();
    setState(() {
      _disciplinaPreview = d;
      _buscaDiscCtrl.clear();
      _isDisciplinaExpanded = false;
      FocusScope.of(context).unfocus(); 
      
      _instCtrl.text = d.instituto;
      _deptCtrl.text = d.departamento;
      
      if (d.turmas.isNotEmpty) {
        _turmaPreview = d.turmas.first;
        _turmaCtrl.text = d.turmas.first.codigo;
      } else {
        _turmaPreview = null; _turmaCtrl.clear();
      }

      if (_instScroll.hasClients && _currInstitutos.contains(d.instituto)) _instScroll.jumpToItem(_currInstitutos.indexOf(d.instituto));
      if (_deptScroll.hasClients && _currDeptos.contains(d.departamento)) _deptScroll.jumpToItem(_currDeptos.indexOf(d.departamento));
      if (_turmaScroll.hasClients && _currTurmasStr.isNotEmpty) _turmaScroll.jumpToItem(0);
    });
  }

  void _aplicarCascataTurma(String turmaCodigo) {
    if (_turmaCtrl.text == turmaCodigo) return;
    _marcarAlteracao();
    _turmaCtrl.text = turmaCodigo;
    if (_disciplinaPreview != null) {
      _turmaPreview = _disciplinaPreview!.turmas.firstWhere((t) => t.codigo == turmaCodigo, orElse: () => _disciplinaPreview!.turmas.first);
    }
    setState(() {});
  }

  bool _checkConflict(Turma tTarget) {
    for (var h1 in tTarget.horarios) {
      int s1 = _timeToMin(h1.inicio);
      int e1 = _timeToMin(h1.fim);
      for (var d in _disciplinas) {
        if (d.turmas.isEmpty) continue;
        for (var h2 in d.turmas.first.horarios) {
          if (h1.dia.toUpperCase() == h2.dia.toUpperCase()) {
            int s2 = _timeToMin(h2.inicio);
            int e2 = _timeToMin(h2.fim);
            if (math.max(s1, s2) < math.min(e1, e2)) return true;
          }
        }
      }
    }
    return false;
  }

  void _confirmarPreview() {
    if (_disciplinaPreview != null && _turmaPreview != null) {
      if (_checkConflict(_turmaPreview!)) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Conflito de Horário! Essa turma choca com outra já salva.', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red));
        return;
      }

      setState(() {
        _disciplinas.add(_disciplinaPreview!);
        _disciplinaPreview = null;
        _turmaPreview = null;
        _turmaCtrl.clear();
        _teveAlteracao = false; 
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sua nova grade foi salva com sucesso!')));
    }
  }
  
  void _resetarAlteracoes() {
    setState(() {
      _disciplinas = List.from(widget.initialDisciplinas); 
      _teveAlteracao = false; 
      _disciplinaPreview = null;
      _turmaPreview = null;
      _instCtrl.clear();
      _deptCtrl.clear();
      _turmaCtrl.clear();
      _isDisciplinaExpanded = false;
      FocusScope.of(context).unfocus();
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Edição desfeita. A grade voltou ao estado original.')));
  }

  int _timeToMin(String time) {
    if (time.isEmpty || !time.contains(':')) return 0;
    try {
      final parts = time.split(':');
      return int.parse(parts[0].trim()) * 60 + int.parse(parts[1].trim());
    } catch (e) { return 0; }
  }

  @override
  Widget build(BuildContext context) {
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    
    // 🟢 MATEMÁTICA PURA E BLINDADA
    // O teto máximo que a grade pode chegar para exibir as 11 linhas NATIVAMENTE
    final double _alturaMaximaDaGrade = (11 * _tamanhoLinhaHora) + 40.0 + _espacoTopoAntesDo7 + _margemExtraFimGrade;

    return Scaffold(
      backgroundColor: _corFundoGrade,
      resizeToAvoidBottomInset: false, 
      body: SafeArea(
        bottom: false, 
        child: Stack(
          children: [
            Positioned(
              top: 0, left: 0, right: 0,
              bottom: _alturaBarraInferior,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // 🟢 FLEXIBLE E CONSTRAINED BOX: 
                  // Isso resolve TODOS os bugs zebrados. A grade pode crescer no máximo o tamanho das 11 linhas.
                  // E se o teclado subir (ou as ferramentas crescerem), a grade ENCOLHE e vira rolável!
                  Flexible(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: _larguraMaximaParaTablets,
                        maxHeight: _alturaMaximaDaGrade, 
                        minHeight: _minAlturaDaGrade, // Não deixa a grade sumir totalmente
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(left: _margemLateralExterna, right: _margemLateralExterna, top: _distanciaTetoTela),
                        child: ClipRRect(
                          child: Hero(
                            tag: 'grade-hero',
                            child: Material(
                              type: MaterialType.transparency,
                              child: CustomPaint(
                                foregroundPainter: _GradientBorderPainter(
                                  strokeWidth: _espessuraBordaHero,
                                  radius: _raioBordaHero,
                                  gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [_corBordaInicio, _corBordaFim]),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(_raioBordaHero - (_espessuraBordaHero / 2)),
                                  child: Container(
                                    color: _corFundoGrade,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(top: _paddingTopInterno, left: _paddingLateralInterno, right: _paddingLateralInterno),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('GRADE HORÁRIA', style: TextStyle(fontFamily: 'Aristotelica', fontSize: _tamanhoTitulo, fontWeight: FontWeight.w700, color: _corTitulo)),
                                              Text('24 Č', style: TextStyle(fontFamily: 'Aristotelica', fontSize: _tamanhoTitulo, fontWeight: FontWeight.w700, color: _corTitulo)),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: _espacoTituloGrade),
                                        // 🟢 Expanded Interno para permitir a rolagem das linhas.
                                        Expanded(child: _buildGradeInternal()),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // FERRAMENTAS E TEXTOS INFERIORES
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildToolControls(),
                  ),

                  // 🟢 MOLA DO TECLADO: Substitui o Spacer e garante a subida com a altura precisa!
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    height: keyboardHeight > 0 ? _ajusteSubidaTeclado : 0.0,
                  )
                ],
              )
            ),

            Positioned(
              left: 0, right: 0, bottom: 0, height: _alturaBarraInferior,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: _buildBottomBar(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradeInternal() {
    final List<String> diasDaSemana = ['SEG', 'TER', 'QUA', 'QUI', 'SEX'];
    
    int calcMaxHour = 17; // 🟢 SEMPRE garante que vai renderizar até às 17h
    void analisarTempo(Turma t) {
      for (var h in t.horarios) {
        int fim = _timeToMin(h.fim);
        int horaCeil = (fim / 60).ceil();
        if (horaCeil > calcMaxHour) calcMaxHour = horaCeil;
      }
    }
    for (var d in _disciplinas) { if(d.turmas.isNotEmpty) analisarTempo(d.turmas.first); }
    if (_turmaPreview != null) analisarTempo(_turmaPreview!);

    final int horaInicio = 7;
    final int horaFim = calcMaxHour;
    
    final now = DateTime.now();
    double currentHourDecimal = now.hour + (now.minute / 60.0);
    bool isCurrentTimeVisible = currentHourDecimal >= horaInicio && currentHourDecimal <= horaFim + 1;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double topOffset = 40.0; 
        final double safeWidth = constraints.maxWidth.isInfinite ? MediaQuery.of(context).size.width : constraints.maxWidth;

        final double leftOffset = _distanciaNumerosEsquerda + _larguraColunaHoras + _distanciaHoraLinha;
        final double columnWidth = math.max(0.0, safeWidth - leftOffset - _paddingLateralInterno) / 5; 
        
        // 🟢 AS LINHAS NUNCA MUDAM DE TAMANHO MAIS! Elas são fixas em 38.0
        final double rowHeight = _tamanhoLinhaHora;
        final double totalGridHeight = (rowHeight * (horaFim - horaInicio + 1)) + _espacoTopoAntesDo7 + _margemExtraFimGrade;

        List<Widget> buildBlocosDasDisciplinas() {
          List<Widget> blocos = [];
          void posicionarBlocos(Disciplina d, Turma t, bool isPreview) {
            for (var hor in t.horarios) {
              int diaIndex = ['SEGUNDA', 'TERÇA', 'QUARTA', 'QUINTA', 'SEXTA'].indexOf(hor.dia.toUpperCase());
              if (diaIndex == -1) continue;

              int startMin = _timeToMin(hor.inicio);
              int endMin = _timeToMin(hor.fim);
              if (startMin == 0 || endMin == 0) continue;

              double top = _espacoTopoAntesDo7 + ((startMin - (horaInicio * 60)) / 60) * rowHeight;
              double height = ((endMin - startMin) / 60) * rowHeight;
              double left = leftOffset + (diaIndex * columnWidth);

              double blockWidth = columnWidth - 4; 
              double leftPos = left + 2;

              Widget box;
              if (isPreview) {
                bool isConflict = _checkConflict(t);
                Color dashColor = isConflict ? const Color(0xFFE04F44) : const Color(0xFF0460E9);

                box = DottedContainer(
                  color: dashColor.withOpacity(0.15), borderColor: dashColor, strokeWidth: 2.0, dashPattern: const [4, 4], borderRadius: BorderRadius.circular(6.0),
                  child: Center(child: Text(d.codigo, style: TextStyle(fontFamily: 'Aristotelica', fontWeight: FontWeight.w700, fontSize: 16, color: Colors.white, shadows: [Shadow(color: dashColor.withOpacity(0.8), blurRadius: 2)]))),
                );
              } else {
                box = Container(
                  decoration: BoxDecoration(color: d.cor, borderRadius: BorderRadius.circular(6.0)),
                  child: Center(child: Text(d.codigo, style: const TextStyle(fontFamily: 'Aristotelica', fontWeight: FontWeight.w700, fontSize: 16, color: Colors.white))),
                );
              }

              blocos.add(Positioned(top: top, left: leftPos, width: blockWidth, height: height, child: box));
            }
          }

          for (var d in _disciplinas) {
            if (d.turmas.isNotEmpty) posicionarBlocos(d, d.turmas.first, false);
          }
          if (_disciplinaPreview != null && _turmaPreview != null) {
            posicionarBlocos(_disciplinaPreview!, _turmaPreview!, true);
          }

          return blocos;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: topOffset,
              child: Row(
                children: [
                  SizedBox(width: leftOffset), 
                  ...diasDaSemana.map((dia) => SizedBox(
                        width: columnWidth,
                        child: Center(child: Text(dia, style: TextStyle(fontFamily: 'Aristotelica', fontWeight: FontWeight.w700, fontSize: _tamanhoFonteDias, color: const Color(0xFFBCBEBF)))),
                      )),
                ],
              ),
            ),
            
            Expanded(
              child: ShaderMask(
                shaderCallback: (Rect bounds) => const LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.white, Colors.white, Colors.transparent],
                  stops: [0.0, 0.05, 0.95, 1.0], 
                ).createShader(bounds),
                blendMode: BlendMode.dstIn,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: SizedBox(
                    height: totalGridHeight, // Essa altura interna controla o scroll!
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Column(
                          children: List.generate((horaFim - horaInicio + 1), (index) {
                            return Padding(
                              padding: EdgeInsets.only(top: index == 0 ? _espacoTopoAntesDo7 : 0.0),
                              child: SizedBox(
                                height: rowHeight,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start, 
                                  children: [
                                    SizedBox(width: _distanciaNumerosEsquerda), 
                                    SizedBox(
                                      width: _larguraColunaHoras,
                                      child: Text('${horaInicio + index}', style: TextStyle(fontFamily: 'Aristotelica', fontWeight: FontWeight.w700, fontSize: _tamanhoFonteHoras, color: const Color(0xFFBCBEBF), height: 1.0), textAlign: TextAlign.center),
                                    ),
                                    SizedBox(width: _distanciaHoraLinha),
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.only(top: _ajusteVerticalLinhaHora), 
                                        child: Container(height: _espessuraLinhaHorizontal, decoration: BoxDecoration(color: _corLinhaHorizontal, borderRadius: BorderRadius.circular(_raioBordaLinha))),
                                      )
                                    ),
                                    SizedBox(width: _paddingLateralInterno), 
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                        ...buildBlocosDasDisciplinas(),
                  
                        if (isCurrentTimeVisible)
                          Positioned(
                            top: _espacoTopoAntesDo7 + (currentHourDecimal - horaInicio) * rowHeight + _ajusteVerticalLinhaHora - (_tamanhoSetaVermelha/2), 
                            left: _distanciaNumerosEsquerda + _larguraColunaHoras + _distanciaSetaNumeros,
                            right: _paddingLateralInterno,
                            child: Row(
                              children: [
                                _safeImage('assets/images/setavermelha_icon.png', width: _tamanhoSetaVermelha, height: _tamanhoSetaVermelha),
                                Expanded(
                                  child: Transform.translate(
                                    offset: Offset(-_avancoLinhaVermelha, 0),
                                    child: Container(height: 1.5, color: const Color(0xFFD20A0A)),
                                  )
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // =========================================================================
  // 🟢 CONSTRUTORES DE WIDGETS INTERATIVOS
  // =========================================================================

  Widget _buildSearchableCasino({
    required String hint,
    required bool isTyping,
    required TextEditingController controller,
    required FocusNode focusNode,
    required List<String> items,
    required FixedExtentScrollController scrollController,
    required Function(int) onSelectedItemChanged,
    required VoidCallback onTap,
  }) {
    List<String> displayItems = items.isEmpty ? ['---'] : items;
    bool hasValue = controller.text.isNotEmpty;
    
    return GestureDetector(
      onTap: () { _marcarAlteracao(); onTap(); },
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: _corFundoInput,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: isTyping ? _corBordaFocada : (hasValue ? const Color(0xFFA1BF06) : _corBordaInativa), width: isTyping ? 2.0 : 1.5),
        ),
        child: isTyping
          ? TextField(
              controller: controller,
              focusNode: focusNode,
              autofocus: true,
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Aristotelica', fontWeight: FontWeight.w700, fontSize: _tamanhoTextoBotoes, color: _corTextoDigitado, height: 1.0),
              cursorColor: _corBordaFocada, cursorWidth: 2.5, cursorHeight: 18, cursorRadius: const Radius.circular(5.0),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(fontFamily: 'Aristotelica', color: _corDicaInput, fontSize: _tamanhoTextoDicaBotoes, height: 1.0),
                border: InputBorder.none, isDense: true, contentPadding: const EdgeInsets.only(top: 14.0),
              ),
              onChanged: (_) => _marcarAlteracao(),
              onSubmitted: (_) => focusNode.unfocus(),
            )
          : ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black, Colors.black, Colors.transparent],
                stops: [0.0, 0.15, 0.55, 1.0], 
              ).createShader(bounds),
              blendMode: BlendMode.dstIn,
              child: ListWheelScrollView.useDelegate(
                controller: scrollController,
                itemExtent: 30, physics: const FixedExtentScrollPhysics(), overAndUnderCenterOpacity: 1.0, 
                onSelectedItemChanged: (index) {
                  _marcarAlteracao();
                  if (items.isNotEmpty) onSelectedItemChanged(index);
                },
                childDelegate: ListWheelChildBuilderDelegate(
                  builder: (context, index) {
                    return Center(child: Text(displayItems[index], style: TextStyle(fontFamily: 'Aristotelica', fontWeight: FontWeight.w700, fontSize: hasValue ? _tamanhoTextoBotoes : _tamanhoTextoDicaBotoes, color: hasValue ? _corTextoDigitado : _corDicaInput, height: 1.0)));
                  },
                  childCount: displayItems.length, 
                ),
              ),
            ),
      ),
    );
  }

  Widget _buildDisciplinaDropdown() {
    bool isPreenchido = _disciplinaPreview != null;
    Color corUpload = (isPreenchido && _turmaPreview != null) ? const Color(0xFF0B46B4) : const Color(0xFFBCBEBF);
    List<Disciplina> results = _currDisciplinas;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      width: double.infinity,
      decoration: BoxDecoration(
        color: _corFundoInput,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: _isDisciplinaExpanded ? _corBordaFocada : (isPreenchido ? const Color(0xFFA1BF06) : _corBordaInativa),
          width: _isDisciplinaExpanded ? 2.0 : 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, 
        children: [
          SizedBox(
            height: _alturaCaixaDisciplina, 
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      _marcarAlteracao();
                      setState(() {
                        _isDisciplinaExpanded = !_isDisciplinaExpanded;
                        if (!_isDisciplinaExpanded) {
                           FocusScope.of(context).unfocus();
                        } else {
                           _buscaFocus.requestFocus(); 
                        }
                      });
                    },
                    child: Row(
                      children: [
                        const SizedBox(width: 12),
                        Icon(Icons.search, size: 22, color: _corDicaInput),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _isDisciplinaExpanded 
                            ? TextField(
                                controller: _buscaDiscCtrl,
                                focusNode: _buscaFocus,
                                autofocus: true,
                                style: TextStyle(fontFamily: 'Aristotelica', fontWeight: FontWeight.w700, fontSize: _tamanhoTextoBotoes, color: _corTextoDigitado, height: 1.0),
                                cursorColor: _corBordaFocada, cursorWidth: 2.5, cursorHeight: 18, cursorRadius: const Radius.circular(5.0),
                                decoration: InputDecoration(
                                  hintText: 'BUSCAR DISCIPLINA...',
                                  hintStyle: TextStyle(fontFamily: 'Aristotelica', color: _corDicaInput, fontSize: _tamanhoTextoDicaBotoes, height: 1.0),
                                  border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero,
                                ),
                                onChanged: (_) { _marcarAlteracao(); setState((){}); }, 
                                onSubmitted: (_) { FocusScope.of(context).unfocus(); },
                              )
                            : Text(
                                isPreenchido ? '${_disciplinaPreview!.codigo} - ${_disciplinaPreview!.nome}' : 'SELECIONE UMA DISCIPLINA',
                                style: TextStyle(
                                  fontFamily: 'Aristotelica', fontWeight: FontWeight.w700,
                                  fontSize: isPreenchido ? _tamanhoTextoBotoes : _tamanhoTextoDicaBotoes, 
                                  color: isPreenchido ? _corTextoDigitado : _corDicaInput,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: (isPreenchido && _turmaPreview != null) ? _confirmarPreview : null,
                  child: Container(
                    width: _larguraCaixaUpload,
                    decoration: BoxDecoration(
                      color: corUpload, 
                      borderRadius: BorderRadius.only(
                        topRight: const Radius.circular(6.5),
                        bottomRight: Radius.circular(_isDisciplinaExpanded ? 0.0 : 6.5)
                      )
                    ),
                    child: Center(
                      child: _safeImage('assets/images/upload_icon.png', color: Colors.white, width: _tamanhoIconeUpload, height: _tamanhoIconeUpload),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            firstCurve: Curves.easeOutCubic,
            secondCurve: Curves.easeOutCubic,
            sizeCurve: Curves.easeOutCubic,
            crossFadeState: _isDisciplinaExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            firstChild: const SizedBox(width: double.infinity, height: 0),
            secondChild: Column(
              children: [
                Container(height: 1.5, color: _corBordaInativa.withOpacity(0.3)), 
                Container(
                  constraints: BoxConstraints(maxHeight: _maxAlturaListaPesquisa), 
                  child: ShaderMask(
                    shaderCallback: (Rect bounds) => const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black, Colors.black, Colors.transparent], stops: [0.0, 0.05, 0.95, 1.0]).createShader(bounds),
                    blendMode: BlendMode.dstIn,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(), 
                      child: Column(
                        children: results.isEmpty 
                          ? [Padding(padding: const EdgeInsets.all(16.0), child: Text('NENHUMA ENCONTRADA', style: TextStyle(fontFamily: 'Aristotelica', fontWeight: FontWeight.w700, fontSize: _tamanhoTextoDicaBotoes, color: _corDicaInput)))]
                          : results.map((d) {
                            return GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => _selecionarDisciplinaDaLista(d),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 11),
                                decoration: BoxDecoration(border: d != results.last ? Border(bottom: BorderSide(color: _corBordaInativa.withOpacity(0.3), width: 1)) : null),
                                child: Text('${d.codigo} - ${d.nome}', style: TextStyle(fontFamily: 'Aristotelica', fontWeight: FontWeight.w700, fontSize: _tamanhoTextoBotoes, color: _corTextoDigitado)),
                              ),
                            );
                          }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolControls() {
    return Container(
      constraints: BoxConstraints(maxWidth: _larguraMaximaParaTablets),
      padding: EdgeInsets.only(left: _margemLateralExterna, right: _margemLateralExterna, top: 12, bottom: 12),
      child: Column(
        children: [
          _buildDisciplinaDropdown(),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4, 
                child: _buildSearchableCasino(
                  hint: 'INSTITUTO', isTyping: _isInstTyping, controller: _instCtrl, focusNode: _instFocus, items: _currInstitutos, scrollController: _instScroll,
                  onTap: () { _marcarAlteracao(); setState(() => _isInstTyping = true); _instFocus.requestFocus(); },
                  onSelectedItemChanged: (idx) { _aplicarCascataInst(_currInstitutos[idx]); },
                )
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 4, 
                child: _buildSearchableCasino(
                  hint: 'DEPTO', isTyping: _isDeptTyping, controller: _deptCtrl, focusNode: _deptFocus, items: _currDeptos, scrollController: _deptScroll,
                  onTap: () { _marcarAlteracao(); setState(() => _isDeptTyping = true); _deptFocus.requestFocus(); },
                  onSelectedItemChanged: (idx) { _aplicarCascataDept(_currDeptos[idx]); },
                )
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3, 
                child: _buildSearchableCasino(
                  hint: 'TURMA', isTyping: _isTurmaTyping, controller: _turmaCtrl, focusNode: _turmaFocus, items: _currTurmasStr, scrollController: _turmaScroll,
                  onTap: () { _marcarAlteracao(); setState(() => _isTurmaTyping = true); _turmaFocus.requestFocus(); },
                  onSelectedItemChanged: (idx) { _aplicarCascataTurma(_currTurmasStr[idx]); },
                )
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(fontFamily: 'Aristotelica', fontWeight: FontWeight.w700, fontSize: _tamanhoFonteAvisos, color: const Color(0xFFBCBEBF), height: 1.3),
                children: [
                  const TextSpan(text: 'O PERÍODO DE MATRÍCULA PELA WEB ESTÁ ENCERRADO.\n'),
                  const TextSpan(text: 'EM '),
                  TextSpan(
                    text: 'AVISOS',
                    style: const TextStyle(color: Color(0xFF517DDD), decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()..onTap = () {
                      context.push('/avisos');
                    },
                  ),
                  const TextSpan(text: ', VOCÊ ENCONTRA OS PERÍODOS DE MATRÍCULA,\nCONSOLIDAÇÃO E EXCLUSÃO DE DISCIPLINAS.'),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: _corFundoGrade,
        border: Border(top: BorderSide(color: _corLinhaBarra, width: _espessuraLinhaBarra)),
      ),
      child: SafeArea(
        top: false, 
        child: Container(
          height: _alturaBarraInferior,
          padding: EdgeInsets.only(left: _margemEsquerdaBarraInferior, right: _margemDireitaBarraInferior), 
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 95.0, height: 40.0,
                    child: GestureDetector(
                      onTap: () {
                        if (_teveAlteracao) {
                          setState(() => _teveAlteracao = false);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sua nova grade foi salva com sucesso!')));
                        } else {
                          context.pop();
                        }
                      },
                      child: Stack(
                        clipBehavior: Clip.none, alignment: Alignment.centerLeft,
                        children: [
                          Positioned(left: 0, child: _safeImage('assets/images/estrela_icon.png', height: 32, width: 32, color: const Color(0xFF0085FF))),
                          Positioned(
                            left: 15.0, right: 0, top: 0, bottom: 0,
                            child: Container(
                              decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF0460E9), Color(0xFF0D41A9)], begin: Alignment.centerLeft, end: Alignment.centerRight), borderRadius: BorderRadius.circular(6.7), border: Border.all(color: const Color(0xFF0085FF), width: 1.7)),
                              alignment: Alignment.center,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 3.0), 
                                child: Text(_teveAlteracao ? 'SALVAR' : 'VOLTAR', style: const TextStyle(fontFamily: 'Aristotelica', color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16, letterSpacing: 1.2))
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  if (_teveAlteracao) ...[
                    SizedBox(width: _espacoBotaoAteReset),
                    GestureDetector(
                      onTap: _resetarAlteracoes,
                      child: _safeImage('assets/images/desfazer_icon.png', width: _tamanhoIconeReset, height: _tamanhoIconeReset),
                    ),
                  ],
                ],
              ),

              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'QUER\nAJUDA?', 
                    textAlign: TextAlign.right, 
                    style: TextStyle(fontFamily: 'Aristotelica', color: const Color(0xFFBCBEBF), fontSize: _tamanhoTextoAjuda, fontWeight: FontWeight.w700, letterSpacing: 1.0, height: 1.0)
                  ),
                  const SizedBox(width: 8),
                  _safeImage('assets/images/estrela_icon.png', color: _corEstrelaAjuda, width: _tamanhoEstrelaAjuda, height: _tamanhoEstrelaAjuda),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class TrianglePainter extends CustomPainter {
  final Color color;
  TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = color..style = PaintingStyle.fill;
    var path = Path();
    path.moveTo(0, 0); 
    path.lineTo(size.width, size.height / 2); 
    path.lineTo(0, size.height); 
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GradientBorderPainter extends CustomPainter {
  final double strokeWidth;
  final double radius;
  final Gradient gradient;

  _GradientBorderPainter({required this.strokeWidth, required this.radius, required this.gradient});

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Rect.fromLTWH(strokeWidth / 2, strokeWidth / 2, size.width - strokeWidth, size.height - strokeWidth);
    final RRect rRect = RRect.fromRectAndRadius(rect, Radius.circular(radius - (strokeWidth / 2)));
    final Paint paint = Paint()..shader = gradient.createShader(rect)..strokeWidth = strokeWidth..style = PaintingStyle.stroke;
    canvas.drawRRect(rRect, paint);
  }

  @override
  bool shouldRepaint(covariant _GradientBorderPainter old) => old.strokeWidth != strokeWidth || old.radius != radius || old.gradient != gradient;
}