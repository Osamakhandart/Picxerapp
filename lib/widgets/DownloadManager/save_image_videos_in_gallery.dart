import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:fiberchat/Configs/app_constants.dart';
import 'package:fiberchat/Services/localization/language_constants.dart';
import 'package:fiberchat/Utils/color_detector.dart';
import 'package:fiberchat/Utils/theme_management.dart';
import 'package:fiberchat/Utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
// import 'package:gallery_saver/gallery_saver.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GalleryDownloader {
  static void saveNetworkVideoInGallery(
      BuildContext context,
      String url,
      bool isFurtherOpenFile,
      String fileName,
      GlobalKey keyloader,
      SharedPreferences prefs) async {
    String path = url + "&ext=.mp4";

    Dialogs.showLoadingDialog(context, keyloader, prefs);
    //change done
    String cleanUrl =
        path.replaceAll(RegExp(r'[^\w\d\-._~:/?#\[\]@!$&\()*+,;=%]+'), '');

    Random random = new Random();
    int randomNumber = random.nextInt(100);
    String imageName = randomNumber.toString();
    final imagePath = '${Directory.systemTemp.path}/${imageName}video..mp4';
    var response = await Dio().download('$cleanUrl', imagePath).catchError((e) {
      Navigator.of(keyloader.currentContext!, rootNavigator: true).pop();
      Fiberchat.toast(getTranslated(context, 'failedtodownload'));
    });
    if (response.statusCode == 200) {
      await Gal.putVideo(imagePath).then((value) {
        Navigator.of(keyloader.currentContext!, rootNavigator: true).pop();

        Fiberchat.toast("$fileName  " + getTranslated(context, "folder"));
      });
    }

    //change done
    // print('saving path $imagePath');
    // await Gal.putVideo('$path').catchError((e) {
    //   print(e);
    // });

    // GallerySaver.saveVideo(path).then((success) async {
    //   if (success == true) {
    //     Navigator.of(keyloader.currentContext!, rootNavigator: true).pop();
    //
    //     Fiberchat.toast("$fileName  " + getTranslated(context, "folder"));
    //   } else {
    //     Navigator.of(keyloader.currentContext!, rootNavigator: true).pop();
    //     Fiberchat.toast(getTranslated(context, 'failedtodownload'));
    //   }
    // }).catchError((err) {
    //   Navigator.of(keyloader.currentContext!, rootNavigator: true).pop();
    //   Fiberchat.toast(err.toString());
    // });
  }

  saveInGallery(content, context) async {
    // Save Image
    ///change Done
    String path = content + "&ext=.jpg".replaceAll(' ', '');

    String cleanUrl =
        path.replaceAll(RegExp(r'[^\w\d\-._~:/?#\[\]@!$&\()*+,;=%]+'), '');

    Random random = new Random();
    int randomNumber = random.nextInt(100);
    String imageName = randomNumber.toString();
    final imagePath = '${Directory.systemTemp.path}/${imageName}image.jpg';
    var response = await Dio().download('$cleanUrl', imagePath);
    if (response.statusCode == 200) {
      await Gal.putImage(imagePath);
      Fiberchat.toast(
          "Image Downloaded Successfully " + getTranslated(context, "folder"));
    } else {}
    //change done
    print('saving path $imagePath');
    // await Gal.putImage('$path').catchError((e) {
    //   print(e);
    // });
    // GallerySaver.saveImage(
    //   path, toDcim: false,
    //   // shortName: true
    // );
  }

  static void saveNetworkImage(
      BuildContext context,
      String url,
      bool isFurtherOpenFile,
      String fileName,
      GlobalKey keyloader,
      SharedPreferences prefs) async {
    // String path =
    //     'https://image.shutterstock.com/image-photo/montreal-canada-july-11-2019-600w-1450023539.jpg';

    String path = url + "&ext=.jpg";
    Dialogs.showLoadingDialog(context, keyloader, prefs);
    //change done
    // GallerySaver.saveImage(path, toDcim: true).then((success) async {
    //   if (success == true) {
    //     Navigator.of(keyloader.currentContext!, rootNavigator: true).pop();
    //     Fiberchat.toast(fileName == ""
    //         ? getTranslated(context, "folder")
    //         : "$fileName  " + getTranslated(context, "folder"));
    //   } else {
    //     Fiberchat.toast(getTranslated(context, 'failedtodownload'));
    //     Navigator.of(keyloader.currentContext!, rootNavigator: true).pop();
    //   }
    // }).catchError((err) {
    //   Navigator.of(keyloader.currentContext!, rootNavigator: true).pop();
    //   Fiberchat.toast(err.toString());
    // });
  }
}

class Dialogs {
  static Future<void> showLoadingDialog(
      BuildContext context, GlobalKey key, SharedPreferences prefs) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new WillPopScope(
              onWillPop: () async => false,
              child: SimpleDialog(
                  key: key,
                  backgroundColor: Thm.isDarktheme(prefs)
                      ? fiberchatDIALOGColorDarkMode
                      : fiberchatDIALOGColorLightMode,
                  children: <Widget>[
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 18,
                              ),
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    fiberchatSECONDARYolor),
                              ),
                              SizedBox(
                                width: 23,
                              ),
                              Text(
                                getTranslated(context, "downloading"),
                                style: TextStyle(
                                  color: pickTextColorBasedOnBgColorAdvanced(
                                      Thm.isDarktheme(prefs)
                                          ? fiberchatDIALOGColorDarkMode
                                          : fiberchatDIALOGColorLightMode),
                                ),
                              )
                            ]),
                      ),
                    )
                  ]));
        });
  }
}
