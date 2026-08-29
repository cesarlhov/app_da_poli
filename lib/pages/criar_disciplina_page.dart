// lib/pages/criar_disciplina_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_da_poli/models/disciplina_model.dart';
import 'package:app_da_poli/services/firestore_service.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:app_da_poli/providers/user_provider.dart';

class CriarDisciplinaPage extends StatefulWidget {
  final Disciplina? disciplinaParaEditar; // 🟢 Se for passado, a tela vira "Edição"
  const CriarDisciplinaPage({super.key, this.disciplinaParaEditar});

  @override
  State<CriarDisciplinaPage> createState() => _CriarDisciplinaPageState();
}

class _CriarDisciplinaPageState extends State<CriarDisciplinaPage> {

  // =========================================================================
  // 🎛️ PAINEL DE CONTROLE - ABA DE HISTÓRICO (ANTERIORMENTE)
  // =========================================================================
  final double _espacoCimaTituloAba = 26.0; 
  final double _espacoTituloAbaAteData = 0.0; 
  final double _espacoDataAbaAteTexto = 3.0; 
  final double _espacoEntreTextosAba = 2.0;

  bool _isLoadingSave = false; 

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

  final double _larguraCaixaAvaliacaoNova = 60.0; 
  final double _espacoAbaixoSalvar = 24.0; 

  // =========================================================================
  // 🎛️ PAINEL DE CONTROLE - ESPAÇAMENTOS E ÍCONES
  // =========================================================================
  final double _larguraCaixaEpiNova = 150.0; 
  final double _tamanhoTextoEpiNovo = 19.0; 
  final double _deslocamentoVerticalEpiNovo = 0.0; 

  final double _tamanhoIconeSeta = 20.0;
  final double _espacoSetaTexto = 8.0;
  final double _tamanhoIconeLixeira = 26.0;
  final double _espacoLixeiraCaixa = 12.0;
  final double _tamanhoIconeX = 20.0;
  
  final double _espacoLocalAteAdd = 8.0; 

  // =========================================================================
  // 🎛️ PAINEL DE CONTROLE - FINAL DA TELA E BOTÃO SALVAR
  // =========================================================================
  final double _espacoCaixaAteAvisos = 16.0; 
  final double _espacoAvisosAteSalvar = 16.0; 
  final double _alturaBotaoSalvar = 40.0; 

  // =========================================================================
  // 🎛️ PAINEL DE CONTROLE - TOGGLE E FOOTER
  // =========================================================================
  final double _larguraToggle = 58.0;
  final double _alturaToggle = 32.0;
  final double _tamanhoBolinhaToggle = 20.0;
  final double _paddingInternoToggle = 5.0; 
  final Color _corFundoToggleInativo = const Color(0xFFF5F5F7); 
  final double _deslocamentoVerticalTextoToggle = 1.5; 

  final double _alturaBotoes = 40.0; 
  final double _larguraTotalVoltar = 95.0; 
  final double _tamanhoEstrela = 32.0; 
  final double _avancoBotaoVoltar = 15.0; 
  
  final double _alturaFooter = 85.0; 
  final double _espessuraLinhaFooter = 3.0; 
  final double _paddingLateralFooter = 20.0; 
  final double _espacoTextoDesfazer = 8.0; 

  // =========================================================================
  // ESTADOS GLOBAIS E DE DATAS
  // =========================================================================
  bool _isQuadrimestral = false;
  bool _isEstagio = false;
  bool _contaPresenca = true;

  // 🟢 FONTES DO MINI CALENDÁRIO
  final double _tamanhoFonteCalendarioDias = 12.0; 
  final double _tamanhoFonteCalendarioNumeros = 15.0;
  final double _tamanhoFonteDatasCustomizadas = 15.0;

  // 🟢 VARIÁVEIS PARA O MINI CALENDÁRIO INLINE E CÉDULAS
  bool _isCalendarExpanded = false;
  int _tapStep = 2; // 0 = Início, 1 = Fim, 2 = Completo
  DateTime _mesExibido = DateTime.now();

  DateTime _dataInicio = DateTime.now();
  DateTime _dataFim = DateTime.now().add(const Duration(days: 120));
  
  bool _selecionouInicio = false;
  bool _selecionouFim = false;
  
  final _inicioDataCtrl = TextEditingController(); final _inicioDataFocus = FocusNode();
  final _fimDataCtrl = TextEditingController(); final _fimDataFocus = FocusNode();

  bool _isDeptExpanded = false;
  bool _isInstitutoExpanded = false;

  final List<String> _institutos = [
    'POLI - Escola Politécnica', 
    'IME - Inst. de Matemática e Estatística', 
    'IF - Instituto de Física', 
    'IQ - Instituto de Química', 
    'ICG - Instituto de Geociências'
  ];
  
  final Map<String, List<String>> _bancoDeDepartamentos = {
    'POLI - Escola Politécnica': [
        'PCC - Eng. de Construção Civil', 'PCS - Eng. de Computação e Sistemas Digitais', 'PEA - Eng. de Energia e Automação Elétricas',
        'PEF - Eng. de Estruturas e Geotécnica', 'PHA - Eng. Hidráulica e Ambiental', 'PME - Eng. Mecânica', 'PMI - Eng. de Minas e de Petróleo',
        'PMR - Eng. Mecatrônica e Sistemas Mecânicos', 'PMT - Eng. Metalúrgica e de Materiais', 'PNV - Eng. Naval e Oceânica',
        'PQI - Eng. Química', 'PRO - Eng. de Produção', 'PSI - Eng. de Sistemas Eletrônicos', 'PTC - Eng. de Telecomunicações e Controle', 'PTR - Eng. de Transportes'
    ],
    'IME - Inst. de Matemática e Estatística': [ 'MAC - Ciência da Computação', 'MAE - Estatística', 'MAP - Matemática Aplicada', 'MAT - Matemática' ],
    'IF - Instituto de Física': [ 'FAP - Física Aplicada', 'FEP - Física Experimental', 'FGE - Física Geral', 'FMA - Física Matemática', 'FMT - Física de Materiais e Mecânica', 'FNC - Física Nuclear' ],
    'IQ - Instituto de Química': [ 'QBQ - Bioquímica', 'QFL - Química Fundamental' ],
    'ICG - Instituto de Geociências': [ 'GAA - Geologia Ambiental e Aplicada', 'GMG - Mineralogia e Geotectônica' ]
  };

  bool _isCreditoTyping = false;
  int _creditoValue = 1;
  late FixedExtentScrollController _creditoScrollController;
  
  final ScrollController _mainScrollController = ScrollController();

  final _codigoController = TextEditingController(); final _codigoFocus = FocusNode();
  final _nomeController = TextEditingController(); final _nomeFocus = FocusNode();
  final _institutoController = TextEditingController(); final _institutoFocus = FocusNode();
  final _creditoController = TextEditingController(); final _creditoFocus = FocusNode();
  final _departamentoController = TextEditingController(); final _departamentoFocus = FocusNode();
  final _ementaController = TextEditingController(); final _ementaFocus = FocusNode();
  final _formulaController = TextEditingController(); final _formulaFocus = FocusNode();
  final _avisosController = TextEditingController(); final _avisosFocus = FocusNode();

  List<TurmaInputData> _turmas = [];

  void _atualizarTela() {
    if (mounted) setState(() {});
  }

