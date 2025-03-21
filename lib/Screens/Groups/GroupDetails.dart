//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fiberchat/Configs/Dbkeys.dart';
import 'package:fiberchat/Configs/Dbpaths.dart';
import 'package:fiberchat/Configs/app_constants.dart';
import 'package:fiberchat/Configs/optional_constants.dart';
import 'package:fiberchat/Models/DataModel.dart';
import 'package:fiberchat/Screens/Groups/AddContactsToGroup.dart';
import 'package:fiberchat/Screens/Groups/EditGroupDetails.dart';
import 'package:fiberchat/Screens/call_history/callhistory.dart';
import 'package:fiberchat/Screens/calling_screen/pickup_layout.dart';
import 'package:fiberchat/Screens/profile_settings/profile_view.dart';
import 'package:fiberchat/Services/Admob/admob.dart';
import 'package:fiberchat/Services/Providers/GroupChatProvider.dart';
import 'package:fiberchat/Services/Providers/Observer.dart';
import 'package:fiberchat/Services/Providers/SmartContactProviderWithLocalStoreData.dart';
import 'package:fiberchat/Services/localization/language_constants.dart';
import 'package:fiberchat/Utils/color_detector.dart';
import 'package:fiberchat/Utils/theme_management.dart';
import 'package:fiberchat/Utils/utils.dart';
import 'package:fiberchat/widgets/ImagePicker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GroupDetails extends StatefulWidget {
  final DataModel model;
  final SharedPreferences prefs;
  final String currentUserno;
  final String groupID;
  const GroupDetails(
      {Key? key,
      required this.model,
      required this.prefs,
      required this.currentUserno,
      required this.groupID})
      : super(key: key);

  @override
  _GroupDetailsState createState() => _GroupDetailsState();
}

class _GroupDetailsState extends State<GroupDetails> {
  File? imageFile;

  getImage(File image) {
    // ignore: unnecessary_null_comparison
    if (image != null) {
      setStateIfMounted(() {
        imageFile = image;
      });
    }
    return uploadFile(false);
  }

  bool isloading = false;
  String? videometadata;
  int? uploadTimestamp;
  int? thumnailtimestamp;

