import 'dart:io';
import 'dart:ui';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:recording_app/audio/page_manager.dart';
import 'package:recording_app/audio/recorder_home_view.dart';
import 'package:recording_app/main.dart';
import 'package:recording_app/main/utils/AppColors.dart';
import 'package:recording_app/main/utils/AppConstant.dart';
import 'package:recording_app/main/utils/AppWidget.dart';
import 'package:share/share.dart';

class CustomDialogBox extends StatefulWidget {
  final String title, descriptions, path;

  const CustomDialogBox({Key? key, required this.title, required this.descriptions, required this.path}) : super(key: key);

  @override
  _CustomDialogBoxState createState() => _CustomDialogBoxState();
}

class _CustomDialogBoxState extends State<CustomDialogBox> {

  late final PageManager _pageManager;

  @override
  void initState() {
    super.initState();
    _pageManager = PageManager(widget.path);
  }

  @override
  void dispose() {
    _pageManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }
  contentBox(context){
    return Container(
      height: 300,
      padding: EdgeInsets.only(left: 20,top: 45 + 20, right: 20,bottom: 20),
      margin: EdgeInsets.only(top: 45),
      decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          text(widget.title,
              fontSize: textSizeMedium,
              textColor: appStore.textPrimaryColor,
              fontFamily: fontMedium),
          text(widget.descriptions,
              fontSize: textSizeSMedium,
              textColor: appStore.textSecondaryColor),
          Spacer(),
          ValueListenableBuilder<ProgressBarState>(
            valueListenable: _pageManager.progressNotifier,
            builder: (_, value, __) {
              return ProgressBar(
                progress: value.current,
                buffered: value.buffered,
                total: value.total,
                onSeek: _pageManager.seek,
              );
            },
          ),
          ValueListenableBuilder<ButtonState>(
            valueListenable: _pageManager.buttonNotifier,
            builder: (_, value, __) {
              switch (value) {
                case ButtonState.loading:
                  return Container(
                    margin: EdgeInsets.all(8.0),
                    width: 32.0,
                    height: 32.0,
                    child: CircularProgressIndicator(),
                  );
                case ButtonState.paused:
                  return IconButton(
                    icon: Icon(Icons.play_arrow),
                    iconSize: 32.0,
                    onPressed: _pageManager.play,
                  );
                case ButtonState.playing:
                  return IconButton(
                    icon: Icon(Icons.pause),
                    iconSize: 32.0,
                    onPressed: _pageManager.pause,
                  );
              }
            },
          ),
          SizedBox(height: 10,),
          Row(
            children: [
              Expanded(
                child: MaterialButton(
                  child: text("Share"),
                  shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(40.0), side: BorderSide(color: appDark_parrot_green, width: 1)),
                  color: appWhite,
                  onPressed: () async {
                    Share.shareFiles(['${widget.path}'], text: 'Check this audio');
                  },
                ),
              ),
              SizedBox(width: 5,),
              Expanded(
                child: MaterialButton(
                  child: text("Delete"),
                  shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(40.0), side: BorderSide(color: appDarkRed, width: 1)),
                  color: appWhite,
                  onPressed: () async {
                    await File(widget.path).delete();
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                        context,
                        new MaterialPageRoute(builder: (BuildContext context) => RecorderHomeView(title: 'Audio Recording'))
                    );
                  },
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}