import 'package:flutter/material.dart';

class GeneratingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Generating Podcast")),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text("Creating your AI podcast...", style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
