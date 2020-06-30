import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:semicolontodoapp/constant.dart';
import 'package:semicolontodoapp/model/task.dart';
import 'package:semicolontodoapp/provider/auth.dart';
import 'package:semicolontodoapp/provider/task_provider.dart';
import 'package:semicolontodoapp/view/screens/login_screen.dart';
import 'package:semicolontodoapp/view/screens/signup_screen.dart';
import 'package:semicolontodoapp/view/screens/task_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    //to prevent landscape mode
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    var mode =
        SchedulerBinding.instance.window.platformBrightness; //no context needed
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<Auth>(
          create: (context) => Auth(),
        ),

        ChangeNotifierProxyProvider<Auth, TaskProvider>(
          update: (_, auth, previousTask) => TaskProvider(
            auth.token,
            auth.userID,
            previousTask == null ? List<Task>() : previousTask.tasks,
          ),
        ),
//        ChangeNotifierProvider<TaskProvider>(
//          create: (context) => TaskProvider(),
//        ),
      ],
      child: Consumer<Auth>(
          builder: (context, auth, child) => MaterialApp(
                title: 'TODO-APP',
                theme: _AppMode(isDarkMode, mode),
                home: auth.isAuth
                    ? TaskScreen()
                    : FutureBuilder(
                        future: auth.autoLogIn(),
                        builder: (context, dataSnapshot) =>
                            dataSnapshot.connectionState ==
                                    ConnectionState.waiting
                                ? Scaffold(
                                    body: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                : LoginScreen()),
              )),
    );
  }

  ThemeData _AppMode(bool isDarkMode, mode) {
//    if(isDarkMode){//if i use switch
    if (mode == Brightness.dark) {
      return ThemeData(
        primaryColor: KPrimaryColorDarkMode,
        accentColor: KAccentColorDarkMode,
        brightness: Brightness.dark,
        textTheme: TextTheme(
          headline: TextStyle(fontSize: 22.0), //app bar title
          display1: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
          ), //funded product title
          display2: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w600,
          ),
          display3: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.w700,
          ), //product details screen title
          display4: TextStyle(
            fontSize: 22.0,
            fontWeight: FontWeight.w300,
          ),
          subhead: TextStyle(
            fontSize: 15.0,
            fontWeight: FontWeight.w500,
          ),
          title: TextStyle(
            fontSize: 17.0,
            fontWeight: FontWeight.w600,
          ), //product title
          body1: TextStyle(
            fontSize: 14.0,
            color: KAccentColorDarkMode,
          ), // old price
          body2: TextStyle(fontSize: 16.0), //price
          caption: TextStyle(
            fontSize: 12.0,
          ),
        ),
      );
    }

    return ThemeData(
      primaryColor: KPrimaryColorLightMode,
      accentColor: KAccentColorLightMode,
      brightness: Brightness.light,
      textTheme: TextTheme(
        headline: TextStyle(fontSize: 22.0), //app bar title
        display1: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.w600,
        ), //funded product title
        display2: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.w600,
        ),
        display3: TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.w700,
        ), //product details screen title
        display4: TextStyle(
          fontSize: 22.0,
          fontWeight: FontWeight.w300,
        ),
        subhead: TextStyle(
          fontSize: 15.0,
          fontWeight: FontWeight.w500,
        ),
        title: TextStyle(
          fontSize: 17.0,
          fontWeight: FontWeight.w600,
        ), //product title
        body1: TextStyle(
          fontSize: 14.0,
          color: KAccentColorLightMode,
        ), // old price
        body2: TextStyle(fontSize: 16.0,), //price
        caption: TextStyle(
          fontSize: 12.0,
        ),
      ),
    );
  }
}
