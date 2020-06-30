
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = new GoogleSignIn();

class Auth extends ChangeNotifier{
  String _token;
  String _userId;
  String _message;


  bool get isAuth {
    return token != null;
  }

  String get token {
    if (_token != null) {
      return _token;
    }
    return null;
  }

  String get userID{
    return _userId;
  }


  Future<bool> signWithGmail({String email, String password}) async{
    bool trusted = false;
    GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser
        .authentication; //you can sign in without firebase just get data from google account

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final AuthResult authResult = await _auth.signInWithCredential(credential);
    final FirebaseUser user = authResult.user;

    if (user != null &&
        user.isAnonymous == false && await user.getIdToken() != null) {
       await user.getIdToken(refresh: true).then((value) => _token =value.token);
      _userId = user.uid;
       trusted = true;
    }
    notifyListeners();

    final prefs =await SharedPreferences.getInstance();
    final userData = json.encode({
      'token':_token,
      'userId':_userId,
      'email':email,//for auto login if expiry date isn't valid it is slow
      'password':password,
      'google':true,
      'accessToken':googleAuth.accessToken,
      'idToken':googleAuth.idToken,
    });

    prefs.setString('userData', userData);
    return trusted;
  }


  Future<String> logInWithEmail({String email, String password})async{
    try {
      FirebaseUser user = (await _auth.signInWithEmailAndPassword(
      email: email, password: password))
        .user;
    assert(user != null);

    if (user.isEmailVerified) {
      await user.getIdToken(refresh: true).then((value) => _token =value.token);
      _userId = user.uid;
      notifyListeners();

      final prefs =await SharedPreferences.getInstance();
      final userData = json.encode({
        'token':_token,
        'userId':_userId,
        'email':email,//for auto login if expiry date isn't valid it is slow
        'password':password,
        'google':false,
      });
      prefs.setString('userData', userData);
      return 'Done';
    } else {
//    _scaffoldKey.currentState.showSnackBar(new SnackBar(
//    content: new Text(
//    "Please check you email and verify your account !!")));
    _message ="Please check you email and verify your account !!";
    return _message;

    }
    } catch (e) {
    //Go to sign Up
//    _scaffoldKey.currentState
//        .showSnackBar(new SnackBar(content: new Text("Sign Up now ")));
      _message ="Sign Up now ";
      return _message;
    }
  }

  void logout()async{
    _token=null;
    _userId=null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
//    prefs.remove('userData');
    prefs.clear();
  }

  Future<bool> autoLogIn() async{
    final prefs = await SharedPreferences.getInstance();
//    prefs.clear();  //TODO
    if(!prefs.containsKey('userData')){
      return false;
    }

//    FirebaseAuth.instance.onAuthStateChanged.listen((event){if(event.hashCode != true){
//
//      prefs.clear();
//    }else{
//      print('${event.getIdToken()}');
//    }
//    });

    final extractedUserData = await checkExpiryDate(prefs);

    _token = extractedUserData['token'];
    _userId = extractedUserData['userId'];
    print('========================================${_userId}');
    notifyListeners();
    return true;
  }


  checkExpiryDate(SharedPreferences pref) async{
    if(_auth.currentUser() == null){
      _auth.currentUser().then((value) =>value.getIdToken().whenComplete(() async{
        var extractedUserData = json.decode(pref.getString('userData')) as Map<String,Object>;
        extractedUserData = await updateToken(extractedUserData['email'],extractedUserData['password']);
        return extractedUserData;
      }),);
    }
    return json.decode(pref.getString('userData')) as Map<String,Object>;
  }

   updateToken(String email, String password) async{
    if(_auth.currentUser() != null){
      _auth.currentUser().then((value)async{
        value.getIdToken(refresh: true).then((onValue) => _token=onValue.token);
        final prefs =await SharedPreferences.getInstance();
        final userData = json.encode({
          'token':_token,
          'userId':_userId,
          'email':email,//for auto login if expiry date isn't valid it is slow
          'password':password,
        });
        prefs.setString('userData', userData);
        return userData;
      });
    }
  }


  Future<String> uploadImage(File file,String basename) async{
    StorageReference ref=FirebaseStorage.instance.ref().child('images/${basename}');
    StorageUploadTask uploadTask=ref.putFile(file);
    StorageTaskSnapshot snapshot=await uploadTask.onComplete;
    var  location =await snapshot.ref.getDownloadURL();
    String path =await snapshot.ref.getPath();

    print('Path: ${location.toString()}');
    return location.toString();
  }

}