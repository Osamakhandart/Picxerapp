import 'package:fiberchat/firebase_options.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseInitializer {
  late final Future<FirebaseApp> initialization;

  FirebaseInitializer() {
    initialization = _initializeFirebase();
  }
  Future<FirebaseApp> _initializeFirebase() async {
    if (!kDebugMode) {
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.playIntegrity,
        appleProvider: AppleProvider.appAttest,
        // webRecaptchaSiteKey: "6Lf0oYQpAAAAAEYvcfSrxU1lyz9T8ggMB89hYDr2",
      );
    } else {
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.debug,
        appleProvider: AppleProvider.debug,
      );
      print(AppleProvider.debug);
      print(DefaultFirebaseOptions.currentPlatform);
    }
    return Firebase.initializeApp(
      name: 'Pixar',
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}
