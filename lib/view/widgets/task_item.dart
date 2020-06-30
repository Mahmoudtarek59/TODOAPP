import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:semicolontodoapp/model/task.dart';
import 'package:semicolontodoapp/provider/task_provider.dart';
import 'package:semicolontodoapp/view/screens/task_screen.dart';
import 'package:semicolontodoapp/view/widgets/showBTs.dart';

class TaskItem extends StatelessWidget {
  _removeConfirm(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('Are you sure?'), //TODO translate
              content: Text('Do you want to remove this task?'),
              actions: [
                FlatButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text('No')),
                FlatButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text('Yes')),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    final task = Provider.of<Task>(context);

    return Dismissible(
      key: ValueKey(task.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).errorColor,
        ),
        child: Icon(
          Icons.delete,
          color: Colors.white,
          size: 40,
        ),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await _removeConfirm(context);
      },
      onDismissed: (direction) {
        Provider.of<TaskProvider>(context, listen: false).removeTask(task.id);
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: ListTile(
          title: Text(
            task.task.length < 110
                ? task.task
                : '${task.task.substring(0, 110)}...',
            style: Theme.of(context).textTheme.title.copyWith(
                decoration: task.isDone ? TextDecoration.lineThrough : null),
          ),
          subtitle: Text(DateFormat('dd/MM/yyyy hh:mm').format(task.dateTime)),
          trailing: Checkbox(
            value: task.isDone,
            onChanged: (val) => task.toggleIsDone(),
            activeColor: Theme.of(context).accentColor,
            checkColor: Theme.of(context).primaryColor,
          ),

          onTap: ()=>ShowBTS().showBTS(context: context,task: task),
        ),
      ),
    );
  }
}
