import 'package:flutter/material.dart';
import 'tank.dart';
import 'main.dart';
import 'package:sqflite/sqflite.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';

File _image;

class CreateHabitant extends StatefulWidget {
  @override
  CreateHabitantState createState() => new CreateHabitantState();
}

class CreateHabitantState extends State<CreateHabitant> {
  String selectedTank;
  final nameFieldController = TextEditingController(text:myInhabitant.name);
  final speciesFieldController = TextEditingController(text:myInhabitant.species);
  final descFieldController = TextEditingController(text:myInhabitant.description);
  final qtyFieldController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool multipleInhab = false;

  @override
  Widget build(BuildContext context) {
    if (myTank!=null){
      selectedTank = myTank.id.toString();
    }
    return Scaffold(
      appBar: GradientAppBar(
        backgroundColorStart: myTheme.appBarStart,
        backgroundColorEnd: myTheme.appBarEnd,
        brightness: Brightness.dark, // or use Brightness.dark
        elevation: 1,
        title: Text('Create Habitant',),
      ),
      body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 60.0),
          child: _habitantCreation()
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_formKey.currentState.validate()) {
            if(selectedTank!=null){
              saveHabitant();
            } else {
              Scaffold
                  .of(context)
                  .showSnackBar(SnackBar(content: Text('Please choose a tank type')));
            }
          }

        },
        icon: Icon(Icons.save),
        label: Text("Save Habitant"),
      ),
    );
  }


  Widget _habitantCreation() {

    Future<File> _cropImage(File imageFile) async {
      File croppedFile = await ImageCropper.cropImage(
        sourcePath: imageFile.path,
        ratioX: 1.0,
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
        child: Column(
          children: <Widget>[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ListTile(
                          title: Text(
                              "Your Habitant",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 21, foreground: Paint()..shader=myTheme.textGradient)
                          ),
                        ),
                        TextFormField(
                          controller: nameFieldController,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter a habitant name';
                            } else {
                              if(value.replaceAll(new RegExp(r"\s+\b|\b\s"), "").contains(new RegExp(r'[\W]'))){
                                return('Special characters can not be used.');
                              } else {
                                for (var inhab in myinhabitants){

                                  if (value.toString()==inhab.name){
                                    return 'A habitant with this name already exists! Please choose another name.';
                                  }
                                }
                              }
                            }
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            icon: Icon(Icons.text_format),
                            hintText: 'Enter your habitants name!',
                            labelText: 'Habitant Name *',
                          ),
                        ),
                        Padding(
                            padding: EdgeInsets.fromLTRB(0, 18, 0, 18),
                          child: TextFormField(
                            controller: speciesFieldController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              icon: Icon(Icons.pets),
                              hintText: 'Your habitants species. EG: Betta, Blue Tongue',
                              labelText: 'Habitant Species',
                            ),
                          ),
                        ),
                        MergeSemantics(
                          child: ListTile(
                            title: Text("Multiple Inhabitants / School"),
                            subtitle: Text(
                                "Is there multiple of this inhabitant?"),
                            trailing: CupertinoSwitch(
                              value: multipleInhab,
                              onChanged: (bool value) { setState(() { multipleInhab = value; }); },
                            ),
                            onTap: () { setState(() { multipleInhab = !multipleInhab; }); },
                          ),
                        ),
                        multipleInhab == true
                            ? Padding(
                            padding: EdgeInsets.fromLTRB(0, 0, 0, 18),
                            child:Container(
                              width:150,
                              child:TextFormField(
                                  controller: qtyFieldController,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    icon: Icon(Icons.filter_1),
                                    hintText: 'Quantity',
                                    labelText: 'Quantity',
                                  ),
                                  validator: (value) {
                                    var val = int.tryParse(value);
                                    if (val == null) {
                                      return('Quantity must be a number.');
                                    }
                                  }
                              ),
                            ),
                        )
                            : Text(''),
                        Divider(
                          color: Colors.cyan,
                          height: 5,
                        ),
                        ListTile(
                          title: Text(
                              "Details",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 21, foreground: Paint()..shader=myTheme.textGradient)
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 0, 0, 18),
                          child: Column(
                            children: <Widget>[
                              ListTile(
                                title: Text("Host Tank"),
                                subtitle: Text(
                                    "The tank that your habitant lives in.."),
                              ),
                              Center(
                                child: new DropdownButton<String>(
                                  hint: new Text("Select a tank"),
                                  value: selectedTank,
                                  onChanged: (String newValue) {
                                    setState(() {
                                      selectedTank = newValue;
                                    });
                                  },
                                  items: mytanks.map((dynamic tank) {
                                    return new DropdownMenuItem<String>(
                                      value: tank.id.toString(),
                                      child: new Text(
                                        tank.name,
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextFormField(
                          keyboardType: TextInputType.multiline,
                          maxLines: 5,
                          controller: descFieldController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            icon: Icon(Icons.description),
                            hintText: 'A description of your habitant.',
                            labelText: 'Description',
                          ),
                        ),
                        Divider(
                          color: Colors.cyan,
                          height: 40,
                        ),
                        ListTile(
                          title: Text(
                              "Image",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 21, foreground: Paint()..shader=myTheme.textGradient)
                          ),
                        ),
                        ListTile(
                          title: Text("Habitant Image"),
                          subtitle: Text("A nice photo of the habitant!"),
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
                            ? new Text('')
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

  TextStyle formText = TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.w400,
  );

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

  saveHabitant() async {
    myInhabitant.name = nameFieldController.text;
    myInhabitant.description = descFieldController.text;
    myInhabitant.species = speciesFieldController.text;
    myInhabitant.tank = int.tryParse(selectedTank);

    if(multipleInhab){
      myInhabitant.count = int.tryParse(qtyFieldController.text);
    } else {
      myInhabitant.count = 1;
    }

    // Get a location using getDatabasesPath
    var databasesPath = await getDatabasesPath();
    String path = databasesPath + '/plop.db';

    // open the database
    Database database = await openDatabase(path, version: 1);

    // Get the records
    List<Map> list = await database.rawQuery('SELECT * FROM Inhabitants WHERE id = ' + myInhabitant.id);

    if (list.length>0){
      // Delete a record
      await database.rawDelete('DELETE FROM Inhabitants WHERE id = ' + myInhabitant.id);
      print('deleted record');
    }

    var rpath = await getApplicationDocumentsDirectory();
    var name = myInhabitant.name;
    name = name.replaceAll("'", "");
    var dir = rpath.path + '/' +  name.replaceAll(new RegExp(r"\s+\b|\b\s"), "_") + '.png';

    compressFile(_image, dir);

    // Insert some records in a transaction
    await database.transaction((txn) async {
      int id1 = await txn.rawInsert(
          'INSERT INTO Inhabitants(name, species, description, tank, image, count) VALUES("' + myInhabitant.name + '","'  + myInhabitant.species+ '","' + myInhabitant.description + '","' + myInhabitant.tank.toString() + '","' + dir + '",' + myInhabitant.count.toString() + ')');
      print('inserted1: $id1');
    });
    // Close the database
    await database.close();

    buildTanks();
    Navigator.pop(context);
  }
}