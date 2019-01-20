import 'package:flutter/material.dart';
import 'CreateTank.dart';
import 'TankView.dart';
import 'main.dart';
import 'package:sqflite/sqflite.dart';


//TODO add to shared preferences
String measurementPreferences = 'Metric';

//List <String> parameterTypes = [' Total Hardness (gH)', 'Carbonate Hardness (kH)', 'pH value (pH)', 'Iron (Fe)', 'Electrical Conductance', 'Temperature', 'Nitrate (N02)', 'Nitrate (N03)', 'Ammonia (NH3)', 'Ammonium (NH4)', 'Phosphate (P04)', 'Chlorine (Cl)', 'Copper (Cu)', 'Oxygen (O2)', 'Carbon Dioxide', 'Silicon Dioxide'];

List <ParameterType> paramTypes = [
  ParameterType(
    name:'Total Hardness (gH)',
    measurement: 'mg/L'
  ),
  ParameterType(
    name:'Temperature',
    measurement: measurementPreferences=='Metric'
      ?'C°'
        :'F°',
  ),
  ParameterType(
    name:'Oxygen(02)',
    measurement: 'Value'
  ),
  ParameterType(
    name:'pH Value (pH)',
    measurement: 'pH'
  ),
  ParameterType(
      name:'Nitrate (NO2)',
      measurement: 'mg/L'
  ),
  ParameterType(
      name:'Nitrate (NO3)',
      measurement: 'mg/L'
  ),
  ParameterType(
      name:'Chlorine (Cl)',
      measurement: 'ppm'
  ),
  ParameterType(
      name:'Phosphate (PO4)',
      measurement: 'mg/L'
  ),
  ParameterType(
      name:'Copper',
      measurement: 'mg/L'
  ),
  ParameterType(
      name:'Carbon Dioxide ()',
      measurement: 'Value'
  ),
];

class Tank {
  int id;
  String name;
  String type;
  String description;
  int size;
  String image;
  int habcount;

  rtnImage(width){
    return Hero(
      tag: this.id.toString() + 'imageHero',
      child: new Image(
        image: new AssetImage(this.image),
        width: width * 1,
          fit: BoxFit.cover
      ),
    );
  }

  void open(BuildContext context){
    myTank = this;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TankView()),
    );
  }
  void edit(BuildContext context){
    myTank = this;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateTank()),
    );
  }
  Tank({this.id, this.name, this.type, this.description, this.size, this.image, this.habcount});
}

class Reminder {
  int id;
  int notificationid;
  int group;
  String type;
  int tank;
  int inhabitant;
  String notes;
  String stringTime;
  String stringDay;
  bool done;
  int interval;
  Reminder({this.id, this.notificationid, this.group, this.type, this.tank, this.inhabitant, this.notes, this.stringDay, this.stringTime, this.done, this.interval});
}

class ParameterType {
  String name;
  String measurement;
  int val;
  int high;
  int low;
  ParameterType({this.name, this.val, this.measurement, this.high, this.low});
}


class Parameter {
  int id;
  int groupid;
  String type;
  int tank;
  String notes;
  double value;
  DateTime date;
  Parameter({this.id, this.groupid, this.type, this.tank, this.notes, this.value, this.date});
}


buildTanks() async {
  mytanks = [];
  myinhabitants = [];
  myreminders = [];
  myparameters = [];

  // Get a location using getDatabasesPath
  var databasesPath = await getDatabasesPath();
  String path = databasesPath + '/plop.db';

  // open the database
  Database database = await openDatabase(path, version: 1,
      onCreate: (Database db, int version) async {
        // When creating the db, create the table
        await db.execute(
            'CREATE TABLE Tanks (id INTEGER PRIMARY KEY, name TEXT, type TEXT, description TEXT, size INT, image TEXT)');
        await db.execute(
            'CREATE TABLE Inhabitants (id INTEGER PRIMARY KEY, name TEXT, species TEXT, description TEXT, tank INTEGER, image TEXT, count INTEGER)');
        await db.execute(
            'CREATE TABLE Reminders (id INTEGER PRIMARY KEY, notificationid INTEGER, tankgroup INTEGER, type TEXT, tank INTEGER, habitant INTEGER, note TEXT, time TEXT, day TEXT, done BOOL, interval INTEGER)');
        await db.execute(
            'CREATE TABLE Parameters (id INTEGER PRIMARY KEY, groupid INTEGER, type TEXT, value DOUBLE, tank INTEGER, datetime TEXT)');
      });



  List<Map> dbtanks = await database.rawQuery('SELECT * FROM Tanks');

  for (var tank in dbtanks) {
    var temp = Tank (
      id:(tank['id']),
      name:tank['name'],
      type:tank['type'],
      description:tank['description'],
      size:tank['size'],
      image:tank['image'],
      habcount:Sqflite.firstIntValue(await database.rawQuery('SELECT COUNT(*) FROM Inhabitants WHERE tank = "' + tank['name'] + '"')),
    );

    mytanks.add(temp);
  }


  List<Map> dbinhabs = await database.rawQuery('SELECT * FROM Inhabitants');

  for (var inhab in dbinhabs) {
    var temp = Inhabitant (
      id:(inhab['id']).toString(),
      name:inhab['name'],
      species:inhab['species'],
      description:inhab['description'],
      tank:inhab['tank'],
      image:inhab['image'],
      count:inhab['count'],
    );
    myinhabitants.add(temp);
  }

  List<Map> dbreminders = await database.rawQuery('SELECT * FROM Reminders');

  parseBool(val){
    if (val==0){
      return false;
    } else {
      return true;
    }
  }

  for (var inhab in dbreminders) {
    print(inhab);
    var temp = Reminder (
      id:(inhab['id']),
      notificationid: inhab['notificationid'],
      group: inhab['tankgroup'],
      type:inhab['type'],
      tank:inhab['tank'],
      inhabitant:inhab['habitant'],
      notes:inhab['note'],
      stringTime:inhab['time'],
      stringDay:inhab['day'].toString(),
      done:parseBool(inhab['done']),
      interval: inhab['interval'] ?? 0,
    );
    myreminders.add(temp);
  }

  List<Map> dbParams = await database.rawQuery('SELECT * FROM Parameters');

  for (var inhab in dbParams) {
    print(inhab);
    var temp = Parameter (
      id:(inhab['id']),
      groupid: inhab['groupid'],
      type:inhab['type'],
      value: inhab['value'],
      tank:inhab['tank'],
      date: DateTime.parse(inhab['datetime']),
    );
    myparameters.add(temp);
  }

  // Close the database
  await database.close();
  return 'done!';
}

newTank(){
  return Tank (
    id:-1,
    name:'',
    type:'Tropical',
    description:'',
    size:0,
    image:'',
  );
}
newHabitant(){
  return Inhabitant (
    id:'-1',
    name:'',
    species:'',
    tank:-1,
    description:'',
    image:'',
    count:1,
  );
}

class Page{
  final String name;
  final Icon icon;
  final String description;
  final Widget action;
  const Page({this.name, this.description, this.icon, this.action});
}

class Inhabitant{
  String id;
  String name;
  String species;
  String description;
  String image;
  int tank;
  int count;
  Inhabitant({this.id, this.name, this.species, this.description, this.image, this.tank, this.count});
}

allHabitants(){
  List<Inhabitant> habs = [];
//  for (var tank in mytanks) {
  //  for (var hab in tank.inhabitants) {
    //  habs.add(hab);
    //}
  //}
  return habs;
}


