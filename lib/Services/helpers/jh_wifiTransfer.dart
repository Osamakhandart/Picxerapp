import 'dart:io';
import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:fiberchat/Services/localization/language_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:location/location.dart' as locate;
import 'package:nearby_connections/nearby_connections.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'jh_progressService.dart';
import 'widgets/alert_method.dart';

typedef DeviceConnectionCallback = void Function(
    String numberOfConnectedDevices);
typedef ConnectionFoundCallback = void Function(
    List<Map> numberOfConnectedDevices);
typedef SearchingCallBack = void Function(bool isSearch);
typedef AvailableDevices = void Function(bool isSearch);
typedef ImageSent = void Function(
    Status uploaded, Map<String, ConnectionInfo> point);

class WifiDirectService {
  String? userName;
  BuildContext? context;
  final Strategy strategy = Strategy.P2P_STAR;
  final int progressId = Random().nextInt(10000);
  Map<String, ConnectionInfo> endpointMap = {};
  String? connectedDeviceName;
  bool isDiscoveryOn = false;
  String? tempFileUri; //reference to the file currently being transferred
  Map<int, String> map = {};
  bool popUp = false;
  bool locationService = false;
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  List<String> receivedImageNames = [];
  bool _isReceivedFilesDialogShown = false;

  getDeviceInfo() async {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    userName = androidInfo.model;
  }

  NotificationService notificationService = NotificationService();

