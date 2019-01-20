import 'package:flutter/material.dart';
import 'main.dart';
import 'tank.dart';
import 'Reminders.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/cupertino.dart';
import 'SettingsView.dart';
import 'package:sqflite/sqflite.dart';
import 'package:firebase_admob/firebase_admob.dart';

List <String> paramName = [];
String selectedParam;
String selectedTankName;

final Map<int, Widget> children = const <int, Widget>{
  0: Padding(padding:EdgeInsets.all(10), child:Text('Habitants')),
  1: Padding(padding:EdgeInsets.all(10), child:Text('Parameters')),
};
int sharedValue = 0;

class DashBoard extends StatefulWidget {
  @override
  DashBoardState createState() => new DashBoardState();
}

class DashBoardState extends State<DashBoard> {

  static const MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    testDevices: <String> ['BE6F240F-913E-4AA1-9D05'],
    keywords: <String>['foo', 'bar'],
    contentUrl: 'http://foo.com/bar.html',
    childDirected: true,
    nonPersonalizedAds: true,
  );

  BannerAd _bannerAd;

  BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: 'ca-app-pub-7518868735661612/1774818152',
      size: AdSize.fullBanner,
      targetingInfo: targetingInfo,
      listener: (MobileAdEvent event) {
        print("BannerAd event $event");
      },
    );
  }

  @override
  void initState() {
    super.initState();
    FirebaseAdMob.instance.initialize(appId: 'ca-app-pub-7518868735661612~2157961536');
    _bannerAd = createBannerAd()..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    _bannerAd
      ..show(
        // Positions the banner ad 60 pixels from the bottom of the screen
        anchorOffset: 50.0,
        // Banner Position
        anchorType: AnchorType.bottom,
      );
    return Scaffold(
      body:Padding(
          padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
        child:_dashboard(),
      ),
        appBar:PreferredSize(
            preferredSize: Size.fromHeight(110.0), // here the desired height
            child:        GradientAppBar(
              backgroundColorStart: myTheme.appBarStart,
              backgroundColorEnd: myTheme.appBarEnd,
              brightness: Brightness.dark, // or use Brightness.dark
              elevation: 1,
              actions: <Widget>[
                IconButton(icon: Icon(Icons.settings), onPressed: (){Navigator
                    .push(
                  context,
                  new MaterialPageRoute(builder: (context) => new Settings()),
                );_bannerAd?.dispose();})
              ],

              flexibleSpace: Padding(
                  padding: const EdgeInsets.fromLTRB(3, 62, 8, 8),
                  child:Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ListTile(
                        title: Text(
                          ("Welcome " + myName),
                          style: TextStyle(color:Colors.white, fontWeight: FontWeight.bold, fontSize: 32),

                        ),
                      ),
                    ],
                  )
              ),
            ),
        ),

    );
  }


  Widget _dashboard() {
    List<Reminder> overdueTasks = [];
    List<Reminder> todaysTasks = [];
    List<Reminder> tomorrowTasks = [];
    List<String> _weekDays = ['Sunday', 'Monday', 'Tuesday', 'Wednsday', 'Thursday', 'Friday', 'Saturday'];
    int today = DateTime.now().weekday+1;
    print(today.toString());

    for (var rem in myreminders){
      //Add to todaysTask if task test for today
      if (int.parse(rem.stringDay)==today){
        todaysTasks.add(rem);
      }

      //Add to upcoming tasks if due in next 2 days
      if(int.parse(rem.stringDay)==today+1 || int.parse(rem.stringDay)==today+2){
        tomorrowTasks.add(rem);
      }

      //Add to upcoming tasks if due in next 2 days and today is 6 or 7
      if(today==7 || today==6){
        if(today==7){
          if(int.parse(rem.stringDay)==1 || int.parse(rem.stringDay)==2){
            tomorrowTasks.add(rem);
          }
        }
        if(today==6){
          if(int.parse(rem.stringDay)==1 || int.parse(rem.stringDay)==7){
            tomorrowTasks.add(rem);
          }
        }
      }

      //Get overdue tasks from past 2 days
      if(int.parse(rem.stringDay)==today-1 || int.parse(rem.stringDay)==today-2){
        overdueTasks.add(rem);
      }

      //Get overdue tasks if weekday is 1 or 2
      if(today==1 || today == 2){
        if(today==1){
          if(int.parse(rem.stringDay)==7 || int.parse(rem.stringDay)==6 && !rem.done){
            overdueTasks.add(rem);
          }
        }
        if(today==2){
          if(int.parse(rem.stringDay)==7 || int.parse(rem.stringDay)==1 && !rem.done){
            overdueTasks.add(rem);
          }
        }
      }
    }

    if(myTank!=null){
      for (var param in myparameters){
        var add = true;
        for (var exist in paramName){
          if (param.type==exist){
            add=false;
          }
        }
        if(add && param.tank==myTank.id){
          paramName.add(param.type);
        }
      }
    }

    completeTask(i, list) async{
      // Get a location using getDatabasesPath
      var databasesPath = await getDatabasesPath();
      String path = databasesPath + '/plop.db';

      // open the database
      Database database = await openDatabase(path, version: 1);
      list[i].done=!list[i].done;
      await database.execute(
          'UPDATE Reminders SET done = ' + list[i].done.toString() + ' \ WHERE notificationid = ' + list[i].notificationid.toString());
      database.close();
      list.removeAt(i);
    }

    return SingleChildScrollView(
        child:Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            quicklook==true ? Padding(
              padding:EdgeInsets.fromLTRB(18, 2, 18, 2),
              child:Card(
                child:Padding(
                    padding: const EdgeInsets.all(8.0),
                    child:Column(
                      children: <Widget>[
                        ListTile(
                          title: Text(
                              "Quick Look",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 21, foreground: Paint()..shader=myTheme.textGradient)
                          ),
                        ),
                        Center(
                          child: new DropdownButton<String>(
                            hint: mytanks.length <= 0
                                ? new Text('No Tanks')
                                :new Text("Select a Tank"),
                            onChanged: (String newValue) {
                              setState(() {
                                selectedTankName = newValue;
                                for(var tank in mytanks){
                                  if(tank.name==newValue){
                                    myTank=tank;
                                  }
                                }
                              });
                            },
                            value: selectedTankName,
                            items: mytanks.map((dynamic tank) {
                              return new DropdownMenuItem<String>(
                                value: tank.name,
                                child: new Text(
                                  tank.name,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        CupertinoSegmentedControl(children: children, onValueChanged: (int newValue) {
                          setState(() {
                            sharedValue = newValue;
                          });
                        },
                          groupValue: sharedValue, borderColor: Colors.blueAccent, pressedColor: Colors.blueAccent, selectedColor: Colors.blueAccent,),
                        myTank!=null
                            ? Container()
                            :Padding(
                          padding:EdgeInsets.all(18),
                          child:Text('No Tank Selected')
                        ),
                        sharedValue==1&&myTank!=null
                            ? Column(children: <Widget>[
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
                              ),
                              ListTile(
                                title: Text(
                                    "Parameter Summary",
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 21, foreground: Paint()..shader=myTheme.textGradient)
                                ),
                              ),
                              Container(
                                height:200,
                                child:SimpleLineChart.withSampleData(),
                              ),
                            ],)
                            :Text(''),
                        sharedValue==0&&myTank!=null
                            ? Column(children: <Widget>[
                          ListTile(
                            title: Text(
                                "Inhabitant Summary",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 21, foreground: Paint()..shader=myTheme.textGradient)
                            ),
                          ),
                          Container(
                            height:200,
                            child:PieOutsideLabelChart.withSampleData(),
                          ),
                        ],)
                            :Text(''),
                      ],
                    )
                ),
              ),
            )
            : Container(),
            overdueTasks.length!=0 && trackrem ? Padding(
              padding:EdgeInsets.fromLTRB(18, 2, 18, 2),
              child:Card(
                child:Padding(
                    padding: const EdgeInsets.all(8.0),
                    child:Column(
                      children: <Widget>[
                        ListTile(
                          title: Text(
                              "Overdue Tasks",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 21, foreground: Paint()..shader=myTheme.textGradient)
                          ),
                        ),
                        Container(
                          constraints: BoxConstraints.tight(Size(500, 150)),
                          child:overdueTasks.length > 0
                              ?
                          ListView.separated(
                              padding: EdgeInsets.all(0),
                              itemCount: overdueTasks.length,
                              separatorBuilder: (context, index) => Divider(
                                color: Colors.black38,
                              ),
                              itemBuilder: /*1*/ (context, i) {
                                String _myHabitant = '';
                                String _myTanks = 'All Tanks';
                                for (var hab in myinhabitants){
                                  if (hab.id==overdueTasks[i].inhabitant.toString()){
                                    _myHabitant = hab.name;
                                  }
                                }

                                if (_myHabitant=='' && overdueTasks[i].type=='Feeding'){
                                  _myHabitant = 'Everyone';
                                }

                                for (var tank in mytanks){
                                  if(tank.id==overdueTasks[i].tank){
                                    _myTanks = tank.name;
                                  }
                                }

                                return Row(
                                  children: <Widget>[
                                    Container(
                                      color: Colors.redAccent,
                                      width:5,
                                      height:70,
                                    ),
                                    Expanded(
                                      child:ListTile(
                                        leading:overdueTasks[i].type=='Feeding'
                                            ?Icon(Icons.local_dining)
                                            :Icon(Icons.room_service),
                                        title: Text(overdueTasks[i].type + ' ' + _myHabitant),
                                        subtitle: Text('Tank: ' + _myTanks + '\n' + 'Time:' + overdueTasks[i].stringTime + '\n' + 'Day: ' + _weekDays[int.parse(overdueTasks[i].stringDay) - 1]),
                                        trailing:  trackrem==true ? Checkbox(value: overdueTasks[i].done, onChanged:(bool){setState(() {
                                          completeTask(i, overdueTasks);
                                        });}) : Container(width:0),
                                      ),
                                    ),
                                  ],
                                );
                              }
                          )
                              : Center(child:Text('No Overdue Tasks.')),
                        ),
                      ],
                    )
                ),
              ),
            ) : Container(),
            Padding(
              padding:EdgeInsets.fromLTRB(18, 2, 18, 2),
              child:Card(
                child:InkWell(
                  onTap: (){setState(() {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Reminders()),
                    );
                  });},
                  child:Padding(
                      padding: const EdgeInsets.all(8.0),
                      child:Column(
                        children: <Widget>[
                          ListTile(
                            title: Text(
                                "Todays Tasks",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 21, foreground: Paint()..shader=myTheme.textGradient)
                            ),
                          ),
                          Container(
                            constraints: BoxConstraints.tight(Size(500, 150)),
                            child:todaysTasks.length > 0

                                ?
                            ListView.separated(
                                padding: EdgeInsets.all(0),
                                itemCount: todaysTasks.length,
                                separatorBuilder: (context, index) => Divider(
                                  color: Colors.black38,
                                ),
                                itemBuilder: /*1*/ (context, i) {
                                  String _myHabitant = '';
                                  String _myTanks = 'All Tanks';
                                  for (var hab in myinhabitants){
                                    if (hab.id==todaysTasks[i].inhabitant.toString()){
                                      _myHabitant = hab.name;
                                    }
                                  }

                                  if (_myHabitant=='' && todaysTasks[i].type=='Feeding'){
                                    _myHabitant = 'Everyone';
                                  }

                                  for (var tank in mytanks){
                                    if(tank.id==todaysTasks[i].tank){
                                      _myTanks = tank.name;
                                    }
                                  }

                                  return Row(
                                    children: <Widget>[
                                      Container(
                                        color:Colors.orangeAccent,
                                        width:5,
                                        height:60,
                                      ),
                                      Expanded(
                                        child:ListTile(
                                          leading:todaysTasks[i].type=='Feeding'
                                              ?Icon(Icons.local_dining)
                                              :Icon(Icons.room_service),
                                          title: Text(todaysTasks[i].type + ' ' + _myHabitant),
                                          subtitle: Text('Tank: ' + _myTanks + '\n' + 'Time: ' + todaysTasks[i].stringTime),
                                          trailing:  trackrem==true ? Checkbox(value: todaysTasks[i].done, onChanged:(bool){setState(() {
                                            todaysTasks[i].done=!todaysTasks[i].done;
                                          });completeTask(i, todaysTasks);}):Container(width:0),
                                        ),
                                      ),
                                    ],
                                  );
                                }
                            )
                                : Center(child:Text('No Tasks Today.')),
                          ),
                        ],
                      )
                  ),
                )
              ),
            ),
            Padding(
              padding:EdgeInsets.fromLTRB(18, 2, 18, 2),
              child:Card(
                child:InkWell(
    onTap: (){setState(() {
    Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => Reminders()),
    );
    });},
                  child:Padding(
                    padding: const EdgeInsets.all(8.0),
                    child:Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ListTile(
                          title: Text(
                              "Upcoming Tasks",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 21,foreground: Paint()..shader=myTheme.textGradient)
                          ),
                        ),
                        Container(
                          constraints: BoxConstraints.tight(Size(500, 150)),
                          child:tomorrowTasks.length > 0
                              ?
                          ListView.separated(
                              padding: EdgeInsets.all(0),
                              itemCount: tomorrowTasks.length,
                              separatorBuilder: (context, index) => Divider(
                                color: Colors.black38,
                              ),
                              itemBuilder: /*1*/ (context, i) {
                                String _myHabitant = '';
                                String _myTanks = 'All Tanks';
                                for (var hab in myinhabitants){
                                  if (hab.id==tomorrowTasks[i].inhabitant.toString()){
                                    _myHabitant = hab.name;
                                  }
                                }

                                if (_myHabitant=='' && tomorrowTasks[i].type=='Feeding'){
                                  _myHabitant = 'Everyone';
                                }

                                for (var tank in mytanks){
                                  if(tank.id==tomorrowTasks[i].tank){
                                    _myTanks = tank.name;
                                  }
                                }


                                return Row(
                                    children: <Widget>[
                                      Container(
                                        color:Colors.greenAccent,
                                        width:5,
                                        height:70,
                                      ),
                                      Expanded(
                                        child:ListTile(
                                          leading: tomorrowTasks[i].type=='Feeding'
                                              ?Icon(Icons.local_dining)
                                              :Icon(Icons.room_service),
                                          title: Text(tomorrowTasks[i].type + ' ' + _myHabitant),
                                          subtitle: Text('Tank: ' + _myTanks + '\n' + 'Time:' + tomorrowTasks[i].stringTime + '\n' + 'Day: ' + _weekDays[int.parse(tomorrowTasks[i].stringDay) - 1]),
                                        ),
                                      ),
                                    ],
                                  );

                              }
                          )
                              : Center(child:Text('No Upcoming Tasks.')),
                        ),
                      ],
                    )
                ),
    ),
              ),
            ),
          ],
        )
    );
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