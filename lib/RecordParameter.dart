import 'package:flutter/material.dart';
import 'tank.dart';
import 'main.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/cupertino.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

List <ParameterType> tempParamTypes = [];
List <ParameterType> testingTypes = [];

class RecordParameter extends StatefulWidget {


  @override
  //RecordParameterState createState() => new RecordParameterState();
  RecordParameterState createState() {
    tempParamTypes = [];
    testingTypes = [];
    for(var pt in paramTypes){
      tempParamTypes.add(pt);
    }
    return RecordParameterState();
  }
}

class RecordParameterState extends State<RecordParameter> {
  String selectedTank;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {

    print(paramTypes.length.toString());
    _select(ParameterType type) {
      // Causes the app to rebuild with the new _selectedChoice.
      setState(() {
        testingTypes.add(type);
        tempParamTypes.remove(type);
      });
    }

    return Scaffold(
      appBar: GradientAppBar(
        backgroundColorStart: myTheme.appBarStart,
        backgroundColorEnd: myTheme.appBarEnd,
        brightness: Brightness.dark,
        // or use Brightness.dark
        elevation: 1,
        title: Text('Record Parameters',),
        actions: <Widget>[
          // overflow menu
          PopupMenuButton<ParameterType>(
            icon: Icon(Icons.add),
            onSelected: _select,
            itemBuilder: (BuildContext context) {
              return tempParamTypes.map((ParameterType type) {
                return PopupMenuItem<ParameterType>(
                  value: type,
                  child: Text(type.name),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: testingTypes.length==0 ? Center(child:Text('Enter some results using + in the app bar \n\n Save results by using the foating save button at the bottom of your screen.', textAlign: TextAlign.center,)) : _habitantCreation(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_formKey.currentState.validate()) {
            setReminder();
          }
        },
        icon: Icon(Icons.save),
        label: Text("Save Results"),
      ),
    );
  }


  Widget _habitantCreation() {

    return Form(
      key:_formKey,
      child:ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          itemCount: testingTypes.length,
          itemBuilder: /*1*/ (context, i) {
            //ParameterType type = testingTypes[i];
            return Card(
                child: Padding(padding: EdgeInsets.all(8),
                  child:Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Expanded(
                        child:ListTile(
                          title: Text(testingTypes[i].name),
                          subtitle: Text(testingTypes[i].measurement),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding:EdgeInsets.fromLTRB(0, 5, 0, 0),
                          child:TextFormField(
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText:'Value',
                                labelText: 'Recording',
                              ),

                              validator: (value) {
                                var _val = int.tryParse(value);
                                if (_val == null) {
                                  return('Value must not be empty.');
                                }
                                testingTypes[i].val = _val;
                              }

                          ),),
                      ),
                      Container(
                        child:Padding(
                            padding:EdgeInsets.fromLTRB(0, 10, 0, 0),
                            child:IconButton(
                                icon: Icon(Icons.delete, color: Colors.black45,),
                                onPressed: (){
                                  setState(() {
                                    tempParamTypes.add(testingTypes[i]);
                                    testingTypes.remove(testingTypes[i]);
                                  });
                                })
                        ),
                      ),
                    ],
                  ),
                )

            );
          }
      ),
    );
  }


  setReminder() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int group = (prefs.getInt('parameter_group_counter') ?? 0);
    group++;
    // Get a location using getDatabasesPath
    var databasesPath = await getDatabasesPath();
    String path = databasesPath + '/plop.db';
    // open the database
    Database database = await openDatabase(path, version: 1);

    var now = new DateTime.now();

    for(var param in testingTypes){
      // Insert some records in a transaction
      await database.transaction((txn) async {
        int id1 = await txn.rawInsert(
            'INSERT INTO Parameters (groupid, type, value, tank, datetime) VALUES(' + group.toString() +  ',"' + param.name +  '","' + param.val.toString() + '",'  + myTank.id.toString() + ',"' + now.toUtc().toString() + '")');
        print('inserted1: $id1');
      });
    }

    await prefs.setInt('parameter_group_counter', group);

    buildTanks();

    Navigator.pop(context);
  }



}