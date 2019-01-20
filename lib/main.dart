import 'package:flutter/material.dart';
import 'tank.dart';
import 'TankList.dart';
import 'SettingsView.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Reminders.dart';
import 'Habitants.dart';
import 'Dashboard.dart';
import 'Onboard.dart';
import 'package:package_info/package_info.dart';
import 'Themes.dart';
import 'package:firebase_admob/firebase_admob.dart';

Tank myTank;
Inhabitant myInhabitant;
Reminder myReminder;
String myName;
List<CustomTheme> themeData;
bool darktheme = false;
bool quicklook = false;
bool disableparams = false;
bool trackrem = false;

CustomTheme myTheme = themeData.first;

String appName;
String packageName;
String version;
String buildNumber;

void main(){

  Future<void> displayTanks() {
    final future = buildTanks();
    return future.then((message) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      myName = (prefs.get('user_name') ?? null);
      darktheme = (prefs.getBool('darktheme') ?? false);
      //TODO change quicklook to true once complete
      quicklook = (prefs.getBool('quicklook') ?? false);
      disableparams = (prefs.getBool('disableparams') ?? false);
      trackrem = (prefs.getBool('trackrem') ?? false);
      themeData = returnThemes(darktheme);

      var theme = (prefs.getInt('theme') ?? 0);
      myTheme = themeData[theme];

      runApp(PlopApp());

      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      appName = packageInfo.appName;
      packageName = packageInfo.packageName;
      version = packageInfo.version;
      buildNumber = packageInfo.buildNumber;
    });
  }

  displayTanks();
}

class PlopApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {


    return MaterialApp(
      title: 'My Flutter App',
      home: myName==null
          ? Onboard()
            : Home(),
        theme: myTheme.themeData,
    );
  }
}

class Home extends StatefulWidget {


  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;
  final List<Widget> _children = [
    myPages[0].action,
    myPages[1].action,
    myPages[2].action,
    myPages[3].action,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: myPages[0].icon,
            title: new Text(myPages[0].name),
          ),
          BottomNavigationBarItem(
            icon: myPages[1].icon,
            title: new Text(myPages[1].name),
          ),
          BottomNavigationBarItem(
            icon: myPages[2].icon,
            title: new Text(myPages[2].name),
          ),
          BottomNavigationBarItem(
            icon: myPages[3].icon,
            title: new Text(myPages[3].name),
          ),
        ],
      ),
    );

  }
  void onTabTapped(int index) {
    setState(() {
      myTank=null;
      _currentIndex = index;
    });
  }
}


List<Page> myPages = [
  Page (
    name: 'Dashboard',
    description: 'The landing page.',
    icon: Icon(Icons.dashboard),
    action: DashBoard(),
  ),
  Page (
    name: 'My Tanks',
    description: 'The home page of plop, a card list of your tanks.',
    icon: Icon(Icons.video_label),
    action: TankName(),
  ),
  Page (
    name: 'Inhabitants',
    description: 'All of your inhabitants.',
    icon: Icon(Icons.pets),
    action: habitants(),
  ),
  Page (
    name: 'Tasks',
    description: 'All of your reminders.',
    icon: Icon(Icons.done_all),
    action: Reminders(),
  ),
];

Future onSelectNotification(String payload) async {
  if (payload != null) {
    print('notification payload: ' + payload);
    // Get a location using getDatabasesPath
    var databasesPath = await getDatabasesPath();
    String path = databasesPath + '/plop.db';

    // open the database
    Database database = await openDatabase(path, version: 1);
    await database.execute(
        'UPDATE Reminders SET done = true \ WHERE notificationid = ' + payload + '');
    buildTanks();
    database.close();
  }
}

List<Tank> mytanks = [];
List<Inhabitant> myinhabitants = [];
List<Reminder> myreminders = [];
List<Parameter> myparameters = [];


