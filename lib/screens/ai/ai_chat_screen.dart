
import 'package:flutter/material.dart';

class AIChatScreen extends StatefulWidget {
  @override
  _AIChatScreenState createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _ctrl = TextEditingController();
  List<Map<String,String>> messages = [];

  void send() {
    final q = _ctrl.text.trim();
    if (q.isEmpty) return;
    setState(() { messages.add({'role':'user','text':q}); });
    _ctrl.clear();
    // Placeholder response - in real app call backend /ask-ustaz
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() { messages.add({'role':'ai','text':'(Dalil: Surah Al-Baqarah 2:286) Ini jawapan ringkas berdasarkan sumber rasmi.'}); });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('AI Ustaz / Ustazah')),
      body: Column(
        children: [
          Expanded(child: ListView.builder(
            padding: EdgeInsets.all(12),
            itemCount: messages.length,
            itemBuilder: (_,i){
              final m = messages[i];
              final isUser = m['role']=='user';
              return Align(
                alignment: isUser? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: EdgeInsets.symmetric(vertical:6),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isUser? Colors.green[100] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8)
                  ),
                  child: Text(m['text'] ?? ''),
                ),
              );
            }
          )),
          SafeArea(child: Row(
            children: [
              Expanded(child: Padding(
                padding: EdgeInsets.symmetric(horizontal:12),
                child: TextField(controller: _ctrl, decoration: InputDecoration(hintText: 'Tanya soalan...')),
              )),
              IconButton(icon: Icon(Icons.send), onPressed: send)
            ],
          ))
        ],
      ),
    );
  }
}
