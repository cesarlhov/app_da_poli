// lib/pages/criar_disciplina_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CriarDisciplinaPage extends StatefulWidget {
  const CriarDisciplinaPage({super.key});

  @override
  State<CriarDisciplinaPage> createState() => _CriarDisciplinaPageState();
}

class _CriarDisciplinaPageState extends State<CriarDisciplinaPage> {

  // 📝 Estados para os Critérios de Avaliação Dinâmicos
  List<AvaliacaoData> _avaliacoes = [AvaliacaoData('P1', true),AvaliacaoData('P2', false), AvaliacaoData('T1', false),];
  bool _isAddingAvaliacao = false;
  final TextEditingController _newAvaliacaoCtrl = TextEditingController();
  final FocusNode _newAvaliacaoFocus = FocusNode();
  // =========================================================================
  // 🎛️ PAINEL DE CONTROLE - CORES E TIPOGRAFIA GERAL
  // =========================================================================
  final Color _corPrincipal = const Color(0xFF162038); 
  final Color _corDestaque = const Color(0xFF0460E9); 
  
  final Color _corFundoInput = Colors.white; 
  final Color _corLabel = const Color(0xFF6B7280); 
  final Color _corLixeira = const Color(0xFFE04F44); 

  final double _tamanhoTituloPrincipal = 15.5; 
  final double _tamanhoTituloSecao = 18.0; 
  final double _tamanhoTextoLabel = 18.0; 

  // =========================================================================
  // 🎛️ PAINEL DE CONTROLE - DESIGN DAS CAIXAS DE TEXTO E GEOMETRIA
  // =========================================================================
  final double _tamanhoFonteDigitada = 19.0; 
  final double _tamanhoFonteDica = 19.0; 
  final Color _corBordaInativa = const Color(0xFF848B97); 
  final Color _corBordaFocada = const Color(0xFF0460E9); 
  final Color _corTextoDigitado = const Color(0xFF5A5F62); 
  final Color _corDicaInput = const Color(0xFFBCBEBF); 

  final double _paddingLateralTela = 14.0; 
  final double _raioBordaCaixaPrincipal = 6.0; 
  
  final double _espacoAcimaDisciplina = 13.0; 
  final double _espacoDisciplinaAtePrimeiraSecao = 6.0; 
  final double _espacoEntreSecoes = 14.0; 
  final double _espacoSecaoAteCaixa = 4.0; 
  
  final double _paddingTopCaixaPrincipal = 18.0; 
  final double _paddingBottomCaixaPrincipal = 16.0;
  final double _paddingLateralCaixaPrincipal = 22.0; 
  
  final double _espacoTituloAteInput = 0.0; 
  final double _espacoInputAteProximoTitulo = 7.0; 
  final double _espacoInputAteToggle = 16.0; 
  final double _espacoToggleAteTexto = 12.0; 
  
  final double _tamanhoFadeTopoLista = 20.0; 
  final double _paddingTopoListaDropdown = 0.0; 

  final double _larguraCaixaAvaliacaoNova = 60.0; // Ajuste o valor aqui para deixar menor ou maior

  final double _espacoAbaixoSalvar = 24.0; // 🟢 Controla o espaço abaixo do botão Salvar Disciplina (diminua ou aumente aqui)

  // =========================================================================
  // 🎛️ PAINEL DE CONTROLE - ESPAÇAMENTOS (LOGÍSTICA) E ÍCONES
  // =========================================================================
  final double _espacoTopoDiaLogistica = 5.0; 
  final double _espacoDiaInicioLogistica = 0.0; 
  final double _espacoInicioFimLogistica = 0.0; 
  
  final double _larguraCaixaEpiNova = 150.0; 
  final double _tamanhoTextoEpiNovo = 19.0; 
  final double _deslocamentoVerticalEpiNovo = 0.0; 

  final double _tamanhoIconeSeta = 20.0;
  final double _espacoSetaTexto = 8.0;
  final double _tamanhoIconeLixeira = 26.0;
  final double _espacoLixeiraCaixa = 12.0;
  final double _tamanhoIconeX = 20.0;
  final double _tamanhoNovaTurma = 16.0;
  
  final double _espacoLocalAteAdd = 8.0; 

  // =========================================================================
  // 🎛️ PAINEL DE CONTROLE - FINAL DA TELA E BOTÃO SALVAR
  // =========================================================================
  final double _espacoCaixaAteAvisos = 16.0; 
  final double _espacoAvisosAteSalvar = 16.0; 
  final double _alturaBotaoSalvar = 40.0; 

  // =========================================================================
  // 🎛️ PAINEL DE CONTROLE - TOGGLE (Botão de Ativar)
  // =========================================================================
  final double _larguraToggle = 58.0;
  final double _alturaToggle = 32.0;
  final double _tamanhoBolinhaToggle = 20.0;
  final double _paddingInternoToggle = 5.0; 
  final Color _corFundoToggleInativo = const Color(0xFFF5F5F7); 
  final double _deslocamentoVerticalTextoToggle = 1.5; 

  // =========================================================================
  // 🎛️ PAINEL DE CONTROLE - FOOTER E BOTÕES
  // =========================================================================
  final double _alturaBotoes = 40.0; 
  final double _larguraTotalVoltar = 95.0; 
  final double _tamanhoEstrela = 32.0; 
  final double _avancoBotaoVoltar = 15.0; 
  
  final double _alturaFooter = 85.0; 
  final double _espessuraLinhaFooter = 3.0; 
  final double _paddingLateralFooter = 20.0; 
  final double _espacoTextoDesfazer = 8.0; 

  // Estados Globais
  bool _isQuadrimestral = false;
  bool _isEstagio = false;
  bool _contaPresenca = true;

  bool _isDeptExpanded = false;
  bool _isInstitutoExpanded = false;
  // 🟢 NOMES POR EXTENSO!
  final List<String> _institutos = [
    'POLI - Escola Politécnica', 
    'IME - Inst. de Matemática e Estatística', 
    'IF - Instituto de Física', 
    'IQ - Instituto de Química', 
    'ICG - Instituto de Geociências'
  ];
  
  // 🟢 AS CHAVES DO DICIONÁRIO AGORA ACOMPANHAM O NOME POR EXTENSO
  final Map<String, List<String>> _bancoDeDepartamentos = {
    'POLI - Escola Politécnica': [
        'PCC - Eng. de Construção Civil',
        'PCS - Eng. de Computação e Sistemas Digitais',
        'PEA - Eng. de Energia e Automação Elétricas',
        'PEF - Eng. de Estruturas e Geotécnica',
        'PHA - Eng. Hidráulica e Ambiental',
        'PME - Eng. Mecânica',
        'PMI - Eng. de Minas e de Petróleo',
        'PMR - Eng. Mecatrônica e Sistemas Mecânicos',
        'PMT - Eng. Metalúrgica e de Materiais',
        'PNV - Eng. Naval e Oceânica',
        'PQI - Eng. Química',
        'PRO - Eng. de Produção',
        'PSI - Eng. de Sistemas Eletrônicos',
        'PTC - Eng. de Telecomunicações e Controle',
        'PTR - Eng. de Transportes'
    ],
    'IME - Inst. de Matemática e Estatística': [
        'MAC - Ciência da Computação',
        'MAE - Estatística',
        'MAP - Matemática Aplicada',
        'MAT - Matemática'
    ],
    'IF - Instituto de Física': [
        'FAP - Física Aplicada',
        'FEP - Física Experimental',
        'FGE - Física Geral',
        'FMA - Física Matemática',
        'FMT - Física de Materiais e Mecânica',
        'FNC - Física Nuclear'
    ],
    'IQ - Instituto de Química': [
        'QBQ - Bioquímica',
        'QFL - Química Fundamental'
    ],
    'IGc - Instituto de Geociências': [
        'GAA - Geologia Ambiental e Aplicada',
        'GMG - Mineralogia e Geotectônica'
    ]
  };

  // Estados Especiais: Roleta de Cassino (Créditos)
  bool _isCreditoTyping = false;
  int _creditoValue = 1;
  late FixedExtentScrollController _creditoScrollController;
  
  final ScrollController _mainScrollController = ScrollController();

  // =========================================================================
  // 📝 CONTROLADORES ESTÁTICOS
  // =========================================================================
  final _codigoController = TextEditingController(); final _codigoFocus = FocusNode();
  final _nomeController = TextEditingController(); final _nomeFocus = FocusNode();
  final _institutoController = TextEditingController(); final _institutoFocus = FocusNode();
  final _creditoController = TextEditingController(); final _creditoFocus = FocusNode();
  final _departamentoController = TextEditingController(); final _departamentoFocus = FocusNode();
  final _ementaController = TextEditingController(); final _ementaFocus = FocusNode();
  
  // 🟢 FÓRMULA ÚNICA (Sem texto pré-preenchido, apenas sugestão/hint)
  final _formulaController = TextEditingController(); final _formulaFocus = FocusNode();
  final _avisosController = TextEditingController(); final _avisosFocus = FocusNode();

