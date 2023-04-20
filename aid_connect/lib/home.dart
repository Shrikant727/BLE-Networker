import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:mobile_number/mobile_number.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:typed_data';

import 'display.dart';
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _passwordController = TextEditingController();
  bool check=false;
  @override
  List user_data=[];
  final String pass='12345';
  bool advertising = false;
  initState(){
    setup();
    super.initState();
  }
  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }
  void _handleSubmitted() async {
    if(_passwordController.text==pass) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('password',pass);
      setState() {
        check = true;
      }
    }
    Navigator.of(context).pop(_passwordController.text);
  }
  Future<void> setup() async {
    await requestPermissions();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.getString('password')==null){
      showdialog();
    }
    if(prefs.getInt('phone')!=null){
      if (kDebugMode) {
        print(prefs.getInt('phone'));
      }
      user_data.add(prefs.getInt('phone'));
    }
    else{
      print('yo');
      await initMobileNumberState();
      user_data.add(prefs.getInt('phone'));
      print(prefs.getInt('phone'));
    }
  }
  Future<void> initMobileNumberState() async {
    if (!await MobileNumber.hasPhonePermission) {
      await MobileNumber.requestPhonePermission;
    }
    try {
      var mobileNumber = (await MobileNumber.mobileNumber)!;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      print('Mobile number: ${mobileNumber}');
      if(check==false) {
        if(mobileNumber!=null) {
          prefs.setInt('phone', int.parse(mobileNumber.substring(4)));
        }
        else{
          prefs.setInt('phone',1111111111);
        }
        if (kDebugMode) {
          print('Mobile number: $mobileNumber');
        }
      }
      else{
        prefs.setInt('phone',1111111111);
      }
    }
    catch (e) {
      debugPrint(e.toString());
    }
  }
  final FlutterBlePeripheral blePeripheral = FlutterBlePeripheral();
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (advertising) CircularProgressIndicator(),
            ElevatedButton(
              onPressed: () {
                List<int> send=[];
                send.add(0);
                int f=0;
                if(user_data.length==0){
                  f=1111111111;
                }
                else{
                  f=user_data[0];
                }
                String t=f.toString();
                int fb=int.parse(t.substring(0,2));
                int sb=int.parse(t.substring(2,4));
                int tb=int.parse(t.substring(4,6));
                int fo=int.parse(t.substring(6,8));
                int fi=int.parse(t.substring(8,10));
                send.add(fb);
                send.add(sb);
                send.add(tb);
                send.add(fo);
                send.add(fi);
                print(send);
                advertise(0,Uint8List.fromList(send));
              },
              child: Text('Send'),
            ),
            ElevatedButton(
                onPressed:()async{
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


  Future<void> advertise(int counter,send) async {
    if(counter<=25){
      final advertiseSettings= AdvertiseSettings(advertiseMode: AdvertiseMode.advertiseModeLowLatency,
          txPowerLevel: AdvertiseTxPower.advertiseTxPowerHigh);
      Uint8List payload = send;
      final AdvertiseData advertiseData = AdvertiseData(
        serviceUuid: 'bf27730d-860a-4e09-889c-2d8b6a9e0fe7',
        manufacturerId: 1234,
        manufacturerData: payload,
      );
      print(payload);
      await blePeripheral.start(advertiseData: advertiseData,advertiseSettings: advertiseSettings);
      setState(() {
        advertising=true;
      });
    }
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

  Future<void> showdialog() async {
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Password'),
          content: TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(hintText: 'Password'),
            onSubmitted: (_) => _handleSubmitted(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => _handleSubmitted(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
StreamSubscription<DiscoveredDevice>? subscription;
final service = FlutterBackgroundService();
stopScan(){
  if(subscription!=null){
    subscription!.cancel();
  }
}
Future<void> initializeService() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var phone=prefs.getInt('phone');
  final flutterReactiveBle = FlutterReactiveBle();
  StreamSubscription<DiscoveredDevice>? subscription=flutterReactiveBle.scanForDevices(withServices: [Uuid.parse('bf27730d-860a-4e09-889c-2d8b6a9e0fe7')], scanMode: ScanMode.lowLatency).listen((device) {
    var data=device.manufacturerData;
    var counter=data[2];
    if(phone!=null){
      if(phone==1111111111){
        Display(data:device.manufacturerData);
      }
    }
    advert(counter+1,data);

  }, onError: (Object error, StackTrace stackTrace) {
    print(error.toString());
  });

}

void advert(int counter, Uint8List data) {
  final FlutterBlePeripheral blePeripheral = FlutterBlePeripheral();
  if(counter<=25){
    final advertiseSettings= AdvertiseSettings(advertiseMode: AdvertiseMode.advertiseModeLowLatency,
        txPowerLevel: AdvertiseTxPower.advertiseTxPowerHigh);
    Uint8List payload = data;
    final AdvertiseData advertiseData = AdvertiseData(
      serviceUuid: 'bf27730d-860a-4e09-889c-2d8b6a9e0fe7',
      manufacturerId: 1234,
      manufacturerData: payload,
    );
    print(payload);
    blePeripheral.start(advertiseData: advertiseData,advertiseSettings: advertiseSettings);
  }
}