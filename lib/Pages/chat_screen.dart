import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Constante que almacena la clave de la API de Google Generative AI
const String apiKey = "AIzaSyCSODG2Bohy9_tSYKXAtrL6s3KEEk-smeI"; // Reemplazar con una clave válida

// La clase ChatScreen representa la pantalla de chat de la aplicación
class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

// Estado de la clase ChatScreen, que gestiona la lógica de la pantalla
class _ChatScreenState extends State<ChatScreen> {
  late stt.SpeechToText _speech; // Variable para el reconocimiento de voz
  late FlutterTts _flutterTts; // Variable para la síntesis de voz
  late final GenerativeModel _model; // Modelo generativo de IA
  late final ChatSession _chatSession; // Sesión de chat con el modelo de IA
  bool _isListening = false; // Indica si el micrófono está activo o no
  bool _isConnected = true; // Indica si hay conexión a internet
  String _speechText = ''; // Texto reconocido por voz
  String _selectedLanguage = "en-US"; // Idioma seleccionado para el reconocimiento de voz
  final List<ChatMessage> _messages = []; // Lista para almacenar los mensajes del chat
  final TextEditingController _controller = TextEditingController(); // Controlador para el campo de texto

  @override
  void initState() {
    super.initState();
    _initializeService(); // Inicializa los servicios al iniciar la pantalla
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Método para inicializar los servicios necesarios
  Future<void> _initializeService() async {
    _speech = stt.SpeechToText(); // Inicializa el reconocimiento de voz
    _flutterTts = FlutterTts(); // Inicializa la síntesis de voz
    _model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey); // Inicializa el modelo de IA
    _chatSession = _model.startChat(); // Inicia la sesión de chat con el modelo

    await _requestMicrophonePermission(); // Solicita permisos para el micrófono
    await _checkInternetConnection(); // Verifica la conexión a internet
    await _loadMessages(); // Carga los mensajes guardados
  }