  // 🟢 CONTROLADORES DINÂMICOS DAS TURMAS
  List<TurmaInputData> _turmas = [];

  void _atualizarTela() {
    if (mounted) setState(() {});
  }

  void _resetarTudo() {
    setState(() {
      _codigoController.clear();
      _nomeController.clear();
      _institutoController.clear();
      _departamentoController.clear();
      _ementaController.clear();
      _formulaController.clear(); 
      _avisosController.clear();
      
      _isQuadrimestral = false;
      _isEstagio = false; 
      _contaPresenca = false;
      _isDeptExpanded = false;
      _isInstitutoExpanded = false; 
      
      _isAddingAvaliacao = false;
      _avaliacoes = [
        AvaliacaoData('P1', true),
        AvaliacaoData('P2', false),
        AvaliacaoData('T1', false),
      ];
      
      for (var t in _turmas) { t.dispose(); }
      _turmas.clear();
      
      var turmaMestra = TurmaInputData(onUpdate: _atualizarTela);
      turmaMestra.iniciarListeners();
      _turmas.add(turmaMestra);
    });
  }

  @override
  void initState() {
    super.initState();

    _turmas.add(TurmaInputData(onUpdate: _atualizarTela));

    _newAvaliacaoFocus.addListener(() {
      if (_newAvaliacaoFocus.hasFocus) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (_newAvaliacaoFocus.context != null) {
            Scrollable.ensureVisible(_newAvaliacaoFocus.context!, alignment: 0.3, duration: const Duration(milliseconds: 300), curve: Curves.easeOutCubic);
          }
        });
      } else {
        if (_newAvaliacaoCtrl.text.trim().isNotEmpty) {
          setState(() {
            _avaliacoes.add(AvaliacaoData(_newAvaliacaoCtrl.text.trim().toUpperCase(), true, isCustom: true));
          });
        }
        _newAvaliacaoCtrl.clear();
        setState(() => _isAddingAvaliacao = false);
      }
    });

    // 🟢 Tiramos o foco de Crédito, Instituto e Departamento daqui
    final todosFocosEstaticos = [_codigoFocus, _nomeFocus, _ementaFocus, _formulaFocus, _avisosFocus];
    
    for (var foco in todosFocosEstaticos) {
      foco.addListener(() {
        if (foco.hasFocus) {
          Future.delayed(const Duration(milliseconds: 300), () {
            if (foco.context != null) {
              Scrollable.ensureVisible(foco.context!, alignment: 0.3, duration: const Duration(milliseconds: 300), curve: Curves.easeOutCubic);
            }
          });
        }
        _atualizarTela();
      });
    }
  }

  @override
  void dispose() {
    _mainScrollController.dispose();
    _codigoController.dispose();
    _nomeController.dispose();
    _institutoController.dispose();
    _departamentoController.dispose();
    _ementaController.dispose();
    _formulaController.dispose();
    _avisosController.dispose();
    
    _codigoFocus.dispose();
    _nomeFocus.dispose();
    _institutoFocus.dispose();
    _departamentoFocus.dispose();
    _ementaFocus.dispose();
    _formulaFocus.dispose();
    _avisosFocus.dispose();

    _newAvaliacaoCtrl.dispose();
    _newAvaliacaoFocus.dispose();

    for (var t in _turmas) { t.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false, 
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            SizedBox(height: _espacoAcimaDisciplina),
            Text('DISCIPLINA', style: TextStyle(fontFamily: 'MonumentExtended', fontSize: _tamanhoTituloPrincipal, fontWeight: FontWeight.w900, color: _corPrincipal)),
            SizedBox(height: _espacoDisciplinaAtePrimeiraSecao),
            
            Expanded(
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: const [Colors.transparent, Colors.black, Colors.black],
                    stops: [0.0, bounds.height > 0 ? (_tamanhoFadeTopoLista / bounds.height).clamp(0.0, 1.0) : 0.0, 1.0], 
                  ).createShader(bounds);
                },
                blendMode: BlendMode.dstIn,
                child: GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(), 
                  child: SingleChildScrollView(
                    controller: _mainScrollController, 
                    padding: EdgeInsets.only(
                        left: _paddingLateralTela, right: _paddingLateralTela, 
                        top: 10.0, 
                        // 🟢 Substituído pelos valores controlados (antes era 100.0 fixo)
                        bottom: keyboardHeight > 0 ? keyboardHeight + 40.0 : _espacoAbaixoSalvar,
                      ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildSectionInformacoesGerais(),
                        SizedBox(height: _espacoEntreSecoes),
                        _buildSectionTurmasHorarios(),
                        SizedBox(height: _espacoEntreSecoes),
                        _buildSectionLogisticaLaboratorio(),
                        SizedBox(height: _espacoEntreSecoes),
                        _buildSectionCriteriosAvaliacao(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            _buildFooterBar(context),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // 🧩 CONSTRUTORES DE SEÇÃO
  // =========================================================================

  Widget _buildSectionInformacoesGerais() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('INFORMAÇÕES GERAIS'),
        _buildOutlinedBox(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('CÓDIGO DA DISCIPLINA'),
              _buildRealTextField(hint: 'EX: GP2601', controller: _codigoController, focusNode: _codigoFocus, nextFocus: _nomeFocus),
              SizedBox(height: _espacoInputAteProximoTitulo),
              
              _buildLabel('NOME DA DISCIPLINA'),
              _buildRealTextField(hint: 'EX: FENÔMENOS PARANORMAIS', controller: _nomeController, focusNode: _nomeFocus),
              SizedBox(height: _espacoInputAteProximoTitulo),
              
              // 🟢 CRÉDITOS REMOVIDOS. INSTITUTO ESTICA DE PONTA A PONTA!
              _buildLabel('INSTITUTO'),
              _buildInstitutoDropdown(), 
              SizedBox(height: _espacoInputAteProximoTitulo),

              _buildLabel('DEPARTAMENTO'),
              _buildDepartamentoDropdown(), 
              SizedBox(height: _espacoInputAteProximoTitulo),

              _buildLabel('EMENTA'),
              _buildRealTextField(hint: 'COPIE E COLE DO JÚPITER', controller: _ementaController, focusNode: _ementaFocus, minLines: 3, maxLines: 5),
              SizedBox(height: _espacoInputAteToggle),

              Row(
                children: [
                  _buildToggle(valor: _isQuadrimestral, onChanged: (v) => setState(() => _isQuadrimestral = v)),
                  SizedBox(width: _espacoToggleAteTexto),
                  Transform.translate(
                    offset: Offset(0, _deslocamentoVerticalTextoToggle),
                    child: Text('É QUADRIMESTRAL', style: TextStyle(fontFamily: 'Aristotelica', fontSize: _tamanhoFonteDigitada, fontWeight: FontWeight.w700, color: _corLabel, height: 1.0)),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildToggle(valor: _isEstagio, onChanged: (v) => setState(() => _isEstagio = v)),
                  SizedBox(width: _espacoToggleAteTexto),
                  Transform.translate(
                    offset: Offset(0, _deslocamentoVerticalTextoToggle),
                    child: Text('DISCIPLINA DE ESTÁGIO', style: TextStyle(fontFamily: 'Aristotelica', fontSize: _tamanhoFonteDigitada, fontWeight: FontWeight.w700, color: _corLabel, height: 1.0)),
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTurmasHorarios() {
    return Opacity(
      opacity: _isEstagio ? 0.3 : 1.0, 
      child: IgnorePointer(
        ignoring: _isEstagio, 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionTitle('TURMAS & HORÁRIOS', marginBottom: _espacoSecaoAteCaixa),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      var novaTurma = TurmaInputData(onUpdate: _atualizarTela);
                      novaTurma.iniciarListeners(); 
                      _turmas.add(novaTurma);
                    });
                  },
                  child: Text('+ NOVA TURMA', style: TextStyle(fontFamily: 'Aristotelica', fontWeight: FontWeight.w700, fontSize: _tamanhoNovaTurma, color: const Color(0xFF969AA0))),
                ),
              ],
            ),
            
            ..._turmas.asMap().entries.map((entry) {
              int indexTurma = entry.key;
              TurmaInputData turma = entry.value;
              bool isLast = indexTurma == _turmas.length - 1; 

              return Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0.0 : _espacoEntreSecoes),
                child: _buildOutlinedBox(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(turma.getDisplayTitle(indexTurma), style: TextStyle(fontFamily: 'LeagueSpartan', fontWeight: FontWeight.w800, fontSize: 16, color: _corLabel)),
                              Text('${turma.professores.length} PROFESSORES ~ ${turma.horarios.length} HORÁRIOS', style: TextStyle(fontFamily: 'Lato', fontSize: 12, color: _corDicaInput)),
                            ],
                          ),
                          if (_turmas.length > 1)
                            GestureDetector(
                              onTap: () {
                                setState(() { turma.dispose(); _turmas.removeAt(indexTurma); });
                              },
                              child: Image.asset('assets/images/x_icon.png', width: _tamanhoIconeX, height: _tamanhoIconeX, color: _corDicaInput),
                            ),
                        ],
                      ),
                      SizedBox(height: _espacoInputAteProximoTitulo),

                      _buildLabel('CÓDIGO DE TURMA'),
                      _buildRealTextField(
                        hint: 'EX: 2026101', 
                        controller: turma.codigoCtrl, 
                        focusNode: turma.codigoFocus, 
                        nextFocus: turma.professores.isNotEmpty ? turma.professores.first.nomeFocus : null, 
                        onChanged: (_) => _atualizarTela()
                      ), 
                      SizedBox(height: _espacoInputAteProximoTitulo),

                      _buildLabel('PROFESSOR'),
                      ...turma.professores.asMap().entries.map((eProf) {
                        int pIndex = eProf.key;
                        ProfessorInputData prof = eProf.value;
                        
                        FocusNode? nextFocus;
                        if (pIndex < turma.professores.length - 1) {
                          nextFocus = turma.professores[pIndex + 1].nomeFocus;
                        } else if (turma.horarios.isNotEmpty) {
                          nextFocus = turma.horarios.first.salaFocus; 
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              Expanded(child: _buildRealTextField(hint: 'NOME DO PROFESSOR', controller: prof.nomeCtrl, focusNode: prof.nomeFocus, nextFocus: nextFocus)),
                              if (turma.professores.length > 1) ...[
                                SizedBox(width: _espacoLixeiraCaixa),
                                GestureDetector(
                                  onTap: () => setState(() { prof.dispose(); turma.professores.removeAt(pIndex); }),
                                  child: Image.asset('assets/images/lixeira_icon.png', width: _tamanhoIconeLixeira, height: _tamanhoIconeLixeira, color: _corLixeira),
                                )
                              ]
                            ],
                          ),
                        );
                      }),
                      _buildNovoBotaoAcao('+ ADD', () => setState(() {
                        var novoProf = ProfessorInputData(onUpdate: _atualizarTela);
                        novoProf.iniciarListeners(); 
                        turma.professores.add(novoProf);
                      })),
                      SizedBox(height: _espacoInputAteProximoTitulo),

                      _buildLabel('HORÁRIOS & LOCAIS'),
                      ...turma.horarios.asMap().entries.map((eHor) {
                        int hIndex = eHor.key;
                        HorarioInputData hor = eHor.value;
                        return Padding(
                          padding: EdgeInsets.only(bottom: _espacoLocalAteAdd),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(child: _buildDiaCasinoWidget(hor)),
                                  const SizedBox(width: 8),
                                  Expanded(child: _buildTimeCasinoWidget(hor, false)),
                                  const SizedBox(width: 8),
                                  Expanded(child: _buildTimeCasinoWidget(hor, true)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(child: _buildRealTextField(hint: 'SALA / LOCAL', controller: hor.salaCtrl, focusNode: hor.salaFocus)),
                                  if (turma.horarios.length > 1) ...[
                                    SizedBox(width: _espacoLixeiraCaixa),
                                    GestureDetector(
                                      onTap: () => setState(() { hor.dispose(); turma.horarios.removeAt(hIndex); }),
                                      child: Image.asset('assets/images/lixeira_icon.png', width: _tamanhoIconeLixeira, height: _tamanhoIconeLixeira, color: _corLixeira),
                                    )
                                  ]
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                      _buildNovoBotaoAcao('+ ADD', () => setState(() {
                        var novoHor = HorarioInputData(onUpdate: _atualizarTela);
                        novoHor.iniciarListeners(); 
                        turma.horarios.add(novoHor);
                      })),
                      SizedBox(height: _espacoInputAteProximoTitulo),
                      
                      _buildNovoBotaoAcao('GERENCIAR EXCEÇÕES', () {}, expandir: true),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    ); // 🟢 Fechamentos corrigidos!
  }

  Widget _buildSectionLogisticaLaboratorio() {
    return Opacity(
      opacity: _isEstagio ? 0.3 : 1.0, 
      child: IgnorePointer(
        ignoring: _isEstagio, 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('LOGÍSTICA & LABORATÓRIO'),
            
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(_raioBordaCaixaPrincipal),
                border: Border.all(color: _corDestaque, width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: _paddingTopCaixaPrincipal, left: _paddingLateralCaixaPrincipal, right: _paddingLateralCaixaPrincipal, bottom: _paddingBottomCaixaPrincipal),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('CONTA PRESENÇA', marginBottom: 2),
                            Text('O MEC EXIGE 70% DE PRESENÇA', style: TextStyle(fontFamily: 'Lato', fontSize: 11, color: _corDicaInput)),
                          ],
                        ),
                        _buildToggle(valor: _contaPresenca, onChanged: (v) => setState(() => _contaPresenca = v)),
                      ],
                    ),
                  ),

                  Container(height: 1.5, color: _corDestaque, width: double.infinity),
                  
                  Padding(
                    padding: EdgeInsets.only(top: _paddingTopCaixaPrincipal, left: _paddingLateralCaixaPrincipal, right: _paddingLateralCaixaPrincipal, bottom: _paddingBottomCaixaPrincipal),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('CONFIGURAÇÕES DE LABORATÓRIO', marginBottom: 2),
                        Text('SELECIONE ABAIXO QUAIS DIAS SÃO DE\nLABORATÓRIO E O QUE PRECISA LEVAR', style: TextStyle(fontFamily: 'Lato', fontSize: 11, color: _corDicaInput, height: 1.2)),
                        SizedBox(height: _espacoInputAteProximoTitulo),

                        ..._turmas.asMap().entries.map((entry) {
                          int tIndex = entry.key;
                          TurmaInputData turma = entry.value;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: () => setState(() => turma.isLogisticaExpanded = !turma.isLogisticaExpanded),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Row(
                                    children: [
                                      Transform.rotate(
                                        angle: turma.isLogisticaExpanded ? 3.14159 : 0,
                                        child: Image.asset('assets/images/seta_icon.png', width: _tamanhoIconeSeta, height: _tamanhoIconeSeta, color: _corLabel),
                                      ),
                                      SizedBox(width: _espacoSetaTexto),
                                      Text(turma.getDisplayTitle(tIndex), style: TextStyle(fontFamily: 'LeagueSpartan', fontWeight: FontWeight.w800, fontSize: _tamanhoTextoLabel, color: _corLabel)),
                                    ],
                                  ),
                                ),
                              ),
                              
                              AnimatedCrossFade(
                                duration: const Duration(milliseconds: 300),
                                firstCurve: Curves.easeOutCubic,
                                secondCurve: Curves.easeOutCubic,
                                sizeCurve: Curves.easeOutCubic,
                                alignment: Alignment.topCenter,
                                crossFadeState: turma.isLogisticaExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                                firstChild: const SizedBox(width: double.infinity, height: 0),
                                secondChild: Container(
                                  width: double.infinity,
                                  child: Column(
                                    children: turma.horarios.map((hor) {
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
                                        child: Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: _corFundoInput, 
                                            borderRadius: BorderRadius.circular(_raioBordaCaixaPrincipal),
                                            border: Border.all(color: _corBordaInativa, width: 1.5),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start, 
                                            children: [
                                              Text(
                                                '${hor.diaCtrl.text}   ${hor.inicioCtrl.text} - ${hor.fimCtrl.text}', 
                                                style: const TextStyle(fontFamily: 'Aristotelica', fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF969AA0))
                                              ),
                                              const SizedBox(height: 14),

                                              Row(
                                                children: [
                                                  _buildToggle(
                                                    valor: hor.isLaboratorio, 
                                                    onChanged: (v) {
                                                      setState(() {
                                                        hor.isLaboratorio = v;
                                                        if (!v) hor.precisaEpi = false; 
                                                      });
                                                    }
                                                  ),
                                                  SizedBox(width: _espacoToggleAteTexto),
                                                  Transform.translate(
                                                    offset: Offset(0, _deslocamentoVerticalTextoToggle),
                                                    child: Text('É LABORATÓRIO?', style: TextStyle(fontFamily: 'Aristotelica', fontSize: _tamanhoFonteDigitada, fontWeight: FontWeight.w700, color: _corLabel.withOpacity(hor.isLaboratorio ? 1.0 : 0.5), height: 1.0)),
                                                  ),
                                                ],
                                              ),
                                              
                                              AnimatedCrossFade(
                                                duration: const Duration(milliseconds: 300),
                                                firstCurve: Curves.easeOutCubic,
                                                secondCurve: Curves.easeOutCubic,
                                                sizeCurve: Curves.easeOutCubic,
                                                alignment: Alignment.topCenter,
                                                crossFadeState: hor.isLaboratorio ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                                                firstChild: const SizedBox(width: double.infinity, height: 0),
                                                secondChild: Container(
                                                  width: double.infinity,
                                                  padding: const EdgeInsets.only(top: 14.0),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      _buildFrequenciaSelector(hor),
                                                      
                                                      if (hor.frequenciaLab == 1 || hor.frequenciaLab == 2)
                                                        Padding(
                                                          padding: const EdgeInsets.only(top: 8.0, left: 2.0),
                                                          child: Text(
                                                            hor.frequenciaLab == 1
                                                              ? 'Aulas a cada 15 dias iniciando a partir da 1ª ${hor.diaCtrl.text.toUpperCase()} disponível.\nToque em QUINZENAL 1 novamente para alternar.'
                                                              : 'Aulas a cada 15 dias iniciando a partir da 2ª ${hor.diaCtrl.text.toUpperCase()} disponível.\nToque em QUINZENAL 2 novamente para alternar.',
                                                            style: TextStyle(fontFamily: 'Lato', fontSize: 11, color: _corDicaInput, height: 1.2),
                                                          ),
                                                        )
                                                      else if (hor.frequenciaLab == 3)
                                                        Padding(
                                                          padding: const EdgeInsets.only(top: 14.0),
                                                          child: Wrap(
                                                            spacing: 8, runSpacing: 8,
                                                            children: hor.obterDatasSemestre().map((d) {
                                                              bool ativo = hor.datasSelecionadas.contains(d);
                                                              String texto = '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
                                                              return GestureDetector(
                                                                onTap: () {
                                                                  setState(() {
                                                                    if (ativo) hor.datasSelecionadas.remove(d);
                                                                    else hor.datasSelecionadas.add(d);
                                                                  });
                                                                },
                                                                // 🟢 MÁGICA: Borda e gradiente iguais aos botões de EPI!
                                                                child: AnimatedContainer(
                                                                  duration: const Duration(milliseconds: 200),
                                                                  width: 58, 
                                                                  height: 40,
                                                                  alignment: Alignment.center,
                                                                  decoration: BoxDecoration(
                                                                    gradient: ativo 
                                                                      ? const LinearGradient(colors: [Color(0xFF0460E9), Color(0xFF0D41A9)], begin: Alignment.centerLeft, end: Alignment.centerRight)
                                                                      : null,
                                                                    color: ativo ? null : _corFundoInput,
                                                                    border: Border.all(
                                                                      color: ativo ? const Color(0xFF0085FF) : _corBordaInativa, 
                                                                      width: ativo ? 1.7 : 1.5
                                                                    ),
                                                                    borderRadius: BorderRadius.circular(6.7)
                                                                  ),
                                                                  child: Text(texto, style: TextStyle(fontFamily: 'Aristotelica', fontWeight: FontWeight.w700, color: ativo ? Colors.white : _corTextoDigitado, fontSize: 13)),
                                                                )
                                                              );
                                                            }).toList(),
                                                          ),
                                                        )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              
                                              const SizedBox(height: 14),
                                              Row(
                                                children: [
                                                  _buildToggle(
                                                    valor: hor.precisaEpi, 
                                                    isEnabled: hor.isLaboratorio, 
                                                    onChanged: (v) => setState(() => hor.precisaEpi = v)
                                                  ),
                                                  SizedBox(width: _espacoToggleAteTexto),
                                                  Transform.translate(
                                                    offset: Offset(0, _deslocamentoVerticalTextoToggle),
                                                    child: Text('PRECISA DE EPIS?', style: TextStyle(fontFamily: 'Aristotelica', fontSize: _tamanhoFonteDigitada, fontWeight: FontWeight.w700, color: _corLabel.withOpacity(hor.isLaboratorio ? (hor.precisaEpi ? 1.0 : 0.5) : 0.3), height: 1.0)),
                                                  ),
                                                ],
                                              ),
                                              
                                              AnimatedCrossFade(
                                                duration: const Duration(milliseconds: 300),
                                                firstCurve: Curves.easeOutCubic,
                                                secondCurve: Curves.easeOutCubic,
                                                sizeCurve: Curves.easeOutCubic,
                                                alignment: Alignment.topCenter,
                                                crossFadeState: hor.precisaEpi ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                                                firstChild: const SizedBox(width: double.infinity, height: 0),
                                                secondChild: Container(
                                                  width: double.infinity,
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      const SizedBox(height: 16),
                                                      Wrap(
                                                        spacing: 8, runSpacing: 8,
                                                        children: [
                                                          ...hor.epis.map((epi) {
                                                            return GestureDetector(
                                                              onTap: () {
                                                                setState(() {
                                                                  if (epi.isCustom && epi.ativo) {
                                                                    hor.epis.remove(epi);
                                                                  } else {
                                                                    epi.ativo = !epi.ativo;
                                                                  }
                                                                });
                                                              },
                                                              child: _buildEpiChip(epi.nome, ativo: epi.ativo),
                                                            );
                                                          }).toList(),

                                                          if (hor.isAddingEpi)
                                                            Container(
                                                              height: _alturaBotoes,
                                                              width: _larguraCaixaEpiNova, 
                                                              decoration: BoxDecoration(
                                                                color: _corFundoInput,
                                                                border: Border.all(color: const Color(0xFF0085FF), width: 1.7), 
                                                                borderRadius: BorderRadius.circular(6.7),
                                                              ),
                                                              alignment: Alignment.center,
                                                              child: TextField(
                                                                controller: hor.newEpiCtrl,
                                                                focusNode: hor.newEpiFocus,
                                                                autofocus: true,
                                                                textAlign: TextAlign.center,
                                                                inputFormatters: [
                                                                  LengthLimitingTextInputFormatter(20),
                                                                ],
                                                                style: TextStyle(fontFamily: 'Aristotelica', fontWeight: FontWeight.w700, fontSize: _tamanhoTextoEpiNovo, color: _corTextoDigitado, letterSpacing: 1.2),
                                                                cursorColor: _corBordaFocada, 
                                                                cursorWidth: 2.5, 
                                                                cursorHeight: 20, 
                                                                cursorRadius: const Radius.circular(5.0),
                                                                decoration: InputDecoration(
                                                                  border: InputBorder.none,
                                                                  isDense: true,
                                                                  contentPadding: EdgeInsets.only(bottom: _deslocamentoVerticalEpiNovo),
                                                                ),
                                                                onSubmitted: (_) {
                                                                  hor.newEpiFocus.unfocus();
                                                                },
                                                              ),
                                                            )
                                                          else
                                                            GestureDetector(
                                                              onTap: () {
                                                                setState(() => hor.isAddingEpi = true);
                                                                hor.newEpiFocus.requestFocus();
                                                              },
                                                              child: _buildEpiChip('+ ADD', ativo: false),
                                                            )
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              )
                            ],
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCriteriosAvaliacao() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('CRITÉRIO DE AVALIAÇÃO'),
        _buildOutlinedBox(
          child: _isEstagio 
            ? Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 30),
                alignment: Alignment.center,
                // 🟢 MÁGICA DO "EM BREVE": Fonte Aristotelica, tamanho 19!
                child: Text('EM BREVE', style: TextStyle(fontFamily: 'Aristotelica', fontWeight: FontWeight.w700, fontSize: 19, color: _corBordaInativa, letterSpacing: 2.0)),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: [
                      ..._avaliacoes.map((av) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (av.isCustom && av.ativo) {
                                _avaliacoes.remove(av);
                              } else {
                                av.ativo = !av.ativo;
                              }
                            });
                          },
                          child: _buildEpiChip(av.nome, ativo: av.ativo),
                        );
                      }).toList(),

                      if (_isAddingAvaliacao)
                        Container(
                          height: _alturaBotoes,
                          width: _larguraCaixaAvaliacaoNova, 
                          decoration: BoxDecoration(
                            color: _corFundoInput,
                            border: Border.all(color: const Color(0xFF0085FF), width: 1.7), 
                            borderRadius: BorderRadius.circular(6.7),
                          ),
                          alignment: Alignment.center,
                          child: TextField(
                            controller: _newAvaliacaoCtrl,
                            focusNode: _newAvaliacaoFocus,
                            autofocus: true,
                            textAlign: TextAlign.center,
                            inputFormatters: [LengthLimitingTextInputFormatter(20)],
                            style: TextStyle(fontFamily: 'Aristotelica', fontWeight: FontWeight.w700, fontSize: _tamanhoTextoEpiNovo, color: _corTextoDigitado, letterSpacing: 1.2),
                            cursorColor: _corBordaFocada, 
                            cursorWidth: 2.5, cursorHeight: 20, cursorRadius: const Radius.circular(5.0),
                            decoration: InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.only(bottom: _deslocamentoVerticalEpiNovo)),
                            onSubmitted: (_) { _newAvaliacaoFocus.unfocus(); },
                          ),
                        )
                      else
                        GestureDetector(
                          onTap: () {
                            setState(() => _isAddingAvaliacao = true);
                            _newAvaliacaoFocus.requestFocus();
                          },
                          child: _buildEpiChip('+ ADD', ativo: false),
                        )
                    ],
                  ),
                  SizedBox(height: _espacoInputAteProximoTitulo),
                  
                  _buildLabel('FÓRMULA FINAL'),
                  _buildRealTextField(hint: 'EX: (P1+P2+T1)/3', controller: _formulaController, focusNode: _formulaFocus, nextFocus: _avisosFocus),
                ],
              ),
        ),
        
        SizedBox(height: _espacoEntreSecoes),
        _buildSectionTitle('AVISOS GERAIS E COMPLEMENTARES'),
        
        _buildRealTextField(
          hint: 'ESCREVA DICAS, AVISOS, CULTURAS DA DISCIPLINA QUE PODEM SER RELEVANTES PARA OS ALUNOS', 
          controller: _avisosController, focusNode: _avisosFocus, minLines: 3, maxLines: 5
        ),
        
        SizedBox(height: _espacoAvisosAteSalvar),
        GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus(); 
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Disciplina salva com sucesso!')));
            Navigator.of(context).pop();
          },
          child: Container(
            height: _alturaBotaoSalvar, width: double.infinity,
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF7C9F19), Color(0xFFAFCB00)], begin: Alignment.centerLeft, end: Alignment.centerRight), border: Border.all(color: const Color(0xFFCEDD26), width: 1.7), borderRadius: BorderRadius.circular(6.7)),
            alignment: Alignment.center,
            child: const Padding(padding: EdgeInsets.only(top: 3.0), child: Text('SALVAR DISCIPLINA', style: TextStyle(fontFamily: 'Aristotelica', fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF303B02), letterSpacing: 1.2))),
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // 🛠️ COMPONENTES DE UI REUTILIZÁVEIS E INTERATIVOS
  // =========================================================================

  Widget _buildSectionTitle(String title, {double? marginBottom}) {
    return Padding(
      padding: EdgeInsets.only(bottom: marginBottom ?? _espacoSecaoAteCaixa), 
      child: Text(title, style: TextStyle(fontFamily: 'LeagueSpartan', fontSize: _tamanhoTituloSecao, fontWeight: FontWeight.w900, color: _corDestaque)),
    );
  }

  Widget _buildOutlinedBox({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: _paddingTopCaixaPrincipal,
        bottom: _paddingBottomCaixaPrincipal,
        left: _paddingLateralCaixaPrincipal,
        right: _paddingLateralCaixaPrincipal,
      ), 
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_raioBordaCaixaPrincipal), 
        border: Border.all(color: _corDestaque, width: 1.5),
      ),
      child: child,
    );
  }

  Widget _buildLabel(String text, {double? marginBottom, double opacity = 1.0}) {
    return Padding(
      padding: EdgeInsets.only(bottom: marginBottom ?? _espacoTituloAteInput), 
      child: Text(text, style: TextStyle(fontFamily: 'LeagueSpartan', fontSize: _tamanhoTextoLabel, fontWeight: FontWeight.w800, color: _corLabel.withOpacity(opacity))),
    );
  }

  Widget _buildRealTextField({
    required String hint, 
    required TextEditingController controller, 
    required FocusNode focusNode, 
    int? minLines = 1, // 🟢 Adicionado para controlar a altura mínima (O padrão é 1)
    int? maxLines = 1, // 🟢 Agora aceita mais linhas
    TextAlign textAlign = TextAlign.start, 
    bool alignCenter = false,
    TextInputType keyboardType = TextInputType.text,
    FocusNode? nextFocus,
    ValueChanged<String>? onChanged, 
  }) {
    final bool isPreenchido = controller.text.isNotEmpty;
    final bool isMultiline = minLines != null && minLines > 1; // Verifica se é uma caixa grande
    
    return SizedBox(
      height: !isMultiline ? 47 : null, // 🟢 Só trava a altura em 47px se for caixa de 1 linha!
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        minLines: minLines,
        maxLines: maxLines,
        onChanged: onChanged,
        textAlign: alignCenter ? TextAlign.center : textAlign,
        keyboardType: isMultiline ? TextInputType.multiline : keyboardType, // 🟢 Habilita quebra de linha no teclado do celular
        textInputAction: nextFocus != null ? TextInputAction.next : (isMultiline ? TextInputAction.newline : TextInputAction.done),
        onSubmitted: (_) { 
          if (nextFocus != null) { FocusScope.of(context).requestFocus(nextFocus); } else if (!isMultiline) { FocusScope.of(context).unfocus(); } 
        },
        style: TextStyle(fontFamily: 'Aristotelica', fontWeight: FontWeight.w700, fontSize: _tamanhoFonteDigitada, color: _corTextoDigitado),
        textAlignVertical: isMultiline ? TextAlignVertical.top : TextAlignVertical.center, // 🟢 Joga o texto pro topo em caixas grandes
        cursorColor: _corBordaFocada, 
        cursorWidth: 2.5, cursorHeight: 20, cursorRadius: const Radius.circular(5.0),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontFamily: 'Aristotelica', color: _corDicaInput, fontSize: _tamanhoFonteDica, height: 1.0),
          contentPadding: EdgeInsets.only(
            left: 11.0, right: 11.0, 
            top: 15.0, 
            bottom: isMultiline ? 15.0 : 2.0 // 🟢 Caixas grandes ganham mais respiro na parte de baixo
          ),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6.7), borderSide: BorderSide(color: isPreenchido ? const Color(0xFFA1BF06) : _corBordaInativa, width: 1.5)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6.7), borderSide: BorderSide(color: _corBordaFocada, width: 2.0)),
          fillColor: _corFundoInput,
          filled: true,
        ),
      ),
    );
  }

  Widget _buildInstitutoDropdown() {
    bool isPreenchido = _institutoController.text.isNotEmpty;
    
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); 
        setState(() => _isInstitutoExpanded = !_isInstitutoExpanded);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        width: double.infinity,
        decoration: BoxDecoration(
          color: _corFundoInput,
          borderRadius: BorderRadius.circular(6.7),
          border: Border.all(
            color: _isInstitutoExpanded ? _corBordaFocada : (isPreenchido ? const Color(0xFFA1BF06) : _corBordaInativa),
            width: _isInstitutoExpanded ? 2.0 : 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, 
          children: [
            Container(
              height: 44, 
              padding: const EdgeInsets.symmetric(horizontal: 11.0),
              color: Colors.transparent, 
              child: Row(
                children: [
                  Transform.rotate(
                    angle: _isInstitutoExpanded ? 3.14159 : 0, 
                    child: Image.asset('assets/images/seta_icon.png', width: _tamanhoIconeSeta, height: _tamanhoIconeSeta, color: _corLabel),
                  ),
                  SizedBox(width: _espacoSetaTexto),
                  Expanded(
                    child: Text(
                      isPreenchido ? _institutoController.text : 'EX: ESCOLA POLITÉCNICA',
                      style: TextStyle(
                        fontFamily: 'Aristotelica',
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5, 
                        color: isPreenchido ? _corTextoDigitado : _corDicaInput,
                        overflow: TextOverflow.ellipsis,
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
              crossFadeState: _isInstitutoExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              firstChild: const SizedBox(width: double.infinity, height: 0),
              secondChild: Column(
                children: [
                  Container(height: 1.5, color: _corBordaInativa.withOpacity(0.3)), 
                  
                  // 🟢 MÁGICA: Limita a altura, cria o Scroll e aplica o Fade de esmaecimento!
                  Container(
                    constraints: const BoxConstraints(maxHeight: 220), 
                    child: ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black, Colors.black, Colors.transparent],
                          stops: [0.0, 0.05, 0.95, 1.0], // Fade bem suave só nas beiradinhas
                        ).createShader(bounds);
                      },
                      blendMode: BlendMode.dstIn,
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(), // Scroll suave estilo iOS
                        child: Column(
                          children: _institutos.map((inst) {
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  _institutoController.text = inst;
                                  _isInstitutoExpanded = false;
                                  _departamentoController.clear(); 
                                });
                                _atualizarTela();
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 11),
                                decoration: BoxDecoration(
                                  border: inst != _institutos.last ? Border(bottom: BorderSide(color: _corBordaInativa.withOpacity(0.3), width: 1)) : null,
                                ),
                                child: Text(
                                  inst,
                                  style: TextStyle(fontFamily: 'Aristotelica', fontWeight: FontWeight.w700, fontSize: 14.5, color: _corTextoDigitado),
                                ),
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
      ),
    );
  }

  Widget _buildDepartamentoDropdown() {
    bool isInstitutoSelecionado = _institutoController.text.isNotEmpty;
    bool isPreenchido = _departamentoController.text.isNotEmpty;
    
    List<String> deptsAtuais = _bancoDeDepartamentos[_institutoController.text] ?? [];
    
    return GestureDetector(
      onTap: () {
        if (!isInstitutoSelecionado) return; 
        FocusScope.of(context).unfocus();
        setState(() => _isDeptExpanded = !_isDeptExpanded);
      },
      child: Opacity(
        opacity: isInstitutoSelecionado ? 1.0 : 0.5,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          width: double.infinity,
          decoration: BoxDecoration(
            color: _corFundoInput,
            borderRadius: BorderRadius.circular(6.7),
            border: Border.all(
              color: _isDeptExpanded ? _corBordaFocada : (isPreenchido ? const Color(0xFFA1BF06) : _corBordaInativa),
              width: _isDeptExpanded ? 2.0 : 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 11.0),
                color: Colors.transparent,
                child: Row(
                  children: [
                    Transform.rotate(
                      angle: _isDeptExpanded ? 3.14159 : 0,
                      child: Image.asset('assets/images/seta_icon.png', width: _tamanhoIconeSeta, height: _tamanhoIconeSeta, color: _corLabel),
                    ),
                    SizedBox(width: _espacoSetaTexto),
                    Expanded(
                      child: Text(
                        isPreenchido 
                          ? _departamentoController.text 
                          : (isInstitutoSelecionado ? 'TOQUE PARA REVELAR' : 'SELECIONE UM INSTITUTO ANTES'),
                        style: TextStyle(
                          fontFamily: 'Aristotelica',
                          fontWeight: FontWeight.w700,
                          fontSize: 14.5, 
                          color: isPreenchido ? _corTextoDigitado : _corDicaInput,
                          overflow: TextOverflow.ellipsis,
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
                crossFadeState: _isDeptExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                firstChild: const SizedBox(width: double.infinity, height: 0),
                secondChild: Column(
                  children: [
                    Container(height: 1.5, color: _corBordaInativa.withOpacity(0.3)),
                    
                    // 🟢 MÁGICA REPLICADA: MaxHeight, BouncingScroll e ShaderMask com Fade!
                    Container(
                      constraints: const BoxConstraints(maxHeight: 220),
                      child: ShaderMask(
                        shaderCallback: (Rect bounds) {
                          return const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black, Colors.black, Colors.transparent],
                            stops: [0.0, 0.05, 0.95, 1.0], 
                          ).createShader(bounds);
                        },
                        blendMode: BlendMode.dstIn,
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            children: deptsAtuais.map((dept) {
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    _departamentoController.text = dept;
                                    _isDeptExpanded = false;
                                  });
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 11),
                                  decoration: BoxDecoration(
                                    border: dept != deptsAtuais.last ? Border(bottom: BorderSide(color: _corBordaInativa.withOpacity(0.3), width: 1)) : null,
                                  ),
                                  child: Text(
                                    dept,
                                    style: TextStyle(fontFamily: 'Aristotelica', fontWeight: FontWeight.w700, fontSize: 14.5, color: _corTextoDigitado),
                                  ),
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
        ),
      ),
    );
  }

  Widget _buildCreditoCasinoWidget() {
    if (_isCreditoTyping) {
      return _buildRealTextField(hint: '1', controller: _creditoController, focusNode: _creditoFocus, keyboardType: TextInputType.number, alignCenter: true);
    }
    return GestureDetector(
      onTap: () {
        setState(() => _isCreditoTyping = true);
        FocusScope.of(context).requestFocus(_creditoFocus);
      },
      child: Container(
        height: 47,
        decoration: BoxDecoration(color: _corFundoInput, borderRadius: BorderRadius.circular(6.7), border: Border.all(color: _corBordaInativa, width: 1.5)),
        // 🟢 REMOVIDO O ROW E A SETINHA. AGORA CENTRALIZA PERFEITO IGUAL OS HORÁRIOS!
        child: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black, Colors.black, Colors.transparent],
            stops: [0.0, 0.15, 0.55, 1.0], 
          ).createShader(bounds),
          blendMode: BlendMode.dstIn,
          child: ListWheelScrollView.useDelegate(
            controller: _creditoScrollController,
            itemExtent: 30, physics: const FixedExtentScrollPhysics(), overAndUnderCenterOpacity: 1.0, 
            onSelectedItemChanged: (index) { _creditoValue = index; _creditoController.text = index.toString(); },
            childDelegate: ListWheelChildBuilderDelegate(
              builder: (context, index) {
                return Center(child: Text('$index Č', style: TextStyle(fontFamily: 'Aristotelica', fontWeight: FontWeight.w700, fontSize: _tamanhoFonteDigitada, color: _corTextoDigitado, height: 1.0)));
              },
              childCount: 41, 
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDiaCasinoWidget(HorarioInputData hor) {
    return GestureDetector(
      onTap: () {
        setState(() => hor.isDiaTyping = true);
        FocusScope.of(context).requestFocus(hor.diaFocus);
      },
      child: hor.isDiaTyping
        ? _buildRealTextField(hint: 'DIA', controller: hor.diaCtrl, focusNode: hor.diaFocus)
        : Container(
            height: 47,
            decoration: BoxDecoration(color: _corFundoInput, borderRadius: BorderRadius.circular(6.7), border: Border.all(color: _corBordaInativa, width: 1.5)),
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black, Colors.black, Colors.transparent], stops: [0.0, 0.15, 0.55, 1.0]).createShader(bounds),
              blendMode: BlendMode.dstIn,
              child: ListWheelScrollView.useDelegate(
                controller: hor.diaScroll,
                itemExtent: 30, physics: const FixedExtentScrollPhysics(), overAndUnderCenterOpacity: 1.0,
                onSelectedItemChanged: (index) { hor.diaIndex = index; hor.diaCtrl.text = hor.dias[index]; _atualizarTela();},
                childDelegate: ListWheelChildBuilderDelegate(
                  builder: (context, index) {
                    return Container(
                      width: double.infinity, alignment: Alignment.centerLeft, padding: const EdgeInsets.only(left: 11.0, top: 4.0),
                      child: Text(hor.dias[index], style: TextStyle(fontFamily: 'Aristotelica', fontWeight: FontWeight.w700, fontSize: _tamanhoFonteDigitada, color: _corTextoDigitado, height: 1.0)),
                    );
                  },
                  childCount: hor.dias.length,
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildTimeCasinoWidget(HorarioInputData hor, bool isFim) {
    int minTime = isFim ? hor.inicioVal + 10 : 450; 
    int maxTime = isFim ? 1120 : 1070; 
    if (minTime > maxTime) minTime = maxTime; 

    int totalItems = ((maxTime - minTime) ~/ 10) + 1;
    if (totalItems < 1) totalItems = 1;

    bool isTyping = isFim ? hor.isFimTyping : hor.isInicioTyping;

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isFim) {
            hor.isFimTyping = true;
            FocusScope.of(context).requestFocus(hor.fimFocus);
          } else {
            hor.isInicioTyping = true;
            FocusScope.of(context).requestFocus(hor.inicioFocus);
          }
        });
      },
      child: isTyping
        ? _buildRealTextField(hint: isFim ? 'FIM' : 'INÍCIO', controller: isFim ? hor.fimCtrl : hor.inicioCtrl, focusNode: isFim ? hor.fimFocus : hor.inicioFocus, textAlign: TextAlign.center, keyboardType: TextInputType.datetime)
        : Container(
            height: 47,
            decoration: BoxDecoration(color: _corFundoInput, borderRadius: BorderRadius.circular(6.7), border: Border.all(color: _corBordaInativa, width: 1.5)),
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black, Colors.black, Colors.transparent], stops: [0.0, 0.15, 0.55, 1.0]).createShader(bounds),
              blendMode: BlendMode.dstIn,
              child: ListWheelScrollView.useDelegate(
                key: isFim ? ValueKey('fim_${hor.inicioVal}_${hor.fimScroll.hashCode}') : null,
                controller: isFim ? hor.fimScroll : hor.inicioScroll,
                itemExtent: 30, physics: const FixedExtentScrollPhysics(), overAndUnderCenterOpacity: 1.0,
                onSelectedItemChanged: (index) {
                  int newMins = minTime + (index * 10);
                  if (isFim) { 
                    hor.fimVal = newMins; hor.fimCtrl.text = _formatMinsToTime(newMins); 
                  } else {
                    hor.inicioVal = newMins; hor.inicioCtrl.text = _formatMinsToTime(newMins);
                    
                    int minFimPermitido = hor.inicioVal + 10;
                    if (hor.fimVal < minFimPermitido) {
                      hor.fimVal = minFimPermitido;
                      if (hor.fimVal > 1120) hor.fimVal = 1120;
                      hor.fimCtrl.text = _formatMinsToTime(hor.fimVal);
                    }
                    
                    int novoIndexFim = (hor.fimVal - minFimPermitido) ~/ 10;
                    if(novoIndexFim < 0) novoIndexFim = 0;
                    
                    if (hor.fimScroll.hasClients) {
                      hor.fimScroll.jumpToItem(novoIndexFim);
                    }
                    _atualizarTela(); 
                  }
                },
                childDelegate: ListWheelChildBuilderDelegate(
                  builder: (context, index) {
                    int displayMins = minTime + (index * 10);
                    return Center(child: Padding(padding: const EdgeInsets.only(top: 4.0), child: Text(_formatMinsToTime(displayMins), style: TextStyle(fontFamily: 'Aristotelica', fontWeight: FontWeight.w700, fontSize: _tamanhoFonteDigitada, color: _corTextoDigitado, height: 1.0))));
                  },
                  childCount: totalItems,
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildNovoBotaoAcao(String texto, VoidCallback onTap, {bool expandir = false}) {
    Widget btn = Container(
      height: _alturaBotoes,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        gradient: const RadialGradient(colors: [Color(0xFFA8A7A7), Color(0xFFBABBBB)], radius: 3.0),
        border: Border.all(color: const Color(0xFF969AA0), width: 1.7),
        borderRadius: BorderRadius.circular(6.7),
      ),
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.only(top: 3.0),
        child: Text(texto, style: const TextStyle(fontFamily: 'Aristotelica', fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFFF0F0F0), letterSpacing: 1.2)),
      ),
    );
    return GestureDetector(
      onTap: onTap,
      child: expandir ? Row(children: [Expanded(child: btn)]) : btn,
    );
  }

  Widget _buildToggle({required bool valor, required ValueChanged<bool> onChanged, bool isEnabled = true}) {
    return GestureDetector(
      // 🟢 Se estiver desativado (travado), ignoramos o toque
      onTap: isEnabled ? () => onChanged(!valor) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: _larguraToggle, height: _alturaToggle, padding: EdgeInsets.all(_paddingInternoToggle),
        decoration: BoxDecoration(
          // 🟢 Fica transparente/desbotado se estiver travado
          color: isEnabled 
              ? (valor ? _corDestaque : _corFundoToggleInativo) 
              : _corFundoToggleInativo.withOpacity(0.5), 
          borderRadius: BorderRadius.circular(_alturaToggle / 2),
          border: Border.all(
            color: isEnabled ? (valor ? _corDestaque : _corBordaInativa) : _corBordaInativa.withOpacity(0.3), 
            width: 1.5
          ), 
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: valor ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: _tamanhoBolinhaToggle, height: _tamanhoBolinhaToggle, 
            decoration: BoxDecoration(
              shape: BoxShape.circle, 
              color: isEnabled ? (valor ? Colors.white : _corBordaInativa) : _corBordaInativa.withOpacity(0.3)
            )
          ),
        ),
      ),
    );
  }

  Widget _buildEpiChip(String texto, {required bool ativo}) {
    return Container(
      height: _alturaBotoes,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: ativo 
            ? const LinearGradient(colors: [Color(0xFF0460E9), Color(0xFF0D41A9)], begin: Alignment.centerLeft, end: Alignment.centerRight)
            : const RadialGradient(colors: [Color(0xFFA8A7A7), Color(0xFFBABBBB)], radius: 3.0),
        border: Border.all(color: ativo ? const Color(0xFF0085FF) : const Color(0xFF969AA0), width: 1.7),
        borderRadius: BorderRadius.circular(6.7),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Padding(
              padding: const EdgeInsets.only(top: 3.0),
              child: Text(
                texto, 
                style: TextStyle(fontFamily: 'Aristotelica', fontWeight: FontWeight.w700, fontSize: 16, color: ativo ? Colors.white : const Color(0xFFF0F0F0), letterSpacing: 1.2),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFrequenciaSelector(HorarioInputData hor) {
    int index = hor.frequenciaLab; 
    int pos = index == 0 ? 0 : (index == 1 || index == 2 ? 1 : 2);

    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: const Color(0xFFB5B6B8), 
        borderRadius: BorderRadius.circular(6.7),
        border: Border.all(color: const Color(0xFF969AA0), width: 1.5),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          double totalWidth = constraints.maxWidth;
          
          double w1 = totalWidth * 0.42;
          double w2 = totalWidth * 0.42;
          double w3 = totalWidth * 0.16;

          double leftPos = pos == 0 ? 0 : (pos == 1 ? w1 : w1 + w2);
          double currentWidth = pos == 0 ? w1 : (pos == 1 ? w2 : w3);

          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                left: leftPos,
                top: 0,
                bottom: 0,
                width: currentWidth,
                child: Container(
                  margin: const EdgeInsets.all(2.0),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF0460E9), Color(0xFF0D41A9)]),
                    borderRadius: BorderRadius.circular(5.0),
                    border: Border.all(color: const Color(0xFF0085FF), width: 1.5),
                  ),
                ),
              ),

              Row(
                children: [
                  SizedBox(
                    width: w1,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => setState(() => hor.frequenciaLab = 0),
                      child: const Center(child: Text('SEMANAL', style: TextStyle(fontFamily: 'Aristotelica', fontWeight: FontWeight.w700, fontSize: 13, color: Colors.white, letterSpacing: 0.5))),
                    ),
                  ),
                  SizedBox(
                    width: w2,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        setState(() {
                          if (hor.frequenciaLab == 1) hor.frequenciaLab = 2; 
                          else hor.frequenciaLab = 1; 
                        });
                      },
                      child: Center(
                        child: Text(
                          hor.frequenciaLab == 1 ? 'QUINZENAL 1' : (hor.frequenciaLab == 2 ? 'QUINZENAL 2' : 'QUINZENAL'), 
                          style: const TextStyle(fontFamily: 'Aristotelica', fontWeight: FontWeight.w700, fontSize: 13, color: Colors.white, letterSpacing: 0.5)
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: w3,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        setState(() => hor.frequenciaLab = 3);
                        // 🟢 Removida a chamada do _abrirCalendarioCustom. Ele apenas muda o estado.
                      },
                      child: const Center(child: Icon(Icons.edit_rounded, color: Colors.white, size: 20)),
                    ),
                  ),
                ],
              ),
            ],
          );
        }
      ),
    );
  }

  // =========================================================================
  // 🔘 FOOTER (RODAPÉ DE NAVEGAÇÃO E AÇÕES)
  // =========================================================================
  Widget _buildFooterBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: const Color(0xFFE5E7EB), width: _espessuraLinhaFooter))),
      child: SafeArea(
        top: false,
        child: Container(
          height: _alturaFooter, 
          padding: EdgeInsets.only(left: _paddingLateralFooter, right: _paddingLateralFooter),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center, 
            children: [
              SizedBox(
                width: _larguraTotalVoltar, height: _alturaBotoes,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Stack(
                    clipBehavior: Clip.none, alignment: Alignment.centerLeft, 
                    children: [
                      Positioned(left: 0, child: Image.asset('assets/images/estrela_icon.png', height: _tamanhoEstrela, width: _tamanhoEstrela, color: const Color(0xFF0085FF))),
                      Positioned(
                        left: _avancoBotaoVoltar, right: 0, top: 0, bottom: 0,
                        child: Container(
                          decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF0460E9), Color(0xFF0D41A9)], begin: Alignment.centerLeft, end: Alignment.centerRight), borderRadius: BorderRadius.circular(6.7), border: Border.all(color: const Color(0xFF0085FF), width: 1.7)),
                          alignment: Alignment.center,
                          child: const Padding(padding: EdgeInsets.only(top: 3.0), child: Text('VOLTAR', style: TextStyle(fontFamily: 'Aristotelica', color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16, letterSpacing: 1.2))),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _resetarTudo,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 🟢 COMPLETAMENTE LIVRE DE 'const' PARA NÃO DAR ERRO DE CONSTRUTOR!
                    RichText(
                      textAlign: TextAlign.right,
                      text: const TextSpan(
                        style: TextStyle(fontFamily: 'Aristotelica', fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFFBCBEBF), height: 1.1),
                        children: [
                          TextSpan(text: 'LIMPAR\n'),
                          TextSpan(text: 'DISCIPLINA?'),
                        ],
                      ),
                    ),
                    SizedBox(width: _espacoTextoDesfazer),
                    Image.asset('assets/images/desfazer_icon.png', width: _tamanhoIconeLixeira, height: _tamanhoIconeLixeira),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// =========================================================================
// 🧠 FUNÇÕES GLOBAIS DE TEMPO E MODELOS DE DADOS PARA A LISTA DINÂMICA
// =========================================================================

String _formatMinsToTime(int mins) {
  int h = mins ~/ 60;
  int m = mins % 60;
  return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
}

int _parseTimeToMins(String timeStr) {
  String clean = timeStr.replaceAll(RegExp(r'[^0-9]'), '');
  if (clean.isEmpty) return 450;
  int h = 0, m = 0;
  if (clean.length <= 2) { h = int.parse(clean); } 
  else if (clean.length == 3) { h = int.parse(clean.substring(0, 1)); m = int.parse(clean.substring(1)); } 
  else { h = int.parse(clean.substring(0, 2)); m = int.parse(clean.substring(2, 4)); }
  return h * 60 + m;
}

// 🟢 Ferramenta que injeta o auto-scroll (puxar pra cima) nas caixas geradas via "+ ADD"
void _aplicarAutoScroll(FocusNode focus) {
  focus.addListener(() {
    if (focus.hasFocus) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (focus.context != null) {
          Scrollable.ensureVisible(
            focus.context!,
            alignment: 0.3,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
          );
        }
      });
    }
  });
}

