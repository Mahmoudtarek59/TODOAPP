import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:semicolontodoapp/constant.dart';
import 'package:semicolontodoapp/provider/auth.dart';
import 'package:semicolontodoapp/provider/task_provider.dart';
import 'package:semicolontodoapp/view/screens/task_screen.dart';
import 'package:semicolontodoapp/view/screens/login_screen.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = new GoogleSignIn();

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> _formkey = new GlobalKey<FormState>();

  String _name;

  String _email;

  String _password;

  bool imageLoaded = false;

  File _image;

  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);
    setState(() {
      _image = File(pickedFile.path);
    });
  }

  void _googleSignUp(BuildContext context) {
    Provider.of<Auth>(context, listen: false)
        .signWithGmail(email: _email, password: _password);
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => TaskScreen()),
        (route) => false);
  }

  void _sign(BuildContext context) async {
    final _formData = _formkey.currentState;
    if (_formData.validate()) {
      setState(() {
        imageLoaded = true;
      });
      _formData.save();
      try {
        final FirebaseUser user = (await _auth.createUserWithEmailAndPassword(
                email: _email, password: _password))
            .user;

        var userUpdateInfo = UserUpdateInfo();
        userUpdateInfo.displayName = _name;
        userUpdateInfo.photoUrl = await Auth().uploadImage(_image, '${user.uid}${DateTime.now()}');//TODO upload image
        await user.updateProfile(userUpdateInfo);
        await user.reload();

        assert(user != null);
        assert(await user.getIdToken() != null);
        user.sendEmailVerification();

//        print('${await user.getIdToken()}');
//        print(user.email);
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => LoginScreen(
              message: "check your email and Verify your account and login"),
        ));
        setState(() {
          imageLoaded = false;
        });
      } catch (e) {
        print(e);
        //already have an account
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => LoginScreen(
            message: "already have an account Log in now",
          ),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topCenter, colors: [
              Colors.black87,
              Colors.black54,
              Colors.black45,
              Colors.black38,
              Colors.black26,
              Colors.black12,
        ])),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 80,
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "SignUp",
                    style: TextStyle(color: Colors.white, fontSize: 40),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Create an account",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(60),
                    )),
                child: imageLoaded
                    ? Center(
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.blueGrey[700],
                        ),
                      )
                    : SingleChildScrollView(
                        child: Form(
                          key: _formkey,
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: <Widget>[
                                CircleAvatar(
                                    backgroundColor: Colors.black87,
                                    radius: 55,
                                    backgroundImage: _image != null
                                        ? FileImage(_image)
                                        : null,
                                    child: Center(
                                      child: IconButton(
                                        icon: Icon(
                                          _image == null ? Icons.add : null,
                                          size: 30,
                                        ),
                                        color: Colors.white,
                                        onPressed: getImage,
                                      ),
                                    )),

                                SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.blueGrey,
                                            blurRadius: 30,
                                            offset: Offset(0, 10))
                                      ]),
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(
                                                    color: Colors.grey[600]))),
                                        child: TextFormField(
                                          decoration: InputDecoration(
                                              hintText: "Name",
                                              hintStyle:
                                                  TextStyle(color: Colors.grey),
                                              border: InputBorder.none),
                                          validator: (val) {
                                            if (val.isEmpty) {
                                              return 'enter your Name';
                                            }
                                          },
                                          style: TextStyle(color: KAccentColorLightMode),
                                          onSaved: (val) => _name = val,
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(
                                                    color: Colors.grey[600]))),
                                        child: TextFormField(
                                          decoration: InputDecoration(
                                              hintText: "Email",
                                              hintStyle:
                                                  TextStyle(color: Colors.grey),
                                              border: InputBorder.none),
                                          style: TextStyle(color: KAccentColorLightMode),
                                          validator: (val) {
                                            if (val.isEmpty) {
                                              return 'enter your email';
                                            }
                                          },
                                          onSaved: (val) => _email = val,
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(
                                                    color: Colors.grey[200]))),
                                        child: TextFormField(
                                          obscureText: true,
                                          style: TextStyle(color: KAccentColorLightMode),
                                          decoration: InputDecoration(
                                              hintText: "Password",
                                              hintStyle:
                                                  TextStyle(color: Colors.grey),
                                              border: InputBorder.none),
                                          validator: (val) {
                                            if (val.isEmpty) {
                                              return 'enter you password';
                                            }
                                          },
                                          cursorColor: KAccentColorLightMode,
                                          onSaved: (val) => _password = val,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 40,
                                ),
//                          Text("Forgot Password?", style: TextStyle(color: Colors.grey),),
//                          SizedBox(height: 40,),
                                SizedBox(
                                  height: 50,
//                            margin: EdgeInsets.symmetric(horizontal: 20),
                                  width: MediaQuery.of(context).size.width,
                                  child: RaisedButton(
                                    onPressed: () => _sign(context),
                                    child: new Text(
                                      "SignUp",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                    color: Colors.black87,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            new BorderRadius.circular(50),
                                        side:
                                            BorderSide(color: Colors.blueGrey)),
                                  ),
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                                Divider(),
                                SizedBox(
                                  height: 30,
                                ),
                                SizedBox(
                                  height: 50,
                                  width: MediaQuery.of(context).size.width,
                                  child: SignInButton(
                                    Buttons.Google,
                                    text: "Sign Up with Google",
                                    onPressed: () => _googleSignUp(context),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          new BorderRadius.circular(50),
                                      side: BorderSide(color: Colors.black),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                                SizedBox(
                                  height: 50,
                                  width: MediaQuery.of(context).size.width,
                                  child: new FlatButton(
                                      onPressed: () => Navigator.of(context)
                                          .pushReplacement(MaterialPageRoute(
                                              builder: (_) => LoginScreen())),
                                      child: new Text(
                                        "Have an account? Sign in",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: KAccentColorLightMode,
                                        ),
                                      )),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
