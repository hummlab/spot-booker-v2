import 'package:flutter/material.dart';

/// Main entry point for the panel application
/// 
/// This is the web admin panel application for administrators and managers.
void main() {
  runApp(const PanelApp());
}

/// Main application widget for the panel app
/// 
/// Configures the app theme, routing, and initial screen for the admin panel.
class PanelApp extends StatelessWidget {
  const PanelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Panel',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const PanelHomePage(title: 'Admin Panel'),
    );
  }
}

/// Home page widget for the panel application
/// 
/// This is the main dashboard screen that administrators see when they access the panel.
class PanelHomePage extends StatefulWidget {
  const PanelHomePage({super.key, required this.title});

  final String title;

  @override
  State<PanelHomePage> createState() => _PanelHomePageState();
}

class _PanelHomePageState extends State<PanelHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Admin Panel - You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
