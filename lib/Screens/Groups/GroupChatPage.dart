//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart' as emojipic;
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:fiberchat/Configs/Dbkeys.dart';
import 'package:fiberchat/Configs/Dbpaths.dart';
import 'package:fiberchat/Configs/Enum.dart';
import 'package:fiberchat/Configs/app_constants.dart';
import 'package:fiberchat/Configs/optional_constants.dart';
import 'package:fiberchat/Models/DataModel.dart';
import 'package:fiberchat/Models/E2EE/e2ee.dart' as e2ee;
import 'package:fiberchat/Screens/Groups/GroupDetails.dart';
import 'package:fiberchat/Screens/Groups/widget/groupChatBubble.dart';
import 'package:fiberchat/Screens/auth_screens/login.dart';
import 'package:fiberchat/Screens/call_history/callhistory.dart';
import 'package:fiberchat/Screens/calling_screen/pickup_layout.dart';
import 'package:fiberchat/Screens/chat_screen/chat.dart';
import 'package:fiberchat/Screens/chat_screen/utils/aes_encryption.dart';
import 'package:fiberchat/Screens/chat_screen/utils/photo_view.dart';
import 'package:fiberchat/Screens/chat_screen/utils/uploadMediaWithProgress.dart';
import 'package:fiberchat/Screens/contact_screens/ContactsSelect.dart';
import 'package:fiberchat/Screens/contact_screens/SelectContactsToForward.dart';
import 'package:fiberchat/Screens/privacypolicy&TnC/PdfViewFromCachedUrl.dart';
import 'package:fiberchat/Services/Admob/admob.dart';
import 'package:fiberchat/Services/Providers/GroupChatProvider.dart';
import 'package:fiberchat/Services/Providers/Observer.dart';
import 'package:fiberchat/Services/Providers/SmartContactProviderWithLocalStoreData.dart';
import 'package:fiberchat/Services/Providers/currentchat_peer.dart';
import 'package:fiberchat/Services/localization/language_constants.dart';
import 'package:fiberchat/Utils/chat_controller.dart';
import 'package:fiberchat/Utils/color_detector.dart';
import 'package:fiberchat/Utils/custom_url_launcher.dart';
import 'package:fiberchat/Utils/emoji_detect.dart';
import 'package:fiberchat/Utils/mime_type.dart';
import 'package:fiberchat/Utils/save.dart';
import 'package:fiberchat/Utils/setStatusBarColor.dart';
import 'package:fiberchat/Utils/theme_management.dart';
import 'package:fiberchat/Utils/unawaited.dart';
import 'package:fiberchat/Utils/utils.dart';
import 'package:fiberchat/widgets/AudioRecorder/Audiorecord.dart';
import 'package:fiberchat/widgets/CameraGalleryImagePicker/multiMediaPicker.dart';
import 'package:fiberchat/widgets/DownloadManager/download_all_file_type.dart';
import 'package:fiberchat/widgets/InfiniteList/InfiniteCOLLECTIONListViewWidget.dart';
import 'package:fiberchat/widgets/MultiDocumentPicker/multiDocumentPicker.dart';
import 'package:fiberchat/widgets/MultiImagePicker/multiImagePicker.dart';
import 'package:fiberchat/widgets/MyElevatedButton/MyElevatedButton.dart';
import 'package:fiberchat/widgets/SoundPlayer/SoundPlayerPro.dart';
import 'package:fiberchat/widgets/VideoEditor/video_editor.dart';
import 'package:fiberchat/widgets/VideoPicker/VideoPreview.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:giphy_get/giphy_get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
//import 'package:link_preview_generator/link_preview_generator.dart';
import 'package:media_info/media_info.dart';
import 'package:path/path.dart' as p;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_compress/video_compress.dart' as compress;
import 'package:video_thumbnail/video_thumbnail.dart';

class GroupChatPage extends StatefulWidget {
  final String currentUserno;
  final String groupID;
  final int joinedTime;
  final DataModel model;
  final SharedPreferences prefs;
  final List<SharedMediaFile>? sharedFiles;
  final MessageType? sharedFilestype;
  final bool isSharingIntentForwarded;
  final String? sharedText;
  final bool isCurrentUserMuted;
  GroupChatPage({
    Key? key,
    required this.currentUserno,
    required this.groupID,
    required this.joinedTime,
    required this.model,
    required this.prefs,
    required this.isSharingIntentForwarded,
    required this.isCurrentUserMuted,
    this.sharedFiles,
    this.sharedFilestype,
    this.sharedText,
  }) : super(key: key);

