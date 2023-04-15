import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:typed_data';
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  List user_data=[];
  bool advertising = false;
  initState(){
    super.initState();
    // TODO: implement initState
    setup();
  }
  Future<void> setup() async {
    String uid=await generateuuid();
    // user_data.add(255);
    // (utf8.encode(uid!)).forEach((element) {user_data.add(element);});
  await getinfo();
    print(user_data);
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
            FocusScope.of(context).requestFocus(FocusNode());
            advertise(_textcontroller.text,0,user_data);
            _textcontroller.clear();
              },
          child: Text('Send'),
    ),
            ElevatedButton(
                onPressed:()async{
                  print(user_data);
                  if(await blePeripheral.isAdvertising) {
                    blePeripheral.stop();
                  }
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
    print(user_data);
    List<int> send=[];
    send.add(counter);
    send.add(255);
    (user_data).forEach((element) {send.add(element);});
    send.add(255);
    (utf8.encode(data)).forEach((element) {send.add(element);});
    GZipCodec codec = GZipCodec();
    // List<int> compressedData = codec.encode(send);
    // print(compressedData);
    // send=compressedData;
    if(counter<=255){
      int delimiter=255;
    final advertiseSettings= AdvertiseSettings(advertiseMode: AdvertiseMode.advertiseModeLowLatency,
        txPowerLevel: AdvertiseTxPower.advertiseTxPowerHigh);
    Uint8List payload = Uint8List.fromList(send);
    final AdvertiseData advertiseData = AdvertiseData(
      serviceUuid: 'bf27730d-860a-4e09-889c-2d8b6a9e0fe7',
      manufacturerId: 1234,
      manufacturerData: payload,
    );
    print(payload);
    _textcontroller.clear();
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
Future<void> getinfo() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? phone = prefs.getString('phone');
  if(phone==null||phone.isEmpty){
      List data= await getform();
        prefs.setString('phone', data[0]);
        prefs.setString('name', data[1]);
        prefs.setString('extra', data[2]);
  }
  phone = prefs.getString('phone');
  String? name = prefs.getString('name');
  String? extra = prefs.getString('extra');
  debugPrint('phone: $phone, name: $name, extra: $extra');
  user_data.add(255);
  (utf8.encode(phone!)).forEach((element) {user_data.add(element);});
  user_data.add(255);
  // (utf8.encode(name!)).forEach((element) {user_data.add(element);});
  // user_data.add(255);
  // (utf8.encode(extra!)).forEach((element) {user_data.add(element);});
  // user_data.add(255);

}
  Future<List<String>> getform() async {
    List<String> data = [];
    Completer<List<String>> completer = Completer<List<String>>();
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Please Enter your Phone, Name and any additional information you would like to share"),
          content: SingleChildScrollView(
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
                      labelText: 'Extra Additional Information'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Submit"),
              onPressed: () {
                data.add(_phonecontroller.text);
                data.add(_namecontroller.text);
                data.add(_extracontroller.text);
                Navigator.of(context).pop();
                completer.complete(data);
              },
            ),
          ],
        );
      },
    );
    return completer.future;
  }

}