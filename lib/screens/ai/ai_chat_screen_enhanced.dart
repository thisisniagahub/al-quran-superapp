import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import '../../services/ai_service.dart';

// COMPLETE AI Ustaz/Ustazah dengan VOICE Q&A!
class AIChatScreenEnhanced extends StatefulWidget {
  @override
  _AIChatScreenEnhancedState createState() => _AIChatScreenEnhancedState();
}

class _AIChatScreenEnhancedState extends State<AIChatScreenEnhanced> {
  final AIService _aiService = AIService();
  final TextEditingController _messageController = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  
  List<ChatMessage> messages = [];
  bool isLoading = false;
  bool isListening = false;
  String selectedLanguage = 'ms'; // ms, id, en
  
  @override
  void initState() {
    super.initState();
    _initializeSpeech();
    _initializeTts();
    _addWelcomeMessage();
  }
  
  Future<void> _initializeSpeech() async {
    await _speech.initialize();
  }
  
  Future<void> _initializeTts() async {
    await _flutterTts.setLanguage(selectedLanguage == 'ms' ? 'ms-MY' : 
                                  selectedLanguage == 'id' ? 'id-ID' : 'en-US');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }
  
  void _addWelcomeMessage() {
    setState(() {
      messages.add(ChatMessage(
        text: 'Assalamualaikum! Saya AI Ustaz/Ustazah yang akan membantu anda dengan soalan agama berdasarkan Al-Quran dan Hadith sahih.\n\n⚠️ PENTING: Untuk keputusan hukum yang mengikat, sila rujuk ke JAKIM atau e-Fatwa.',
        isUser: false,
        timestamp: DateTime.now(),
        hasDisclaimer: true,
      ));
    });
  }
  
  @override
  void dispose() {
    _messageController.dispose();
    _flutterTts.stop();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('AI Ustaz / AI Ustazah', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Bertanya dengan dalil sahih', style: TextStyle(fontSize: 11)),
          ],
        ),
        backgroundColor: Color(0xFF4A7C9D),
        actions: [
          // Language selector
          PopupMenuButton<String>(
            icon: Icon(Icons.language),
            onSelected: (value) {
              setState(() => selectedLanguage = value);
              _initializeTts();
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'ms', child: Text('Bahasa Melayu')),
              PopupMenuItem(value: 'id', child: Text('Bahasa Indonesia')),
              PopupMenuItem(value: 'en', child: Text('English')),
            ],
          ),
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // JAKIM Warning Banner
          Container(
            padding: EdgeInsets.all(12),
            color: Colors.amber.shade100,
            child: Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'AI tidak boleh beri fatwa. Rujuk e-Fatwa atau JAKIM untuk hukum rasmi.',
                    style: TextStyle(fontSize: 11, color: Colors.orange.shade900),
                  ),
                ),
              ],
            ),
          ),
          
          // Chat Messages
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[messages.length - 1 - index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          
          // Loading indicator
          if (isLoading)
            Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                children: [
                  SizedBox(width: 16),
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text('AI sedang menjawab...', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          
          // Input area
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2)),
              ],
            ),
            child: Row(
              children: [
                // Voice button
                Container(
                  decoration: BoxDecoration(
                    color: isListening ? Colors.red : Color(0xFF4A7C9D),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      isListening ? Icons.mic : Icons.mic_none,
                      color: Colors.white,
                    ),
                    onPressed: _toggleListening,
                  ),
                ),
                SizedBox(width: 12),
                
                // Text input
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Tanya soalan agama...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                SizedBox(width: 12),
                
                // Send button
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF4A7C9D),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(14),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: message.isUser ? Color(0xFF4A7C9D) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: message.isUser ? Colors.white : Colors.black87,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(message.timestamp),
                  style: TextStyle(
                    color: message.isUser ? Colors.white70 : Colors.grey,
                    fontSize: 10,
                  ),
                ),
                if (!message.isUser) ...[
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.volume_up, size: 16, color: Color(0xFF4A7C9D)),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    onPressed: () => _speakText(message.text),
                  ),
                ],
              ],
            ),
            if (message.sources != null && message.sources!.isNotEmpty) ...[
              SizedBox(height: 8),
              Divider(),
              Text('Sumber:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ...message.sources!.map((source) => 
                Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text('• $source', style: TextStyle(fontSize: 10, color: Colors.grey[700])),
                ),
              ),
            ],
            if (message.hasDisclaimer) ...[
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.verified, size: 14, color: Colors.green),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Mematuhi garis panduan JAKIM',
                        style: TextStyle(fontSize: 9, color: Colors.green.shade800),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  void _toggleListening() async {
    if (isListening) {
      await _speech.stop();
      setState(() => isListening = false);
    } else {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => isListening = true);
        _speech.listen(
          onResult: (result) {
            setState(() {
              _messageController.text = result.recognizedWords;
            });
          },
          localeId: selectedLanguage == 'ms' ? 'ms-MY' : 
                   selectedLanguage == 'id' ? 'id-ID' : 'en-US',
        );
      }
    }
  }
  
  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    
    // Add user message
    setState(() {
      messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _messageController.clear();
      isLoading = true;
    });
    
    // Get AI response
    try {
      final response = await _aiService.askUstaz(text, language: selectedLanguage);
      
      setState(() {
        messages.add(ChatMessage(
          text: response['answer'],
          isUser: false,
          timestamp: DateTime.now(),
          sources: response['sources'] != null 
              ? List<String>.from(response['sources']) 
              : null,
          hasDisclaimer: true,
        ));
        isLoading = false;
      });
      
      // Auto-speak response
      await _speakText(response['answer']);
      
    } catch (e) {
      setState(() {
        messages.add(ChatMessage(
          text: 'Maaf, terdapat masalah. Sila rujuk:\n• myHadith.islam.gov.my\n• e-fatwa.gov.my\n• JAKIM',
          isUser: false,
          timestamp: DateTime.now(),
        ));
        isLoading = false;
      });
    }
  }
  
  Future<void> _speakText(String text) async {
    await _flutterTts.speak(text);
  }
  
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
  
  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tentang AI Ustaz/Ustazah'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('AI ini menggunakan:'),
              SizedBox(height: 8),
              Text('✓ Al-Quran (Mushaf Malaysia)'),
              Text('✓ Hadith Sahih (myHadith)'),
              Text('✓ e-Fatwa Malaysia'),
              Text('✓ Garis Panduan JAKIM'),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '⚠️ AI tidak boleh mengeluarkan fatwa. Untuk keputusan hukum rasmi, rujuk mufti atau JAKIM.',
                  style: TextStyle(fontSize: 12, color: Colors.orange.shade900),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Faham'),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<String>? sources;
  final bool hasDisclaimer;
  
  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.sources,
    this.hasDisclaimer = false,
  });
}
