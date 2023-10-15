import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile_number/mobile_number.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'display.dart';
import 'constants.dart' as constants;
import 'package:geolocator/geolocator.dart';
import 'permissions.dart';
import 'advertise.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:bluetooth_low_energy/bluetooth_low_energy.dart';
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _passwordController = TextEditingController();
  bool check = false;
  Map<String, dynamic>userData = {
    'phone': 2222222222,
    'latitude': 0.0,
    'longitude': 0.0
  };
  final String pass = constants.password;
  bool advertising = false;
  Map<String, dynamic>sender_data = {
    'phone': 2222222222,
    'latitude': 0.0,
    'longitude': 0.0
  };
  int filler = 0;

  initState() {
    setup();
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.red));
    super.initState();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSubmitted() async {
    if (_passwordController.text.trim() == pass) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('password', pass);
    }
    Navigator.of(context).pop(_passwordController.text);
  }

  Future<void> setup() async {
    int phone = 2222222222;
    double latitude = 0.0;
    double longitude = 0.0;
    await requestPermissions();
    if (!await MobileNumber.hasPhonePermission) {
      await MobileNumber.requestPhonePermission;
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('password') == null||prefs.getString('password')=='xxxx') {
      prefs.setString('password', 'xxxx');
      await showdialog();
    }
    print('thereeeeeeeeeeeeeeeeeeeee');
    print(prefs.getDouble('latitude'));
    try {
      if (prefs.getDouble('latitude') == null||prefs.getDouble('latitude')==0.0) {
        prefs.setDouble('latitude', 0.0);
        prefs.setDouble('longitude', 0.0);
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        prefs.setDouble('latitude', position.latitude);
        prefs.setDouble('longitude', position.longitude);
        latitude = position.latitude;
        longitude = position.longitude;
      }
    }
    catch (e) {
      print('Sheeeeeeeeeeeeeeeeeeeeeeeeeeee');
      print(e);
    }
    if (prefs.getInt('phone') == null||prefs.getInt('phone')==2222222222) {
      try {
        prefs.setInt('phone', 2222222222);
        var mobileNumber = (await MobileNumber.mobileNumber)!;
        prefs.setInt('phone', int.parse(mobileNumber.substring(4)));
        phone = int.parse(mobileNumber.substring(4));
      }
      catch (e) {
        print(e);
      }
    }
    userData['phone'] = prefs.getInt('phone');
    userData['latitude'] = prefs.getDouble('latitude');
    userData['longitude'] = prefs.getDouble('longitude');
    print('kittttttttttttttttttttttttttttttta');
    print(userData);
    await initializeService(context);
  }

  // final FlutterBlePeripheral blePeripheral = FlutterBlePeripheral();

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(widget.title)),
        backgroundColor: Colors.red,
      ),
      body: Center(

        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

            if (advertising)const SpinKitWave(
              color: Colors.white,
              size: 50.0,
            ),
            GestureDetector(
              onTap: () {
                // List<int> send = CreatePayload(userData, 0, 0, 0);
                // advertise(blePeripheral, Uint8List.fromList(send));
                // setState(() {
                //   advertising = true;
                // });
                // print('khooooooooooookho');
                // print(send);
                // print(Uint8List.fromList(send));
                _showEmergencyOptions(context);

              },
              child: Image.asset('assets/images/emergen_buz.png'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () async {
                // if (await blePeripheral.isAdvertising) {
                //   print("still advertsiiiiiiiiiiiiiiiiiiiiiiiiiiings");
                //   blePeripheral.stop();
                // }
                await stopAdvertising();
                setState(() {
                  advertising = false;
                });
              }
              , child: Text('Stop Signal'),

            ),

          ],
        ),
      ),
    );
  }


  void _showEmergencyOptions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.local_hospital),
                title: Text('Medical'),
                onTap: () async {
                  // sendMessage('Medical');
                  List<int>send = CreatePayload(userData, 0, 1, 0);
                  await advertise(Uint8List.fromList(send));
                  send=CreatePayload(userData, 0, 1, 1);
                  await advertise(Uint8List.fromList(send));
                  setState(() {
                    advertising = true;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.security),
                title: Text('Police'),
                onTap: () {
                  //sendMessage('Police');
                  List<int>send = CreatePayload(userData, 0, 2, 0);
                  advertise( Uint8List.fromList(send));
                  send=CreatePayload(userData, 0, 1, 1);
                  advertise( Uint8List.fromList(send));
                  setState(() {
                    advertising = true;
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }


  Future<void> showdialog() async {
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('If Event Coordinator, Enter Password'),
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

  // StreamSubscription<DiscoveredDevice>? subscription;
  //
  // stopScan() {
  //   if (subscription != null) {
  //     subscription!.cancel();
  //   }
  // }
  //
  // @pragma('vm:entry-point')
  // static void onStart(ServiceInstance service) async {
  //   int filler=0;
  //   Map<String, dynamic>sender_data = {
  //     'phone': 2222222222,
  //     'latitude': 0.0,
  //     'longitude': 0.0
  //   };
  //   DartPluginRegistrant.ensureInitialized();
  //   SharedPreferences preferences = await SharedPreferences.getInstance();
  //   await preferences.setString("hello", "world");
  //   final AwesomeNotifications awesomeNotifications = AwesomeNotifications();
  //
  //   if (service is AndroidServiceInstance) {
  //     service.on('setAsForeground').listen((event) {
  //       service.setAsForegroundService();
  //     });
  //
  //     service.on('setAsBackground').listen((event) {
  //       service.setAsBackgroundService();
  //     });
  //   }
  //
  //   service.on('stopService').listen((event) {
  //     service.stopSelf();
  //   });
  //
  //   //initialize flutter reactive ble
  //   String pass=preferences.getString('password')!;
  //   Timer.periodic(const Duration(seconds:10), (timer) async {
  //     if (service is AndroidServiceInstance) {
  //       if (await service.isForegroundService()) {
  //         await awesomeNotifications.createNotification(
  //           content: NotificationContent(
  //             id: 888,
  //             channelKey: 'my_foreground',
  //             title: 'AidConnect',
  //             body: 'Running in Background',
  //           ),
  //           actionButtons: [
  //             NotificationActionButton(
  //               key: 'stop_action',
  //               label: 'Stop Service',
  //             ),
  //           ],
  //         );
  //       }
  //     }
  //
  //         });
  // }
  //
  //
  // Future<void> initializeService() async {
  //   final service = FlutterBackgroundService();
  //    NotificationChannel channel = NotificationChannel(
  //     importance: NotificationImportance.High,
  //      channelKey: 'my_foreground', channelName: 'MY FOREGROUND SERVICE', channelDescription: 'For AidConnect', // importance must be at low or higher level
  //   );
  //
  //   final AwesomeNotifications awesomeNotifications = AwesomeNotifications();
  //   if (Platform.isIOS || Platform.isAndroid) {
  //     await awesomeNotifications.initialize(
  //       null,
  //       [
  //        channel,
  //       ],
  //       debug: true,
  //     );
  //   }
  //
  //   await service.configure(
  //     androidConfiguration: AndroidConfiguration(
  //       onStart: onStart,
  //       autoStart: true,
  //       isForegroundMode: false,
  //       notificationChannelId: 'my_foreground',
  //       initialNotificationTitle: 'AWESOME SERVICE',
  //       initialNotificationContent: 'Initializing',
  //       foregroundServiceNotificationId: 888,
  //     ),
  //     iosConfiguration: IosConfiguration(
  //       autoStart: true,
  //       onForeground: onStart,
  //     ),
  //   );
  //   awesomeNotifications.actionStream.listen((receivedNotification) async {
  //     if (receivedNotification.channelKey == 'my_foreground' &&
  //         receivedNotification.buttonKeyPressed == 'stop_action') {
  //       FlutterBackgroundService().invoke('stopService');
  //     }
  //   });
  //   final scanner = FlutterReactiveBle();
  //   scanner.scanForDevices(withServices: [],scanMode: ScanMode.lowLatency).listen((device) async {
  //     var data=device.manufacturerData;
  //     print('dataaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  //     print(device);
  //     // var counter=data[0];
  //     // if(pass==constants.password) {
  //     //   var flag = data[1];
  //     //   if (flag == 0) {
  //     //     if (filler == 0) {
  //     //       sender_data['phone'] = getphone(data);
  //     //       sender_data['type']=gettype(data);
  //     //       filler++;
  //     //     }
  //     //   }
  //     //   else {
  //     //     if (filler == 1) {
  //     //       sender_data['latitude'] = getlat(data);
  //     //       sender_data['longitude'] = getlon(data);
  //     //       filler++;
  //     //       Builder(
  //     //         builder: (context) {
  //     //           return Display(data: sender_data,yourLatitude: preferences.getDouble('latitude')!,yourLongitude: preferences.getDouble('longitude')!);
  //     //         },
  //     //       );
  //     //     }
  //     //   }
  //     // }
  //     // advert(data);
  //   });
  //   service.startService();
  // }
  final service = FlutterBackgroundService();
  Future<void> initializeService(context) async {
    print('hiiiiiiiiiiiiiiiii');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final service = FlutterBackgroundService();
    service.startService();
    var pass=prefs.getString('password');
    final flutterReactiveBle = FlutterReactiveBle();

    subscription=flutterReactiveBle.scanForDevices(withServices: [], scanMode: ScanMode.lowLatency).listen((device) async {
      var data=device.manufacturerData;
      print('kdsfdfdddddddddddddddddddd');
      print(device);
      //show a dialog box with device data as soon as it is discovered
      await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('If Event Coordinator, Enter Password'),
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
      print("advertisment staaaaaaaaaaaaaaaaaaaaaaaart");
      advert(data);
      stopScan();
      print("scan stoooooooooooooooooooped");
      Future.delayed(Duration(seconds: 2)).then((value) => initializeService(context));
      print("scan staaaaaaaaaaaaaaaaaaaaaaaart");
    }, onError: (Object error, StackTrace stackTrace) {
      print(error.toString());
    });
    print('service startedddddddddddddddddddddddddd');
    Future.delayed(Duration(minutes: 1)).then((value) => service.invoke('stopService') );
  }
  StreamSubscription<DiscoveredDevice>? subscription;
  stopScan(){
    if(subscription!=null){
      subscription!.cancel();
    }
  }

  // void advertisssse() async {
  //   try {
  //     final advertiseSettings = AdvertiseSettings(
  //         advertiseMode: AdvertiseMode.advertiseModeLowLatency,
  //         txPowerLevel: AdvertiseTxPower.advertiseTxPowerHigh);
  //     Uint8List payload = Uint8List.fromList([1, 2, 3, 4, 5]);
  //     final AdvertiseData advertiseData = AdvertiseData(
  //       serviceDataUuid: '7e7ed6da-4d2d-4f07-ba97-04222a651038',
  //       serviceUuid: '7e7ed6da-4d2d-4f07-ba97-04222a651038',
  //       manufacturerId: 1234,
  //       manufacturerData: payload,
  //     );
  //     print(payload);
  //     await blePeripheral.start(
  //         advertiseData: advertiseData, advertiseSettings: advertiseSettings);
  //     setState(() {
  //       advertising = true;
  //     });
  //   }
  //   catch(e){
  //     print('errrrrrrrrrrrror');
  //     print(e);
  //   }
  // }
  // Future<void> initializeService() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   var phone=prefs.getInt('phone');
  //   final flutterReactiveBle = FlutterReactiveBle();
  //   StreamSubscription<DiscoveredDevice>? subscription=flutterReactiveBle.scanForDevices(withServices: [Uuid.parse('7e7ed6da-4d2d-4f07-ba97-04222a651038')], scanMode: ScanMode.lowLatency).listen((device) {
  //     var data=device.manufacturerData;
  //           print('dataaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  //           print(data);
  //           var counter=data[0];
  //           if(pass==constants.password) {
  //             var flag = data[1];
  //             if (flag == 0) {
  //               if (filler == 0) {
  //                 sender_data['phone'] = getphone(data);
  //                 sender_data['type']=gettype(data);
  //                 filler++;
  //               }
  //             }
  //             else {
  //               if (filler == 1) {
  //                 sender_data['latitude'] = getlat(data);
  //                 sender_data['longitude'] = getlon(data);
  //                 filler++;
  //                 Builder(
  //                   builder: (context) {
  //                     return Display(data: sender_data,yourLatitude: prefs.getDouble('latitude')!,yourLongitude: prefs.getDouble('longitude')!);
  //                   },
  //                 );
  //               }
  //             }
  //           }
  //           advert(data);
  //         });
  //
  // }

}