  final BannerAd myBanner = BannerAd(
    adUnitId: getBannerAdUnitId()!,
    size: AdSize.banner,
    request: AdRequest(),
    listener: BannerAdListener(),
  );
  AdWidget? adWidget;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final observer = Provider.of<Observer>(this.context, listen: false);
      if (IsBannerAdShow == true && observer.isadmobshow == true) {
        myBanner.load();
        adWidget = AdWidget(ad: myBanner);
        setState(() {});
      }
    });
  }

  Future uploadFile(bool isthumbnail) async {
    uploadTimestamp = DateTime.now().millisecondsSinceEpoch;
    String fileName = 'GROUP_ICON';
    Reference reference = FirebaseStorage.instance
        .ref("+00_GROUP_MEDIA/${widget.groupID}/")
        .child(fileName);

    File? compressedImage;

    final targetPath = imageFile!.absolute.path
            .replaceAll(basename(imageFile!.absolute.path), "") +
        "temp.jpg";
    XFile? compressedGetFile = await FlutterImageCompress.compressAndGetFile(
      imageFile!.absolute.path,
      targetPath,
      quality: DpImageQualityCompress,
      rotate: 0,
    );
    //change done
    compressedImage = File(compressedGetFile!.path);
    // compressedImage = await FlutterImageCompress.compressAndGetFile(
    //   imageFile!.absolute.path,
    //   targetPath,
    //   quality: DpImageQualityCompress,
    //   rotate: 0,
    // );

    TaskSnapshot uploading = await reference.putFile(compressedImage!);
    if (isthumbnail == false) {
      setStateIfMounted(() {
        thumnailtimestamp = uploadTimestamp;
      });
    }

    return uploading.ref.getDownloadURL();
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  userAction(value, String targetPhone, bool targetPhoneIsAdmin,
      List targetUserNotificationTokens) async {
    if (value == 'Remove as Admin') {
      showDialog(
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Thm.isDarktheme(widget.prefs)
                ? fiberchatDIALOGColorDarkMode
                : fiberchatDIALOGColorLightMode,
            title: new Text(
              getTranslated(context, 'removeasadmin'),
              style: TextStyle(
                color: pickTextColorBasedOnBgColorAdvanced(
                    Thm.isDarktheme(widget.prefs)
                        ? fiberchatDIALOGColorDarkMode
                        : fiberchatDIALOGColorLightMode),
              ),
            ),
            actions: [
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                  ),
                  child: Text(
                    getTranslated(context, 'cancel'),
                    style:
                        TextStyle(color: fiberchatPRIMARYcolor, fontSize: 18),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                ),
                child: Text(
                  getTranslated(context, 'confirm'),
                  style:
                      TextStyle(color: fiberchatREDbuttonColor, fontSize: 18),
                ),
                onPressed: () async {
                  Navigator.of(context).pop();
                  setStateIfMounted(() {
                    isloading = true;
                  });
                  await FirebaseFirestore.instance
                      .collection(DbPaths.collectiongroups)
                      .doc(widget.groupID)
                      .update({
                    Dbkeys.groupADMINLIST:
                        FieldValue.arrayRemove([targetPhone]),
                  }).then((value) async {
                    DateTime time = DateTime.now();
                    await FirebaseFirestore.instance
                        .collection(DbPaths.collectiongroups)
                        .doc(widget.groupID)
                        .collection(DbPaths.collectiongroupChats)
                        .doc(time.millisecondsSinceEpoch.toString() +
                            '--' +
                            widget.currentUserno)
                        .set({
                      Dbkeys.groupmsgCONTENT: '',
                      Dbkeys.groupmsgLISToptional: [
                        targetPhone,
                      ],
                      Dbkeys.groupmsgTIME: time.millisecondsSinceEpoch,
                      Dbkeys.groupmsgSENDBY: widget.currentUserno,
                      Dbkeys.groupmsgISDELETED: false,
                      Dbkeys.groupmsgTYPE:
                          Dbkeys.groupmsgTYPEnotificationUserRemovedAsAdmin,
                    });
                    setStateIfMounted(() {
                      isloading = false;
                    });
                  }).catchError((onError) {
                    setStateIfMounted(() {
                      isloading = false;
                    });
                    Fiberchat.toast(
                        'Failed to set as Admin ! \nError occured -$onError');
                  });
                },
              )
            ],
          );
        },
        context: this.context,
      );
    } else if (value == 'Set as Admin') {
      showDialog(
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Thm.isDarktheme(widget.prefs)
                ? fiberchatDIALOGColorDarkMode
                : fiberchatDIALOGColorLightMode,
            title: new Text(
              getTranslated(context, 'setasadmin'),
              style: TextStyle(
                color: pickTextColorBasedOnBgColorAdvanced(
                    Thm.isDarktheme(widget.prefs)
                        ? fiberchatDIALOGColorDarkMode
                        : fiberchatDIALOGColorLightMode),
              ),
            ),
            actions: [
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                  ),
                  child: Text(
                    getTranslated(context, 'cancel'),
                    style:
                        TextStyle(color: fiberchatPRIMARYcolor, fontSize: 18),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                ),
                child: Text(
                  getTranslated(context, 'confirm'),
                  style:
                      TextStyle(color: fiberchatREDbuttonColor, fontSize: 18),
                ),
                onPressed: () async {
                  Navigator.of(context).pop();
                  setStateIfMounted(() {
                    isloading = true;
                  });
                  await FirebaseFirestore.instance
                      .collection(DbPaths.collectiongroups)
                      .doc(widget.groupID)
                      .update({
                    Dbkeys.groupADMINLIST: FieldValue.arrayUnion([targetPhone]),
                  }).then((value) async {
                    DateTime time = DateTime.now();
                    await FirebaseFirestore.instance
                        .collection(DbPaths.collectiongroups)
                        .doc(widget.groupID)
                        .collection(DbPaths.collectiongroupChats)
                        .doc(time.millisecondsSinceEpoch.toString() +
                            '--' +
                            widget.currentUserno)
                        .set({
                      Dbkeys.groupmsgCONTENT: '',
                      Dbkeys.groupmsgLISToptional: [
                        targetPhone,
                      ],
                      Dbkeys.groupmsgTIME: time.millisecondsSinceEpoch,
                      Dbkeys.groupmsgSENDBY: widget.currentUserno,
                      Dbkeys.groupmsgISDELETED: false,
                      Dbkeys.groupmsgTYPE:
                          Dbkeys.groupmsgTYPEnotificationUserSetAsAdmin,
                    });
                    setStateIfMounted(() {
                      isloading = false;
                    });
                  }).catchError((onError) {
                    setStateIfMounted(() {
                      isloading = false;
                    });
                    Fiberchat.toast(
                        'Failed to set as Admin ! \nError occured -$onError');
                  });
                },
              )
            ],
          );
        },
        context: this.context,
      );
    } else if (value == 'Remove from Group') {
      showDialog(
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Thm.isDarktheme(widget.prefs)
                ? fiberchatDIALOGColorDarkMode
                : fiberchatDIALOGColorLightMode,
            title: new Text(
              getTranslated(context, 'removefromgroup'),
              style: TextStyle(
                color: pickTextColorBasedOnBgColorAdvanced(
                    Thm.isDarktheme(widget.prefs)
                        ? fiberchatDIALOGColorDarkMode
                        : fiberchatDIALOGColorLightMode),
              ),
            ),
            actions: [
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                  ),
                  child: Text(
                    getTranslated(context, 'cancel'),
                    style:
                        TextStyle(color: fiberchatPRIMARYcolor, fontSize: 18),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                ),
                child: Text(
                  getTranslated(context, 'remove'),
                  style: TextStyle(color: Colors.red, fontSize: 18),
                ),
                onPressed: () async {
                  Navigator.of(context).pop();
                  setStateIfMounted(() {
                    isloading = true;
                  });
                  try {
                    await FirebaseFirestore.instance
                        .collection(DbPaths.collectiontemptokensforunsubscribe)
                        .doc(targetPhone)
                        .delete();
                  } catch (err) {}
                  await FirebaseFirestore.instance
                      .collection(DbPaths.collectiontemptokensforunsubscribe)
                      .doc(targetPhone)
                      .set({
                    Dbkeys.groupIDfiltered:
                        '${widget.groupID.replaceAll(RegExp('-'), '').substring(1, widget.groupID.replaceAll(RegExp('-'), '').toString().length)}',
                    Dbkeys.notificationTokens: targetUserNotificationTokens,
                    'type': 'unsubscribe'
                  });

                  await FirebaseFirestore.instance
                      .collection(DbPaths.collectiongroups)
                      .doc(widget.groupID)
                      .update(targetPhoneIsAdmin == true
                          ? {
                              Dbkeys.groupMEMBERSLIST:
                                  FieldValue.arrayRemove([targetPhone]),
                              Dbkeys.groupADMINLIST:
                                  FieldValue.arrayRemove([targetPhone]),
                              targetPhone: FieldValue.delete(),
                              '$targetPhone-joinedOn': FieldValue.delete(),
                              '$targetPhone': FieldValue.delete(),
                            }
                          : {
                              Dbkeys.groupMEMBERSLIST:
                                  FieldValue.arrayRemove([targetPhone]),
                              targetPhone: FieldValue.delete(),
                              '$targetPhone-joinedOn': FieldValue.delete(),
                              '$targetPhone': FieldValue.delete(),
                            })
                      .then((value) async {
                    DateTime time = DateTime.now();
                    await FirebaseFirestore.instance
                        .collection(DbPaths.collectiongroups)
                        .doc(widget.groupID)
                        .collection(DbPaths.collectiongroupChats)
                        .doc(time.millisecondsSinceEpoch.toString() +
                            '--' +
                            widget.currentUserno)
                        .set({
                      Dbkeys.groupmsgCONTENT:
                          '$targetPhone ${getTranslated(context, 'removedbyadmin')}',
                      Dbkeys.groupmsgLISToptional: [
                        targetPhone,
                      ],
                      Dbkeys.groupmsgTIME: time.millisecondsSinceEpoch,
                      Dbkeys.groupmsgSENDBY: widget.currentUserno,
                      Dbkeys.groupmsgISDELETED: false,
                      Dbkeys.groupmsgTYPE:
                          Dbkeys.groupmsgTYPEnotificationRemovedUser,
                    });
                    setStateIfMounted(() {
                      isloading = false;
                    });
                    try {
                      await FirebaseFirestore.instance
                          .collection(
                              DbPaths.collectiontemptokensforunsubscribe)
                          .doc(targetPhone)
                          .delete();
                    } catch (err) {}
                  }).catchError((onError) {
                    setStateIfMounted(() {
                      isloading = false;
                    });
                    // Fiberchat.toast(
                    //     'Failed to remove ! \nError occured -$onError');
                  });
                },
              )
            ],
          );
        },
        context: this.context,
      );
    }
  }

  @override
  void dispose() {
    super.dispose();

    if (IsBannerAdShow == true) {
      myBanner.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    final observer = Provider.of<Observer>(context, listen: false);
    return PickupLayout(
        prefs: widget.prefs,
        scaffold: Fiberchat.getNTPWrappedWidget(
            Consumer<List<GroupModel>>(builder: (context, groupList, _child) {
          Map<dynamic, dynamic> groupDoc = groupList.indexWhere((element) =>
                      element.docmap[Dbkeys.groupID] == widget.groupID) <
                  0
              ? {}
              : groupList
                  .lastWhere((element) =>
                      element.docmap[Dbkeys.groupID] == widget.groupID)
                  .docmap;
          return Consumer<SmartContactProviderWithLocalStoreData>(
              builder: (context, availableContacts, _child) => Scaffold(
                    bottomSheet: IsBannerAdShow == true &&
                            observer.isadmobshow == true &&
                            adWidget != null
                        ? Container(
                            height: 60,
                            margin: EdgeInsets.only(
                                bottom: Platform.isIOS == true ? 25.0 : 5,
                                top: 0),
                            child: Center(child: adWidget),
                          )
                        : SizedBox(
                            height: 0,
                          ),
                    backgroundColor: Thm.isDarktheme(widget.prefs)
                        ? fiberchatBACKGROUNDcolorDarkMode
                        : fiberchatBACKGROUNDcolorLightMode,
                    appBar: AppBar(
                      elevation: 0.4,
                      titleSpacing: -5,
                      leading: Container(
                        margin: EdgeInsets.only(right: 0),
                        width: 10,
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            size: 24,
                            color: pickTextColorBasedOnBgColorAdvanced(
                                Thm.isDarktheme(widget.prefs)
                                    ? fiberchatAPPBARcolorDarkMode
                                    : fiberchatAPPBARcolorLightMode),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                      actions: <Widget>[
                        groupDoc[Dbkeys.groupADMINLIST]
                                .contains(widget.currentUserno)
                            ? IconButton(
                                onPressed: () {
                                  Navigator.push(
                                      this.context,
                                      new MaterialPageRoute(
                                          builder: (context) =>
                                              new EditGroupDetails(
                                                prefs: widget.prefs,
                                                currentUserNo:
                                                    widget.currentUserno,
                                                isadmin: groupDoc[Dbkeys
                                                        .groupCREATEDBY] ==
                                                    widget.currentUserno,
                                                groupType:
                                                    groupDoc[Dbkeys.groupTYPE],
                                                groupDesc: groupDoc[
                                                    Dbkeys.groupDESCRIPTION],
                                                groupName:
                                                    groupDoc[Dbkeys.groupNAME],
                                                groupID: widget.groupID,
                                              )));
                                },
                                icon: Icon(
                                  Icons.edit,
                                  size: 21,
                                  color: pickTextColorBasedOnBgColorAdvanced(
                                      Thm.isDarktheme(widget.prefs)
                                          ? fiberchatAPPBARcolorDarkMode
                                          : fiberchatAPPBARcolorLightMode),
                                ))
                            : SizedBox()
                      ],
                      backgroundColor: Thm.isDarktheme(widget.prefs)
                          ? fiberchatAPPBARcolorDarkMode
                          : fiberchatAPPBARcolorLightMode,
                      title: InkWell(
                        onTap: () {
                          // Navigator.push(
                          //     context,
                          //     PageRouteBuilder(
                          //         opaque: false,
                          //         pageBuilder: (context, a1, a2) =>
                          //             ProfileView(peer)));
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              groupDoc[Dbkeys.groupNAME],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: pickTextColorBasedOnBgColorAdvanced(
                                      Thm.isDarktheme(widget.prefs)
                                          ? fiberchatAPPBARcolorDarkMode
                                          : fiberchatAPPBARcolorLightMode),
                                  fontSize: 17.0,
                                  fontWeight: FontWeight.w500),
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Text(
                              widget.currentUserno ==
                                      groupDoc[Dbkeys.groupCREATEDBY]
                                  ? '${getTranslated(context, 'createdbyu')}, ${formatDate(groupDoc[Dbkeys.groupCREATEDON].toDate())}'
                                  : '${getTranslated(context, 'createdby')} ${groupDoc[Dbkeys.groupCREATEDBY]}, ${formatDate(groupDoc[Dbkeys.groupCREATEDON].toDate())}',
                              style: TextStyle(
                                  color: pickTextColorBasedOnBgColorAdvanced(
                                          Thm.isDarktheme(widget.prefs)
                                              ? fiberchatAPPBARcolorDarkMode
                                              : fiberchatAPPBARcolorLightMode)
                                      .withOpacity(0.9),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400),
                            ),
                          ],
                        ),
                      ),
                    ),
                    body: Padding(
                      padding: EdgeInsets.only(
                          bottom: IsBannerAdShow == true &&
                                  observer.isadmobshow == true
                              ? 60
                              : 0),
                      child: Stack(
                        children: [
                          ListView(
                            children: [
                              Stack(
                                children: [
                                  CachedNetworkImage(
                                    imageUrl:
                                        groupDoc[Dbkeys.groupPHOTOURL] ?? '',
                                    imageBuilder: (context, imageProvider) =>
                                        Container(
                                      width: w,
                                      height: w / 1.2,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.rectangle,
                                        image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.cover),
                                      ),
                                    ),
                                    placeholder: (context, url) => Container(
                                      width: w,
                                      height: w / 1.2,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.rectangle,
                                      ),
                                      child: Icon(Icons.people,
                                          color: fiberchatGrey.withOpacity(0.5),
                                          size: 75),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                      width: w,
                                      height: w / 1.2,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.rectangle,
                                      ),
                                      child: Icon(Icons.people,
                                          color: fiberchatGrey.withOpacity(0.5),
                                          size: 75),
                                    ),
                                  ),
                                  Container(
                                    alignment: Alignment.bottomRight,
                                    width: w,
                                    height: w / 1.2,
                                    decoration: BoxDecoration(
                                      color:
                                          groupDoc[Dbkeys.groupPHOTOURL] == null
                                              ? Colors.black.withOpacity(0.2)
                                              : Colors.black.withOpacity(0.4),
                                      shape: BoxShape.rectangle,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(18.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          groupDoc[Dbkeys.groupADMINLIST]
                                                  .contains(
                                                      widget.currentUserno)
                                              ? IconButton(
                                                  onPressed: () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                SingleImagePicker(
                                                                  prefs: widget
                                                                      .prefs,
                                                                  title: getTranslated(
                                                                      this.context,
                                                                      'pickimage'),
                                                                  callback:
                                                                      getImage,
                                                                ))).then(
                                                        (url) async {
                                                      if (url != null) {
                                                        await FirebaseFirestore
                                                            .instance
                                                            .collection(DbPaths
                                                                .collectiongroups)
                                                            .doc(widget.groupID)
                                                            .update({
                                                          Dbkeys.groupPHOTOURL:
                                                              url
                                                        }).then((value) async {
                                                          DateTime time =
                                                              DateTime.now();
                                                          await FirebaseFirestore
                                                              .instance
                                                              .collection(DbPaths
                                                                  .collectiongroups)
                                                              .doc(widget
                                                                  .groupID)
                                                              .collection(DbPaths
                                                                  .collectiongroupChats)
                                                              .doc(time
                                                                      .millisecondsSinceEpoch
                                                                      .toString() +
                                                                  '--' +
                                                                  widget
                                                                      .currentUserno
                                                                      .toString())
                                                              .set({
                                                            Dbkeys
                                                                .groupmsgCONTENT: groupDoc[
                                                                        Dbkeys
                                                                            .groupCREATEDBY] ==
                                                                    widget
                                                                        .currentUserno
                                                                ? '${getTranslated(context, 'grpiconchangedby')} ${getTranslated(context, 'admin')}'
                                                                : '${getTranslated(context, 'grpiconchangedby')} ${widget.currentUserno}',
                                                            Dbkeys.groupmsgLISToptional:
                                                                [],
                                                            Dbkeys.groupmsgTIME:
                                                                time.millisecondsSinceEpoch,
                                                            Dbkeys.groupmsgSENDBY:
                                                                widget
                                                                    .currentUserno,
                                                            Dbkeys.groupmsgISDELETED:
                                                                false,
                                                            Dbkeys.groupmsgTYPE:
                                                                Dbkeys
                                                                    .groupmsgTYPEnotificationUpdatedGroupicon,
                                                          });
                                                        });
                                                      } else {}
                                                    });
                                                  },
                                                  icon: Icon(
                                                      Icons.camera_alt_rounded,
                                                      color: fiberchatWhite,
                                                      size: 35),
                                                )
                                              : SizedBox(),
                                          groupDoc[Dbkeys.groupPHOTOURL] ==
                                                      null ||
                                                  groupDoc[Dbkeys
                                                          .groupCREATEDBY] !=
                                                      widget.currentUserno
                                              ? SizedBox()
                                              : groupDoc[Dbkeys.groupADMINLIST]
                                                      .contains(
                                                          widget.currentUserno)
                                                  ? IconButton(
                                                      onPressed: () async {
                                                        Fiberchat.toast(
                                                            getTranslated(
                                                                context,
                                                                'plswait'));
                                                        await FirebaseStorage
                                                            .instance
                                                            .refFromURL(
                                                                groupDoc[Dbkeys
                                                                    .groupPHOTOURL])
                                                            .delete()
                                                            .then((d) async {
                                                          await FirebaseFirestore
                                                              .instance
                                                              .collection(DbPaths
                                                                  .collectiongroups)
                                                              .doc(widget
                                                                  .groupID)
                                                              .update({
                                                            Dbkeys.groupPHOTOURL:
                                                                null,
                                                          });
                                                          DateTime time =
                                                              DateTime.now();
                                                          await FirebaseFirestore
                                                              .instance
                                                              .collection(DbPaths
                                                                  .collectiongroups)
                                                              .doc(widget
                                                                  .groupID)
                                                              .collection(DbPaths
                                                                  .collectiongroupChats)
                                                              .doc(time
                                                                      .millisecondsSinceEpoch
                                                                      .toString() +
                                                                  '--' +
                                                                  widget
                                                                      .currentUserno
                                                                      .toString())
                                                              .set({
                                                            Dbkeys
                                                                .groupmsgCONTENT: groupDoc[
                                                                        Dbkeys
                                                                            .groupCREATEDBY] ==
                                                                    widget
                                                                        .currentUserno
                                                                ? '${getTranslated(context, 'grpicondeletedby')} ${getTranslated(context, 'admin')}'
                                                                : '${getTranslated(context, 'grpicondeletedby')} ${widget.currentUserno}',
                                                            Dbkeys.groupmsgLISToptional:
                                                                [],
                                                            Dbkeys.groupmsgTIME:
                                                                time.millisecondsSinceEpoch,
                                                            Dbkeys.groupmsgSENDBY:
                                                                widget
                                                                    .currentUserno,
                                                            Dbkeys.groupmsgISDELETED:
                                                                false,
                                                            Dbkeys.groupmsgTYPE:
                                                                Dbkeys
                                                                    .groupmsgTYPEnotificationDeletedGroupicon,
                                                          });
                                                        }).catchError(
                                                                (error) async {
                                                          if (error.toString().contains(Dbkeys.firebaseStorageNoObjectFound1) ||
                                                              error
                                                                  .toString()
                                                                  .contains(Dbkeys
                                                                      .firebaseStorageNoObjectFound2) ||
                                                              error
                                                                  .toString()
                                                                  .contains(Dbkeys
                                                                      .firebaseStorageNoObjectFound3) ||
                                                              error
                                                                  .toString()
                                                                  .contains(Dbkeys
                                                                      .firebaseStorageNoObjectFound4)) {
                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(DbPaths
                                                                    .collectiongroups)
                                                                .doc(widget
                                                                    .groupID)
                                                                .update({
                                                              Dbkeys.groupPHOTOURL:
                                                                  null,
                                                            });
                                                          }
                                                        });
                                                      },
                                                      icon: Icon(
                                                          Icons
                                                              .delete_outline_rounded,
                                                          color: fiberchatWhite,
                                                          size: 35),
                                                    )
                                                  : SizedBox(),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                color: Thm.isDarktheme(widget.prefs)
                                    ? fiberchatCONTAINERboxColorDarkMode
                                    : fiberchatCONTAINERboxColorLightMode,
                                padding: EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          getTranslated(context, 'desc'),
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: fiberchatPRIMARYcolor,
                                              fontSize: 16),
                                        ),
                                        groupDoc[Dbkeys.groupADMINLIST]
                                                .contains(widget.currentUserno)
                                            ? IconButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                      this.context,
                                                      new MaterialPageRoute(
                                                          builder: (context) =>
                                                              new EditGroupDetails(
                                                                prefs: widget
                                                                    .prefs,
                                                                currentUserNo:
                                                                    widget
                                                                        .currentUserno,
                                                                isadmin: groupDoc[
                                                                        Dbkeys
                                                                            .groupCREATEDBY] ==
                                                                    widget
                                                                        .currentUserno,
                                                                groupType:
                                                                    groupDoc[Dbkeys
                                                                        .groupTYPE],
                                                                groupDesc:
                                                                    groupDoc[Dbkeys
                                                                        .groupDESCRIPTION],
                                                                groupName:
                                                                    groupDoc[Dbkeys
                                                                        .groupNAME],
                                                                groupID: widget
                                                                    .groupID,
                                                              )));
                                                },
                                                icon: Icon(
                                                  Icons.edit,
                                                  color: fiberchatGrey,
                                                ))
                                            : SizedBox()
                                      ],
                                    ),
                                    Divider(),
                                    SizedBox(
                                      height: 7,
                                    ),
                                    Text(
                                      groupDoc[Dbkeys.groupDESCRIPTION] == ''
                                          ? getTranslated(context, 'nodesc')
                                          : groupList
                                              .lastWhere((element) =>
                                                  element
                                                      .docmap[Dbkeys.groupID] ==
                                                  widget.groupID)
                                              .docmap[Dbkeys.groupDESCRIPTION],
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          color: pickTextColorBasedOnBgColorAdvanced(Thm
                                                  .isDarktheme(widget.prefs)
                                              ? fiberchatCONTAINERboxColorDarkMode
                                              : fiberchatCONTAINERboxColorLightMode),
                                          fontSize: 15.3),
                                    ),
                                    SizedBox(
                                      height: 7,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Container(
                                color: Thm.isDarktheme(widget.prefs)
                                    ? fiberchatCONTAINERboxColorDarkMode
                                    : fiberchatCONTAINERboxColorLightMode,
                                padding: EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          getTranslated(context, 'grouptype'),
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: fiberchatPRIMARYcolor,
                                              fontSize: 16),
                                        ),
                                        groupDoc[Dbkeys.groupADMINLIST]
                                                .contains(widget.currentUserno)
                                            ? IconButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                      this.context,
                                                      new MaterialPageRoute(
                                                          builder: (context) =>
                                                              new EditGroupDetails(
                                                                prefs: widget
                                                                    .prefs,
                                                                currentUserNo:
                                                                    widget
                                                                        .currentUserno,
                                                                isadmin: groupDoc[
                                                                        Dbkeys
                                                                            .groupCREATEDBY] ==
                                                                    widget
                                                                        .currentUserno,
                                                                groupType:
                                                                    groupDoc[Dbkeys
                                                                        .groupTYPE],
                                                                groupDesc:
                                                                    groupDoc[Dbkeys
                                                                        .groupDESCRIPTION],
                                                                groupName:
                                                                    groupDoc[Dbkeys
                                                                        .groupNAME],
                                                                groupID: widget
                                                                    .groupID,
                                                              )));
                                                },
                                                icon: Icon(
                                                  Icons.edit,
                                                  color: fiberchatGrey,
                                                ))
                                            : SizedBox()
                                      ],
                                    ),
                                    Divider(),
                                    SizedBox(
                                      height: 7,
                                    ),
                                    Text(
                                      groupDoc[Dbkeys.groupTYPE] ==
                                              Dbkeys
                                                  .groupTYPEonlyadminmessageallowed
                                          ? getTranslated(context, 'onlyadmin')
                                          : getTranslated(
                                              context, 'bothuseradmin'),
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          color: pickTextColorBasedOnBgColorAdvanced(Thm
                                                  .isDarktheme(widget.prefs)
                                              ? fiberchatCONTAINERboxColorDarkMode
                                              : fiberchatCONTAINERboxColorLightMode),
                                          fontSize: 15.3),
                                    ),
                                    SizedBox(
                                      height: 7,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Container(
                                color: Thm.isDarktheme(widget.prefs)
                                    ? fiberchatCONTAINERboxColorDarkMode
                                    : fiberchatCONTAINERboxColorLightMode,
                                padding: EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          width: 150,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                '${groupList.firstWhere((element) => element.docmap[Dbkeys.groupID] == widget.groupID).docmap[Dbkeys.groupMEMBERSLIST].length}' +
                                                    ' ' +
                                                    getTranslated(context,
                                                        'participants'),
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        fiberchatPRIMARYcolor,
                                                    fontSize: 16),
                                              ),
                                            ],
                                          ),
                                        ),
                                        (groupDoc[Dbkeys.groupMEMBERSLIST]
                                                        .length >=
                                                    observer
                                                        .groupMemberslimit) ||
                                                !(groupDoc[
                                                        Dbkeys.groupADMINLIST]
                                                    .contains(
                                                        widget.currentUserno))
                                            ? SizedBox()
                                            : InkWell(
                                                onTap: () {
                                                  final SmartContactProviderWithLocalStoreData
                                                      dbcontactsProvider =
                                                      Provider.of<
                                                              SmartContactProviderWithLocalStoreData>(
                                                          context,
                                                          listen: false);
                                                  dbcontactsProvider
                                                      .fetchContacts(
                                                          context,
                                                          widget.model,
                                                          widget.currentUserno,
                                                          widget.prefs,
                                                          false);
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              AddContactsToGroup(
                                                                currentUserNo:
                                                                    widget
                                                                        .currentUserno,
                                                                model: widget
                                                                    .model,
                                                                biometricEnabled:
                                                                    false,
                                                                prefs: widget
                                                                    .prefs,
                                                                groupID: widget
                                                                    .groupID,
                                                                isAddingWhileCreatingGroup:
                                                                    false,
                                                              )));
                                                },
                                                child: SizedBox(
                                                  height: 50,
                                                  // width: 70,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      SizedBox(
                                                        width: 30,
                                                        child: Icon(Icons.add,
                                                            size: 19,
                                                            color:
                                                                fiberchatPRIMARYcolor),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                      ],
                                    ),
                                    getAdminList(),
                                    getUsersList(),
                                  ],
                                ),
                              ),
                              widget.currentUserno ==
                                      groupDoc[Dbkeys.groupCREATEDBY]
                                  ? InkWell(
                                      onTap: () {
                                        showDialog(
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              backgroundColor: Thm.isDarktheme(
                                                      widget.prefs)
                                                  ? fiberchatDIALOGColorDarkMode
                                                  : fiberchatDIALOGColorLightMode,
                                              title: new Text(getTranslated(
                                                  context, 'deletegroup')),
                                              actions: [
                                                ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    elevation: 0,
                                                    backgroundColor:
                                                        Colors.transparent,
                                                  ),
                                                  child: Text(
                                                    getTranslated(
                                                        context, 'cancel'),
                                                    style: TextStyle(
                                                        color:
                                                            fiberchatPRIMARYcolor,
                                                        fontSize: 18),
                                                  ),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                                ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    elevation: 0,
                                                    backgroundColor:
                                                        Colors.transparent,
                                                  ),
                                                  child: Text(
                                                    getTranslated(
                                                        context, 'delete'),
                                                    style: TextStyle(
                                                        color:
                                                            fiberchatREDbuttonColor,
                                                        fontSize: 18),
                                                  ),
                                                  onPressed: () async {
                                                    Navigator.of(context).pop();
                                                    Navigator.of(context).pop();
                                                    Navigator.of(context).pop();

                                                    Future.delayed(
                                                        const Duration(
                                                            milliseconds: 500),
                                                        () async {
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection(DbPaths
                                                              .collectiongroups)
                                                          .doc(widget.groupID)
                                                          .get()
                                                          .then((doc) async {
                                                        await doc.reference
                                                            .delete();
                                                      });

                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection(DbPaths
                                                              .collectiontemptokensforunsubscribe)
                                                          .doc(widget.groupID)
                                                          .delete();
                                                      //No need to delete the media data from here as it will be deleted automatically using Cloud functions deployed in Firebase once the .doc is deleted .
                                                    });
                                                  },
                                                )
                                              ],
                                            );
                                          },
                                          context: context,
                                        );
                                      },
                                      child: Container(
                                          alignment: Alignment.center,
                                          margin: EdgeInsets.fromLTRB(
                                              10, 30, 10, 30),
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: 48.0,
                                          decoration: new BoxDecoration(
                                            color: fiberchatREDbuttonColor,
                                            borderRadius:
                                                new BorderRadius.circular(5.0),
                                          ),
                                          child: Text(
                                            getTranslated(
                                                context, 'deletegroup'),
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 16),
                                          )),
                                    )
                                  : InkWell(
                                      onTap: () {
                                        showDialog(
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              backgroundColor: Thm.isDarktheme(
                                                      widget.prefs)
                                                  ? fiberchatDIALOGColorDarkMode
                                                  : fiberchatDIALOGColorLightMode,
                                              title: new Text(
                                                getTranslated(
                                                    context, 'leavegroup'),
                                                style: TextStyle(
                                                  color: pickTextColorBasedOnBgColorAdvanced(Thm
                                                          .isDarktheme(
                                                              widget.prefs)
                                                      ? fiberchatDIALOGColorDarkMode
                                                      : fiberchatDIALOGColorLightMode),
                                                ),
                                              ),
                                              actions: [
                                                ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    elevation: 0,
                                                    backgroundColor:
                                                        Colors.transparent,
                                                  ),
                                                  child: Text(
                                                    getTranslated(
                                                        context, 'cancel'),
                                                    style: TextStyle(
                                                        color:
                                                            fiberchatPRIMARYcolor,
                                                        fontSize: 18),
                                                  ),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                                ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    elevation: 0,
                                                    backgroundColor:
                                                        Colors.transparent,
                                                  ),
                                                  child: Text(
                                                    getTranslated(
                                                        context, 'leave'),
                                                    style: TextStyle(
                                                        color:
                                                            fiberchatREDbuttonColor,
                                                        fontSize: 18),
                                                  ),
                                                  onPressed: () async {
                                                    Navigator.of(context).pop();
                                                    Navigator.of(context).pop();
                                                    Navigator.of(context).pop();
                                                    Future.delayed(
                                                        const Duration(
                                                            milliseconds: 300),
                                                        () async {
                                                      DateTime time =
                                                          DateTime.now();
                                                      try {
                                                        await FirebaseFirestore
                                                            .instance
                                                            .collection(DbPaths
                                                                .collectiontemptokensforunsubscribe)
                                                            .doc(widget
                                                                .currentUserno)
                                                            .delete();
                                                      } catch (err) {}
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection(DbPaths
                                                              .collectiontemptokensforunsubscribe)
                                                          .doc(widget
                                                              .currentUserno)
                                                          .set({
                                                        Dbkeys.groupIDfiltered:
                                                            '${widget.groupID.replaceAll(RegExp('-'), '').substring(1, widget.groupID.replaceAll(RegExp('-'), '').toString().length)}',
                                                        Dbkeys
                                                            .notificationTokens: widget
                                                                    .model
                                                                    .currentUser![
                                                                Dbkeys
                                                                    .notificationTokens] ??
                                                            [],
                                                        'type': 'unsubscribe'
                                                      }).then((value) async {
                                                        await FirebaseFirestore
                                                            .instance
                                                            .collection(DbPaths
                                                                .collectiongroups)
                                                            .doc(widget.groupID)
                                                            .update(groupDoc[Dbkeys
                                                                        .groupADMINLIST]
                                                                    .contains(widget
                                                                        .currentUserno)
                                                                ? {
                                                                    Dbkeys.groupADMINLIST:
                                                                        FieldValue
                                                                            .arrayRemove([
                                                                      widget
                                                                          .currentUserno
                                                                    ]),
                                                                    Dbkeys.groupMEMBERSLIST:
                                                                        FieldValue
                                                                            .arrayRemove([
                                                                      widget
                                                                          .currentUserno
                                                                    ]),
                                                                    widget.currentUserno:
                                                                        FieldValue
                                                                            .delete(),
                                                                    '${widget.currentUserno}-joinedOn':
                                                                        FieldValue
                                                                            .delete()
                                                                  }
                                                                : {
                                                                    Dbkeys.groupMEMBERSLIST:
                                                                        FieldValue
                                                                            .arrayRemove([
                                                                      widget
                                                                          .currentUserno
                                                                    ]),
                                                                    widget.currentUserno:
                                                                        FieldValue
                                                                            .delete(),
                                                                    '${widget.currentUserno}-joinedOn':
                                                                        FieldValue
                                                                            .delete()
                                                                  });

                                                        await FirebaseFirestore
                                                            .instance
                                                            .collection(DbPaths
                                                                .collectiongroups)
                                                            .doc(widget.groupID)
                                                            .collection(DbPaths
                                                                .collectiongroupChats)
                                                            .doc(time
                                                                    .millisecondsSinceEpoch
                                                                    .toString() +
                                                                '--' +
                                                                widget
                                                                    .currentUserno)
                                                            .set({
                                                          Dbkeys.groupmsgCONTENT:
                                                              '${widget.currentUserno} ${getTranslated(context, 'leftthegroup')}',
                                                          Dbkeys.groupmsgLISToptional:
                                                              [],
                                                          Dbkeys.groupmsgTIME: time
                                                              .millisecondsSinceEpoch,
                                                          Dbkeys.groupmsgSENDBY:
                                                              widget
                                                                  .currentUserno,
                                                          Dbkeys.groupmsgISDELETED:
                                                              false,
                                                          Dbkeys.groupmsgTYPE:
                                                              Dbkeys
                                                                  .groupmsgTYPEnotificationUserLeft,
                                                        });

                                                        try {
                                                          await FirebaseFirestore
                                                              .instance
                                                              .collection(DbPaths
                                                                  .collectiontemptokensforunsubscribe)
                                                              .doc(widget
                                                                  .currentUserno)
                                                              .delete();
                                                        } catch (err) {}
                                                      }).catchError((err) {
                                                        // Fiberchat.toast(
                                                        //     getTranslated(context,
                                                        //         'unabletoleavegrp'));
                                                      });
                                                    });
                                                  },
                                                )
                                              ],
                                            );
                                          },
                                          context: context,
                                        );
                                      },
                                      child: Container(
                                          alignment: Alignment.center,
                                          margin: EdgeInsets.fromLTRB(
                                              10, 30, 10, 30),
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: 48.0,
                                          decoration: new BoxDecoration(
                                            color: Colors.black,
                                            borderRadius:
                                                new BorderRadius.circular(5.0),
                                          ),
                                          child: Text(
                                            getTranslated(
                                                context, 'leavegroup'),
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16),
                                          )),
                                    )
                            ],
                          ),
                          Positioned(
                            child: isloading
                                ? Container(
                                    child: Center(
                                      child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  fiberchatSECONDARYolor)),
                                    ),
                                    color: pickTextColorBasedOnBgColorAdvanced(!Thm
                                                .isDarktheme(widget.prefs)
                                            ? fiberchatCONTAINERboxColorDarkMode
                                            : fiberchatCONTAINERboxColorLightMode)
                                        .withOpacity(0.6))
                                : Container(),
                          )
                        ],
                      ),
                    ),
                  ));
        })));
  }

  getAdminList() {
    return Consumer<List<GroupModel>>(builder: (context, groupList, _child) {
      Map<dynamic, dynamic> groupDoc = groupList
          .lastWhere(
              (element) => element.docmap[Dbkeys.groupID] == widget.groupID)
          .docmap;

      return Consumer<SmartContactProviderWithLocalStoreData>(
          builder: (context, availableContacts, _child) => ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              itemCount: groupDoc[Dbkeys.groupADMINLIST].length,
              itemBuilder: (context, int i) {
                List adminlist = groupDoc[Dbkeys.groupADMINLIST].toList();
                return FutureBuilder<LocalUserData?>(
                    future: availableContacts.fetchUserDataFromnLocalOrServer(
                        widget.prefs, adminlist[i]),
                    builder: (context, AsyncSnapshot<LocalUserData?> snapshot) {
                      // if (snapshot.connectionState == ConnectionState.waiting) {
                      //   return Column(
                      //     mainAxisSize: MainAxisSize.min,
                      //     children: [
                      //       Divider(
                      //         height: 3,
                      //       ),
                      //       Stack(
                      //         children: [
                      //           ListTile(
                      //             isThreeLine: false,
                      //             contentPadding:
                      //                 EdgeInsets.fromLTRB(0, 0, 0, 0),
                      //             leading: Padding(
                      //               padding: const EdgeInsets.only(left: 5),
                      //               child: Padding(
                      //                 padding: const EdgeInsets.all(0.0),
                      //                 child: CachedNetworkImage(
                      //                     imageUrl: '',
                      //                     imageBuilder:
                      //                         (context, imageProvider) =>
                      //                             Container(
                      //                               width: 40.0,
                      //                               height: 40.0,
                      //                               decoration: BoxDecoration(
                      //                                 shape: BoxShape.circle,
                      //                                 image: DecorationImage(
                      //                                     image: imageProvider,
                      //                                     fit: BoxFit.cover),
                      //                               ),
                      //                             ),
                      //                     placeholder: (context, url) =>
                      //                         Container(
                      //                           width: 40.0,
                      //                           height: 40.0,
                      //                           decoration: BoxDecoration(
                      //                             color: Colors.grey[300],
                      //                             shape: BoxShape.circle,
                      //                           ),
                      //                         ),
                      //                     errorWidget: (context, url, error) =>
                      //                         SizedBox(
                      //                           width: 40,
                      //                           height: 40,
                      //                           child: customCircleAvatar(
                      //                               radius: 40),
                      //                         )),
                      //               ),
                      //             ),
                      //             title: Text(
                      //               availableContacts.contactsBookContactList!
                      //                           .entries
                      //                           .toList()
                      //                           .indexWhere((element) =>
                      //                               element.key ==
                      //                               adminlist[i]) >
                      //                       0
                      //                   ? availableContacts
                      //                       .contactsBookContactList!.entries
                      //                       .elementAt(availableContacts
                      //                           .contactsBookContactList!
                      //                           .entries
                      //                           .toList()
                      //                           .indexWhere((element) =>
                      //                               element.key ==
                      //                               adminlist[i]))
                      //                       .value
                      //                       .toString()
                      //                   : adminlist[i],
                      //               maxLines: 1,
                      //               overflow: TextOverflow.ellipsis,
                      //               style: TextStyle(
                      //                   fontWeight: FontWeight.normal),
                      //             ),
                      //             subtitle: Text(
                      //               '',
                      //               maxLines: 1,
                      //               overflow: TextOverflow.ellipsis,
                      //               style: TextStyle(height: 1.4),
                      //             ),
                      //           ),
                      //           groupDoc[Dbkeys.groupADMINLIST]
                      //                   .contains(adminlist[i])
                      //               ? Positioned(
                      //                   right: 27,
                      //                   top: 10,
                      //                   child: Container(
                      //                     padding:
                      //                         EdgeInsets.fromLTRB(4, 2, 4, 2),
                      //                     height: 18.0,
                      //                     decoration: new BoxDecoration(
                      //                       color: Colors.white,
                      //                       border: new Border.all(
                      //                           color: adminlist[i] ==
                      //                                   groupList
                      //                                           .lastWhere((element) =>
                      //                                               element.docmap[
                      //                                                   Dbkeys
                      //                                                       .groupID] ==
                      //                                               widget.groupID)
                      //                                           .docmap[
                      //                                       Dbkeys
                      //                                           .groupCREATEDBY]
                      //                               ? Colors.purple[400]!
                      //                               : Colors.green[400] ??
                      //                                   Colors.grey,
                      //                           width: 1.0),
                      //                       borderRadius:
                      //                           new BorderRadius.circular(5.0),
                      //                     ),
                      //                     child: new Center(
                      //                       child: new Text(
                      //                         getTranslated(context, 'admin'),
                      //                         style: new TextStyle(
                      //                             fontSize: 11.0,
                      //                             color: adminlist[i] ==
                      //                                     groupList
                      //                                         .lastWhere((element) =>
                      //                                             element.docmap[
                      //                                                 Dbkeys
                      //                                                     .groupID] ==
                      //                                             widget
                      //                                                 .groupID)
                      //                                         .docmap[Dbkeys.groupCREATEDBY]
                      //                                 ? Colors.purple[400]
                      //                                 : Colors.green[400]),
                      //                       ),
                      //                     ),
                      //                   ),
                      //                 )
                      //               : SizedBox(),
                      //         ],
                      //       ),
                      //     ],
                      //   );
                      // } else
                      if (snapshot.hasData && snapshot.data != null) {
                        bool isCurrentUserSuperAdmin = widget.currentUserno ==
                            groupDoc[Dbkeys.groupCREATEDBY];
                        bool isCurrentUserAdmin =
                            groupDoc[Dbkeys.groupADMINLIST]
                                .contains(widget.currentUserno);

                        bool isListUserSuperAdmin =
                            groupDoc[Dbkeys.groupCREATEDBY] == adminlist[i];
                        //----
                        bool islisttUserAdmin = groupDoc[Dbkeys.groupADMINLIST]
                            .contains(adminlist[i]);
                        bool isListUserOnlyUser =
                            !groupDoc[Dbkeys.groupADMINLIST]
                                .contains(adminlist[i]);
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Divider(
                              height: 3,
                            ),
                            Stack(
                              children: [
                                ListTile(
                                  trailing: SizedBox(
                                    width: 30,
                                    child: (isCurrentUserSuperAdmin ||
                                            ((isCurrentUserAdmin &&
                                                    isListUserOnlyUser) ==
                                                true))
                                        ? isListUserSuperAdmin
                                            ? null
                                            : PopupMenuButton<String>(
                                                color: Thm.isDarktheme(
                                                        widget.prefs)
                                                    ? fiberchatDIALOGColorDarkMode
                                                    : fiberchatDIALOGColorLightMode,
                                                itemBuilder:
                                                    (BuildContext context) =>
                                                        <PopupMenuEntry<
                                                            String>>[
                                                          PopupMenuItem<String>(
                                                            value:
                                                                'Remove from Group',
                                                            child: Text(
                                                              getTranslated(
                                                                  context,
                                                                  'removefromgroup'),
                                                              style: TextStyle(
                                                                  color: pickTextColorBasedOnBgColorAdvanced(Thm.isDarktheme(
                                                                          widget
                                                                              .prefs)
                                                                      ? fiberchatDIALOGColorDarkMode
                                                                      : fiberchatDIALOGColorLightMode)),
                                                            ),
                                                          ),
                                                          PopupMenuItem<String>(
                                                            value: isListUserOnlyUser
                                                                ? 'Set as Admin'
                                                                : 'Remove as Admin',
                                                            child: Text(
                                                                isListUserOnlyUser
                                                                    ? '${getTranslated(context, 'setasadmin')}'
                                                                    : '${getTranslated(context, 'removeasadmin')}',
                                                                style: TextStyle(
                                                                    color: pickTextColorBasedOnBgColorAdvanced(Thm.isDarktheme(
                                                                            widget.prefs)
                                                                        ? fiberchatDIALOGColorDarkMode
                                                                        : fiberchatDIALOGColorLightMode))),
                                                          ),
                                                        ],
                                                onSelected:
                                                    (String value) async {
                                                  await availableContacts
                                                      .fetchFromFiretsoreAndReturnData(
                                                          widget.prefs,
                                                          snapshot.data!.id,
                                                          (doc) {
                                                    userAction(
                                                        value,
                                                        adminlist[i],
                                                        islisttUserAdmin,
                                                        doc[Dbkeys
                                                                .notificationTokens] ??
                                                            []);
                                                  });
                                                },
                                                child: Icon(
                                                  Icons.more_vert_outlined,
                                                  size: 20,
                                                  color: fiberchatGrey,
                                                ))
                                        : null,
                                  ),
                                  isThreeLine: false,
                                  contentPadding:
                                      EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  leading: Padding(
                                    padding: const EdgeInsets.only(left: 5),
                                    child: Padding(
                                        padding: const EdgeInsets.all(0.0),
                                        child: customCircleAvatar(
                                            url: snapshot.data!.photoURL,
                                            radius: 22)),
                                  ),
                                  title: Text(
                                    availableContacts.contactsBookContactList!
                                                .entries
                                                .toList()
                                                .indexWhere((element) =>
                                                    element.key ==
                                                    adminlist[i]) >
                                            0
                                        ? availableContacts
                                            .contactsBookContactList!.entries
                                            .elementAt(availableContacts
                                                .contactsBookContactList!
                                                .entries
                                                .toList()
                                                .indexWhere((element) =>
                                                    element.key ==
                                                    adminlist[i]))
                                            .value
                                            .toString()
                                        : snapshot.data!.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: pickTextColorBasedOnBgColorAdvanced(Thm
                                                .isDarktheme(widget.prefs)
                                            ? fiberchatCONTAINERboxColorDarkMode
                                            : fiberchatCONTAINERboxColorLightMode)),
                                  ),
                                  enabled: true,
                                  subtitle: Text(
                                    //-- or about me
                                    snapshot.data!.id,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        height: 1.4, color: fiberchatGrey),
                                  ),
                                  onTap: widget.currentUserno ==
                                          snapshot.data!.id
                                      ? () {}
                                      : () async {
                                          await availableContacts
                                              .fetchFromFiretsoreAndReturnData(
                                                  widget.prefs,
                                                  snapshot.data!.id, (doc) {
                                            Navigator.push(
                                                context,
                                                new MaterialPageRoute(
                                                    builder: (context) =>
                                                        new ProfileView(
                                                          doc.data()!,
                                                          widget.currentUserno,
                                                          widget.model,
                                                          widget.prefs,
                                                          [],
                                                          firestoreUserDoc: doc,
                                                        )));
                                          });
                                        },
                                ),
                                groupDoc[Dbkeys.groupADMINLIST]
                                        .contains(adminlist[i])
                                    ? Positioned(
                                        right: 27,
                                        top: 10,
                                        child: Container(
                                          padding:
                                              EdgeInsets.fromLTRB(4, 2, 4, 2),
                                          // width: 50.0,
                                          height: 18.0,
                                          decoration: new BoxDecoration(
                                            color: Thm.isDarktheme(widget.prefs)
                                                ? fiberchatCONTAINERboxColorDarkMode
                                                : fiberchatCONTAINERboxColorLightMode,
                                            border: new Border.all(
                                                color: adminlist[i] ==
                                                        groupDoc[Dbkeys
                                                            .groupCREATEDBY]
                                                    ? Colors.purple[400]!
                                                    : fiberchatGreenColor400,
                                                width: 1.0),
                                            borderRadius:
                                                new BorderRadius.circular(5.0),
                                          ),
                                          child: new Center(
                                            child: new Text(
                                              getTranslated(context, 'admin'),
                                              style: new TextStyle(
                                                fontSize: 11.0,
                                                color: adminlist[i] ==
                                                        groupDoc[Dbkeys
                                                            .groupCREATEDBY]
                                                    ? Colors.purple[400]
                                                    : fiberchatGreenColor400,
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    : SizedBox(),
                              ],
                            ),
                          ],
                        );
                      }
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Divider(
                            height: 3,
                          ),
                          Stack(
                            children: [
                              ListTile(
                                isThreeLine: false,
                                contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                leading: Padding(
                                  padding: const EdgeInsets.only(left: 5),
                                  child: Padding(
                                      padding: const EdgeInsets.all(0.0),
                                      child: customCircleAvatar(
                                          url: snapshot.data!.photoURL,
                                          radius: 22)),
                                ),
                                title: Text(
                                  availableContacts
                                              .contactsBookContactList!.entries
                                              .toList()
                                              .indexWhere((element) =>
                                                  element.key == adminlist[i]) >
                                          0
                                      ? availableContacts
                                          .contactsBookContactList!.entries
                                          .elementAt(availableContacts
                                              .contactsBookContactList!.entries
                                              .toList()
                                              .indexWhere((element) =>
                                                  element.key == adminlist[i]))
                                          .value
                                          .toString()
                                      : adminlist[i],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      color: pickTextColorBasedOnBgColorAdvanced(Thm
                                              .isDarktheme(widget.prefs)
                                          ? fiberchatCONTAINERboxColorDarkMode
                                          : fiberchatCONTAINERboxColorLightMode)),
                                ),
                                subtitle: Text(
                                  '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(height: 1.4),
                                ),
                              ),
                              groupDoc[Dbkeys.groupADMINLIST]
                                      .contains(adminlist[i])
                                  ? Positioned(
                                      right: 27,
                                      top: 10,
                                      child: Container(
                                        padding:
                                            EdgeInsets.fromLTRB(4, 2, 4, 2),
                                        // width: 50.0,
                                        height: 18.0,
                                        decoration: new BoxDecoration(
                                          color: Thm.isDarktheme(widget.prefs)
                                              ? fiberchatCONTAINERboxColorDarkMode
                                              : fiberchatCONTAINERboxColorLightMode,
                                          border: new Border.all(
                                              color: adminlist[i] ==
                                                      groupDoc[
                                                          Dbkeys.groupCREATEDBY]
                                                  ? Colors.purple[400]!
                                                  : fiberchatGreenColor400,
                                              width: 1.0),
                                          borderRadius:
                                              new BorderRadius.circular(5.0),
                                        ),
                                        child: new Center(
                                          child: new Text(
                                            getTranslated(context, 'admin'),
                                            style: new TextStyle(
                                              fontSize: 11.0,
                                              color: adminlist[i] ==
                                                      groupDoc[
                                                          Dbkeys.groupCREATEDBY]
                                                  ? Colors.purple[400]
                                                  : fiberchatGreenColor400,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : SizedBox(),
                            ],
                          ),
                        ],
                      );
                    });
              }));
    });
  }

  getUsersList() {
    return Consumer<List<GroupModel>>(builder: (context, groupList, _child) {
      Map<dynamic, dynamic> groupDoc = groupList
          .lastWhere(
              (element) => element.docmap[Dbkeys.groupID] == widget.groupID)
          .docmap;

      return Consumer<SmartContactProviderWithLocalStoreData>(
          builder: (context, availableContacts, _child) {
        List onlyuserslist = groupDoc[Dbkeys.groupMEMBERSLIST];
        groupDoc[Dbkeys.groupMEMBERSLIST].toList().forEach((member) {
          if (groupDoc[Dbkeys.groupADMINLIST].contains(member) == true) {
            onlyuserslist.remove(member);
          }
        });
        return ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            physics: BouncingScrollPhysics(),
            itemCount: onlyuserslist.length,
            itemBuilder: (context, int i) {
              List viewerslist = onlyuserslist;

              return FutureBuilder<LocalUserData?>(
                  future: availableContacts.fetchUserDataFromnLocalOrServer(
                      widget.prefs, viewerslist[i]),
                  builder: (context, AsyncSnapshot<LocalUserData?> snapshot) {
                    // if (snapshot.connectionState == ConnectionState.waiting) {
                    //   return Column(
                    //     mainAxisSize: MainAxisSize.min,
                    //     children: [
                    //       Divider(
                    //         height: 3,
                    //       ),
                    //       Stack(
                    //         children: [
                    //           ListTile(
                    //             isThreeLine: false,
                    //             contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    //             leading: Padding(
                    //               padding: const EdgeInsets.only(left: 5),
                    //               child: Padding(
                    //                 padding: const EdgeInsets.all(0.0),
                    //                 child: CachedNetworkImage(
                    //                     imageUrl: '',
                    //                     imageBuilder:
                    //                         (context, imageProvider) =>
                    //                             Container(
                    //                               width: 40.0,
                    //                               height: 40.0,
                    //                               decoration: BoxDecoration(
                    //                                 shape: BoxShape.circle,
                    //                                 image: DecorationImage(
                    //                                     image: imageProvider,
                    //                                     fit: BoxFit.cover),
                    //                               ),
                    //                             ),
                    //                     placeholder: (context, url) =>
                    //                         Container(
                    //                           width: 40.0,
                    //                           height: 40.0,
                    //                           decoration: BoxDecoration(
                    //                             color: Colors.grey[300],
                    //                             shape: BoxShape.circle,
                    //                           ),
                    //                         ),
                    //                     errorWidget: (context, url, error) =>
                    //                         SizedBox(
                    //                           width: 40,
                    //                           height: 40,
                    //                           child: customCircleAvatar(
                    //                               radius: 40),
                    //                         )),
                    //               ),
                    //             ),
                    //             title: Text(
                    //               availableContacts
                    //                           .contactsBookContactList!.entries
                    //                           .toList()
                    //                           .indexWhere((element) =>
                    //                               element.key ==
                    //                               viewerslist[i]) >
                    //                       0
                    //                   ? availableContacts
                    //                       .contactsBookContactList!.entries
                    //                       .elementAt(availableContacts
                    //                           .contactsBookContactList!.entries
                    //                           .toList()
                    //                           .indexWhere((element) =>
                    //                               element.key ==
                    //                               viewerslist[i]))
                    //                       .value
                    //                       .toString()
                    //                   : viewerslist[i],
                    //               maxLines: 1,
                    //               overflow: TextOverflow.ellipsis,
                    //               style:
                    //                   TextStyle(fontWeight: FontWeight.normal),
                    //             ),
                    //             subtitle: Text(
                    //               '',
                    //               maxLines: 1,
                    //               overflow: TextOverflow.ellipsis,
                    //               style: TextStyle(height: 1.4),
                    //             ),
                    //           ),
                    //           groupDoc[Dbkeys.groupADMINLIST]
                    //                   .contains(viewerslist[i])
                    //               ? Positioned(
                    //                   right: 27,
                    //                   top: 10,
                    //                   child: Container(
                    //                     padding:
                    //                         EdgeInsets.fromLTRB(4, 2, 4, 2),
                    //                     // width: 50.0,
                    //                     height: 18.0,
                    //                     decoration: new BoxDecoration(
                    //                       color: Colors.white,
                    //                       border: new Border.all(
                    //                           color: Colors.green[400] ??
                    //                               Colors.grey,
                    //                           width: 1.0),
                    //                       borderRadius:
                    //                           new BorderRadius.circular(5.0),
                    //                     ),
                    //                     child: new Center(
                    //                       child: new Text(
                    //                         getTranslated(context, 'admin'),
                    //                         style: new TextStyle(
                    //                             fontSize: 11.0,
                    //                             color: Colors.green[400]),
                    //                       ),
                    //                     ),
                    //                   ),
                    //                 )
                    //               : SizedBox(),
                    //         ],
                    //       ),
                    //     ],
                    //   );
                    // } else

                    if (snapshot.hasData && snapshot.data != null) {
                      bool isCurrentUserSuperAdmin = widget.currentUserno ==
                          groupDoc[Dbkeys.groupCREATEDBY];
                      bool isCurrentUserAdmin = groupDoc[Dbkeys.groupADMINLIST]
                          .contains(widget.currentUserno);

                      bool isListUserSuperAdmin =
                          groupDoc[Dbkeys.groupCREATEDBY] == viewerslist[i];
                      //----
                      bool islisttUserAdmin = groupDoc[Dbkeys.groupADMINLIST]
                          .contains(viewerslist[i]);
                      bool isListUserOnlyUser = !groupDoc[Dbkeys.groupADMINLIST]
                          .contains(viewerslist[i]);
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Divider(
                            height: 3,
                          ),
                          Stack(
                            children: [
                              ListTile(
                                trailing: SizedBox(
                                  width: 30,
                                  child: (isCurrentUserSuperAdmin ||
                                          ((isCurrentUserAdmin &&
                                                  isListUserOnlyUser) ==
                                              true))
                                      ? isListUserSuperAdmin
                                          ? null
                                          : PopupMenuButton<String>(
                                              color: Thm.isDarktheme(
                                                      widget.prefs)
                                                  ? fiberchatDIALOGColorDarkMode
                                                  : fiberchatDIALOGColorLightMode,
                                              itemBuilder:
                                                  (BuildContext context) =>
                                                      <PopupMenuEntry<String>>[
                                                        PopupMenuItem<String>(
                                                          value:
                                                              'Remove from Group',
                                                          child: Text(
                                                            getTranslated(
                                                                context,
                                                                'removefromgroup'),
                                                            style: TextStyle(
                                                                color: pickTextColorBasedOnBgColorAdvanced(Thm
                                                                        .isDarktheme(
                                                                            widget.prefs)
                                                                    ? fiberchatDIALOGColorDarkMode
                                                                    : fiberchatDIALOGColorLightMode)),
                                                          ),
                                                        ),
                                                        PopupMenuItem<String>(
                                                          value: isListUserOnlyUser ==
                                                                  true
                                                              ? 'Set as Admin'
                                                              : 'Remove as Admin',
                                                          child: Text(
                                                            isListUserOnlyUser ==
                                                                    true
                                                                ? '${getTranslated(context, 'setasadmin')}'
                                                                : '${getTranslated(context, 'removeasadmin')}',
                                                            style: TextStyle(
                                                                color: pickTextColorBasedOnBgColorAdvanced(Thm
                                                                        .isDarktheme(
                                                                            widget.prefs)
                                                                    ? fiberchatDIALOGColorDarkMode
                                                                    : fiberchatDIALOGColorLightMode)),
                                                          ),
                                                        ),
                                                      ],
                                              onSelected: (String value) async {
                                                await availableContacts
                                                    .fetchFromFiretsoreAndReturnData(
                                                        widget.prefs,
                                                        snapshot.data!.id,
                                                        (doc) {
                                                  userAction(
                                                      value,
                                                      viewerslist[i],
                                                      islisttUserAdmin,
                                                      doc[Dbkeys
                                                              .notificationTokens] ??
                                                          []);
                                                });
                                              },
                                              child: Icon(
                                                Icons.more_vert_outlined,
                                                size: 20,
                                                color: fiberchatGrey,
                                              ))
                                      : null,
                                ),
                                isThreeLine: false,
                                contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                leading: Padding(
                                  padding: const EdgeInsets.only(left: 5),
                                  child: Padding(
                                    padding: const EdgeInsets.all(0.0),
                                    child: customCircleAvatar(
                                        url: snapshot.data!.photoURL,
                                        radius: 22),
                                  ),
                                ),
                                title: Text(
                                  availableContacts
                                              .contactsBookContactList!.entries
                                              .toList()
                                              .indexWhere((element) =>
                                                  element.key ==
                                                  viewerslist[i]) >
                                          0
                                      ? availableContacts
                                          .contactsBookContactList!.entries
                                          .elementAt(availableContacts
                                              .contactsBookContactList!.entries
                                              .toList()
                                              .indexWhere((element) =>
                                                  element.key ==
                                                  viewerslist[i]))
                                          .value
                                          .toString()
                                      : snapshot.data!.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      color: pickTextColorBasedOnBgColorAdvanced(Thm
                                              .isDarktheme(widget.prefs)
                                          ? fiberchatCONTAINERboxColorDarkMode
                                          : fiberchatCONTAINERboxColorLightMode)),
                                ),
                                subtitle: Text(
                                  //-- or about me
                                  snapshot.data!.id,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      height: 1.4, color: fiberchatGrey),
                                ),
                                onTap: widget.currentUserno == snapshot.data!.id
                                    ? () {}
                                    : () async {
                                        await availableContacts
                                            .fetchFromFiretsoreAndReturnData(
                                                widget.prefs, snapshot.data!.id,
                                                (doc) {
                                          Navigator.push(
                                              context,
                                              new MaterialPageRoute(
                                                  builder: (context) =>
                                                      new ProfileView(
                                                        doc.data()!,
                                                        widget.currentUserno,
                                                        widget.model,
                                                        widget.prefs,
                                                        [],
                                                      )));
                                        });
                                      },
                                enabled: true,
                              ),
                            ],
                          ),
                        ],
                      );
                    }
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Divider(
                          height: 3,
                        ),
                        Stack(
                          children: [
                            ListTile(
                              isThreeLine: false,
                              contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                              leading: Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Padding(
                                    padding: const EdgeInsets.all(0.0),
                                    child: customCircleAvatar(radius: 22)),
                              ),
                              title: Text(
                                availableContacts
                                            .contactsBookContactList!.entries
                                            .toList()
                                            .indexWhere((element) =>
                                                element.key == viewerslist[i]) >
                                        0
                                    ? availableContacts
                                        .contactsBookContactList!.entries
                                        .elementAt(availableContacts
                                            .contactsBookContactList!.entries
                                            .toList()
                                            .indexWhere((element) =>
                                                element.key == viewerslist[i]))
                                        .value
                                        .toString()
                                    : viewerslist[i],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    color: pickTextColorBasedOnBgColorAdvanced(Thm
                                            .isDarktheme(widget.prefs)
                                        ? fiberchatCONTAINERboxColorDarkMode
                                        : fiberchatCONTAINERboxColorLightMode)),
                              ),
                              subtitle: Text(
                                '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    height: 1.4, color: fiberchatGrey),
                              ),
                            ),
                            groupDoc[Dbkeys.groupADMINLIST]
                                    .contains(viewerslist[i])
                                ? Positioned(
                                    right: 27,
                                    top: 10,
                                    child: Container(
                                      padding: EdgeInsets.fromLTRB(4, 2, 4, 2),
                                      // width: 50.0,
                                      height: 18.0,
                                      decoration: new BoxDecoration(
                                        color: Thm.isDarktheme(widget.prefs)
                                            ? fiberchatCONTAINERboxColorDarkMode
                                            : fiberchatCONTAINERboxColorLightMode,
                                        border: new Border.all(
                                            color: fiberchatGreenColor400,
                                            width: 1.0),
                                        borderRadius:
                                            new BorderRadius.circular(5.0),
                                      ),
                                      child: new Center(
                                        child: new Text(
                                          getTranslated(context, 'admin'),
                                          style: new TextStyle(
                                            fontSize: 11.0,
                                            color: fiberchatGreenColor400,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : SizedBox(),
                          ],
                        ),
                      ],
                    );
                  });
            });
      });
    });
  }
}

formatDate(DateTime timeToFormat) {
  final DateFormat formatter = DateFormat('dd/MM/yyyy');
  final String formatted = formatter.format(timeToFormat);
  return formatted;
}
