//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'dart:core';
import 'package:google_api_availability/google_api_availability.dart';
import 'package:camera/camera.dart';
import 'package:fiberchat/Configs/Dbkeys.dart';
import 'package:fiberchat/Configs/app_constants.dart';
import 'package:fiberchat/Screens/homepage/homepage.dart';
import 'package:fiberchat/Screens/homepage/initialize.dart';
import 'package:fiberchat/Screens/splash_screen/splash_screen.dart';
import 'package:fiberchat/Services/Providers/BroadcastProvider.dart';
import 'package:fiberchat/Services/Providers/DownloadInfoProvider.dart';
import 'package:fiberchat/Services/Providers/GroupChatProvider.dart';
import 'package:fiberchat/Services/Providers/LazyLoadingChatProvider.dart';
import 'package:fiberchat/Services/Providers/Observer.dart';
import 'package:fiberchat/Services/Providers/SmartContactProviderWithLocalStoreData.dart';
import 'package:fiberchat/Services/Providers/StatusProvider.dart';
import 'package:fiberchat/Services/Providers/TimerProvider.dart';
import 'package:fiberchat/Services/Providers/call_history_provider.dart';
import 'package:fiberchat/Services/Providers/currentchat_peer.dart';
import 'package:fiberchat/Services/Providers/seen_provider.dart';
import 'package:fiberchat/Services/Providers/user_provider.dart';
import 'package:fiberchat/Services/localization/demo_localization.dart';
import 'package:fiberchat/Services/localization/language_constants.dart';
import 'package:fiberchat/Utils/theme_management.dart';
import 'package:fiberchat/firebase_options.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:oktoast/oktoast.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    name: 'Pixar',
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (message.data['title'] == 'Call Ended' ||
      message.data['title'] == 'Missed Call') {
    flutterLocalNotificationsPlugin..cancelAll();
    final data = message.data;
    final titleMultilang = data['titleMultilang'];
    final bodyMultilang = data['bodyMultilang'];

    await showNotificationWithDefaultSound(
        'Missed Call', 'You have Missed a Call', titleMultilang, bodyMultilang);
  } else {
    if (message.data['title'] == 'You have new message(s)' ||
        message.data['title'] == 'New message in Group') {
      //-- need not to do anythig for these message type as it will be automatically popped up.
    } else if (message.data['title'] == 'Incoming Audio Call...' ||
        message.data['title'] == 'Incoming Video Call...') {
      final data = message.data;
      final title = data['title'];
      final body = data['body'];
      final titleMultilang = data['titleMultilang'];
      final bodyMultilang = data['bodyMultilang'];

      await showNotificationWithDefaultSound(
          title, body, titleMultilang, bodyMultilang);
    }
  }

  return Future<void>.value();
}

@pragma(
    'vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
// void callbackDispatcher() {
//   Workmanager().executeTask((task, inputData) {
//     if (task == "uploadTask") {
//       List<String> filePaths = List<String>.from(inputData!['filePaths']);
//       String? currentUserNo = inputData['currentUserNo'];
//       String? chatId = inputData['chatId'];
//       String textimageupload = inputData['textimageupload'];
//       String textimageuploadsuccess = inputData['textimageuploadsuccess'];
//
//       if (filePaths.length > 0) {
//         List<File> files = filePaths.map((path) => File(path)).toList();
//         NotificationService _notificationService = NotificationService();
//
//         uploadEach(files, 0, currentUserNo, chatId, textimageupload,
//             textimageuploadsuccess, _notificationService);
//       }
//     }
//     return Future.value(true);
//   });
// }

List<CameraDescription> cameras = <CameraDescription>[];

void main() async {
  final WidgetsBinding binding = WidgetsFlutterBinding.ensureInitialized();

  binding.renderView.automaticSystemUiAdjustment = false;
  // if (Platform.isAndroid) {
  //   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // }

  if (IsBannerAdShow == true ||
      IsInterstitialAdShow == true ||
      IsVideoAdShow == true) {
    MobileAds.instance.initialize();
  }

  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    logError(e.code, e.description);
  }
  //added by JH
  // Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  // Workmanager().registerOneOffTask("task-identifier", "simpleTask");
  //added by JH until here

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((_) {
    runApp(OverlaySupport(child: FiberchatWrapper()));
  });
}

class FiberchatWrapper extends StatefulWidget {
  const FiberchatWrapper({Key? key}) : super(key: key);
  static void setLocale(BuildContext context, Locale newLocale) {
    _FiberchatWrapperState state =
        context.findAncestorStateOfType<_FiberchatWrapperState>()!;
    state.setLocale(newLocale);
  }

