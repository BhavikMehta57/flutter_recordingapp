// import 'package:device_screen_recorder/device_screen_recorder.dart';
// import 'package:flutter/material.dart';
// import 'package:recording_app/main/utils/AppColors.dart';
// import 'package:recording_app/main/utils/AppWidget.dart';
//
// class ScreenRecorder extends StatefulWidget {
//   @override
//   _ScreenRecorderState createState() => _ScreenRecorderState();
// }
//
// class _ScreenRecorderState extends State<ScreenRecorder> {
//   bool recording = false;
//   String path = '';
//
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: text("Screen Recorder", textColor: TextColorPrimary),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             recording
//                 ?
//             OutlinedButton(
//               onPressed: () async {
//                 var file = await DeviceScreenRecorder.stopRecordScreen();
//                 setState(() {
//                   path = file ?? '';
//                   recording = false;
//                 });
//               },
//               child: Text('Stop'),
//             )
//                 :
//             OutlinedButton(
//               onPressed: () async {
//                 var status = await DeviceScreenRecorder.startRecordScreen();
//                 setState(() {
//                   recording = status ?? false;
//                 });
//               },
//               child: Text('Start'),
//             ),
//             Text(path)
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'dart:async';

import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_screen_recording/flutter_screen_recording.dart';

class ScreenRecorder extends StatefulWidget {
  @override
  _ScreenRecorderState createState() => _ScreenRecorderState();
}

class _ScreenRecorderState extends State<ScreenRecorder> {
  bool recording = false;
  int _time = 0;


  @override
  void initState() {
    super.initState();
  }


  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Screen Recording'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Time: $_time\n'),
            !recording
                ? Center(
              child: RaisedButton(
                child: Text("Record Screen"),
                onPressed: () => startScreenRecord(false),
              ),
            )
                : Container(),
            !recording
                ? Center(
              child: RaisedButton(
                child: Text("Record Screen & audio"),
                onPressed: () => startScreenRecord(true),
              ),
            )
                : Center(
              child: RaisedButton(
                child: Text("Stop Record"),
                onPressed: () => stopScreenRecord(),
              ),
            )
          ],
        ),
      ),
    );
  }

  startScreenRecord(bool audio) async {
    bool start = false;
    await Future.delayed(const Duration(milliseconds: 1000));

    if (audio) {
      start = (await FlutterScreenRecording.startRecordScreenAndAudio("Title" + _time.toString(),  titleNotification:"dsffad", messageNotification: "sdffd"))!;
    } else {
      start = (await FlutterScreenRecording.startRecordScreen("Title", titleNotification:"dsffad", messageNotification: "sdffd"))!;
    }

    if (start) {
      setState(() => recording = !recording);
    }

    return start;
  }

  stopScreenRecord() async {
    String path = await FlutterScreenRecording.stopRecordScreen;
    setState(() {
      recording = !recording;
    });
    print("Opening video");
    print(path);
  }
}