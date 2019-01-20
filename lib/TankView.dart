import 'package:flutter/material.dart';
import 'main.dart';
import 'tank.dart';
import 'Habitants.dart';
import 'Reminders.dart';
import 'Parameters.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:charts_flutter/flutter.dart' as charts;

List<String> paramName = [];
String selectedParam;



class TankView extends StatefulWidget {
  @override
  TankViewState createState() => new TankViewState();
}



class TankViewState extends State<TankView> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    List<Widget> _children;

    if(disableparams){
      _children = [
        SingleChildScrollView(child:home()),
        Reminders(),
        habitants(),
      ];
    } else {
    _children = [
    SingleChildScrollView(child:home()),
    Parameters(),
    Reminders(),
    habitants(),
    ];
    }

    return Scaffold(
      body:_children[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: disableparams==false ? [
          BottomNavigationBarItem(
            icon: new Icon(Icons.bubble_chart),
            title: new Text(myTank.name),
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.table_chart),
            title: new Text('Parameters'),
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.timer),
            title: new Text('Reminders'),
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.pets),
            title: new Text('Inhabitants'),
          ),
        ] : [
          BottomNavigationBarItem(
            icon: new Icon(Icons.bubble_chart),
            title: new Text(myTank.name),
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.timer),
            title: new Text('Reminders'),
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.pets),
            title: new Text('Inhabitants'),
          ),
        ],
      ),

    );

  }

  Widget home(){
    return Stack(
      children: <Widget>[
        mainPage(),
        Container(
          height:100,
          child:AppBar(
            elevation: 1,
            iconTheme: IconThemeData(color: Colors.white),
            title: Text(myTank.name, style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.transparent,
          ),
        ),

      ],
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Widget mainPage(){
    double width = MediaQuery.of(context).size.width;
    int habitantCount = 0;

    for (var hab in myinhabitants){
      if(hab.tank==myTank.id){
        habitantCount += hab.count;
      }
    }

    int remindersCount = 0;

    for (var rem in myreminders){
      if(rem.tank==myTank.id){
        remindersCount++;
      }
    }


    for (var param in myparameters){
      var add = true;
      for (var exist in paramName){
        if (param.type==exist){
          add=false;
        }
      }
      if(add){
        paramName.add(param.type);
      }
    }


    return Container(
          child: Center(
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: myTank.rtnImage(width),
                      ),
                      Container(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            ListTile(
                              title: Text(myTank.name,
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 38, foreground: Paint()..shader=myTheme.textGradient)),
                              subtitle: Text(myTank.type + ' tank'),
                            ),
                            ListTile(
                              title:Text('About ' + myTank.name),
                              subtitle: Text("\n" +myTank.description + "\n\n" + habitantCount.toString() + " Habitant(s) in " + myTank.name + "\n\n" + remindersCount.toString() + ' reminder(s) set in ' + myTank.name + '\n'),
                            ),
                            disableparams==false ? ListTile(
                              title: Text(
                                  "Parameter Summary",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 21, foreground: Paint()..shader=myTheme.textGradient)
                              ),
                            ) : Container(),
                            disableparams==false ?
                            Center(
                              child: new DropdownButton<String>(
                                hint: paramName.length <= 0
                                    ? new Text('No Parameter test history')
                                    :new Text("Select a parameter"),
                                onChanged: (String newValue) {
                                  setState(() {
                                    selectedParam = newValue;
                                  });
                                },
                                value: selectedParam,
                                items: paramName.map((String param) {
                                  return new DropdownMenuItem<String>(
                                    value: param,
                                    child: new Text(
                                      param,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ) : Container(),
                            disableparams==false ?
                            Padding(
                              padding:EdgeInsets.all(18),
                              child:Container(
                                height:200,
                                child:SimpleLineChart.withSampleData(),
                              )
                            ): Container(),
                            ListTile(
                              title: Text(
                                  "Inhabitant Summary",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 21, foreground: Paint()..shader=myTheme.textGradient)
                              ),
                            ),
                            habitantCount==0
                                ? Text('No Habitants')
                            : Container(
                              height:200,
                              child:PieOutsideLabelChart.withSampleData(),
                            ),
                            //
                            ButtonTheme.bar( // make buttons use the appropriate styles for cards
                              child: ButtonBar(
                                children: <Widget>[
                                  FlatButton(
                                    child: const Text('Edit'),
                                    onPressed: () {myTank.edit(context);},
                                  ),
                                  RaisedButton(
                                    child: const Text('Delete',style:TextStyle(color:Colors.white),),
                                    color: Colors.redAccent,
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          // return object of type Dialog
                                          return AlertDialog(
                                            title: new Text("Delete Habitant"),
                                            content: new Text("Are you sure you want to delete " + myTank.name + "?"),
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
                                                  deleteTank();
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
            ),
    );
  }

  deleteTank() async {
    // Get a location using getDatabasesPath
    var databasesPath = await getDatabasesPath();
    String path = databasesPath + '/plop.db';

    // open the database
    Database database = await openDatabase(path, version: 1);

    await database.rawDelete('DELETE FROM tanks WHERE id = ' + myTank.id.toString());

    for (var hab in myinhabitants){
      if (hab.tank==myTank.id){
        await database.rawDelete('DELETE FROM Inhabitants WHERE id = ' + hab.tank.toString());
      }
    }

    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid =
    new AndroidInitializationSettings('drawable/ic_stat_artboard_1');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);

    for (var rem in myreminders){
      if(rem.tank==myTank.id){
        await database.rawDelete('DELETE FROM Reminders WHERE id = ' + rem.tank.toString());
      }
      await flutterLocalNotificationsPlugin.cancel(rem.notificationid);
    }

    // Close the database
    await database.close();
    Future<void> displayTanks() {
      final future = buildTanks();
      return future.then((message) {
        Navigator.pop(context);
      });
    }

    displayTanks();
  }
}


class SimpleLineChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  SimpleLineChart(this.seriesList, {this.animate});

  /// Creates a [LineChart] with sample data and no transition.
  factory SimpleLineChart.withSampleData() {
    return new SimpleLineChart(
      _createSampleData(),
      // Disable animations for image tests.
      animate: true,
    );
  }


  @override
  Widget build(BuildContext context) {
    return new charts.LineChart(seriesList, animate: animate,        // Provide a tickProviderSpec which does NOT require that zero is
        // included.
        primaryMeasureAxis: new charts.NumericAxisSpec(
          tickProviderSpec:
          new charts.BasicNumericTickProviderSpec(zeroBound: false)),
     domainAxis: new charts.NumericAxisSpec(
          tickProviderSpec:
          new charts.BasicNumericTickProviderSpec(zeroBound: false)),

    );
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<ParamResults, int>> _createSampleData() {

    List <ParamResults> data = [];

    int i = 1;
    for(var param in myparameters){
      if(param.type==selectedParam && param.tank==myTank.id){
        data.add(new ParamResults(i, param.value.floor()));
        i++;
      }

    }

    return [
      new charts.Series<ParamResults, int>(
        displayName: 'Temperature',
        id: 'Results',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (ParamResults result, _) => result.test,
        measureFn: (ParamResults result, _) => result.value,
        data: data,
      )
    ];
  }
}

/// Sample linear data type.
class ParamResults {
  final int test;
  final int value;

  ParamResults(this.test, this.value);
}



class PieOutsideLabelChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  PieOutsideLabelChart(this.seriesList, {this.animate});

  /// Creates a [PieChart] with sample data and no transition.
  factory PieOutsideLabelChart.withSampleData() {
    return new PieOutsideLabelChart(
      _createSampleData(),
      // Disable animations for image tests.
      animate: false,
    );
  }


  @override
  Widget build(BuildContext context) {
    return new charts.PieChart(seriesList,
        animate: animate,
        // Add an [ArcLabelDecorator] configured to render labels outside of the
        // arc with a leader line.
        //
        // Text style for inside / outside can be controlled independently by
        // setting [insideLabelStyleSpec] and [outsideLabelStyleSpec].
        //
        // Example configuring different styles for inside/outside:
        //       new charts.ArcLabelDecorator(
        //          insideLabelStyleSpec: new charts.TextStyleSpec(...),
        //          outsideLabelStyleSpec: new charts.TextStyleSpec(...)),
        defaultRenderer: new charts.ArcRendererConfig(arcRendererDecorators: [
          new charts.ArcLabelDecorator(
              labelPosition: charts.ArcLabelPosition.outside)
        ]));
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<HabitantSpecies, int>> _createSampleData() {
    List <HabitantSpecies> data = [];

    for(var hab in myinhabitants){
      if(hab.tank==myTank.id){
        data.add(new HabitantSpecies(hab.count, hab.species));
      }

    }

    return [
      new charts.Series<HabitantSpecies, int>(
        id: 'Sales',
        domainFn: (HabitantSpecies sales, _) => sales.count,
        measureFn: (HabitantSpecies sales, _) => sales.count,
        data: data,
        // Set a label accessor to control the text of the arc label.
        labelAccessorFn: (HabitantSpecies row, _) => '${row.species}: ${row.count}',
      )
    ];
  }
}

/// Sample linear data type.
class HabitantSpecies{
  final int count;
  final String species;

  HabitantSpecies(this.count, this.species);
}