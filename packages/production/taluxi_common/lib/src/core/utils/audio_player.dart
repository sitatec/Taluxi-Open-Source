import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/foundation.dart';

class AudioPlayer {
  final AssetsAudioPlayer _assetAudioPlayer;

  AudioPlayer({AssetsAudioPlayer assetsAudioPlayer})
      : _assetAudioPlayer = assetsAudioPlayer ?? AssetsAudioPlayer.newPlayer();

  Future<void> initialize(
      {@required String fileName, bool loop = false}) async {
    await _assetAudioPlayer.open(
      Audio(fileName),
      autoStart: false,
      playInBackground: PlayInBackground.enabled,
      loopMode: loop ? LoopMode.single : LoopMode.none,
    );
  }

  Future<void> play() async => await _assetAudioPlayer.play();

  Future<void> stop() async => await _assetAudioPlayer.stop();

  Future<void> dispose() async {
    await _assetAudioPlayer.dispose();
  }
}
