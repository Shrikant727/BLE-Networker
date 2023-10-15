
import 'dart:typed_data';
// import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';
import 'package:bluetooth_low_energy/bluetooth_low_energy.dart';

PeripheralManager get peripheralManager => PeripheralManager.instance;
void advert(Uint8List data) {
  // final FlutterBlePeripheral blePeripheral = FlutterBlePeripheral();
  int counter=data[0];
  if(counter<=25){
    // final advertiseSettings= AdvertiseSettings(advertiseMode: AdvertiseMode.advertiseModeLowLatency,
    //     txPowerLevel: AdvertiseTxPower.advertiseTxPowerHigh);
    Uint8List payload = data;
    payload[0]=counter+1;
    // final AdvertiseData advertiseData = AdvertiseData(
    //   serviceUuid: '7e7ed6da-4d2d-4f07-ba97-04222a651038',
    //   manufacturerId: 1234,
    //   manufacturerData: payload,
    // );
    print(payload);
    // blePeripheral.start(advertiseData: advertiseData,advertiseSettings: advertiseSettings);
    // Future.delayed(Duration(seconds: 2)).then((value) => blePeripheral.stop());
  }
}

List<int> CreatePayload(Map<String,dynamic>userData,int counter,int code,int check){
  List<int> send=[];
  send.add(counter);
  if(check==0){
    send.add(code);
    String t=userData['phone'].toString();
    for(int i=0;i<10;i+=2){
      int f=int.parse(t.substring(i,i+2));
      send.add(f);
    }
  }
  else{
    int latn=0,longn=0;
    if(userData['latitude']<0)latn=1;
    if(userData['longitude']<0)longn=1;
    send.add(latn);
    send.add(longn);
    String f=userData['latitude'].toString();
    int i=0;
    while(f[i]!='.'){
      i++;
    }i++;
    send.add(int.parse(f.substring(0,i-1)));
    int j=i,cnt=0;
    print(f);
    if(f.length-i<6){
      while(f.length-i!=6){
        f+='0';
      }
    }
    while((j-i)<6&&j<f.length){
      send.add(int.parse(f.substring(j,j+2)));
      j+=2;
      cnt++;
    }
    if(cnt!=3){
      while(cnt!=3){
        send.add(0);
        cnt++;
      }
    }
    f=userData['longitude'].toString();
    i=0;
    while(f[i]!='.'){
      i++;
    }i++;
    send.add(int.parse(f.substring(0,i-1)));
    print(f);
    if(f.length-i<6){
      while(f.length-i!=6){
        f+='0';
      }
    }
    j=i;cnt=0;
    while((j-i)<6&&j<f.length){
      send.add(int.parse(f.substring(j,j+2)));
      j+=2;
      cnt++;
    }
    if(cnt!=3){
      while(cnt!=3){
        send.add(0);
        cnt++;
      }
    }
  }
  return send;
}

Future<void> advertise(send) async {
  // final FlutterBlePeripheral bleP = FlutterBlePeripheral();
  // final advertiseSettings= AdvertiseSettings(advertiseMode: AdvertiseMode.advertiseModeLowLatency,
  //     txPowerLevel: AdvertiseTxPower.advertiseTxPowerHigh);
  Uint8List payload = Uint8List.fromList(send);
  final advertiseData = AdvertiseData(
    name: 'flutter',
    manufacturerSpecificData: ManufacturerSpecificData(
      id: 0x2e19,
      data: payload,
    ),
  );
  await peripheralManager.startAdvertising(advertiseData);
  // final AdvertiseData advertiseData = AdvertiseData(
  //   serviceUuid: '7e7ed6da-4d2d-4f07-ba97-04222a651038',
  //   manufacturerId: 1234,
  //   manufacturerData: payload,
  // );
  print(payload);
  // try {
  //   await bleP.start(
  //       advertiseData: advertiseData, advertiseSettings: advertiseSettings);
  // }
  // catch(e){
  //   print('errrrrrrrrrrrror');
  //   print(e);
  // }
  // final BlePeripheral blePeripheral = BlePeripheral();
  // await blePeripheral.initialize();
  // UUID serviceBattery = UUID(value: "0000180F-0000-1000-8000-00805F9B34FB");
  // UUID characteristicBatteryLevel = UUID(value: "00002A19-0000-1000-8000-00805F9B34FB");
  //
  // BleService batteryService = BleService(
  //   uuid: serviceBattery,
  //   primary: true,
  //   characteristics: [
  //     BleCharacteristic(
  //       uuid: characteristicBatteryLevel,
  //       properties: [
  //         CharacteristicProperties.read.index,
  //         CharacteristicProperties.notify.index
  //       ],
  //       value: send,
  //       descriptors: [],
  //       permissions: [
  //         AttributePermissions.readable.index
  //       ],
  //     ),
  //   ],
  // );
  //
  // List<BleService> services = [batteryService];
  // await blePeripheral.addServices(services);
  // blePeripheral.startAdvertising([serviceBattery],send.toString());
}
Future<void> stopAdvertising() async {
  await peripheralManager.stopAdvertising();
}