  @override
  _GroupChatPageState createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage>
    with WidgetsBindingObserver {
  bool isgeneratingSomethingLoader = false;
  // int tempSendIndex = 0;
  late String messageReplyOwnerName;
  late Stream<QuerySnapshot> groupChatMessages;
  final TextEditingController reportEditingController =
      new TextEditingController();
  late Query firestoreChatquery;
  GlobalKey<ScaffoldState> _scaffold = new GlobalKey<ScaffoldState>();
  GlobalKey<State> _keyLoader =
      new GlobalKey<State>(debugLabel: 'qqqeqeqsssaadqeqe');
  final ScrollController realtime = new ScrollController();
  Map<String, dynamic>? replyDoc;
  bool isReplyKeyboard = false;
  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;
  RewardedAd? _rewardedAd;
  int _numRewardedLoadAttempts = 0;
  bool isCurrentUserMuted = false;
  @override
  void initState() {
    super.initState();
    isCurrentUserMuted = widget.isCurrentUserMuted;
    firestoreChatquery = FirebaseFirestore.instance
        .collection(DbPaths.collectiongroups)
        .doc(widget.groupID)
        .collection(DbPaths.collectiongroupChats)
        .where(Dbkeys.groupmsgTIME, isGreaterThanOrEqualTo: widget.joinedTime)
        .orderBy(Dbkeys.groupmsgTIME, descending: true)
        .limit(maxChatMessageDocsLoadAtOnceForGroupChatAndBroadcastLazyLoading);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      var currentpeer =
          Provider.of<CurrentChatPeer>(this.context, listen: false);
      var firestoreProvider =
          Provider.of<FirestoreDataProviderMESSAGESforGROUPCHAT>(this.context,
              listen: false);
      final observer = Provider.of<Observer>(this.context, listen: false);
      firestoreProvider.reset();
      Future.delayed(const Duration(milliseconds: 1700), () {
        loadMessagesAndListen();

        currentpeer.setpeer(
            newgroupChatId: widget.groupID
                .replaceAll(RegExp('-'), '')
                .substring(
                    1,
                    widget.groupID
                        .replaceAll(RegExp('-'), '')
                        .toString()
                        .length));

        Future.delayed(const Duration(milliseconds: 3000), () {
          if (IsVideoAdShow == true && observer.isadmobshow == true) {
            _createRewardedAd();
          }

          if (IsInterstitialAdShow == true && observer.isadmobshow == true) {
            _createInterstitialAd();
          }
        });
      });
    });
    setStatusBarColor(widget.prefs);
  }

  // ignore: cancel_subscriptions
  StreamSubscription<QuerySnapshot>? subscription;
  loadMessagesAndListen() async {
    subscription = firestoreChatquery.snapshots().listen((snapshot) {
      snapshot.docChanges.forEach((change) {
        if (change.type == DocumentChangeType.added) {
          var chatprovider =
              Provider.of<FirestoreDataProviderMESSAGESforGROUPCHAT>(
                  this.context,
                  listen: false);
          DocumentSnapshot newDoc = change.doc;
          // if (chatprovider.datalistSnapshot.length == 0) {
          // } else if ((chatprovider.checkIfDocAlreadyExits(
          //       newDoc: newDoc,
          //     ) ==
          //     false)) {

          // if (newDoc[Dbkeys.groupmsgSENDBY] != widget.currentUserno) {
          chatprovider.addDoc(newDoc);
          // unawaited(realtime.animateTo(0.0,
          //     duration: Duration(milliseconds: 300), curve: Curves.easeOut));
          // }
          // }
        } else if (change.type == DocumentChangeType.modified) {
          var chatprovider =
              Provider.of<FirestoreDataProviderMESSAGESforGROUPCHAT>(
                  this.context,
                  listen: false);
          DocumentSnapshot updatedDoc = change.doc;
          if (chatprovider.checkIfDocAlreadyExits(
                  newDoc: updatedDoc,
                  timestamp: updatedDoc[Dbkeys.timestamp]) ==
              true) {
            chatprovider.updateparticulardocinProvider(updatedDoc: updatedDoc);
          }
        } else if (change.type == DocumentChangeType.removed) {
          var chatprovider =
              Provider.of<FirestoreDataProviderMESSAGESforGROUPCHAT>(
                  this.context,
                  listen: false);
          DocumentSnapshot deletedDoc = change.doc;
          if (chatprovider.checkIfDocAlreadyExits(
                  newDoc: deletedDoc,
                  timestamp: deletedDoc[Dbkeys.groupmsgTIME]) ==
              true) {
            chatprovider.deleteparticulardocinProvider(deletedDoc: deletedDoc);
          }
        }
      });
    });

    setStateIfMounted(() {});

//       //----sharing intent action:
    if (widget.isSharingIntentForwarded == true) {
      if (widget.sharedText != null) {
        onSendMessage(
            context: this.context,
            content: widget.sharedText!,
            type: MessageType.text,
            timestamp: DateTime.now().millisecondsSinceEpoch);
      } else if (widget.sharedFiles != null) {
        setStateIfMounted(() {
          isgeneratingSomethingLoader = true;
        });
        uploadEach(0);
      }
    }
  }

  int currentUploadingIndex = 0;

  uploadEach(
    int index,
  ) async {
    File file = new File(widget.sharedFiles![index].path);
    String fileName = file.path.split('/').last.toLowerCase();

    if (index >= widget.sharedFiles!.length) {
      setStateIfMounted(() {
        isgeneratingSomethingLoader = false;
      });
    } else {
      int messagetime = DateTime.now().millisecondsSinceEpoch;
      setState(() {
        currentUploadingIndex = index;
      });
      await getFileData(File(widget.sharedFiles![index].path),
              timestamp: messagetime, totalFiles: widget.sharedFiles!.length)
          .then((imageUrl) async {
        if (imageUrl != null) {
          MessageType type = fileName.contains('.png') ||
                  fileName.contains('.gif') ||
                  fileName.contains('.jpg') ||
                  fileName.contains('.jpeg') ||
                  fileName.contains('giphy')
              ? MessageType.image
              : fileName.contains('.mp4') || fileName.contains('.mov')
                  ? MessageType.video
                  : fileName.contains('.mp3') || fileName.contains('.aac')
                      ? MessageType.audio
                      : MessageType.doc;
          String? thumbnailurl;
          if (type == MessageType.video) {
            thumbnailurl = await getThumbnail(imageUrl);
            debugPrint('THUMNBNAIL URL::::: ' + thumbnailurl!);
            setStateIfMounted(() {});
          }

          String finalUrl = fileName.contains('.png') ||
                  fileName.contains('.gif') ||
                  fileName.contains('.jpg') ||
                  fileName.contains('.jpeg') ||
                  fileName.contains('giphy')
              ? imageUrl
              : fileName.contains('.mp4') || fileName.contains('.mov')
                  ? imageUrl +
                      '-BREAK-' +
                      thumbnailurl +
                      '-BREAK-' +
                      videometadata
                  : fileName.contains('.mp3') || fileName.contains('.aac')
                      ? imageUrl + '-BREAK-' + uploadTimestamp.toString()
                      : imageUrl +
                          '-BREAK-' +
                          basename(pickedFile!.path).toString();
          onSendMessage(
              context: this.context,
              content: finalUrl,
              type: type,
              timestamp: messagetime);
        }
      }).then((value) {
        if (widget.sharedFiles!.last == widget.sharedFiles![index]) {
          setStateIfMounted(() {
            isgeneratingSomethingLoader = false;
          });
        } else {
          uploadEach(currentUploadingIndex + 1);
        }
      });
    }
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  setLastSeen(bool iswillpop, isemojikeyboardopen) {
    FirebaseFirestore.instance
        .collection(DbPaths.collectiongroups)
        .doc(widget.groupID)
        .update(
      {
        widget.currentUserno: DateTime.now().millisecondsSinceEpoch,
      },
    );
    setStatusBarColor(widget.prefs);
    if (iswillpop == true && isemojikeyboardopen == false) {
      Navigator.of(this.context).pop();
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    setLastSeen(false, isemojiShowing);
    subscription!.cancel();
    if (IsInterstitialAdShow == true) {
      _interstitialAd!.dispose();
    }
    if (IsVideoAdShow == true) {
      _rewardedAd!.dispose();
    }
  }

  File? pickedFile;
  File? thumbnailFile;

  getFileData(File image, {int? timestamp, int? totalFiles}) {
    final observer = Provider.of<Observer>(this.context, listen: false);

    setStateIfMounted(() {
      pickedFile = image;
    });

    return observer.isPercentProgressShowWhileUploading
        ? (totalFiles == null
            ? uploadFileWithProgressIndicator(
                false,
                timestamp: timestamp,
              )
            : totalFiles == 1
                ? uploadFileWithProgressIndicator(
                    false,
                    timestamp: timestamp,
                  )
                : uploadFile(false, timestamp: timestamp))
        : uploadFile(false, timestamp: timestamp);
  }

  getFileName(groupid, timestamp) {
    return "${widget.currentUserno}-$timestamp";
  }

  getThumbnail(String url) async {
    final observer = Provider.of<Observer>(this.context, listen: false);
    setStateIfMounted(() {
      isgeneratingSomethingLoader = true;
    });
    String? path = await VideoThumbnail.thumbnailFile(
        video: url,
        thumbnailPath: (await getTemporaryDirectory()).path,
        imageFormat: ImageFormat.PNG,
        quality: 20);
    thumbnailFile = File(path!);
    setStateIfMounted(() {
      isgeneratingSomethingLoader = false;
    });
    return observer.isPercentProgressShowWhileUploading
        ? uploadFileWithProgressIndicator(true)
        : uploadFile(true);
  }

  String? videometadata;
  int? uploadTimestamp;
  int? thumnailtimestamp;
  Future uploadFile(bool isthumbnail, {int? timestamp}) async {
    uploadTimestamp = timestamp ?? DateTime.now().millisecondsSinceEpoch;
    String fileName = getFileName(
        widget.groupID,
        isthumbnail == false
            ? '$uploadTimestamp'
            : '${thumnailtimestamp}Thumbnail');
    Reference reference = FirebaseStorage.instance
        .ref("+00_GROUP_MEDIA/${widget.groupID}/")
        .child(fileName);
    TaskSnapshot uploading = await reference
        .putFile(isthumbnail == true ? thumbnailFile! : pickedFile!);
    if (isthumbnail == false) {
      setStateIfMounted(() {
        thumnailtimestamp = uploadTimestamp;
      });
    }
    if (isthumbnail == true) {
      MediaInfo _mediaInfo = MediaInfo();
      await _mediaInfo.getMediaInfo(thumbnailFile!.path).then((mediaInfo) {
        setStateIfMounted(() {
          videometadata = jsonEncode({
            "width": mediaInfo['width'],
            "height": mediaInfo['height'],
            "orientation": null,
            "duration": mediaInfo['durationMs'],
            "filesize": null,
            "author": null,
            "date": null,
            "framerate": null,
            "location": null,
            "path": null,
            "title": '',
            "mimetype": mediaInfo['mimeType'],
          }).toString();
        });
      }).catchError((onError) {
        Fiberchat.toast(getTranslated(this.context, 'failedsending'));
        debugPrint('ERROR SENDING MEDIA: $onError');
      });
    } else {
      FirebaseFirestore.instance
          .collection(DbPaths.collectionusers)
          .doc(widget.currentUserno)
          .set({
        Dbkeys.mssgSent: FieldValue.increment(1),
      }, SetOptions(merge: true));
      FirebaseFirestore.instance
          .collection(DbPaths.collectiondashboard)
          .doc(DbPaths.docchatdata)
          .set({
        Dbkeys.mediamessagessent: FieldValue.increment(1),
      }, SetOptions(merge: true));
    }
    return uploading.ref.getDownloadURL();
  }

  Future uploadFileWithProgressIndicator(
    bool isthumbnail, {
    int? timestamp,
  }) async {
    uploadTimestamp = timestamp ?? DateTime.now().millisecondsSinceEpoch;

    String fileName = getFileName(
        widget.currentUserno,
        isthumbnail == false
            ? '$uploadTimestamp'
            : '${thumnailtimestamp}Thumbnail');
    Reference reference = FirebaseStorage.instance
        .ref("+00_GROUP_MEDIA/${widget.groupID}/")
        .child(fileName);

    File fileToCompress;
    File? compressedImage;

    if (isthumbnail == false && isVideo(pickedFile!.path) == true) {
      fileToCompress = File(pickedFile!.path);
      await compress.VideoCompress.setLogLevel(0);

      final compress.MediaInfo? info =
          await compress.VideoCompress.compressVideo(
        fileToCompress.path,
        quality: IsVideoQualityCompress == true
            ? compress.VideoQuality.MediumQuality
            : compress.VideoQuality.HighestQuality,
        deleteOrigin: false,
        includeAudio: true,
      );
      pickedFile = File(info!.path!);
    } else if (isthumbnail == false && isImage(pickedFile!.path) == true) {
      final targetPath = pickedFile!.absolute.path
              .replaceAll(basename(pickedFile!.absolute.path), "") +
          "temp.jpg";
//change done
      XFile? compressedGetFile = await FlutterImageCompress.compressAndGetFile(
        pickedFile!.absolute.path,
        targetPath,
        quality: ImageQualityCompress,
        rotate: 0,
      );
      //change done
      compressedImage = File(compressedGetFile!.path);
      // compressedImage = await FlutterImageCompress.compressAndGetFile(
      //   pickedFile!.absolute.path,
      //   targetPath,
      //   quality: ImageQualityCompress,
      //   rotate: 0,
      // );
    } else {}

    UploadTask uploading = reference.putFile(isthumbnail == true
        ? thumbnailFile!
        : isImage(pickedFile!.path) == true
            ? compressedImage!
            : pickedFile!);

    showDialog<void>(
        context: this.context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new WillPopScope(
              onWillPop: () async => false,
              child: SimpleDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7),
                  ),
                  key: _keyLoader,
                  backgroundColor: Thm.isDarktheme(widget.prefs)
                      ? fiberchatDIALOGColorDarkMode
                      : fiberchatDIALOGColorLightMode,
                  children: <Widget>[
                    Center(
                      child: StreamBuilder(
                          stream: uploading.snapshotEvents,
                          builder: (BuildContext context, snapshot) {
                            if (snapshot.hasData) {
                              final TaskSnapshot snap = uploading.snapshot;

                              return openUploadDialog(
                                prefs: widget.prefs,
                                context: context,
                                percent: bytesTransferred(snap) / 100,
                                title: isthumbnail == true
                                    ? getTranslated(
                                        context, 'generatingthumbnail')
                                    : getTranslated(context, 'sending'),
                                subtitle:
                                    "${((((snap.bytesTransferred / 1024) / 1000) * 100).roundToDouble()) / 100}/${((((snap.totalBytes / 1024) / 1000) * 100).roundToDouble()) / 100} MB",
                              );
                            } else {
                              return openUploadDialog(
                                prefs: widget.prefs,
                                context: context,
                                percent: 0.0,
                                title: isthumbnail == true
                                    ? getTranslated(
                                        context, 'generatingthumbnail')
                                    : getTranslated(context, 'sending'),
                                subtitle: '',
                              );
                            }
                          }),
                    ),
                  ]));
        });

    TaskSnapshot downloadTask = await uploading;
    String downloadedurl = await downloadTask.ref.getDownloadURL();

    if (isthumbnail == false) {
      setStateIfMounted(() {
        thumnailtimestamp = uploadTimestamp;
      });
    }
    if (isthumbnail == true) {
      MediaInfo _mediaInfo = MediaInfo();

      await _mediaInfo.getMediaInfo(thumbnailFile!.path).then((mediaInfo) {
        setStateIfMounted(() {
          videometadata = jsonEncode({
            "width": mediaInfo['width'],
            "height": mediaInfo['height'],
            "orientation": null,
            "duration": mediaInfo['durationMs'],
            "filesize": null,
            "author": null,
            "date": null,
            "framerate": null,
            "location": null,
            "path": null,
            "title": '',
            "mimetype": mediaInfo['mimeType'],
          }).toString();
        });
      }).catchError((onError) {
        Fiberchat.toast(getTranslated(this.context, 'failedsending'));
        debugPrint('ERROR SENDING FILE: $onError');
      });
    } else {
      FirebaseFirestore.instance
          .collection(DbPaths.collectionusers)
          .doc(widget.currentUserno)
          .set({
        Dbkeys.mssgSent: FieldValue.increment(1),
      }, SetOptions(merge: true));
      FirebaseFirestore.instance
          .collection(DbPaths.collectiondashboard)
          .doc(DbPaths.docchatdata)
          .set({
        Dbkeys.mediamessagessent: FieldValue.increment(1),
      }, SetOptions(merge: true));
    }
    Navigator.of(_keyLoader.currentContext!, rootNavigator: true).pop(); //
    return downloadedurl;
  }

  Future uploadSelectedLocalFileWithProgressIndicator(
      File selectedFile, bool isVideo, bool isthumbnail, int timeEpoch,
      {String? filenameoptional}) async {
    String ext = p.extension(selectedFile.path);
    String fileName = filenameoptional != null
        ? filenameoptional
        : isthumbnail == true
            ? 'Thumbnail-$timeEpoch$ext'
            : isVideo
                ? 'Video-$timeEpoch$ext'
                : 'IMG-$timeEpoch$ext';
    // String fileName = getFileName(widget.currentUserno,
    //     isthumbnail == false ? '$timeEpoch' : '${timeEpoch}Thumbnail');
    Reference reference = FirebaseStorage.instance
        .ref("+00_GROUP_MEDIA/${widget.groupID}/")
        .child(fileName);

    UploadTask uploading = reference.putFile(selectedFile);

    showDialog<void>(
        context: this.context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new WillPopScope(
              onWillPop: () async => false,
              child: SimpleDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7),
                  ),
                  key: _keyLoader,
                  backgroundColor: Thm.isDarktheme(widget.prefs)
                      ? fiberchatDIALOGColorDarkMode
                      : fiberchatDIALOGColorLightMode,
                  children: <Widget>[
                    Center(
                      child: StreamBuilder(
                          stream: uploading.snapshotEvents,
                          builder: (BuildContext context, snapshot) {
                            if (snapshot.hasData) {
                              final TaskSnapshot snap = uploading.snapshot;

                              return openUploadDialog(
                                prefs: widget.prefs,
                                context: context,
                                percent: bytesTransferred(snap) / 100,
                                title: isthumbnail == true
                                    ? getTranslated(
                                        context, 'generatingthumbnail')
                                    : getTranslated(context, 'sending'),
                                subtitle:
                                    "${((((snap.bytesTransferred / 1024) / 1000) * 100).roundToDouble()) / 100}/${((((snap.totalBytes / 1024) / 1000) * 100).roundToDouble()) / 100} MB",
                              );
                            } else {
                              return openUploadDialog(
                                prefs: widget.prefs,
                                context: context,
                                percent: 0.0,
                                title: isthumbnail == true
                                    ? getTranslated(
                                        context, 'generatingthumbnail')
                                    : getTranslated(context, 'sending'),
                                subtitle: '',
                              );
                            }
                          }),
                    ),
                  ]));
        });

    TaskSnapshot downloadTask = await uploading;
    String downloadedurl = await downloadTask.ref.getDownloadURL();

    if (isthumbnail == true) {
      MediaInfo _mediaInfo = MediaInfo();

      await _mediaInfo.getMediaInfo(selectedFile.path).then((mediaInfo) {
        setStateIfMounted(() {
          videometadata = jsonEncode({
            "width": mediaInfo['width'],
            "height": mediaInfo['height'],
            "orientation": null,
            "duration": mediaInfo['durationMs'],
            "filesize": null,
            "author": null,
            "date": null,
            "framerate": null,
            "location": null,
            "path": null,
            "title": '',
            "mimetype": mediaInfo['mimeType'],
          }).toString();
        });
      }).catchError((onError) {
        Fiberchat.toast(getTranslated(this.context, 'failedsending'));
        debugPrint('ERROR SENDING FILE: $onError');
      });
    } else {
      FirebaseFirestore.instance
          .collection(DbPaths.collectionusers)
          .doc(widget.currentUserno)
          .set({
        Dbkeys.mssgSent: FieldValue.increment(1),
      }, SetOptions(merge: true));
      FirebaseFirestore.instance
          .collection(DbPaths.collectiondashboard)
          .doc(DbPaths.docchatdata)
          .set({
        Dbkeys.mediamessagessent: FieldValue.increment(1),
      }, SetOptions(merge: true));
    }
    Navigator.of(_keyLoader.currentContext!, rootNavigator: true).pop(); //
    return downloadedurl;
  }

  void onSendMessage(
      {required BuildContext context,
      required String content,
      required MessageType type,
      int? timestamp,
      bool? isForward = false}) async {
    final observer = Provider.of<Observer>(this.context, listen: false);
    final List<GroupModel> groupList =
        Provider.of<List<GroupModel>>(context, listen: false);
    // var chatprovider = Provider.of<FirestoreDataProviderMESSAGESforGROUPCHAT>(
    //     this.context,
    //     listen: false);
    Map<dynamic, dynamic> groupDoc = groupList.indexWhere(
                (element) => element.docmap[Dbkeys.groupID] == widget.groupID) <
            0
        ? {}
        : groupList
            .lastWhere(
                (element) => element.docmap[Dbkeys.groupID] == widget.groupID)
            .docmap;
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    if (content.trim() != '') {
      content = content.trim();
      textEditingController.clear();
      FirebaseFirestore.instance
          .collection(DbPaths.collectiongroups)
          .doc(widget.groupID)
          .collection(DbPaths.collectiongroupChats)
          .doc(timestamp.toString() + '--' + widget.currentUserno)
          .set({
        Dbkeys.groupmsgCONTENT: content,
        Dbkeys.groupmsgISDELETED: false,
        Dbkeys.groupmsgLISToptional: [],
        Dbkeys.groupmsgTIME: timestamp,
        Dbkeys.groupmsgSENDBY: widget.currentUserno,
        Dbkeys.groupmsgISDELETED: false,
        Dbkeys.groupmsgTYPE: type.index,
        Dbkeys.groupNAME: groupDoc[Dbkeys.groupNAME],
        Dbkeys.groupID: groupDoc[Dbkeys.groupNAME],
        Dbkeys.sendername: widget.model.currentUser![Dbkeys.nickname],
        Dbkeys.groupIDfiltered: groupDoc[Dbkeys.groupIDfiltered],
        Dbkeys.isReply: isReplyKeyboard,
        Dbkeys.replyToMsgDoc: replyDoc,
        Dbkeys.isForward: isForward
      }, SetOptions(merge: true));

      unawaited(realtime.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut));
      // _playPopSound();
      FirebaseFirestore.instance
          .collection(DbPaths.collectiongroups)
          .doc(widget.groupID)
          .update(
        {Dbkeys.groupLATESTMESSAGETIME: timestamp},
      );
      setStateIfMounted(() {
        isReplyKeyboard = false;
        replyDoc = null;
      });
      setStatusBarColor(widget.prefs);
      unawaited(realtime.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut));
      if (type == MessageType.doc ||
          type == MessageType.audio ||
          // (type == MessageType.image && !content.contains('giphy')) ||
          type == MessageType.location ||
          type == MessageType.contact &&
              widget.isSharingIntentForwarded == false) {
        if (IsVideoAdShow == true &&
            observer.isadmobshow == true &&
            IsInterstitialAdShow == false) {
          Future.delayed(const Duration(milliseconds: 800), () {
            _showRewardedAd();
          });
        } else if (IsInterstitialAdShow == true &&
            observer.isadmobshow == true) {
          _showInterstitialAd();
        }
      } else if (type == MessageType.video) {
        if (IsVideoAdShow == true && observer.isadmobshow == true) {
          Future.delayed(const Duration(milliseconds: 800), () {
            _showRewardedAd();
          });
        }
      }
    }
  }

  void _createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: getInterstitialAdUnitId()!,
        request: AdRequest(
          nonPersonalizedAds: true,
        ),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            debugPrint('$ad loaded');
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
            _interstitialAd!.setImmersiveMode(true);
          },
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('InterstitialAd failed to load: $error.');
            _numInterstitialLoadAttempts += 1;
            _interstitialAd = null;
            if (_numInterstitialLoadAttempts <= maxAdFailedLoadAttempts) {
              _createInterstitialAd();
            }
          },
        ));
  }

  void _showInterstitialAd() {
    if (_interstitialAd == null) {
      debugPrint('Warning: attempt to show interstitial before loaded.');
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          debugPrint('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        debugPrint('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        debugPrint('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createInterstitialAd();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }

  void _createRewardedAd() {
    RewardedAd.load(
        adUnitId: getRewardBasedVideoAdUnitId()!,
        request: AdRequest(
          nonPersonalizedAds: true,
        ),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            debugPrint('$ad loaded.');
            _rewardedAd = ad;
            _numRewardedLoadAttempts = 0;
          },
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('RewardedAd failed to load: $error');
            _rewardedAd = null;
            _numRewardedLoadAttempts += 1;
            if (_numRewardedLoadAttempts <= maxAdFailedLoadAttempts) {
              _createRewardedAd();
            }
          },
        ));
  }

  void _showRewardedAd() {
    if (_rewardedAd == null) {
      debugPrint('Warning: attempt to show rewarded before loaded.');
      return;
    }
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) =>
          debugPrint('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        debugPrint('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        debugPrint('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createRewardedAd();
      },
    );

    _rewardedAd!.setImmersiveMode(true);
    _rewardedAd!.show(onUserEarnedReward: (a, b) {});
    _rewardedAd = null;
  }

  _onEmojiSelected(Emoji emoji) {
    textEditingController
      ..text += emoji.emoji
      ..selection = TextSelection.fromPosition(
          TextPosition(offset: textEditingController.text.length));
    setStateIfMounted(() {});
    if (textEditingController.text.isNotEmpty &&
        textEditingController.text.length == 1) {
      setStateIfMounted(() {});
    }
    if (textEditingController.text.isEmpty) {
      setStateIfMounted(() {});
    }
  }

  _onBackspacePressed() {
    textEditingController
      ..text = textEditingController.text.characters.skipLast(1).toString()
      ..selection = TextSelection.fromPosition(
          TextPosition(offset: textEditingController.text.length));
    if (textEditingController.text.isNotEmpty &&
        textEditingController.text.length == 1) {
      setStateIfMounted(() {});
    }
    if (textEditingController.text.isEmpty) {
      setStateIfMounted(() {});
    }
  }

  final TextEditingController textEditingController =
      new TextEditingController();
  FocusNode keyboardFocusNode = new FocusNode();
  Widget buildInputAndroid(BuildContext context, bool isemojiShowing,
      Function refreshThisInput, bool keyboardVisible) {
    final observer = Provider.of<Observer>(context, listen: true);

    return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          isReplyKeyboard == true
              ? buildReplyMessageForInput(
                  context,
                )
              : SizedBox(),
          Container(
            margin: EdgeInsets.only(bottom: Platform.isIOS == true ? 20 : 0),
            child: Row(
              children: <Widget>[
                Flexible(
                  child: Container(
                    margin: EdgeInsets.only(
                      left: 10,
                    ),
                    decoration: BoxDecoration(
                        color: fiberchatWhite,
                        borderRadius: BorderRadius.all(Radius.circular(30))),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 40,
                          child: IconButton(
                            onPressed: () {
                              refreshThisInput();
                            },
                            icon: Icon(Icons.emoji_emotions,
                                color: fiberchatGrey, size: 23),
                          ),
                        ),
                        Flexible(
                          child: TextField(
                            onTap: () {
                              if (isemojiShowing == true) {
                              } else {
                                keyboardFocusNode.requestFocus();
                                setStateIfMounted(() {});
                              }
                            },
                            onChanged: (f) {
                              if (textEditingController.text.isNotEmpty &&
                                  textEditingController.text.length == 1) {
                                setStateIfMounted(() {});
                              }
                              setStateIfMounted(() {});
                            },
                            showCursor: true,
                            focusNode: keyboardFocusNode,
                            maxLines: null,
                            textCapitalization: TextCapitalization.sentences,
                            style: TextStyle(
                                fontSize: 16.0, color: fiberchatBlack),
                            controller: textEditingController,
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                // width: 0.0 produces a thin "hairline" border
                                borderRadius: BorderRadius.circular(1),
                                borderSide: BorderSide(
                                    color: Colors.transparent, width: 1.5),
                              ),
                              hoverColor: Colors.transparent,
                              focusedBorder: OutlineInputBorder(
                                // width: 0.0 produces a thin "hairline" border
                                borderRadius: BorderRadius.circular(1),
                                borderSide: BorderSide(
                                    color: Colors.transparent, width: 1.5),
                              ),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(1),
                                  borderSide:
                                      BorderSide(color: Colors.transparent)),
                              contentPadding: EdgeInsets.fromLTRB(10, 4, 7, 4),
                              hintText: getTranslated(this.context, 'msg'),
                              hintStyle:
                                  TextStyle(color: Colors.grey, fontSize: 15),
                            ),
                          ),
                        ),
                        Container(
                            margin: EdgeInsets.fromLTRB(0, 0, 5, 0),
                            width: textEditingController.text.isNotEmpty
                                ? 10
                                : IsShowGIFsenderButtonByGIPHY == false
                                    ? 45 //changed by JH
                                    : 120,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                textEditingController.text.isNotEmpty
                                    ? SizedBox()
                                    : SizedBox(
                                        width: 30,
                                        child: IconButton(
                                          icon: new Icon(
                                            Icons.attachment_outlined,
                                            color: fiberchatGrey,
                                          ),
                                          padding: EdgeInsets.all(0.0),
                                          onPressed:
                                              observer.ismediamessagingallowed ==
                                                      false
                                                  ? () {
                                                      Fiberchat.showRationale(
                                                          getTranslated(
                                                              this.context,
                                                              'mediamssgnotallowed'));
                                                    }
                                                  : () {
                                                      hidekeyboard(context);
                                                      shareMedia(context);
                                                    },
                                          color: fiberchatWhite,
                                        ),
                                      ),
                                textEditingController.text.isNotEmpty
                                    ? SizedBox()
                                    : SizedBox(), //deleted by JH
                                textEditingController.text.length != 0 ||
                                        IsShowGIFsenderButtonByGIPHY == false
                                    ? SizedBox(
                                        width: 0,
                                      )
                                    : Container(
                                        margin: EdgeInsets.only(bottom: 5),
                                        height: 35,
                                        alignment: Alignment.topLeft,
                                        width: 40,
                                        child: IconButton(
                                            color: fiberchatWhite,
                                            padding: EdgeInsets.all(0.0),
                                            icon: Icon(
                                              Icons.gif_rounded,
                                              size: 40,
                                              color: fiberchatGrey,
                                            ),
                                            onPressed: observer
                                                        .ismediamessagingallowed ==
                                                    false
                                                ? () {
                                                    Fiberchat.showRationale(
                                                        getTranslated(
                                                            this.context,
                                                            'mediamssgnotallowed'));
                                                  }
                                                : () async {
                                                    GiphyGif? gif =
                                                        await GiphyGet.getGif(
                                                      tabColor:
                                                          fiberchatPRIMARYcolor,
                                                      context: context,
                                                      apiKey:
                                                          GiphyAPIKey, //YOUR API KEY HERE
                                                      lang:
                                                          GiphyLanguage.english,
                                                    );
                                                    if (gif != null &&
                                                        mounted) {
                                                      onSendMessage(
                                                        context: context,
                                                        content: gif.images!
                                                            .original!.url,
                                                        type: MessageType.image,
                                                      );
                                                      hidekeyboard(context);
                                                      setStateIfMounted(() {});
                                                    }
                                                  }),
                                      ),
                              ],
                            ))
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 47,
                  width: 47,
                  // alignment: Alignment.center,
                  margin: EdgeInsets.only(left: 6, right: 10),
                  decoration: BoxDecoration(
                      color: fiberchatSECONDARYolor,
                      borderRadius: BorderRadius.all(Radius.circular(30))),
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: IconButton(
                      icon: textInSendButton == ""
                          ? new Icon(
                              textEditingController.text.length == 0
                                  ? Icons.camera_alt_rounded
                                  : Icons.send,
                              color: fiberchatWhite.withOpacity(0.99),
                            )
                          : textEditingController.text.length == 0
                              ? new Icon(
                                  Icons.camera_alt_rounded,
                                  color: fiberchatWhite.withOpacity(0.99),
                                )
                              : Text(
                                  textInSendButton,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: textInSendButton.length > 2
                                          ? 10.7
                                          : 17.5),
                                ),
                      onPressed: observer.ismediamessagingallowed == true
                          ? textEditingController.text.isNotEmpty == false
                              ? () async {
                                  hidekeyboard(context);

                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              MultiImagePicker(
                                                title: getTranslated(
                                                    this.context, 'pickimage'),
                                                prefs: widget.prefs,
                                                callback: getFileData,
                                                writeMessage: (String? url,
                                                    int time) async {
                                                  if (url != null) {
                                                    onSendMessage(
                                                        context: this.context,
                                                        content: url,
                                                        type:
                                                            MessageType.image);
                                                  }
                                                },
                                              )));
                                }
                              : observer.istextmessagingallowed == false
                                  ? () {
                                      Fiberchat.showRationale(getTranslated(
                                          this.context, 'textmssgnotallowed'));
                                    }
                                  : () => onSendMessage(
                                        context: context,
                                        content: textEditingController
                                            .value.text
                                            .trim(),
                                        type: MessageType.text,
                                      )
                          : () {
                              Fiberchat.showRationale(getTranslated(
                                  this.context, 'mediamssgnotallowed'));
                            },
                      color: fiberchatWhite,
                    ),
                  ),
                ),
              ],
            ),
            width: double.infinity,
            height: 60.0,
            decoration: new BoxDecoration(
              // border: new Border(top: new BorderSide(color: Colors.grey, width: 0.5)),
              color: Colors.transparent,
            ),
          ),
          isemojiShowing == true && keyboardVisible == false
              ? Offstage(
                  offstage: !isemojiShowing,
                  child: SizedBox(
                    height: 300,
                    child: EmojiPicker(
                        onEmojiSelected:
                            (emojipic.Category? category, Emoji emoji) {
                          _onEmojiSelected(emoji);
                        },
                        onBackspacePressed: _onBackspacePressed,
                        //change done
                        config: Config(
                          searchViewConfig: SearchViewConfig(),
                          skinToneConfig: SkinToneConfig(
                            indicatorColor: fiberchatPRIMARYcolor,
                          ),
                          emojiViewConfig: EmojiViewConfig(
                              columns: 7,
                              emojiSizeMax: 32.0,
                              verticalSpacing: 0,
                              horizontalSpacing: 0,
                              recentsLimit: 28,
                              buttonMode: ButtonMode.MATERIAL),
                          categoryViewConfig: CategoryViewConfig(
                            initCategory: emojipic.Category.RECENT,
                            indicatorColor: fiberchatPRIMARYcolor,
                            iconColor: Colors.grey,
                            iconColorSelected: fiberchatPRIMARYcolor,
                            categoryIcons: CategoryIcons(),
                            backspaceColor: fiberchatPRIMARYcolor,
                          ),
                          bottomActionBarConfig: BottomActionBarConfig(
                              // bgColor: Color(0xFFF2F2F2),
                              //
                              //
                              // progressIndicatorColor: Colors.blue,
                              //
                              // showRecentsTab: true,
                              //
                              //
                              // buttonMode: ButtonMode.MATERIAL
                              ),
                        )

                        // config: Config(
                        //     columns: 7,
                        //     emojiSizeMax: 32.0,
                        //     verticalSpacing: 0,
                        //     horizontalSpacing: 0,
                        //     initCategory: emojipic.Category.RECENT,
                        //     bgColor: Color(0xFFF2F2F2),
                        //     indicatorColor: fiberchatPRIMARYcolor,
                        //     iconColor: Colors.grey,
                        //     iconColorSelected: fiberchatPRIMARYcolor,
                        //     progressIndicatorColor: Colors.blue,
                        //     backspaceColor: fiberchatPRIMARYcolor,
                        //     showRecentsTab: true,
                        //     recentsLimit: 28,
                        //     categoryIcons: CategoryIcons(),
                        //     buttonMode: ButtonMode.MATERIAL)
                        ),
                  ),
                )
              : SizedBox(),
        ]);
  }

  // Widget buildInputAndroid(
  //   BuildContext context,
  //   bool isemojiShowing,
  //   Function refreshThisInput,
  //   bool keyboardVisible,
  // ) {
  //   final observer = Provider.of<Observer>(context, listen: false);

  //   return Column(children: [
  //     Container(
  //       margin: EdgeInsets.only(bottom: Platform.isIOS == true ? 20 : 0),
  //       child: Row(
  //         children: <Widget>[
  //           Flexible(
  //             child: Container(
  //               margin: EdgeInsets.only(
  //                 left: 10,
  //               ),
  //               decoration: BoxDecoration(
  //                   color: fiberchatWhite,
  //                   borderRadius: BorderRadius.all(Radius.circular(30))),
  //               child: Row(
  //                 children: [
  //                   isemojiShowing == true && keyboardVisible == false
  //                       ? SizedBox(
  //                           width: 50,
  //                           child: IconButton(
  //                             onPressed: () {
  //                               refreshThisInput();
  //                             },
  //                             icon: Icon(
  //                               Icons.keyboard,
  //                               color: fiberchatGrey,
  //                             ),
  //                           ),
  //                         )
  //                       : SizedBox(
  //                           width: textEditingController.text.isNotEmpty
  //                               ? 50
  //                               : 110,
  //                           child: Row(
  //                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                             children: [
  //                               SizedBox(
  //                                 width: 30,
  //                                 child: IconButton(
  //                                   onPressed: () {
  //                                     refreshThisInput();
  //                                   },
  //                                   icon: Icon(
  //                                     Icons.emoji_emotions,
  //                                     color: fiberchatGrey,
  //                                   ),
  //                                 ),
  //                               ),
  //                               textEditingController.text.isNotEmpty == true
  //                                   ? SizedBox(
  //                                       width: 0,
  //                                     )
  //                                   : SizedBox(
  //                                       width: 50,
  //                                       child: IconButton(
  //                                           color: fiberchatWhite,
  //                                           padding: EdgeInsets.all(0.0),
  //                                           icon: Icon(
  //                                             Icons.gif,
  //                                             size: 40,
  //                                             color: fiberchatGrey,
  //                                           ),
  //                                           onPressed: observer
  //                                                       .ismediamessagingallowed ==
  //                                                   false
  //                                               ? () {
  //                                                   Fiberchat.showRationale(
  //                                                       getTranslated(
  //                                                           this.context,
  //                                                           'mediamssgnotallowed'));
  //                                                 }
  //                                               : () async {
  //                                                   GiphyGif? gif =
  //                                                       await GiphyGet.getGif(
  //                                                     tabColor: fiberchatgreen,
  //                                                     context: context,
  //                                                     apiKey:
  //                                                         GiphyAPIKey, //YOUR API KEY HERE
  //                                                     lang:
  //                                                         GiphyLanguage.english,
  //                                                   );
  //                                                   if (gif != null &&
  //                                                       mounted) {
  //                                                     onSendMessage(
  //                                                       context: context,
  //                                                       content: gif.images!
  //                                                           .original!.url,
  //                                                       type: MessageType.image,
  //                                                     );
  //                                                     hidekeyboard(context);
  //                                                     setStateIfMounted(() {});
  //                                                   }
  //                                                 }),
  //                                     ),
  //                               textEditingController.text.isNotEmpty == true
  //                                   ? SizedBox()
  //                                   : SizedBox(
  //                                       width: 30,
  //                                       child: IconButton(
  //                                         icon: new Icon(
  //                                           Icons.attachment_outlined,
  //                                           color: fiberchatGrey,
  //                                         ),
  //                                         padding: EdgeInsets.all(0.0),
  //                                         onPressed:
  //                                             observer.ismediamessagingallowed ==
  //                                                     false
  //                                                 ? () {
  //                                                     Fiberchat.showRationale(
  //                                                         getTranslated(
  //                                                             this.context,
  //                                                             'mediamssgnotallowed'));
  //                                                   }
  //                                                 : () {
  //                                                     hidekeyboard(context);
  //                                                     shareMedia(context);
  //                                                   },
  //                                         color: fiberchatWhite,
  //                                       ),
  //                                     )
  //                             ],
  //                           ),
  //                         ),
  //                   Flexible(
  //                     child: TextField(
  //                       textCapitalization: TextCapitalization.sentences,
  //                       onTap: () {
  //                         if (isemojiShowing == true) {
  //                         } else {
  //                           keyboardFocusNode.requestFocus();
  //                         }
  //                       },
  //                       onChanged: (f) {
  //                         if (textEditingController.text.isNotEmpty &&
  //                             textEditingController.text.length == 1) {
  //                           setStateIfMounted(() {});
  //                         }
  //                         if (textEditingController.text.isEmpty) {
  //                           setStateIfMounted(() {});
  //                         }
  //                       },
  //                       showCursor: true,
  //                       focusNode: keyboardFocusNode,
  //                       maxLines: null,
  //                       style: TextStyle(fontSize: 16.0, color: fiberchatBlack),
  //                       controller: textEditingController,
  //                       decoration: InputDecoration(
  //                         enabledBorder: OutlineInputBorder(
  //                           // width: 0.0 produces a thin "hairline" border
  //                           borderRadius: BorderRadius.circular(1),
  //                           borderSide: BorderSide(
  //                               color: Colors.transparent, width: 1.5),
  //                         ),
  //                         hoverColor: Colors.transparent,
  //                         focusedBorder: OutlineInputBorder(
  //                           // width: 0.0 produces a thin "hairline" border
  //                           borderRadius: BorderRadius.circular(1),
  //                           borderSide: BorderSide(
  //                               color: Colors.transparent, width: 1.5),
  //                         ),
  //                         border: OutlineInputBorder(
  //                             borderRadius: BorderRadius.circular(1),
  //                             borderSide:
  //                                 BorderSide(color: Colors.transparent)),
  //                         contentPadding: EdgeInsets.fromLTRB(10, 4, 7, 4),
  //                         hintText: getTranslated(this.context, 'msg'),
  //                         hintStyle:
  //                             TextStyle(color: Colors.grey, fontSize: 15),
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //           Container(
  //             height: 47,
  //             width: 47,
  //             // alignment: Alignment.center,
  //             margin: EdgeInsets.only(left: 6, right: 10),
  //             decoration: BoxDecoration(
  //                 color: DESIGN_TYPE == Themetype.whatsapp
  //                     ? fiberchatgreen
  //                     : fiberchatLightGreen,
  //                 // border: Border.all(
  //                 //   color: Colors.red[500],
  //                 // ),
  //                 borderRadius: BorderRadius.all(Radius.circular(30))),
  //             child: Padding(
  //               padding: const EdgeInsets.all(2.0),
  //               child: IconButton(
  //                 icon: new Icon(
  //                   textEditingController.text.isNotEmpty == true
  //                       ? Icons.send
  //                       : Icons.mic,
  //                   color: fiberchatWhite.withOpacity(0.99),
  //                 ),
  //                 onPressed: observer.ismediamessagingallowed == true
  //                     ? textEditingController.text.isNotEmpty == false
  //                         ? () {
  //                             hidekeyboard(context);

  //                             Navigator.push(
  //                                 context,
  //                                 MaterialPageRoute(
  //                                     builder: (context) => AudioRecord(
  //                                           title: getTranslated(
  //                                               this.context, 'record'),
  //                                           callback: getFileData,
  //                                         ))).then((url) {
  //                               if (url != null) {
  //                                 onSendMessage(
  //                                   context: context,
  //                                   content: url +
  //                                       '-BREAK-' +
  //                                       uploadTimestamp.toString(),
  //                                   type: MessageType.audio,
  //                                 );
  //                               } else {}
  //                             });
  //                           }
  //                         : observer.istextmessagingallowed == false
  //                             ? () {
  //                                 Fiberchat.showRationale(getTranslated(
  //                                     this.context, 'textmssgnotallowed'));
  //                               }
  //                             : () => onSendMessage(
  //                                   context: context,
  //                                   content:
  //                                       textEditingController.value.text.trim(),
  //                                   type: MessageType.text,
  //                                 )
  //                     : () {
  //                         Fiberchat.showRationale(getTranslated(
  //                             this.context, 'mediamssgnotallowed'));
  //                       },
  //                 color: fiberchatWhite,
  //               ),
  //             ),
  //           ),
  //           // Button send message
  //         ],
  //       ),
  //       width: double.infinity,
  //       height: 60.0,
  //       decoration: new BoxDecoration(
  //         // border: new Border(top: new BorderSide(color: Colors.grey, width: 0.5)),
  //         color: Colors.transparent,
  //       ),
  //     ),
  //     isemojiShowing == true && keyboardVisible == false
  //         ? Offstage(
  //             offstage: !isemojiShowing,
  //             child: SizedBox(
  //               height: 300,
  //               child: EmojiPicker(
  //                   onEmojiSelected: (emojipic.Category category, Emoji emoji) {
  //                     _onEmojiSelected(emoji);
  //                   },
  //                   onBackspacePressed: _onBackspacePressed,
  //                   config: Config(
  //                       columns: 7,
  //                       emojiSizeMax: 32.0,
  //                       verticalSpacing: 0,
  //                       horizontalSpacing: 0,
  //                       initCategory: emojipic.Category.RECENT,
  //                       bgColor: Color(0xFFF2F2F2),
  //                       indicatorColor: fiberchatgreen,
  //                       iconColor: Colors.grey,
  //                       iconColorSelected: fiberchatgreen,
  //                       progressIndicatorColor: Colors.blue,
  //                       backspaceColor: fiberchatgreen,
  //                       showRecentsTab: true,
  //                       recentsLimit: 28,
  //                       noRecentsText: 'No Recents',
  //                       noRecentsStyle:
  //                           TextStyle(fontSize: 20, color: Colors.black26),
  //                       categoryIcons: CategoryIcons(),
  //                       buttonMode: ButtonMode.MATERIAL)),
  //             ),
  //           )
  //         : SizedBox(),
  //   ]);
  // }

  // Widget buildInputIos(BuildContext context) {
  //   return Consumer<Observer>(
  //       builder: (context, observer, _child) => Container(
  //             margin: EdgeInsets.only(bottom: Platform.isIOS == true ? 20 : 0),
  //             child: Row(
  //               children: <Widget>[
  //                 Flexible(
  //                   child: Container(
  //                     margin: EdgeInsets.only(
  //                       left: 10,
  //                     ),
  //                     decoration: BoxDecoration(
  //                         color: fiberchatWhite,
  //                         borderRadius: BorderRadius.all(Radius.circular(30))),
  //                     child: Row(
  //                       children: [
  //                         SizedBox(
  //                           width: 100,
  //                           child: Row(
  //                             children: [
  //                               IconButton(
  //                                   color: fiberchatWhite,
  //                                   padding: EdgeInsets.all(0.0),
  //                                   icon: Icon(
  //                                     Icons.gif,
  //                                     size: 40,
  //                                     color: fiberchatGrey,
  //                                   ),
  //                                   onPressed: observer
  //                                               .ismediamessagingallowed ==
  //                                           false
  //                                       ? () {
  //                                           Fiberchat.showRationale(
  //                                               getTranslated(this.context,
  //                                                   'mediamssgnotallowed'));
  //                                         }
  //                                       : () async {
  //                                           GiphyGif? gif =
  //                                               await GiphyGet.getGif(
  //                                             tabColor: fiberchatgreen,
  //                                             context: context,
  //                                             apiKey:
  //                                                 GiphyAPIKey, //YOUR API KEY HERE
  //                                             lang: GiphyLanguage.english,
  //                                           );
  //                                           if (gif != null && mounted) {
  //                                             onSendMessage(
  //                                               context: context,
  //                                               content:
  //                                                   gif.images!.original!.url,
  //                                               type: MessageType.image,
  //                                             );
  //                                             hidekeyboard(context);
  //                                             setStateIfMounted(() {});
  //                                           }
  //                                         }),
  //                               IconButton(
  //                                 icon: new Icon(
  //                                   Icons.attachment_outlined,
  //                                   color: fiberchatGrey,
  //                                 ),
  //                                 padding: EdgeInsets.all(0.0),
  //                                 onPressed: observer.ismediamessagingallowed ==
  //                                         false
  //                                     ? () {
  //                                         Fiberchat.showRationale(getTranslated(
  //                                             this.context,
  //                                             'mediamssgnotallowed'));
  //                                       }
  //                                     : () {
  //                                         hidekeyboard(context);
  //                                         shareMedia(context);
  //                                       },
  //                                 color: fiberchatWhite,
  //                               ),
  //                             ],
  //                           ),
  //                         ),
  //                         Flexible(
  //                           child: TextField(
  //                             textCapitalization: TextCapitalization.sentences,
  //                             onChanged: (v) {},
  //                             maxLines: null,
  //                             style: TextStyle(
  //                                 fontSize: 18.0, color: fiberchatBlack),
  //                             controller: textEditingController,
  //                             decoration: InputDecoration(
  //                               enabledBorder: OutlineInputBorder(
  //                                 // width: 0.0 produces a thin "hairline" border
  //                                 borderRadius: BorderRadius.circular(1),
  //                                 borderSide: BorderSide(
  //                                     color: Colors.transparent, width: 1.5),
  //                               ),
  //                               hoverColor: Colors.transparent,
  //                               focusedBorder: OutlineInputBorder(
  //                                 // width: 0.0 produces a thin "hairline" border
  //                                 borderRadius: BorderRadius.circular(1),
  //                                 borderSide: BorderSide(
  //                                     color: Colors.transparent, width: 1.5),
  //                               ),
  //                               border: OutlineInputBorder(
  //                                   borderRadius: BorderRadius.circular(1),
  //                                   borderSide:
  //                                       BorderSide(color: Colors.transparent)),
  //                               contentPadding: EdgeInsets.fromLTRB(7, 4, 7, 4),
  //                               hintText: getTranslated(this.context, 'msg'),
  //                               hintStyle:
  //                                   TextStyle(color: Colors.grey, fontSize: 16),
  //                             ),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //                 // Button send message
  //                 Container(
  //                   height: 47,
  //                   width: 47,
  //                   // alignment: Alignment.center,
  //                   margin: EdgeInsets.only(left: 6, right: 10),
  //                   decoration: BoxDecoration(
  //                       color: DESIGN_TYPE == Themetype.whatsapp
  //                           ? fiberchatgreen
  //                           : fiberchatLightGreen,
  //                       // border: Border.all(
  //                       //   color: Colors.red[500],
  //                       // ),
  //                       borderRadius: BorderRadius.all(Radius.circular(30))),
  //                   child: Padding(
  //                     padding: const EdgeInsets.all(2.0),
  //                     child: IconButton(
  //                       icon: new Icon(
  //                         Icons.send,
  //                         color: fiberchatWhite.withOpacity(0.99),
  //                       ),
  //                       onPressed: observer.istextmessagingallowed == false
  //                           ? () {
  //                               Fiberchat.showRationale(getTranslated(
  //                                   this.context, 'textmssgnotallowed'));
  //                             }
  //                           : () {
  //                               onSendMessage(
  //                                 context: context,
  //                                 content:
  //                                     textEditingController.value.text.trim(),
  //                                 type: MessageType.text,
  //                               );
  //                             },
  //                       color: fiberchatWhite,
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             width: double.infinity,
  //             height: 60.0,
  //             decoration: new BoxDecoration(
  //               // border: new Border(top: new BorderSide(color: Colors.grey, width: 0.5)),
  //               color: Colors.transparent,
  //             ),
  //           ));
  // }

  Widget buildReplyMessageForInput(
    BuildContext context,
  ) {
    return Flexible(
      child: Container(
          height: 80,
          margin: EdgeInsets.only(left: 15, right: 70),
          decoration: BoxDecoration(
              color: fiberchatWhite,
              borderRadius: BorderRadius.all(Radius.circular(10))),
          child: Stack(
            children: [
              Container(
                  margin: EdgeInsetsDirectional.all(4),
                  decoration: BoxDecoration(
                      color: fiberchatGrey.withOpacity(0.1),
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                  child: Row(children: [
                    Container(
                      decoration: BoxDecoration(
                        color: replyDoc![Dbkeys.groupmsgSENDBY] ==
                                widget.currentUserno
                            ? fiberchatPRIMARYcolor
                            : Colors.purple,
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(0),
                            bottomRight: Radius.circular(0),
                            topLeft: Radius.circular(10),
                            bottomLeft: Radius.circular(10)),
                      ),
                      height: 75,
                      width: 3.3,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Expanded(
                        child: Container(
                      padding: EdgeInsetsDirectional.all(5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(right: 30),
                            child: Text(
                              replyDoc![Dbkeys.groupmsgSENDBY] ==
                                      widget.currentUserno
                                  ? getTranslated(this.context, 'you')
                                  : messageReplyOwnerName,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: replyDoc![Dbkeys.groupmsgSENDBY] ==
                                          widget.currentUserno
                                      ? fiberchatPRIMARYcolor
                                      : Colors.purple),
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          replyDoc![Dbkeys.messageType] ==
                                  MessageType.text.index
                              ? Text(
                                  replyDoc![Dbkeys.content],
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  style: TextStyle(color: fiberchatBlack),
                                )
                              : replyDoc![Dbkeys.messageType] ==
                                      MessageType.doc.index
                                  ? Container(
                                      width: MediaQuery.of(context).size.width -
                                          125,
                                      padding: const EdgeInsets.only(right: 55),
                                      child: Text(
                                        replyDoc![Dbkeys.content]
                                            .split('-BREAK-')[1],
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                      ),
                                    )
                                  : Text(
                                      getTranslated(
                                          this.context,
                                          replyDoc![Dbkeys.messageType] ==
                                                  MessageType.image.index
                                              ? 'nim'
                                              : replyDoc![Dbkeys.messageType] ==
                                                      MessageType.video.index
                                                  ? 'nvm'
                                                  : replyDoc![Dbkeys
                                                              .messageType] ==
                                                          MessageType
                                                              .audio.index
                                                      ? 'nam'
                                                      : replyDoc![Dbkeys
                                                                  .messageType] ==
                                                              MessageType
                                                                  .contact.index
                                                          ? 'ncm'
                                                          : replyDoc![Dbkeys
                                                                      .messageType] ==
                                                                  MessageType
                                                                      .location
                                                                      .index
                                                              ? 'nlm'
                                                              : replyDoc![Dbkeys
                                                                          .messageType] ==
                                                                      MessageType
                                                                          .doc
                                                                          .index
                                                                  ? 'ndm'
                                                                  : ''),
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(color: fiberchatBlack),
                                    ),
                        ],
                      ),
                    ))
                  ])),
              replyDoc![Dbkeys.messageType] == MessageType.text.index
                  ? SizedBox(
                      width: 0,
                      height: 0,
                    )
                  : replyDoc![Dbkeys.messageType] == MessageType.image.index
                      ? Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            width: 84.0,
                            height: 84.0,
                            padding: EdgeInsetsDirectional.all(6),
                            child: ClipRRect(
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(5),
                                  bottomRight: Radius.circular(5),
                                  topLeft: Radius.circular(0),
                                  bottomLeft: Radius.circular(0)),
                              child: CachedNetworkImage(
                                placeholder: (context, url) => Container(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        fiberchatSECONDARYolor),
                                  ),
                                  width: replyDoc![Dbkeys.content]
                                          .contains('giphy')
                                      ? 60
                                      : 60.0,
                                  height: replyDoc![Dbkeys.content]
                                          .contains('giphy')
                                      ? 60
                                      : 60.0,
                                  padding: EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    color: Colors.blueGrey[200],
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                  ),
                                ),
                                errorWidget: (context, str, error) => Material(
                                  child: Image.asset(
                                    'assets/images/img_not_available.jpeg',
                                    width: 60.0,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8.0),
                                  ),
                                  clipBehavior: Clip.hardEdge,
                                ),
                                imageUrl: replyDoc![Dbkeys.messageType] ==
                                        MessageType.video.index
                                    ? ''
                                    : replyDoc![Dbkeys.content],
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        )
                      : replyDoc![Dbkeys.messageType] == MessageType.video.index
                          ? Positioned(
                              right: -2,
                              top: -2,
                              child: Container(
                                  width: 84.0,
                                  height: 84.0,
                                  padding: EdgeInsetsDirectional.all(6),
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(5),
                                          bottomRight: Radius.circular(5),
                                          topLeft: Radius.circular(0),
                                          bottomLeft: Radius.circular(0)),
                                      child: Container(
                                        color: Colors.blueGrey[200],
                                        height: 84,
                                        width: 84,
                                        child: Stack(
                                          children: [
                                            CachedNetworkImage(
                                              placeholder: (context, url) =>
                                                  Container(
                                                child:
                                                    CircularProgressIndicator(
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                              Color>(
                                                          fiberchatSECONDARYolor),
                                                ),
                                                width: 84,
                                                height: 84,
                                                padding: EdgeInsets.all(8.0),
                                                decoration: BoxDecoration(
                                                  color: Colors.blueGrey[200],
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(0.0),
                                                  ),
                                                ),
                                              ),
                                              errorWidget:
                                                  (context, str, error) =>
                                                      Material(
                                                child: Image.asset(
                                                  'assets/images/img_not_available.jpeg',
                                                  width: 60,
                                                  height: 60,
                                                  fit: BoxFit.cover,
                                                ),
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(0.0),
                                                ),
                                                clipBehavior: Clip.hardEdge,
                                              ),
                                              imageUrl:
                                                  replyDoc![Dbkeys.content]
                                                      .split('-BREAK-')[1],
                                              width: 84,
                                              height: 84,
                                              fit: BoxFit.cover,
                                            ),
                                            Container(
                                              color:
                                                  Colors.black.withOpacity(0.4),
                                              height: 84,
                                              width: 84,
                                            ),
                                            Center(
                                              child: Icon(
                                                  Icons
                                                      .play_circle_fill_outlined,
                                                  color: Colors.white70,
                                                  size: 25),
                                            ),
                                          ],
                                        ),
                                      ))))
                          : Positioned(
                              right: -2,
                              top: -2,
                              child: Container(
                                  width: 84.0,
                                  height: 84.0,
                                  padding: EdgeInsetsDirectional.all(6),
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(5),
                                          bottomRight: Radius.circular(5),
                                          topLeft: Radius.circular(0),
                                          bottomLeft: Radius.circular(0)),
                                      child: Container(
                                          color: replyDoc![
                                                      Dbkeys.messageType] ==
                                                  MessageType.doc.index
                                              ? Colors.yellow[00]
                                              : replyDoc![Dbkeys.messageType] ==
                                                      MessageType.audio.index
                                                  ? fiberchatGreenColor400
                                                  : replyDoc![Dbkeys
                                                              .messageType] ==
                                                          MessageType
                                                              .location.index
                                                      ? Colors.red[700]
                                                      : replyDoc![Dbkeys
                                                                  .messageType] ==
                                                              MessageType
                                                                  .contact.index
                                                          ? Colors.blue[400]
                                                          : Colors.cyan[700],
                                          height: 84,
                                          width: 84,
                                          child: Icon(
                                            replyDoc![Dbkeys.messageType] ==
                                                    MessageType.doc.index
                                                ? Icons.insert_drive_file
                                                : replyDoc![Dbkeys
                                                            .messageType] ==
                                                        MessageType.audio.index
                                                    ? Icons.mic_rounded
                                                    : replyDoc![Dbkeys
                                                                .messageType] ==
                                                            MessageType
                                                                .location.index
                                                        ? Icons.location_on
                                                        : replyDoc![Dbkeys
                                                                    .messageType] ==
                                                                MessageType
                                                                    .contact
                                                                    .index
                                                            ? Icons
                                                                .contact_page_sharp
                                                            : Icons
                                                                .insert_drive_file,
                                            color: Colors.white,
                                            size: 35,
                                          ))))),
              Positioned(
                right: 7,
                top: 7,
                child: InkWell(
                  onTap: () {
                    setStateIfMounted(() {
                      HapticFeedback.heavyImpact();
                      isReplyKeyboard = false;
                      hidekeyboard(context);
                    });
                  },
                  child: Container(
                    width: 15,
                    height: 15,
                    decoration: new BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: new Icon(
                      Icons.close,
                      color: Colors.blueGrey,
                      size: 13,
                    ),
                  ),
                ),
              )
            ],
          )),
    );
  }

  buildEachMessage(Map<String, dynamic> doc, GroupModel groupData) {
    if (doc[Dbkeys.groupmsgTYPE] == Dbkeys.groupmsgTYPEnotificationAddedUser) {
      return Center(
          child: Chip(
        labelStyle: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w400, color: Colors.black87),
        backgroundColor: Colors.blueGrey[50],
        label: Text(
          doc[Dbkeys.groupmsgLISToptional].contains(widget.currentUserno) &&
                  doc[Dbkeys.groupmsgLISToptional].length > 1
              ? doc[Dbkeys.groupmsgLISToptional]
                      .contains(groupData.docmap[Dbkeys.groupCREATEDBY])
                  ? widget.currentUserno ==
                          groupData.docmap[Dbkeys.groupCREATEDBY]
                      ? '${getTranslated(this.context, 'uhaveadded')} ${doc[Dbkeys.groupmsgLISToptional].length - 1} ${getTranslated(this.context, 'users')} '
                      : '${getTranslated(this.context, 'adminahasadded')} ${getTranslated(this.context, 'youandother')} ${doc[Dbkeys.groupmsgLISToptional].length - 1} ${getTranslated(this.context, 'users')}'
                  : '${doc[Dbkeys.groupmsgSENDBY]} ${getTranslated(this.context, 'added')} ${getTranslated(this.context, 'youandother')} ${doc[Dbkeys.groupmsgLISToptional].length - 1} ${getTranslated(this.context, 'users')}'
              : doc[Dbkeys.groupmsgLISToptional]
                          .contains(widget.currentUserno) &&
                      doc[Dbkeys.groupmsgLISToptional].length == 1
                  ? '${getTranslated(this.context, 'youareaddedtothisgrp')}'
                  : !doc[Dbkeys.groupmsgLISToptional]
                              .contains(widget.currentUserno) &&
                          doc[Dbkeys.groupmsgLISToptional].length == 1
                      ? doc[Dbkeys.groupmsgSENDBY] ==
                              groupData.docmap[Dbkeys.groupCREATEDBY]
                          ? widget.currentUserno ==
                                  groupData.docmap[Dbkeys.groupCREATEDBY]
                              ? '${getTranslated(this.context, 'uhaveadded')} ${doc[Dbkeys.groupmsgLISToptional][0]}'
                              : '${getTranslated(this.context, 'adminhasadded')} ${doc[Dbkeys.groupmsgLISToptional][0]}'
                          : '${doc[Dbkeys.groupmsgSENDBY]} ${getTranslated(this.context, 'adminhasadded')} ${doc[Dbkeys.groupmsgLISToptional][0]}'
                      : doc[Dbkeys.groupmsgSENDBY] ==
                              groupData.docmap[Dbkeys.groupCREATEDBY]
                          ? '${getTranslated(this.context, 'adminahasadded')} ${doc[Dbkeys.groupmsgLISToptional].length} ${getTranslated(this.context, 'users')}'
                          : '${doc[Dbkeys.groupmsgSENDBY]} ${getTranslated(this.context, 'added')} ${doc[Dbkeys.groupmsgLISToptional].length} ${getTranslated(this.context, 'users')}',
          style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w400, color: Colors.black87),
        ),
      ));
    } else if (doc[Dbkeys.groupmsgTYPE] ==
        Dbkeys.groupmsgTYPEnotificationCreatedGroup) {
      return Center(
          child: Chip(
        labelStyle: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w400, color: Colors.black87),
        backgroundColor: Colors.blueGrey[50],
        label: Text(
          groupData.docmap[Dbkeys.groupCREATEDBY].contains(widget.currentUserno)
              ? getTranslated(this.context, 'youcreatedthisgroup')
              : '${groupData.docmap[Dbkeys.groupCREATEDBY]} ${getTranslated(this.context, 'hascreatedthisgroup')}',
          style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w400, color: Colors.black87),
        ),
      ));
    } else if (doc[Dbkeys.groupmsgTYPE] ==
        Dbkeys.groupmsgTYPEnotificationUpdatedGroupDetails) {
      return Center(
          child: Chip(
        labelStyle: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w400, color: Colors.black87),
        backgroundColor: Colors.blueGrey[50],
        label: Text(
          doc[Dbkeys.groupmsgSENDBY] == widget.currentUserno
              ? getTranslated(this.context, 'uhvupdatedgrpdetails')
              : '${doc[Dbkeys.groupmsgSENDBY]} ${getTranslated(this.context, 'hasupdatedgrpdetails')}'
                      .contains(groupData.docmap[Dbkeys.groupCREATEDBY])
                  ? getTranslated(this.context, 'grpdetailsupdatebyadmin')
                  : '${doc[Dbkeys.groupmsgSENDBY]} ${getTranslated(this.context, 'hasupdatedgrpdetails')}',
          style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w400, color: Colors.black87),
        ),
      ));
    } else if (doc[Dbkeys.groupmsgTYPE] ==
        Dbkeys.groupmsgTYPEnotificationUserSetAsAdmin) {
      return Center(
          child: Chip(
        labelStyle: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w400, color: Colors.black87),
        backgroundColor: Colors.blueGrey[50],
        label: Text(
          doc[Dbkeys.groupmsgSENDBY] == widget.currentUserno
              ? '${doc[Dbkeys.groupmsgLISToptional][0]} ${getTranslated(this.context, 'hasbeensetasadminbyu')}'
              : doc[Dbkeys.groupmsgLISToptional][0] == widget.currentUserno
                  ? '${doc[Dbkeys.groupmsgSENDBY]} ${getTranslated(this.context, 'hvsetuasadsmin')}'
                  : '${doc[Dbkeys.groupmsgSENDBY]} ${getTranslated(this.context, 'set')} ${doc[Dbkeys.groupmsgLISToptional][0]} ${getTranslated(this.context, 'asadmin')}',
          style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w400, color: Colors.black87),
        ),
      ));
    } else if (doc[Dbkeys.groupmsgTYPE] ==
        Dbkeys.groupmsgTYPEnotificationUserRemovedAsAdmin) {
      return Center(
          child: Chip(
        labelStyle: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w400, color: Colors.black87),
        backgroundColor: Colors.blueGrey[50],
        label: Text(
          doc[Dbkeys.groupmsgSENDBY] == widget.currentUserno
              ? '${getTranslated(this.context, 'youhaveremoved')} ${doc[Dbkeys.groupmsgLISToptional][0]} ${getTranslated(this.context, 'fromadmin')}'
              : doc[Dbkeys.groupmsgLISToptional][0] == widget.currentUserno
                  ? '${doc[Dbkeys.groupmsgSENDBY]} ${getTranslated(this.context, 'theyremoveduasadmin')}'
                  : '${doc[Dbkeys.groupmsgSENDBY]} ${getTranslated(this.context, 'hasremoved')} ${doc[Dbkeys.groupmsgLISToptional][0]} ${getTranslated(this.context, 'fromadmin')}',
          style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w400, color: Colors.black87),
        ),
      ));
    } else if (doc[Dbkeys.groupmsgTYPE] ==
        Dbkeys.groupmsgTYPEnotificationUpdatedGroupicon) {
      return Center(
          child: Chip(
        labelStyle: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w400, color: Colors.black87),
        backgroundColor: Colors.blueGrey[50],
        label: Text(
          doc[Dbkeys.groupmsgSENDBY] == widget.currentUserno
              ? getTranslated(this.context, 'youupdatedgrpicon')
              : '${doc[Dbkeys.groupmsgSENDBY]} ${getTranslated(this.context, 'hasupdatedgrpicon')}',
          style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w400, color: Colors.black87),
        ),
      ));
    } else if (doc[Dbkeys.groupmsgTYPE] ==
        Dbkeys.groupmsgTYPEnotificationDeletedGroupicon) {
      return Center(
          child: Chip(
        labelStyle: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w400, color: Colors.black87),
        backgroundColor: Colors.blueGrey[50],
        label: Text(
          doc[Dbkeys.groupmsgSENDBY] == widget.currentUserno
              ? getTranslated(this.context, 'youremovedgrpicon')
              : '${doc[Dbkeys.groupmsgSENDBY]} ${getTranslated(this.context, 'hasremovedgrpicon')}',
          style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w400, color: Colors.black87),
        ),
      ));
    } else if (doc[Dbkeys.groupmsgTYPE] ==
        Dbkeys.groupmsgTYPEnotificationRemovedUser) {
      return Center(
          child: Chip(
        labelStyle: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w400, color: Colors.black87),
        backgroundColor: Colors.blueGrey[50],
        label: Text(
          doc[Dbkeys.groupmsgCONTENT].contains('by ' + widget.currentUserno)
              ? '${getTranslated(this.context, 'youhaveremoved')} ${doc[Dbkeys.groupmsgLISToptional][0]}'
              : doc[Dbkeys.groupmsgSENDBY] ==
                      groupData.docmap[Dbkeys.groupCREATEDBY]
                  ? '${doc[Dbkeys.groupmsgLISToptional][0]} ${getTranslated(this.context, 'removedbyadmin')}'
                  : '${doc[Dbkeys.groupmsgSENDBY]} ${getTranslated(this.context, 'hasremoved')} ${doc[Dbkeys.groupmsgLISToptional][0]}',
          style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w400, color: Colors.black87),
        ),
      ));
    } else if (doc[Dbkeys.groupmsgTYPE] ==
        Dbkeys.groupmsgTYPEnotificationUserLeft) {
      return Center(
          child: Chip(
        labelStyle: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w400, color: Colors.black87),
        backgroundColor: Colors.blueGrey[50],
        label: Text(
          doc[Dbkeys.groupmsgCONTENT].contains(widget.currentUserno)
              ? getTranslated(this.context, 'youleftthegroup')
              : '${doc[Dbkeys.groupmsgCONTENT]}',
          style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w400, color: Colors.black87),
        ),
      ));
    } else if (doc[Dbkeys.groupmsgTYPE] == MessageType.image.index ||
        doc[Dbkeys.groupmsgTYPE] == MessageType.doc.index ||
        doc[Dbkeys.groupmsgTYPE] == MessageType.text.index ||
        doc[Dbkeys.groupmsgTYPE] == MessageType.video.index ||
        doc[Dbkeys.groupmsgTYPE] == MessageType.audio.index ||
        doc[Dbkeys.groupmsgTYPE] == MessageType.contact.index ||
        doc[Dbkeys.groupmsgTYPE] == MessageType.location.index) {
      return doc[Dbkeys.content] == null || doc[Dbkeys.content] == ''
          ? buildMediaMessages(doc, groupData)
          : Dismissible(
              direction: DismissDirection.startToEnd,
              key: Key(doc[Dbkeys.groupmsgTIME].toString()),
              confirmDismiss: (direction) {
                onDismiss(doc);
                return Future.value(false);
              },
              child: buildMediaMessages(doc, groupData));
    }

    return Text(doc[Dbkeys.groupmsgCONTENT]);
  }

  onDismiss(Map<String, dynamic> doc) {
    if ((doc[Dbkeys.content] == '' || doc[Dbkeys.content] == null) == false) {
      final contactsProvider =
          Provider.of<SmartContactProviderWithLocalStoreData>(this.context,
              listen: false);
      setStateIfMounted(() {
        isReplyKeyboard = true;
        replyDoc = doc;
        messageReplyOwnerName = contactsProvider
                    .alreadyJoinedSavedUsersPhoneNameAsInServer
                    .indexWhere((element) =>
                        element.phone == doc[Dbkeys.groupmsgSENDBY]) >=
                0
            ? contactsProvider
                    .alreadyJoinedSavedUsersPhoneNameAsInServer[contactsProvider
                        .alreadyJoinedSavedUsersPhoneNameAsInServer
                        .indexWhere((element) =>
                            element.phone == doc[Dbkeys.groupmsgSENDBY])]
                    .name ??
                doc[Dbkeys.groupmsgSENDBY].toString()
            : doc[Dbkeys.groupmsgSENDBY].toString();
      });
      HapticFeedback.heavyImpact();
      keyboardFocusNode.requestFocus();
    }
  }

  FlutterSecureStorage storage = new FlutterSecureStorage();
  late encrypt.Encrypter cryptor;
  final iv = encrypt.IV.fromLength(8);

  contextMenu(BuildContext context, Map<String, dynamic> mssgDoc,
      {bool saved = false}) {
    List<Widget> tiles = List.from(<Widget>[]);

    if (mssgDoc[Dbkeys.groupmsgSENDBY] == widget.currentUserno) {
      tiles.add(Builder(
          builder: (BuildContext popable) => ListTile(
              dense: true,
              leading: Icon(Icons.delete),
              title: Text(
                getTranslated(popable, 'dltforeveryone'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: pickTextColorBasedOnBgColorAdvanced(
                      Thm.isDarktheme(widget.prefs)
                          ? fiberchatDIALOGColorDarkMode
                          : fiberchatDIALOGColorLightMode),
                ),
              ),
              onTap: () async {
                Navigator.of(popable).pop();
                if (mssgDoc[Dbkeys.messageType] == MessageType.image.index &&
                    !mssgDoc[Dbkeys.groupmsgCONTENT].contains('giphy')) {
                  try {
                    await FirebaseStorage.instance
                        .refFromURL(mssgDoc[Dbkeys.groupmsgCONTENT])
                        .delete();
                  } catch (e) {}
                } else if (mssgDoc[Dbkeys.messageType] ==
                    MessageType.doc.index) {
                  try {
                    await FirebaseStorage.instance
                        .refFromURL(
                            mssgDoc[Dbkeys.groupmsgCONTENT].split('-BREAK-')[0])
                        .delete();
                  } catch (e) {}
                } else if (mssgDoc[Dbkeys.messageType] ==
                    MessageType.audio.index) {
                  try {
                    await FirebaseStorage.instance
                        .refFromURL(
                            mssgDoc[Dbkeys.groupmsgCONTENT].split('-BREAK-')[0])
                        .delete();
                  } catch (e) {}
                } else if (mssgDoc[Dbkeys.messageType] ==
                    MessageType.video.index) {
                  try {
                    await FirebaseStorage.instance
                        .refFromURL(
                            mssgDoc[Dbkeys.groupmsgCONTENT].split('-BREAK-')[0])
                        .delete();
                    await FirebaseStorage.instance
                        .refFromURL(
                            mssgDoc[Dbkeys.groupmsgCONTENT].split('-BREAK-')[1])
                        .delete();
                  } catch (e) {}
                }
                if (deleteMessaqgeForEveryoneDeleteFromServer == true) {
                  await FirebaseFirestore.instance
                      .collection(DbPaths.collectiongroups)
                      .doc(widget.groupID)
                      .collection(DbPaths.collectiongroupChats)
                      .doc(
                          '${mssgDoc[Dbkeys.groupmsgTIME]}--${mssgDoc[Dbkeys.groupmsgSENDBY]}')
                      .delete();
                } else {
                  await FirebaseFirestore.instance
                      .collection(DbPaths.collectiongroups)
                      .doc(widget.groupID)
                      .collection(DbPaths.collectiongroupChats)
                      .doc(
                          '${mssgDoc[Dbkeys.groupmsgTIME]}--${mssgDoc[Dbkeys.groupmsgSENDBY]}')
                      .update({
                    Dbkeys.groupmsgISDELETED: true,
                    Dbkeys.groupmsgCONTENT: '',
                  });
                }
              })));
    }
    if (mssgDoc[Dbkeys.groupmsgISDELETED] == false) {
      tiles.add(Builder(
          builder: (BuildContext popable) => ListTile(
              dense: true,
              leading: Icon(FontAwesomeIcons.share, size: 22),
              title: Text(
                getTranslated(popable, 'forward'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: pickTextColorBasedOnBgColorAdvanced(
                      Thm.isDarktheme(widget.prefs)
                          ? fiberchatDIALOGColorDarkMode
                          : fiberchatDIALOGColorLightMode),
                ),
              ),
              onTap: () async {
                Navigator.of(popable).pop();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SelectContactsToForward(
                            contentPeerNo: mssgDoc[Dbkeys.from],
                            messageOwnerPhone: widget.currentUserno,
                            currentUserNo: widget.currentUserno,
                            model: widget.model,
                            prefs: widget.prefs,
                            onSelect: (selectedlist) async {
                              if (selectedlist.length > 0) {
                                setStateIfMounted(() {
                                  isgeneratingSomethingLoader = true;
                                  // tempSendIndex = 0;
                                });

                                String? privateKey =
                                    await storage.read(key: Dbkeys.privateKey);

                                await sendForwardMessageEach(
                                    0, selectedlist, privateKey!, mssgDoc);
                              }
                            })));
              })));

      tiles.add(Builder(
          builder: (BuildContext context) => ListTile(
              dense: true,
              leading: Icon(FontAwesomeIcons.reply, size: 22),
              title: Text(
                getTranslated(context, 'reply'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: pickTextColorBasedOnBgColorAdvanced(
                      Thm.isDarktheme(widget.prefs)
                          ? fiberchatDIALOGColorDarkMode
                          : fiberchatDIALOGColorLightMode),
                ),
              ),
              onTap: () async {
                Navigator.of(context).pop();
                final contactsProvider =
                    Provider.of<SmartContactProviderWithLocalStoreData>(
                        this.context,
                        listen: false);
                setStateIfMounted(() {
                  isReplyKeyboard = true;
                  replyDoc = mssgDoc;
                  messageReplyOwnerName = contactsProvider
                              .alreadyJoinedSavedUsersPhoneNameAsInServer
                              .indexWhere((element) =>
                                  element.phone ==
                                  mssgDoc[Dbkeys.groupmsgSENDBY]) >=
                          0
                      ? contactsProvider
                              .alreadyJoinedSavedUsersPhoneNameAsInServer[
                                  contactsProvider
                                      .alreadyJoinedSavedUsersPhoneNameAsInServer
                                      .indexWhere((element) =>
                                          element.phone ==
                                          mssgDoc[Dbkeys.groupmsgSENDBY])]
                              .name ??
                          mssgDoc[Dbkeys.groupmsgSENDBY].toString()
                      : mssgDoc[Dbkeys.groupmsgSENDBY].toString();
                });
                HapticFeedback.heavyImpact();
                keyboardFocusNode.requestFocus();
              })));
    }

    showDialog(
        context: this.context,
        builder: (context) {
          return SimpleDialog(
              backgroundColor: Thm.isDarktheme(widget.prefs)
                  ? fiberchatDIALOGColorDarkMode
                  : fiberchatDIALOGColorLightMode,
              children: tiles);
        });
  }

  sendForwardMessageEach(
      int index, List<dynamic> list, String privateKey, var mssgDoc) async {
    if (index >= list.length) {
      setStateIfMounted(() {
        isgeneratingSomethingLoader = false;
      });
      Navigator.of(this.context).pop();
    } else {
      if (list[index].containsKey(Dbkeys.groupNAME)) {
        try {
          Map<dynamic, dynamic> groupDoc = list[index];
          int timestamp = DateTime.now().millisecondsSinceEpoch;

          FirebaseFirestore.instance
              .collection(DbPaths.collectiongroups)
              .doc(groupDoc[Dbkeys.groupID])
              .collection(DbPaths.collectiongroupChats)
              .doc(timestamp.toString() + '--' + widget.currentUserno)
              .set({
            Dbkeys.groupmsgCONTENT: mssgDoc[Dbkeys.content],
            Dbkeys.groupmsgISDELETED: false,
            Dbkeys.groupmsgLISToptional: [],
            Dbkeys.groupmsgTIME: timestamp,
            Dbkeys.groupmsgSENDBY: widget.currentUserno,
            Dbkeys.groupmsgISDELETED: false,
            Dbkeys.groupmsgTYPE: mssgDoc[Dbkeys.messageType],
            Dbkeys.groupNAME: groupDoc[Dbkeys.groupNAME],
            Dbkeys.groupID: groupDoc[Dbkeys.groupNAME],
            Dbkeys.sendername: widget.model.currentUser![Dbkeys.nickname],
            Dbkeys.groupIDfiltered: groupDoc[Dbkeys.groupIDfiltered],
            Dbkeys.isReply: false,
            Dbkeys.replyToMsgDoc: null,
            Dbkeys.isForward: true
          }, SetOptions(merge: true)).then((value) {
            unawaited(realtime.animateTo(0.0,
                duration: Duration(milliseconds: 300), curve: Curves.easeOut));
            // _playPopSound();
            FirebaseFirestore.instance
                .collection(DbPaths.collectiongroups)
                .doc(groupDoc[Dbkeys.groupID])
                .update(
              {Dbkeys.groupLATESTMESSAGETIME: timestamp},
            );
          }).then((value) async {
            if (index >= list.length - 1) {
              Fiberchat.toast(
                getTranslated(this.context, 'sent'),
              );
              setStateIfMounted(() {
                isgeneratingSomethingLoader = false;
              });
              Navigator.of(this.context).pop();
            } else {
              await sendForwardMessageEach(
                  index + 1, list, privateKey, mssgDoc);
            }
          });
        } catch (e) {
          setStateIfMounted(() {
            isgeneratingSomethingLoader = false;
          });
          Fiberchat.toast(getTranslated(this.context, 'failedsending'));
        }
      } else {
        try {
          String? sharedSecret = (await e2ee.X25519().calculateSharedSecret(
                  e2ee.Key.fromBase64(privateKey, false),
                  e2ee.Key.fromBase64(list[index][Dbkeys.publicKey], true)))
              .toBase64();
          final key = encrypt.Key.fromBase64(sharedSecret);
          cryptor = new encrypt.Encrypter(encrypt.Salsa20(key));
          String content = mssgDoc[Dbkeys.content];
          final encrypted = AESEncryptData.encryptAES(content, sharedSecret);
          if (encrypted is String) {
            int timestamp2 = DateTime.now().millisecondsSinceEpoch;
            if (content.trim() != '') {
              Map<String, dynamic>? targetPeer =
                  widget.model.userData[list[index][Dbkeys.phone]];
              if (targetPeer == null) {
                await ChatController.request(
                    widget.currentUserno,
                    list[index][Dbkeys.phone],
                    Fiberchat.getChatId(
                        widget.currentUserno, list[index][Dbkeys.phone]));
              }
              var chatId = Fiberchat.getChatId(
                  widget.currentUserno, list[index][Dbkeys.phone]);
              await FirebaseFirestore.instance
                  .collection(DbPaths.collectionmessages)
                  .doc(chatId)
                  .set({
                widget.currentUserno: true,
                list[index][Dbkeys.phone]: list[index][Dbkeys.lastSeen],
              }, SetOptions(merge: true)).then((value) async {
                Future messaging = FirebaseFirestore.instance
                    .collection(DbPaths.collectionusers)
                    .doc(list[index][Dbkeys.phone])
                    .collection(Dbkeys.chatsWith)
                    .doc(Dbkeys.chatsWith)
                    .set({
                  widget.currentUserno: 4,
                }, SetOptions(merge: true));
                widget.model.addMessage(
                    list[index][Dbkeys.phone], timestamp2, messaging);
              }).then((value) async {
                Future messaging = FirebaseFirestore.instance
                    .collection(DbPaths.collectionmessages)
                    .doc(chatId)
                    .collection(chatId)
                    .doc('$timestamp2')
                    .set({
                  Dbkeys.from: widget.currentUserno,
                  Dbkeys.to: list[index][Dbkeys.phone],
                  Dbkeys.timestamp: timestamp2,
                  Dbkeys.content: encrypted,
                  Dbkeys.messageType: mssgDoc[Dbkeys.messageType],
                  Dbkeys.hasSenderDeleted: false,
                  Dbkeys.hasRecipientDeleted: false,
                  Dbkeys.sendername: widget.model.currentUser![Dbkeys.nickname],
                  Dbkeys.isReply: false,
                  Dbkeys.replyToMsgDoc: null,
                  Dbkeys.isForward: true,
                  Dbkeys.latestEncrypted: true,
                  Dbkeys.isMuted: false,
                }, SetOptions(merge: true));
                widget.model.addMessage(
                    list[index][Dbkeys.phone], timestamp2, messaging);
              }).then((value) async {
                if (index >= list.length - 1) {
                  Fiberchat.toast(
                    getTranslated(this.context, 'sent'),
                  );
                  setStateIfMounted(() {
                    isgeneratingSomethingLoader = false;
                  });
                  Navigator.of(this.context).pop();
                } else {
                  await sendForwardMessageEach(
                      index + 1, list, privateKey, mssgDoc);
                }
              });
            }
          } else {
            setStateIfMounted(() {
              isgeneratingSomethingLoader = false;
            });
            Fiberchat.toast('Nothing to send');
          }
        } catch (e) {
          setStateIfMounted(() {
            isgeneratingSomethingLoader = false;
          });
          Fiberchat.toast('Failed to Forward message. Error:$e');
        }
      }
    }
  }

  Widget buildMediaMessages(Map<String, dynamic> doc, GroupModel groupData) {
    bool isMe = widget.currentUserno == doc[Dbkeys.groupmsgSENDBY];
    bool saved = false;
    final observer = Provider.of<Observer>(this.context, listen: false);
    bool isContainURL = false;

    /*try { Deactivated by JH because otherwise many links (e.g. firebase links) were shown as picture with "Oops! Unable to parse the url"
      isContainURL = Uri.tryParse(doc[Dbkeys.content]!) == null
          ? false
          : Uri.tryParse(doc[Dbkeys.content]!)!.isAbsolute;
    } on Exception catch (_) {
      isContainURL = false;
    } */
    return Consumer<SmartContactProviderWithLocalStoreData>(
        builder: (context, contactsProvider, _child) => InkWell(
              onLongPress: doc[Dbkeys.groupmsgISDELETED] == false
                  ? () {
                      contextMenu(
                        context,
                        doc,
                      );
                      hidekeyboard(context);
                    }
                  : null,
              child: GroupChatBubble(
                isURLtext: doc[Dbkeys.messageType] == MessageType.text.index &&
                    isContainURL == true,
                is24hrsFormat: observer.is24hrsTimeformat,
                prefs: widget.prefs,
                currentUserNo: widget.currentUserno,
                model: widget.model,
                savednameifavailable: contactsProvider
                            .contactsBookContactList!.entries
                            .toList()
                            .indexWhere((element) =>
                                element.key == doc[Dbkeys.groupmsgSENDBY]) >=
                        0
                    ? contactsProvider.contactsBookContactList!.entries
                        .toList()[contactsProvider
                            .contactsBookContactList!.entries
                            .toList()
                            .indexWhere((element) =>
                                element.key == doc[Dbkeys.groupmsgSENDBY])]
                        .value
                    : null,
                postedbyname: contactsProvider
                            .alreadyJoinedSavedUsersPhoneNameAsInServer
                            .indexWhere((element) =>
                                element.phone == doc[Dbkeys.groupmsgSENDBY]) >=
                        0
                    ? contactsProvider
                            .alreadyJoinedSavedUsersPhoneNameAsInServer[
                                contactsProvider
                                    .alreadyJoinedSavedUsersPhoneNameAsInServer
                                    .indexWhere((element) =>
                                        element.phone ==
                                        doc[Dbkeys.groupmsgSENDBY])]
                            .name ??
                        doc[Dbkeys.groupmsgSENDBY]
                    : '',
                postedbyphone: doc[Dbkeys.groupmsgSENDBY],
                messagetype: doc[Dbkeys.groupmsgISDELETED] == true
                    ? MessageType.text
                    : doc[Dbkeys.messageType] == MessageType.text.index
                        ? MessageType.text
                        : doc[Dbkeys.messageType] == MessageType.contact.index
                            ? MessageType.contact
                            : doc[Dbkeys.messageType] ==
                                    MessageType.location.index
                                ? MessageType.location
                                : doc[Dbkeys.messageType] ==
                                        MessageType.image.index
                                    ? MessageType.image
                                    : doc[Dbkeys.messageType] ==
                                            MessageType.video.index
                                        ? MessageType.video
                                        : doc[Dbkeys.messageType] ==
                                                MessageType.doc.index
                                            ? MessageType.doc
                                            : doc[Dbkeys.messageType] ==
                                                    MessageType.audio.index
                                                ? MessageType.audio
                                                : MessageType.text,
                child: doc[Dbkeys.groupmsgISDELETED] == true
                    ? Text(
                        getTranslated(context, 'msgdeleted'),
                        style: TextStyle(
                            color: fiberchatBlack.withOpacity(0.6),
                            fontSize: 15,
                            fontStyle: FontStyle.italic),
                      )
                    : doc[Dbkeys.messageType] == MessageType.text.index
                        ? getTextMessage(isMe, doc, saved)
                        : doc[Dbkeys.messageType] == MessageType.location.index
                            ? getLocationMessage(doc[Dbkeys.content], doc,
                                saved: false)
                            : doc[Dbkeys.messageType] == MessageType.doc.index
                                ? getDocmessage(
                                    context, doc[Dbkeys.content], doc,
                                    saved: false)
                                : doc[Dbkeys.messageType] ==
                                        MessageType.audio.index
                                    ? getAudiomessage(
                                        context, doc[Dbkeys.content], doc,
                                        isMe: isMe, saved: false)
                                    : doc[Dbkeys.messageType] ==
                                            MessageType.video.index
                                        ? getVideoMessage(
                                            context, doc[Dbkeys.content], doc,
                                            saved: false)
                                        : doc[Dbkeys.messageType] ==
                                                MessageType.contact.index
                                            ? getContactMessage(context,
                                                doc[Dbkeys.content], doc,
                                                saved: false)
                                            : getImageMessage(
                                                doc,
                                                saved: saved,
                                              ),
                isMe: isMe,
                delivered: true,
                isContinuing: true,
                timestamp: doc[Dbkeys.groupmsgTIME],
              ),
            ));
  }

  Widget getVideoMessage(
      BuildContext context, String message, Map<String, dynamic> doc,
      {bool saved = false}) {
    Map<dynamic, dynamic>? meta =
        jsonDecode((message.split('-BREAK-')[2]).toString());
    final bool isMe = doc[Dbkeys.groupmsgSENDBY] == widget.currentUserno;
    return Container(
      child: InkWell(
        onTap: () {
          Navigator.push(
              this.context,
              new MaterialPageRoute(
                  builder: (context) => new PreviewVideo(
                        prefs: widget.prefs,
                        isdownloadallowed: true,
                        filename: message.split('-BREAK-')[1],
                        id: null,
                        videourl: message.split('-BREAK-')[0],
                        aspectratio: meta!["width"] / meta["height"],
                      )));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            doc.containsKey(Dbkeys.isForward) == true
                ? doc[Dbkeys.isForward] == true
                    ? Container(
                        margin: EdgeInsets.only(bottom: 10),
                        child: Row(
                            mainAxisAlignment: isMe == true
                                ? MainAxisAlignment.start
                                : MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                FontAwesomeIcons.share,
                                size: 12,
                                color: fiberchatGrey.withOpacity(0.5),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(getTranslated(this.context, 'forwarded'),
                                  maxLines: 1,
                                  style: TextStyle(
                                      color: fiberchatGrey.withOpacity(0.7),
                                      fontStyle: FontStyle.italic,
                                      overflow: TextOverflow.ellipsis,
                                      fontSize: 13))
                            ]))
                    : SizedBox(height: 0, width: 0)
                : SizedBox(height: 0, width: 0),
            Container(
              color: Colors.blueGrey,
              width: 245,
              height: 245,
              child: Stack(
                children: [
                  CachedNetworkImage(
                    placeholder: (context, url) => Container(
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.blueGrey[400]!),
                        ),
                      ),
                      width: 245,
                      height: 245,
                      padding: EdgeInsets.all(80.0),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey,
                        borderRadius: BorderRadius.all(
                          Radius.circular(0.0),
                        ),
                      ),
                    ),
                    errorWidget: (context, str, error) => Material(
                      child: Image.asset(
                        'assets/images/img_not_available.jpeg',
                        width: 245,
                        height: 245,
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(0.0),
                      ),
                      clipBehavior: Clip.hardEdge,
                    ),
                    imageUrl: message.split('-BREAK-')[1],
                    width: 245,
                    height: 245,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    color: Colors.black.withOpacity(0.4),
                    width: 245,
                    height: 245,
                  ),
                  Center(
                    child: Icon(Icons.play_circle_fill_outlined,
                        color: Colors.white70, size: 65),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getContactMessage(
      BuildContext context, String message, Map<String, dynamic> doc,
      {bool saved = false}) {
    final bool isMe = doc[Dbkeys.groupmsgSENDBY] == widget.currentUserno;
    return SizedBox(
      width: 210,
      height: 100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          doc.containsKey(Dbkeys.isForward) == true
              ? doc[Dbkeys.isForward] == true
                  ? Container(
                      margin: EdgeInsets.only(bottom: 10),
                      child: Row(
                          mainAxisAlignment: isMe == true
                              ? MainAxisAlignment.start
                              : MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              FontAwesomeIcons.share,
                              size: 12,
                              color: fiberchatGrey.withOpacity(0.5),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(getTranslated(this.context, 'forwarded'),
                                maxLines: 1,
                                style: TextStyle(
                                    color: fiberchatGrey.withOpacity(0.7),
                                    fontStyle: FontStyle.italic,
                                    overflow: TextOverflow.ellipsis,
                                    fontSize: 13))
                          ]))
                  : SizedBox(height: 0, width: 0)
              : SizedBox(height: 0, width: 0),
          ListTile(
            isThreeLine: false,
            leading: customCircleAvatar(url: null, radius: 20),
            title: Text(
              message.split('-BREAK-')[0],
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                  height: 1.4,
                  fontWeight: FontWeight.w700,
                  color: Colors.blue[400]),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(
                message.split('-BREAK-')[1],
                style: TextStyle(
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getTextMessage(bool isMe, Map<String, dynamic> doc, bool saved) {
    return doc.containsKey(Dbkeys.isReply) == true
        ? doc[Dbkeys.isReply] == true
            ? Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  replyAttachedWidget(this.context, doc[Dbkeys.replyToMsgDoc]),
                  SizedBox(
                    height: 10,
                  ),
                  selectablelinkify(doc[Dbkeys.content], 15.5, TextAlign.left),
                ],
              )
            : doc.containsKey(Dbkeys.isForward) == true
                ? doc[Dbkeys.isForward] == true
                    ? Column(
                        crossAxisAlignment: isMe
                            ? CrossAxisAlignment.start
                            : CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                              child: Row(
                                  mainAxisAlignment: isMe == true
                                      ? MainAxisAlignment.start
                                      : MainAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                Icon(
                                  FontAwesomeIcons.share,
                                  size: 12,
                                  color: fiberchatGrey.withOpacity(0.5),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(getTranslated(this.context, 'forwarded'),
                                    maxLines: 1,
                                    style: TextStyle(
                                        color: fiberchatGrey.withOpacity(0.7),
                                        fontStyle: FontStyle.italic,
                                        overflow: TextOverflow.ellipsis,
                                        fontSize: 13))
                              ])),
                          SizedBox(
                            height: 10,
                          ),
                          selectablelinkify(
                              doc[Dbkeys.content], 15.5, TextAlign.left)
                        ],
                      )
                    : selectablelinkify(
                        doc[Dbkeys.content], 15.5, TextAlign.left)
                : selectablelinkify(doc[Dbkeys.content], 15.5, TextAlign.left)
        : selectablelinkify(doc[Dbkeys.content], 15.5, TextAlign.left);
  }

  Widget getLocationMessage(String? message, Map<String, dynamic> doc,
      {bool saved = false}) {
    final bool isMe = doc[Dbkeys.groupmsgSENDBY] == widget.currentUserno;
    return InkWell(
      onTap: () {
        custom_url_launcher(message!);
      },
      child: doc.containsKey(Dbkeys.isForward) == true
          ? doc[Dbkeys.isForward] == true
              ? Column(
                  crossAxisAlignment:
                      isMe ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                        child: Row(
                            mainAxisAlignment: isMe == true
                                ? MainAxisAlignment.start
                                : MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                          Icon(
                            FontAwesomeIcons.share,
                            size: 12,
                            color: fiberchatGrey.withOpacity(0.5),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(getTranslated(this.context, 'forwarded'),
                              maxLines: 1,
                              style: TextStyle(
                                  color: fiberchatGrey.withOpacity(0.7),
                                  fontStyle: FontStyle.italic,
                                  overflow: TextOverflow.ellipsis,
                                  fontSize: 13))
                        ])),
                    SizedBox(
                      height: 10,
                    ),
                    Image.asset(
                      'assets/images/mapview.jpg',
                      width: MediaQuery.of(this.context).size.width / 1.7,
                      height:
                          (MediaQuery.of(this.context).size.width / 1.7) * 0.6,
                    ),
                  ],
                )
              : Image.asset(
                  'assets/images/mapview.jpg',
                  width: MediaQuery.of(this.context).size.width / 1.7,
                  height: (MediaQuery.of(this.context).size.width / 1.7) * 0.6,
                )
          : Image.asset(
              'assets/images/mapview.jpg',
              width: MediaQuery.of(this.context).size.width / 1.7,
              height: (MediaQuery.of(this.context).size.width / 1.7) * 0.6,
            ),
    );
  }

  Widget getAudiomessage(
      BuildContext context, String message, Map<String, dynamic> doc,
      {bool saved = false, bool isMe = true}) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      // width: 250,
      // height: 116,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          doc.containsKey(Dbkeys.isForward) == true
              ? doc[Dbkeys.isForward] == true
                  ? Container(
                      margin: EdgeInsets.only(bottom: 10),
                      child: Row(
                          mainAxisAlignment: isMe == true
                              ? MainAxisAlignment.start
                              : MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              FontAwesomeIcons.share,
                              size: 12,
                              color: fiberchatGrey.withOpacity(0.5),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(getTranslated(this.context, 'forwarded'),
                                maxLines: 1,
                                style: TextStyle(
                                    color: fiberchatGrey.withOpacity(0.7),
                                    fontStyle: FontStyle.italic,
                                    overflow: TextOverflow.ellipsis,
                                    fontSize: 13))
                          ]))
                  : SizedBox(height: 0, width: 0)
              : SizedBox(height: 0, width: 0),
          SizedBox(
            width: 200,
            height: 80,
            child: MultiPlayback(
              isMe: isMe,
              onTapDownloadFn: () async {
                await MobileDownloadService().download(
                    prefs: widget.prefs,
                    keyloader: _keyLoader,
                    url: message.split('-BREAK-')[0],
                    fileName:
                        'Recording_' + message.split('-BREAK-')[1] + '.mp3',
                    context: this.context,
                    isOpenAfterDownload: true);
              },
              url: message.split('-BREAK-')[0],
            ),
          )
        ],
      ),
    );
  }

  Widget getDocmessage(
      BuildContext context, String message, Map<String, dynamic> doc,
      {bool saved = false}) {
    final bool isMe = doc[Dbkeys.groupmsgSENDBY] == widget.currentUserno;
    return SizedBox(
      width: 220,
      height: 126,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          doc.containsKey(Dbkeys.isForward) == true
              ? doc[Dbkeys.isForward] == true
                  ? Container(
                      margin: EdgeInsets.only(bottom: 10),
                      child: Row(
                          mainAxisAlignment: isMe == true
                              ? MainAxisAlignment.start
                              : MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              FontAwesomeIcons.share,
                              size: 12,
                              color: fiberchatGrey.withOpacity(0.5),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(getTranslated(this.context, 'forwarded'),
                                maxLines: 1,
                                style: TextStyle(
                                    color: fiberchatGrey.withOpacity(0.7),
                                    fontStyle: FontStyle.italic,
                                    overflow: TextOverflow.ellipsis,
                                    fontSize: 13))
                          ]))
                  : SizedBox(height: 0, width: 0)
              : SizedBox(height: 0, width: 0),
          ListTile(
            contentPadding: EdgeInsets.all(4),
            isThreeLine: false,
            leading: Container(
              decoration: BoxDecoration(
                color: Colors.yellow[800],
                borderRadius: BorderRadius.circular(7.0),
              ),
              padding: EdgeInsets.all(12),
              child: Icon(
                Icons.insert_drive_file,
                size: 25,
                color: Colors.white,
              ),
            ),
            title: Text(
              message.split('-BREAK-')[1],
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: TextStyle(
                  height: 1.4,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87),
            ),
          ),
          Divider(
            height: 3,
          ),
          message.split('-BREAK-')[1].endsWith('.pdf')
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: Colors.transparent,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute<dynamic>(
                              builder: (_) => PDFViewerCachedFromUrl(
                                prefs: widget.prefs,
                                title: message.split('-BREAK-')[1],
                                url: message.split('-BREAK-')[0],
                                isregistered: true,
                              ),
                            ),
                          );
                        },
                        child: Text(getTranslated(context, 'preview'),
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.blue[400]))),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: Colors.transparent,
                        ),
                        onPressed: () async {
                          await MobileDownloadService().download(
                              prefs: widget.prefs,
                              url: message.split('-BREAK-')[0],
                              fileName: message.split('-BREAK-')[1],
                              context: context,
                              keyloader: _keyLoader,
                              isOpenAfterDownload: true);
                        },
                        child: Text(getTranslated(context, 'download'),
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.blue[400]))),
                  ],
                )
              : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                  ),
                  onPressed: () async {
                    await MobileDownloadService().download(
                        prefs: widget.prefs,
                        url: message.split('-BREAK-')[0],
                        fileName: message.split('-BREAK-')[1],
                        context: context,
                        keyloader: _keyLoader,
                        isOpenAfterDownload: true);
                  },
                  child: Text(getTranslated(context, 'download'),
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.blue[400]))),
        ],
      ),
    );
  }

  Widget getImageMessage(Map<String, dynamic> doc, {bool saved = false}) {
    final bool isMe = doc[Dbkeys.groupmsgSENDBY] == widget.currentUserno;
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          doc.containsKey(Dbkeys.isForward) == true
              ? doc[Dbkeys.isForward] == true
                  ? Container(
                      margin: EdgeInsets.only(bottom: 10),
                      child: Row(
                          mainAxisAlignment: isMe == true
                              ? MainAxisAlignment.start
                              : MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              FontAwesomeIcons.share,
                              size: 12,
                              color: fiberchatGrey.withOpacity(0.5),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(getTranslated(this.context, 'forwarded'),
                                maxLines: 1,
                                style: TextStyle(
                                    color: fiberchatGrey.withOpacity(0.7),
                                    fontStyle: FontStyle.italic,
                                    overflow: TextOverflow.ellipsis,
                                    fontSize: 13))
                          ]))
                  : SizedBox(height: 0, width: 0)
              : SizedBox(height: 0, width: 0),
          saved
              ? Material(
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: Save.getImageFromBase64(doc[Dbkeys.content])
                              .image,
                          fit: BoxFit.cover),
                    ),
                    width: doc[Dbkeys.content].contains('giphy') ? 160 : 245.0,
                    height: doc[Dbkeys.content].contains('giphy') ? 160 : 245.0,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(8.0),
                  ),
                  clipBehavior: Clip.hardEdge,
                )
              : InkWell(
                  onTap: () => Navigator.push(
                      this.context,
                      MaterialPageRoute(
                        builder: (context) => PhotoViewWrapper(
                          prefs: widget.prefs,
                          keyloader: _keyLoader,
                          imageUrl: doc[Dbkeys.content],
                          message: doc[Dbkeys.content],
                          tag: doc[Dbkeys.groupmsgTIME].toString(),
                          imageProvider:
                              CachedNetworkImageProvider(doc[Dbkeys.content]),
                        ),
                      )),
                  child: CachedNetworkImage(
                    placeholder: (context, url) => Container(
                      child: Center(
                        child: SizedBox(
                          height: 60.0,
                          width: 60.0,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.blueGrey[400]!),
                          ),
                        ),
                      ),
                      width:
                          doc[Dbkeys.content].contains('giphy') ? 160 : 245.0,
                      height:
                          doc[Dbkeys.content].contains('giphy') ? 160 : 245.0,
                      padding: EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey,
                        borderRadius: BorderRadius.all(
                          Radius.circular(8.0),
                        ),
                      ),
                    ),
                    errorWidget: (context, str, error) => Material(
                      child: Image.asset(
                        'assets/images/img_not_available.jpeg',
                        width:
                            doc[Dbkeys.content].contains('giphy') ? 160 : 245.0,
                        height:
                            doc[Dbkeys.content].contains('giphy') ? 160 : 245.0,
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(8.0),
                      ),
                      clipBehavior: Clip.hardEdge,
                    ),
                    imageUrl: doc[Dbkeys.content],
                    width: doc[Dbkeys.content].contains('giphy') ? 160 : 245.0,
                    height: doc[Dbkeys.content].contains('giphy') ? 160 : 245.0,
                    fit: BoxFit.cover,
                  ),
                ),
        ],
      ),
    );
  }

  replyAttachedWidget(BuildContext context, var doc) {
    return Consumer<SmartContactProviderWithLocalStoreData>(
        builder: (context, contactsProvider, _child) => Flexible(
              child: Container(
                  // width: 280,
                  height: 70,
                  margin: EdgeInsets.only(left: 0, right: 0),
                  decoration: BoxDecoration(
                      color: fiberchatWhite.withOpacity(0.55),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: Stack(
                    children: [
                      Container(
                          margin: EdgeInsetsDirectional.all(4),
                          decoration: BoxDecoration(
                              color: fiberchatGrey.withOpacity(0.1),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8))),
                          child: Row(children: [
                            Container(
                              decoration: BoxDecoration(
                                color: doc[Dbkeys.groupmsgSENDBY] ==
                                        widget.currentUserno
                                    ? fiberchatPRIMARYcolor
                                    : Colors.purple,
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(0),
                                    bottomRight: Radius.circular(0),
                                    topLeft: Radius.circular(10),
                                    bottomLeft: Radius.circular(10)),
                              ),
                              height: 75,
                              width: 3.3,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Expanded(
                                child: Container(
                              padding: EdgeInsetsDirectional.all(5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(right: 30),
                                    child: Text(
                                      doc[Dbkeys.groupmsgSENDBY] ==
                                              widget.currentUserno
                                          ? getTranslated(this.context, 'you')
                                          : contactsProvider
                                                      .alreadyJoinedSavedUsersPhoneNameAsInServer
                                                      .indexWhere((element) =>
                                                          element.phone ==
                                                          doc[Dbkeys
                                                              .groupmsgSENDBY]) >=
                                                  0
                                              ? contactsProvider
                                                      .alreadyJoinedSavedUsersPhoneNameAsInServer[
                                                          contactsProvider
                                                              .alreadyJoinedSavedUsersPhoneNameAsInServer
                                                              .indexWhere((element) =>
                                                                  element
                                                                      .phone ==
                                                                  doc[Dbkeys
                                                                      .groupmsgSENDBY])]
                                                      .name ??
                                                  doc[Dbkeys.groupmsgSENDBY]
                                                      .toString()
                                              : doc[Dbkeys.groupmsgSENDBY]
                                                  .toString(),
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: doc[Dbkeys.groupmsgSENDBY] ==
                                                  widget.currentUserno
                                              ? fiberchatPRIMARYcolor
                                              : Colors.purple),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  doc[Dbkeys.messageType] ==
                                          MessageType.text.index
                                      ? Text(
                                          doc[Dbkeys.content],
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style:
                                              TextStyle(color: fiberchatBlack),
                                        )
                                      : doc[Dbkeys.messageType] ==
                                              MessageType.doc.index
                                          ? Container(
                                              padding: const EdgeInsets.only(
                                                  right: 75),
                                              child: Text(
                                                doc[Dbkeys.content]
                                                    .split('-BREAK-')[1],
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                                style: TextStyle(
                                                    color: fiberchatBlack),
                                              ),
                                            )
                                          : Text(
                                              getTranslated(
                                                  this.context,
                                                  doc[Dbkeys.messageType] ==
                                                          MessageType
                                                              .image.index
                                                      ? 'nim'
                                                      : doc[Dbkeys.messageType] ==
                                                              MessageType
                                                                  .video.index
                                                          ? 'nvm'
                                                          : doc[Dbkeys.messageType] ==
                                                                  MessageType
                                                                      .audio
                                                                      .index
                                                              ? 'nam'
                                                              : doc[Dbkeys.messageType] ==
                                                                      MessageType
                                                                          .contact
                                                                          .index
                                                                  ? 'ncm'
                                                                  : doc[Dbkeys.messageType] ==
                                                                          MessageType
                                                                              .location
                                                                              .index
                                                                      ? 'nlm'
                                                                      : doc[Dbkeys.messageType] ==
                                                                              MessageType.doc.index
                                                                          ? 'ndm'
                                                                          : ''),
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  color: fiberchatBlack),
                                            ),
                                ],
                              ),
                            ))
                          ])),
                      doc[Dbkeys.messageType] == MessageType.text.index ||
                              doc[Dbkeys.messageType] ==
                                  MessageType.location.index
                          ? SizedBox(
                              width: 0,
                              height: 0,
                            )
                          : doc[Dbkeys.messageType] == MessageType.image.index
                              ? Positioned(
                                  right: -2,
                                  top: -2,
                                  child: Container(
                                    width: 74.0,
                                    height: 74.0,
                                    padding: EdgeInsetsDirectional.all(6),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(5),
                                          bottomRight: Radius.circular(5),
                                          topLeft: Radius.circular(0),
                                          bottomLeft: Radius.circular(0)),
                                      child: CachedNetworkImage(
                                        placeholder: (context, url) =>
                                            Container(
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    fiberchatSECONDARYolor),
                                          ),
                                          width: doc[Dbkeys.content]
                                                  .contains('giphy')
                                              ? 60
                                              : 60.0,
                                          height: doc[Dbkeys.content]
                                                  .contains('giphy')
                                              ? 60
                                              : 60.0,
                                          padding: EdgeInsets.all(8.0),
                                          decoration: BoxDecoration(
                                            color: Colors.blueGrey[200],
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(8.0),
                                            ),
                                          ),
                                        ),
                                        errorWidget: (context, str, error) =>
                                            Material(
                                          child: Image.asset(
                                            'assets/images/img_not_available.jpeg',
                                            width: 60.0,
                                            height: 60,
                                            fit: BoxFit.cover,
                                          ),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(8.0),
                                          ),
                                          clipBehavior: Clip.hardEdge,
                                        ),
                                        imageUrl: doc[Dbkeys.messageType] ==
                                                MessageType.video.index
                                            ? ''
                                            : doc[Dbkeys.content],
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                )
                              : doc[Dbkeys.messageType] ==
                                      MessageType.video.index
                                  ? Positioned(
                                      right: -2,
                                      top: -2,
                                      child: Container(
                                          width: 74.0,
                                          height: 74.0,
                                          padding: EdgeInsetsDirectional.all(6),
                                          child: ClipRRect(
                                              borderRadius: BorderRadius.only(
                                                  topRight: Radius.circular(5),
                                                  bottomRight:
                                                      Radius.circular(5),
                                                  topLeft: Radius.circular(0),
                                                  bottomLeft:
                                                      Radius.circular(0)),
                                              child: Container(
                                                color: Colors.blueGrey[200],
                                                height: 74,
                                                width: 74,
                                                child: Stack(
                                                  children: [
                                                    CachedNetworkImage(
                                                      placeholder:
                                                          (context, url) =>
                                                              Container(
                                                        child:
                                                            CircularProgressIndicator(
                                                          valueColor:
                                                              AlwaysStoppedAnimation<
                                                                      Color>(
                                                                  fiberchatSECONDARYolor),
                                                        ),
                                                        width: 74,
                                                        height: 74,
                                                        padding:
                                                            EdgeInsets.all(8.0),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors
                                                              .blueGrey[200],
                                                          borderRadius:
                                                              BorderRadius.all(
                                                            Radius.circular(
                                                                0.0),
                                                          ),
                                                        ),
                                                      ),
                                                      errorWidget: (context,
                                                              str, error) =>
                                                          Material(
                                                        child: Image.asset(
                                                          'assets/images/img_not_available.jpeg',
                                                          width: 60,
                                                          height: 60,
                                                          fit: BoxFit.cover,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.all(
                                                          Radius.circular(0.0),
                                                        ),
                                                        clipBehavior:
                                                            Clip.hardEdge,
                                                      ),
                                                      imageUrl:
                                                          doc[Dbkeys.content]
                                                              .split(
                                                                  '-BREAK-')[1],
                                                      width: 74,
                                                      height: 74,
                                                      fit: BoxFit.cover,
                                                    ),
                                                    Container(
                                                      color: Colors.black
                                                          .withOpacity(0.4),
                                                      height: 74,
                                                      width: 74,
                                                    ),
                                                    Center(
                                                      child: Icon(
                                                          Icons
                                                              .play_circle_fill_outlined,
                                                          color: Colors.white70,
                                                          size: 25),
                                                    ),
                                                  ],
                                                ),
                                              ))))
                                  : Positioned(
                                      right: -2,
                                      top: -2,
                                      child: Container(
                                          width: 74.0,
                                          height: 74.0,
                                          padding: EdgeInsetsDirectional.all(6),
                                          child: ClipRRect(
                                              borderRadius: BorderRadius.only(
                                                  topRight: Radius.circular(5),
                                                  bottomRight:
                                                      Radius.circular(5),
                                                  topLeft: Radius.circular(0),
                                                  bottomLeft:
                                                      Radius.circular(0)),
                                              child: Container(
                                                  color: doc[Dbkeys.messageType] ==
                                                          MessageType.doc.index
                                                      ? Colors.yellow[800]
                                                      : doc[Dbkeys.messageType] ==
                                                              MessageType
                                                                  .audio.index
                                                          ? fiberchatGreenColor400
                                                          : doc[Dbkeys.messageType] ==
                                                                  MessageType
                                                                      .location
                                                                      .index
                                                              ? Colors.red[700]
                                                              : doc[Dbkeys.messageType] ==
                                                                      MessageType
                                                                          .contact
                                                                          .index
                                                                  ? Colors
                                                                      .blue[400]
                                                                  : Colors
                                                                      .cyan[700],
                                                  height: 74,
                                                  width: 74,
                                                  child: Icon(
                                                    doc[Dbkeys.messageType] ==
                                                            MessageType
                                                                .doc.index
                                                        ? Icons
                                                            .insert_drive_file
                                                        : doc[Dbkeys.messageType] ==
                                                                MessageType
                                                                    .audio.index
                                                            ? Icons.mic_rounded
                                                            : doc[Dbkeys.messageType] ==
                                                                    MessageType
                                                                        .location
                                                                        .index
                                                                ? Icons
                                                                    .location_on
                                                                : doc[Dbkeys.messageType] ==
                                                                        MessageType
                                                                            .contact
                                                                            .index
                                                                    ? Icons
                                                                        .contact_page_sharp
                                                                    : Icons
                                                                        .insert_drive_file,
                                                    color: Colors.white,
                                                    size: 35,
                                                  ))))),
                    ],
                  )),
            ));
  }

  Future<bool> checkIfLocationEnabled() async {
    if (await Permission.location.request().isGranted) {
      return true;
    } else if (await Permission.locationAlways.request().isGranted) {
      return true;
    } else if (await Permission.locationWhenInUse.request().isGranted) {
      return true;
    } else {
      return false;
    }
  }

  Future<Position> _determinePosition() async {
    return await Geolocator.getCurrentPosition();
  }

  Widget buildMessagesUsingProvider(BuildContext context) {
    return Consumer<List<GroupModel>>(
        builder: (context, groupList, _child) =>
            Consumer<FirestoreDataProviderMESSAGESforGROUPCHAT>(
                builder: (context, firestoreDataProvider, _) =>
                    InfiniteCOLLECTIONListViewWidget(
                      prefs: widget.prefs,
                      scrollController: realtime,
                      isreverse: true,
                      firestoreDataProviderMESSAGESforGROUPCHAT:
                          firestoreDataProvider,
                      datatype: Dbkeys.datatypeGROUPCHATMSGS,
                      refdata: firestoreChatquery,
                      list: ListView.builder(
                          reverse: true,
                          padding: EdgeInsets.all(7),
                          physics: BouncingScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: firestoreDataProvider.recievedDocs.length,
                          itemBuilder: (BuildContext context, int i) {
                            var dc = firestoreDataProvider.recievedDocs[i];

                            return buildEachMessage(
                                dc,
                                groupList.lastWhere((element) =>
                                    element.docmap[Dbkeys.groupID] ==
                                    widget.groupID));
                          }),
                    )));
  }

  Widget buildLoadingThumbnail() {
    return Positioned(
      child: isgeneratingSomethingLoader
          ? Container(
              child: Center(
                child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(fiberchatSECONDARYolor)),
              ),
              color: pickTextColorBasedOnBgColorAdvanced(
                      !Thm.isDarktheme(widget.prefs)
                          ? fiberchatCONTAINERboxColorDarkMode
                          : fiberchatCONTAINERboxColorLightMode)
                  .withOpacity(0.6),
            )
          : Container(),
    );
  }

  shareMedia(BuildContext context) {
    showModalBottomSheet(
        backgroundColor: Thm.isDarktheme(widget.prefs)
            ? fiberchatDIALOGColorDarkMode
            : fiberchatDIALOGColorLightMode,
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
        ),
        builder: (BuildContext context) {
          // return your layout
          return Container(
            padding: EdgeInsets.all(12),
            height: 250,
            child: Column(children: [
              SizedBox(
                height: 20,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 3.27,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        RawMaterialButton(
                          disabledElevation: 0,
                          onPressed: () {
                            hidekeyboard(context);
                            Navigator.of(context).pop();
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MultiDocumentPicker(
                                          prefs: widget.prefs,
                                          title: getTranslated(
                                              this.context, 'pickdoc'),
                                          callback: getFileData,
                                          writeMessage:
                                              (String? url, int time) async {
                                            if (url != null) {
                                              String finalUrl = url +
                                                  '-BREAK-' +
                                                  basename(pickedFile!.path)
                                                      .toString();
                                              onSendMessage(
                                                  context: this.context,
                                                  content: finalUrl,
                                                  type: MessageType.doc,
                                                  timestamp: time);
                                            }
                                          },
                                        )));
                          },
                          elevation: .5,
                          fillColor: Colors.indigo,
                          child: Icon(
                            Icons.file_copy,
                            size: 25.0,
                            color: Colors.white,
                          ),
                          padding: EdgeInsets.all(15.0),
                          shape: CircleBorder(),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          getTranslated(this.context, 'doc'),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: fiberchatGrey, fontSize: 14),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 3.27,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        RawMaterialButton(
                          disabledElevation: 0,
                          onPressed: () async {
                            hidekeyboard(context);
                            Navigator.of(context).pop();
                            File? selectedMedia =
                                await pickVideoFromgallery(context)
                                    .catchError((err) {
                              Fiberchat.toast(
                                  getTranslated(context, "invalidfile"));
                              return null;
                            });

                            if (selectedMedia == null) {
                              setStatusBarColor(widget.prefs);
                            } else {
                              setStatusBarColor(widget.prefs);
                              String fileExtension =
                                  p.extension(selectedMedia.path).toLowerCase();

                              if (fileExtension == ".mp4" ||
                                  fileExtension == ".mov") {
                                final tempDir = await getTemporaryDirectory();
                                File file = await File(
                                        '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.mp4')
                                    .create();
                                file.writeAsBytesSync(
                                    selectedMedia.readAsBytesSync());

                                await Navigator.push(
                                    this.context,
                                    new MaterialPageRoute(
                                        builder: (context) => new VideoEditor(
                                            prefs: widget.prefs,
                                            onClose: () {
                                              setStatusBarColor(widget.prefs);
                                            },
                                            thumbnailQuality: 90,
                                            videoQuality: 100,
                                            maxDuration: 1900,
                                            onEditExported: (videoFile,
                                                thumnailFile) async {
                                              int timeStamp = DateTime.now()
                                                  .millisecondsSinceEpoch;
                                              String videoFileext =
                                                  p.extension(file.path);
                                              String videofileName =
                                                  'Video-$timeStamp$videoFileext';
                                              String? videoUrl =
                                                  await uploadSelectedLocalFileWithProgressIndicator(
                                                      file,
                                                      true,
                                                      false,
                                                      timeStamp,
                                                      filenameoptional:
                                                          videofileName);
                                              if (videoUrl != null) {
                                                String? thumnailUrl =
                                                    await uploadSelectedLocalFileWithProgressIndicator(
                                                        thumnailFile,
                                                        false,
                                                        true,
                                                        timeStamp);
                                                if (thumnailUrl != null) {
                                                  onSendMessage(
                                                    context: this.context,
                                                    content: videoUrl +
                                                        '-BREAK-' +
                                                        thumnailUrl +
                                                        '-BREAK-' +
                                                        videometadata! +
                                                        '-BREAK-' +
                                                        "$videofileName",
                                                    type: MessageType.video,
                                                  );
                                                  file.delete();
                                                  thumnailFile.delete();
                                                }
                                              }
                                            },
                                            file: File(file.path))));
                              } else {
                                Fiberchat.toast(
                                    "File type not supported. Please choose a valid .mp4, .mov file. \n\nSelected file was $fileExtension ");
                              }
                            }
                          },
                          elevation: .5,
                          fillColor: Colors.pink[600],
                          child: Icon(
                            Icons.video_collection_sharp,
                            size: 25.0,
                            color: Colors.white,
                          ),
                          padding: EdgeInsets.all(15.0),
                          shape: CircleBorder(),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          getTranslated(this.context, 'video'),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: fiberchatGrey, fontSize: 14),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 3.27,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        RawMaterialButton(
                          disabledElevation: 0,
                          onPressed: () {
                            //changed by JH
                            hidekeyboard(context);
                            Navigator.of(context).pop();

                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MultiImagePicker(
                                          title: getTranslated(
                                              this.context, 'pickimage'),
                                          prefs: widget.prefs,
                                          callback: getFileData,
                                          writeMessage:
                                              (String? url, int time) async {
                                            if (url != null) {
                                              onSendMessage(
                                                  context: this.context,
                                                  content: url,
                                                  type: MessageType.image,
                                                  timestamp: time);
                                            }
                                          },
                                        )));
                          },
                          elevation: .5,
                          fillColor: Colors.purple,
                          child: Icon(
                            Icons.image_rounded,
                            size: 25.0,
                            color: Colors.white,
                          ),
                          padding: EdgeInsets.all(15.0),
                          shape: CircleBorder(),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          getTranslated(this.context, 'image'),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: fiberchatGrey, fontSize: 14),
                        )
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 3.27,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        RawMaterialButton(
                          disabledElevation: 0,
                          onPressed: () {
                            hidekeyboard(context);

                            Navigator.of(context).pop();
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AudioRecord(
                                          prefs: widget.prefs,
                                          title: getTranslated(
                                              this.context, 'record'),
                                          callback: getFileData,
                                        ))).then((url) {
                              if (url != null) {
                                onSendMessage(
                                  context: this.context,
                                  content: url +
                                      '-BREAK-' +
                                      uploadTimestamp.toString(),
                                  type: MessageType.audio,
                                );
                              } else {}
                            });
                          },
                          elevation: .5,
                          fillColor: Colors.yellow[900],
                          child: Icon(
                            Icons.mic_rounded,
                            size: 25.0,
                            color: Colors.white,
                          ),
                          padding: EdgeInsets.all(15.0),
                          shape: CircleBorder(),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          getTranslated(this.context, 'audio'),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: fiberchatGrey),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 3.27,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        RawMaterialButton(
                          disabledElevation: 0,
                          onPressed: () async {
                            hidekeyboard(context);
                            Navigator.of(context).pop();
                            await checkIfLocationEnabled().then((value) async {
                              if (value == true) {
                                Fiberchat.toast(getTranslated(
                                    this.context, 'detectingloc'));
                                await _determinePosition().then(
                                  (location) async {
                                    var locationstring =
                                        'https://www.google.com/maps/search/?api=1&query=${location.latitude},${location.longitude}';
                                    onSendMessage(
                                      context: this.context,
                                      content: locationstring,
                                      type: MessageType.location,
                                    );
                                    setStateIfMounted(() {});
                                    Fiberchat.toast(
                                      getTranslated(this.context, 'sent'),
                                    );
                                  },
                                );
                              } else {
                                Fiberchat.toast(getTranslated(
                                    this.context, 'locationdenied'));
                                openAppSettings();
                              }
                            });
                          },
                          elevation: .5,
                          fillColor: Colors.cyan[700],
                          child: Icon(
                            Icons.location_on,
                            size: 25.0,
                            color: Colors.white,
                          ),
                          padding: EdgeInsets.all(15.0),
                          shape: CircleBorder(),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          getTranslated(this.context, 'location'),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: fiberchatGrey),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 3.27,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        RawMaterialButton(
                          disabledElevation: 0,
                          onPressed: () async {
                            hidekeyboard(context);
                            Navigator.of(context).pop();
                            await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ContactsSelect(
                                        currentUserNo: widget.currentUserno,
                                        model: widget.model,
                                        biometricEnabled: false,
                                        prefs: widget.prefs,
                                        onSelect: (name, phone) {
                                          onSendMessage(
                                            context: context,
                                            content: '$name-BREAK-$phone',
                                            type: MessageType.contact,
                                          );
                                        })));
                          },
                          elevation: .5,
                          fillColor: Colors.blue[800],
                          child: Icon(
                            Icons.person,
                            size: 25.0,
                            color: Colors.white,
                          ),
                          padding: EdgeInsets.all(15.0),
                          shape: CircleBorder(),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          getTranslated(this.context, 'contact'),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: fiberchatGrey),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ]),
          );
        });
  }

  Future<bool> onWillPop() {
    if (isemojiShowing == true) {
      setStateIfMounted(() {
        isemojiShowing = false;
      });
      Future.value(false);
    } else {
      setLastSeen(true, isemojiShowing);
      return Future.value(true);
    }
    return Future.value(false);
  }

  bool isemojiShowing = false;
  refreshInput() {
    setStateIfMounted(() {
      if (isemojiShowing == false) {
        keyboardFocusNode.unfocus();
        isemojiShowing = true;
      } else {
        isemojiShowing = false;
        keyboardFocusNode.requestFocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var _keyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;

    return PickupLayout(
        prefs: widget.prefs,
        scaffold: Fiberchat.getNTPWrappedWidget(Consumer<List<GroupModel>>(
            builder: (context, groupList, _child) => WillPopScope(
                  onWillPop: isgeneratingSomethingLoader == true
                      ? () async {
                          return Future.value(false);
                        }
                      : isemojiShowing == true
                          ? () {
                              setStateIfMounted(() {
                                isemojiShowing = false;
                                keyboardFocusNode.unfocus();
                              });
                              return Future.value(false);
                            }
                          : () async {
                              WidgetsBinding.instance
                                  .addPostFrameCallback((timeStamp) {
                                var currentpeer = Provider.of<CurrentChatPeer>(
                                    this.context,
                                    listen: false);
                                currentpeer.setpeer(newgroupChatId: '');
                              });
                              setLastSeen(false, false);

                              return Future.value(true);
                            },
                  child: Stack(
                    children: [
                      Scaffold(
                          key: _scaffold,
                          backgroundColor: Thm.isDarktheme(widget.prefs)
                              ? fiberchatCHATBACKGROUNDDarkMode
                              : fiberchatCHATBACKGROUNDLightMode,
                          appBar: AppBar(
                            elevation: 0.4,
                            titleSpacing: -10,
                            leading: Container(
                              margin: EdgeInsets.only(right: 0),
                              width: 10,
                              child: IconButton(
                                icon: Icon(
                                  Icons.arrow_back_ios,
                                  size: 20,
                                  color: pickTextColorBasedOnBgColorAdvanced(
                                      Thm.isDarktheme(widget.prefs)
                                          ? fiberchatAPPBARcolorDarkMode
                                          : fiberchatAPPBARcolorLightMode),
                                ),
                                onPressed: onWillPop,
                              ),
                            ),
                            backgroundColor: Thm.isDarktheme(widget.prefs)
                                ? fiberchatAPPBARcolorDarkMode
                                : fiberchatAPPBARcolorLightMode,
                            title: InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    new MaterialPageRoute(
                                        builder: (context) => new GroupDetails(
                                            model: widget.model,
                                            prefs: widget.prefs,
                                            currentUserno: widget.currentUserno,
                                            groupID: widget.groupID)));
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(0, 7, 0, 7),
                                      child: customCircleAvatarGroup(
                                          radius: 20,
                                          url: groupList
                                              .lastWhere((element) =>
                                                  element
                                                      .docmap[Dbkeys.groupID] ==
                                                  widget.groupID)
                                              .docmap[Dbkeys.groupPHOTOURL])),
                                  SizedBox(
                                    width: 7,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            groupList
                                                .lastWhere((element) =>
                                                    element.docmap[
                                                        Dbkeys.groupID] ==
                                                    widget.groupID)
                                                .docmap[Dbkeys.groupNAME],
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                color: pickTextColorBasedOnBgColorAdvanced(Thm
                                                        .isDarktheme(
                                                            widget.prefs)
                                                    ? fiberchatAPPBARcolorDarkMode
                                                    : fiberchatAPPBARcolorLightMode),
                                                fontSize: 17.0,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          isCurrentUserMuted
                                              ? Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 5.0),
                                                  child: Icon(
                                                    Icons.volume_off,
                                                    color: pickTextColorBasedOnBgColorAdvanced(Thm
                                                                .isDarktheme(
                                                                    widget
                                                                        .prefs)
                                                            ? fiberchatAPPBARcolorDarkMode
                                                            : fiberchatAPPBARcolorLightMode)
                                                        .withOpacity(0.5),
                                                    size: 17,
                                                  ),
                                                )
                                              : SizedBox(),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 6,
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                1.7,
                                        child: Text(
                                          getTranslated(
                                              context, 'tapherefrgrpinfo'),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: pickTextColorBasedOnBgColorAdvanced(Thm
                                                          .isDarktheme(
                                                              widget.prefs)
                                                      ? fiberchatAPPBARcolorDarkMode
                                                      : fiberchatAPPBARcolorLightMode)
                                                  .withOpacity(0.9),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              Container(
                                margin: EdgeInsets.only(right: 15, left: 15),
                                width: 25,
                                child: PopupMenuButton(
                                    icon: Padding(
                                      padding: const EdgeInsets.only(right: 0),
                                      child: Icon(
                                        Icons.more_vert_outlined,
                                        color: pickTextColorBasedOnBgColorAdvanced(
                                            Thm.isDarktheme(widget.prefs)
                                                ? fiberchatAPPBARcolorDarkMode
                                                : fiberchatAPPBARcolorLightMode),
                                      ),
                                    ),
                                    color: Thm.isDarktheme(widget.prefs)
                                        ? fiberchatDIALOGColorDarkMode
                                        : fiberchatDIALOGColorLightMode,
                                    onSelected: (dynamic val) {
                                      switch (val) {
                                        case 'mute':
                                          setStateIfMounted(() {
                                            isCurrentUserMuted =
                                                !isCurrentUserMuted;
                                          });

                                          FirebaseMessaging.instance
                                              .unsubscribeFromTopic(
                                                  "GROUP${widget.groupID.replaceAll(RegExp('-'), '').substring(1, widget.groupID.replaceAll(RegExp('-'), '').toString().length)}")
                                              .then((value) {
                                            FirebaseFirestore.instance
                                                .collection(
                                                    DbPaths.collectiongroups)
                                                .doc(widget.groupID)
                                                .update({
                                              Dbkeys.groupMUTEDMEMBERS:
                                                  FieldValue.arrayUnion(
                                                      [widget.currentUserno]),
                                            });
                                          }).catchError((err) {
                                            setStateIfMounted(() {
                                              isCurrentUserMuted =
                                                  !isCurrentUserMuted;
                                            });
                                            FirebaseFirestore.instance
                                                .collection(
                                                    DbPaths.collectiongroups)
                                                .doc(widget.groupID)
                                                .update({
                                              Dbkeys.groupMUTEDMEMBERS:
                                                  FieldValue.arrayRemove(
                                                      [widget.currentUserno]),
                                            });
                                          });

                                          break;
                                        case 'unmute':
                                          setStateIfMounted(() {
                                            isCurrentUserMuted =
                                                !isCurrentUserMuted;
                                          });

                                          FirebaseMessaging.instance
                                              .subscribeToTopic(
                                                  "GROUP${widget.groupID.replaceAll(RegExp('-'), '').substring(1, widget.groupID.replaceAll(RegExp('-'), '').toString().length)}")
                                              .then((value) {
                                            FirebaseFirestore.instance
                                                .collection(
                                                    DbPaths.collectiongroups)
                                                .doc(widget.groupID)
                                                .update({
                                              Dbkeys.groupMUTEDMEMBERS:
                                                  FieldValue.arrayRemove(
                                                      [widget.currentUserno]),
                                            });
                                          }).catchError((err) {
                                            setStateIfMounted(() {
                                              isCurrentUserMuted =
                                                  !isCurrentUserMuted;
                                            });
                                            FirebaseFirestore.instance
                                                .collection(
                                                    DbPaths.collectiongroups)
                                                .doc(widget.groupID)
                                                .update({
                                              Dbkeys.groupMUTEDMEMBERS:
                                                  FieldValue.arrayUnion(
                                                      [widget.currentUserno]),
                                            });
                                          });

                                          break;
                                        case 'report':
                                          showModalBottomSheet(
                                              backgroundColor: Thm.isDarktheme(
                                                      widget.prefs)
                                                  ? fiberchatDIALOGColorDarkMode
                                                  : fiberchatDIALOGColorLightMode,
                                              isScrollControlled: true,
                                              context: context,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.vertical(
                                                        top: Radius.circular(
                                                            25.0)),
                                              ),
                                              builder: (BuildContext context) {
                                                // return your layout
                                                var w = MediaQuery.of(context)
                                                    .size
                                                    .width;
                                                return Padding(
                                                  padding: EdgeInsets.only(
                                                      bottom:
                                                          MediaQuery.of(context)
                                                              .viewInsets
                                                              .bottom),
                                                  child: Container(
                                                      padding:
                                                          EdgeInsets.all(16),
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height /
                                                              2.6,
                                                      child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .stretch,
                                                          children: [
                                                            SizedBox(
                                                              height: 12,
                                                            ),
                                                            SizedBox(
                                                              height: 3,
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      left: 7),
                                                              child: Text(
                                                                getTranslated(
                                                                    this.context,
                                                                    'reportshort'),
                                                                textAlign:
                                                                    TextAlign
                                                                        .left,
                                                                style: TextStyle(
                                                                    color: pickTextColorBasedOnBgColorAdvanced(Thm.isDarktheme(widget
                                                                            .prefs)
                                                                        ? fiberchatDIALOGColorDarkMode
                                                                        : fiberchatDIALOGColorLightMode),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        16.5),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 10,
                                                            ),
                                                            Container(
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      top: 10),
                                                              padding:
                                                                  EdgeInsets
                                                                      .fromLTRB(
                                                                          0,
                                                                          0,
                                                                          0,
                                                                          0),
                                                              // height: 63,
                                                              height: 63,
                                                              width: w / 1.24,
                                                              child:
                                                                  InpuTextBox(
                                                                isDark: Thm
                                                                    .isDarktheme(
                                                                        widget
                                                                            .prefs),
                                                                controller:
                                                                    reportEditingController,
                                                                leftrightmargin:
                                                                    0,
                                                                showIconboundary:
                                                                    false,
                                                                boxcornerradius:
                                                                    5.5,
                                                                boxheight: 50,
                                                                hinttext: getTranslated(
                                                                    this.context,
                                                                    'reportdesc'),
                                                                prefixIconbutton:
                                                                    Icon(
                                                                  Icons.message,
                                                                  color: Colors
                                                                      .grey
                                                                      .withOpacity(
                                                                          0.5),
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: w / 10,
                                                            ),
                                                            myElevatedButton(
                                                                color:
                                                                    fiberchatPRIMARYcolor,
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .fromLTRB(
                                                                          10,
                                                                          15,
                                                                          10,
                                                                          15),
                                                                  child: Text(
                                                                    getTranslated(
                                                                        context,
                                                                        'report'),
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            18),
                                                                  ),
                                                                ),
                                                                onPressed:
                                                                    () async {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();

                                                                  DateTime
                                                                      time =
                                                                      DateTime
                                                                          .now();

                                                                  Map<String,
                                                                          dynamic>
                                                                      mapdata =
                                                                      {
                                                                    'title':
                                                                        'New report by User',
                                                                    'desc':
                                                                        '${reportEditingController.text}',
                                                                    'phone':
                                                                        '${widget.currentUserno}',
                                                                    'type':
                                                                        'Group Chat',
                                                                    'time': time
                                                                        .millisecondsSinceEpoch,
                                                                    'id': widget
                                                                        .groupID,
                                                                  };

                                                                  await FirebaseFirestore
                                                                      .instance
                                                                      .collection(
                                                                          'reports')
                                                                      .doc(time
                                                                          .millisecondsSinceEpoch
                                                                          .toString())
                                                                      .set(
                                                                          mapdata)
                                                                      .then(
                                                                          (value) async {
                                                                    showModalBottomSheet(
                                                                        backgroundColor: Thm.isDarktheme(widget.prefs)
                                                                            ? fiberchatDIALOGColorDarkMode
                                                                            : fiberchatDIALOGColorLightMode,
                                                                        isScrollControlled:
                                                                            true,
                                                                        context:
                                                                            context,
                                                                        shape:
                                                                            RoundedRectangleBorder(
                                                                          borderRadius:
                                                                              BorderRadius.vertical(top: Radius.circular(25.0)),
                                                                        ),
                                                                        builder:
                                                                            (BuildContext
                                                                                context) {
                                                                          return Container(
                                                                            height:
                                                                                220,
                                                                            child:
                                                                                Padding(
                                                                              padding: const EdgeInsets.all(28.0),
                                                                              child: Column(
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                children: [
                                                                                  Icon(Icons.check, color: fiberchatGreenColor400, size: 40),
                                                                                  SizedBox(
                                                                                    height: 30,
                                                                                  ),
                                                                                  Text(
                                                                                    getTranslated(context, 'reportsuccess'),
                                                                                    textAlign: TextAlign.center,
                                                                                    style: TextStyle(
                                                                                      color: pickTextColorBasedOnBgColorAdvanced(Thm.isDarktheme(widget.prefs) ? fiberchatDIALOGColorDarkMode : fiberchatDIALOGColorLightMode),
                                                                                    ),
                                                                                  )
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          );
                                                                        });

                                                                    //----
                                                                  }).catchError(
                                                                          (err) {
                                                                    showModalBottomSheet(
                                                                        backgroundColor: Thm.isDarktheme(widget.prefs)
                                                                            ? fiberchatDIALOGColorDarkMode
                                                                            : fiberchatDIALOGColorLightMode,
                                                                        isScrollControlled:
                                                                            true,
                                                                        context:
                                                                            this
                                                                                .context,
                                                                        shape:
                                                                            RoundedRectangleBorder(
                                                                          borderRadius:
                                                                              BorderRadius.vertical(top: Radius.circular(25.0)),
                                                                        ),
                                                                        builder:
                                                                            (BuildContext
                                                                                context) {
                                                                          return Container(
                                                                            height:
                                                                                220,
                                                                            child:
                                                                                Padding(
                                                                              padding: const EdgeInsets.all(28.0),
                                                                              child: Column(
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                children: [
                                                                                  Icon(Icons.check, color: fiberchatGreenColor400, size: 40),
                                                                                  SizedBox(
                                                                                    height: 30,
                                                                                  ),
                                                                                  Text(
                                                                                    getTranslated(context, 'reportsuccess'),
                                                                                    textAlign: TextAlign.center,
                                                                                    style: TextStyle(
                                                                                      color: pickTextColorBasedOnBgColorAdvanced(Thm.isDarktheme(widget.prefs) ? fiberchatDIALOGColorDarkMode : fiberchatDIALOGColorLightMode),
                                                                                    ),
                                                                                  )
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          );
                                                                        });
                                                                  });
                                                                }),
                                                          ])),
                                                );
                                              });
                                          break;
                                      }
                                    },
                                    itemBuilder: ((context) =>
                                        <PopupMenuItem<String>>[
                                          PopupMenuItem<String>(
                                            value: isCurrentUserMuted
                                                ? 'unmute'
                                                : 'mute',
                                            child: Text(
                                              isCurrentUserMuted
                                                  ? '${getTranslated(this.context, 'unmute')}'
                                                  : '${getTranslated(this.context, 'mute')}',
                                              style: TextStyle(
                                                color: pickTextColorBasedOnBgColorAdvanced(Thm
                                                        .isDarktheme(
                                                            widget.prefs)
                                                    ? fiberchatDIALOGColorDarkMode
                                                    : fiberchatDIALOGColorLightMode),
                                              ),
                                            ),
                                          ),
                                          PopupMenuItem<String>(
                                            value: 'report',
                                            child: Text(
                                              '${getTranslated(this.context, 'report')}',
                                              style: TextStyle(
                                                color: pickTextColorBasedOnBgColorAdvanced(Thm
                                                        .isDarktheme(
                                                            widget.prefs)
                                                    ? fiberchatDIALOGColorDarkMode
                                                    : fiberchatDIALOGColorLightMode),
                                              ),
                                            ),
                                          ),
                                          // ignore: unnecessary_null_comparison
                                        ].toList())),
                              ),
                            ],
                          ),
                          body: Stack(children: <Widget>[
                            new Container(
                              decoration: new BoxDecoration(
                                color: Thm.isDarktheme(widget.prefs)
                                    ? fiberchatCHATBACKGROUNDDarkMode
                                    : fiberchatCHATBACKGROUNDLightMode,
                                image: new DecorationImage(
                                    image: AssetImage(Thm.isDarktheme(
                                            widget.prefs)
                                        ? "assets/images/background_dark.png"
                                        : "assets/images/background_light.png"),
                                    fit: BoxFit.cover),
                              ),
                            ),
                            PageView(children: <Widget>[
                              Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Expanded(
                                        child: buildMessagesUsingProvider(
                                            context)),
                                    groupList
                                                    .lastWhere((element) =>
                                                        element.docmap[
                                                            Dbkeys.groupID] ==
                                                        widget.groupID)
                                                    .docmap[Dbkeys.groupTYPE] ==
                                                Dbkeys
                                                    .groupTYPEallusersmessageallowed ||
                                            groupList
                                                .lastWhere((element) =>
                                                    element.docmap[
                                                        Dbkeys.groupID] ==
                                                    widget.groupID)
                                                .docmap[Dbkeys.groupADMINLIST]
                                                .contains(widget.currentUserno)
                                        ? buildInputAndroid(
                                            context,
                                            isemojiShowing,
                                            refreshInput,
                                            _keyboardVisible,
                                          )
                                        : Container(
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.fromLTRB(
                                                14, 7, 14, 7),
                                            color: Colors.white,
                                            height: 70,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            child: Text(
                                              getTranslated(
                                                  context, 'onlyadminsend'),
                                              textAlign: TextAlign.center,
                                              style: TextStyle(height: 1.3),
                                            ),
                                          ),
                                  ])
                            ]),
                          ])),
                      buildLoadingThumbnail()
                    ],
                  ),
                ))));
  }

  // Widget selectablelinkify(
  //     String? text, double? fontsize, TextAlign? textalign) {
  //   return SelectableLinkify(
  //     style: TextStyle(
  //         fontSize: fontsize,
  //         color: Colors.black87,
  //         height: 1.3,
  //         fontStyle: FontStyle.normal),
  //     text: text ?? "",
  //     textAlign: textalign,
  //     onOpen: (link) async {
  //       if (1 == 1) {
  //         await custom_url_launcher(link.url);
  //       } else {
  //         throw 'Could not launch $link';
  //       }
  //     },
  //   );
  // }
  Widget selectablelinkify(
      String? text, double? fontsize, TextAlign? textalign) {
    bool isContainURL = false;
    try {
      isContainURL =
          Uri.tryParse(text!) == null ? false : Uri.tryParse(text)!.isAbsolute;
    } on Exception catch (_) {
      isContainURL = false;
    }
    return isContainURL == false
        ? SelectableLinkify(
            style: TextStyle(
                fontSize: isAllEmoji(text!) ? fontsize! * 2 : fontsize,
                color: Colors.black87),
            text: text,
            onOpen: (link) async {
              custom_url_launcher(link.url);
            },
          )
        : Container();
    //confirmation require
    // LinkPreviewGenerator(
    //         removeElevation: true,
    //         graphicFit: BoxFit.contain,
    //         borderRadius: 5,
    //         showDomain: true,
    //         titleStyle: TextStyle(
    //             fontSize: 13, height: 1.4, fontWeight: FontWeight.bold),
    //         showBody: true,
    //         bodyStyle: TextStyle(fontSize: 11.6, color: Colors.black45),
    //         placeholderWidget: SelectableLinkify(
    //           textAlign: textalign,
    //           style: TextStyle(fontSize: fontsize, color: Colors.black87),
    //           text: text!,
    //           onOpen: (link) async {
    //             custom_url_launcher(link.url);
    //           },
    //         ),
    //         errorWidget: SelectableLinkify(
    //           style: TextStyle(fontSize: fontsize, color: Colors.black87),
    //           text: text,
    //           textAlign: textalign,
    //           onOpen: (link) async {
    //             custom_url_launcher(link.url);
    //           },
    //         ),
    //         link: text,
    //         linkPreviewStyle: LinkPreviewStyle.large,
    //       );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed)
      setLastSeen(false, false);
    else
      setLastSeen(false, false);
  }
}

deletedGroupWidget(BuildContext context) {
  return Scaffold(
    appBar: AppBar(),
    body: Container(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Text(
            getTranslated(context, 'deletedgroup'),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ),
  );
}
