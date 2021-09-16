import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:recording_app/audio/recorded_list_view.dart';
import 'package:recording_app/audio/recorder_view.dart';
import 'package:recording_app/main/utils/AppColors.dart';
import 'package:recording_app/main/utils/AppWidget.dart';

class RecorderHomeView extends StatefulWidget {
  final String _title;

  const RecorderHomeView({Key? key, required String title})
      : _title = title,
        super(key: key);

  @override
  _RecorderHomeViewState createState() => _RecorderHomeViewState();
}

class _RecorderHomeViewState extends State<RecorderHomeView> {
  late Directory appDirectory;
  Directory audioDirectory = Directory("./");
  List<String> records = [];

  @override
  void initState() {
    super.initState();
    getApplicationDocumentsDirectory().then((value) {
      appDirectory = value;
      getDirectory();
    });
  }

  @override
  void dispose() {
    audioDirectory.delete();
    super.dispose();
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
    return Scaffold(
      appBar: AppBar(
        title: text("Audio Recordings", textColor: TextColorPrimary),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: RecordListView(
              records: records,
            ),
          ),
          Expanded(
            flex: 1,
            child: RecorderView(
              onSaved: _onRecordComplete,
            ),
          ),
        ],
      ),
    );
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