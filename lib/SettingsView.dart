import 'package:flutter/material.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';
import 'package:plop_manager/Themes.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';

class Settings extends StatefulWidget {
  @override
  SettingsViewState createState() => new SettingsViewState();
}

class SettingsViewState extends State<Settings> {

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: GradientAppBar(
        backgroundColorStart: myTheme.appBarStart,
        backgroundColorEnd: myTheme.appBarEnd,
        brightness: Brightness.dark, // or use Brightness.dark
        elevation: 1,
        title: Text('Settings',),
      ),
      body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 60.0),
          child: _settingslist()
      ),
    );
  }

  Widget _settingslist(){
    final List<String>_productLists = ['com.coreybourke.plop'];

    List<IAPItem> _items = [];

    void getItems () async {
      List<IAPItem> items = await FlutterInappPurchase.getProducts(_productLists);
      for (var item in items) {
        print('${item.toString()}');
        _items.add(item);
      }
    }

    Future<Null> _buyProduct(IAPItem item) async {
      try {
        PurchasedItem purchased= await FlutterInappPurchase.buyProduct(item.productId);
        print('purcuased - ${purchased.toString()}');
      } catch (error) {
        print('$error');
      }
    }

    getItems();

    return Column(
      children: <Widget>[
        ListTile(
          title: Text(
              "General",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 21, foreground: Paint()..shader=myTheme.textGradient)
          ),
          subtitle: Text('General Settings.'),
        ),
        MergeSemantics(
          child: ListTile(
            title: Text("Quick Look"),
            subtitle: Text(
                "Enable the quick look card on the dash board."),
            trailing: CupertinoSwitch(
              value: quicklook,
              onChanged: (bool value) { setState(() { quicklook = value; toggleQL();}); },
            ),
            onTap: () { setState(() { quicklook = !quicklook; toggleQL();});
            },
          ),
        ),
        MergeSemantics(
          child: ListTile(
            title: Text("Track Tasks"),
            subtitle: Text(
                "Require tasks to be marked as done."),
            trailing: CupertinoSwitch(
              value: trackrem,
              onChanged: (bool value) { setState(() { trackrem = value; toggleRem();}); },
            ),
            onTap: () { setState(() { trackrem = !trackrem; toggleRem();});
            },
          ),
        ),
        MergeSemantics(
          child: ListTile(
            title: Text("Disable Parameters"),
            subtitle: Text(
                "Disable parameter pages if not in use."),
            trailing: CupertinoSwitch(
              value: disableparams,
              onChanged: (bool value) { setState(() { disableparams = value; toggleP();}); },
            ),
            onTap: () { setState(() { disableparams = !disableparams; toggleP();});
            },
          ),
        ),
        ListTile(
          title: Text(
              "Appearance",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 21, foreground: Paint()..shader=myTheme.textGradient)
          ),
          subtitle: Text('Get your style on.'),
        ),
        ListTile(
          title: Text("Theme"),
          subtitle: Text('Choose a theme.'),
        ),
        Center(
          child: new DropdownButton<String>(
            hint:Text("Select a Theme"),
            onChanged: (String newValue) {
              setState(() {
                //selectedTankName = newValue;
                for(var theme in themeData){
                  if(theme.name==newValue){
                    myTheme=theme;
                  }
                }
                changeTheme();
              });
            },
            value: myTheme.name,
            items: themeData.map((dynamic theme) {
              return new DropdownMenuItem<String>(
                value: theme.name,
                child: new Text(
                  theme.name,
                ),
              );
            }).toList(),
          ),
        ),
        MergeSemantics(
          child: ListTile(
            title: Text("Dark theme"),
            subtitle: Text(
                "Night night?"),
            trailing: CupertinoSwitch(
              value: darktheme,
              onChanged: (bool value) { setState(() { darktheme = value; toggleTheme();}); },
            ),
            onTap: () { setState(() { darktheme = !darktheme; toggleTheme();}); },
          ),
        ),
        ListTile(
          title: Text(
              "Purchases",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 21, foreground: Paint()..shader=myTheme.textGradient),
          ),
          subtitle: Text('Unlock extra features.'),
        ),
        MergeSemantics(
          child: ListTile(
            title: Text("Disable Ads"),
            subtitle: Text(
                "Permenantly disable ads."),
            trailing: Text('\$1.69'),
            onTap: () { setState(() {_buyProduct(_items.first); }); },
          ),
        ),
        ListTile(
          title: Text(
              "About",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 21, foreground: Paint()..shader=myTheme.textGradient)
          ),
          subtitle: Text('About Plop.' + '\n\n App Name: ' + appName + '\n Package Name: ' + packageName + '\n Version: ' + version + '\n Build: ' + buildNumber),
        ),
      ],
    );
  }

}

toggleTheme() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('darktheme', darktheme);
  themeData = returnThemes(darktheme);
  for(var theme in themeData){
    if(theme.name==myTheme.name){
      myTheme=theme;
    }
  }
  runApp(PlopApp());
}
changeTheme() async {
  var i = 0;
  for(var theme in themeData){
    if(theme.name==myTheme.name){
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setInt('theme', i);
      runApp(PlopApp());
    }
    i++;
  }
}

toggleQL() async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('quicklook', quicklook);
  runApp(PlopApp());
}
toggleP() async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('disableparams', disableparams);
  runApp(PlopApp());
}
toggleRem() async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('trackrem', trackrem);
  runApp(PlopApp());
}