class EpiData {
  String nome;
  bool ativo;
  bool isCustom;
  EpiData(this.nome, this.ativo, {this.isCustom = false});
}

class AvaliacaoData {
  String nome;
  bool ativo;
  bool isCustom;
  AvaliacaoData(this.nome, this.ativo, {this.isCustom = false});
}

class TurmaInputData {
  final TextEditingController codigoCtrl = TextEditingController();
  final FocusNode codigoFocus = FocusNode();
  
  List<ProfessorInputData> professores = [];
  List<HorarioInputData> horarios = []; 
  
  bool isLogisticaExpanded = true;
  
  final VoidCallback onUpdate;

  TurmaInputData({required this.onUpdate}) {
    codigoFocus.addListener(onUpdate);
    _aplicarAutoScroll(codigoFocus); // 🟢 Auto-scroll garantido para Código da Turma
    
    var prof = ProfessorInputData(onUpdate: onUpdate);
    prof.iniciarListeners();
    professores.add(prof);
    
    var hor = HorarioInputData(onUpdate: onUpdate);
    hor.iniciarListeners();
    horarios.add(hor);
  }

  void iniciarListeners() {}

  String getDisplayTitle(int index) {
    String txt = codigoCtrl.text.trim().toUpperCase();
    if (txt.isEmpty) return 'TURMA ${(index + 1).toString().padLeft(2, '0')}'; 
    return 'TURMA $txt';
  }

