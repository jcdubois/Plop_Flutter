import 'package:flutter/material.dart';
import 'main.dart';

class CustomTheme{
  String name;
  ThemeData themeData;
  Shader textGradient;
  Color appBarStart;
  Color appBarEnd;
  CustomTheme({this.name, this.themeData, this.textGradient, this.appBarEnd, this.appBarStart});
}

returnThemes(dark){
  return [
    CustomTheme(
      name:'Plop',
      themeData: ThemeData(
        // Define the default Brightness and Colors
        brightness: dark ? Brightness.dark : Brightness.light,
        primaryColor: Colors.lightBlue[800],
        accentColor: darktheme ?Colors.cyanAccent : Colors.blue,

        // Define the default Font Family
        //fontFamily: 'QuattrocentoSans',
        // Define the default TextTheme. Use this to specify the default
        // text styling for headlines, titles, bodies of text, and more.
        textTheme: TextTheme(
          headline: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
          title: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
          body1: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
        ),
      ),
      textGradient: LinearGradient(
        colors: dark ?  <Color>[Colors.cyanAccent, Colors.blue] : <Color>[Colors.cyan, Colors.blueAccent],
      ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
      appBarStart: dark ? Colors.cyanAccent : Colors.cyan,
      appBarEnd:Colors.blue,
    ),
    CustomTheme(
      name:'Lawn',
      themeData: ThemeData(
        // Define the default Brightness and Colors
        brightness: dark ? Brightness.dark : Brightness.light,
        primaryColor: Colors.lightGreen,
        accentColor: darktheme ?Colors.greenAccent : Colors.lightGreenAccent,

        //fontFamily: 'QuattrocentoSans',
        textTheme: TextTheme(
          headline: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
          title: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
          body1: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
        ),
      ),
      textGradient: LinearGradient(
        colors: dark ?  <Color>[Colors.greenAccent, Colors.lightGreenAccent] : <Color>[Colors.lightGreen, Colors.lightGreenAccent],
      ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
      appBarStart: dark ? Colors.greenAccent : Colors.lime,
      appBarEnd:Colors.lightGreenAccent,
    ),
    CustomTheme(
      name:'Sunset',
      themeData: ThemeData(
        // Define the default Brightness and Colors
        brightness: dark ? Brightness.dark : Brightness.light,
        primaryColor: Colors.orangeAccent,
        accentColor: darktheme ?Colors.orangeAccent : Colors.orange,

        //fontFamily: 'QuattrocentoSans',
        textTheme: TextTheme(
          headline: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
          title: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
          body1: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
        ),
      ),
      textGradient: LinearGradient(
        colors: dark ?  <Color>[Colors.yellowAccent, Colors.deepOrangeAccent] : <Color>[Colors.orangeAccent, Colors.deepOrangeAccent],
      ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
      appBarStart: dark ? Colors.yellowAccent : Colors.orangeAccent,
      appBarEnd:Colors.deepOrangeAccent,
    ),
  ];
}

