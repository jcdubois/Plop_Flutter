import 'package:flutter/material.dart';
import 'tank.dart';
import 'package:intl/intl.dart';
import 'main.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:datetime_picker_formfield/time_picker_formfield.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';

class CreateReminder extends StatefulWidget {
  @override
  CreateReminderState createState() => new CreateReminderState();
}

class CreateReminderState extends State<CreateReminder> {

  DateTime date;
  TimeOfDay time = TimeOfDay(hour: DateTime.now().hour, minute: DateTime.now().minute);

  String selectedType;
  String selectedTank;
  String selectedHabitant;
  String selectedInterval;
  List<Inhabitant> selectedTankHabitants =[];
  List<String> reminderTypes = ['Feeding', 'Cleaning', 'Water Change'];
  List<bool> reminderDays = [false, false, false, false, false, false, false];

  List<Tank> _mytanks;


  final noteFieldController = TextEditingController();
  final daysFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        backgroundColorStart: myTheme.appBarStart,
        backgroundColorEnd: myTheme.appBarEnd,
        brightness: Brightness.dark, // or use Brightness.dark
        elevation: 1,
        title: Text('Task',),
      ),
      body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 60.0),
          child: _habitantCreation()
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          setReminder();
        },
        icon: Icon(Icons.alarm_on),
        label: Text("Save"),
      ),
    );
  }


  Widget _habitantCreation() {
    final dateFormat = DateFormat("EEEE, MMMM d, yyyy 'at' h:mma");
    final timeFormat = DateFormat("h:mm a");
    _mytanks = [];
    _mytanks.add(new Tank(id:-1,name:'All'));
    for (var tank in mytanks){
      _mytanks.add(tank);
    }

    return Center(
        child: Column(
          children: <Widget>[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Form(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ListTile(
                          title: Text(
                              "Task Type",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 21, foreground: Paint()..shader=myTheme.textGradient)
                          ),
                        ),
                        ListTile(
                          title: Text("Reminder Type"),
                          subtitle: Text(
                              "The type of reminder."),
                        ),
                        Center(
                          child: new DropdownButton<String>(
                            hint: new Text("Select an action"),
                            value: selectedType,
                            onChanged: (String newValue) {
                              setState(() {
                                selectedType = newValue;
                              });
                            },
                            items: reminderTypes.map((String type) {
                              return new DropdownMenuItem<String>(
                                value: type,
                                child: new Text(
                                  type,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        ListTile(
                          title: Text("Tank"),
                          subtitle: Text(
                              "The tank that your reminder relates to"),
                        ),
                        Center(
                          child: new DropdownButton<String>(
                            hint: new Text("Select a tank"),
                            value: selectedTank,
                            onChanged: (String newValue) {
                              setState(() {
                                selectedTank = newValue;
                                print(selectedTank);
                                selectedTankHabitants = [];
                                selectedTankHabitants.add(new Inhabitant(
                                  name:'All',id:'-1',
                                ));
                                for (var hab in myinhabitants){
                                  if (selectedTank==hab.tank.toString()){
                                    selectedTankHabitants.add(hab);
                                  }
                                }
                                print(selectedTankHabitants);
                              });
                            },
                            items: _mytanks.map((dynamic tank) {
                              return new DropdownMenuItem<String>(
                                value: tank.id.toString(),
                                child: new Text(
                                  tank.name,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        selectedType == 'Cleaning' || selectedType=='Water Change'
                            ? Text("")
                            :
                        ListTile(
                          title: Text("Habitant"),
                          subtitle: Text(
                              "Select the habitant."),
                        ),
                        selectedType == 'Cleaning' || selectedType=='Water Change'
                            ? Text("")
                            :
                        selectedTank == null
                            ? new Text('No Tank selected.')
                            :
                        Center(
                          child: new DropdownButton<String>(
                            hint: selectedTankHabitants.length <= 0
                                ? new Text('Tank contains no habitants.')
                                :new Text("Select a Habitant"),
                            value: selectedHabitant,
                            onChanged: (String newValue) {
                              setState(() {
                                selectedHabitant = newValue;
                              });
                            },
                            items: selectedTankHabitants.map((dynamic habitant) {
                              return new DropdownMenuItem<String>(
                                value: habitant.id.toString(),
                                child: new Text(
                                  habitant.name,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    )
                ),
              ),
            ),
            selectedType == 'Water Change' ? Card(
              child:Padding(
                padding:EdgeInsets.all(8),
                child:Column(
                  children: <Widget>[
                    ListTile(
                      title: Text(
                          "Water Change Interval",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 21, foreground: Paint()..shader=myTheme.textGradient)
                      ),
                    ),
                    Container(
                      width:150,
                      child:TextFormField(
                          controller: daysFieldController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            icon: Icon(Icons.calendar_today),
                            hintText: 'Days interval',
                            labelText: 'Days interval',
                          ),
                          validator: (value) {
                            var val = int.tryParse(value);
                            if (val == null) {
                              return('Interval must be a number.');
                            }
                          }
                      ),
                    ),
                    ListTile(
                      title:Text('Starting at'),
                    ),
                    DateTimePickerFormField(
                      format: dateFormat,
                      decoration: InputDecoration(
                        labelText: 'Date',
                        border: OutlineInputBorder(),
                        icon: Icon(Icons.calendar_today),
                      ),
                      onChanged: (dt) => setState(() => date = dt),
                    ),
                  ],
                ),
              ),
            ) : Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    ListTile(
                      title: Text(
                          "Task Time",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 21, foreground: Paint()..shader=myTheme.textGradient)
                      ),
                    ),
                    ListTile(
                      title: Text("Reminder Time and Days"),
                      subtitle: Text(
                          "Choose how often to complete the reminder action"),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        MaterialButton(
                          child: const Text('S'),
                          color: reminderDays[0]==false
                          ? Colors.white : Colors.blueAccent,
                          textColor: reminderDays[0]==false
                              ? Colors.blueAccent : Colors.white,
                          minWidth: 5,
                          onPressed: () {
                            setState(() {
                              reminderDays[0] = !reminderDays[0];
                            });
                          },
                        ),
                        MaterialButton(
                          child: const Text('M'),
                          color: reminderDays[1]==false
                              ? Colors.white : Colors.blueAccent,
                          textColor: reminderDays[1]==false
                              ? Colors.blueAccent : Colors.white,
                          minWidth: 5,
                          onPressed: () {
                            setState(() {
                              reminderDays[1] = !reminderDays[1];
                            });
                          },
                        ),
                        MaterialButton(
                          child: const Text('T'),
                          color: reminderDays[2]==false
                              ? Colors.white : Colors.blueAccent,
                          textColor: reminderDays[2]==false
                              ? Colors.blueAccent : Colors.white,
                          minWidth: 5,
                          onPressed: () {
                            setState(() {
                              reminderDays[2] = !reminderDays[2];
                            });
                          },
                        ),
                        MaterialButton(
                          child: const Text('W'),
                          color: reminderDays[3]==false
                              ? Colors.white : Colors.blueAccent,
                          textColor: reminderDays[3]==false
                              ? Colors.blueAccent : Colors.white,
                          minWidth: 5,
                          onPressed: () {
                            setState(() {
                              reminderDays[3] = !reminderDays[3];
                            });
                          },
                        ),
                        MaterialButton(
                          child: const Text('T'),
                          color: reminderDays[4]==false
                              ? Colors.white : Colors.blueAccent,
                          textColor: reminderDays[4]==false
                              ? Colors.blueAccent : Colors.white,
                          minWidth: 5,
                          onPressed: () {
                            setState(() {
                              reminderDays[4] = !reminderDays[4];
                            });
                          },
                        ),
                        MaterialButton(
                          child: const Text('F'),
                          color: reminderDays[5]==false
                              ? Colors.white : Colors.blueAccent,
                          textColor: reminderDays[5]==false
                              ? Colors.blueAccent : Colors.white,
                          minWidth: 5,
                          onPressed: () {
                            setState(() {
                              reminderDays[5] = !reminderDays[5];
                            });
                          },
                        ),
                        MaterialButton(
                          child: const Text('S'),
                          color: reminderDays[6]==false
                              ? Colors.white : Colors.blueAccent,
                          textColor: reminderDays[6]==false
                              ? Colors.blueAccent : Colors.white,
                          minWidth: 5,
                          onPressed: () {
                            setState(() {
                              reminderDays[6] = !reminderDays[6];
                            });
                          },
                        ),
                      ],
                    ),
                    TimePickerFormField(
                      format: timeFormat,
                      decoration: InputDecoration(
                        labelText: 'Time',
                        border: OutlineInputBorder(),
                        icon: Icon(Icons.timer),
                      ),
                      onChanged: (t) => setState(() => time = t),
                    ),
                  ],
                )
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Form(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ListTile(
                        title: Text(
                            "Details",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 21, foreground: Paint()..shader=myTheme.textGradient)
                        ),
                      ),

                        ListTile(
                          title: Text("Reminder Notes"),
                          subtitle: Text("Any notes related to the action Required"),
                        ),
                        TextFormField(
                          keyboardType: TextInputType.multiline,
                          maxLines: 5,
                          controller: noteFieldController,
                          //initialValue: myTank.size.toString(),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Notes.',
                          ),
                        ),
                      ],
                    )
                ),
              ),
            ),
          ],
        )
    );
  }



  TextStyle formText = TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.w400,
  );

  setReminder() async {
    //Prep notification
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid =
    new AndroidInitializationSettings('@drawable/ic_stat_artboard_1');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();

    //Prep Sharedpreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int counter = (prefs.getInt('notification_id_counter') ?? 0);
    int group = (prefs.getInt('notification_group_counter') ?? 0);
    group++;

    //Prep Database
    var databasesPath = await getDatabasesPath();
    String path = databasesPath + '/plop.db';
    Database database = await openDatabase(path, version: 1);

    //Get tank and habitant name
    String selectedTankName;
    String selectedHabitantName;
    if (selectedTank == '-1') {
      selectedTankName = 'All Tanks';
    } else {
      for (var tank in mytanks) {
        if (tank.id == int.parse(selectedTank)) {
          selectedTankName = tank.name;
        }
      }
    }
    if (selectedHabitant == '-1') {
      selectedHabitantName = "Everyone";
      //selectedHabitant = '-1';
    } else {
      for (var hab in myinhabitants) {
        if (hab.id == selectedHabitant) {
          selectedHabitantName = hab.name;
        }
      }
    }
    int _interval = int.parse(daysFieldController.text);

    //Time
    var _time = new Time(time.hour, time.minute, 00);

    if(selectedType=='Water Change'){
      var scheduledNotificationDateTime = date;
      var androidPlatformChannelSpecifics = new AndroidNotificationDetails('your other channel id',
          'your other channel name', 'your other channel description');
      var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
      NotificationDetails platformChannelSpecifics = new NotificationDetails(
          androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
      await flutterLocalNotificationsPlugin.schedule(
          0,
          'Water Change',
          '$selectedTankName needs a water change.',
          scheduledNotificationDateTime,
          platformChannelSpecifics);
      await database.transaction((txn) async {
        int id1 = await txn.rawInsert(
            'INSERT INTO Reminders(notificationid, tankgroup, type, tank, habitant, note, time, day, done) VALUES(' +
                counter.toString() + ',' + group.toString() + ',"' +
                selectedType + '",' + selectedTank.toString() + ',' +
                '0' + ',"' +
                noteFieldController.text + '","' +
                (time.hour.toString() + ':' + time.minute.toString()) +
                '","' + date.day.toString() + '",' + 'false' + ',' + _interval.toString() + ')');
        print('inserted1: $id1');
        counter++;
      });

    } else {

      var androidPlatformChannelSpecifics =
      new AndroidNotificationDetails('show weekly channel id',
          'show weekly channel name', 'show weekly description');
      var platformChannelSpecifics = new NotificationDetails(
          androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

      List<Day> days = [Day.Sunday, Day.Monday, Day.Tuesday, Day.Wednesday, Day.Thursday, Day.Friday, Day.Saturday];

      int _i = 0;

      for (var day in days) {
        if (reminderDays[_i] == true) {
          if (selectedType == "Cleaning") {
            await flutterLocalNotificationsPlugin.showWeeklyAtDayAndTime(
                counter,
                'Cleaning reminder',
                '$selectedTankName needs to be cleaned!',
                day,
                _time,
                platformChannelSpecifics);
          } else {
            await flutterLocalNotificationsPlugin.showWeeklyAtDayAndTime(
                counter,
                'Feeding reminder',
                '$selectedHabitantName in $selectedTankName needs feeding!',
                day,
                _time,
                platformChannelSpecifics, payload: counter.toString());
          }
          // Insert some records in a transaction
          await database.transaction((txn) async {
            int id1 = await txn.rawInsert(
                'INSERT INTO Reminders(notificationid, tankgroup, type, tank, habitant, note, time, day, done) VALUES(' +
                    counter.toString() + ',' + group.toString() + ',"' +
                    selectedType + '",' + selectedTank.toString() + ',' +
                    selectedHabitant.toString() + ',"' +
                    noteFieldController.text + '","' +
                    (time.hour.toString() + ':' + time.minute.toString()) +
                    '","' + day.value.toString() + '",' + 'false' + ')');
            print('inserted1: $id1');
          });
        }
        counter++;
        _i++;
      }
    }
    await prefs.setInt('notification_id_counter', counter);
    await prefs.setInt('notification_group_counter', group);
    database.close();

    buildTanks();
    Navigator.pop(context);
    }

}

