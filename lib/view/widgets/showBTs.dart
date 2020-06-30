import 'package:flutter/material.dart';
import 'package:semicolontodoapp/model/task.dart';
import 'package:semicolontodoapp/view/widgets/add_task.dart';

class ShowBTS{

  showBTS({BuildContext context, Task task = null}) {
    showModalBottomSheet(
      elevation: 5,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).primaryColor,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.0))),
      context: context,
      builder: (context) => Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: AddTask(
          eTask: task,
        ),
      ),
    );
  }
}