  sender(context) async {
    Nearby().stopAdvertising();
    Nearby().stopDiscovery();
    Nearby().stopAllEndpoints();
    Navigator.of(context, rootNavigator: true).pop();
    alertMethod(
        context: context,
        childrenData: [
          SizedBox(
            height: 30,
          ),
          Text(
            getTranslated(context, "searchingreceiver"),
            style: TextStyle(color: Colors.black),
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            height: 40,
            width: 40,
            child: CircularProgressIndicator(),
          ),
          SizedBox(
            height: 30,
          ),
          TextButton(
            child: Text(getTranslated(context, "stopsearching"),
                style: TextStyle(color: Colors.white)),
            onPressed: () {
              Nearby().stopAdvertising();
              Navigator.of(context, rootNavigator: true).pop();
            },
            style: TextButton.styleFrom(
              fixedSize: Size(200, 50),
              backgroundColor:
                  Color(0xff5f42ff), // Sets the background color to purple
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                    8.0), // Sets the corner radius for rounded corners
              ),
            ),
          ),
        ],
        onClose: () {});
    try {
      await Nearby().startAdvertising(
        userName!,
        strategy,
        serviceId: "picxer",
        onConnectionInitiated: (id, info) {
          onConnectionInit(id, info, context, false);
        },
        onConnectionResult: (id, status) async {
          sendImage(status, context);
        },

        // print(status);
        // print('status');
        // // searchingSender(false);

        // sent(sendImage());

        //   onDeviceConnected(connectedDeviceName!);
        //   print('connection establihed');
        //   print(endpointMap.length);
        //   XFile? file =
        //       await ImagePicker().pickImage(source: ImageSource.gallery);
        //
        //   if (file == null) return;
        //   for (MapEntry<String, ConnectionInfo> m in endpointMap.entries) {
        //     int payloadId = await Nearby().sendFilePayload(m.key, file.path);
        //     notificationService.showInitialNotification(
        //         progressId, 'Image', 'Preparing to send');
        //     Nearby().sendBytesPayload(
        //         m.key,
        //         Uint8List.fromList(
        //             "$payloadId:${file.path.split('/').last}".codeUnits)).then((value) {
        //
        //     });

        // } else {
        //   print(Status.ERROR);
        // }

        onDisconnected: (id) {
          print(getTranslated(context, "disconnected"));
          // showSnackbar("Disconnected: ${endpointMap[id]!.endpointName}, id $id");
          // setState(() {
          endpointMap.remove(id);
          // });
        },
      );
    } catch (e) {
      print(e);
    }

    // showSnackbar("ADVERTISING: $a");
  }

  List<Map>? available;
  List<String> availableEndpoints = [];
  var availableEndpointsMap = [];
  receiver(context) async {
    Nearby().stopAdvertising();
    Nearby().stopDiscovery();
    Nearby().stopAllEndpoints();

    availableEndpoints.clear();
    Navigator.of(context, rootNavigator: true).pop();
    try {
      alertMethod(
          context: context,
          childrenData: [
            SizedBox(height: 10),
            Text(
              getTranslated(context, "searchingsender"),
              style: TextStyle(color: Colors.black),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(),
            SizedBox(height: 20),
            InkWell(
              child: Text(getTranslated(context, "stopsearching"),
                  style: TextStyle(color: Colors.black)),
              onTap: () {
                Nearby().stopDiscovery();
                Navigator.of(context, rootNavigator: true).pop();
              },
            ),
          ],
          onClose: () {});

      await Nearby().startDiscovery(
        userName!,
        strategy,
        serviceId: "picxer",
        onEndpointFound: (id, name, serviceId) {
          if (!availableEndpoints.contains(name) && userName != name) {
            print(name);
            availableEndpoints.add(name);
            availableEndpointsMap.add({'name': name, 'id': id});

            // Directly request connection without showing discovered sender

            Nearby().requestConnection(
              userName!,
              id,
              onConnectionInitiated: (id, info) {
                Navigator.of(context, rootNavigator: true).pop();

                onConnectionInit(id, info, context, true);
              },
              onConnectionResult: (id, status) {
                showSnackbar(userName);
              },
              onDisconnected: (id) {
                endpointMap.remove(id);
              },
            );
          }
          print('found');
        },
        onEndpointLost: (id) {
          // Handle endpoint lost if necessary
        },
      );
      isDiscoveryOn = true;
    } catch (e) {
      // Handle exception if necessary
    }
  }

  sendImage(status, context) async {
    if (status == Status.CONNECTED) {
      print('connection established');
      print(endpointMap.length);

      // Pick multiple images
      List<XFile>? files = await ImagePicker().pickMultiImage();

      // Iterate over each file and send it
      for (XFile file in files) {
        for (MapEntry<String, ConnectionInfo> m in endpointMap.entries) {
          int payloadId = await Nearby().sendFilePayload(m.key, file.path);
          /*notificationService.showInitialNotification(
            progressId,
            getTranslated(context, "image"),
            getTranslated(context, "preparingtosend"));*/
          Nearby()
              .sendBytesPayload(
                  m.key,
                  Uint8List.fromList(
                      "$payloadId:${file.path.split('/').last}".codeUnits))
              .then((value) {
            // sent(status, endpointMap);
          });
        }
      }
    }
  }

  transferCompleted(status, context, progressId) {
    notificationService.showCompletionNotification(
        progressId,
        getTranslated(context, "image"),
        getTranslated(context, "imagetransfered"));
    bool pressed = false;
    alertMethod(
      context: context,
      titleText: getTranslated(context, "imagetransfered"),
      theme: Colors.black,
      onClose: (v) {
        if (!pressed) {
          popUp = false;
          Nearby().stopAllEndpoints();
        }
      },
      childrenData: [
        SizedBox(
          height: 10,
        ),
        wifiDialogButton(Icons.send, getTranslated(context, "sendmore"), () {
          pressed = true;
          Navigator.of(context, rootNavigator: true).pop();

          popUp = false;
          sendImage(status, context);
          // Navigator.push(
          //     context, MaterialPageRoute(builder: (context) => ViaWifi()));
        }, context),
        wifiDialogButton(
          Icons.close,
          getTranslated(context, "disconnect"),
          () {
            pressed = true;
            Nearby().stopAllEndpoints();
            Navigator.of(context, rootNavigator: true).pop();
            // Navigator.push(
            //     context, MaterialPageRoute(builder: (context) => ViaWifxi()));
          },
          context,
        ),
      ],
    );
  }

  void openGalleryApp(BuildContext xcontext) async {
    final Uri url = Uri.parse('content://media/internal/images/media');
    // You can also try using 'photos-redirect://' for iOS, but it's not guaranteed to work
    launchUrl(url);
  }

  void showReceivedFilesDialog(BuildContext context) {
    // Check if dialog is already shown
    if (_isReceivedFilesDialogShown) {
      Navigator.of(context, rootNavigator: true)
          .pop(); // Close the existing dialog
    }
    _isReceivedFilesDialogShown =
        true; // Set flag to indicate dialog is being shown

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8))),
          title: Text(getTranslated(context, "imagereceived"),
              textAlign: TextAlign.center),
          content: SingleChildScrollView(
            child: Column(children: [
              Container(
                padding: EdgeInsets.all(25),
                child: Text(getTranslated(context, "imagereceiveddesc"),
                    textAlign: TextAlign.center),
              ),
              ListBody(
                children: receivedImageNames
                    .map((filename) => GestureDetector(
                          /*onTap: () {
                           Add navigation logic to the folder containing the files
                        },*/
                          child: Container(
                              child: Text(filename),
                              padding: EdgeInsets.all(5)),
                        ))
                    .toList(),
              )
            ]),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                getTranslated(context, "opengallerybutton"),
                style: TextStyle(
                  color: Colors.white, // Sets the font color to white
                ),
              ),
              onPressed: () {
                openGalleryApp(context);
                /*
                getExternalStorageDirectory().then((parentDir) {
                  String picturesfolder = parentDir!.path;
                  print(picturesfolder);
                  OpenFile.open(picturesfolder);
                  print(picturesfolder);
                }); */
              },
              style: TextButton.styleFrom(
                fixedSize: Size(120, 45),

                backgroundColor:
                    Color(0xff5f42ff), // Sets the background color to purple
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      8.0), // Sets the corner radius for rounded corners
                ),
              ),
            ),
            TextButton(
              child: Text(
                getTranslated(context, "close"),
                style: TextStyle(
                  color: Colors.white, // Sets the font color to white
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _isReceivedFilesDialogShown =
                    false; // Reset flag when dialog is closed
              },
              style: TextButton.styleFrom(
                fixedSize: Size(120, 45),
                backgroundColor:
                    Color(0xff5f42ff), // Sets the background color to purple
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      8.0), // Sets the corner radius for rounded corners
                ),
              ),
            )
          ],
        );
      },
    );
  }

  transferCompletedReceiver(status, context, progressId) {
    showReceivedFilesDialog(context);
    notificationService.showCompletionNotification(
        progressId,
        getTranslated(context, "image"),
        getTranslated(context, "imagereceived"));
    bool pressed = false;

    alertMethod(
      context: context,
      titleText: getTranslated(context, "imagereceived"),
      theme: Colors.black,
      onClose: (v) {
        if (!pressed) {
          Nearby().stopAllEndpoints();
        }
      },
      childrenData: [
        SizedBox(
          height: 10,
        ),
        // wifiDialogButton(Icons.send, 'Send More', () {
        //   pressed = true;
        //   Navigator.of(context, rootNavigator: true).pop();
        //   sendImage(status, context);
        //   // Navigator.push(
        //   //     context, MaterialPageRoute(builder: (context) => ViaWifi()));
        // }, context),

        wifiDialogButton(
          Icons.close,
          getTranslated(context, "disconnect"),
          () {
            pressed = true;
            Nearby().stopAllEndpoints();
            Navigator.of(context, rootNavigator: true).pop();
            // Navigator.push(
            //     context, MaterialPageRoute(builder: (context) => ViaWifxi()));
          },
          context,
        ),
      ],
    );
  }

  void onConnectionInit(String id, ConnectionInfo info, context, fromReceive) {
    print(info.endpointName);
    print(info.authenticationToken);
    print(info.isIncomingConnection);
    endpointMap[id] = info;

    if (!fromReceive) {
      Navigator.of(context, rootNavigator: true).pop();
    }
    // Navigator.of(context, rootNavigator: true).pop();
    connectedDeviceName = info.endpointName;
    // Navigator.pop(context);
    // Nearby().acceptConnection(
    //   id,
    //   onPayLoadRecieved: (endid, payload) async {
    //     if (payload.type == PayloadType.BYTES) {
    //       String str = String.fromCharCodes(payload.bytes!);
    //       // showSnackbar("$endid: $str");
    //
    //       if (str.contains(':')) {
    //         // used for file payload as file payload is mapped as
    //         // payloadId:filename
    //         int payloadId = int.parse(str.split(':')[0]);
    //         String fileName = (str.split(':')[1]);
    //
    //         if (map.containsKey(payloadId)) {
    //           if (tempFileUri != null) {
    //             moveFile(tempFileUri!, fileName);
    //           } else {
    //             // showSnackbar("File doesn't exist");
    //           }
    //         } else {
    //           //add to map if not already
    //           map[payloadId] = fileName;
    //         }
    //       }
    //     } else if (payload.type == PayloadType.FILE) {
    //       // showSnackbar("$endid: File transfer started");
    //       tempFileUri = payload.uri;
    //     }
    //   },
    //   onPayloadTransferUpdate: (endid, payloadTransferUpdate) {
    //     if (payloadTransferUpdate.status == PayloadStatus.IN_PROGRESS) {
    //       int maxValue = 100; // The maximum value for the progress bar is 100%
    //       int currentValue = ((payloadTransferUpdate.bytesTransferred /
    //                   payloadTransferUpdate.totalBytes) *
    //               100)
    //           .toInt();
    //
    //       notificationService.showProgressNotification(
    //           id, 'Video', 'Uploading', maxValue, currentValue);
    //
    //       print(currentValue);
    //     } else if (payloadTransferUpdate.status == PayloadStatus.FAILURE) {
    //       print("failed");
    //       // showSnackbar("$endid: FAILED to transfer file");
    //     } else if (payloadTransferUpdate.status == PayloadStatus.SUCCESS) {
    //       // showSnackbar(
    //       //     "$endid success, total bytes = ${payloadTransferUpdate.totalBytes}");
    //
    //       if (map.containsKey(payloadTransferUpdate.id)) {
    //         //rename the file now
    //         String name = map[payloadTransferUpdate.id]!;
    //         moveFile(tempFileUri!, name);
    //       } else {
    //         //bytes not received till yet
    //         map[payloadTransferUpdate.id] = "";
    //       }
    //     }
    //   },
    // );

    showModalBottomSheet(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25), topRight: Radius.circular(25))),
      context: context,
      builder: (builder) {
        return Center(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 20,
              ),
              // Text("id: $id"),
              // Text("Token: ${info.authenticationToken}"),
              Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  getTranslated(context, "agreeconnect") +
                      "${info.endpointName}?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height / 35),
                ),
              ),

              SizedBox(
                height: 20,
              ),

              InkWell(
                onTap: () {
                  {
                    endpointMap[id] = info;

                    Navigator.pop(context);
                    Nearby().acceptConnection(
                      id,
                      onPayLoadRecieved: (endid, payload) async {
                        if (payload.type == PayloadType.BYTES) {
                          String str = String.fromCharCodes(payload.bytes!);
                          // showSnackbar("$endid: $str");

                          if (str.contains(':')) {
                            // used for file payload as file payload is mapped as
                            // payloadId:filename
                            int payloadId = int.parse(str.split(':')[0]);
                            String fileName = (str.split(':')[1]);

                            if (map.containsKey(payloadId)) {
                              if (tempFileUri != null) {
                                moveFile(tempFileUri!, fileName);
                              } else {
                                // showSnackbar("File doesn't exist");
                              }
                            } else {
                              //add to map if not already
                              map[payloadId] = fileName;
                            }
                          }
                        } else if (payload.type == PayloadType.FILE) {
                          // showSnackbar("$endid: File transfer started");
                          tempFileUri = payload.uri;
                        }
                      },
                      onPayloadTransferUpdate: (endid, payloadTransferUpdate) {
                        bool hasShownProgress = false;
                        if (payloadTransferUpdate.status ==
                            PayloadStatus.IN_PROGRESS) {
                          int maxValue =
                              100; // The maximum value for the progress bar is 100%
                          int currentValue =
                              ((payloadTransferUpdate.bytesTransferred /
                                          payloadTransferUpdate.totalBytes) *
                                      100)
                                  .toInt();
                          if (hasShownProgress == false) {
                            // notificationService.showProgressNotification(
                            //     progressId,
                            //     'Image',
                            //     'Uploading',
                            //     maxValue,
                            //     currentValue);
                          }

                          print(currentValue);
                          print(maxValue);
                        } else if (payloadTransferUpdate.status ==
                            PayloadStatus.FAILURE) {
                          print("failed");
                          // showSnackbar("$endid: FAILED to transfer file");
                        } else if (payloadTransferUpdate.status ==
                            PayloadStatus.SUCCESS) {
                          if (!fromReceive) {
                            if (!popUp) {
                              popUp = true;
                              print('popup opens');
                              transferCompleted(
                                  Status.CONNECTED, context, progressId);
                            }
                          } else {
                            if (map.containsKey(payloadTransferUpdate.id)) {
                              //rename the file now
                              String name = map[payloadTransferUpdate.id]!;
                              moveFile(tempFileUri!, name);
                            } else {
                              //bytes not received till yet
                              map[payloadTransferUpdate.id] = "";
                            }

                            showReceivedFilesDialog(context);

                            notificationService.showCompletionNotification(
                                progressId,
                                getTranslated(context, "image"),
                                getTranslated(context, "imagereceived"));
                          }
                          // showSnackbar(
                          //     "$endid success, total bytes = ${payloadTransferUpdate.totalBytes}");

                          hasShownProgress = true;
                        }
                      },
                    );
                    // setState(() {

                    // });
                  }
                },
                child: Container(
                    padding: EdgeInsets.only(left: 5, right: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(15),
                      ),
                      color: Color(0xff5f42ff),
                    ),
                    width: MediaQuery.of(context).size.width / 2.5,
                    height: MediaQuery.of(context).size.height / 20,
                    child: Center(
                        child: Text(
                      "Yes",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: MediaQuery.of(context).size.height / 40),
                    ))),
              ),
              SizedBox(
                height: 20,
              ),
              InkWell(
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    await Nearby().rejectConnection(id);
                  } catch (e) {
                    // showSnackbar(e);
                  }
                },
                child: Container(
                    padding: EdgeInsets.only(left: 5, right: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(15),
                      ),
                      color: Color(0xff5f42ff),
                    ),
                    width: MediaQuery.of(context).size.width / 2.5,
                    height: MediaQuery.of(context).size.height / 20,
                    child: Center(
                      child: Text(
                        "No",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: MediaQuery.of(context).size.height / 40),
                      ),
                    )),
              ),
            ],
          ),
        );
      },
    );
  }

  void showSnackbar(dynamic a, {context}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.transparent,
      duration: Duration(hours: 120),
      elevation: 0,
      content: Container(
          padding: const EdgeInsets.only(left: 8, right: 8, bottom: 3),
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: Colors.black, width: 3),
            boxShadow: const [
              BoxShadow(
                color: Color(0x19000000),
                spreadRadius: 2.0,
                blurRadius: 8.0,
                offset: Offset(2, 4),
              )
            ],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Text('Connected to $a',
                    style: TextStyle(color: Color(0xff5f42ff))),
              ),
              const Spacer(),
              InkWell(
                  onTap: () async {
                    await Nearby().stopAllEndpoints();
                    ScaffoldMessenger.of(context!).hideCurrentSnackBar();
                  },
                  child: Text(
                    getTranslated(context, "disconnect"),
                    style: TextStyle(color: Colors.white),
                  ))
            ],
          )),
    ));
  }

  void showSnackbarError(dynamic a, {context}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.black,
      duration: Duration(seconds: 4),
      elevation: 0,
      content: Container(
        padding: const EdgeInsets.only(left: 8, right: 8, bottom: 3),
        child: Text(a, style: TextStyle(color: Colors.white)),
      ),
    ));
  }

  Future<String?> saveFileToGallery(String filePath) async {
    final File file = File(filePath);
    final Uint8List bytes = await file.readAsBytes();
    final result = await ImageGallerySaver.saveImage(bytes);
    print(result); // It prints the saved file's path or URI.
    return result[
        'filePath']; // Assuming the result is a Map with a 'filePath' key.
  }

  void saveFileToDownloads(String filePath) async {
    final File file = File(filePath);
    final Uint8List bytes = await file.readAsBytes();

    // Get the downloads directory
    Directory downloadsDirectory = (await getExternalStorageDirectory())!;
    String downloadsPath = downloadsDirectory.path;

    // Create a new file in the downloads directory with the same name
    String newFilePath = '$downloadsPath/${file.uri.pathSegments.last}';
    File newFile = File(newFilePath);

    // Write the bytes to the new file
    await newFile.writeAsBytes(bytes);
  }

  Future<dynamic> moveFile(String uri, String fileName) async {
    receivedImageNames.add(fileName);
    String parentDir = (await getExternalStorageDirectory())!.path;
    final b =
        await Nearby().copyFileAndDeleteOriginal(uri, '$parentDir/$fileName');
    saveFileToGallery('$parentDir/$fileName');

    return b;
  }
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
