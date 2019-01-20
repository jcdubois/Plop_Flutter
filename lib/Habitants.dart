import 'package:flutter/material.dart';
import 'main.dart';
import 'tank.dart';
import 'CreateHabitant.dart';
import 'package:sqflite/sqflite.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';


class habitants extends StatefulWidget {
  @override
  habitantsState createState() => new habitantsState();
}

class habitantsState extends State<habitants> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:myinhabitants.length==0
          ? Center(
        child: Text('No Habitants'),
      )
          :myTank==null
          ? habitantsList('All', context)
          : habitantsList(myTank.id, context),
      appBar: GradientAppBar(
        backgroundColorStart: myTheme.appBarStart,
        backgroundColorEnd: myTheme.appBarEnd,
        brightness: Brightness.dark, // or use Brightness.dark
        elevation: 1,
        title: Text('My Inhabitants',),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          myInhabitant = newHabitant();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateHabitant()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget habitantsList(tankName, BuildContext context){

    deleteHabitant(id) async {
      var databasesPath = await getDatabasesPath();
      String path = databasesPath + '/plop.db';

      // open the database
      Database database = await openDatabase(path, version: 1);
      await database.rawDelete('DELETE FROM Inhabitants WHERE id = ' + id);

      var toDelete;
      for (var hab in myinhabitants){
        if (hab.id==id){
          toDelete = hab;
        }
      }
      myinhabitants.remove(toDelete);
    }

    List<Inhabitant> filtered = [];
    filtered.clear();

    if (tankName!='All'){
      for (var inhab in myinhabitants) {
        if (inhab.tank==tankName){
          filtered.add(inhab);
        }
      }
    } else {
      for (var inhab in myinhabitants) {
          filtered.add(inhab);
        }
    }

    return ListView.builder(
        padding: const EdgeInsets.fromLTRB(50, 16, 16, 16),
        itemCount: filtered.length,
        itemBuilder: /*1*/ (context, i) {
          var myTankName;
          for (var tank in mytanks){
            if (filtered[i].tank==tank.id){
              myTankName=tank.name;
            }
          }
          return Center(
            child: Card(
              margin:EdgeInsets.symmetric(vertical:10.0),
              child: InkWell(
              onTap: (){
                myInhabitant = filtered[i];
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateHabitant()),
              );
              },
                onLongPress: (){
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    // return object of type Dialog
                    return AlertDialog(
                      title: new Text("Delete Habitant"),
                      content: new Text("Are you sure you want to delete " +
                          filtered[i].name + "?"),
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
                            deleteHabitant(filtered[i].id).whenComplete(() {
                              Navigator.of(context).pop();
                              setState(() {});
                            });
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Transform(transform: Matrix4.translationValues(-30, -10, 0),
                      child: Container(
                          width: 150.0,
                          height: 150.0,
                          decoration: new BoxDecoration(
                              shape: BoxShape.circle,
                              image: new DecorationImage(
                                  fit: BoxFit.fill,
                                  image: new AssetImage(filtered[i].image),
                              )
                          )),
                      ),

                        Expanded(
                          child:Transform(transform: Matrix4.translationValues(-30, 0, 0),
                            child:ListTile(
                              title: Text(
                                  filtered[i].name,
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 21, foreground: Paint()..shader=myTheme.textGradient)
                              ),
                              subtitle: myTank==null
                                  ? Text('Tank: ' + myTankName + '\n' + 'Species: ' + filtered[i].species)
                                  : Text('Species ' + filtered[i].species + '\n\n' + 'Quantity: ' +  filtered[i].count.toString()),
                            ),
                          ),
                        )
                    ],
                  ),
                ],
              ),
            ),
            ),
          );
        });
  }
}