  void dispose() {
    codigoCtrl.dispose(); codigoFocus.dispose();
    for (var p in professores) { p.dispose(); }
    for (var h in horarios) { h.dispose(); }
  }
}

class ProfessorInputData {
  final TextEditingController nomeCtrl = TextEditingController();
  final FocusNode nomeFocus = FocusNode();
  final VoidCallback onUpdate;

  ProfessorInputData({required this.onUpdate}) {
    _aplicarAutoScroll(nomeFocus); // 🟢 Auto-scroll garantido para Professores novos!
  }

  void iniciarListeners() {
    nomeFocus.addListener(onUpdate);
  }

  void dispose() { nomeCtrl.dispose(); nomeFocus.dispose(); }
}

class HorarioInputData {
  final TextEditingController diaCtrl = TextEditingController(text: 'SEGUNDA');
  final TextEditingController inicioCtrl = TextEditingController(text: '07:30');
  final TextEditingController fimCtrl = TextEditingController(text: '09:10'); 
  final TextEditingController salaCtrl = TextEditingController();
  
  final FocusNode diaFocus = FocusNode();
  final FocusNode inicioFocus = FocusNode();
  final FocusNode fimFocus = FocusNode();
  final FocusNode salaFocus = NodeSemLoop();
  
  final VoidCallback onUpdate;
  final List<String> dias = ['SEGUNDA', 'TERÇA', 'QUARTA', 'QUINTA', 'SEXTA', 'SÁBADO']; 

