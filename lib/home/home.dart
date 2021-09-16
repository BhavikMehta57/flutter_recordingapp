import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/scheduler.dart';
import 'package:recording_app/audio/recorder_home_view.dart';
import 'package:recording_app/authentication/Login.dart';
import 'package:recording_app/main.dart';
import 'package:recording_app/main/utils/AppColors.dart';
import 'package:recording_app/main/utils/AppConstant.dart';
import 'package:recording_app/main/utils/AppWidget.dart';
import 'package:share/share.dart';

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  String link="";

  @override
  void initState(){
    super.initState();
  }

  signOut() {
    //redirect
    FirebaseAuth.instance.signOut().then((value) => Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
        Login()), (Route<dynamic> route) => false));
  }

  int _currentIndex = 0;
  int _pageIndex = 0;

  final List<Widget> _children = [
    Home(),
    // Announcements(),
    // SubmitPoints(),
    // Rules(),
    // Profile(),
  ];

  _onTap() {
    if(_currentIndex != 1){
      Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => _children[_currentIndex])); // this has changed
    }
    else{
      showModalBottomSheet(
          context: context,
          builder: (context) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.mic_none_outlined,color: appColorPrimary),
                  title: text('Audio'),
                  onTap: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (BuildContext context) => RecorderHomeView(title: 'Audio Recording')));
                  },
                ),
                ListTile(
                  leading: Icon(Icons.mobile_screen_share_outlined,color: appColorPrimary),
                  title: text('Screen Without Audio'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.mobile_screen_share_rounded,color: appColorPrimary),
                  title: text('Screen With Audio'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double h = size.height;
    double w = size.width;
    return Scaffold(
        backgroundColor:app_Background,
        appBar: AppBar(
          backgroundColor: app_Background,
          title: Text("Recording App",
            style: TextStyle(
                color: appColorPrimary,
            ),
          ),
          leading: Image.asset("images/logo.jpg"),
          elevation: 0.0,
          actions: [
            GestureDetector(
              onTap: () {
                Share.share("Check out this app " + link + "", subject: 'Recording App');
              },
              child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Icon(Icons.share,color: appColorPrimary))
              ,
            ),
            GestureDetector(
              onTap: () {
                signOut();
              },
              child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Icon(Icons.exit_to_app,color: appColorPrimary)
              ),
            ),
          ],
          centerTitle: false,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _pageIndex,
          onTap: (index) { // this has changed
            setState(() {
              _currentIndex = index;
            });
            _onTap();
          },
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home,color: appColorPrimary), title: Text("Home",style: TextStyle(color: Colors.red)),backgroundColor: appLayout_background),
            BottomNavigationBarItem(icon: Icon(Icons.add_circle,color: appColorPrimary,size: 50.0,), title: Text("Record",style: TextStyle(color: Colors.red)),backgroundColor: app_Background),
            BottomNavigationBarItem(icon: Icon(Icons.settings,color: appColorPrimary), title: Text("Settings",style: TextStyle(color: Colors.red)),backgroundColor: app_Background),
          ],

        ),
        body: ListView(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(top: 10,bottom: 10),
                    child: text(
                      'Record Voice, Screen with and without audio easily',
                      isCentered: true,
                      maxLine: 3,
                    )
                ),
                SizedBox(
                  height: h*0.04,
                ),
                Container(
                    width: w/2.5,
                    height: h*0.20,
                    decoration: boxDecoration(bgColor: appColorPrimary.withOpacity(0.2), radius: spacing_standard),
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (BuildContext context) => RecorderHomeView(title: 'Audio Recording')));
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.multitrack_audio_outlined,
                            size: w*0.2,
                            color: appColorPrimary,),
                          SizedBox(height: 10),
                          text("Audio", maxLine: 3, isCentered: true, textColor: TextColorPrimary),
                        ],
                      ),
                    )
                ),
                SizedBox(
                  height: h*0.04,
                ),
                Container(
                    width: w/2.5,
                    height: h*0.20,
                    decoration: boxDecoration(bgColor: appColorPrimary.withOpacity(0.2), radius: spacing_standard),
                    child: TextButton(
                      onPressed: () {
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.mobile_screen_share_outlined,
                            size: w*0.2,
                            color: appColorPrimary,),
                          SizedBox(height: 10),
                          text("Screen Recording", maxLine: 3, isCentered: true, textColor: TextColorPrimary),
                        ],
                      ),
                    )
                ),
                SizedBox(
                  height: 10,
                ),
              ],
            ),
            SizedBox(
              height: 10.0,
            )
          ],
        )
    );
  }
}

