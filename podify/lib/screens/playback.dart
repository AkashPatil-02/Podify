import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class PlaybackScreen extends StatefulWidget {
  final String? audioUrl;
  const PlaybackScreen({super.key, required this.audioUrl});

  @override
  State<PlaybackScreen> createState() => _PlaybackScreenState();
}

class _PlaybackScreenState extends State<PlaybackScreen> {
  final player = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    super.initState();
    player.onDurationChanged.listen((d) => setState(() => duration = d));
    player.onPositionChanged.listen((p) => setState(() => position = p));
    player.onPlayerComplete.listen((_) => setState(() => isPlaying = false));
  }

  void togglePlay() async {
    if (isPlaying) {
      await player.pause();
    } else {
      await player.play(UrlSource(widget.audioUrl!));
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
      appBar: AppBar(title: Text("Your Podcast")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.podcasts, size: 100),
            SizedBox(height: 20),
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
                  iconSize: 60,
                  onPressed: togglePlay,
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              "${position.inMinutes}:${(position.inSeconds % 60).toString().padLeft(2, '0')} / "
              "${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}",
            ),
          ],
        ),
      ),
    );
  }
}
