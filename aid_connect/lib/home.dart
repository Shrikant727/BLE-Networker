import 'dart:typed_data';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  List<String>user_data=[];
  bool advertising = false;
  initState(){
    super.initState();
    // TODO: implement initState
    setup();
  }
  Future<void> setup() async {
    String uid=await generateuuid();
    user_data.add(uid);
    List data=await getinfo();
    for(int i=0;i<data.length;i++){
      user_data.add(data[i]);
    }
    await requestPermissions();
  }
  final _textcontroller = TextEditingController();
  final _phonecontroller = TextEditingController();
  final _namecontroller = TextEditingController();
  final _extracontroller = TextEditingController();
  final FlutterBlePeripheral blePeripheral = FlutterBlePeripheral();
  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _textcontroller.dispose();
    _phonecontroller.dispose();
    _namecontroller.dispose();
    _extracontroller.dispose();
    super.dispose();
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            //show a loading indicator if the app is advertising
            if (advertising) CircularProgressIndicator(),
            textbox(_textcontroller),
          ElevatedButton(
          onPressed: () {
            advertise(_textcontroller.text,0,user_data);
              },
          child: Text('Send'),
    ),
            ElevatedButton(
                onPressed:(){
                  blePeripheral.stop();
                  setState(() {
                    advertising=false;
                  });
                }
                , child: Text('Stop advertising'))
          ],
        ),
      ),
    );
  }


  Future<void> advertise(String data,int counter,user_data) async {
    if(counter<=255){
    final advertiseSettings= AdvertiseSettings(advertiseMode: AdvertiseMode.advertiseModeLowLatency,
        txPowerLevel: AdvertiseTxPower.advertiseTxPowerHigh);
    Uint8List counterList = Uint8List.fromList([counter]);
    final AdvertiseData advertiseData = AdvertiseData(
      serviceUuid: 'bf27730d-860a-4e09-889c-2d8b6a9e0fe7',
      manufacturerId: 1234,
      manufacturerData: counterList,
    );
    await blePeripheral.start(advertiseData: advertiseData,advertiseSettings: advertiseSettings);
    setState(() {
      advertising=true;
    });
  }
}




textbox(TextEditingController _textcontroller){
  return TextField(
    controller: _textcontroller,
    decoration: InputDecoration(
      border: OutlineInputBorder(),
      labelText: 'Enter the data to be sent',
    ),
  );
}



Future<void> requestPermissions() async {
  final Map<Permission, PermissionStatus> statuses = await [
    Permission.bluetooth,
    Permission.bluetoothAdvertise,
    Permission.location,
  ].request();
  for (final status in statuses.keys) {
    if (statuses[status] == PermissionStatus.granted) {
      debugPrint('$status permission granted');
    } else if (statuses[status] == PermissionStatus.denied) {
      debugPrint(
          '$status denied. Show a dialog with a reason and again ask for the permission.'
      );
      requestPermissions();
    } else if (statuses[status] == PermissionStatus.permanentlyDenied) {
      debugPrint(
        '$status permanently denied. Take the user to the settings page.',
      );
      takeUserToSettings();
    }
  }
}
void takeUserToSettings() {
  openAppSettings();
}
Future<String> generateuuid() async {
// Initialize SharedPreferences
  SharedPreferences prefs = await SharedPreferences.getInstance();
  // Check if UUID is already generated
  String? uuid = prefs.getString('uuid');
  if (uuid==null||uuid.isEmpty) {
    var uniqueId = const Uuid().v4();
    prefs.setString('uuid', uniqueId);
    uuid=uniqueId;
    debugPrint(uuid);
  }
  return uuid;
}
Future<List<String?>> getinfo() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? phone = prefs.getString('phone');
  String? name = prefs.getString('name');
  String? extra = prefs.getString('extra');
  if(phone==null||phone.isEmpty){
      List data=await getform();
      prefs.setString('phone', data[0]);
      prefs.setString('name', data[1]);
      prefs.setString('extra', data[2]);
  }
  debugPrint('phone: $phone, name: $name, extra: $extra');
  return [phone,name,extra];
}

//show dialog which uses createform() to get the name and extra info
Future<List> getform()async {
    List<String>data =[];
  showDialog(
    context: context,
    builder: (BuildContext context){
      return AlertDialog(
        title: const Text("Please Enter your Phone, Name and any additional information you would like to share"),
        content: createform(),
        actions: [
          TextButton(
            child: const Text("Submit"),
            onPressed: () {
              data.add(_phonecontroller.text);
              data.add(_namecontroller.text);
              data.add(_extracontroller.text);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    });
  return data;
}
Widget createform(){
  return Form(
    child: Column(
      children: [
        TextFormField(
          controller: _phonecontroller,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Phone Number',
          ),
        ),
        TextFormField(
          controller: _namecontroller,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Name',
          ),
        ),
        TextFormField(
          controller: _extracontroller,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Extra Additional Information'
          ),
        ),
      ],
    ),
  );
}
}