import 'package:flutter/material.dart';
import 'RecordParameter.dart';
import 'CreateReminder.dart';
import "main.dart";
import 'tank.dart';
import 'package:sqflite/sqflite.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:charts_flutter/flutter.dart' as charts;

List<String> paramName = [];
String selectedParam;


class Parameters extends StatefulWidget {
  @override
  ParametersState createState() => new ParametersState();
}

class ParametersState extends State<Parameters> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:myparameters.length==0
          ? Center(
        child: Text('No parameter recordings'),
      )
          :parameterList(myTank.id),
      appBar: GradientAppBar(
        backgroundColorStart: myTheme.appBarStart,
        backgroundColorEnd: myTheme.appBarEnd,
        brightness: Brightness.dark, // or use Brightness.dark
        elevation: 1,
        title: Text('Parameters'
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator
              .push(
            context,
            new MaterialPageRoute(builder: (context) => new RecordParameter()),
          );
        },
        child: Icon(Icons.note_add),
      ),
    );
  }

  Widget parameterList(tankName){
    List<List<Parameter>> builtParams = [];
    List<List<Parameter>> sortedParams = [];
    List<Parameter> paramGroup = [];
    bool empty = true;

    paramGroup.add(myparameters.first);
    for (var i = 1; i < myparameters.length; i++) {
      if (myparameters[i].groupid == myparameters[i-1].groupid) {
        paramGroup.add(myparameters[i]);
        if (myparameters[i] == myparameters.last) {
          print('Reached last reminder and adding remindergroup ' + paramGroup.first.groupid.toString());
          builtParams.add(paramGroup);
        }
      } else {
        if (myparameters[i] == myparameters.last) {
          builtParams.add(paramGroup);
          paramGroup=[];
          paramGroup.add(myparameters[i]);
          builtParams.add(paramGroup);
        } else {
          print('Adding remindergroup ' + paramGroup.first.groupid.toString());
          builtParams.add(paramGroup);
          paramGroup = [];
          paramGroup.add(myparameters[i]);
        }
      }
    }

      for(var plist in builtParams){
        print('Testing ' + plist.first.tank.toString() + ' against ' + myTank.id.toString());
        if (plist.first.tank==myTank.id){
          sortedParams.add(plist);
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

    if (sortedParams.length==0){
      return Center(
        child: Text('No previous parameter tests'),
      );
    } else {
      return Column(
        children: <Widget>[
          Card(
            child:Column(
              children: <Widget>[
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
                Padding(
                  padding:EdgeInsets.all(8),
                  child:Container(
                    height:200,
                    child:SimpleLineChart.withSampleData(),
                  ),
                ),
              ],
            )
          ),
          Expanded(
            child:ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                itemCount: sortedParams.length,
                itemBuilder: /*1*/ (context, i) {
                  List<Parameter> sortedRems = sortedParams[i];

                  Parameter firstParam = sortedRems[0];

                  return Center(
                    child: Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ListTile(
                            title: Text(
                                "Recording",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 21, foreground: Paint()..shader=myTheme.textGradient)
                            ),
                            subtitle: Text(sortedParams[i].first.date.day.toString() + '/' + sortedParams[i].first.date.month.toString() + '/' + sortedParams[i].first.date.year.toString()),
                          ),
                          Container(
                            constraints: BoxConstraints(maxHeight: 150),
                            child:ListView.builder(
                                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                                itemCount: sortedParams[i].length,
                                itemBuilder: /*1*/ (context, ii) {
                                  List<Parameter> paramGroup = sortedParams[i];
                                  return Row(
                                    children: <Widget>[
                                      Container(
                                        color:Colors.cyan,
                                        width:5,
                                        height:60,
                                      ),
                                      Expanded(
                                        child:ListTile(
                                          title: Text(paramGroup[ii].type),
                                          subtitle: Text(paramGroup[ii].value.toString()),
                                        ),
                                      ),
                                    ],
                                  );
                                }
                            ),
                          ),

                        ],
                      ),
                    ),
                  );
                }),
          )
        ],
      );
    }
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




