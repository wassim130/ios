import 'package:flutter/material.dart';
import 'package:ahmini/theme.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import '../../../../../models/message.dart';
import '../../../../../services/constants.dart';

class AudioAttachment extends StatefulWidget {
  final MessagesModel message;

  const AudioAttachment({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  State<AudioAttachment> createState() => _AudioAttachmentState();
}

class _AudioAttachmentState extends State<AudioAttachment> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  String? _audioUrl;
  bool _isInitialized = false;
  bool _hasError = false;
  String _errorMessage = '';
  String? _localFilePath;

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
  }

  Future<void> _initAudioPlayer() async {
    try {
      _audioUrl = widget.message.attachmentUrl;

      if (_audioUrl == null) {
        setState(() {
          _hasError = true;
          _errorMessage = "Audio URL is missing";
        });
        return;
      }

      if (!_audioUrl!.startsWith('http')) {
        _audioUrl = '$httpURL/api/chat${_audioUrl}';
      }

      final prefs = await SharedPreferences.getInstance();
      final sessionCookie = prefs.getString('session_cookie'.tr);

      if (sessionCookie == null) {
        setState(() {
          _hasError = true;
          _errorMessage = "Session cookie is missing";
        });
        return;
      }

      final headers = {
        'Cookie': 'sessionid=$sessionCookie',
      };

      final response = await http.get(Uri.parse(_audioUrl!), headers: headers);

      if (response.statusCode != 200) {
        setState(() {
          _hasError = true;
          _errorMessage = "Erreur de téléchargement (${response.statusCode})";
        });
        return;
      }

      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.m4a';
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      _localFilePath = filePath;
      await _audioPlayer.setSourceDeviceFile(_localFilePath!);

      if (widget.message.audioDuration != null) {
        _duration = Duration(seconds: widget.message.audioDuration!);
      }

      _audioPlayer.onPlayerStateChanged.listen((state) {
        if (mounted) {
          setState(() {
            _isPlaying = state == PlayerState.playing;
          });
        }
      });

      _audioPlayer.onDurationChanged.listen((newDuration) {
        if (mounted) {
          setState(() {
            _duration = newDuration;
          });
        }
      });

      _audioPlayer.onPositionChanged.listen((newPosition) {
        if (mounted) {
          setState(() {
            _position = newPosition;
          });
        }
      });

      _audioPlayer.onPlayerComplete.listen((_) {
        if (mounted) {
          setState(() {
            _position = _duration;
            _isPlaying = false;
          });
        }
      });

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
      print("Erreur init audio: $e");
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  Future<void> _playPause() async {
    if (_localFilePath == null) return;

    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        // 🔁 Redémarrer l'audio s'il est terminé
        if (_position >= _duration || _position.inSeconds == _duration.inSeconds) {
          await _audioPlayer.seek(Duration.zero);
          await _audioPlayer.resume();
        } else {
          await _audioPlayer.resume();
        }
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
      print("Erreur lecture audio: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          "Erreur audio: $_errorMessage",
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    if (!_isInitialized) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(12),
        child: Center(
          child: CircularProgressIndicator(
            color: widget.message.mine ? Colors.white : primaryColor,
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: widget.message.mine
            ? Colors.white.withOpacity(0.2)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
              color: widget.message.mine ? Colors.white : primaryColor,
              size: 36,
            ),
            onPressed: _playPause,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Audio message'.tr,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: widget.message.mine ? Colors.white : primaryColor,
                  ),
                ),
                SizedBox(height: 6),
                SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 4,
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
                  ),
                  child: Slider(
                    min: 0,
                    max: _duration.inSeconds.toDouble() > 0
                        ? _duration.inSeconds.toDouble()
                        : 1,
                    value: _position.inSeconds.toDouble().clamp(
                        0,
                        _duration.inSeconds.toDouble() > 0
                            ? _duration.inSeconds.toDouble()
                            : 1),
                    onChanged: (value) async {
                      final position = Duration(seconds: value.toInt());
                      await _audioPlayer.seek(position);
                      setState(() {
                        _position = position;
                      });
                    },
                    activeColor:
                    widget.message.mine ? Colors.white : primaryColor,
                    inactiveColor: widget.message.mine
                        ? Colors.white.withOpacity(0.3)
                        : Colors.grey[300],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(_position),
                        style: TextStyle(
                          fontSize: 12,
                          color: widget.message.mine
                              ? Colors.white.withOpacity(0.7)
                              : Colors.grey[600],
                        ),
                      ),
                      Text(
                        _formatDuration(_duration),
                        style: TextStyle(
                          fontSize: 12,
                          color: widget.message.mine
                              ? Colors.white.withOpacity(0.7)
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
