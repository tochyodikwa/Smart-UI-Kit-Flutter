import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smartkit/FullApp/NewsApp/helper/ButtonClickAnimation.dart';
import 'package:smartkit/FullApp/NewsApp/helper/ColorsRes.dart';
import 'package:smartkit/FullApp/NewsApp/helper/VideoView/overlay_handler.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:smartkit/FullApp/NewsApp/activity/LiveVideos/LiveVideoDetail.dart';

class FullScreenVideo extends StatefulWidget {
  @override
  _FullScreenVideoState createState() => _FullScreenVideoState();
}

class _FullScreenVideoState extends State<FullScreenVideo> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OverlayHandlerProvider>(builder: (context, overlayProvider, _) {
      return Stack(
        alignment: Alignment.bottomCenter,
        children: [
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: videoPlayerController.value.size?.width ?? 0,
                height: videoPlayerController.value.size?.height ?? 0,
                child: VideoPlayer(videoPlayerController),
              ),
            ),
          ),
          VideoProgressIndicator(
            videoPlayerController,
            allowScrubbing: true,
            colors: VideoProgressColors(backgroundColor: ColorsRes.grey.withOpacity(0.5), bufferedColor: ColorsRes.grey, playedColor: ColorsRes.appcolor),
          ),
          ButtonClickAnimation(
            onTap: () {
              setState(() {
                videoPlayerController.value.isPlaying ? videoPlayerController.pause() : videoPlayerController.play();
              });
            },
            child: CircleAvatar(
              backgroundColor: ColorsRes.white.withOpacity(0.5),
              child: Icon(
                videoPlayerController.value.isPlaying ? Icons.pause : Icons.play_arrow,
              ),
            ),
          ),
        ],
      );
    });
  }
}
