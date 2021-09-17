import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:recording_app/authentication/Login.dart';
import 'package:recording_app/authentication/otp.dart';
import 'package:recording_app/home/home.dart';
import 'package:recording_app/main.dart';
import 'package:recording_app/main/utils/AppColors.dart';
import 'package:recording_app/main/utils/AppConstant.dart';
import 'package:recording_app/main/utils/AppString.dart';
import 'package:recording_app/main/utils/AppWidget.dart';
import 'package:recording_app/main/utils/animation/fadeAnimation.dart';
import 'package:nb_utils/nb_utils.dart';

class Signup extends StatefulWidget {
  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? fullName;
  String? phoneNumber;
  String? email;
  String? password;
  String? rePassword;

  bool isLoading = false;

  startLoading() => setState(() {
        isLoading = true;
      });
  stopLoading() => setState(() {
        isLoading = false;
      });

  Future<void> addUserToDatabase() async {
    String phone = '+91' + phoneNumber!;
    await _firestore.collection("users").doc(phone).set({
      "Full Name": fullName,
      "Phone Number": phone,
      "Email": email,
      "Password": password,
      "Registered On": DateTime.now().toString(),
    });
  }

  Future<void> processRegisterRequest(context) async {
    String phone = "+91" + phoneNumber!;
    stopLoading();
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
                //Sign In using auth credentials
                final result = await _auth.signInWithCredential(credential);
                print(
                    "Tried logging in with phone auth credentials... from SignUp");
                User? user = result.user;

                // Store user details in database
                await addUserToDatabase();

                if (user != null) {
                  print("User Not Null, Sign In, Redirecting To Home");
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => Home(),
                      ),
                      (Route<dynamic> route) => false);
                } else {
                  print("Auth Failed! (Login from SignUp)");
                }
              },
              verifyButtonOnTap:
                  (String verificationId, String enteredCode) async {
                try {
                  final AuthCredential credential =
                      PhoneAuthProvider.credential(
                          verificationId: verificationId, smsCode: enteredCode);

                  final UserCredential userCreds =
                      await _auth.signInWithCredential(credential);
                  final User? currentUser = FirebaseAuth.instance.currentUser;

                  print("Adding to firestore");
                  // Store user details in database
                  await addUserToDatabase();

                  assert(userCreds.user!.uid == currentUser!.uid);

                  if (userCreds.user != null) {
                    print("User Not Null, Signing In, Redirecting To Home");
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => Home(),
                        ),
                        (Route<dynamic> route) => false);
                    return "Success";
                  } else {
                    print("Auth Failed! (Login, from verify callback)");
                    return "Some error occurred!";
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Center(
        child: Container(
          alignment: Alignment.center,
          child: Observer(
            builder: (_) => SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // SizedBox(height: 30),
                  // FadeAnimation(
                  //     0.4,
                  //     commonCacheImageWidget(SignLogo, 100,
                  //         width: 100, fit: BoxFit.fill)
                  // ),
                  SizedBox(height: 16),
                  FadeAnimation(
                    0.6,
                    formHeading(sign_up_header),
                  ),
                  SizedBox(height: 40),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        FadeAnimation(
                          0.8,
                          TextFormField(
                            keyboardType: TextInputType.text,
                            onChanged: (value){
                              fullName = value;
                              print(fullName);
                            },
                            decoration: InputDecoration(
                              hintText: hint_fullName,
                              prefixIcon: Icon(fullnameIcon),
                            ),
                            validator: (value){
                              if (value == null || value.length == 0) {
                                return "Please enter your full name";
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: 16),
                        FadeAnimation(
                          1.0,
                          TextFormField(
                            keyboardType: TextInputType.phone,
                            onChanged: (value){
                              phoneNumber = value;
                              print(phoneNumber);
                            },
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
                        ),
                        SizedBox(height: 16),
                        FadeAnimation(
                          1.2,
                          TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            onChanged: (value){
                              email = value;
                            },
                            decoration: InputDecoration(
                              hintText: hint_email,
                              prefixIcon: Icon(emailIcon),
                            ),
                            validator: (value){
                              String pattern =
                                  r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                              RegExp regExp = new RegExp(pattern);
                              if (value == null || value.isEmpty) {
                                return 'Please enter email address';
                              } else if (!regExp.hasMatch(value)) {
                                return 'Please enter valid email address';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: 16),
                        FadeAnimation(
                          1.4,
                          TextFormField(
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
                        ),
                        SizedBox(height: 16),
                        FadeAnimation(
                          1.8,
                          TextFormField(
                            keyboardType: TextInputType.text,
                            onChanged: (value){
                              rePassword = value;
                            },
                            obscureText: true,
                            decoration: InputDecoration(
                              hintText: hint_re_passwordText,
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
                        ),
                        SizedBox(height: 20),
                        isLoading
                            ? CircularProgressIndicator()
                            : Padding(
                                padding: const EdgeInsets.fromLTRB(40, 16, 40, 16),
                                child: FadeAnimation(
                                  1.0,
                                    SizedBox(
                                        width: double.infinity,
                                        height: 50,
                                        // height: double.infinity,
                                        child:  MaterialButton(
                                          child: text(sign_upText),
                                          shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(40.0), side: BorderSide(color: appColorPrimary, width: 1)),
                                          color: appWhite,
                                          onPressed: () async {
                                            if (_formKey.currentState!.validate()) {
                                              startLoading();
                                              if (rePassword == password) {
                                                //Check if mobile number is already registered
                                                try {
                                                  DocumentSnapshot ds =
                                                  await _firestore
                                                      .collection("users")
                                                      .doc("+91" + phoneNumber!)
                                                      .get();

                                                  if (ds.exists) {
                                                    final snackBar = SnackBar(
                                                      content: Text(
                                                          'User with this mobile already exists !'),
                                                      duration: Duration(seconds: 3),
                                                    );
                                                    ScaffoldMessenger.of(context)
                                                        .showSnackBar(snackBar);
                                                    stopLoading();
                                                    return;
                                                  } else {
                                                    // Process registration
                                                    await processRegisterRequest(
                                                        context);
                                                  }
                                                } catch (e) {
                                                  print(e);
                                                  final snackBar = SnackBar(
                                                    content: Text(
                                                        'Some error occurred! Please check you internet connection.'),
                                                    duration: Duration(seconds: 3),
                                                  );
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(snackBar);
                                                  stopLoading();
                                                  return;
                                                }
                                              } else {
                                                final snackBar = SnackBar(
                                                  content:
                                                  Text('Passwords do not match'),
                                                  duration: Duration(seconds: 3),
                                                );
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(snackBar);
                                                stopLoading();
                                                return;
                                              }
                                            }
                                          },
                                        )
                                    )
                                ),
                              ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  FadeAnimation(
                    2.0,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        text(already_have_account,
                            textColor: appStore.textSecondaryColor,
                            fontSize: textSizeLargeMedium),
                        SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            Login().launch(context);
                          },
                          child: text(sign_inText,
                              fontFamily: fontMedium,
                              textColor: appColorPrimary),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
