import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_api_availability/google_api_availability.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../localization/language_constants.dart';

class PermissionService {
  bool locationService = false;
  bool storage = false;
  bool wifi = false;
  bool bluetooth = false;
  bool shown = false;

  // Define a helper function for requesting a single permission
  Future<bool> requestPermission(Permission permission, String permissionName,
      BuildContext context) async {
    //workaround because in skd > 33 storage permission doesn't need to be requested:
    if (permission == Permission.storage && Platform.isAndroid) {
      final plugin = DeviceInfoPlugin();

      final android = await plugin.androidInfo;
      if (android.version.sdkInt >= 33) {
        //with newer apks, storage request is not needed anymore
        permission = Permission.photos;
      }
    }

    var status = await permission.request();
    switch (status) {
      case PermissionStatus.granted:
        return true;
      case PermissionStatus.denied:
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            duration: const Duration(seconds: 8),
            content: Text(
                permissionName + getTranslated(context, 'permission_req'))));
        Timer(Duration(seconds: 6), () => openAppSettings());
        return false;
      case PermissionStatus.permanentlyDenied:
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            duration: const Duration(seconds: 8),
            content: Text(
                permissionName + getTranslated(context, 'permission_req'))));
        Timer(Duration(seconds: 6), () => openAppSettings());
        return false;
      default:
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            duration: const Duration(seconds: 8),
            content: Text(
                permissionName + getTranslated(context, 'permission_req'))));
        Timer(Duration(seconds: 6), () => openAppSettings());
        return false;
    }
  }

  Future<bool> checkAndAskPermissionsForWifiSending(
      BuildContext context) async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    int androidSdkVersion = androidInfo.version.sdkInt;
    var neededPermissions = [];
    if (androidSdkVersion < 29) {
      neededPermissions = ["storage"];
    } else if (androidSdkVersion == 29) {
      neededPermissions = ["storage", "location"];
    } else if (androidSdkVersion == 30) {
      neededPermissions = ["location"];
    } else if (androidSdkVersion >= 31 && androidSdkVersion <= 32) {
      neededPermissions = ["location", "bluetooth"];
    } else {
      neededPermissions = ["wifi", "location", "bluetooth"];
    }

    //check if all needed permissions are alerady granted:
    bool allPermissionsAlreadyGranted = true;
    for (var permission in neededPermissions) {
      if (permission == "wifi") {
        if (!await Permission.nearbyWifiDevices.isGranted) {
          allPermissionsAlreadyGranted = false;
        }
      } else if (permission == "storage") {
        if (!await Permission.storage.isGranted) {
          allPermissionsAlreadyGranted = false;
        }
      } else if (permission == "location") {
        if (!await Permission.location.isGranted) {
          allPermissionsAlreadyGranted = false;
        }
      } else if (permission == "bluetooth") {
        if (!await Permission.bluetooth.isGranted) {
          allPermissionsAlreadyGranted = false;
        }
      }
    }
    if (allPermissionsAlreadyGranted) {
      return true;
    }

    //show a pop up to explain why the app needs these permissions:
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            //center the title:
            title: Text(
              getTranslated(context, 'pleaseallowpermissions'),
              textAlign: TextAlign.center,
            ),
            content: Text(
              getTranslated(context, 'pleaseallowpermissionstext'),
              textAlign: TextAlign.center,
            ),
            actions: <Widget>[
              TextButton(
                child: Text(getTranslated(context, 'ok')),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });

    bool permissionsOk = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      shown = prefs.getBool('shown') ?? false;

      // Add logic here if you want to show a dialog or additional information
      // before requesting permissions.

      // Request all permissions
      if (neededPermissions.contains("wifi") && permissionsOk == true) {
        permissionsOk = await requestPermission(
            Permission.nearbyWifiDevices, "Wifi", context);
      }
      if (neededPermissions.contains("storage") && permissionsOk == true) {
        permissionsOk =
            await requestPermission(Permission.storage, "Storage", context);
      }
      if (neededPermissions.contains("location") && permissionsOk == true) {
        permissionsOk = await requestPermission(
            Permission.location, "Location Service", context);
      }
      if (neededPermissions.contains("bluetooth") && permissionsOk == true) {
        permissionsOk = await _checkBluetoothPermissions(context);
      }

      // Update shared preferences if needed
      // await prefs.setBool('shown', true);
    } catch (e) {
      permissionsOk = false;
      debugPrint('Error in checkAndAskPermissions: $e');
    }
    return permissionsOk;
  }

  Future<bool> _checkBluetoothPermissions(BuildContext context) async {
    List<Permission> bluetoothPermissions = [
      Permission.bluetooth,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.bluetoothScan
    ];

    for (var permission in bluetoothPermissions) {
      if (!await requestPermission(
          permission, permission.toString(), context)) {
        return false;
      }
    }
    return true;
  }

  Future<void> checkBluetoothPermissions(context) async {
    List<Permission> bluetoothPermissions = [
      Permission.bluetooth,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.bluetoothScan
    ];

    List<PermissionStatus> statuses =
        await Future.wait(bluetoothPermissions.map((p) => p.status));

    if (statuses.any((status) => status == PermissionStatus.denied)) {
      List<PermissionStatus> requestResults =
          await Future.wait(bluetoothPermissions.map((p) => p.request()));
      if (requestResults
          .every((result) => result == PermissionStatus.granted)) {
        bluetooth = true;
      } else {
        showSnackbarError('Bluetooth denied', context: context);
      }
    } else {
      bluetooth = true;
    }
  }

  Future<void> checkWifiPermission(context) async {
    PermissionStatus status = await Permission.nearbyWifiDevices.status;

    if (status.isDenied) {
      showSnackbarError('WiFi denied', context: context);
      if (!(await Permission.nearbyWifiDevices.request().isGranted)) {
        wifi = true;
      }
    } else {
      wifi = true;
    }
  }

  Future<bool> checkGooglePlayServices() async {
    GooglePlayServicesAvailability availability = await GoogleApiAvailability
        .instance
        .checkGooglePlayServicesAvailability();

    if (availability == GooglePlayServicesAvailability.success) {
      print(
          'Google Play Services available: ${GooglePlayServicesAvailability.success}');
      return true;
    } else if (availability ==
        GooglePlayServicesAvailability.serviceVersionUpdateRequired) {
      return true;
    } else {
      return false;
    }
  }

  // getDeviceInfo() async {
  //   AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  //   userName = androidInfo.model;
  // }

  void showSnackbarError(String message, {required BuildContext context}) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> determinePosition(context) async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        showSnackbarError('Location service is disabled.', context: context);
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          showSnackbarError('Location Permission Denied', context: context);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        showSnackbarError('Location denied forever', context: context);
        return;
      }

      locationService = true;
      await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
    } catch (e) {
      showSnackbarError('Location Permission Denied Error', context: context);
    }
  }
}
