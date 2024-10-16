import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatelessWidget {
  // Función para abrir el enlace del repositorio en el navegador
  void _launchURL() async {
    const url = 'https://github.com/AlexisJuarez2227/Chat_Bot.git';  // Cambia este URL por el de tu repositorio
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'No se pudo abrir el enlace $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Información del Alumno'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Image.asset(
                'assets/images/logo.jpg',  // Asegúrate de que el logo esté en la carpeta assets
                height: 150,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Carrera: Ingeniería en Software',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Materia: Programación Móvil',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Grupo: A',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Alumno: Jorge Alexis Arredondo Juárez',  // Aquí puedes colocar tu nombre
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Matrícula: 221187',  // Coloca tu matrícula aquí
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _launchURL,  // Llamada para abrir el repositorio
              child: Text('Ver Repositorio'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navegar a la pantalla del chatbot
                Navigator.pushNamed(context, '/chat');
              },
              child: Text('Ir al Chatbot'),
            ),
          ],
        ),
      ),
    );
  }
}
