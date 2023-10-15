import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

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
