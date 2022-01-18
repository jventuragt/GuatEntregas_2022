import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../sistema.dart';

class AudioPlayWidget extends StatefulWidget {
  final Color color;
  final Color backgroud;
  final chatCompraModel;
  final key;

  AudioPlayWidget(this.chatCompraModel, this.key, {this.color, this.backgroud});

  @override
  _AudioPlayWidgetState createState() =>
      _AudioPlayWidgetState(chatCompraModel, color, backgroud);
}

typedef void OnError(Exception exception);
enum PlayerState { stopped, playing, paused }

class _AudioPlayWidgetState extends State<AudioPlayWidget> {
  var chatCompraModel;

  Color color;
  Color backgroud;

  _AudioPlayWidgetState(this.chatCompraModel, this.color, this.backgroud);

  Duration duration;
  Duration position;

  AudioPlayer audioPlayer;

  PlayerState playerState = PlayerState.stopped;

  get isPlaying => playerState == PlayerState.playing;

  get isPaused => playerState == PlayerState.paused;

  get durationText =>
      duration != null ? duration.toString().split('.').first : '';

  get positionText =>
      position != null ? position.toString().split('.').first : '';

  bool isMuted = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    audioPlayer?.stop();
    super.dispose();
  }

  void initAudioPlayer() async {
    audioPlayer = AudioPlayer();
    audioPlayer.onAudioPositionChanged.listen((p) {
      if (mounted) setState(() => position = p);
    });

    audioPlayer.onPlayerStateChanged.listen((s) {
      if (!mounted) return;

      if (s.toString() == 'PlayerState.PLAYING') {
        onComplete();
      }
      if (s.toString() == 'PlayerState.PLAYING') {
        audioPlayer.onDurationChanged.listen((Duration d) {
          setState(() => duration = d);
        });
      } else if (s.toString() == 'PlayerState.STOPPED') {
        onComplete();
        setState(() {
          position = duration;
        });
      }
    }, onError: (msg) {
      if (!mounted) return;
      setState(() {
        playerState = PlayerState.stopped;
        duration = Duration(seconds: 0);
        position = Duration(seconds: 0);
      });
    });
  }

  Future play() async {
    initAudioPlayer();
    await stop();
    await audioPlayer
        .play('${Sistema.storage}${chatCompraModel.mensaje}?alt=media');
    setState(() {
      playerState = PlayerState.playing;
    });
  }

  Future pause() async {
    await audioPlayer?.pause();
    setState(() => playerState = PlayerState.paused);
  }

  Future stop() async {
    await audioPlayer?.stop();
    setState(() {
      playerState = PlayerState.stopped;
      position = Duration();
    });
  }

  void onComplete() {
    setState(() => playerState = PlayerState.stopped);
  }

  @override
  Widget build(BuildContext context) {
    return _buildPlayer();
  }

  Widget _buildPlayer() => Container(
        width: 240.0,
        height: 58,
        color: backgroud,
        padding: EdgeInsets.only(bottom: 5.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            isPlaying && durationText.toString().length <= 0
                ? Container(
                    child: CircularProgressIndicator(),
                    padding: EdgeInsets.all(10.0),
                  )
                : IconButton(
                    onPressed: isPlaying ? () => pause() : () => play(),
                    iconSize: 45.0,
                    icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                    color: color),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                duration == null
                    ? Container(
                        height: 40.0,
                        width: 175.0,
                        child: Slider(
                          value: 0,
                          min: 0.0,
                          max: 100,
                          inactiveColor: Colors.white,
                          activeColor: Colors.blueAccent,
                          onChanged: (a) {},
                        ),
                      )
                    : Container(
                        height: 40.0,
                        width: 175.0,
                        child: Slider(
                            value: position?.inMilliseconds?.toDouble() ?? 0.0,
                            onChanged: (double value) =>
                                audioPlayer?.seek(Duration(seconds: 1)),
                            min: 0.0,
                            max: duration.inMilliseconds.toDouble())),
                Text(
                  position != null
                      ? "${positionText ?? ''} / ${durationText ?? ''}"
                      : duration != null
                          ? durationText
                          : chatCompraModel.valor,
                  style: TextStyle(fontSize: 10.0, color: color),
                ),
              ],
            ),
          ],
        ),
      );
}