  @override
  _FiberchatWrapperState createState() => _FiberchatWrapperState();
}

class _FiberchatWrapperState extends State<FiberchatWrapper> {
  DarkThemeProvider themeChangeProvider = new DarkThemeProvider();

  void getCurrentAppTheme() async {
    themeChangeProvider.darkTheme =
        await themeChangeProvider.darkThemePreference.getTheme();
    //   await FirebaseAppCheck.instance
    // // Your personal reCaptcha public key goes here:
    // .activate();
  }

  Locale? _locale;
  setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void initState() {
    super.initState();
    getCurrentAppTheme();
  }

  bool check = false;
  final Future<FirebaseApp> _initialization = Firebase.initializeApp(
    name: 'Pixar',
    options: DefaultFirebaseOptions.currentPlatform,
  );

  initializationAppCheck() async {

    if (!kDebugMode) {
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.playIntegrity,
        appleProvider: AppleProvider.appAttest,
        webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
      );
    } else {
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.debug,
        appleProvider: AppleProvider.debug,
      );
    }
  }
Future<void> checkGooglePlayServices() async {
  GooglePlayServicesAvailability availability = 
      await GoogleApiAvailability.instance.checkGooglePlayServicesAvailability();

  if (availability != GooglePlayServicesAvailability.success) {
    print('Google Play Services are not available: $availability');
  }
  else{
    
     print('Google Play Services available: $availability');
  }
  }
  Future<FirebaseApp> checkFirebase() {
    if (Firebase.apps.isEmpty) {
      return Firebase.initializeApp(
        name: 'Pixar',
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } else {
      Firebase.app('Pixar').delete();
      return Firebase.initializeApp(
        name: 'Pixar',
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  }

  @override
  void didChangeDependencies() {
    getLocale().then((locale) {
      setState(() {
        this._locale = locale;
      });
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    ///removed from here
    return FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return MaterialApp(
              builder: (context, child) {
                return MediaQuery(
                  child: child!,
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: const TextScaler.linear(1.0)),
                );
              },
              debugShowCheckedModeBanner: false,
              home: Splashscreen(),
            );
          }
          if (snapshot.connectionState == ConnectionState.done) {
            if (!check) {
              checkGooglePlayServices();
              initializationAppCheck();
              check = true;
            }
            // FirebaseAppCheck.instance
            // // Your personal reCaptcha public key goes here:
            //     .activate( androidProvider: AndroidProvider.debug,
            //   appleProvider: AppleProvider.debug,
            //   webRecaptchaSiteKey: "6Lf0oYQpAAAAAEYvcfSrxU1lyz9T8ggMB89hYDr2",
            // );
            ///jh_ added here
            final FirebaseGroupServices firebaseGroupServices =
                FirebaseGroupServices();
            final FirebaseBroadcastServices firebaseBroadcastServices =
                FirebaseBroadcastServices();
            if (this._locale == null) {
              return MaterialApp(
                builder: (context, child) {
                  return MediaQuery(
                    child: child!,
                    data: MediaQuery.of(context)
                        .copyWith(textScaler: const TextScaler.linear(1.0)),
                  );
                },
                debugShowCheckedModeBanner: false,
                home: Splashscreen(),
              );
            } else {
              ///jh_ till here
              return FutureBuilder(
                  future: SharedPreferences.getInstance(),
                  builder:
                      (context, AsyncSnapshot<SharedPreferences> snapshot) {
                    if (snapshot.hasData) {
                      return MultiProvider(
                        providers: [
                          ChangeNotifierProvider(
                              create: (_) =>
                                  FirestoreDataProviderMESSAGESforBROADCASTCHATPAGE()),
                          //---
                          ChangeNotifierProvider(
                              create: (_) => StatusProvider()),
                          ChangeNotifierProvider(
                              create: (_) => TimerProvider()),
                          ChangeNotifierProvider(
                              create: (_) =>
                                  FirestoreDataProviderMESSAGESforGROUPCHAT()),
                          ChangeNotifierProvider(
                              create: (_) =>
                                  FirestoreDataProviderMESSAGESforLAZYLOADINGCHAT()),
                          ChangeNotifierProvider(
                              create: (_) => DarkThemeProvider()),
                          ChangeNotifierProvider(
                              create: (_) =>
                                  SmartContactProviderWithLocalStoreData()),
                          ChangeNotifierProvider(create: (_) => Observer()),
                          Provider(create: (_) => SeenProvider()),
                          ChangeNotifierProvider(
                              create: (_) => DownloadInfoprovider()),
                          ChangeNotifierProvider(create: (_) => UserProvider()),
                          ChangeNotifierProvider(
                              create: (_) =>
                                  FirestoreDataProviderCALLHISTORY()),
                          ChangeNotifierProvider(
                              create: (_) => CurrentChatPeer()),
                        ],
                        child: StreamProvider<List<BroadcastModel>>(
                          initialData: [],
                          create: (BuildContext context) =>
                              firebaseBroadcastServices.getBroadcastsList(
                                  snapshot.data!.getString(Dbkeys.phone) ?? ''),
                          child: StreamProvider<List<GroupModel>>(
                              initialData: [],
                              create: (BuildContext context) =>
                                  firebaseGroupServices.getGroupsList(
                                      snapshot.data!.getString(Dbkeys.phone) ??
                                          ''),
                              child: Consumer<DarkThemeProvider>(builder:
                                  (BuildContext context, value, child) {
                                return OKToast(

                                    /// set toast style, optional
                                    child: MaterialApp(
                                  theme: Styles.themeData(
                                      themeChangeProvider.darkTheme, context),

                                  builder:
                                      (BuildContext? context, Widget? widget) {
                                    ErrorWidget.builder =
                                        (FlutterErrorDetails errorDetails) {
                                      return MediaQuery(
                                        child: CustomError(
                                            errorDetails: errorDetails),
                                        data: MediaQuery.of(context!).copyWith(
                                            textScaler:
                                                const TextScaler.linear(0.5)),
                                      );
                                    };

                                    return widget!;
                                  },

                                  title: Appname,
                                  debugShowCheckedModeBanner: false,
                                  home: Initialize(
                                    app: K11,
                                    doc: K9,
                                    prefs: snapshot.data!,
                                    id: snapshot.data!.getString(Dbkeys.phone),
                                  ),

                                  // ignore: todo
                                  //TODO:---- All localizations settings----
                                  locale: _locale,
                                  supportedLocales: supportedlocale,
                                  localizationsDelegates: [
                                    DemoLocalization.delegate,
                                    GlobalMaterialLocalizations.delegate,
                                    GlobalWidgetsLocalizations.delegate,
                                    GlobalCupertinoLocalizations.delegate,
                                  ],
                                  localeResolutionCallback:
                                      (locale, supportedLocales) {
                                    for (var supportedLocale
                                        in supportedLocales) {
                                      if (supportedLocale.languageCode ==
                                              locale!.languageCode &&
                                          supportedLocale.countryCode ==
                                              locale.countryCode) {
                                        return supportedLocale;
                                      }
                                    }
                                    return supportedLocales.first;
                                  },
                                  //--- All localizations settings ended here----
                                ));
                              })),
                        ),
                      );
                    }
                    return MultiProvider(
                        providers: [
                          ChangeNotifierProvider(create: (_) => UserProvider()),
                        ],
                        child: MaterialApp(
                          builder: (context, child) {
                            return MediaQuery(
                              child: child!,
                              data: MediaQuery.of(context).copyWith(
                                  textScaler: const TextScaler.linear(1.0)),
                            );
                          },
                          theme: ThemeData(
                              dividerTheme: DividerThemeData(
                                color: themeChangeProvider.darkTheme
                                    ? Colors.black
                                    : Colors.white,
                              ),
                              useMaterial3: false,
                              fontFamily: FONTFAMILY_NAME == ''
                                  ? null
                                  : FONTFAMILY_NAME,
                              primaryColor: fiberchatPRIMARYcolor,
                              primaryColorLight: fiberchatPRIMARYcolor,
                              indicatorColor: fiberchatPRIMARYcolor),
                          debugShowCheckedModeBanner: false,
                          home: Splashscreen(),
                        ));
                  });
            }
          }
          return MaterialApp(
            builder: (context, child) {
              return MediaQuery(
                child: child!,
                data: MediaQuery.of(context)
                    .copyWith(textScaler: const TextScaler.linear(1.0)),
              );
            },
            debugShowCheckedModeBanner: false,
            home: LoaderOverlay(child: Splashscreen()),
          );
        });
  }
}

class CustomError extends StatelessWidget {
  final FlutterErrorDetails errorDetails;

  const CustomError({
    Key? key,
    required this.errorDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0,
      width: 0,
    );
  }
}

void logError(String code, String? message) {
  if (message != null) {
    debugPrint('Error: $code\nError Message: $message');
  } else {
    debugPrint('Error: $code');
  }
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
