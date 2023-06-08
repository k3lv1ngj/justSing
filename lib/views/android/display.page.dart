import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class PlayerPage extends StatefulWidget {
  String? link;

  PlayerPage({this.link});

  //const YoutubePlayerExample({super.key});

  @override
  State<PlayerPage> createState() => _PlayerState();
}

class _PlayerState extends State<PlayerPage> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    final videoID = YoutubePlayer.convertUrlToId(widget.link.toString());

    _controller = YoutubePlayerController(
      initialVideoId: videoID!,
      flags: const YoutubePlayerFlags(
          autoPlay: true,
          controlsVisibleAtStart: false,
          hideControls: true,
          forceHD: false,
          showLiveFullscreenButton: false),
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        foregroundColor: Colors.orange,
        title: Text('Reproduzir'),
        centerTitle: true,
        backgroundColor: Colors.grey[850],
        leading: GestureDetector(
          child: FloatingActionButton(
            shape: BeveledRectangleBorder(),
            backgroundColor: Colors.transparent,
            onPressed: () => Navigator.of(context).pop('/result'),
            child: Icon(
              Icons.close,
              color: Colors.orange,
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          YoutubePlayer(
            controller: _controller,
            showVideoProgressIndicator: true,
          ),
        ],
      ),
    );
  }
}
