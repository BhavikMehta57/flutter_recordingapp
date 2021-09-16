import 'dart:io';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:recording_app/audio/audio_player.dart';
import 'package:recording_app/audio/page_manager.dart';
import 'package:flutter/material.dart';
import 'package:recording_app/audio/recorder_home_view.dart';
import 'package:recording_app/main.dart';
import 'package:recording_app/main/utils/AppColors.dart';
import 'package:recording_app/main/utils/AppConstant.dart';
import 'package:recording_app/main/utils/AppWidget.dart';
import 'package:share/share.dart';

class RecordListView extends StatefulWidget {
  final List<String> records;
  const RecordListView({
    Key? key,
    required this.records,
  }) : super(key: key);

  @override
  _RecordListViewState createState() => _RecordListViewState();
}

class _RecordListViewState extends State<RecordListView> {

  @override
  Widget build(BuildContext context) {
    return widget.records.isEmpty
        ?
    Center(child: Text('No recordings yet'))
        :
    ListView.builder(
      itemCount: widget.records.length,
      shrinkWrap: true,
      reverse: true,
      itemBuilder: (BuildContext context, int i) {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:[
                    Container(
                      decoration: boxDecoration(
                        bgColor: white,
                        showShadow: false,
                        color: app_Background,
                        radius: spacing_standard,
                      ),
                      padding: EdgeInsets.all(spacing_standard),
                      margin: EdgeInsets.only(bottom: spacing_standard),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                SizedBox(
                                  height: 10,
                                ),
                                text('Recording ${widget.records.elementAt(i).substring(widget.records.elementAt(i).lastIndexOf('/') + 1)}',
                                    fontSize: textSizeSMedium,
                                    textColor: appStore.textPrimaryColor,
                                    fontFamily: fontMedium),
                                text(_getDateFromFilePath(filePath: widget.records.elementAt(i)),
                                    fontSize: textSizeSmall,
                                    textColor: appStore.textSecondaryColor)
                                    .paddingTop(spacing_control_half),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.play_arrow, color: appColorPrimary),
                            onPressed: () {
                              showDialog(context: context,
                                  builder: (BuildContext context){
                                    return CustomDialogBox(
                                      title: "Recording ${widget.records.elementAt(i).substring(widget.records.elementAt(i).lastIndexOf('/') + 1)}",
                                      descriptions: "${_getDateFromFilePath(filePath: widget.records.elementAt(i))}",
                                      path: widget.records.elementAt(i),
                                    );
                                  }
                              );
                            },
                          ),
                          SizedBox(width: 50,)
                        ],
                      ),
                    )
                  ]
              ),
              Divider(height: 1,),
            ]
        );
      },
    );
  }

  String _getDateFromFilePath({required String filePath}) {
    String fromEpoch = filePath.substring(filePath.lastIndexOf('/') + 1, filePath.lastIndexOf('.'));

    DateTime recordedDate = DateTime.fromMillisecondsSinceEpoch(int.parse(fromEpoch));
    print(filePath);
    int year = recordedDate.year;
    int month = recordedDate.month;
    int day = recordedDate.day;
    int hour = recordedDate.hour;
    int minute = recordedDate.minute;
    int second = recordedDate.second;

    return ('$day-$month-$year  $hour:$minute:$second');
  }
}