  bool isDiaTyping = false;
  bool isInicioTyping = false;
  bool isFimTyping = false;
  
  bool isLaboratorio = false;
  int frequenciaLab = 0; 
  Set<DateTime> datasSelecionadas = {}; 
  bool precisaEpi = false;
  
  List<EpiData> epis = [
    EpiData('JALECO', true),
    EpiData('CALÇA COMPRIDA', false),
    EpiData('ÓCULOS DE PROTEÇÃO', false),
  ];

  bool isAddingEpi = false;
  final TextEditingController newEpiCtrl = TextEditingController();
  final FocusNode newEpiFocus = FocusNode();

  int diaIndex = 0; 
  int inicioVal = 450; 
  int fimVal = 550; 

  late FixedExtentScrollController diaScroll;
  late FixedExtentScrollController inicioScroll;
  late FixedExtentScrollController fimScroll;

  HorarioInputData({required this.onUpdate}) {
    diaScroll = FixedExtentScrollController(initialItem: diaIndex);
    inicioScroll = FixedExtentScrollController(initialItem: (inicioVal - 450) ~/ 10);
    fimScroll = FixedExtentScrollController(initialItem: (fimVal - (inicioVal + 10)) ~/ 10);
    
    _aplicarAutoScroll(salaFocus); // 🟢 Auto-scroll garantido para Salas novas!
  }

