import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// La clase HomeScreen define la pantalla principal que se mostrará en la aplicación.
class HomeScreen extends StatelessWidget {
  // Función que intenta abrir el enlace del repositorio en el navegador web.
  // Si el enlace no se puede abrir, muestra un mensaje de error.
  void _launchURL() async {
    const url = 'https://github.com/AlexisJuarez2227/Chat_Bot.git';  // URL del repositorio de GitHub
    if (await canLaunch(url)) { // Verifica si el enlace puede ser abierto
      await launch(url); // Abre el enlace en el navegador
    } else {
      throw 'No se pudo abrir el enlace $url'; // Lanza un error si no se puede abrir el enlace
    }
  }

  // El método build construye la interfaz de la pantalla.
  @override
  Widget build(BuildContext context) {
    // Scaffold es un contenedor básico para la estructura de la interfaz de usuario.
    return Scaffold(
      backgroundColor: Colors.black, // Color de fondo de la pantalla (negro)
      appBar: AppBar(
        title: Text(
          'Información del Alumno', // Título que aparece en la parte superior de la pantalla
          style: TextStyle(color: Colors.black), // Color del texto del título
        ),
        centerTitle: true,  // El título se centrará en la barra superior
        backgroundColor: Colors.white, // Color de fondo de la barra superior
        iconTheme: IconThemeData(color: Colors.white), // Color de los iconos en la barra superior
      ),
      // El cuerpo de la pantalla se define aquí
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Espacio alrededor del contenido
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,  // Centra los elementos verticalmente en la pantalla
            children: <Widget>[
              // Muestra una imagen circular (avatar)
              CircleAvatar(
                backgroundImage: AssetImage('assets/images/logo.jpg'),  // Ruta de la imagen (debe estar en la carpeta 'assets')
                radius: 75, // Tamaño del círculo (radio)
              ),
              SizedBox(height: 20), // Espacio vacío de 20 píxeles
              // Texto que muestra la carrera
              Text(
                'Carrera: Ingeniería en Software',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white), // Estilo del texto (blanco)
              ),
              SizedBox(height: 10), // Espacio vacío de 10 píxeles
              // Texto que muestra la materia
              Text(
                'Materia: Programación Móvil',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white), // Estilo del texto (blanco)
              ),
              SizedBox(height: 10), // Espacio vacío de 10 píxeles
              // Texto que muestra el grupo
              Text(
                'Grupo: A',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white), // Estilo del texto (blanco)
              ),
              SizedBox(height: 10), // Espacio vacío de 10 píxeles
              // Texto que muestra el nombre del alumno
              Text(
                'Alumno: Carlos Eduardo Gumeta Navarro',  // Aquí puedes colocar tu nombre
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white), // Estilo del texto (blanco)
              ),
              SizedBox(height: 10), // Espacio vacío de 10 píxeles
              // Texto que muestra la matrícula del alumno
              Text(
                'Matrícula: 221199',  // Coloca tu matrícula aquí
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white), // Estilo del texto (blanco)
              ),
              SizedBox(height: 30), // Espacio vacío de 30 píxeles
              // Botón para abrir el enlace del repositorio
              ElevatedButton(
                onPressed: _launchURL,  // Llamada para abrir el enlace cuando se presiona el botón
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent, // Color de fondo del botón
                  foregroundColor: Colors.white, // Color del texto del botón
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20), // Bordes redondeados del botón
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15), // Espacio interno del botón
                  textStyle: TextStyle(fontSize: 16), // Tamaño del texto del botón
                ),
                child: Text('Ver Repositorio'), // Texto del botón
              ),
              SizedBox(height: 20), // Espacio vacío de 20 píxeles
              // Botón para navegar a la pantalla del chatbot
              ElevatedButton(
                onPressed: () {
                  // Navega a la pantalla del chatbot utilizando el nombre de la ruta '/chat'
                  Navigator.pushNamed(context, '/chat');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent, // Color de fondo del botón
                  foregroundColor: Colors.black, // Color del texto del botón
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20), // Bordes redondeados del botón
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15), // Espacio interno del botón
                  textStyle: TextStyle(fontSize: 16), // Tamaño del texto del botón
                ),
                child: Text('Ir al Chatbot'), // Texto del botón
              ),
            ],
          ),
        ),
      ),
    );
  }
}
