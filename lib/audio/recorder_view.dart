import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:path_provider/path_provider.dart';
import 'package:flutter_audio_recorder2/flutter_audio_recorder2.dart';
import 'package:recording_app/main/utils/AppWidget.dart';

class RecorderView extends StatefulWidget {
  final Function onSaved;

  const RecorderView({Key? key, required this.onSaved}) : super(key: key);
  @override
  _RecorderViewState createState() => _RecorderViewState();
}

enum RecordingState {
  UnSet,
  Set,
  Recording,
  Stopped,
}

class _RecorderViewState extends State<RecorderView> {
  IconData _recordIcon = Icons.mic_none;
  String _recordText = 'Click To Start';
  RecordingState _recordingState = RecordingState.UnSet;
  Duration duration = Duration();
  Timer? timer;
  // Recorder properties
  late FlutterAudioRecorder2 audioRecorder;

  @override
  void initState() {
    super.initState();

    FlutterAudioRecorder2.hasPermissions.then((hasPermission) {
      if (hasPermission!) {
        _recordingState = RecordingState.Set;
        _recordIcon = Icons.mic_outlined;
        _recordText = 'Record a New Audio';
      }
    });
  }

  @override
  void dispose() {
    _recordingState = RecordingState.UnSet;
    super.dispose();
    timer?.cancel();
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (_) => addTime());
  }

  void addTime() {
    final addSeconds = 1;
    setState(() {
      final seconds = duration.inSeconds + addSeconds;
      duration = Duration(seconds: seconds);
    });
  }

  void stopTimer() {
    setState(() {
      duration = Duration();
      timer?.cancel();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildTime(),
        MaterialButton(
          onPressed: () async {
            await _onRecordButtonPressed();
            setState(() {});
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          child: Container(
            width: 75,
            height: 75,
            child: Icon(
              _recordIcon,
              size: 50,
            ),
          ),
        ),
        Padding(
          child: text(_recordText),
          padding: const EdgeInsets.all(10),
        )
      ],
    );
    //   Stack(
    //   alignment: Alignment.center,
    //   children: [
    //     Align(
    //         alignment: Alignment.topCenter,
    //         child: buildTime()
    //     ),
    //     MaterialButton(
    //       onPressed: () async {
    //         await _onRecordButtonPressed();
    //         setState(() {});
    //       },
    //       shape: RoundedRectangleBorder(
    //         borderRadius: BorderRadius.circular(50),
    //       ),
    //       child: Container(
    //         width: 150,
    //         height: 150,
    //         child: Icon(
    //           _recordIcon,
    //           size: 50,
    //         ),
    //       ),
    //     ),
    //     Align(
    //         alignment: Alignment.bottomCenter,
    //         child: Padding(
    //           child: text(_recordText),
    //           padding: const EdgeInsets.all(20),
    //         )
    //     ),
    //   ],
    // );
  }

  Widget buildTime() {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return text('$minutes:$seconds');
  }

  Future<void> _onRecordButtonPressed() async {
    switch (_recordingState) {
      case RecordingState.Set:
        await _recordVoice();
        break;

      case RecordingState.Recording:
        await _stopRecording();
        _recordingState = RecordingState.Stopped;
        _recordIcon = Icons.fiber_manual_record;
        _recordText = 'Record a New One';
        break;

      case RecordingState.Stopped:
        await _recordVoice();
        break;

      case RecordingState.UnSet:
        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Please allow recording from settings.'),
        ));
        break;
    }
  }

  _initRecorder() async {
    Directory appDirectory = await getApplicationDocumentsDirectory();

    Directory _appDocDirFolder =  Directory('${appDirectory.path}/Audio_Recordings/');

    String filePath = _appDocDirFolder.path + '/' + '${DateTime.now().millisecondsSinceEpoch.toString()}' + '.aac';

    audioRecorder = FlutterAudioRecorder2(filePath, audioFormat: AudioFormat.AAC);
    await audioRecorder.initialized;
  }

  _startRecording() async {
    await audioRecorder.start();
    startTimer();
    // await audioRecorder.current(channel: 0);
  }

  _stopRecording() async {
    await audioRecorder.stop();
    widget.onSaved();
    stopTimer();
  }

  Future<void> _recordVoice() async {
    final hasPermission = await FlutterAudioRecorder2.hasPermissions;
    if (hasPermission ?? false) {
      await _initRecorder();

      await _startRecording();
      _recordingState = RecordingState.Recording;
      _recordIcon = Icons.stop;
      _recordText = 'Recording';
    } else {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please allow recording from settings.'),
      ));
    }
  }
}