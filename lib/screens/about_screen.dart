import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sobre')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: const [
            Text('Controle de Despesas'),
            SizedBox(height: 8),
            Text('Versão 1.0.0'),
            SizedBox(height: 8),
            Text('Aplicativo sem Firebase - armazenando localmente com SharedPreferences.'),
          ],
        ),
      ),
    );
  }
}
