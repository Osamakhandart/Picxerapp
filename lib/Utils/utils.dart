//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fiberchat/Configs/Dbkeys.dart';
import 'package:fiberchat/Configs/app_constants.dart';
import 'package:fiberchat/Services/Providers/Observer.dart';
import 'package:fiberchat/Services/localization/language_constants.dart';
import 'package:fiberchat/Models/DataModel.dart';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:ntp/ntp.dart';
// import 'package:ntp/ntp.dart';
import 'package:oktoast/oktoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:fiberchat/Configs/Enum.dart';
import 'package:share_plus/share_plus.dart';
class Fiberchat {
  static String? getNickname(Map<String, dynamic> user) =>
      user[Dbkeys.aliasName] ?? user[Dbkeys.nickname];

  static void toast(String message) {
    showToast(message, position: ToastPosition.bottom);
  }

  static void internetLookUp() async {
    try {
      // ignore: body_might_complete_normally_catch_error
      await InternetAddress.lookup('google.com').catchError((e) {
        Fiberchat.toast('No internet connection.');
      });
    } catch (err) {
      Fiberchat.toast('No internet connection.');
    }
  }

  static void invite(BuildContext context) {
    final observer = Provider.of<Observer>(context, listen: false);
    String multilingualtext = Platform.isIOS
        ? '${getTranslated(context, 'letschat')} $Appname, ${getTranslated(context, 'joinme')} - ${observer.iosapplink}'
        : '${getTranslated(context, 'letschat')} $Appname, ${getTranslated(context, 'joinme')} -  ${observer.androidapplink}';
    Share.share(observer.isCustomAppShareLink == true
        ? (Platform.isAndroid
            ? observer.appShareMessageStringAndroid == ''
                ? multilingualtext
                : observer.appShareMessageStringAndroid
            : Platform.isIOS
                ? observer.appShareMessageStringiOS == ''
                    ? multilingualtext
                    : observer.appShareMessageStringiOS
                : multilingualtext)
        : multilingualtext);
  }

  static Widget avatar(Map<String, dynamic>? user,
      {File? image, double radius = 22.5, String? predefinedinitials}) {
    if (image == null) {
      if (user![Dbkeys.aliasAvatar] == null)
        return (user[Dbkeys.photoUrl] ?? '').isNotEmpty
            ? CircleAvatar(
                backgroundColor: Colors.grey[200],
                backgroundImage:
                    CachedNetworkImageProvider(user[Dbkeys.photoUrl]),
                radius: radius)
            : CircleAvatar(
                backgroundColor: fiberchatPRIMARYcolor,
                foregroundColor: Colors.white,
                child: Text(predefinedinitials ??
                    getInitials(Fiberchat.getNickname(user)!)),
                radius: radius,
              );
      return CircleAvatar(
        backgroundImage: Image.file(File(user[Dbkeys.aliasAvatar])).image,
        radius: radius,
      );
    }
    return CircleAvatar(
        backgroundImage: Image.file(image).image, radius: radius);
  }

  static Future<int> getNTPOffset() {
    return NTP.getNtpOffset();
  }

  static Widget getNTPWrappedWidget(Widget child) {
    return FutureBuilder(
        future: NTP.getNtpOffset(),
        builder: (context, AsyncSnapshot<int> snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            if (snapshot.data! > Duration(minutes: 1).inMilliseconds ||
                snapshot.data! < -Duration(minutes: 1).inMilliseconds)
              return Material(
                  color: fiberchatBlack,
                  child: Center(
                      child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30.0),
                          child: Text(
                            getTranslated(context, 'clocktime'),
                            style:
                                TextStyle(color: fiberchatWhite, fontSize: 18),
                          ))));
          }
          return child;
        });
  }
