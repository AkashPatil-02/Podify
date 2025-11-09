import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';

class PlaybackScreen extends StatefulWidget {
  final String audioUrl;
  final String transcript;
  const PlaybackScreen({
    super.key,
    required this.audioUrl,
    required this.transcript,
  });

  @override
  State<PlaybackScreen> createState() => _PlaybackScreenState();
}

class _PlaybackScreenState extends State<PlaybackScreen> {
  final player = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  bool isDownloading = false;
  double downloadProgress = 0.0;
  String? localFilePath;

  void copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.transcript));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Copied to clipboard!"),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _checkOrDownloadAudio();

    player.onDurationChanged.listen((d) => setState(() => duration = d));
    player.onPositionChanged.listen((p) => setState(() => position = p));
    player.onPlayerComplete.listen((_) => setState(() => isPlaying = false));
  }

  Future<void> _checkOrDownloadAudio() async {
    final dir = Platform.isAndroid
        ? Directory('/storage/emulated/0/Download')
        : await getApplicationDocumentsDirectory();

    String fileName = widget.audioUrl.split('/').last;
    String path = '${dir.path}/$fileName';

    if (File(path).existsSync()) {
      print('File already downloaded: $path');
      setState(() => localFilePath = path);
      return;
    }

    await Permission.storage.request();

    try {
      setState(() => isDownloading = true);

      await Dio().download(
        widget.audioUrl,
        path,
        onReceiveProgress: (rec, total) {
          if (total != -1) {
            setState(() => downloadProgress = rec / total);
          }
        },
      );

      setState(() {
        isDownloading = false;
        localFilePath = path;
      });

      print(' Download complete: $path');
    } catch (e) {
      setState(() => isDownloading = false);
      print(' Download failed: $e');
    }
  }

  void togglePlay() async {
    if (localFilePath == null) return;

    if (isPlaying) {
      await player.pause();
    } else {
      await player.stop();
      await player.play(DeviceFileSource(localFilePath!));
    }

    setState(() => isPlaying = !isPlaying);
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Audio Player")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 500,
                height: 450,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey,
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    widget.transcript,
                    style: TextStyle(fontSize: 25),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: copyToClipboard,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(10),
                  ),
                  elevation: 0,
                ),

                child: const Text(
                  "copy transcript",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              if (isDownloading) ...[
                LinearProgressIndicator(value: downloadProgress),
                const SizedBox(height: 10),
                Text(
                  "Downloading... ${(downloadProgress * 100).toStringAsFixed(0)}%",
                ),
              ] else if (localFilePath == null) ...[
                const Text("Preparing audio..."),
              ] else ...[
                Slider(
                  min: 0,
                  max: duration.inSeconds.toDouble(),
                  value: position.inSeconds.toDouble().clamp(
                    0,
                    duration.inSeconds.toDouble(),
                  ),
                  onChanged: (value) async {
                    final pos = Duration(seconds: value.toInt());
                    await player.seek(pos);
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(
                        isPlaying ? Icons.pause_circle : Icons.play_circle,
                      ),
                      iconSize: 70,
                      onPressed: togglePlay,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  "${position.inMinutes}:${(position.inSeconds % 60).toString().padLeft(2, '0')} / "
                  "${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}",
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
