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
import 'package:flutter_screen_recording/flutter_screen_recording.dart';
import 'package:recording_app/home/home.dart';
import 'package:recording_app/main/utils/AppColors.dart';
import 'package:recording_app/main/utils/AppConstant.dart';
import 'package:recording_app/main/utils/AppWidget.dart';
import 'package:recording_app/main/utils/animation/fadeAnimation.dart';

class ScreenRecorder extends StatefulWidget {
  @override
  _ScreenRecorderState createState() => _ScreenRecorderState();
}

class _ScreenRecorderState extends State<ScreenRecorder> {
  bool recording = false;
  Duration duration = Duration();
  Timer? timer;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
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
    return new WillPopScope(
      child: new Scaffold(
        appBar: AppBar(
            title: text("Screen Recorder", textColor: TextColorPrimary),
            leading: (!recording) ? GestureDetector(
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            buildTime(),
            SizedBox(
              height: 10,
            ),
            !recording
                ?
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 16, 40, 16),
              child: FadeAnimation(
                  1.2,
                  Center(
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        // height: double.infinity,
                        child: MaterialButton(
                          child: text("Record Screen"),
                          shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(40.0), side: BorderSide(color: appDarkRed, width: 1)),
                          color: appWhite,
                          onPressed: () => startScreenRecord(false),
                        ),
                      )
                  )
              ),
            )
                :
            Container(),
            !recording
                ?
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 16, 40, 16),
              child: FadeAnimation(
                  1.2,
                  Center(
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        // height: double.infinity,
                        child: MaterialButton(
                          child: text("Record Screen & Audio"),
                          shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(40.0), side: BorderSide(color: appDarkRed, width: 1)),
                          color: appWhite,
                          onPressed: () => startScreenRecord(true),
                        ),
                      )
                  )
              ),
            )
                :
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 16, 40, 16),
              child: FadeAnimation(
                  1.2,
                  Center(
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        // height: double.infinity,
                        child: MaterialButton(
                          child: text("Stop Recording"),
                          shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(40.0), side: BorderSide(color: appDarkRed, width: 1)),
                          color: appWhite,
                          onPressed: () => stopScreenRecord(),
                        ),
                      )
                  )
              ),
            )
          ],
        ),
      ),
      onWillPop: () async {
        return false;
      },
    );
  }

  startScreenRecord(bool audio) async {
    bool start = false;
    await Future.delayed(const Duration(milliseconds: 1000));
    if (audio) {
      start = (await FlutterScreenRecording.startRecordScreenAndAudio("ScreenRecordingWithAudio_${DateTime.now().millisecondsSinceEpoch.toString()}"))!;
    } else {
      start = (await FlutterScreenRecording.startRecordScreen("ScreenRecording_${DateTime.now().millisecondsSinceEpoch.toString()}"))!;
    }

    if (start) {
      startTimer();
      setState(() => recording = !recording);
    }

    return start;
  }

  stopScreenRecord() async {
    String path = await FlutterScreenRecording.stopRecordScreen;
    stopTimer();
    setState(() {
      recording = !recording;
    });
    print("Opening video");
    print(path);
    final snackBar = SnackBar(
      content: Text('Video Saved at $path'),
      duration: Duration(seconds: 10),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);

  }

  Widget buildTime() {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours.remainder(60));
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return FadeAnimation(
      1.2,
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildTimeCard(time: hours, header:'HOURS'),
              SizedBox(width: 10),
              buildTimeCard(time: minutes, header:'MINUTES'),
              SizedBox(width: 10),
              buildTimeCard(time: seconds, header:'SECONDS'),
            ]
        )
    );
  }

  Widget buildTimeCard({required String time, required String header}) =>
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: appColorSecondary,
                borderRadius: BorderRadius.circular(20)
            ),
            child: Text(
              time, style: TextStyle(fontWeight: FontWeight.bold,
                color: Colors.black,fontSize: 60),),
          ),
          SizedBox(height: 5,),
          text(header,textColor: TextColorSecondary),
        ],
      );

}