import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:flutter_sound/flutter_sound.dart';

enum RecordingState { stopped, recording, paused }

class AudioRecorderService {
  final AudioRecorder _recorder = AudioRecorder(); // ✅ nouvelle instanciation
  final FlutterSoundPlayer _player = FlutterSoundPlayer();

  RecordingState _recordingState = RecordingState.stopped;
  String? _path;
  Timer? _recordingTimer;
  int _recordingDuration = 0;

  final StreamController<int> _durationController = StreamController<int>.broadcast();
  Stream<int> get durationStream => _durationController.stream;

  RecordingState get recordingState => _recordingState;
  int get recordingDuration => _recordingDuration;
  String? get path => _path;

  Future<void> initialize() async {
    await _player.openPlayer();
  }

  Future<void> startRecording() async {
    try {
      final hasPermission = await _recorder.hasPermission();
      if (hasPermission) {
        final directory = await getTemporaryDirectory();
        _path = '${directory.path}/voice_message_${DateTime.now().millisecondsSinceEpoch}.m4a';

        await _recorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: _path!,
        );

        _recordingState = RecordingState.recording;
        _recordingDuration = 0;

        _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          _recordingDuration++;
          _durationController.add(_recordingDuration);
        });
      }
    } catch (e) {
      debugPrint('Error starting recording: $e');
      _recordingState = RecordingState.stopped;
    }
  }

  Future<String?> stopRecording() async {
    _recordingTimer?.cancel();
    _recordingTimer = null;

    if (_recordingState == RecordingState.recording) {
      await _recorder.stop();
      _recordingState = RecordingState.stopped;
      return _path;
    }
    return null;
  }

  Future<void> cancelRecording() async {
    final path = _path;
    await stopRecording();

    if (path != null) {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    }
    _path = null;
  }

  Future<void> playAudio(String path) async {
    if (_player.isOpen()) {
      await _player.startPlayer(
        fromURI: path,
        whenFinished: () {
          debugPrint('Finished playing');
        },
      );
    }
  }

  Future<void> stopPlayback() async {
    if (_player.isPlaying) {
      await _player.stopPlayer();
    }
  }

  Future<void> dispose() async {
    _recordingTimer?.cancel();
    await _recorder.dispose();
    await _player.closePlayer();
    await _durationController.close();
  }

  String formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