  // 🟢 FUNÇÃO INTELIGENTE: Restaura a disciplina exatamente para o que estava no banco
  void _carregarDadosIniciais() {
    final d = widget.disciplinaParaEditar!;
    
    _codigoController.text = d.codigo;
    _nomeController.text = d.nome;
    _institutoController.text = d.instituto;
    _departamentoController.text = d.departamento;
    _ementaController.text = d.ementa;
    
    _isQuadrimestral = d.isQuadrimestral;
    _isEstagio = d.isEstagio;
    _contaPresenca = d.contaPresenca;
    
    _formulaController.text = d.formulaFinal;
    _avisosController.text = d.avisosGerais;
    
    // Restaurando Datas
    _dataInicio = d.dataInicio.toDate();
    _dataFim = d.dataFim.toDate();
    _selecionouInicio = true;
    _selecionouFim = true;
    _inicioDataCtrl.text = DateFormat('dd/MM/yy').format(_dataInicio);
    _fimDataCtrl.text = DateFormat('dd/MM/yy').format(_dataFim);
    _tapStep = 2;
    _mesExibido = DateTime(_dataInicio.year, _dataInicio.month, 1);
    
    // Restaurando Avaliações
    _avaliacoes.clear();
    for (var aval in d.avaliacoesAtivas) {
      _avaliacoes.add(AvaliacaoData(aval, true, isCustom: !['P1', 'P2', 'T1'].contains(aval)));
    }
    for (var def in ['P1', 'P2', 'T1']) {
      if (!d.avaliacoesAtivas.contains(def)) _avaliacoes.add(AvaliacaoData(def, false));
    }

    // Restaurando Turmas
    for (var t in _turmas) { t.dispose(); }
    _turmas.clear();

    if (d.turmas.isNotEmpty) {
      for (var t in d.turmas) {
        var turmaData = TurmaInputData(onUpdate: _atualizarTela);
        turmaData.codigoCtrl.text = t.codigo;
        
        // Professores
        turmaData.professores.clear();
        for (var p in t.professores) {
          var profData = ProfessorInputData(onUpdate: _atualizarTela);
          profData.nomeCtrl.text = p;
          profData.iniciarListeners(); // 🟢 Ativa o ouvinte
          turmaData.professores.add(profData);
        }
        if (turmaData.professores.isEmpty) {
          var pData = ProfessorInputData(onUpdate: _atualizarTela);
          pData.iniciarListeners();
          turmaData.professores.add(pData);
        }

        // Horários e EPIs
        turmaData.horarios.clear();
        for (var h in t.horarios) {
          var horData = HorarioInputData(onUpdate: _atualizarTela);
          horData.diaCtrl.text = h.dia;
          horData.inicioCtrl.text = h.inicio;
          horData.fimCtrl.text = h.fim;
          horData.salaCtrl.text = h.local;
          horData.isLaboratorio = h.isLaboratorio;
          horData.frequenciaLab = h.frequenciaLab;
          horData.precisaEpi = h.precisaEpi;
          
          horData.datasSelecionadas = h.datasCustomizadas.map((dateStr) {
            var parts = dateStr.split('-');
            if(parts.length == 3) return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
            return DateTime.now();
          }).toSet();

          horData.epis.clear();
          for (var epi in h.epis) {
            horData.epis.add(EpiData(epi, true, isCustom: !['JALECO', 'CALÇA COMPRIDA', 'ÓCULOS DE PROTEÇÃO'].contains(epi)));
          }
          for (var def in ['JALECO', 'CALÇA COMPRIDA', 'ÓCULOS DE PROTEÇÃO']) {
            if (!h.epis.contains(def)) horData.epis.add(EpiData(def, false));
          }
          
          horData.iniciarListeners(); // 🟢 Ativa o ouvinte
          turmaData.horarios.add(horData);
        }
        if (turmaData.horarios.isEmpty) {
          var hData = HorarioInputData(onUpdate: _atualizarTela);
          hData.iniciarListeners();
          turmaData.horarios.add(hData);
        }

        turmaData.iniciarListeners(); // 🟢 Ativa o ouvinte
        _turmas.add(turmaData);
      }
    } else {
      var turmaMestra = TurmaInputData(onUpdate: _atualizarTela);
      turmaMestra.iniciarListeners();
      _turmas.add(turmaMestra);
    }
  }

  void _resetarTudo() {
    setState(() {
      if (widget.disciplinaParaEditar != null) {
        // 🟢 MODO EDIÇÃO: Restaura todos os dados originais
        _carregarDadosIniciais();
      } else {
        // 🟢 MODO CRIAÇÃO: Limpa todos os campos para branco
        _codigoController.clear(); _nomeController.clear(); _institutoController.clear();
        _departamentoController.clear(); _ementaController.clear(); _formulaController.clear(); 
        _avisosController.clear();
        
        _inicioDataCtrl.clear(); _fimDataCtrl.clear();
        _selecionouInicio = false; _selecionouFim = false; _tapStep = 2;

        _isQuadrimestral = false; _isEstagio = false; _contaPresenca = true;
        _isDeptExpanded = false; _isInstitutoExpanded = false; 
        
        _isAddingAvaliacao = false;
        _avaliacoes = [AvaliacaoData('P1', true), AvaliacaoData('P2', false), AvaliacaoData('T1', false)];
        
        for (var t in _turmas) { t.dispose(); }
        _turmas.clear();
        var turmaMestra = TurmaInputData(onUpdate: _atualizarTela);
        turmaMestra.iniciarListeners();
        _turmas.add(turmaMestra);
      }
    });
  }

  void _parseDataManual(TextEditingController ctrl, bool isInicio) {
    if (ctrl.text.length >= 8) { 
      try {
        List<String> parts = ctrl.text.split('/');
        int d = int.parse(parts[0]); int m = int.parse(parts[1]); int y = int.parse(parts[2]);
        if (y < 100) y += 2000;
        DateTime parsed = DateTime(y, m, d);
        
        setState(() {
          if (isInicio) {
            _dataInicio = parsed; _selecionouInicio = true; _tapStep = 1;
            if (_selecionouFim && _dataFim.isBefore(_dataInicio)) {
              _dataFim = _dataInicio;
              _fimDataCtrl.text = DateFormat('dd/MM/yy').format(_dataFim);
            }
            _mesExibido = DateTime(_dataInicio.year, _dataInicio.month, 1);
          } else {
            if (parsed.isBefore(_dataInicio)) {
              _dataFim = _dataInicio; _fimDataCtrl.text = DateFormat('dd/MM/yy').format(_dataFim);
            } else {
              _dataFim = parsed; _selecionouFim = true; _tapStep = 2;
            }
            _mesExibido = DateTime(_dataFim.year, _dataFim.month, 1);
          }
        });
      } catch (_) {}
    }
  }

  // 🟢 Variáveis para guardar o estado anterior
  String _codigoAnterior = '';
  String _nomeAnterior = '';
  String _dataEdicaoAnterior = '27/08/2026'; // Exemplo de formatação da data

  @override
  void initState() {
    super.initState();
    
    // 🟢 PRÉ-CARREGAMENTO
    if (widget.disciplinaParaEditar != null) {
      _carregarDadosIniciais();
    } else {
      var turmaMestra = TurmaInputData(onUpdate: _atualizarTela);
      turmaMestra.iniciarListeners();
      _turmas.add(turmaMestra);
    }

    _inicioDataFocus.addListener(() { if (!_inicioDataFocus.hasFocus) _parseDataManual(_inicioDataCtrl, true); });
    _fimDataFocus.addListener(() { if (!_fimDataFocus.hasFocus) _parseDataManual(_fimDataCtrl, false); });

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

    final todosFocosEstaticos = [_codigoFocus, _nomeFocus, _ementaFocus, _formulaFocus, _avisosFocus, _inicioDataFocus, _fimDataFocus];
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
    _mainScrollController.dispose(); _codigoController.dispose(); _nomeController.dispose();
    _institutoController.dispose(); _departamentoController.dispose(); _ementaController.dispose();
    _formulaController.dispose(); _avisosController.dispose(); _inicioDataCtrl.dispose(); _fimDataCtrl.dispose();
    _codigoFocus.dispose(); _nomeFocus.dispose(); _institutoFocus.dispose(); _departamentoFocus.dispose(); 
    _ementaFocus.dispose(); _formulaFocus.dispose(); _avisosFocus.dispose(); _inicioDataFocus.dispose(); _fimDataFocus.dispose();
    _newAvaliacaoCtrl.dispose(); _newAvaliacaoFocus.dispose();
    for (var t in _turmas) { t.dispose(); }
    super.dispose();
  }

