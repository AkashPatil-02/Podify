// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:podify/screens/loading.dart';
import 'package:podify/screens/playback.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _contentController = TextEditingController();
  bool summarize = true;
  bool isGenerating = false;

  Future<void> generatePodcast() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GeneratingScreen()),
    );

    try {
      final res = await http.post(
        Uri.parse("http://10.217.38.192:8000/api/podcast"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "text": _contentController.text,
          "summarize": summarize,
        }),
      );

      final data = jsonDecode(res.body);
      print(data['audio_url']);

      await Future.delayed(Duration(milliseconds: 600));

      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PlaybackScreen(audioUrl: data['audio_url']),
        ),
      );
    } catch (e) {
      print(e);
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error generating podcast: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Podify"),
        actions: [
          IconButton(onPressed: generatePodcast, icon: Icon(Icons.settings)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            TextField(
              controller: _contentController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: "Paste url or content",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            SwitchListTile(
              title: const Text("summarize before generating"),
              value: summarize,
              onChanged: (v) => {
                setState(() {
                  summarize = v;
                }),
              },
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: isGenerating ? null : generatePodcast,
              icon: Icon(Icons.podcasts),
              label: Text(isGenerating ? "Generating..." : "Generate Podcast"),
            ),
          ],
        ),
      ),
    );
  }
}
