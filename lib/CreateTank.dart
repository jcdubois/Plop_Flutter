import 'package:flutter/material.dart';
import 'tank.dart';
import 'main.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:image_cropper/image_cropper.dart';

File _image;


class CreateTank extends StatefulWidget {
  @override
  CreateTankState createState() => new CreateTankState();
}

class CreateTankState extends State<CreateTank> {


  List<String> tankTypes = <String>["Tropical", "Freshwater", "Reptile", "Amphibian"];
  var selectedType = myTank.type;
  final nameFieldController = TextEditingController(text:myTank.name);
  final sizeFieldController = TextEditingController(text:myTank.size.toString());
  final descFieldController = TextEditingController(text:myTank.description);
  final originalTank = myTank;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        backgroundColorStart: myTheme.appBarStart,
        backgroundColorEnd: myTheme.appBarEnd,
        brightness: Brightness.dark, // or use Brightness.dark
        elevation: 1,
        title: Text('My Tanks',),
      ),
      body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16.0,16.0,16.0,60.0),
          child:_settingslist()
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_formKey.currentState.validate()) {
            if(selectedType!=null){
              saveTank();
            } else {
              Scaffold
                  .of(context)
                  .showSnackBar(SnackBar(content: Text('Please choose a tank type')));
            }
          }
        },
        icon: Icon(Icons.save),
        label: Text("Save Tank"),
      ),
    );
  }


  Widget _settingslist() {
    Future<File> _cropImage(File imageFile) async {
      File croppedFile = await ImageCropper.cropImage(
        sourcePath: imageFile.path,
        ratioX: 1.5,
        ratioY: 1.0,
      );
      return croppedFile;
    }

    Future getImage() async {
      var image = await ImagePicker.pickImage(source: ImageSource.gallery);
      image = await _cropImage(image);
      setState(() {
        _image = image;
      });
    }

    Future takeImage() async {
      var image = await ImagePicker.pickImage(source: ImageSource.camera);
      image = await _cropImage(image);
      setState(() {
        _image = image;
      });
    }



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
                title: Text(
                    "Your Tank",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 21, foreground: Paint()..shader=myTheme.textGradient)
                ),
              ),
              TextFormField(
                //initialValue: myTank.name,
                controller: nameFieldController,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter a tank name';
                  } else {
                    if(value.replaceAll(new RegExp(r"\s+\b|\b\s"), "").contains(new RegExp(r'[\W]'))){
                      return('Special characters can not be used.');
                    } else {
                      for (var tank in mytanks){

                        if (value.toString()==tank.name){
                          return 'This tank already exists! Please choose another name.';
                        }
                      }
                    }
                  }
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  icon: Icon(Icons.bubble_chart),
                  hintText: 'Enter a name! Lounge Tank, My tank..',
                  labelText: 'Tank Name *',
                ),
              ),
              Row(
                children: <Widget>[
                  Container(
                    width:150,
                      child:ListTile(
                        title: Text("Tank Type:"),
                      ),
                  ),
                  Container(
                    child:DropdownButton<String>(
                      hint: new Text("Select a user"),
                      value: selectedType,
                      onChanged: (String newValue) {
                        setState(() {
                          selectedType = newValue;
                        });
                      },
                      items: tankTypes.map((String type) {
                        return new DropdownMenuItem<String>(
                          value: type,
                          child: new Text(
                            type,
                          ),
                        );
                      }).toList(),
                    ),
                  ),


                ],
              ),

              Divider(
                color: Colors.cyan,
                height: 40,
              ),
              ListTile(
                title: Text(
                    "Details",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 21, foreground: Paint()..shader=myTheme.textGradient)
                ),
              ),
              TextFormField(
                  controller: sizeFieldController,
                  //initialValue: myTank.size.toString(),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    icon: Icon(Icons.border_style),
                    hintText: 'Your tank size in Litres',
                    labelText: 'Tank Size (Litres) *',
                  ),
                  validator: (value) {
                    var val = int.tryParse(value);
                    if (val == null) {
                      return('Tank size must be a number. If unknown leave at 0');
                    }
                  }
              ),
              Container(height: 10,),
              TextFormField(
                keyboardType: TextInputType.multiline,
                maxLines: 5,
                controller: descFieldController,
                //initialValue: myTank.size.toString(),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  icon: Icon(Icons.description),
                  hintText: 'A description for your tank.',
                  labelText: 'Description',
                ),
              ),
              Divider(
                color: Colors.cyan,
                height: 40,
              ),
              ListTile(
                title: Text(
                    "Cover Image",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 21, foreground: Paint()..shader=myTheme.textGradient)
                ),
              ),
              ListTile(
                title: Text("Tank Image"),
                subtitle: Text("A nice photo of the tank!"),
              ),
              OutlineButton(
                child:Text('Choose Image'),
                  onPressed: getImage,
              ),
              OutlineButton(
                child:Text('Take Photo'),
                onPressed: takeImage,
              ),
              _image == null
                  ? new Text('No image selected.')
                  : new Image.file(_image),
              Container(height: 10,),
            ],
          )
      ),
    ),
    ),
        ],
      )
    );

  }
  bool isNumeric(String s) {
    if(s == null) {
      return false;
    }
    return double.parse(s) != null;
  }
  void set(){
    print("yello");
  }
  TextStyle formText = TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.w400,
  );
  void saveTank(){
    myTank.name = nameFieldController.text;
    myTank.description = descFieldController.text;
    myTank.size = int.tryParse(sizeFieldController.text);
    myTank.type = selectedType;
    dbsave();
  }

  Future<List<int>> compressFile(File file, String dir) async {
    var result = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      minWidth: 900,
      minHeight: 700,
      quality: 60,
      rotate: 0,
    );
    print(file.lengthSync());
    print(result.length);
    //return result;
    writeToFile(result, dir);
  }

  void writeToFile(List<int> list, String filePath) {
    var file = File(filePath);
    file.writeAsBytes(list, flush: true, mode: FileMode.write);
  }

  dbsave() async {
    // Get a location using getDatabasesPath
    var databasesPath = await getDatabasesPath();
    String path = databasesPath + '/plop.db';

    // open the database
    Database database = await openDatabase(path, version: 1);

    // Get the records
    List<Map> list = await database.rawQuery('SELECT * FROM Tanks WHERE id = ' + myTank.id.toString());
      print(myTank.id);
      print(list);
    if (list.length>0){
      // Delete a record
      await database.rawDelete('DELETE FROM Tanks WHERE id = ' + myTank.id.toString());
      print('deleted record');
    }

    var rpath = await getApplicationDocumentsDirectory();
    var name = myTank.name;
    name = name.replaceAll("'", "");
    var dir = rpath.path + '/' +  name.replaceAll(new RegExp(r"\s+\b|\b\s"), "_") + '.png';
    File file = new File(
        dir
    );

    compressFile(_image, dir);

    // Insert some records in a transaction
    await database.transaction((txn) async {
      int id1 = await txn.rawInsert(
          'INSERT INTO Tanks(name, type, description, size, image) VALUES("' + myTank.name + '","'  + myTank.type + '","' + myTank.description + '",' + myTank.size.toString() + ',"' + dir + '")');
      print('inserted1: $id1');
    });



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