static const String worldTimeApiUrl = 'http://worldtimeapi.org/api/timezone/Etc/UTC';

  /// Fetch the NTP offset by comparing the local time with the server time.
  // static Future<int> getNTPOffset() async {
  //   try {
  //     final response = await http.get(Uri.parse(worldTimeApiUrl));
  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       final serverTime = DateTime.parse(data['utc_datetime']);
  //       final localTime = DateTime.now().toUtc();
  //       final offset = serverTime.difference(localTime).inMilliseconds;
  //       return offset;
  //     } else {
  //       throw Exception('Failed to fetch time from API');
  //     }
  //   } catch (e) {
  //     print('Error fetching NTP offset: $e');
  //     return 0; // Default offset if there's an error
  //   }
  // }

  // /// Wrap a widget and display a warning if the clock time is inaccurate.
  // static Widget getNTPWrappedWidget(Widget child) {
  //   return FutureBuilder(
  //     future: getNTPOffset(),
  //     builder: (context, AsyncSnapshot<int> snapshot) {
  //       if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
  //         final offset = snapshot.data!;
  //         if (offset.abs() > Duration(minutes: 1).inMilliseconds) {
  //           return Material(
  //             color: Colors.black,
  //             child: Center(
  //               child: Padding(
  //                 padding: EdgeInsets.symmetric(horizontal: 30.0),
  //                 child: Text(
  //                           getTranslated(context, 'clocktime'),
  //                           style:
  //                               TextStyle(color: fiberchatWhite, fontSize: 18),
  //                         )
  //               ),
  //             ),
  //           );
  //         }
  //       }
  //       return child;
  //     },
  //   );
  
  static void showRationale(rationale) async {
    Fiberchat.toast(rationale);
    // await Future.delayed(Duration(seconds: 2));
    // Fiberchat.toast(
    //     'If you change your mind, you can grant the permission through App Settings > Permissions');
  }

  static Future<bool> checkAndRequestPermission(Permission permission) {
    Completer<bool> completer = new Completer<bool>();
    permission.request().then((status) {
      if (status != PermissionStatus.granted) {
        permission.request().then((_status) {
          bool granted = _status == PermissionStatus.granted;
          completer.complete(granted);
        });
      } else
        completer.complete(true);
    });
    return completer.future;
  }

  static String getInitials(String name) {
    try {
      List<String> names = name
          .trim()
          .replaceAll(new RegExp(r'[\W]'), '')
          .toUpperCase()
          .split(' ');
      names.retainWhere((s) => s.trim().isNotEmpty);
      if (names.length >= 2)
        return names.elementAt(0)[0] + names.elementAt(1)[0];
      else if (names.elementAt(0).length >= 2)
        return names.elementAt(0).substring(0, 2);
      else
        return names.elementAt(0)[0];
    } catch (e) {
      return '?';
    }
  }

  static String getChatId(String currentUserNo, String peerNo) {
    if ((int.tryParse(currentUserNo) ?? 0) >= (int.tryParse(peerNo) ?? 0)) {
      return '$currentUserNo-$peerNo';
    }
    return '$peerNo-$currentUserNo';
  }

  static AuthenticationType getAuthenticationType(
      bool biometricEnabled, DataModel? model) {
    if (biometricEnabled && model?.currentUser != null) {
      return AuthenticationType
          .values[model!.currentUser![Dbkeys.authenticationType]];
    }
    return AuthenticationType.passcode;
  }

  static ChatStatus getChatStatus(int index) => ChatStatus.values[index];

  static String normalizePhone(String phone) =>
      phone.replaceAll(new RegExp(r"\s+\b|\b\s"), "");

  static String getHashedAnswer(String answer) {
    answer = answer.toLowerCase().replaceAll(new RegExp(r"[^a-z0-9]"), "");
    var bytes = utf8.encode(answer); // data being hashed
    Digest digest = sha1.convert(bytes);
    return digest.toString();
  }

  static String getHashedString(String str) {
    var bytes = utf8.encode(str); // data being hashed
    Digest digest = sha1.convert(bytes);
    return digest.toString();
  }

  static List<List<String>> divideIntoChuncks(List<String> array, int size) {
    List<List<String>> chunks = [];
    int i = 0;
    while (i < array.length) {
      int j = i + size;
      chunks.add(array.sublist(i, j > array.length ? array.length : j));
      i = j;
    }
    return chunks;
  }

  static List<List<List<String>>> divideIntoChuncksGroup(
      List<List<String>> array, int size) {
    List<List<List<String>>> chunks = [];
    int i = 0;
    while (i < array.length) {
      int j = i + size;
      chunks.add(array.sublist(i, j > array.length ? array.length : j));
      i = j;
    }
    return chunks;
  }
}
