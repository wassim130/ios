import 'package:ahmini/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RecordingOverlay extends StatefulWidget {
  const RecordingOverlay({super.key});

  @override
  State<RecordingOverlay> createState() => RecordingOverlayState();
}

class RecordingOverlayState extends State<RecordingOverlay> {
  bool isRecording = false;

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
            const Icon(
              Icons.mic,
              color: Colors.white,
              size: 48,
            ),
            const SizedBox(height: 16),
             Text(
              'Enregistrement en cours...'.tr,
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _stopRecording,
              style: ElevatedButton.styleFrom(
                backgroundColor:  primaryColor,
              ),
              child:  Text('Arrêter'.tr),
            ),
          ],
        ),
      ),
    );
  }

  void _stopRecording() {
    setState(() {
      isRecording = false;
    });
  }
}
