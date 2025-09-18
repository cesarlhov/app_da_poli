// lib/pages/chat_page.dart

import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

const String _apiKey = "SUA_API_KEY_AQUI";

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  late final GenerativeModel _model;
  late final ChatSession _chatSession;

  @override
  void initState() {
    super.initState();
    const String baseDeConhecimento = """
      DOCUMENTO INTERNO: NORMAS DA ESCOLA POLITÉCNICA DA USP
      Artigo 1: Matrícula ...
      """;
    
    final systemInstruction = Content.text(
      'Você é o Assistente Virtual da Poli-USP... $baseDeConhecimento ...'
    );

    _model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: _apiKey,
      systemInstruction: systemInstruction,
    );
    _chatSession = _model.startChat();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isLoading) return;

    setState(() {
      _messages.insert(0, ChatMessage(text: text, isUser: true));
      _messages.insert(0, ChatMessage.loading());
      _isLoading = true;
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
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat Acadêmico'), centerTitle: true),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) => _MessageBubble(message: _messages[index]),
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
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -1),
            blurRadius: 2,
            // Correção aqui:
            color: Colors.black.withAlpha((255 * 0.05).round()),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration.collapsed(hintText: 'Pergunte sobre as normas...'),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: _isLoading ? Colors.grey : Theme.of(context).primaryColor),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final bool isLoading;

  ChatMessage({required this.text, required this.isUser, this.isLoading = false});
  factory ChatMessage.loading() => ChatMessage(text: '', isUser: false, isLoading: true);
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final alignment = message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start;
    final color = message.isUser ? theme.primaryColor : Colors.grey[200];
    final textColor = message.isUser ? Colors.white : Colors.black87;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: alignment,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20.0)),
              child: message.isLoading
                  ? const SizedBox(width: 25, height: 25, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.black54))
                  : SelectableText(message.text, style: TextStyle(color: textColor)),
            ),
          ),
        ],
      ),
    );
  }
}