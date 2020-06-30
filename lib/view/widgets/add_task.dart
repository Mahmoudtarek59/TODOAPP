import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:semicolontodoapp/model/task.dart';
import 'package:semicolontodoapp/provider/task_provider.dart';

class AddTask extends StatefulWidget {
  final Task eTask;
  AddTask({this.eTask});
  @override
  _AddTaskState createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  String _taskContaint = "";
  DateTime _dateTime;

  String _pickedDateTitle = 'Set timer';

  @override
  void initState() {
    if (widget.eTask != null) {
      final datetime = widget.eTask.dateTime;
      final format = DateFormat("MM/dd HH:mm"); //"6:00 AM"

      _taskContaint = widget.eTask.task;
      _dateTime = datetime;
      _pickedDateTitle = format.format(datetime).toString();
    }
  }

  Future _selectDate() async {
    DateTime datePicked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    TimeOfDay timePicked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (datePicked != null && timePicked != null) {
      final datetime = DateTime(datePicked.year, datePicked.month,
          datePicked.day, timePicked.hour, timePicked.minute); //TODO date time
      final format = DateFormat("MM/dd HH:mm"); //"6:00 AM"
      _dateTime = datetime;
      setState(() => _pickedDateTitle = format.format(datetime).toString());
    }
  }

  void addTask() async {
    if (_taskContaint.isNotEmpty) {
      if (_dateTime != null) {
        if (widget.eTask == null) {
          await Provider.of<TaskProvider>(context, listen: false)
              .addTask(Task(task: _taskContaint, dateTime: _dateTime));
        } else {
          await Provider.of<TaskProvider>(context, listen: false).updateTask(
              Task(
                  id: widget.eTask.id,
                  task: _taskContaint,
                  dateTime: _dateTime));
        }
        Navigator.of(context).pop();
      }
      return;
    }
    return;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.all(10),
        padding: EdgeInsets.only(right: 10, top: 5),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter task description',
              ),
              initialValue: widget.eTask != null ? widget.eTask.task : null,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              autofocus: true,
              onChanged: (val) => setState(() => _taskContaint = val),
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                FlatButton.icon(
                  onPressed: _selectDate,
                  icon: Icon(Icons.timer),
                  label: Text('$_pickedDateTitle'),
                  color: Theme.of(context).accentColor.withOpacity(0.2),
                  textColor: Theme.of(context).accentColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                Spacer(),
                SizedBox(
                  width: 50,
                  child: FlatButton(
                    padding: EdgeInsets.all(0),
                    onPressed: _taskContaint.isNotEmpty ? addTask : null,
                    child: Text('Done'),
                    textColor: Theme.of(context).accentColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