  // =========================================================================
  // 🚀 MOTOR DE SALVAMENTO INTELIGENTE (UI -> FIREBASE)
  // =========================================================================
  Future<void> _salvarDisciplina() async {
    if (_codigoController.text.trim().isEmpty || _nomeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Código e Nome da disciplina são obrigatórios!'), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isLoadingSave = true);

    try {
      bool isModoEdicao = widget.disciplinaParaEditar != null;
      List<Turma> turmasMapeadas = [];
      
      for (int i = 0; i < _turmas.length; i++) {
        var turmaData = _turmas[i];
        List<HorarioAula> horariosMapeados = turmaData.horarios.map((horData) {
          return HorarioAula(
            dia: horData.diaCtrl.text.trim().toUpperCase(),
            inicio: horData.inicioCtrl.text.trim(),
            fim: horData.fimCtrl.text.trim(),
            local: horData.salaCtrl.text.trim(),
            isLaboratorio: horData.isLaboratorio,
            frequenciaLab: horData.frequenciaLab,
            datasCustomizadas: horData.datasSelecionadas.map((d) => "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}").toList(),
            precisaEpi: horData.precisaEpi,
            epis: horData.epis.where((e) => e.ativo).map((e) => e.nome).toList(),
          );
        }).toList();

        String codigoDaDisciplina = _codigoController.text.trim().toUpperCase();
        String codigoDaTurma = turmaData.codigoCtrl.text.trim().isEmpty ? 'T0${i+1}' : turmaData.codigoCtrl.text.trim();

        // 🟢 BLINDAGEM DE MATRÍCULA: Mantém o ID original da turma para não desconectar os alunos!
        String turmaIdFinal = '${codigoDaDisciplina}_$codigoDaTurma';
        if (isModoEdicao && i < widget.disciplinaParaEditar!.turmas.length) {
          turmaIdFinal = widget.disciplinaParaEditar!.turmas[i].id;
        }

        turmasMapeadas.add(Turma(
          id: turmaIdFinal,
          codigo: codigoDaTurma,
          professores: turmaData.professores.map((p) => p.nomeCtrl.text.trim()).where((nome) => nome.isNotEmpty).toList(),
          horarios: horariosMapeados,
        ));
      }

      final novaDisciplina = Disciplina(
        id: isModoEdicao ? widget.disciplinaParaEditar!.id : '', // 🟢 USA O ID EXISTENTE SE FOR EDIÇÃO
        codigo: _codigoController.text.trim().toUpperCase(),
        nome: _nomeController.text.trim().toUpperCase(),
        instituto: _institutoController.text.trim(),
        departamento: _departamentoController.text.trim(),
        ementa: _ementaController.text.trim(),
        isQuadrimestral: _isQuadrimestral,
        isEstagio: _isEstagio,
        contaPresenca: _contaPresenca,
        avaliacoesAtivas: _avaliacoes.where((a) => a.ativo).map((a) => a.nome).toList(),
        formulaFinal: _formulaController.text.trim(),
        avisosGerais: _avisosController.text.trim(),
        turmas: turmasMapeadas,
        cor: Disciplina.obterPaleta(_departamentoController.text.trim()).fundoInicio, 
        isVerificada: true, 
        numeroInscritos: widget.disciplinaParaEditar?.numeroInscritos ?? 0, // Mantém os alunos inscritos intactos
        dataInicio: Timestamp.fromDate(_selecionouInicio ? _dataInicio : DateTime.now()),
        dataFim: Timestamp.fromDate(_selecionouFim ? _dataFim : DateTime.now().add(const Duration(days: 120))),
        totalAulasEstimadas: 30,
        dataEdicao: Timestamp.now(), // 🟢 CARIMBA A DATA DA EDIÇÃO!
      );

      final user = context.read<UserProvider>().currentUser;
      final bool isRepresentante = (user?.isRC ?? false) && !(user?.isGremio ?? false);

      if (isModoEdicao) {
         if (isRepresentante) {
             // 🟢 REPRESENTANTE: Envia para a coleção de sugestões
             await FirebaseFirestore.instance.collection('sugestoes_edicao').add({
                 ...novaDisciplina.toMap(),
                 'disciplinaOriginalId': novaDisciplina.id,
                 'sugeridoPor': user?.uid,
                 'status': 'em_analise',
                 'dataSugestao': Timestamp.now(),
             });
             if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sugestão enviada para análise do Grêmio!'), backgroundColor: Colors.orange));
         } else {
             // 🟢 GRÊMIO/ADMIN: Atualiza o documento original no Firebase!
             await FirebaseFirestore.instance.collection('disciplinas').doc(novaDisciplina.id).update(novaDisciplina.toMap());
             if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Edições salvas e atualizadas para todos os alunos!'), backgroundColor: Colors.green));
         }
      } else {
         // 🟢 CRIAÇÃO NOVA
         await FirestoreService().createDisciplinaGlobal(novaDisciplina);
         if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Disciplina criada e enviada ao Hub!'), backgroundColor: Colors.green));
      }

      if (mounted) {
        FocusScope.of(context).unfocus(); 
        Navigator.of(context).pop(); 
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao salvar disciplina: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoadingSave = false);
    }
  }

  // =========================================================================
  // 📅 MOTOR DO MINI-CALENDÁRIO INLINE (SELEÇÃO DE INTERVALO)
  // =========================================================================
  void _mudarMes(int delta) {
    setState(() => _mesExibido = DateTime(_mesExibido.year, _mesExibido.month + delta, 1));
  }

  void _onDayTapped(DateTime date) {
    setState(() {
      if (_tapStep == 0 || _tapStep == 2) {
        // Primeiro Toque
        _dataInicio = date;
        _dataFim = date; 
        _selecionouInicio = true;
        _selecionouFim = false; 
        _tapStep = 1;
        
        _inicioDataCtrl.text = DateFormat('dd/MM/yy').format(date);
        _fimDataCtrl.clear();
      } else if (_tapStep == 1) {
        // Segundo Toque 
        if (date.isBefore(_dataInicio)) {
          _dataFim = _dataInicio;
          _dataInicio = date;
          _inicioDataCtrl.text = DateFormat('dd/MM/yy').format(_dataInicio);
        } else {
          _dataFim = date;
        }
        _selecionouFim = true;
        _tapStep = 2;
        
        _fimDataCtrl.text = DateFormat('dd/MM/yy').format(_dataFim);
      }
    });
  }

  Widget _buildMiniCalendar() {
    const meses = ['JANEIRO', 'FEVEREIRO', 'MARÇO', 'ABRIL', 'MAIO', 'JUNHO', 'JULHO', 'AGOSTO', 'SETEMBRO', 'OUTUBRO', 'NOVEMBRO', 'DEZEMBRO'];
    DateTime firstDay = DateTime(_mesExibido.year, _mesExibido.month, 1);
    int weekdayOffset = firstDay.weekday % 7; 
    int daysInMonth = DateTime(_mesExibido.year, _mesExibido.month + 1, 0).day;
    
    List<Widget> dayWidgets = [];
    final weekdays = ['D','S','T','Q','Q','S','S'];
    for(var wd in weekdays) {
      dayWidgets.add(Center(child: Text(wd, style: TextStyle(fontFamily: 'Aristotelica', color: _corDicaInput, fontSize: _tamanhoFonteCalendarioDias, fontWeight: FontWeight.w900))));
    }
    for(int i = 0; i < weekdayOffset; i++) { dayWidgets.add(const SizedBox()); }
    
    for(int i = 1; i <= daysInMonth; i++) {
      DateTime current = DateTime(_mesExibido.year, _mesExibido.month, i);
      bool isStart = _selecionouInicio && current.year == _dataInicio.year && current.month == _dataInicio.month && current.day == _dataInicio.day;
      bool isEnd = _selecionouFim && current.year == _dataFim.year && current.month == _dataFim.month && current.day == _dataFim.day;
      bool inRange = _selecionouInicio && _selecionouFim && current.isAfter(_dataInicio.subtract(const Duration(days: 1))) && current.isBefore(_dataFim.add(const Duration(days: 1)));
      
      Color bgColor = Colors.transparent;
      Color textColor = _corTextoDigitado;
      
      if (isStart || isEnd) {
        bgColor = _corDestaque;
        textColor = Colors.white;
      } else if (inRange) {
        bgColor = _corDestaque.withOpacity(0.15);
      }
      
      dayWidgets.add(
        GestureDetector(
          onTap: () => _onDayTapped(current),
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(isStart || isEnd ? 6.0 : 4.0)),
            alignment: Alignment.center,
            child: Text('$i', style: TextStyle(fontFamily: 'Aristotelica', color: textColor, fontWeight: FontWeight.w700, fontSize: _tamanhoFonteCalendarioNumeros)),
          ),
        )
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: _corFundoInput, border: Border.all(color: _isCalendarExpanded ? _corBordaFocada : _corBordaInativa, width: 1.5), borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(icon: Icon(Icons.chevron_left, color: _corLabel, size: 28), padding: EdgeInsets.zero, constraints: const BoxConstraints(), onPressed: () => _mudarMes(-1)),
              Text('${meses[_mesExibido.month - 1]} ${_mesExibido.year}', style: TextStyle(fontFamily: 'LeagueSpartan', fontWeight: FontWeight.w900, color: _corPrincipal, fontSize: 15)),
              IconButton(icon: Icon(Icons.chevron_right, color: _corLabel, size: 28), padding: EdgeInsets.zero, constraints: const BoxConstraints(), onPressed: () => _mudarMes(1)),
            ],
          ),
          const SizedBox(height: 8),
          GridView.count(
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 7, childAspectRatio: 1.2,
            children: dayWidgets,
          ),
        ]
      ),
    );
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
    List<Widget> alteracoesGerais = [];
    bool isModoEdicao = widget.disciplinaParaEditar != null;
    final dOriginal = widget.disciplinaParaEditar;
    
    bool codigoModificado = isModoEdicao && _codigoController.text.trim().toUpperCase() != dOriginal!.codigo.trim().toUpperCase();
    bool nomeModificado = isModoEdicao && _nomeController.text.trim().toUpperCase() != dOriginal!.nome.trim().toUpperCase();
    bool instModificado = isModoEdicao && _institutoController.text.trim().toUpperCase() != dOriginal!.instituto.trim().toUpperCase();
    bool deptModificado = isModoEdicao && _departamentoController.text.trim().toUpperCase() != dOriginal!.departamento.trim().toUpperCase();
    bool ementaModificada = isModoEdicao && _ementaController.text.trim() != dOriginal!.ementa.trim();
    bool quadModificado = isModoEdicao && _isQuadrimestral != dOriginal!.isQuadrimestral;

    if (codigoModificado) alteracoesGerais.add(_buildAltText('CÓDIGO: ${dOriginal!.codigo}'));
    if (nomeModificado) alteracoesGerais.add(_buildAltText('NOME: ${dOriginal!.nome}'));
    if (instModificado) alteracoesGerais.add(_buildAltText('INSTITUTO: ${dOriginal!.instituto}'));
    if (deptModificado) alteracoesGerais.add(_buildAltText('DEPARTAMENTO: ${dOriginal!.departamento}'));
    if (ementaModificada) alteracoesGerais.add(_buildAltText('EMENTA ALTERADA'));
    if (quadModificado) alteracoesGerais.add(_buildAltText(dOriginal!.isQuadrimestral ? 'ERA QUADRIMESTRAL' : 'ERA SEMESTRAL'));

    Widget caixaPrincipal = _buildOutlinedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('CÓDIGO DA DISCIPLINA'),
          _buildRealTextField(hint: 'EX: GP2601', controller: _codigoController, focusNode: _codigoFocus, nextFocus: _nomeFocus, isModificado: codigoModificado),
          SizedBox(height: _espacoInputAteProximoTitulo),
          
          _buildLabel('NOME DA DISCIPLINA'),
          _buildRealTextField(hint: 'EX: FENÔMENOS PARANORMAIS', controller: _nomeController, focusNode: _nomeFocus, isModificado: nomeModificado),
          SizedBox(height: _espacoInputAteProximoTitulo),
          
          _buildLabel('INSTITUTO'),
          _buildInstitutoDropdown(isModificado: instModificado), // 🟢 Agora envia o estado amarelo!
          SizedBox(height: _espacoInputAteProximoTitulo),

          _buildLabel('DEPARTAMENTO'),
          _buildDepartamentoDropdown(isModificado: deptModificado), // 🟢 Agora envia o estado amarelo!
          SizedBox(height: _espacoInputAteProximoTitulo),

          _buildLabel('EMENTA'),
          _buildRealTextField(hint: 'COPIE E COLE DO JÚPITER', controller: _ementaController, focusNode: _ementaFocus, minLines: 3, maxLines: 5, isModificado: ementaModificada),
          SizedBox(height: _espacoInputAteToggle),

          Row(
            children: [
              _buildToggle(valor: _isQuadrimestral, onChanged: (v) => setState(() => _isQuadrimestral = v)),
              SizedBox(width: _espacoToggleAteTexto),
              Transform.translate(offset: Offset(0, _deslocamentoVerticalTextoToggle), child: Text('QUADRIMESTRAL', style: TextStyle(fontFamily: 'Aristotelica', fontSize: _tamanhoFonteDigitada, fontWeight: FontWeight.w700, color: _corLabel, height: 1.0))),
            ],
          ),
          
          const SizedBox(height: 12),
          Row(
            children: [
              _buildToggle(valor: _isEstagio, onChanged: (v) => setState(() => _isEstagio = v)),
              SizedBox(width: _espacoToggleAteTexto),
              Transform.translate(offset: Offset(0, _deslocamentoVerticalTextoToggle), child: Text('DISCIPLINA DE ESTÁGIO', style: TextStyle(fontFamily: 'Aristotelica', fontSize: _tamanhoFonteDigitada, fontWeight: FontWeight.w700, color: _corLabel, height: 1.0))),
            ],
          )
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('INFORMAÇÕES GERAIS'),
        _wrapWithHistory(caixaPrincipal, alteracoesGerais),
      ],
    );
  }

  Widget _buildSectionTurmasHorarios() {
    bool isModoEdicao = widget.disciplinaParaEditar != null;
    final dOriginal = widget.disciplinaParaEditar;

    List<Widget> altPeriodo = [];
    bool inicioModificado = false;
    bool fimModificado = false;

    if (isModoEdicao) {
      String dataOrigInicio = DateFormat('dd/MM/yy').format(dOriginal!.dataInicio.toDate());
      String dataOrigFim = DateFormat('dd/MM/yy').format(dOriginal.dataFim.toDate());
      inicioModificado = _inicioDataCtrl.text.trim() != dataOrigInicio;
      fimModificado = _fimDataCtrl.text.trim() != dataOrigFim;
      if (inicioModificado) altPeriodo.add(_buildAltText('INÍCIO: $dataOrigInicio'));
      if (fimModificado) altPeriodo.add(_buildAltText('FIM: $dataOrigFim'));
    }

    Widget caixaPeriodo = _buildOutlinedBox(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildRealTextField(hint: 'INÍCIO', controller: _inicioDataCtrl, focusNode: _inicioDataFocus, alignCenter: true, keyboardType: TextInputType.number, inputFormatters: [DateTextFormatter()], isModificado: inicioModificado, onChanged: (_) => _atualizarTela())),
              const SizedBox(width: 8),
              Expanded(child: _buildRealTextField(hint: 'FINAL', controller: _fimDataCtrl, focusNode: _fimDataFocus, alignCenter: true, keyboardType: TextInputType.number, inputFormatters: [DateTextFormatter()], isModificado: fimModificado, onChanged: (_) => _atualizarTela())),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () { FocusScope.of(context).unfocus(); setState(() => _isCalendarExpanded = !_isCalendarExpanded); },
                child: AnimatedContainer(duration: const Duration(milliseconds: 200), height: 47, width: 47, decoration: BoxDecoration(color: _isCalendarExpanded ? _corDestaque : _corFundoInput, border: Border.all(color: _isCalendarExpanded ? _corDestaque : _corBordaInativa, width: 1.5), borderRadius: BorderRadius.circular(6.7)), child: Icon(Icons.calendar_month_rounded, color: _isCalendarExpanded ? Colors.white : _corLabel)),
              ),
            ],
          ),
          AnimatedCrossFade(duration: const Duration(milliseconds: 300), crossFadeState: _isCalendarExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst, firstChild: const SizedBox(width: double.infinity, height: 0), secondChild: Padding(padding: const EdgeInsets.only(top: 12.0), child: _buildMiniCalendar())),
        ],
      ),
    );

    int totalTurmasNoLayout = _turmas.length;
    if (isModoEdicao && dOriginal!.turmas.length > _turmas.length) {
      totalTurmasNoLayout = dOriginal.turmas.length;
    }

    return Opacity(
      opacity: _isEstagio ? 0.3 : 1.0, 
      child: IgnorePointer(
        ignoring: _isEstagio, 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('PERÍODO DA DISCIPLINA'),
            _wrapWithHistory(caixaPeriodo, altPeriodo),
            SizedBox(height: _espacoEntreSecoes),

            _buildSectionTitle('TURMAS & HORÁRIOS', marginBottom: _espacoSecaoAteCaixa), 
            
            ...List.generate(totalTurmasNoLayout, (indexTurma) {
              bool isLast = indexTurma == totalTurmasNoLayout - 1; 

              if (isModoEdicao && indexTurma >= _turmas.length) {
                Turma tExcluida = dOriginal!.turmas[indexTurma];
                return Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0.0 : _espacoEntreSecoes),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(top: 26, bottom: 16, left: 16, right: 16),
                    decoration: BoxDecoration(color: const Color(0xFFBABBBB), borderRadius: BorderRadius.circular(6.0), border: Border.all(color: const Color(0xFF969AA0), width: 1.5)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('TURMA EXCLUÍDA', style: TextStyle(fontFamily: 'LeagueSpartan', fontSize: 18.0, fontWeight: FontWeight.w800, color: Color(0xFF737576))),
                        SizedBox(height: _espacoTituloAbaAteData),
                        Text(DateFormat('dd/MM/yyyy').format(DateTime.now()), style: const TextStyle(fontFamily: 'Lato', fontStyle: FontStyle.italic, fontSize: 14.0, fontWeight: FontWeight.w800, color: Color(0xFFF0F0F0))),
                        SizedBox(height: _espacoDataAbaAteTexto),
                        _buildAltText('TURMA: ${tExcluida.codigo}', tachado: true),
                      ],
                    ),
                  ),
                );
              }

              TurmaInputData turma = _turmas[indexTurma];
              bool isNovaTurmaNaEdicao = isModoEdicao && indexTurma >= dOriginal!.turmas.length;
              
              List<Widget> altTurma = [];
              Turma? tOriginal;
              bool turmaCodigoModificado = false;

              if (isNovaTurmaNaEdicao) {
                altTurma.add(_buildAltText('CRIADA NESTA EDIÇÃO'));
              } else if (isModoEdicao) {
                tOriginal = dOriginal!.turmas[indexTurma];
                
                turmaCodigoModificado = turma.codigoCtrl.text.trim() != tOriginal.codigo;
                if (turmaCodigoModificado) altTurma.add(_buildAltText('CÓDIGO: ${tOriginal.codigo}'));

                int maxProfs = turma.professores.length > tOriginal.professores.length ? turma.professores.length : tOriginal.professores.length;
                for (int p = 0; p < maxProfs; p++) {
                  if (p >= turma.professores.length) {
                    altTurma.add(_buildAltText('PROFESSOR EXCLUÍDO: ${tOriginal.professores[p]}'));
                  } else if (p >= tOriginal.professores.length) {
                    if (turma.professores[p].nomeCtrl.text.trim().isNotEmpty) {
                      altTurma.add(_buildAltText('PROFESSOR ADICIONADO: ${turma.professores[p].nomeCtrl.text.trim()}', tachado: true));
                    }
                  } else {
                    if (turma.professores[p].nomeCtrl.text.trim().toUpperCase() != tOriginal.professores[p].toUpperCase()) {
                      altTurma.add(_buildAltText('PROFESSOR EDITADO: ERA ${tOriginal.professores[p]}'));
                    }
                  }
                }

                int maxHorarios = turma.horarios.length > tOriginal.horarios.length ? turma.horarios.length : tOriginal.horarios.length;
                for (int h = 0; h < maxHorarios; h++) {
                  if (h >= turma.horarios.length) {
                    altTurma.add(_buildAltText('HORÁRIO EXCLUÍDO: ${tOriginal.horarios[h].dia} ${tOriginal.horarios[h].inicio}-${tOriginal.horarios[h].fim}'));
                  } else if (h >= tOriginal.horarios.length) {
                    var horAtual = turma.horarios[h];
                    altTurma.add(_buildAltText('HORÁRIO ADICIONADO: ${horAtual.diaCtrl.text} ${horAtual.inicioCtrl.text}-${horAtual.fimCtrl.text}', tachado: true));
                    
                    if (horAtual.salaCtrl.text.trim().isNotEmpty) {
                      altTurma.add(_buildAltText('LOCAL ADICIONADO: ${horAtual.salaCtrl.text.trim()}', tachado: true));
                    }
                    if (horAtual.isLaboratorio) {
                      altTurma.add(_buildAltText('LABORATÓRIO ADICIONADO', tachado: true));
                    }
                    // Varre os EPIs de um horário NOVO
                    List<String> epiAtual = (horAtual.isLaboratorio && horAtual.precisaEpi) ? horAtual.epis.where((e) => e.ativo).map((e) => e.nome).toList() : [];
                    for (var epi in epiAtual) {
                      altTurma.add(_buildAltText('EPI ADICIONADO: $epi', tachado: true));
                    }

                  } else {
                    var horAtual = turma.horarios[h];
                    var horAntigo = tOriginal.horarios[h];

                    bool changedHora = horAtual.diaCtrl.text != horAntigo.dia || horAtual.inicioCtrl.text != horAntigo.inicio || horAtual.fimCtrl.text != horAntigo.fim;
                    if (changedHora) altTurma.add(_buildAltText('HORÁRIO EDITADO: ERA ${horAntigo.dia} ${horAntigo.inicio}-${horAntigo.fim}'));

                    if (horAtual.salaCtrl.text.trim() != horAntigo.local) altTurma.add(_buildAltText('LOCAL EDITADO: ERA ${horAntigo.local}'));

                    if (horAtual.isLaboratorio != horAntigo.isLaboratorio) {
                      altTurma.add(_buildAltText(horAntigo.isLaboratorio ? 'ERA LABORATÓRIO' : 'NÃO ERA LABORATÓRIO'));
                    }
                    if (horAtual.isLaboratorio && (horAtual.precisaEpi != horAntigo.precisaEpi)) {
                      altTurma.add(_buildAltText(horAntigo.precisaEpi ? 'EXIGIA EPI' : 'NÃO EXIGIA EPI'));
                    }

                    List<String> epiAtual = (horAtual.isLaboratorio && horAtual.precisaEpi) ? horAtual.epis.where((e) => e.ativo).map((e) => e.nome).toList() : [];
                    List<String> epiAntigo = (horAntigo.isLaboratorio && horAntigo.precisaEpi) ? horAntigo.epis : [];
                    
                    for (var ea in epiAntigo) {
                      if (!epiAtual.contains(ea)) altTurma.add(_buildAltText('EPI REMOVIDO: $ea'));
                    }
                    for (var en in epiAtual) {
                      if (!epiAntigo.contains(en)) altTurma.add(_buildAltText('EPI ADICIONADO: $en', tachado: true));
                    }
                  }
                }
              }

              Color corBordaTurma = isNovaTurmaNaEdicao ? const Color(0xFF969AA0) : _corDestaque;

              Widget caixaTurma = _buildOutlinedBox(
                corBordaPersonalizada: corBordaTurma, 
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
                            onTap: () { setState(() { turma.dispose(); _turmas.removeAt(indexTurma); }); },
                            child: Image.asset('assets/images/x_icon.png', width: _tamanhoIconeX, height: _tamanhoIconeX, color: _corDicaInput),
                          ),
                      ],
                    ),
                    SizedBox(height: _espacoInputAteProximoTitulo),

                    _buildLabel('CÓDIGO DE TURMA'),
                    _buildRealTextField(
                      hint: 'EX: 2026101', controller: turma.codigoCtrl, focusNode: turma.codigoFocus, 
                      nextFocus: turma.professores.isNotEmpty ? turma.professores.first.nomeFocus : null, 
                      isModificado: turmaCodigoModificado,
                      onChanged: (_) => _atualizarTela()
                    ), 
                    SizedBox(height: _espacoInputAteProximoTitulo),

                    _buildLabel('PROFESSOR'),
                    ...turma.professores.asMap().entries.map((eProf) {
                      int pIndex = eProf.key;
                      ProfessorInputData prof = eProf.value;
                      FocusNode? nextFocus = (pIndex < turma.professores.length - 1) ? turma.professores[pIndex + 1].nomeFocus : (turma.horarios.isNotEmpty ? turma.horarios.first.salaFocus : null);

                      bool isProfNovo = isModoEdicao && tOriginal != null && pIndex >= tOriginal.professores.length;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            // 🟢 ADICIONADO ONCHANGED
                            Expanded(child: _buildRealTextField(hint: 'NOME DO PROFESSOR', controller: prof.nomeCtrl, focusNode: prof.nomeFocus, nextFocus: nextFocus, isModificado: isProfNovo, onChanged: (_) => _atualizarTela())),
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
                    }).toList(),
                    _buildNovoBotaoAcao('+ ADD', () => setState(() { var novoProf = ProfessorInputData(onUpdate: _atualizarTela); novoProf.iniciarListeners(); turma.professores.add(novoProf); })),
                    SizedBox(height: _espacoInputAteProximoTitulo),

                    _buildLabel('HORÁRIOS & LOCAIS'),
                    ...turma.horarios.asMap().entries.map((eHor) {
                      int hIndex = eHor.key;
                      HorarioInputData hor = eHor.value;
                      
                      bool salaModificada = false;
                      if (tOriginal != null && hIndex < tOriginal.horarios.length) {
                        salaModificada = hor.salaCtrl.text.trim() != tOriginal.horarios[hIndex].local;
                      }

                      return Padding(
                        padding: EdgeInsets.only(bottom: _espacoLocalAteAdd),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(child: _buildDiaCasinoWidget(hor)), const SizedBox(width: 8),
                                Expanded(child: _buildTimeCasinoWidget(hor, false)), const SizedBox(width: 8),
                                Expanded(child: _buildTimeCasinoWidget(hor, true)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                // 🟢 ADICIONADO ONCHANGED
                                Expanded(child: _buildRealTextField(hint: 'SALA / LOCAL', controller: hor.salaCtrl, focusNode: hor.salaFocus, isModificado: salaModificada, onChanged: (_) => _atualizarTela())),
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
                    }).toList(),
                    _buildNovoBotaoAcao('+ ADD', () => setState(() { var novoHor = HorarioInputData(onUpdate: _atualizarTela); novoHor.iniciarListeners(); turma.horarios.add(novoHor); })),
                    
                    if (isLast) ...[
                      SizedBox(height: _espacoInputAteProximoTitulo),
                      _buildNovoBotaoAcao('+ CRIAR NOVA TURMA', () => setState(() { var novaTurma = TurmaInputData(onUpdate: _atualizarTela); novaTurma.iniciarListeners(); _turmas.add(novaTurma); }), expandir: true),
                    ]
                  ],
                ),
              );

              return Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0.0 : _espacoEntreSecoes),
                child: _wrapWithHistory(
                  caixaTurma, 
                  altTurma, 
                  tituloAba: isNovaTurmaNaEdicao ? 'NOVA TURMA (RASCUNHO)' : 'ANTERIORMENTE',
                  dataPersonalizada: isNovaTurmaNaEdicao ? DateTime.now() : null 
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLogisticaLaboratorio() {
    List<Widget> altLogistica = [];
    bool isModoEdicao = widget.disciplinaParaEditar != null;
    final dOriginal = widget.disciplinaParaEditar;

    if (isModoEdicao) {
      if (_contaPresenca != dOriginal!.contaPresenca) {
        altLogistica.add(_buildAltText(dOriginal.contaPresenca ? 'TINHA CHAMADA (PRESENÇA)' : 'NÃO TINHA CHAMADA (PRESENÇA)'));
      }
      
      // Analisando se alguma turma mudou o status de laboratorio
      bool labMudou = false;
      for (int i = 0; i < _turmas.length; i++) {
        if (i < dOriginal.turmas.length) {
          for (int j = 0; j < _turmas[i].horarios.length; j++) {
            if (j < dOriginal.turmas[i].horarios.length) {
              if (_turmas[i].horarios[j].isLaboratorio != dOriginal.turmas[i].horarios[j].isLaboratorio) labMudou = true;
            }
          }
        }
      }
      if (labMudou) altLogistica.add(_buildAltText('STATUS DE LABORATÓRIO ALTERADO'));
    }

    Widget caixaLogistica = Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(_raioBordaCaixaPrincipal),
          topRight: Radius.circular(_raioBordaCaixaPrincipal),
          bottomLeft: Radius.circular(altLogistica.isNotEmpty ? 0 : _raioBordaCaixaPrincipal),
          bottomRight: Radius.circular(altLogistica.isNotEmpty ? 0 : _raioBordaCaixaPrincipal),
        ),
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
                              Transform.rotate(angle: turma.isLogisticaExpanded ? 3.14159 : 0, child: Image.asset('assets/images/seta_icon.png', width: _tamanhoIconeSeta, height: _tamanhoIconeSeta, color: _corLabel)),
                              SizedBox(width: _espacoSetaTexto),
                              Text(turma.getDisplayTitle(tIndex), style: TextStyle(fontFamily: 'LeagueSpartan', fontWeight: FontWeight.w800, fontSize: _tamanhoTextoLabel, color: _corLabel)),
                            ],
                          ),
                        ),
                      ),
                      
                      AnimatedCrossFade(
                        duration: const Duration(milliseconds: 300),
                        crossFadeState: turma.isLogisticaExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                        firstChild: const SizedBox(width: double.infinity, height: 0),
                        secondChild: SizedBox(
                          width: double.infinity,
                          child: Column(
                            children: turma.horarios.map((hor) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(color: _corFundoInput, borderRadius: BorderRadius.circular(_raioBordaCaixaPrincipal), border: Border.all(color: _corBordaInativa, width: 1.5)),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start, 
                                    children: [
                                      Text('${hor.diaCtrl.text}   ${hor.inicioCtrl.text} - ${hor.fimCtrl.text}', style: const TextStyle(fontFamily: 'Aristotelica', fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF969AA0))),
                                      const SizedBox(height: 14),

                                      Row(
                                        children: [
                                          _buildToggle(valor: hor.isLaboratorio, onChanged: (v) { setState(() { hor.isLaboratorio = v; if (!v) hor.precisaEpi = false; }); }),
                                          SizedBox(width: _espacoToggleAteTexto),
                                          Transform.translate(offset: Offset(0, _deslocamentoVerticalTextoToggle), child: Text('É LABORATÓRIO?', style: TextStyle(fontFamily: 'Aristotelica', fontSize: _tamanhoFonteDigitada, fontWeight: FontWeight.w700, color: _corLabel.withOpacity(hor.isLaboratorio ? 1.0 : 0.5), height: 1.0))),
                                        ],
                                      ),
                                      
                                      AnimatedCrossFade(
                                        duration: const Duration(milliseconds: 300), crossFadeState: hor.isLaboratorio ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                                        firstChild: const SizedBox(width: double.infinity, height: 0),
                                        secondChild: Container(
                                          width: double.infinity, padding: const EdgeInsets.only(top: 14.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              _buildFrequenciaSelector(hor),
                                              if (hor.frequenciaLab != 3) _buildLabDatesText(hor)
                                              else
                                                // Código das bolinhas de data customizadas...
                                                const SizedBox(),
                                            ],
                                          ),
                                        ),
                                      ),
                                      
                                      const SizedBox(height: 14),
                                      Row(
                                        children: [
                                          _buildToggle(valor: hor.precisaEpi, isEnabled: hor.isLaboratorio, onChanged: (v) => setState(() => hor.precisaEpi = v)),
                                          SizedBox(width: _espacoToggleAteTexto),
                                          Transform.translate(offset: Offset(0, _deslocamentoVerticalTextoToggle), child: Text('PRECISA DE EPIS?', style: TextStyle(fontFamily: 'Aristotelica', fontSize: _tamanhoFonteDigitada, fontWeight: FontWeight.w700, color: _corLabel.withOpacity(hor.isLaboratorio ? (hor.precisaEpi ? 1.0 : 0.5) : 0.3), height: 1.0))),
                                        ],
                                      ),
                                      
                                      AnimatedCrossFade(
                                        duration: const Duration(milliseconds: 300), crossFadeState: hor.precisaEpi ? CrossFadeState.showSecond : CrossFadeState.showFirst,
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
                                                      onTap: () { setState(() { if (epi.isCustom && epi.ativo) { hor.epis.remove(epi); } else { epi.ativo = !epi.ativo; } }); },
                                                      child: _buildEpiChip(epi.nome, ativo: epi.ativo),
                                                    );
                                                  }).toList(),

                                                  if (hor.isAddingEpi)
                                                    Container(
                                                      height: _alturaBotoes, width: _larguraCaixaEpiNova, 
                                                      decoration: BoxDecoration(color: _corFundoInput, border: Border.all(color: const Color(0xFF0085FF), width: 1.7), borderRadius: BorderRadius.circular(6.7)),
                                                      alignment: Alignment.center,
                                                      child: TextField(
                                                        controller: hor.newEpiCtrl, focusNode: hor.newEpiFocus, autofocus: true, textAlign: TextAlign.center,
                                                        inputFormatters: [LengthLimitingTextInputFormatter(20)],
                                                        style: TextStyle(fontFamily: 'Aristotelica', fontWeight: FontWeight.w700, fontSize: _tamanhoTextoEpiNovo, color: _corTextoDigitado, letterSpacing: 1.2),
                                                        cursorColor: _corBordaFocada, cursorWidth: 2.5, cursorHeight: 20, cursorRadius: const Radius.circular(5.0),
                                                        decoration: InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.only(bottom: _deslocamentoVerticalEpiNovo)),
                                                        onSubmitted: (_) { hor.newEpiFocus.unfocus(); },
                                                      ),
                                                    )
                                                  else
                                                    GestureDetector(
                                                      onTap: () { setState(() => hor.isAddingEpi = true); hor.newEpiFocus.requestFocus(); },
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
    );

    return Opacity(
      opacity: _isEstagio ? 0.3 : 1.0, 
      child: IgnorePointer(
        ignoring: _isEstagio, 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('LOGÍSTICA & LABORATÓRIO'),
            _wrapWithHistory(caixaLogistica, altLogistica), // 🟢 Aplica a aba Cinza aqui!
          ],
        ),
      ),
    );
  }

  // 🟢 CORREÇÃO 2: Trazendo de volta as instruções claras e o "aulas" inteligente!
  Widget _buildLabDatesText(HorarioInputData hor) {
    List<DateTime> todas = hor.obterDatasSemestre(_dataInicio, _dataFim);
    
    if (todas.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 8.0, left: 2.0),
        child: Text('O período é muito curto para ter aulas neste dia da semana.', style: TextStyle(fontFamily: 'Lato', fontSize: 11, color: _corDicaInput)),
      );
    }

    List<DateTime> validas = [];
    if (hor.frequenciaLab == 0) validas = todas;
    else if (hor.frequenciaLab == 1) validas = [for (int i=0; i<todas.length; i+=2) todas[i]];
    else if (hor.frequenciaLab == 2) validas = [for (int i=1; i<todas.length; i+=2) todas[i]];

    if (validas.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 8.0, left: 2.0),
        child: Text('Nenhuma aula possível com esta configuração.', style: TextStyle(fontFamily: 'Lato', fontSize: 11, color: _corDicaInput)),
      );
    }

    String dInicio = DateFormat('dd/MM').format(validas.first);
    String dFim = DateFormat('dd/MM').format(validas.last);
    int total = validas.length;

    // 🟢 Instruções perfeitas retornadas conforme sua pedida!
    String desc = hor.frequenciaLab == 0 
        ? "Aulas toda semana."
        : hor.frequenciaLab == 1 
            ? "Aulas a cada 15 dias iniciando a partir da 1ª ${hor.diaCtrl.text.toUpperCase()} disponível.\nToque em QUINZENAL 1 novamente para alternar."
            : "Aulas a cada 15 dias iniciando a partir da 2ª ${hor.diaCtrl.text.toUpperCase()} disponível.\nToque em QUINZENAL 2 novamente para alternar.";

    return Padding(
      padding: const EdgeInsets.only(top: 8.0, left: 2.0),
      child: Text(
        '$desc\nTotal: $total aulas. Começando em $dInicio e terminando em $dFim.',
        style: TextStyle(fontFamily: 'Lato', fontSize: 11, color: _corDicaInput, height: 1.3),
      ),
    );
  }

  Widget _buildSectionCriteriosAvaliacao() {
    List<Widget> altCriterios = [];
    bool isModoEdicao = widget.disciplinaParaEditar != null;
    final dOriginal = widget.disciplinaParaEditar;
    
    bool formulaModificada = isModoEdicao && _formulaController.text.trim() != dOriginal!.formulaFinal.trim();
    bool avisosModificados = isModoEdicao && _avisosController.text.trim() != dOriginal!.avisosGerais.trim();

    if (isModoEdicao) {
      List<String> avaliacoesAtuais = _avaliacoes.where((a) => a.ativo).map((a) => a.nome).toList();
      List<String> avaliacoesAntigas = dOriginal!.avaliacoesAtivas;

      for (var ant in avaliacoesAntigas) {
        if (!avaliacoesAtuais.contains(ant)) altCriterios.add(_buildAltText('TINHA: $ant'));
      }
      for (var at in avaliacoesAtuais) {
        // 🟢 Utilizando o Tachado Inteligente após os dois-pontos!
        if (!avaliacoesAntigas.contains(at)) altCriterios.add(_buildAltText('AVALIAÇÃO ADICIONADA: $at', tachado: true));
      }

      if (formulaModificada) altCriterios.add(_buildAltText('FÓRMULA: ${dOriginal.formulaFinal}'));
    }

    final user = context.read<UserProvider>().currentUser;
    final bool isRepresentante = (user?.isRC ?? false) && !(user?.isGremio ?? false);
    
    String textoBotao = isModoEdicao ? (isRepresentante ? 'SUGERIR EDIÇÕES' : 'SALVAR EDIÇÕES') : 'SALVAR DISCIPLINA';

    List<Color> coresBotao = isRepresentante ? const [Color(0xFFEBC12B), Color(0xFFD38F0D)] : const [Color(0xFF7C9F19), Color(0xFFAFCB00)]; 
    Color corBordaBotao = isRepresentante ? const Color(0xFFFFBF00) : const Color(0xFFCEDD26);

    // 🟢 CRIANDO A CAIXA DOS CRITÉRIOS
    Widget caixaCriterios = _buildOutlinedBox(
      child: _isEstagio 
        ? Container(
            width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 30), alignment: Alignment.center,
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
                      onTap: () => setState(() { if (av.isCustom && av.ativo) { _avaliacoes.remove(av); } else { av.ativo = !av.ativo; } }),
                      child: _buildEpiChip(av.nome, ativo: av.ativo),
                    );
                  }).toList(),

                  if (_isAddingAvaliacao)
                    Container(
                      height: _alturaBotoes, width: _larguraCaixaAvaliacaoNova, 
                      decoration: BoxDecoration(color: _corFundoInput, border: Border.all(color: const Color(0xFF0085FF), width: 1.7), borderRadius: BorderRadius.circular(6.7)),
                      alignment: Alignment.center,
                      child: TextField(
                        controller: _newAvaliacaoCtrl, focusNode: _newAvaliacaoFocus, autofocus: true, textAlign: TextAlign.center,
                        inputFormatters: [LengthLimitingTextInputFormatter(20)],
                        style: TextStyle(fontFamily: 'Aristotelica', fontWeight: FontWeight.w700, fontSize: _tamanhoTextoEpiNovo, color: _corTextoDigitado, letterSpacing: 1.2),
                        cursorColor: _corBordaFocada, cursorWidth: 2.5, cursorHeight: 20, cursorRadius: const Radius.circular(5.0),
                        decoration: InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.only(bottom: _deslocamentoVerticalEpiNovo)),
                        onSubmitted: (_) { _newAvaliacaoFocus.unfocus(); },
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: () { setState(() => _isAddingAvaliacao = true); _newAvaliacaoFocus.requestFocus(); },
                      child: _buildEpiChip('+ ADD', ativo: false),
                    )
                ],
              ),
              SizedBox(height: _espacoInputAteProximoTitulo),
              
              _buildLabel('FÓRMULA FINAL'),
              _buildRealTextField(
                hint: 'EX: (P1+P2+T1)/3', controller: _formulaController, focusNode: _formulaFocus, 
                nextFocus: _avisosFocus, isModificado: formulaModificada
              ),
            ],
          ),
    );

    // 🟢 CRIANDO A CAIXA DOS AVISOS (Sem Box Duplo)
    Widget caixaAvisos = _buildRealTextField(
      hint: 'ESCREVA DICAS, AVISOS, CULTURAS DA DISCIPLINA...', 
      controller: _avisosController, focusNode: _avisosFocus, minLines: 3, maxLines: 5,
      isModificado: avisosModificados
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('CRITÉRIO DE AVALIAÇÃO'),
        _wrapWithHistory(caixaCriterios, altCriterios), // 🟢 Wrapper da primeira caixa
        
        SizedBox(height: _espacoEntreSecoes),
        _buildSectionTitle('AVISOS GERAIS E COMPLEMENTARES'),
        
        _wrapWithHistory(caixaAvisos, avisosModificados ? [_buildAltText('AVISOS GERAIS ALTERADOS')] : []), // 🟢 Wrapper da segunda caixa
        
        SizedBox(height: _espacoAvisosAteSalvar),

        GestureDetector(
          onTap: _isLoadingSave ? null : _salvarDisciplina, 
          child: Container(
            height: _alturaBotaoSalvar, width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: coresBotao, begin: Alignment.centerLeft, end: Alignment.centerRight), 
              border: Border.all(color: corBordaBotao, width: 1.7), 
              borderRadius: BorderRadius.circular(6.7)
            ),
            alignment: Alignment.center,
            child: _isLoadingSave 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF303B02)))
                : Padding(
                    padding: const EdgeInsets.only(top: 3.0), 
                    child: Text(textoBotao, style: const TextStyle(fontFamily: 'Aristotelica', fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF303B02), letterSpacing: 1.2))
                  ),
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

  // 🟢 Box Principal agora aceita cor personalizada da borda (Para a Nova Turma Cinza)
  Widget _buildOutlinedBox({required Widget child, Color? corBordaPersonalizada}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: _paddingTopCaixaPrincipal, bottom: _paddingBottomCaixaPrincipal, left: _paddingLateralCaixaPrincipal, right: _paddingLateralCaixaPrincipal), 
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_raioBordaCaixaPrincipal), 
        border: Border.all(color: corBordaPersonalizada ?? _corDestaque, width: 1.5), // 🟢 Cor dinâmica
      ),
      child: child,
    );
  }

  // 🟢 NOVO: Gerador de textos para o Histórico (Tachado Inteligente Pós Dois-Pontos)
  Widget _buildAltText(String text, {bool tachado = false}) {
    // Se deve ser tachado E contém dois-pontos (ex: "PROFESSOR ADICIONADO: João")
    if (tachado && text.contains(':')) {
      final parts = text.split(':');
      final prefix = '${parts[0]}:';
      final suffix = parts.sublist(1).join(':'); // Junta o resto caso tenha mais de um ':'

      return Padding(
        padding: EdgeInsets.only(bottom: _espacoEntreTextosAba),
        child: RichText(
          text: TextSpan(
            style: const TextStyle(fontFamily: 'Aristotelica', fontSize: 19.0, fontWeight: FontWeight.w700, color: Color(0xFFF0F0F0), height: 1.2),
            children: [
              TextSpan(text: prefix),
              TextSpan(
                text: suffix,
                style: const TextStyle(
                  decoration: TextDecoration.lineThrough,
                  decorationColor: Color(0xFFF0F0F0),
                  decorationThickness: 2.0,
                )
              ),
            ],
          ),
        ),
      );
    }

    // Comportamento normal ou tachado simples (Ex: "T1")
    return Padding(
      padding: EdgeInsets.only(bottom: _espacoEntreTextosAba),
      child: Text(
        text, 
        style: TextStyle(
          fontFamily: 'Aristotelica', 
          fontSize: 19.0, 
          fontWeight: FontWeight.w700, 
          color: const Color(0xFFF0F0F0), 
          height: 1.2,
          decoration: tachado ? TextDecoration.lineThrough : TextDecoration.none,
          decorationColor: const Color(0xFFF0F0F0),
          decorationThickness: 2.0,
        )
      ),
    );
  }

  Widget _wrapWithHistory(Widget mainBox, List<Widget> alteracoes, {String tituloAba = 'ANTERIORMENTE', DateTime? dataPersonalizada}) {
    if (alteracoes.isEmpty) return mainBox;

    String dataExibicao = '';
    if (dataPersonalizada != null) {
      dataExibicao = DateFormat('dd/MM/yyyy').format(dataPersonalizada); // 🟢 Força a data de hoje
    } else if (widget.disciplinaParaEditar != null) {
      if (widget.disciplinaParaEditar!.dataEdicao != null) {
        dataExibicao = DateFormat('dd/MM/yyyy').format(widget.disciplinaParaEditar!.dataEdicao!.toDate());
      } else {
        dataExibicao = DateFormat('dd/MM/yyyy').format(widget.disciplinaParaEditar!.dataInicio.toDate());
      }
    } else {
      dataExibicao = DateFormat('dd/MM/yyyy').format(DateTime.now());
    }

    Widget historyBox = Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: _espacoCimaTituloAba, bottom: 16, left: 16, right: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFBABBBB),
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(6.0), bottomRight: Radius.circular(6.0)),
        border: Border.all(color: const Color(0xFF969AA0), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tituloAba, style: const TextStyle(fontFamily: 'LeagueSpartan', fontSize: 18.0, fontWeight: FontWeight.w800, color: Color(0xFF737576))),
          SizedBox(height: _espacoTituloAbaAteData),
          Text(dataExibicao, style: const TextStyle(fontFamily: 'Lato', fontStyle: FontStyle.italic, fontSize: 14.0, fontWeight: FontWeight.w800, color: Color(0xFFF0F0F0))),
          SizedBox(height: _espacoDataAbaAteTexto),
          ...alteracoes, 
        ],
      ),
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Opacity(opacity: 0.0, child: mainBox), 
            Transform.translate(offset: const Offset(0, -12), child: historyBox),
          ],
        ),
        Positioned(top: 0, left: 0, right: 0, child: mainBox),
      ],
    );
  }

  // 🟢 NOVA FUNÇÃO: A aba cinza de "ANTERIORMENTE"
  Widget _buildHistoryBox(List<String> alteracoes) {
    if (alteracoes.isEmpty) return const SizedBox.shrink();
    
    // Pegando a data atual para o histórico de edição
    String dataEdicao = DateFormat('dd/MM/yyyy').format(DateTime.now());

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFBABBBB),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(6.0),
          bottomRight: Radius.circular(6.0),
        ),
        border: Border.all(color: const Color(0xFF969AA0), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ANTERIORMENTE', style: TextStyle(fontFamily: 'LeagueSpartan', fontSize: 18.0, fontWeight: FontWeight.w800, color: Color(0xFF737576))),
          Text(dataEdicao, style: const TextStyle(fontFamily: 'LeagueSpartan', fontSize: 14.0, fontWeight: FontWeight.w800, color: Color(0xFF737576))),
          const SizedBox(height: 8),
          ...alteracoes.map((alt) => Text(alt, style: const TextStyle(fontFamily: 'Aristotelica', fontSize: 19.0, fontWeight: FontWeight.w700, color: Color(0xFFF0F0F0), height: 1.2))),
        ],
      ),
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
    bool isModificado = false, // 🟢 NOVO PARÂMETRO
    int? minLines = 1,
    int? maxLines = 1,
    TextAlign textAlign = TextAlign.start, 
    bool alignCenter = false,
    TextInputType keyboardType = TextInputType.text,
    FocusNode? nextFocus,
    ValueChanged<String>? onChanged, 
    List<TextInputFormatter>? inputFormatters, 
  }) {
    final bool isPreenchido = controller.text.isNotEmpty;
    final bool isMultiline = minLines != null && minLines > 1;
    
    // 🟢 Lógica de cores: Amarelo se editado, senão segue o padrão
    Color corBordaAtiva = isModificado ? const Color(0xFFFFBF00) : _corBordaFocada;
    Color corBordaPreenchida = isModificado ? const Color(0xFFFFBF00) : const Color(0xFFA1BF06);

    return SizedBox(
      height: !isMultiline ? 47 : null,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        minLines: minLines,
        maxLines: maxLines,
        onChanged: onChanged,
        textAlign: alignCenter ? TextAlign.center : textAlign,
        keyboardType: isMultiline ? TextInputType.multiline : keyboardType,
        textInputAction: nextFocus != null ? TextInputAction.next : (isMultiline ? TextInputAction.newline : TextInputAction.done),
        inputFormatters: inputFormatters, 
        onSubmitted: (_) { 
          if (nextFocus != null) { FocusScope.of(context).requestFocus(nextFocus); } else if (!isMultiline) { FocusScope.of(context).unfocus(); } 
        },
        style: TextStyle(fontFamily: 'Aristotelica', fontWeight: FontWeight.w700, fontSize: _tamanhoFonteDigitada, color: _corTextoDigitado),
        textAlignVertical: isMultiline ? TextAlignVertical.top : TextAlignVertical.center,
        cursorColor: corBordaAtiva, 
        cursorWidth: 2.5, cursorHeight: 20, cursorRadius: const Radius.circular(5.0),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontFamily: 'Aristotelica', color: _corDicaInput, fontSize: _tamanhoFonteDica, height: 1.0),
          contentPadding: EdgeInsets.only(left: 11.0, right: 11.0, top: 15.0, bottom: isMultiline ? 15.0 : 2.0),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6.7), borderSide: BorderSide(color: isPreenchido ? corBordaPreenchida : _corBordaInativa, width: 1.5)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6.7), borderSide: BorderSide(color: corBordaAtiva, width: 2.0)),
          fillColor: _corFundoInput,
          filled: true,
        ),
      ),
    );
  }

  Widget _buildInstitutoDropdown({bool isModificado = false}) {
    bool isPreenchido = _institutoController.text.isNotEmpty;
    Color corBordaAtual = isModificado ? const Color(0xFFFFBF00) : (isPreenchido ? const Color(0xFFA1BF06) : _corBordaInativa);
    
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
            color: _isInstitutoExpanded ? _corBordaFocada : corBordaAtual, // 🟢 Aplica o amarelo aqui
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
                  Container(
                    constraints: const BoxConstraints(maxHeight: 220), 
                    child: ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return const LinearGradient(
                          begin: Alignment.topCenter, end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black, Colors.black, Colors.transparent],
                          stops: [0.0, 0.05, 0.95, 1.0], 
                        ).createShader(bounds);
                      },
                      blendMode: BlendMode.dstIn,
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
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

  Widget _buildDepartamentoDropdown({bool isModificado = false}) {
    bool isInstitutoSelecionado = _institutoController.text.isNotEmpty;
    bool isPreenchido = _departamentoController.text.isNotEmpty;
    Color corBordaAtual = isModificado ? const Color(0xFFFFBF00) : (isPreenchido ? const Color(0xFFA1BF06) : _corBordaInativa);
    
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
              color: _isDeptExpanded ? _corBordaFocada : corBordaAtual, // 🟢 Aplica o amarelo aqui
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
                    Container(
                      constraints: const BoxConstraints(maxHeight: 220),
                      child: ShaderMask(
                        shaderCallback: (Rect bounds) {
                          return const LinearGradient(
                            begin: Alignment.topCenter, end: Alignment.bottomCenter,
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
    int maxTime = isFim ? 1380 : 1370; 
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
                    hor.fimVal = newMins; 
                    hor.fimCtrl.text = _formatMinsToTime(newMins); 
                    // 🟢 MÁGICA: Força a interface a reconhecer a nova digitação de FIM!
                    _atualizarTela();
                  } else {
                    hor.inicioVal = newMins; 
                    hor.inicioCtrl.text = _formatMinsToTime(newMins);
                    
                    int minFimPermitido = hor.inicioVal + 10;
                    if (hor.fimVal < minFimPermitido) {
                      hor.fimVal = minFimPermitido;
                      if (hor.fimVal > 1380) hor.fimVal = 1380;
                      hor.fimCtrl.text = _formatMinsToTime(hor.fimVal);
                    }
                    
                    int novoIndexFim = (hor.fimVal - minFimPermitido) ~/ 10;
                    if(novoIndexFim < 0) novoIndexFim = 0;
                    
                    // 🟢 MÁGICA: Recria o controlador de FIM para sincronizar com a nova lista de Início
                    hor.fimScroll.dispose();
                    hor.fimScroll = FixedExtentScrollController(initialItem: novoIndexFim);
                    
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
      onTap: isEnabled ? () => onChanged(!valor) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: _larguraToggle, height: _alturaToggle, padding: EdgeInsets.all(_paddingInternoToggle),
        decoration: BoxDecoration(
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
    bool isModoEdicao = widget.disciplinaParaEditar != null; // 🟢 Verifica o modo

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
                    RichText(
                      textAlign: TextAlign.right,
                      text: TextSpan(
                        style: const TextStyle(fontFamily: 'Aristotelica', fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFFBCBEBF), height: 1.1),
                        children: [
                          // 🟢 MUDA O TEXTO DINAMICAMENTE
                          TextSpan(text: isModoEdicao ? 'DESFAZER\n' : 'LIMPAR\n'),
                          TextSpan(text: isModoEdicao ? 'EDIÇÃO?' : 'DISCIPLINA?'),
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

// 🟢 NOVO: FORMATADOR DE DATAS (Coloca as barras / sozinho enquanto digita)
class DateTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (text.length > 6) text = text.substring(0, 6);
    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if ((i == 1 || i == 3) && i != text.length - 1) {
        buffer.write('/');
      }
    }
    String result = buffer.toString();
    return newValue.copyWith(text: result, selection: TextSelection.collapsed(offset: result.length));
  }
}

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
    _aplicarAutoScroll(codigoFocus);
    
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
    _aplicarAutoScroll(nomeFocus); 
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
    
    _aplicarAutoScroll(salaFocus);
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
        if (inicioVal > 1370) inicioVal = 1370; 
        
        inicioCtrl.text = _formatMinsToTime(inicioVal);
        
        if (fimVal <= inicioVal) {
          fimVal = inicioVal + 10;
          if (fimVal > 1380) fimVal = 1380;
          fimCtrl.text = _formatMinsToTime(fimVal);
        }

        int roundedInicio10 = (inicioVal / 10).round() * 10;
        inicioScroll.dispose();
        inicioScroll = FixedExtentScrollController(initialItem: (roundedInicio10 - 450) ~/ 10);

        int minFimPermitido = inicioVal + 10;
        if(minFimPermitido > 1380) minFimPermitido = 1380;
        
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
        if (fimVal > 1380) fimVal = 1380;

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
              alignment: 0.3, 
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

  // 🟢 MÁGICA: Agora essa função varre apenas o período de início e fim da disciplina!
  List<DateTime> obterDatasSemestre(DateTime dataInicio, DateTime dataFim) {
    List<DateTime> dates = [];
    DateTime now = DateTime(dataInicio.year, dataInicio.month, dataInicio.day); 
    
    int targetDay = DateTime.monday;
    switch(diaCtrl.text.toUpperCase()) {
      case 'TERÇA': targetDay = DateTime.tuesday; break;
      case 'QUARTA': targetDay = DateTime.wednesday; break;
      case 'QUINTA': targetDay = DateTime.thursday; break;
      case 'SEXTA': targetDay = DateTime.friday; break;
      case 'SÁBADO': targetDay = DateTime.saturday; break;
      case 'DOMINGO': targetDay = DateTime.sunday; break;
    }
    
    while (now.weekday != targetDay) { now = now.add(const Duration(days: 1)); }
    
    DateTime endLimit = DateTime(dataFim.year, dataFim.month, dataFim.day, 23, 59, 59);
    while (now.isBefore(endLimit) || now.isAtSameMomentAs(endLimit)) { 
      dates.add(now);
      now = now.add(const Duration(days: 7));
    } 
    return dates;
  }
}

class NodeSemLoop extends FocusNode {}