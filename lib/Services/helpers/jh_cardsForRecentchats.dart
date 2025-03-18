import 'dart:async';
import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:archive/archive.dart';
import 'package:fiberchat/Configs/Dbkeys.dart';
import 'package:fiberchat/Configs/optional_constants.dart';
import 'package:fiberchat/Services/helpers/jh_MailPopup.dart';
import 'package:fiberchat/Services/helpers/jh_onBackToRecents.dart';
import 'package:fiberchat/Services/helpers/jh_searchProduct.dart';
import 'package:fiberchat/Services/localization/language_constants.dart';
import 'package:fiberchat/Utils/utils.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:oktoast/oktoast.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'jh_wifiPermissions.dart';
import 'jh_wifiTransfer.dart';
import 'widgets/alert_method.dart';

class SendAsLinkOrMail {
  SendAsLinkOrMail({chatContext});
  BuildContext? chatContext;
  bool isActiveSendAsLinkOrMail = false;
  bool wifiAlertOn = false;

  ListView jhCards(BuildContext context, SharedPreferences widgetPrefs) {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(7),
      children: [
        /*This part is only for testing (by JH):*
        InkWell(
          child: Container(child: Text("Test", style: TextStyle(fontSize: 25))),
          onTap: () {
            Locale locale = window.locale;
            String? countryCode = locale.countryCode;
            final snackBar = SnackBar(
                content: Text('countryCode: ${countryCode.toString()}'));
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          },
        ),
        *Only for testing until here */
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  sendAsLinkCard(context, widgetPrefs),
                  const Divider(height: 1),
                  sendAsMailCard(
                    context,
                    widgetPrefs.getString(Dbkeys.nickname) ?? '',
                    widgetPrefs,
                  )
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  searchProductCard(context, widgetPrefs),
                  const Divider(height: 1),
                  !Platform.isIOS
                      ? sendWithWifiCard(context, widgetPrefs, Platform.isIOS)
                      : SizedBox(
                          height:
                              64) //needed because otherwise the other card will show centered rigth
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Card cardForRecentChat(BuildContext context, SharedPreferences widgetPrefs,
      IconData icon, String text, Function() functionOnTap,
      {inactive = false}) {
    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
          //side: BorderSide(color: Color.fromARGB(255, 54, 54, 54), width: 2.0),
        ),
        color: inactive ? Colors.grey.withOpacity(0.3) : Color(0xff5f42ff),
        child: Container(
            height: 56,
            child: Center(
                child: ListTile(
                    minLeadingWidth: 10,
                    leading: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 17,
                      child: Icon(
                        icon,
                        size: 21,
                        color: inactive
                            ? Colors.grey.withOpacity(0.3)
                            : Color(0xff5f42ff),
                      ),
                    ),
                    title: Text(getTranslated(context, text),
                        style: TextStyle(fontSize: 13, color: Colors.white)),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 6.0, vertical: 0.0),
                    onTap: () {
                      if (!inactive) {
                        if (isActiveSendAsLinkOrMail == true) {
                        } else {
                          isActiveSendAsLinkOrMail = true;
                          functionOnTap();

                          isActiveSendAsLinkOrMail = false;
                        }
                      } else {
                        alertMethod(
                            isButtonShow: false,
                            context: context,
                            onClose: (v) {},
                            childrenData: [
                              Text(
                                'This Feature is currently unavailable',
                                style: TextStyle(color: Colors.black54),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.of(context, rootNavigator: true)
                                      .pop();
                                },
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 20),
                                    child: Text(
                                      'ok',
                                      style: TextStyle(color: Colors.blue),
                                    ),
                                  ),
                                ),
                              )
                            ]);
                      }
                    }))));
  }

  Card sendAsLinkCard(BuildContext context, SharedPreferences widgetPrefs) {
    return cardForRecentChat(
        context,
        widgetPrefs,
        Icons.linked_camera_outlined,
        "sendvialink",
        () => SendAsLinkOrMail()
                .chooseAndUploadPhotosToLinkMedia(context)
                .then(((downloadUrl) {
              print("downloadUrl: " + downloadUrl);
              if (downloadUrl != '') {
                Timer(Duration(seconds: 3), () {
                  SendAsLinkOrMail().fotoLinkDialog(context, downloadUrl);
                });
              }
            })));
  }

  Card sendWithWifiCard(
      BuildContext context, SharedPreferences widgetPrefs, bool inAct) {
    return cardForRecentChat(context, widgetPrefs, Icons.wifi, "sendviawifi",
        () {
      if (wifiAlertOn == false) {
        wifiAlertOn = true;
        SendAsLinkOrMail().sendWithWifi(context);
        Future.delayed(Duration(seconds: 3)).then((value) {
          wifiAlertOn = false;
        });
      }
    }, inactive: inAct);
  }

  Widget wifiDialogButton(IconData icon, text, functionOnTap(), context) {
    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
          //side: BorderSide(color: Color.fromARGB(255, 54, 54, 54), width: 2.0),
        ),
        color: Color(0xff5f42ff),
        child: Container(
            height: 56,
            child: Center(
                child: ListTile(
              minLeadingWidth: 10,
              leading: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 17,
                child: Icon(
                  icon,
                  size: 21,
                  color: Color(0xff5f42ff),
                ),
              ),
              title: Text(text,
                  //getTranslated(context, text),
                  style: TextStyle(fontSize: 14.5, color: Colors.white)),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 9.0, vertical: 0.0),
              onTap: () {
                functionOnTap();
              },
            ))));
  }

  WifiDirectService wifiDirectService = WifiDirectService();
  PermissionService permissionService = PermissionService();
  void sendWithWifi(BuildContext context) async {
    // Check availability
    // bool isAvailable = await NfcManager.instance.isAvailable();
    // if (isAvailable) {
    try {
      bool check = await permissionService.checkGooglePlayServices();
      if (check) {
        bool permissionsOk = await permissionService
            .checkAndAskPermissionsForWifiSending(context);
        wifiDirectService.getDeviceInfo();

        print("storage" + '${permissionService.storage}');
        print("wifi" + '${permissionService.wifi}');
        print("location" + '${permissionService.locationService}');
        print("bluetooth" + '${permissionService.bluetooth}');

        if (permissionsOk) {
          context.loaderOverlay.hide();
          alertMethod(
            context: context,
            titleText: getTranslated(context, "sendwithwifi"),
            theme: Colors.black,
            childrenData: [
              SizedBox(
                height: 10,
              ),
              wifiDialogButton(Icons.send, 'Send', () {
                wifiDirectService.sender(context);
                // Navigator.push(
                //     context, MaterialPageRoute(builder: (context) => ViaWifi()));
              }, context),
              wifiDialogButton(Icons.get_app, 'Receive', () {
                // Navigator.push(
                //     context, MaterialPageRoute(builder: (context) => ViaWifxi()));
                wifiDirectService.receiver(context);
              }, context),
            ],
          );
        } else {
          print('permission not granted');
          context.loaderOverlay.hide();
        }
      } else {
        alertMethod(childrenData: [
          SizedBox(
            height: 20,
          ),
          Text(
            'This Feature is not supported in your device',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black),
          )
        ], context: context, onClose: () {});
      }
    } catch (e) {}
    // });
    // }
    // else {
    // alertMethod(childrenData: [
    //   SizedBox(
    //     height: 20,
    //   ),
    //   Text(
    //     'This Feature is not supported in your device',
    //     textAlign: TextAlign.center,
    //     style: TextStyle(color: Colors.black),
    //   )
    // ], context: context, onClose: () {});
  }
  // }

  // void sendWithWifi(BuildContext context) {
  //   // : Show options to wait for other users to chat with via wifi
  //   // This will show options to receive/broadcast network connections
  //   /*showDialog<String>(
  //     context: context,
  //     builder: (context) {
  //       return SendWithWifiHome();
  //     },
  //   );*/
  // }

  Card sendAsMailCard(
      BuildContext context, String nickName, SharedPreferences widgetPrefs) {
    return cardForRecentChat(
        context,
        widgetPrefs,
        Icons.email_outlined,
        "sendviamail",
        () => showDialog<String>(
              context: context,
              builder: (context) {
                return EmailInputDialog();
              },
            ).then((email) {
              if (email != null) {
                print("email: $email");
                SendAsLinkOrMail()
                    .chooseAndUploadPhotosToLinkMedia(context)
                    .then(((downloadUrl) {
                  if (downloadUrl != '') {
                    SendAsLinkOrMail()
                        .sendMail(downloadUrl, email, nickName, context);
                  }
                }));
              }
            }));
  }

  ListView listViewForInvite(
      BuildContext context, SharedPreferences widgetPrefs) {
    return ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(0, 0, 0, 120), //changed
        children: [
          cardForRecentChat(context, widgetPrefs, Icons.person_add, "invite",
              () => Fiberchat.invite(context))
        ]);
  }

  /*ChatGpd: Please write a flutter code for android or iOS. It should provide a function named "chooseAndUploadPhotos" which will use the package image_picker to let the user choose one or multiple photos from his smartphone . If the user has picked one picture, this picture should be compressed with the package flutter_image_compress with the quality "ImageQualityCompress" from my own package fiberchat/Configs/optional_constants.dart and then uploaded as a child of FirebaseStorage.instance.ref("LINK_MEDIA/") and the name being "PicxerAppPhoto"+timestamp. While uploading, there should be a progress bar showing the user the progress of the upload. The function should then return the link to the uploaded photo. If the user chose multiple photos, each of them has to be  compressed with the package flutter_image_compress with the quality "ImageQualityCompress" from my own package fiberchat/Configs/optional_constants.dart, then all of these pictures have to be zipped together in one zip file and this has to be uploaded as a child of FirebaseStorage.instance.ref("LINK_MEDIA/") with the name being "PicxerAppPhotos"+timestamp+.zip. Then the link to this file has to be returned by the function. While uploading the zip file, the user has to be informed about the current progress using SnackBar*/
  Future<String> chooseAndUploadPhotosToLinkMedia(context,
      {bool onlyOnePhoto = false, bool reducedquality = false}) async {
    print("onlyOnePhoto:" + onlyOnePhoto.toString());

    final picker = ImagePicker();
    final List<XFile>? selectedFiles = await picker.pickMultiImage();
    if ((selectedFiles == null) || (selectedFiles.length == 0)) {
      return '';
    }
    if ((onlyOnePhoto == true) & (selectedFiles.length > 1)) {
      Fiberchat.toast(getTranslated(context, "onlyonephoto"));
      return '';
    }
    String message = getTranslated(context, "uploading");
    int timeStampFlushbar = DateTime.now().millisecondsSinceEpoch;

    Flushbar(
      backgroundColor: Color(0xff5f42ff),
      key: GlobalKey(),
      isDismissible: true,
      duration: Duration(seconds: 15),
      flushbarPosition: FlushbarPosition.TOP,
      messageText: Text(
        message,
        style: TextStyle(color: Colors.white),
      ),
    )..show(context);
    if (selectedFiles.length == 1) {
      final filePath = selectedFiles[0].path;
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final compressedFile =
          await compressImage(filePath, reducedquality: reducedquality);
      final storageRef = FirebaseStorage.instance.ref("PICXER/$timestamp");
      final uploadTask = storageRef.putFile(
        compressedFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      final snapshot = await uploadTask;

      // flushbar.dismiss();
      return await snapshot.ref.getDownloadURL() + "-PicxerApp";
    } else {
      final List<File> compressedFiles = await Future.wait(
        selectedFiles.map((file) => compressImage(file.path)),
      );

      File archive = await zipFilesFromList(compressedFiles);

      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final storageRef = FirebaseStorage.instance
          .ref("LINK_MEDIA/PhotosFromPicxer$timestamp.zip");
      final uploadTask = storageRef.putFile(
        archive,
      );

      uploadTask.snapshotEvents.listen((event) {
        double progress = event.bytesTransferred / event.totalBytes;

        if (DateTime.now().millisecondsSinceEpoch >
            (timeStampFlushbar + 3001)) {
          Flushbar(
              backgroundColor: Color(0xff5f42ff),
              isDismissible: true,
              animationDuration: Duration(seconds: 0),
              duration: Duration(seconds: 3),
              //key: flushBarKey,
              messageText: Text(
                message +
                    ((progress * 10).round() * 10).toStringAsFixed(0) +
                    "%",
                style: TextStyle(color: Colors.white),
              ),
              flushbarPosition: FlushbarPosition.TOP,
              messageColor: Colors.white)
            ..show(context);
          timeStampFlushbar = DateTime.now().millisecondsSinceEpoch;
        }
      });

      final snapshot = await uploadTask;

      //flushbar.dismiss();
      return await snapshot.ref.getDownloadURL() + "-PicxerApp";
    }
  }

  static Future<File> compressImage(String filePath,
      {reducedquality = false}) async {
    int targetQuality =
        90; //einfach erstmal irgendwas wird sowieso gleich überschrieben
    if (reducedquality = true) {
      targetQuality = 30;
    } else {
      targetQuality = ImageQualityCompress;
    }

    final originalFile = File(filePath);
    //change done
    XFile? compressedGetFile = await FlutterImageCompress.compressAndGetFile(
      originalFile.path,
      originalFile.parent.path +
          '/compressed_${originalFile.path.split('/').last}',
      quality: targetQuality,
    );
    //change done
    final compressedFile = File(compressedGetFile!.path);
    // final compressedFile = await FlutterImageCompress.compressAndGetFile(
    //   originalFile.path,
    //   originalFile.parent.path +
    //       '/compressed_${originalFile.path.split('/').last}',
    //   quality: targetQuality,
    // );
    return compressedFile!;
  }

  Future<File> zipFilesFromList(List<File> files) async {
    final encoder = ZipEncoder();
    final archive = Archive();

    for (final file in files) {
      final filename = basename(file.path);
      final fileData = await file.readAsBytes();
      archive.addFile(ArchiveFile(filename, fileData.length, fileData));
    }

    final zipData = encoder.encode(archive);
    final tempDir = await getTemporaryDirectory();
    final zipFilePath = join(tempDir.path, 'PhotosFromPicxer.zip');
    final zipFile = File(zipFilePath);
    await zipFile.writeAsBytes(zipData!);

    return zipFile;
  }

  final smtpServer = SmtpServer('smtp.zoho.com',
      port: 465,
      ssl: true,
      username: 'picxerapp@picxer.org',
      password: 'PicxerApp635+/');

  Future<void> sendMail(
      String fotoUrl, String recipient, String username, context) async {
    final message = Message()
      ..from = Address('picxerapp@picxer.org', 'Picxer App')
      ..recipients.add(recipient)
      ..subject = getTranslated(context, 'mailsubject') + username
      ..html = '<h2>Hello,</h2><p>' +
          username +
          getTranslated(context, 'mailtext1') +
          '<a href="https://picxer.org/">' +
          getTranslated(context, 'appnamemail') +
          '</a><br><br>' +
          getTranslated(context, 'mailtext2') +
          '<a href="$fotoUrl">' +
          getTranslated(context, 'mailtext3') +
          '</a><br><br></p>';

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());

      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(getTranslated(context, 'mailsuccess'),
                  textAlign: TextAlign.center, textScaleFactor: 0.95),
              content: Text(getTranslated(context, 'mailsuccessdescription'),
                  textAlign: TextAlign.center),
              actions: <Widget>[
                Center(
                    child: TextButton(
                  child: Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                    onBackToRecents(context); //added by JH
                  },
                )),
              ],
            );
          });
    } on MailerException catch (e) {
      print('Message not sent. ' + e.toString());
    }
  }

  Future<void> fotoLinkDialog(context, String link) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            getTranslated(context, 'sentvialinktitle'),
            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            padding: EdgeInsets.zero,
            child: ListBody(
              children: <Widget>[
                Text(getTranslated(context, 'sentvialinkdescription'),
                    textAlign: TextAlign.center),
                Padding(padding: EdgeInsets.only(top: 5)),
                Column(children: [
                  Row(children: [
                    Flexible(
                        child: Container(
                            padding: EdgeInsets.zero,
                            color: Color.fromRGBO(220, 220, 220, 0.5),
                            child: Text(
                              link,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontStyle: FontStyle.italic, fontSize: 13),
                            ))),
                    Container(
                        width: 22,
                        padding: EdgeInsets.fromLTRB(6, 0, 0, 0),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          iconSize: 22,
                          icon: const Icon(Icons.share),
                          onPressed: () {
                            String sharingText =
                                getTranslated(context, 'sharelink') + link;
                            Share.share(sharingText);
                          },
                        )),
                  ]),
                  TextButton(
                    child: Text(getTranslated(context, 'copyclipboard')),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: link));
                      Fiberchat.showRationale(
                          getTranslated(context, 'copyclipboardsuccess'));
                    },
                  )
                ]),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop('dialog');
                onBackToRecents(context); //added by JH
              },
            ),
          ],
        );
      },
    );
  }

  Card searchProductCard(BuildContext context, SharedPreferences widgetPrefs) {
    return cardForRecentChat(
        context,
        widgetPrefs,
        Icons.shopping_bag_outlined,
        "searchProduct",
        () => SendAsLinkOrMail()
                .chooseAndUploadPhotosToLinkMedia(context,
                    onlyOnePhoto: true, reducedquality: true)
                .then(((downloadUrl) {
              print("downloadUrl: " + downloadUrl);
              if (downloadUrl != '') {
                Timer(Duration(seconds: 1), () {
                  SendAsLinkOrMail().searchProductDialog(context, downloadUrl);
                });
              } else {
                showToast(getTranslated(context, 'onlyonephoto'),
                    position: ToastPosition.bottom,
                    duration: Duration(seconds: 5));
              }
            })));
  }

  String truncateString(String title) {
    if (title.length <= 28) {
      return title;
    } else {
      // Find the last blank space within the desired range
      int lastSpace = title.lastIndexOf(' ', 28);

      if (lastSpace >= 15) {
        return title.substring(0, lastSpace);
      } else {
        return title.substring(0, 28);
      }
    }
  }

  Future<void> searchProductDialog(context, imageUrl) async {
    Map<String, Map<String, String>> productData =
        await searchProduct(imageUrl, context);
    Map<String, String> links = {};
    Map<String, String> thumbnails = {};
    if (productData["links"] != null) {
      links = productData["links"]!;
      thumbnails = productData["thumbnails"]!;
    }
    List<Widget> linkWidgets = [];
    if (links.isEmpty) {
      linkWidgets.add(Divider(
        height: 5,
      ));
      linkWidgets.add(
        InkWell(
            child: Container(
          padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
          child: Row(children: [
            Text(
              truncateString(
                  getTranslated(context, 'searchproductnothingfound')),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            )
          ]),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.red),
              borderRadius: BorderRadius.all(Radius.circular(15))),
        )),
      );
    } else {
      links.forEach((title, link) {
        linkWidgets.add(Divider(
          height: 8,
        ));
        linkWidgets.add(
          InkWell(
              onTap: () {
                final Uri url = Uri.parse(link);
                launchUrl(url);
              },
              child: Container(
                padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                child: Row(children: [
                  Container(
                      padding: EdgeInsets.only(right: 5),
                      width: 60,
                      height: 60,
                      child: thumbnails.containsKey(title)
                          ? Image.network(thumbnails[title]!)
                          : null),
                  Container(
                    width: 170,
                    child: Text(
                      truncateString(title),
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  )
                ]),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue, width: 4.0),
                    borderRadius: BorderRadius.all(Radius.circular(15))),
              )),
        );
      });
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            getTranslated(context, 'searchproducttitle'),
            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            padding: EdgeInsets.zero,
            child: ListBody(
              children: <Widget>[
                Text(getTranslated(context, 'searchproductdescription'),
                    textAlign: TextAlign.center),
                Padding(padding: EdgeInsets.only(top: 5)),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: linkWidgets),
              ],
            ),
          ),
          actions: <Widget>[
            ButtonBar(
              children: <Widget>[
                Align(
                  alignment: Alignment.center,
                  child: TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop('dialog');
                      onBackToRecents(context); //added by JH
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
