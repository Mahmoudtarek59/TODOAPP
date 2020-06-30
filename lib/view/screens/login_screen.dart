import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:semicolontodoapp/constant.dart';
import 'package:semicolontodoapp/provider/auth.dart';
import 'package:semicolontodoapp/view/screens/task_screen.dart';
import 'package:semicolontodoapp/view/screens/signup_screen.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = new GoogleSignIn();


class LoginScreen extends StatefulWidget {

  String message;
  LoginScreen({Key key,this.message}):super(key:key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _globalKey = new GlobalKey<FormState>();//form
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();//snack
  String _email;

  String _password;
  bool isloading=false;
  @override
  void initState() {
    super.initState();
//    _checkLogin();//TODO move it with her method to home screen in init State and verfi
    if(widget.message!=null) {
//      print(message);
      WidgetsBinding.instance.addPostFrameCallback((_) =>
          _scaffoldKey.currentState.showSnackBar(
            new SnackBar(content: new Text('${widget.message}')),
          ));
    }
  }


  //google sign in
  void _googleSignin() async {
    setState(() {
      isloading=true;
    });
    bool trusted = await Provider.of<Auth>(context,listen: false).signWithGmail(email: _email,password: _password);
    setState(() {
      isloading=false;
    });
    if(trusted){
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>TaskScreen()), (route) => false);
    }

  }

  void _login() async {

    final formData = _globalKey.currentState;
    if (formData.validate()) {
      setState(() {
        isloading=true;
      });
      formData.save();
      String message = await Provider.of<Auth>(context,listen: false).logInWithEmail(email: _email,password: _password);
      _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text("$message")));
      if(message == 'Done'){
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>TaskScreen()), (route) => false);
      }
      setState(() {
        isloading=false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        width: double.infinity,
        // this decoration for the header
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
          children: [
            SizedBox(
              height: 80,
            ),
            // this Padding for text login to your account
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Login to your Account!",
                    style: TextStyle(color: Colors.white, fontSize: 35),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Welcome Back",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            //Login body
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(60),
                  ),
                ),
                child: SingleChildScrollView(
                  child: isloading?Center(child: CircularProgressIndicator(
                    backgroundColor: Colors.blueGrey[700],
                  ),):Form(
                    key: _globalKey,
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 60,
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
                              ],
                            ),
                            child: Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              color: Colors.grey[600]))),
                                  child: TextFormField(
                                    style: TextStyle(color: KAccentColorLightMode),
                                    decoration: InputDecoration(
                                      hintText: "Email Address",
                                      hintStyle: TextStyle(color: Colors.grey),
                                      border: InputBorder.none,
                                      icon: Icon(
                                        Icons.email,color:KAccentColorLightMode),
                                    ),
                                    validator: (val) {
                                      if (val.isEmpty || !val.contains('@')) {
                                        return 'enter your email';
                                      }
                                    },
                                    onSaved: (val) => _email = val,
                                  ),
                                ),

                                //password
                                Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              color: Colors.grey[200]))),
                                  child: TextFormField(
                                    style: TextStyle(color: KAccentColorLightMode),
                                    obscureText: true,
                                    decoration: InputDecoration(
                                        hintText: "Password",
                                        icon: Icon(Icons.lock,color:KAccentColorLightMode),
                                        hintStyle:
                                        TextStyle(color: Colors.grey),
                                        border: InputBorder.none),
                                    validator: (val) {
                                      if (val.isEmpty || val.length < 5) {
                                        return 'Password is too short!';
                                      }
                                    },
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

                          //login button
                          SizedBox(
                            height: 50,
//                            margin: EdgeInsets.symmetric(horizontal: 20),
                            width: MediaQuery.of(context).size.width,
                            child: RaisedButton(
                              onPressed: _login,
                              shape: RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(50),
                                  side: BorderSide(color: Colors.blueGrey)),
                              color: Colors.black87,
                              child: new Text(
                                "Login",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                          ),

                          SizedBox(
                            height: 30,
                          ),

                          //SignUP
                          SizedBox(
                            height: 50,
//                            margin: EdgeInsets.symmetric(horizontal: 20),
                            width: MediaQuery.of(context).size.width,
                            child: RaisedButton(
                              onPressed: ()=>Navigator.of(context).push(MaterialPageRoute(builder: (context)=>SignUpScreen())),
                              child: new Text(
                                "Sign Up",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              color: Colors.black87,
                              shape: RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(50),
                                  side: BorderSide(color: Colors.blueGrey)),
                            ),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Divider(),
                          SizedBox(
                            height: 30,
                          ),

                          //Sign in with google
                          SizedBox(
                            height: 50,
                            width: MediaQuery.of(context).size.width,
                            child: SignInButton(
                              Buttons.Google,
                              text: "Sign in with Google",
                              onPressed: _googleSignin,
                              shape: RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(50),
                                side: BorderSide(color: Colors.black),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
