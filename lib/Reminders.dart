import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'CreateReminder.dart';
import "main.dart";
import 'tank.dart';
import 'package:sqflite/sqflite.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';


class Reminders extends StatefulWidget {
  @override
  RemindersState createState() => new RemindersState();
}

class RemindersState extends State<Reminders> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:myreminders.length==0
          ? Center(
        child: Text('No reminders'),
      )
          :myTank==null
        ? remindersList('All')
        : remindersList(myTank.id),
      appBar: GradientAppBar(
        backgroundColorStart: myTheme.appBarStart,
        backgroundColorEnd: myTheme.appBarEnd,
        brightness: Brightness.dark, // or use Brightness.dark
        elevation: 1,
        title: Text('Tasks'
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator
              .push(
            context,
            new MaterialPageRoute(builder: (context) => new CreateReminder()),
          );
        },
        child: Icon(Icons.alarm_add),
      ),
    );
  }

  Widget remindersList(tankName){
    List<List<Reminder>> builtReminders = [];
    List<List<Reminder>> sortedReminders = [];
    List<Reminder> reminderGroup = [];
    bool empty = true;

    reminderGroup.add(myreminders.first);
      for (var i = 1; i < myreminders.length; i++) {
        if (myreminders[i].group == myreminders[i-1].group) {
          reminderGroup.add(myreminders[i]);
          if (myreminders[i] == myreminders.last) {
            print('Reached last reminder and adding remindergroup ' + reminderGroup.first.group.toString());
            builtReminders.add(reminderGroup);
          }
        } else {
          print('Adding remindergroup ' + reminderGroup.first.group.toString());
          builtReminders.add(reminderGroup);
          reminderGroup = [];
          reminderGroup.add(myreminders[i]);
        }
      }

      if(tankName=='All'){
        sortedReminders=builtReminders;
      } else {
        for(var remlist in builtReminders){
          if (remlist.first.tank==myTank.id){
            sortedReminders.add(remlist);
          }
        }
      }
    if (sortedReminders.length==0){
      return Center(
        child: Text('No reminders'),
      );
    } else {
      return
        ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            itemCount: sortedReminders.length,
            itemBuilder: /*1*/ (context, i) {
              List<Reminder> sortedRems = sortedReminders[i];
              Reminder firstRem = sortedRems[0];
              List<String> days = [
                'Sun', 'Mon', 'Tue', 'Wed', "Thu", 'Fri', 'Sat'];
              String reminderDays = '';
              String _myHabitant = 'Everyone';
              String _myTank = 'All';

              if (firstRem.type == 'Feeding') {
                for (var hab in myinhabitants) {
                  if (hab.id == firstRem.inhabitant.toString()) {
                    _myHabitant = hab.name;
                  }
                }
              } else {
                _myHabitant = '';
              }
              for (var tank in mytanks){
                if (tank.id==firstRem.tank){
                  _myTank = tank.name;
                }
              }

              for (var rem in sortedRems) {
                var reminderDay = int.parse(rem.stringDay);
                reminderDays = reminderDays + days[reminderDay - 1] + ' ';
              }
              return Center(
                child: Card(
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ListTile(
                        title:
                        Text('\n' + firstRem.type + ' ' + _myHabitant, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 21,foreground: Paint()..shader=myTheme.textGradient)),
                        subtitle: Text(
                            'Tank: ' + _myTank + '\n' + reminderDays + '\n' + firstRem.stringTime + '\n' + firstRem.notes),
                      ),
                      ButtonTheme
                          .bar( // make buttons use the appropriate styles for cards
                        child: ButtonBar(
                          children: <Widget>[
                            RaisedButton(
                              child: const Text('Cancel',
                                style: TextStyle(color: Colors.white),),
                              color: Colors.redAccent,
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    // return object of type Dialog
                                    return AlertDialog(
                                      title: new Text("Cancel"),
                                      content: new Text(
                                          "Are you sure you want to cancel this reminder?"),
                                      actions: <Widget>[
                                        // usually buttons at the bottom of the dialog
                                        new FlatButton(
                                          child: new Text("No"),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        new FlatButton(
                                          child: new Text("Yes"),
                                          onPressed: () {
                                            deleteNotification(sortedRems);
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                                //
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            });
    }
    }

    deleteNotification(List<Reminder> remGroup) async {
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
      var initializationSettingsAndroid =
      new AndroidInitializationSettings('@drawable/ic_stat_artboard_1');
      var initializationSettingsIOS = new IOSInitializationSettings();
      var initializationSettings = new InitializationSettings(
          initializationSettingsAndroid, initializationSettingsIOS);
      flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
      flutterLocalNotificationsPlugin.initialize(initializationSettings,
          onSelectNotification: onSelectNotification);

      var databasesPath = await getDatabasesPath();
      String path = databasesPath + '/plop.db';

      // open the database
      Database database = await openDatabase(path, version: 1);


    for (var rem in remGroup){
      // cancel the notification with id value of zero
      await flutterLocalNotificationsPlugin.cancel(rem.notificationid);
      await database.rawDelete('DELETE FROM Reminders WHERE notificationid = ' + rem.notificationid.toString());
      myreminders.remove(rem);
    }
      setState(() {

      });
    }


}


