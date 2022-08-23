import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:path_provider/path_provider.dart';
import 'package:streaming_app/video.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late VideoPlayerController _videoPlayerController;
  bool _playArea = false;
  String? _thumbTempPath;

  final video = [
    Video(
        name: 'Elephants Dream',
        url:
            'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
        thumbnail:
            'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4'),
    Video(
        name: 'For Bigger Fun',
        url:
            'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
        thumbnail:
            'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4'),
    Video(
        name: 'Volkswagen GTI Review',
        url:
            'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/VolkswagenGTIReview.mp4',
        thumbnail:
            'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/VolkswagenGTIReview.mp4')
  ];

  void getVideoThumbnail({String url = '', int index = 1}) async {
    _thumbTempPath = await VideoThumbnail.thumbnailFile(
      video: video[index].thumbnail,
      //"http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4",
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.WEBP,
      maxHeight:
          64, // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
      quality: 75, // you can change the thumbnail quality here
    );

    setState(() {});
  }

  void _initPlayer({int index = 0, bool init = false}) {
    if (index < 0 || index >= video.length) return;

    if (!init) {
      _videoPlayerController.pause();
    }

    _videoPlayerController = VideoPlayerController.network(video[index].url)
      ..addListener(() => setState(() {}))
      ..setLooping(true)
      ..initialize().then((value) => _videoPlayerController.play());
  }

  String _videoDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return [
      if (duration.inHours > 0) hours,
      minutes,
      seconds,
    ].join(':');
  }

  @override
  void initState() {
    super.initState();

    getVideoThumbnail();

    _initPlayer(init: true);
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    // setAllOrientation();
    super.dispose();
  }

  _showFeedbackDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: const Text("Feedback"),
            content: const Text("Do you like the content"),
            actions: <Widget>[
              CupertinoDialogAction(
                child: const Text("No"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              CupertinoDialogAction(
                child: const Text(
                  "Yes",
                  style: const TextStyle(color: Colors.red),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  _videoPlayerController.play();
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final noMute = (_videoPlayerController.value.volume) > 0;
    return Scaffold(
      appBar: AppBar(
        title: const Text(" Streaming App"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _playArea == false
              ? Container(
                  height: 300,
                  width: double.infinity,
                  color: Colors.deepPurpleAccent,
                  child: const Center(
                    child: Text(
                      'Tap Any from the list\nVideo will Appear ',
                      style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                )
              : Container(
                  color: Colors.deepPurpleAccent,
                  height: 300,
                  child: _videoPlayerController.value.isInitialized
                      ? Column(
                          children: [
                            SizedBox(
                              height: 200,
                              child: VideoPlayer(_videoPlayerController),
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ValueListenableBuilder(
                                    valueListenable: _videoPlayerController,
                                    builder: (context, VideoPlayerValue value,
                                        child) {
                                      Future.delayed(Duration(seconds: 10), () {
                                        _videoPlayerController.pause();
                                        _showFeedbackDialog(context);
                                      });

                                      return Text(
                                        _videoDuration(value.position),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                        ),
                                      );
                                    }),
                                Expanded(
                                  child: SizedBox(
                                    height: 20,
                                    child: VideoProgressIndicator(
                                      _videoPlayerController,
                                      allowScrubbing: true,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 0, horizontal: 12),
                                    ),
                                  ),
                                ),
                                Text(
                                  _videoDuration(
                                      _videoPlayerController.value.duration),
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 25),
                                )
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                InkWell(
                                  onTap: () {
                                    if (noMute) {
                                      _videoPlayerController.setVolume(0);
                                    } else {
                                      _videoPlayerController.setVolume(1);
                                    }
                                    setState(() {});
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                              offset: Offset(0.0, 0.0),
                                              blurRadius: 4,
                                              color:
                                                  Color.fromARGB(50, 0, 0, 0))
                                        ],
                                      ),
                                      child: noMute
                                          ? const Icon(
                                              Icons.volume_up,
                                              color: Colors.white,
                                            )
                                          : const Icon(
                                              Icons.volume_off,
                                              color: Colors.white,
                                            ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.arrow_back,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    Duration currentPosition =
                                        _videoPlayerController.value.position;
                                    Duration targetPosition = currentPosition -
                                        const Duration(seconds: 5);
                                    _videoPlayerController
                                        .seekTo(targetPosition);
                                  },
                                ),
                                IconButton(
                                    icon: Icon(
                                      _videoPlayerController.value.isPlaying
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      _videoPlayerController.value.isPlaying
                                          ? _videoPlayerController.pause()
                                          : _videoPlayerController.play();
                                    }),
                                IconButton(
                                  icon: const Icon(
                                    Icons.arrow_forward,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    Duration currentPosition =
                                        _videoPlayerController.value.position;
                                    Duration targetPosition = currentPosition +
                                        const Duration(seconds: 5);
                                    _videoPlayerController
                                        .seekTo(targetPosition);
                                  },
                                ),
                              ],
                            ),
                          ],
                        )
                      : const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        )),
          if (_thumbTempPath != null)
            Expanded(
              child: ListView.builder(
                itemCount: video.length,
                itemBuilder: ((context, index) {
                  return GestureDetector(
                    onTap: () {
                      debugPrint('tapped $index');
                      setState(() {
                        if (_playArea == false) {
                          _playArea = true;
                          _initPlayer(index: index);
                        }
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                height: 100,
                                width: 100,
                                //child: Image.network(video[index].thumbnail),
                                child: Image.file(File(_thumbTempPath!)),
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              Expanded(
                                child: Text(
                                  video[index].name,
                                  style: const TextStyle(fontSize: 25),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Center(
                            child: Row(
                              children: [
                                for (int i = 0; i <= 100; i++)
                                  i.isEven
                                      ? Container(
                                          width: 3,
                                          height: 1,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(2),
                                              color: Theme.of(context)
                                                  .primaryColor),
                                        )
                                      : Container(
                                          width: 3,
                                          height: 1,
                                          color: Colors.white,
                                        ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}
