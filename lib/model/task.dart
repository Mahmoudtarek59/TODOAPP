
import 'package:flutter/cupertino.dart';

class Task extends ChangeNotifier{
  final String id;
  String task;
  DateTime dateTime;
  bool isDone;
  Task({@required this.id,@required this.task,@required this.dateTime,this.isDone=false});


  void toggleIsDone(){
    final oldStatus =isDone;
    isDone = !isDone;
    notifyListeners();
  }
}