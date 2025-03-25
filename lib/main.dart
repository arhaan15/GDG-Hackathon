import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io' show Platform;

void main() {
  runApp(ChatbotApp());
}

class ChatbotApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'School Chatbot',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: ChatScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  int _feedbackAttempts = 0;
  bool _showFeedback = false;
  String _currentQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('School Chatbot'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.all(8.0),
                itemCount: _messages.length,
                itemBuilder: (_, index) => _messages[index],
              ),
            ),
            if (_isLoading)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (_showFeedback)
              Container(
                padding: EdgeInsets.all(12.0),
                color: Theme.of(context).cardColor,
                child: Column(
                  children: [
                    Text(
                      "Are you satisfied with the response?",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _showFeedback = false;
                              _feedbackAttempts = 0;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          child: Text("Yes"),
                        ),
                        SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: () {
                            if (_feedbackAttempts < 2) {
                              setState(() {
                                _showFeedback = false;
                                _feedbackAttempts++;
                                _sendMessage(_currentQuery);
                              });
                            } else {
                              setState(() {
                                _showFeedback = false;
                                _addMessage("We will now ask a teacher to contact you.", false);
                                _feedbackAttempts = 0;
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: Text("No"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            Divider(height: 1.0),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
              ),
              child: _buildTextComposer(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).primaryColor),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Flexible(
              child: TextField(
                controller: _textController,
                onSubmitted: _handleSubmitted,
                decoration: InputDecoration(
                  hintText: "Enter your query...",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16.0),
                ),
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                icon: Icon(Icons.send),
                onPressed: () => _handleSubmitted(_textController.text),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;
    
    _textController.clear();
    _addMessage(text, true);
    
    if (text.toLowerCase() == 'exit') {
      _addMessage("Goodbye!", false);
    } else {
      _sendMessage(text);
    }
  }

  void _addMessage(String text, bool isUser) {
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: isUser,
        animationController: AnimationController(
          duration: const Duration(milliseconds: 300),
          vsync: this as TickerProvider,
        )..forward(),
      ));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage(String text) {
    setState(() {
      _isLoading = true;
      _currentQuery = text;
    });
    
    _callChatAPI(text).then((response) {
      setState(() {
        _isLoading = false;
        _addMessage(response, false);
        _showFeedback = true;
      });
    });
  }

  Future<String> _callChatAPI(String text) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.0.129:8000/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'query': text}),
      ).timeout(Duration(seconds: 30));
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['response'];
      } else {
        return "Error: ${response.statusCode} - ${response.body}";
      }
    } catch (e) {
      print('Error in _callChatAPI: $e');
      return "Error: $e";
    }
  }
  
  @override
  void dispose() {
    // Clean up animation controllers
    for (var message in _messages) {
      message.animationController.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isUser;
  final AnimationController animationController;

  ChatMessage({
    required this.text, 
    required this.isUser,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: CurvedAnimation(
        parent: animationController,
        curve: Curves.easeOut,
      ),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!isUser) _buildAvatar(context),
            Flexible(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                decoration: BoxDecoration(
                  color: isUser 
                      ? Theme.of(context).primaryColor 
                      : Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[800]
                          : Colors.grey[200],
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Text(
                  text,
                  style: TextStyle(
                    color: isUser 
                        ? Colors.white 
                        : Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ),
            ),
            if (isUser) _buildAvatar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8.0, left: 8.0),
      child: CircleAvatar(
        child: Text(isUser ? 'You' : 'Bot'),
        backgroundColor: isUser ? Colors.blue[300] : Colors.green[300],
        foregroundColor: Colors.white,
      ),
    );
  }
}