  void iniciarListeners() {
    diaFocus.addListener(() {
      if (!diaFocus.hasFocus) {
        isDiaTyping = false;
        diaIndex = dias.indexOf(diaCtrl.text.toUpperCase());
        if (diaIndex == -1) diaIndex = 0;
        diaCtrl.text = dias[diaIndex];
        diaScroll.dispose();
        diaScroll = FixedExtentScrollController(initialItem: diaIndex);
      }
      onUpdate();
    });

    inicioFocus.addListener(() {
      if (!inicioFocus.hasFocus) {
        isInicioTyping = false;
        inicioVal = _parseTimeToMins(inicioCtrl.text);
        inicioVal = (inicioVal ~/ 5) * 5; 
        
        if (inicioVal < 450) inicioVal = 450;
        if (inicioVal > 1070) inicioVal = 1070; 
        
        inicioCtrl.text = _formatMinsToTime(inicioVal);
        
        if (fimVal <= inicioVal) {
          fimVal = inicioVal + 10;
          if (fimVal > 1120) fimVal = 1120;
          fimCtrl.text = _formatMinsToTime(fimVal);
        }

        int roundedInicio10 = (inicioVal / 10).round() * 10;
        inicioScroll.dispose();
        inicioScroll = FixedExtentScrollController(initialItem: (roundedInicio10 - 450) ~/ 10);

        int minFimPermitido = inicioVal + 10;
        if(minFimPermitido > 1120) minFimPermitido = 1120;
        
        int fimRounded10 = (fimVal / 10).round() * 10;
        int novoIndexFim = (fimRounded10 - minFimPermitido) ~/ 10;
        if(novoIndexFim < 0) novoIndexFim = 0;
        
        fimScroll.dispose();
        fimScroll = FixedExtentScrollController(initialItem: novoIndexFim);
      }
      onUpdate();
    });

    fimFocus.addListener(() {
      if (!fimFocus.hasFocus) {
        isFimTyping = false;
        fimVal = _parseTimeToMins(fimCtrl.text);
        fimVal = (fimVal ~/ 5) * 5;
        
        int minFimPermitido = inicioVal + 10;
        if (fimVal < minFimPermitido) fimVal = minFimPermitido; 
        if (fimVal > 1120) fimVal = 1120;

        fimCtrl.text = _formatMinsToTime(fimVal);

        int fimRounded10 = (fimVal / 10).round() * 10;
        int novoIndexFim = (fimRounded10 - minFimPermitido) ~/ 10;
        if(novoIndexFim < 0) novoIndexFim = 0;

        fimScroll.dispose();
        fimScroll = FixedExtentScrollController(initialItem: novoIndexFim);
      }
      onUpdate();
    });

    salaFocus.addListener(onUpdate);

    newEpiFocus.addListener(() {
      if (newEpiFocus.hasFocus) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (newEpiFocus.context != null) {
            Scrollable.ensureVisible(
              newEpiFocus.context!,
              alignment: 0.3, // 🟢 Consertado: Era 1.0, por isso puxava a tela pra baixo em vez de pra cima!
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
            );
          }
        });
      } else {
        if (newEpiCtrl.text.trim().isNotEmpty) {
          epis.add(EpiData(newEpiCtrl.text.trim().toUpperCase(), true, isCustom: true));
        }
        newEpiCtrl.clear();
        isAddingEpi = false;
        onUpdate();
      }
    });
  }

  void dispose() {
    diaCtrl.dispose(); inicioCtrl.dispose(); fimCtrl.dispose(); salaCtrl.dispose();
    diaFocus.dispose(); inicioFocus.dispose(); fimFocus.dispose(); salaFocus.dispose();
    newEpiCtrl.dispose(); newEpiFocus.dispose();
    diaScroll.dispose(); inicioScroll.dispose(); fimScroll.dispose();
  }

  // 🟢 NOVA FUNÇÃO QUE GERA AS DATAS PARA OS QUADRADINHOS IN-LINE
  List<DateTime> obterDatasSemestre() {
    List<DateTime> dates = [];
    DateTime hoje = DateTime.now();
    DateTime now = DateTime(hoje.year, hoje.month, hoje.day); 
    
    int targetDay = DateTime.monday;
    switch(diaCtrl.text.toUpperCase()) {
      case 'TERÇA': targetDay = DateTime.tuesday; break;
      case 'QUARTA': targetDay = DateTime.wednesday; break;
      case 'QUINTA': targetDay = DateTime.thursday; break;
      case 'SEXTA': targetDay = DateTime.friday; break;
      case 'SÁBADO': targetDay = DateTime.saturday; break;
    }
    
    while (now.weekday != targetDay) { now = now.add(const Duration(days: 1)); }
    for (int i = 0; i < 20; i++) { dates.add(now.add(Duration(days: i * 7))); } 
    return dates;
  }
}

class NodeSemLoop extends FocusNode {}