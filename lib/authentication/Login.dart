import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:recording_app/authentication/SignUp.dart';
import 'package:recording_app/authentication/otp.dart';
import 'package:recording_app/home/home.dart';
import 'package:recording_app/main/utils/AppColors.dart';
import 'package:recording_app/main/utils/AppConstant.dart';
import 'package:recording_app/main/utils/AppString.dart';
import 'package:recording_app/main/utils/AppWidget.dart';
import 'package:recording_app/main/utils/animation/fadeAnimation.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../main.dart';

class Login extends StatefulWidget {
  static var tag = "Login";

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  late String phoneNumber;
  late String password;
  late bool hasLoggedIn;
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;

  Future<void> loginUser(BuildContext context) async {
    String phone = "+91" + phoneNumber;
    try {
      print("Getting ds...");
      DocumentSnapshot ds = await _firestore.collection("users").doc(phone).get();
      print("Got ds...");
      if (!ds.exists) {
        final snackBar = SnackBar(
          content: Text('User does not exist !'),
          duration: Duration(seconds: 3),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        setState(() {
          isLoading = false;
        });
        return;
      } else {
        String? pass;
        await _firestore.collection("users").doc(phone).get().then((value){
          setState(() {
            pass = value.get("Password");
          });
        });
        if (pass == password) {
          //Check user type
          setState(() {
            isLoading = false;
          });
          // Password is correct, hence send OTP
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return Otp(
                    phone: phone,
                    onVerificationFailure: () {
                      print("OTP Verification Failed");
                      final snackBar = SnackBar(
                        content: Text('OTP verification failed !'),
                        duration: Duration(seconds: 3),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      return;
                    },
                    onVerificationSuccess: (AuthCredential credential) async {
                      print("OTP Verification successful !");
                      final result =
                          await _auth.signInWithCredential(credential);

                      User? user = result.user;

                      if (user != null) {
                        print("User Not Null, Loggin In, Redirecing To Home");
                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => Home(),
                            ),
                            (Route<dynamic> route) => false);
                      } else {
                        print("Auth Failed! (Login)");
                      }
                    },
                    verifyButtonOnTap:
                        (String verificationId, String enteredCode) async {
                      try {
                        final AuthCredential credential =
                            PhoneAuthProvider.credential(
                                verificationId: verificationId,
                                smsCode: enteredCode);

                        final UserCredential userCreds =
                            await _auth.signInWithCredential(credential);
                        final User? currentUser =
                            FirebaseAuth.instance.currentUser;

                        assert(userCreds.user!.uid == currentUser!.uid);

                        if (userCreds.user != null) {
                          print(
                              "User Not Null, Logging In, Redirecing To Home");
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => Home(),
                              ),
                              (Route<dynamic> route) => false);
                          return "Success";
                        } else {
                          print("Auth Failed! (Login, from verify callback)");
                          return "Some error occured";
                        }
                      } catch (e) {
                        print("Here is the catched error");
                        print(e);
                        if (e is PlatformException) return (e.code);
                        return "Invalid OTP!";
                      }
                    });
              },
            ),
          );
        } else {
          //Passwords don't match, show error
          final snackBar = SnackBar(
            content: Text('Invalid Credentials !'),
            duration: Duration(seconds: 3),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          setState(() {
            isLoading = false;
          });
          return;
        }
      }
    } catch (e) {
      print(e);
      final snackBar = SnackBar(
        content:
            Text('Some error occurred! Please check you internet connection.'),
        duration: Duration(seconds: 3),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      setState(() {
        isLoading = false;
      });
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Center(
        child: SingleChildScrollView(
          child: Observer(
            builder: (_) => Container(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // FadeAnimation(
                  //     0.4,
                  //     commonCacheImageWidget(SignLogo, 100,
                  //         width: 100, fit: BoxFit.fill)),
                  // SizedBox(height: 16),
                  FadeAnimation(0.6, formHeading(sign_in_header)),
                  SizedBox(height: 40),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        FadeAnimation(
                          0.8,
                          Padding(
                            padding: EdgeInsets.only(left: 25, right: 25),
                            child: TextFormField(
                              keyboardType: TextInputType.phone,
                              onChanged: (value){
                                phoneNumber = value;
                              },
                              obscureText: false,
                              decoration: InputDecoration(
                                hintText: hint_phone,
                                prefixIcon: Icon(phoneIcon),
                              ),
                              validator: (value){
                                String patttern = r'(^[0-9]{10}$)';
                                RegExp regExp = new RegExp(patttern);
                                if (value == null || value.isEmpty) {
                                  return 'Please enter mobile number';
                                } else if (!regExp.hasMatch(value)) {
                                  return 'Please enter valid mobile number';
                                }
                                return null;
                              },
                            ),
                          )
                        ),
                        SizedBox(height: 16),
                        FadeAnimation(
                          1.0,
                          Padding(
                            padding: EdgeInsets.only(left: 25, right: 25),
                            child: TextFormField(
                              keyboardType: TextInputType.text,
                              onChanged: (value){
                                password = value;
                              },
                              obscureText: true,
                              decoration: InputDecoration(
                                hintText: hint_password,
                                prefixIcon: Icon(passwordIcon),
                              ),
                              validator: (value){
                                if (value == null || value.isEmpty) {
                                  return 'Please enter password';
                                } else if (value.length < 6) {
                                  return 'Password must consist of at least 6 characters';
                                }
                                return null;
                              },
                            ),
                          )
                        ),
                        SizedBox(height: 8),
                        SizedBox(height: 8),
                        isLoading
                            ? CircularProgressIndicator()
                            : Padding(
                                padding: const EdgeInsets.fromLTRB(40, 16, 40, 16),
                                child: FadeAnimation(
                                  1.2,
                                    SizedBox(
                                        width: double.infinity,
                                        height: 50,
                                        // height: double.infinity,
                                        child:  MaterialButton(
                                          child: text(sign_inText),
                                          shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(40.0), side: BorderSide(color: appColorPrimary, width: 1)),
                                          color: appWhite,
                                          onPressed: () async {
                                            if (_formKey.currentState!.validate()) {
                                              setState(() {
                                                isLoading = true;
                                              });
                                              await loginUser(context);
                                            }
                                          },
                                        )
                                    )
                                ),
                              ),
                        SizedBox(height: 15),
                      ],
                    ),
                  ),
                  FadeAnimation(
                    1.4,
                    GestureDetector(
                      onTap: () {
                        // ForgotPassword().launch(context);
                      },
                      child: text(forgot_passwordText,
                          textColor: appColorPrimary, fontFamily: fontMedium),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  FadeAnimation(
                    1.6,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        text(not_have_account,
                            textColor: appStore.textSecondaryColor,
                            fontSize: textSizeLargeMedium),
                        SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            Signup().launch(context);
                          },
                          child: text(sign_upText,
                              fontFamily: fontMedium,
                              textColor: appColorPrimary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