  // Método para solicitar permisos para usar el micrófono
  Future<void> _requestMicrophonePermission() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      await Permission.microphone.request(); // Solicita el permiso si no está otorgado
    }
  }

  // Verifica si hay conexión a internet haciendo una solicitud a Google
  Future<void> _checkInternetConnection() async {
    try {
      final response = await http.get(Uri.parse('https://google.com'));
      if (response.statusCode == 200) {
        setState(() {
          _isConnected = true; // Indica que hay conexión
        });
      } else {
        setState(() {
          _isConnected = false; // Indica que no hay conexión
        });
      }
    } catch (e) {
      setState(() {
        _isConnected = false; // Indica que no hay conexión
      });
    }
  }

  // Inicia el reconocimiento de voz
  Future<void> _startListening() async {
    var status = await Permission.microphone.request();
    if (status.isGranted) { // Verifica si el permiso fue otorgado
      bool available = await _speech.initialize(
        onStatus: (val) {
          if (val == 'done') {
            _stopListening(); // Detiene el reconocimiento de voz si finaliza
          }
        },
        onError: (val) => print('Error: $val'),
      );

      if (available) {
        setState(() => _isListening = true); // Indica que está escuchando
        _speech.listen(
          onResult: (val) {
            setState(() {
              _speechText = val.recognizedWords; // Actualiza el texto reconocido
              _controller.text = _speechText; // Muestra el texto en el campo de entrada
            });
          },
          localeId: _selectedLanguage, // Idioma seleccionado para el reconocimiento de voz
        );
      }
    } else {
      print("Permisos de micrófono denegados");
    }
  }

  // Detiene el reconocimiento de voz
  void _stopListening() {
    setState(() => _isListening = false);
    _speech.stop();
  }

  // Método para enviar un mensaje al chatbot
  Future<void> _sendMessage() async {
    await _checkInternetConnection(); // Verifica la conexión antes de enviar

    if (!_isConnected) {
      setState(() {
        _messages.add(ChatMessage(
            text: "No se puede enviar el mensaje. Conéctate a Internet.", isUser: false));
      });
      return;
    }

    if (_controller.text.isNotEmpty) {
      setState(() {
        _messages.add(ChatMessage(text: _controller.text, isUser: true)); // Añade el mensaje del usuario
      });
      String userMessage = _controller.text;
      _controller.clear();

      setState(() {
        _messages.add(ChatMessage(text: "Analizando...", isUser: false));
      });

      try {
        // Obtener el contexto de la conversación para enviar al chatbot
        String context = _getContext();

        // Enviar el mensaje con contexto al modelo de IA
        final response = await _chatSession.sendMessage(
          Content.text("$context\nUsuario: $userMessage")
        );
        final botResponse = response.text ?? "No se recibió respuesta";

        setState(() {
          _messages.removeLast(); // Elimina el mensaje de "Analizando..."
          _messages.add(ChatMessage(text: botResponse, isUser: false)); // Añade la respuesta del bot
        });

        await _saveMessages(); // Guarda los mensajes
        await _speak(botResponse); // Hace que el bot lea la respuesta en voz alta
      } catch (e) {
        setState(() {
          _messages.removeLast();
          _messages.add(ChatMessage(text: "Error: $e", isUser: false));
        });
      }
    }
  }

  // Obtiene el contexto de los últimos mensajes guardados para mantener la conversación coherente
  String _getContext() {
    int numberOfMessages = _messages.length < 10 ? _messages.length : 10;
    
    // Concatenar los últimos mensajes para formar el contexto
    return _messages
        .take(numberOfMessages)
        .map((msg) => "${msg.isUser ? 'Usuario' : 'Bot'}: ${msg.text}")
        .join("\n");
  }

  // Hace que el texto sea leído en voz alta
  Future<void> _speak(String text) async {
    await _flutterTts.setLanguage(_selectedLanguage);
    await _flutterTts.speak(text);
  }

  // Cambia el idioma de la aplicación para el reconocimiento y la síntesis de voz
  void _changeLanguage(String languageCode) {
    setState(() {
      _selectedLanguage = languageCode;
    });
  }

  // Guarda los últimos mensajes en la memoria del dispositivo
  Future<void> _saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> messagesToSave = _messages
        .take(100)
        .map((msg) => "${msg.isUser ? 'user:' : 'bot:'}${msg.text}")
        .toList();
    await prefs.setStringList('chatMessages', messagesToSave);
  }

  // Carga los mensajes guardados desde la memoria del dispositivo
  Future<void> _loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? savedMessages = prefs.getStringList('chatMessages');

    if (savedMessages != null) {
      setState(() {
        _messages.clear();
        _messages.addAll(savedMessages.map((msg) {
          bool isUser = msg.startsWith('user:');
          String text = msg.replaceFirst(isUser ? 'user:' : 'bot:', '');
          return ChatMessage(text: text, isUser: isUser);
        }).toList());
      });
    }
  }

  // Método para construir la interfaz de usuario de la pantalla
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Fondo de la pantalla en negro
      appBar: AppBar(
        title: Text('Chatbot'), // Título en la barra superior
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final isUserMessage = _messages[index].isUser;
                return Row(
                  mainAxisAlignment: isUserMessage
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: [
                    if (!isUserMessage)
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: CircleAvatar(
                          backgroundColor: Colors.greenAccent,
                          child: Icon(Icons.smart_toy, color: Colors.white),
                        ),
                      ),
                    Container(
                      padding: EdgeInsets.all(12),
                      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      constraints: BoxConstraints(maxWidth: 300),
                      decoration: BoxDecoration(
                        color: isUserMessage ? Colors.blueAccent : Colors.greenAccent,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        _messages[index].text,
                        style: TextStyle(
                          color: isUserMessage ? Colors.white : Colors.black, // Color del texto según si es del usuario o del bot
                        ),
                      ),
                    ),
                    if (isUserMessage)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: CircleAvatar(
                          backgroundColor: Colors.blueAccent,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                IconButton(
                  icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
                  color: Colors.blueAccent,
                  onPressed: _isListening ? _stopListening : _startListening,
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Escribe un mensaje',
                      hintStyle: TextStyle(color: Colors.grey), // Estilo del texto sugerido
                      filled: true,
                      fillColor: Colors.white24, // Color de fondo del campo de texto
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: TextStyle(color: Colors.white), // Estilo del texto ingresado
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  color: Colors.greenAccent,
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => _changeLanguage("en-US"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: Text("Inglés (EE.UU.)"),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () => _changeLanguage("es-MX"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: Text("Español (México)"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Clase para representar un mensaje en el chat
class ChatMessage {
  final String text; // Texto del mensaje
  final bool isUser; // Indica si el mensaje es del usuario

  ChatMessage({required this.text, required this.isUser});
}
