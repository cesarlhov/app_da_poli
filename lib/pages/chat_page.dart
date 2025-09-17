// lib/pages/chat_page.dart
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

// Modelo para a mensagem (continua o mesmo)
class ChatMessage {
  final String text;
  final bool isUser;
  final bool isLoading;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.isLoading = false,
  });
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];

  late final GenerativeModel _model;
  late final ChatSession _chatSession;

  // Sua chave de API
  static const String _apiKey = "AIzaSyDYlaAkTphTCtj6Hwn54CMgSmyM3m0jExA";

  @override
  void initState() {
    super.initState();

    // --- MUDANÇA PRINCIPAL: BASE DE CONHECIMENTO ---

    // 1. Crie aqui a sua base de conhecimento.
    // Cole o texto dos seus regulamentos, guias, etc.
    const String baseDeConhecimento = """
      DOCUMENTO INTERNO: NORMAS DA ESCOLA POLITÉCNICA DA USP

      Artigo 1: Matrícula
      - A matrícula é obrigatória a cada semestre letivo.
      - O aluno deve se matricular em no mínimo 12 créditos, exceto em casos especiais aprovados pelo colegiado.
      - A perda do prazo de matrícula resulta em desligamento automático do curso.

      Artigo 2: Provas Substitutivas
      - O aluno tem direito a uma prova substitutiva por disciplina, por semestre.
      - A prova substitutiva só pode substituir a nota de uma das provas regulares (P1 ou P2).
      - Para realizar a prova, o aluno deve fazer a solicitação na secretaria em até 5 dias úteis após a divulgação da média final.
      - A nota da prova substitutiva substitui a menor nota, mesmo que a nova nota seja inferior.

      Artigo 3: Jubilamento
      - O jubilamento ocorre quando o aluno não completa o curso no prazo máximo estipulado de 1.5 vezes o tempo ideal.
      - Para Engenharia de Computação (tempo ideal de 5 anos), o prazo máximo é de 7.5 anos.
    """;

    // 2. Atualize a instrução de sistema para usar a base de conhecimento.
    final systemInstruction = Content.text(
      'Você é o Assistente Virtual da Poli-USP, um chatbot acadêmico. '
      'Sua única função é responder perguntas baseando-se ESTRITAMENTE E EXCLUSIVAMENTE no documento fornecido a seguir. '
      'Não utilize nenhum conhecimento externo. Se a resposta não estiver no documento, afirme que "A informação não foi encontrada nas normas disponíveis". '
      'Responda de forma objetiva e formal. Cite o artigo correspondente sempre que possível.'
      '\n\n--- INÍCIO DO DOCUMENTO ---\n'
      '$baseDeConhecimento'
      '\n--- FIM DO DOCUMENTO ---'
    );
    // --- FIM DA MUDANÇA ---

    _model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: _apiKey,
      systemInstruction: systemInstruction,
    );

    _chatSession = _model.startChat();
  }

  void _sendMessage() async {
    final text = _controller.text;
    if (text.isEmpty) return;

    setState(() {
      _messages.insert(0, ChatMessage(text: text, isUser: true));
      _messages.insert(0, ChatMessage(text: 'Digitando...', isUser: false, isLoading: true));
    });

    _controller.clear();
    FocusScope.of(context).unfocus();

    try {
      final response = await _chatSession.sendMessage(Content.text(text));
      final aiText = response.text;

      if (aiText != null) {
        setState(() {
          _messages.removeAt(0);
          _messages.insert(0, ChatMessage(text: aiText, isUser: false));
        });
      }
    } catch (e) {
      setState(() {
        _messages.removeAt(0);
        _messages.insert(0, ChatMessage(text: 'Erro: Não foi possível responder.', isUser: false));
      });
    }
  }

  // O resto do código (a interface) continua o mesmo.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Acadêmico'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(8.0),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    return MessageBubble(
                      text: message.text,
                      isUser: message.isUser,
                      isLoading: message.isLoading,
                    );
                  },
                ),
              ),
            ),
            _buildTextComposer(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [BoxShadow(offset: const Offset(0, -1), blurRadius: 2, color: Colors.black.withOpacity(0.05))],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration.collapsed(hintText: 'Pergunte sobre as normas...'),
              onSubmitted: (value) => _sendMessage(),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: Theme.of(context).primaryColor),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final bool isLoading;

  const MessageBubble({
    super.key,
    required this.text,
    required this.isUser,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
              decoration: BoxDecoration(
                color: isUser ? theme.primaryColor : Colors.grey[200],
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: isLoading
                  ? const SizedBox(width: 25, height: 25, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.black54))
                  : SelectableText(text, style: TextStyle(color: isUser ? Colors.white : Colors.black87)),
            ),
          ),
        ],
      ),
    );
  }
}