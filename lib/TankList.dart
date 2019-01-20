import 'package:flutter/material.dart';
import 'main.dart';
import 'CreateTank.dart';
import 'tank.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';

class TankName extends StatefulWidget {
  @override
  TankNameState createState() => new TankNameState();
}

class TankNameState extends State<TankName> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColorStart: myTheme.appBarStart,
        backgroundColorEnd: myTheme.appBarEnd,
        brightness: Brightness.dark, // or use Brightness.dark
        elevation: 1,
        title: Text('My Tanks',
        ),
      ),
      body: mytanks.length==0
          ? Center(
        child: Text('No Tanks.'),
      )
          :_tanklist(),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            myTank = newTank();
            Navigator
                .push(
              context,
              new MaterialPageRoute(builder: (context) => new CreateTank()),
            )
                .then((value) {
              setState(() {});
            });
          },
        child: Icon(Icons.add),
      ),
    );
  }


  Widget _tanklist() {
    return ListView.builder(
        padding: EdgeInsets.fromLTRB(16.0,16.0,16.0,60.0),
        itemCount: mytanks.length,
        itemBuilder: /*1*/ (context, i) {
          return _buildRow(mytanks[i]);
        });
  }

  Widget _buildRow(Tank tank) {
    double width = MediaQuery.of(context).size.width;

    return Center(
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: InkWell(
        onTap: (){
          tank.open(context);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.bubble_chart, color: Colors.cyan,),
              title: Text(tank.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 21,foreground: Paint()..shader=myTheme.textGradient)),
              subtitle: Text(tank.type),
            ),
            Container(
                child: tank.rtnImage(width),
            ),
            ButtonTheme.bar( // make buttons use the appropriate styles for cards
              child: ButtonBar(
                children: <Widget>[
                  FlatButton(
                    child: const Text('Edit'),
                    onPressed: () {tank.edit(context);},
                  ),
                  OutlineButton(
                    child: const Text('Open'),
                    onPressed: () {tank.open(context);},
                    color: Colors.blueAccent,
                  ),
                ],
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}