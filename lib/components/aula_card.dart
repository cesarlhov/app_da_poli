// lib/components/aula_card.dart

import 'package:app_da_poli/models/disciplina_model.dart';
import 'package:app_da_poli/pages/disciplina_details_page.dart';
import 'package:app_da_poli/providers/disciplinas_provider.dart';
import 'package:app_da_poli/providers/user_provider.dart'; // 🟢 NOVO IMPORT
import 'package:app_da_poli/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AulaCard extends StatelessWidget {
  final Disciplina disciplina;
  const AulaCard({super.key, required this.disciplina});

  // =========================================================================
  // 🎛️ PAINEL DE CONTROLE - DESIGN DO CARD DE AULA
  // =========================================================================
  // Borda e Sombras
  final double _raioBordaCard = 6.0; // 🟢 Arredondamento do Card

  // Espaçamentos Internos e Externos
  final double _distanciaEntreCards = 8.0; 
  final double _paddingLateralInterno = 12.0;
  final double _paddingTopCard = 9.0;
  final double _paddingBottomCard = 12.0;
  final double _espacoHorarioETextos = 9.0; 
  
  // 🟢 MICRO-ESPAÇAMENTOS VERTICAIS
  final double _espacoTituloLocal = 3.0;      // Título da Disciplina -> Local
  final double _espacoLocalAulaNum = 2.0;     // Local -> "Aula 8"
  final double _espacoAulaNumLinha = 10.0;    // "Aula 8" -> Linha Divisória
  final double _espacoLinhaTextoAgora = 8.0;  // Linha Divisória -> "AGORA > VOCÊ ESTÁ NA AULA?"
  final double _espacoTextoAgoraBotoes = 7.0; // Texto "AGORA..." -> Botões de Presença
  
  // Tipografia (Tamanhos)
  final double _tamanhoHorario = 15.0;
  final double _tamanhoTitulo = 18.0;
  final double _tamanhoLocal = 14.0;
  final double _tamanhoAulaNum = 14.0;
  final double _tamanhoTextoAgora = 15.0;
  final double _tamanhoTextoBotao = 18.0;
  
  // Opacidades
  final double _opacidadeTextosSecundarios = 0.60; 

  // Linhas
  final double _espessuraLinhaHorario = 1.5;
  final double _espessuraLinhaDivisoria = 2.5;

  // Botões
  final double _espacoEntreBotoes = 10.0;

  // Cores do Card (Estilo PQI)
  final Color _corBordaCard = const Color(0xFF0085FF);
  final Gradient _gradienteFundo = const LinearGradient(
    colors: [Color(0xFF0460E9), Color(0xFF0D41A9)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  
  // Cores de Texto e Linhas Internas
  final Color _corTextoBase = const Color(0xFFF0F0F0);
  
  // Cores dos Botões
  final Color _corFundoBotao = const Color(0xFFF0F0F0);
  final Color _corBordaBotao = const Color(0xFFB3B3B8);
  final Color _corTextoBotao = const Color(0xFFB3B3B8);
  // =========================================================================

  // 🟢 LENTE INTELIGENTE: Pega a Turma do Aluno e vê a aula de HOJE
  (HorarioAula?, Turma?) _getDadosExibicao(BuildContext context) {
    if (disciplina.turmas.isEmpty) return (null, null);

    final user = context.read<UserProvider>().currentUser;
    final now = DateTime.now();
    const mapDias = {1: 'SEGUNDA', 2: 'TERÇA', 3: 'QUARTA', 4: 'QUINTA', 5: 'SEXTA', 6: 'SÁBADO', 7: 'DOMINGO'};
    final hojeStr = mapDias[now.weekday] ?? '';
    final minutosAtual = now.hour * 60 + now.minute;

    // Filtra para pegar apenas as turmas em que o aluno está inscrito.
    // (Se o banco antigo só tiver a disciplina, usamos todas como fallback)
    List<Turma> turmasDoAluno = disciplina.turmas.where((t) => user?.turmasIds.contains(t.id) ?? false).toList();
    if (turmasDoAluno.isEmpty) {
      turmasDoAluno = disciplina.turmas;
    }

    HorarioAula? horarioHoje;
    Turma? turmaHoje;

    for (var turma in turmasDoAluno) {
      for (var hor in turma.horarios) {
        if (hor.dia == hojeStr) {
          horarioHoje ??= hor; // Salva o primeiro do dia pra caso não seja agora
          turmaHoje ??= turma;
          
          try {
            final inicioStr = hor.inicio.split(':');
            final fimStr = hor.fim.split(':');
            final minutosInicio = int.parse(inicioStr[0]) * 60 + int.parse(inicioStr[1]);
            final minutosFim = int.parse(fimStr[0]) * 60 + int.parse(fimStr[1]);

            // Achou a aula que está acontecendo AGORA (com 15min de tolerância prévia)
            if (minutosAtual >= (minutosInicio - 15) && minutosAtual <= minutosFim) {
              return (hor, turma);
            }
          } catch (e) {}
        }
      }
    }

    // Se não for agora, mas tiver aula hoje, mostra a próxima/anterior do dia
    if (horarioHoje != null) return (horarioHoje, turmaHoje);
    
    // Se não tem aula hoje, mostra o primeiro horário da turma dele só pra preencher o Card
    final primeiraTurma = turmasDoAluno.first;
    final primeiroHorario = primeiraTurma.horarios.isNotEmpty ? primeiraTurma.horarios.first : null;
    return (primeiroHorario, primeiraTurma);
  }

  bool _isAulaAcontecendo(HorarioAula? hor) {
    if (hor == null) return false;
    final now = DateTime.now();
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
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DisciplinasProvider>();
    final progresso = provider.progressos.where((p) => p.disciplinaId == disciplina.id).firstOrNull;

    final hoje = DateTime.now();
    final dataHojeStr = "${hoje.year}-${hoje.month.toString().padLeft(2, '0')}-${hoje.day.toString().padLeft(2, '0')}";

    final bool jaRespondeuHoje = progresso?.historicoPresenca.containsKey(dataHojeStr) ?? false;
    
    // 🟢 Busca os dados inteligentes da Turma/Horário
    final dados = _getDadosExibicao(context);
    final horarioAtual = dados.$1;
    final turmaAtual = dados.$2;

    // Só mostra os botões e a linha se for a hora da aula.
    final bool mostrarBotoes = _isAulaAcontecendo(horarioAtual) && !jaRespondeuHoje;

    final String avisoEspecial = disciplina.departamento == 'PQI' ? 'NÃO DEIXE DE LEVAR JALECO E ÓCULOS DE PROTEÇÃO' : '';

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => DisciplinaDetailsPage(disciplina: disciplina)));
      },
      child: Container(
        margin: EdgeInsets.only(bottom: _distanciaEntreCards),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_raioBordaCard),
          border: Border.all(color: _corBordaCard, width: 1.5), 
          boxShadow: [
            BoxShadow(
              color: disciplina.cor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (avisoEspecial.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(_raioBordaCard), topRight: Radius.circular(_raioBordaCard)),
                ),
                child: Text(
                  avisoEspecial,
                  style: const TextStyle(fontFamily: 'Aristotelica', fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF9FA3AD)),
                ),
              ),

            Container(
              padding: EdgeInsets.only(
                left: _paddingLateralInterno, 
                right: _paddingLateralInterno,
                top: _paddingTopCard,
                bottom: _paddingBottomCard,
              ),
              decoration: BoxDecoration(
                gradient: _gradienteFundo,
                borderRadius: avisoEspecial.isNotEmpty 
                  ? BorderRadius.only(bottomLeft: Radius.circular(_raioBordaCard), bottomRight: Radius.circular(_raioBordaCard)) 
                  : BorderRadius.circular(_raioBordaCard - 1.5),
              ),
              child: Column(
                children: [
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch, 
                      children: [
                        _buildHorarioColumn(horarioAtual),
                        SizedBox(width: _espacoHorarioETextos),
                        Expanded(child: _buildInfoColumn(horarioAtual, turmaAtual)),
                      ],
                    ),
                  ),
                  
                  // ANIMAÇÃO DE GAVETA: O Card cresce suavemente para revelar os botões
                  AnimatedSize(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutCubic,
                    alignment: Alignment.topCenter,
                    child: mostrarBotoes 
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: _espacoAulaNumLinha),
                            Divider(color: _corTextoBase, height: 1, thickness: _espessuraLinhaDivisoria),
                            SizedBox(height: _espacoLinhaTextoAgora),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text('AGORA > VOCÊ ESTÁ NA AULA?', style: TextStyle(fontFamily: 'Aristotelica', color: _corTextoBase, fontWeight: FontWeight.w700, fontSize: _tamanhoTextoAgora)),
                            ),
                            SizedBox(height: _espacoTextoAgoraBotoes),
                            Row(
                              children: [
                                Expanded(
                                  flex: 'PRESENTE'.length,
                                  child: _buildPresenceButton(
                                    label: 'PRESENTE', 
                                    onTap: () => FirestoreService().registrarPresenca(disciplina.id, dataHojeStr, true)
                                  )
                                ),
                                SizedBox(width: _espacoEntreBotoes),
                                Expanded(
                                  flex: 'Ñ HOUVE PRESENÇA'.length, 
                                  child: _buildPresenceButton(
                                    label: 'Ñ HOUVE PRESENÇA', 
                                    onTap: () => FirestoreService().registrarPresenca(disciplina.id, dataHojeStr, false)
                                  )
                                ),
                              ],
                            )
                          ],
                        )
                      : const SizedBox(width: double.infinity, height: 0),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresenceButton({required String label, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _corFundoBotao,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _corBordaBotao, width: 2), 
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: Text(
              label,
              style: TextStyle(fontFamily: 'Aristotelica', color: _corTextoBotao, fontSize: _tamanhoTextoBotao, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHorarioColumn(HorarioAula? hor) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween, 
      children: [
        Text(hor?.inicio ?? '--:--', style: TextStyle(fontFamily: 'Aristotelica', color: _corTextoBase, fontWeight: FontWeight.w700, fontSize: _tamanhoHorario, height: 1.0)),
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6), 
            width: _espessuraLinhaHorario, 
            color: _corTextoBase
          ),
        ),
        Text(hor?.fim ?? '--:--', style: TextStyle(fontFamily: 'Aristotelica', color: _corTextoBase, fontWeight: FontWeight.w700, fontSize: _tamanhoHorario, height: 1.0)),
      ],
    );
  }

  Widget _buildInfoColumn(HorarioAula? hor, Turma? turma) {
    String nomeProfessor = turma != null && turma.professores.isNotEmpty ? turma.professores.first : 'Sem professor';
    String localAula = hor?.local ?? 'A definir';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${disciplina.codigo} – ${disciplina.nome}'.toUpperCase(), style: TextStyle(fontFamily: 'Aristotelica', fontWeight: FontWeight.w700, fontSize: _tamanhoTitulo, color: _corTextoBase, height: 1.1), maxLines: 2, overflow: TextOverflow.ellipsis),
        SizedBox(height: _espacoTituloLocal),
        Text(localAula.toUpperCase(), style: TextStyle(fontFamily: 'Aristotelica', fontSize: _tamanhoLocal, color: _corTextoBase.withOpacity(_opacidadeTextosSecundarios), fontWeight: FontWeight.w700, letterSpacing: 0.5, height: 1.0)),
        SizedBox(height: _espacoLocalAulaNum),
        Text("AULA 8 - PROF. ${nomeProfessor.toUpperCase()}", style: TextStyle(fontFamily: 'Aristotelica', fontSize: _tamanhoAulaNum, color: _corTextoBase.withOpacity(_opacidadeTextosSecundarios), fontWeight: FontWeight.w700, letterSpacing: 0.5, height: 1.0)), 
      ],
    );
  }
}