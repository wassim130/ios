import 'package:ahmini/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../services/audio_recorder.dart';

class RecordingOverlay extends StatefulWidget {
  final Function(String, int)? onRecordingComplete;

  const RecordingOverlay({
    super.key,
    this.onRecordingComplete,
  });

  @override
  State<RecordingOverlay> createState() => RecordingOverlayState();
}

class RecordingOverlayState extends State<RecordingOverlay> {
  bool isRecording = false;
  final AudioRecorderService _audioRecorder = AudioRecorderService();
  int _recordingDuration = 0;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    await _audioRecorder.initialize();
    _isInitialized = true;

    _audioRecorder.durationStream.listen((duration) {
      setState(() {
        _recordingDuration = duration;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return !isRecording ? Container() : _buildRecordingOverlay();
  }

  Widget _buildRecordingOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                ),
                const Icon(
                  Icons.mic,
                  color: Colors.white,
                  size: 48,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _audioRecorder.formatDuration(_recordingDuration),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enregistrement en cours...'.tr,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _cancelRecording,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(16),
                  ),
                  child: const Icon(Icons.close, color: Colors.white),
                ),
                const SizedBox(width: 32),
                ElevatedButton(
                  onPressed: _stopRecording,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(16),
                  ),
                  child: const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> startRecording() async {
    if (!_isInitialized) {
      await _initRecorder();
    }

    setState(() {
      isRecording = true;
    });

    await _audioRecorder.startRecording();
  }

  Future<void> _stopRecording() async {
    final audioPath = await _audioRecorder.stopRecording();
    final duration = _recordingDuration;

    setState(() {
      isRecording = false;
      _recordingDuration = 0;
    });

    if (audioPath != null && widget.onRecordingComplete != null) {
      widget.onRecordingComplete!(audioPath, duration);
    }
  }

  Future<void> _cancelRecording() async {
    await _audioRecorder.cancelRecording();

    setState(() {
      isRecording = false;
      _recordingDuration = 0;
    });
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    super.dispose();
  }
}
