import 'dart:io';

import 'package:fiberchat/Services/helpers/jh_intent/jh_scaffoldExtention.dart';
import 'package:fiberchat/Utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import 'jh_intentConstent.dart';
import 'jh_userListing.dart';

class IntentMainScreen extends StatefulWidget {
  @override
  _IntentMainScreenState createState() => _IntentMainScreenState();
}

class _IntentMainScreenState extends State<IntentMainScreen> {
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      listenShareMediaFiles(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: DimensionConstants.horizontalPadding10),
        child: Text("Receive Sharing Files And Send To Multiple Users...",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: FontSizeWeightConstants.fontSize20,
                color: ColorConstants.greyColor)),
      ),
    ).generalScaffold(
        context: context,
        appTitle: "Receive Sharing Files",
        isBack: false,
        files: [],
        userList: []);
  }

  //All listeners to listen Sharing media files & text
  void listenShareMediaFiles(BuildContext context) {
    Fiberchat.toast("listenShareMediaFiles running"); //TEST

    // For sharing images coming from outside the app while the app is in the memory
  // Listen for media files being shared while the app is running
ReceiveSharingIntent.instance.getMediaStream().listen((List<SharedMediaFile> value) {
  Fiberchat.toast("getMediaStream line 53 running"); // Debugging message
  if (value.isNotEmpty) {
    navigateToShareMedia(context, value); // Navigate to media sharing handler
  }
}, onError: (err) {
  debugPrint("Error in getMediaStream: $err"); // Log errors
});

// Handle media files shared when the app is launched
ReceiveSharingIntent.instance.getInitialMedia().then((List<SharedMediaFile> value) {
  Fiberchat.toast("getInitialMedia line 62 running"); // Debugging message
  if (value.isNotEmpty) {
    navigateToShareMedia(context, value); // Navigate to media sharing handler
  }
}).catchError((err) {
  debugPrint("Error in getInitialMedia: $err"); // Log errors
});


    // For sharing or opening urls/text coming from outside the app while the app is in the memory
    //test require
    // ReceiveSharingIntent.instance.getTextStream().listen((String value) {
    //   navigateToShareText(context, value);
    // }, onError: (err) {
    //   debugPrint("$err");
    // });
    // //test require
    // //  For sharing or opening urls/text coming from outside the app while the app is closed
    // ReceiveSharingIntent.instance.getInitialText().then((String? value) {
    //   navigateToShareText(context, value);
    // });
  }

  void navigateToShareMedia(BuildContext context, List<SharedMediaFile> value) {
    if (value.isNotEmpty) {
      var newFiles = <File>[];
      value.forEach((element) {
        newFiles.add(File(
          Platform.isIOS
              ? element.type == SharedMediaType.file
                  ? element.path
                      .toString()
                      .replaceAll(AppConstants.replaceableText, "")
                  : element.path
              : element.path,
        ));
      });
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => UserListingScreen(
                files: newFiles,
                text: "",
              )));
    }
  }

  void navigateToShareText(BuildContext context, String? value) {
    if (value != null && value.toString().isNotEmpty) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => UserListingScreen(
                files: [],
                text: value,
              )));
    }
  }
}
