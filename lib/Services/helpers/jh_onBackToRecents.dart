import 'dart:io';
import 'package:fiberchat/Configs/Dbkeys.dart';
import 'package:fiberchat/Configs/app_constants.dart';
import 'package:fiberchat/Services/Providers/Observer.dart';
import 'package:fiberchat/Services/localization/language_constants.dart';
import 'package:fiberchat/Utils/custom_url_launcher.dart';
import 'package:fiberchat/widgets/MyElevatedButton/MyElevatedButton.dart';
import 'package:flutter/material.dart';
import 'package:optimize_battery/optimize_battery.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

onBackToRecents(context) {
  print("backbutton running");
  SharedPreferences.getInstance().then((prefs) {
    int? noOfBackToRecentTriggers = prefs.getInt('noOfBackToRecentTriggers');
    if (noOfBackToRecentTriggers != null) {
      prefs.setInt('noOfBackToRecentTriggers', noOfBackToRecentTriggers + 1);
    } else {
      prefs.setInt('noOfBackToRecentTriggers', 1);
    }
    if (noOfBackToRecentTriggers == 25 ||
        noOfBackToRecentTriggers == 60 ||
        noOfBackToRecentTriggers == 100) {
      askForAppRating(context);
    }
    if (noOfBackToRecentTriggers == 7 ||
        noOfBackToRecentTriggers == 25 ||
        noOfBackToRecentTriggers == 50) {
      askForBatteryIgnoring(context);
    }
  });
}

void askForAppRating(context) {
  final observer = Provider.of<Observer>(context, listen: false);
  showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          children: <Widget>[
            ListTile(
              contentPadding: EdgeInsets.only(top: 20),
              subtitle: Padding(padding: EdgeInsets.only(top: 10.0)),
              title:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                InkWell(
                    child: Row(children: [
                      Icon(
                        Icons.star,
                        size: 40,
                        color: fiberchatBlack.withOpacity(0.56),
                      ),
                      Icon(
                        Icons.star,
                        size: 40,
                        color: fiberchatBlack.withOpacity(0.56),
                      ),
                      Icon(
                        Icons.star,
                        size: 40,
                        color: fiberchatBlack.withOpacity(0.56),
                      ),
                      Icon(
                        Icons.star,
                        size: 40,
                        color: fiberchatBlack.withOpacity(0.56),
                      )
                    ]),
                    onTap: () {
                      Navigator.of(context).pop();
                      custom_url_launcher('https://picxer.org/#footer');
                    }),
                InkWell(
                    child: Icon(
                      Icons.star,
                      size: 40,
                      color: fiberchatBlack.withOpacity(0.56),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      Platform.isAndroid
                          ? custom_url_launcher(ConnectWithAdminApp == true
                              ? observer.userAppSettingsDoc!
                                  .data()![Dbkeys.newapplinkandroid]
                              : RateAppUrlAndroid)
                          : custom_url_launcher(ConnectWithAdminApp == true
                              ? observer.userAppSettingsDoc!
                                  .data()![Dbkeys.newapplinkios]
                              : RateAppUrlIOS);
                    }),
              ]),
            ),
            Divider(),
            Padding(
                child: Text(
                  getTranslated(context, 'loved'),
                  style: TextStyle(fontSize: 14, color: fiberchatBlack),
                  textAlign: TextAlign.center,
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
            Center(
                child: myElevatedButton(
                    color: fiberchatPRIMARYcolor,
                    child: Text(
                      getTranslated(context, 'rate'),
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Platform.isAndroid
                          ? custom_url_launcher(ConnectWithAdminApp == true
                              ? observer.userAppSettingsDoc!
                                  .data()![Dbkeys.newapplinkandroid]
                              : RateAppUrlAndroid)
                          : custom_url_launcher(ConnectWithAdminApp == true
                              ? observer.userAppSettingsDoc!
                                  .data()![Dbkeys.newapplinkios]
                              : RateAppUrlIOS);
                    }))
          ],
        );
      });
}

void askForBatteryIgnoring(context) {
  OptimizeBattery.isIgnoringBatteryOptimizations().then((onValue) {
    if (onValue) {
      // Igonring Battery Optimization. Therefore do nothing
    } else {
      // App is under battery optimization
      OptimizeBattery.stopOptimizingBatteryUsage();
    }
  });
}
