import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class TrailerPlayerScreen extends StatefulWidget {
  final String videoId;

  const TrailerPlayerScreen({super.key, required this.videoId});

  @override
  State<TrailerPlayerScreen> createState() => _TrailerPlayerScreenState();
}

class _TrailerPlayerScreenState extends State<TrailerPlayerScreen> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    // 1. Ensure we allow all orientations when entering video
    SystemChrome.setPreferredOrientations([]);

    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(autoPlay: true, mute: false, enableCaption: false),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    // 2. IMPORTANT: Do NOT lock to portrait here.
    // Just clear preferences so the user can rotate the Home screen if they want.
    SystemChrome.setPreferredOrientations([]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      // 3. Remove the onExitFullScreen lock. Let the phone decide.
      onExitFullScreen: () {
        // Optional: You can force portrait here IF you want the player to shrink back
        // SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      },
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.red,
        topActions: [
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              _controller.metadata.title,
              style: const TextStyle(color: Colors.white, fontSize: 18.0),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
      builder: (context, player) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                if (_controller.value.isFullScreen) {
                  _controller.toggleFullScreenMode();
                } else {
                  Navigator.pop(context);
                }
              },
            ),
          ),
          body: Center(child: player),
        );
      },
    );
  }
}
