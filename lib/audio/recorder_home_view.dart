import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_audio_recorder2/flutter_audio_recorder2.dart';
import 'package:path_provider/path_provider.dart';
import 'package:recording_app/audio/recorded_list_view.dart';
import 'package:recording_app/home/home.dart';
import 'package:recording_app/main/utils/AppColors.dart';
import 'package:recording_app/main/utils/AppConstant.dart';
import 'package:recording_app/main/utils/AppWidget.dart';

class RecorderHomeView extends StatefulWidget {
  final String _title;

  const RecorderHomeView({Key? key, required String title})
      : _title = title,
        super(key: key);

  @override
  _RecorderHomeViewState createState() => _RecorderHomeViewState();
}

enum RecordingState {
  UnSet,
  Set,
  Recording,
  Stopped,
}

class _RecorderHomeViewState extends State<RecorderHomeView> {
  late Directory appDirectory;
  Directory audioDirectory = Directory("./");
  List<String> records = [];
  IconData _recordIcon = Icons.mic_none;
  String _recordText = 'Click To Start';
  RecordingState _recordingState = RecordingState.UnSet;
  Duration duration = Duration();
  Timer? timer;
  // Recorder properties
  late FlutterAudioRecorder2 audioRecorder;

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
  void initState() {
    super.initState();
    FlutterAudioRecorder2.hasPermissions.then((hasPermission) {
      if (hasPermission!) {
        _recordingState = RecordingState.Set;
        _recordIcon = Icons.mic_outlined;
        _recordText = 'Record a New Audio';
      }
    });

    getApplicationDocumentsDirectory().then((value) {
      appDirectory = value;
      getDirectory();
    });
  }

  @override
  void dispose() {
    _recordingState = RecordingState.UnSet;
    super.dispose();
    timer?.cancel();
  }

  Future<void> getDirectory() async {
    Directory _appDocDirFolder =  Directory('${appDirectory.path}/Audio_Recordings/');

    if(await _appDocDirFolder.exists()){ //if folder already exists return path
      setState(() {
        audioDirectory = _appDocDirFolder;
        audioDirectory.list().listen((onData) {
          if (onData.path.contains('.aac')) records.add(onData.path);
        }).onDone(() {
          records = records.reversed.toList();
          setState(() {});
        });
      });
    }
    else {//if folder not exists create folder and then return its path
      final Directory _appDocDirNewFolder = await _appDocDirFolder.create(recursive: true);
      setState(() {
        audioDirectory = _appDocDirNewFolder;
        audioDirectory.list().listen((onData) {
          if (onData.path.contains('.aac')) records.add(onData.path);
        }).onDone(() {
          records = records.reversed.toList();
          setState(() {});
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
            title: text("Audio Recordings", textColor: TextColorPrimary),
            leading: _recordText != 'Recording' ? GestureDetector(
              onTap: () {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => Home(),
                    ),
                        (Route<dynamic> route) => false);
              },
              child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Icon(homeIcon,color: appColorPrimary))
              ,
            ) : Container()
        ),
        body: Column(
          children: [
            Expanded(
              flex: 3,
              child: Padding(
                padding: EdgeInsets.all(5),
                child: RecordListView(
                  records: records,
                ),
              )
            ),
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
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
              ),
            ),
          ],
        ),
      ),
      onWillPop: () async {
        return false;
      },
    );
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

    if(await _appDocDirFolder.exists()){ //if folder already exists return path
      String filePath = _appDocDirFolder.path + '/' + '${DateTime.now().millisecondsSinceEpoch.toString()}' + '.aac';

      audioRecorder = FlutterAudioRecorder2(filePath, audioFormat: AudioFormat.AAC);
      await audioRecorder.initialized;
    }
    else {//if folder not exists create folder and then return its path
      final Directory _appDocDirNewFolder = await _appDocDirFolder.create(recursive: true);
      String filePath = _appDocDirNewFolder.path + '/' + '${DateTime.now().millisecondsSinceEpoch.toString()}' + '.aac';

      audioRecorder = FlutterAudioRecorder2(filePath, audioFormat: AudioFormat.AAC);
      await audioRecorder.initialized;
    }
  }

  _startRecording() async {
    await audioRecorder.start();
    startTimer();
    // await audioRecorder.current(channel: 0);
  }

  _stopRecording() async {
    await audioRecorder.stop();
    _onRecordComplete();
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

  _onRecordComplete() {
    records.clear();
    audioDirectory.list().listen((onData) {
      if (onData.path.contains('.aac')) records.add(onData.path);
    }).onDone(() {
      records.sort();
      records = records.reversed.toList();
      setState(() {});
    });
  }
}