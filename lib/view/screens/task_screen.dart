
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:semicolontodoapp/provider/task_provider.dart';
import 'package:semicolontodoapp/view/widgets/add_task.dart';
import 'package:semicolontodoapp/view/widgets/drawer_item.dart';
import 'package:semicolontodoapp/view/widgets/showBTs.dart';
import 'package:semicolontodoapp/view/widgets/task_item.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class TaskScreen extends StatefulWidget {

  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {


  @override
  void initState() {
    final fbm = FirebaseMessaging();
    fbm.requestNotificationPermissions();//we need it for IOS not android
    fbm.configure(onMessage: (msg){
      print(msg);
      return;
    },onLaunch: (msg){
      print(msg);
      return;
    },onResume: (msg){
      print(msg);
      return;
    },);
    super.initState();

  }



  Future<void> _refreshTasks(BuildContext context) async {
    await Provider.of<TaskProvider>(context, listen: false).fetchingTasks();
  }


  @override
  Widget build(BuildContext context) {
    var phoneMode = MediaQuery.of(context).orientation;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "TODO",
          style: Theme.of(context).textTheme.headline,
        ),
//        backgroundColor: Theme.of(context).accentColor,
      ),
      drawer: DrawerItem(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ShowBTS().showBTS(context: context),
        child: Icon(Icons.add),
      ),
      body: FutureBuilder(
        future: _refreshTasks(context),
        builder: (context, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: () => _refreshTasks(context),
                    child: Consumer<TaskProvider>(
                      builder:(context,tasks,_)=> Padding(
                        padding: EdgeInsets.all(8),
                        child: ListView.builder(
                          itemCount: tasks.tasks.length,
                          itemBuilder: (BuildContext context, int index) =>
                              ChangeNotifierProvider.value(
                            value: tasks.tasks[index],
                            child: TaskItem(),
                          ),
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }

}
