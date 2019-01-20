import 'package:flutter/material.dart';
import 'main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'CreateTank.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'tank.dart';

class Onboard extends StatefulWidget {
  @override
  OnboardState createState() => new OnboardState();
}

class OnboardState extends State<Onboard> {
  final nameFieldController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var stateStep = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:PreferredSize(
        preferredSize: Size.fromHeight(150.0), // here the desired height
        child:        GradientAppBar(
          backgroundColorStart: myTheme.appBarStart,
          backgroundColorEnd: myTheme.appBarEnd,
          brightness: Brightness.dark, // or use Brightness.dark
          elevation: 1,

          flexibleSpace: Padding(
              padding: const EdgeInsets.fromLTRB(3, 62, 8, 8),
              child:Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    title: Text(
                      ('Welcome to Plop'),
                      style: TextStyle(color:Colors.white, fontWeight: FontWeight.bold, fontSize: 32),

                    ),
                  ),
                ],
              )
          ),
        ),
      ),
      body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16.0,16.0,16.0,60.0),
          child:_settingslist()
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          if (_formKey.currentState.validate()){
            setState(() {
              stateStep=true;
              setName();
            });
          }
        },
        child: Icon(Icons.done),
      ),
    );

  }

  setName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', nameFieldController.text);
    myName=nameFieldController.text;
  }


  Widget _settingslist() {
    return Center(
        child:Column(
          children: <Widget>[
            Card(
              child:Padding(
                padding: const EdgeInsets.all(8.0),
                child: Form(
                    key: _formKey,
                    child:Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ListTile(
                          subtitle: stateStep == false
                            ? Text("Plop is an app for monitoring and managing Aquariums and Reptile enclosures. \n\n To get started enter your name")
                              : Text("Nice! Now you can get started by Creating a tank!"),
                        ),
                        stateStep == false
                        ? Padding(
                          padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                          child:TextFormField(
                            controller: nameFieldController,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter a your name!';
                              }
                            },
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Your name',
                            ),

                          ),
                        )
                            : Column(
                          children: <Widget>[
                            RaisedButton(
                              child: const Text('Create a Tank',style:TextStyle(color:Colors.white),),
                              color: Colors.cyan,
                              onPressed: () {
                                myTank = newTank();
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>CreateTank()),);
                              },
                            ),
                            FlatButton(
                              child: const Text('Skip'),
                              onPressed: () {
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>Home()),);
                              },
                            ),
                          ],
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
}


