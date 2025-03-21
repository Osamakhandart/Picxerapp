//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
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
import 'package:fiberchat/Screens/auth_screens/login.dart';
import 'package:fiberchat/Screens/call_history/callhistory.dart';
import 'package:fiberchat/Screens/calling_screen/pickup_layout.dart';
import 'package:fiberchat/Screens/chat_screen/Widget/bubble.dart';
import 'package:fiberchat/Screens/chat_screen/utils/aes_encryption.dart';
import 'package:fiberchat/Screens/chat_screen/utils/audioPlayback.dart';
import 'package:fiberchat/Screens/chat_screen/utils/deleteChatMedia.dart';
import 'package:fiberchat/Screens/chat_screen/utils/message.dart';
import 'package:fiberchat/Screens/chat_screen/utils/photo_view.dart';
import 'package:fiberchat/Screens/chat_screen/utils/uploadMediaWithProgress.dart';
import 'package:fiberchat/Screens/contact_screens/ContactsSelect.dart';
import 'package:fiberchat/Screens/contact_screens/SelectContactsToForward.dart';
import 'package:fiberchat/Screens/homepage/homepage.dart';
import 'package:fiberchat/Screens/privacypolicy&TnC/PdfViewFromCachedUrl.dart';
import 'package:fiberchat/Screens/profile_settings/profile_view.dart';
import 'package:fiberchat/Screens/security_screens/security.dart';
import 'package:fiberchat/Services/Admob/admob.dart';
import 'package:fiberchat/Services/Providers/Observer.dart';
import 'package:fiberchat/Services/Providers/SmartContactProviderWithLocalStoreData.dart';
import 'package:fiberchat/Services/Providers/currentchat_peer.dart';
import 'package:fiberchat/Services/Providers/seen_provider.dart';
import 'package:fiberchat/Services/Providers/seen_state.dart';
import 'package:fiberchat/Services/helpers/donation.dart';
import 'package:fiberchat/Services/helpers/jh_backgroundService.dart';
import 'package:fiberchat/Services/helpers/jh_onBackToRecents.dart';
import 'package:fiberchat/Services/helpers/jh_photo_view_loader.dart';
import 'package:fiberchat/Services/helpers/jh_progressService.dart';
import 'package:fiberchat/Services/localization/language_constants.dart';
import 'package:fiberchat/Utils/chat_controller.dart';
import 'package:fiberchat/Utils/color_detector.dart';
import 'package:fiberchat/Utils/crc.dart';
import 'package:fiberchat/Utils/custom_url_launcher.dart';
import 'package:fiberchat/Utils/emoji_detect.dart';
import 'package:fiberchat/Utils/mime_type.dart';
import 'package:fiberchat/Utils/open_settings.dart';
import 'package:fiberchat/Utils/permissions.dart';
import 'package:fiberchat/Utils/save.dart';
import 'package:fiberchat/Utils/setStatusBarColor.dart';
import 'package:fiberchat/Utils/theme_management.dart';
import 'package:fiberchat/Utils/unawaited.dart';
import 'package:fiberchat/Utils/utils.dart';
import 'package:fiberchat/main.dart';
import 'package:fiberchat/widgets/AudioRecorder/Audiorecord.dart';
import 'package:fiberchat/widgets/CameraGalleryImagePicker/multiMediaPicker.dart';
import 'package:fiberchat/widgets/CountryPicker/CountryCode.dart';
import 'package:fiberchat/widgets/DownloadManager/download_all_file_type.dart';
import 'package:fiberchat/widgets/ImagePicker/image_picker.dart';
import 'package:fiberchat/widgets/MultiDocumentPicker/multiDocumentPicker.dart';
import 'package:fiberchat/widgets/MultiImagePicker/multiImagePicker.dart';
import 'package:fiberchat/widgets/MyElevatedButton/MyElevatedButton.dart';
import 'package:fiberchat/widgets/SoundPlayer/SoundPlayerPro.dart';
import 'package:fiberchat/widgets/VideoPicker/VideoPreview.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gal/gal.dart';
//import 'package:gallery_saver/gallery_saver.dart';
import 'package:geolocator/geolocator.dart';
import 'package:giphy_get/giphy_get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
//import 'package:link_preview_generator/link_preview_generator.dart';
import 'package:media_info/media_info.dart';
import 'package:path/path.dart' as p;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_compress/video_compress.dart' as compress;
import 'package:video_thumbnail/video_thumbnail.dart';

hidekeyboard(BuildContext context) {
  FocusScope.of(context).requestFocus(FocusNode());
}

class ChatScreen extends StatefulWidget {
  final String? peerNo, currentUserNo;
  final DataModel model;
  final int unread;
  final SharedPreferences prefs;
  final List<SharedMediaFile>? sharedFiles;
  final MessageType? sharedFilestype;
  final bool isSharingIntentForwarded;
  final String? sharedText;
  ChatScreen({
    Key? key,
    required this.currentUserNo,
    required this.peerNo,
    required this.model,
    required this.prefs,
    required this.unread,
    required this.isSharingIntentForwarded,
    this.sharedFiles,
    this.sharedFilestype,
    this.sharedText,
  });

  @override
  State createState() => new _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  GlobalKey<ScaffoldState> _scaffold = new GlobalKey<ScaffoldState>();
  bool isDeleteChatManually = false;
  bool isReplyKeyboard = false;
  bool isPeerMuted = false;
  Map<String, dynamic>? replyDoc;
  String? peerAvatar, peerNo, currentUserNo, privateKey, sharedSecret;
  late bool locked, hidden;
  Map<String, dynamic>? peer, currentUser;
  int? chatStatus, unread;
  GlobalKey<State> _keyLoader34 =
      new GlobalKey<State>(debugLabel: 'qqqeqeqsse xcb h vgcxhvhaadsqeqe');
  bool isCurrentUserMuted = false;
  String? chatId;
  bool isMessageLoading = true;
  bool typing = false;
  late File thumbnailFile;
  File? pickedFile;
  // bool isLoading = true;
  bool isgeneratingSomethingLoader = false;
  // int tempSendIndex = 0;
  String? imageUrl;
  SeenState? seenState;
  List<Message> messages = new List.from(<Message>[]);
  List<Map<String, dynamic>> _savedMessageDocs =
      new List.from(<Map<String, dynamic>>[]);
  bool isDeletedDoc = false;
  int? uploadTimestamp;

  StreamSubscription? seenSubscription,
      msgSubscription,
      deleteUptoSubscription,
      chatStatusSubscriptionForPeer;

  final TextEditingController textEditingController =
      new TextEditingController();
  final TextEditingController reportEditingController =
      new TextEditingController();
  final ScrollController realtime = new ScrollController();
  final ScrollController saved = new ScrollController();
  late DataModel _cachedModel;

  Duration? duration;
  Duration? position;

  // AudioPlayer audioPlayer = AudioPlayer();

  String? localFilePath;

  PlayerState playerState = PlayerState.stopped;

  get isPlaying => playerState == PlayerState.playing;
  get isPaused => playerState == PlayerState.paused;

  get durationText =>
      duration != null ? duration.toString().split('.').first : '';

  get positionText =>
      position != null ? position.toString().split('.').first : '';

  bool isMuted = false;
  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;
  RewardedAd? _rewardedAd;
  int _numRewardedLoadAttempts = 0;
  BackgroundService background = BackgroundService();
  @override
  void initState() {
    super.initState();

    background.initMethod(context);
    _cachedModel = widget.model;
    peerNo = widget.peerNo;
    currentUserNo = widget.currentUserNo;
    unread = widget.unread;
    // initAudioPlayer();
    // _load();
    Fiberchat.internetLookUp();

    updateLocalUserData(_cachedModel);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final observer = Provider.of<Observer>(this.context, listen: false);
      var currentpeer =
          Provider.of<CurrentChatPeer>(this.context, listen: false);
      currentpeer.setpeer(newpeerid: widget.peerNo);
      seenState = new SeenState(false);
      WidgetsBinding.instance.addObserver(this);
      chatId = '';
      unread = widget.unread;
      // isLoading = false;
      imageUrl = '';
      listenToBlock();
      loadSavedMessages();
      readLocal(this.context);
      Future.delayed(const Duration(milliseconds: 3000), () {
        if (IsVideoAdShow == true && observer.isadmobshow == true) {
          _createRewardedAd();
        }

        if (IsInterstitialAdShow == true && observer.isadmobshow == true) {
          _createInterstitialAd();
        }
      });
    });
    setStatusBarColor(widget.prefs);
  }

  bool hasPeerBlockedMe = false;
  listenToBlock() {
    chatStatusSubscriptionForPeer = FirebaseFirestore.instance
        .collection(DbPaths.collectionusers)
        .doc(widget.peerNo)
        .collection(Dbkeys.chatsWith)
        .doc(Dbkeys.chatsWith)
        .snapshots()
        .listen((doc) {
      if (doc.data() != null && doc.data()!.containsKey(widget.currentUserNo)) {
        if (doc.data()![widget.currentUserNo] == 0) {
          hasPeerBlockedMe = true;
          setStateIfMounted(() {});
        } else if (doc.data()![widget.currentUserNo] == 3) {
          hasPeerBlockedMe = false;
          setStateIfMounted(() {});
        }
      } else {
        hasPeerBlockedMe = false;
        setStateIfMounted(() {});
      }
    });
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

  updateLocalUserData(model) {
    peer = model.userData[peerNo];
    currentUser = _cachedModel.currentUser;
    if (currentUser != null && peer != null) {
      hidden = currentUser![Dbkeys.hidden] != null &&
          currentUser![Dbkeys.hidden].contains(peerNo);
      locked = currentUser![Dbkeys.locked] != null &&
          currentUser![Dbkeys.locked].contains(peerNo);
      chatStatus = peer![Dbkeys.chatStatus];
      peerAvatar = peer![Dbkeys.photoUrl];
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    setLastSeen();
    // audioPlayer.stop();
    msgSubscription?.cancel();

    chatStatusSubscriptionForPeer?.cancel();
    seenSubscription?.cancel();
    deleteUptoSubscription?.cancel();
    if (IsInterstitialAdShow == true) {
      _interstitialAd!.dispose();
    }
    if (IsVideoAdShow == true) {
      _rewardedAd!.dispose();
    }
  }

  void setLastSeen() async {
    if (chatStatus != ChatStatus.blocked.index) {
      if (chatId != null) {
        await FirebaseFirestore.instance
            .collection(DbPaths.collectionmessages)
            .doc(chatId)
            .update(
          {'$currentUserNo': DateTime.now().millisecondsSinceEpoch},
        );
        setStatusBarColor(widget.prefs);
        if (typing == true) {
          FirebaseFirestore.instance
              .collection(DbPaths.collectionusers)
              .doc(currentUserNo)
              .update(
            {Dbkeys.lastSeen: true},
          );
        }
      }
    }
  }

  dynamic encryptWithCRC(String input) {
    try {
      String encrypted = cryptor.encrypt(input, iv: iv).base64;
      int crc = CRC32.compute(input);
      return '$encrypted${Dbkeys.crcSeperator}$crc';
    } catch (e) {
      Fiberchat.toast(
        getTranslated(this.context, 'waitingpeer'),
      );
      return false;
    }
  }

  String decryptWithCRC(String input) {
    try {
      if (input.contains(Dbkeys.crcSeperator)) {
        int idx = input.lastIndexOf(Dbkeys.crcSeperator);
        String msgPart = input.substring(0, idx);
        String crcPart = input.substring(idx + 1);
        int? crc = int.tryParse(crcPart);

        if (crc != null) {
          msgPart =
              cryptor.decrypt(encrypt.Encrypted.fromBase64(msgPart), iv: iv);
          if (CRC32.compute(msgPart) == crc) return msgPart;
        }
      }
    } catch (e) {
      return '';
    }
    // Fiberchat.toast(getTranslated(this.context, 'msgnotload'));
    return '';
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed)
      setIsActive();
    else
      setLastSeen();
  }

  void setIsActive() async {
    await FirebaseFirestore.instance
        .collection(DbPaths.collectionmessages)
        .doc(chatId)
        .set({
      '$currentUserNo': true,
      '$currentUserNo-lastOnline': DateTime.now().millisecondsSinceEpoch
    }, SetOptions(merge: true));
  }

  dynamic lastSeen;

  FlutterSecureStorage storage = new FlutterSecureStorage();
  late encrypt.Encrypter cryptor;
  final iv = encrypt.IV.fromLength(8);

  readLocal(
    BuildContext context,
  ) async {
    flutterLocalNotificationsPlugin..cancelAll(); //added by JH
    try {
      print(Dbkeys.privateKey);
      privateKey = await storage.read(key: Dbkeys.privateKey);
      sharedSecret = (await e2ee.X25519().calculateSharedSecret(
              e2ee.Key.fromBase64(privateKey!, false),
              e2ee.Key.fromBase64(peer![Dbkeys.publicKey], true)))
          .toBase64();

      final key = encrypt.Key.fromBase64(sharedSecret!);
      cryptor = new encrypt.Encrypter(encrypt.Salsa20(key));
    } catch (e) {
      print(e);
      sharedSecret = null;
    }
    try {
      seenState!.value = widget.prefs.getInt(getLastSeenKey());
    } catch (e) {
      seenState!.value = false;
    }
    chatId = Fiberchat.getChatId(currentUserNo!, peerNo!);
    textEditingController.addListener(() {
      if (textEditingController.text.isNotEmpty && typing == false) {
        lastSeen = peerNo;
        FirebaseFirestore.instance
            .collection(DbPaths.collectionusers)
            .doc(currentUserNo)
            .update(
          {Dbkeys.lastSeen: peerNo},
        );
        typing = true;
      }
      if (textEditingController.text.isEmpty && typing == true) {
        lastSeen = true;
        FirebaseFirestore.instance
            .collection(DbPaths.collectionusers)
            .doc(currentUserNo)
            .update(
          {Dbkeys.lastSeen: true},
        );
        typing = false;
      }
    });
    setIsActive();
    seenSubscription = FirebaseFirestore.instance
        .collection(DbPaths.collectionmessages)
        .doc(chatId)
        .snapshots()
        .listen((doc) {
      if (doc.exists) {
        setStateIfMounted(() {
          isDeletedDoc = false;
          isPeerMuted = doc.data()!.containsKey("$peerNo-muted")
              ? doc.data()!["$peerNo-muted"]
              : false;

          isCurrentUserMuted = doc.data()!.containsKey("$currentUserNo-muted")
              ? doc.data()!["$currentUserNo-muted"]
              : false;
        });

        if (mounted && doc.data()!.containsKey(peerNo)) {
          seenState!.value = doc[peerNo!] ?? false;
          if (seenState!.value is int) {
            widget.prefs.setInt(getLastSeenKey(), seenState!.value);
          }
          if (doc.data()!.containsKey("${peerNo!}-lastOnline")) {
            int lastOnline = doc.data()!["${peerNo!}-lastOnline"];
            if (doc.data()!["${peerNo!}"] == true &&
                DateTime.now()
                        .difference(
                            DateTime.fromMillisecondsSinceEpoch(lastOnline))
                        .inMinutes >
                    20) {
              doc.reference.update({"${peerNo!}": lastOnline});
            }
          }
        }
      } else {
        setStateIfMounted(() {
          isDeletedDoc = true;
        });
      }
    });
    loadMessagesAndListen();
  }

  String getLastSeenKey() {
    return "$peerNo-${Dbkeys.lastSeen}";
  }

  int sentFile = 0;
  int totalFile = 0;
  int? randomNumber;

  int? thumnailtimestamp;
  getFileData(File image, {int? timestamp, int? totalFiles}) {
    var rng = Random();

    if (totalFile == 0) {
      randomNumber = rng.nextInt(2147483647) + 1;
      totalFile = totalFiles!;
    }

    sentFile = sentFile + 1;

    // final observer = Provider.of<Observer>(this.context, listen: false);
    print('total files are $totalFiles');

    // setStateIfMounted(() {
    pickedFile = image;
    // });
    return uploadFileWithProgressIndicator(
      false,
      randomNumber: randomNumber!,
      totalFiles: totalFiles!,context: context,
      timestamp: timestamp,
    );
    // return observer.isPercentProgressShowWhileUploading
    //     ? (totalFiles == null
    //         ? uploadFileWithProgressIndicator(
    //             false,
    //             timestamp: timestamp,
    //           )
    //         : totalFiles == 1
    //             ? uploadFileWithProgressIndicator(
    //                 false,
    //                 timestamp: timestamp,
    //               )
    //             // : testService()
    //             : uploadFileWithProgressIndicator(false,
    //                 timestamp: timestamp,
    //                 multipleImages: true,
    //                 totalFiles: totalFiles)) //added by OSAMA
    //     : uploadFileWithProgressIndicator(false,
    //         timestamp: timestamp); //added by OSAMA
  }

  getThumbnail(String url) async {
    //  final observer = Provider.of<Observer>(this.context, listen: false);
    // ignore: unnecessary_null_comparison
    setStateIfMounted(() {
      isgeneratingSomethingLoader = false;
    });

    String? path = await VideoThumbnail.thumbnailFile(
        video: url,
        thumbnailPath: (await getTemporaryDirectory()).path,
        imageFormat: ImageFormat.PNG,
        quality: 30);

    thumbnailFile = File(path!);

    setStateIfMounted(() {
      isgeneratingSomethingLoader = false;
    });

    return
        //observer.isPercentProgressShowWhileUploading
        //?
        uploadFileWithProgressIndicator(true,context: context);
    // : uploadFile(true);
  }

  getWallpaper(File image) {
    // ignore: unnecessary_null_comparison
    if (image != null) {
      _cachedModel.setWallpaper(peerNo, image);
    }
    return Future.value(false);
  }

  String? videometadata;
  Future uploadFile(bool isthumbnail, {int? timestamp}) async {
    uploadTimestamp = timestamp ?? DateTime.now().millisecondsSinceEpoch;
    String fileName = getFileName(
        currentUserNo,
        isthumbnail == false
            ? '$uploadTimestamp'
            : '${thumnailtimestamp}Thumbnail');
    Reference reference =
        FirebaseStorage.instance.ref("+00_CHAT_MEDIA/$chatId/").child(fileName);
    TaskSnapshot uploading = await reference
        .putFile(isthumbnail == true ? thumbnailFile : pickedFile!);
    if (isthumbnail == false) {
      setStateIfMounted(() {
        thumnailtimestamp = uploadTimestamp;
      });
    }
    if (isthumbnail == true) {
      MediaInfo _mediaInfo = MediaInfo();

      await _mediaInfo.getMediaInfo(thumbnailFile.path).then((mediaInfo) {
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
          .doc(widget.currentUserNo)
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

  int counter = 0;
  Future<void> testService() async {
    // Start the foreground task with some initial message.
    background.startForegroundTask(
        context, 'Photo is uploading', 'photoKey', 'photoValue');

    // Simulate a long-running task (e.g., 10 seconds).
    await Future.delayed(Duration(seconds: 10), () {
      // This block simulates doing some work over time.
      // For an actual task like uploading a file, you would perform the upload here.
      print('Long-running task completed.');
    });

    // Stop the foreground task once the simulated task completes.
    background.stopForegroundTask();
  }

  NotificationService notificationService = NotificationService();
  Future uploadFileWithProgressIndicator(bool isthumbnail,
      {int? timestamp,context,
      bool multipleImages = false,
      int totalFiles = 0,
      int? randomNumber}) async {
    uploadTimestamp = timestamp ?? DateTime.now().millisecondsSinceEpoch;

//     if (counter == 0 && totalFiles > 1) {
//       counter = totalFiles;
//     }
    File fileToCompress;
    File? compressedImage;
    String fileName = getFileName(
        currentUserNo,
        isthumbnail == false
            ? '$uploadTimestamp'
            : '${thumnailtimestamp}Thumbnail');
    Reference reference =
        FirebaseStorage.instance.ref("+00_CHAT_MEDIA/$chatId/").child(fileName);
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
// //change done
      XFile? getCompressed = await FlutterImageCompress.compressAndGetFile(
        pickedFile!.absolute.path,
        targetPath,
        quality: ImageQualityCompress,
        rotate: 0,
      );
      compressedImage = File(getCompressed!.path);
//       // await FlutterImageCompress.compressAndGetFile(
//       //   pickedFile!.absolute.path,
//       //   targetPath,
//       //   quality: ImageQualityCompress,
//       //   rotate: 0,
//       // );
    } else {}
    if (randomNumber == null) {
      var rng = Random();
      randomNumber = rng.nextInt(2147483647) + 1;
    }
    // Generate a random integer between 1 and 2147483647

    if (sentFile == 1) {
      background.startForegroundTask(
          context, 'Photo is uploading', 'photoKey', 'photoValue');
      notificationService.showInitialNotification(
          randomNumber, 'Picture', 'Preparing to upload');
    }
    if (totalFile != sentFile) {
      var total;
      var sent;
      if(Platform.isIOS){
      total= totalFile;
      sent=sentFile;}
      else{ total= totalFile * 10;
sent=sentFile*10;
      }
      notificationService.showProgressNotification(
          randomNumber, 'Pictures', 'Uploading', total,sent);
    }
    UploadTask uploading = reference.putFile(isthumbnail == true
        ? thumbnailFile
        : isImage(pickedFile!.path) == true
            ? compressedImage!
            : pickedFile!);

    uploading.snapshotEvents.listen((snap) {
      if (snap.state == TaskState.success &&
          snap.bytesTransferred == snap.totalBytes) {
        counter = counter + 1;
        if (counter == 3) {
          print('working');
        }
        // counter = counter - 1;
        // if (counter == 0) {
        //   // background.stopForegroundTask();
        // }
        // Stop the foreground task
        if (totalFile == sentFile) {
          totalFile = 0;
          sentFile = 0;
          background.stopForegroundTask();
          // Future.delayed(Duration(seconds: 1)).then((value) {
          if(!isthumbnail){
                notificationService.clearAllNotifications();
          notificationService.showCompletionNotification(
              randomNumber!, 'Picture', 'Picture Uploaded');
    
        }}

        // });
      }
    }).onDone(() async {
      bool checkThread = await background.isRunning();
      if (checkThread) {
        background.stopForegroundTask();
      }
    });
    // showDialog<void>(
    //     context: this.context,
    //     barrierDismissible: false,
    //     builder: (BuildContext context) {
    //       return new WillPopScope(
    //           onWillPop: () async => false,
    //           child: SimpleDialog(
    //               shape: RoundedRectangleBorder(
    //                 borderRadius: BorderRadius.circular(7),
    //               ),
    //               key: _keyLoader34,
    //               backgroundColor: Thm.isDarktheme(widget.prefs)
    //                   ? fiberchatDIALOGColorDarkMode
    //                   : fiberchatDIALOGColorLightMode,
    //               children: <Widget>[
    //                 Center(
    //                   child: StreamBuilder(
    //                       stream: uploading.snapshotEvents,
    //                       builder: (BuildContext context, snapshot) {
    //                         if (snapshot.hasData) {
    //                           final TaskSnapshot snap = uploading.snapshot;
    //
    //                           return openUploadDialog(
    //                             prefs: widget.prefs,
    //                             context: context,
    //                             percent: bytesTransferred(snap) / 100,
    //                             title: isthumbnail == true
    //                                 ? getTranslated(
    //                                     context, 'generatingthumbnail')
    //                                 : getTranslated(context, 'sending'),
    //                             subtitle:
    //                                 "${((((snap.bytesTransferred / 1024) / 1000) * 100).roundToDouble()) / 100}/${((((snap.totalBytes / 1024) / 1000) * 100).roundToDouble()) / 100} MB",
    //                           );
    //                         } else {
    //                           return openUploadDialog(
    //                             prefs: widget.prefs,
    //                             context: context,
    //                             percent: 0.0,
    //                             title: isthumbnail == true
    //                                 ? getTranslated(
    //                                     context, 'generatingthumbnail')
    //                                 : getTranslated(context, 'sending'),
    //                             subtitle: '',
    //                           );
    //                         }
    //                       }),
    //                 ),
    //               ]));
    //     });

    TaskSnapshot downloadTask = await uploading;
    String downloadedurl = await downloadTask.ref.getDownloadURL();

    if (isthumbnail == false) {
      setStateIfMounted(() {
        thumnailtimestamp = uploadTimestamp;
      });
    }
    if (isthumbnail == true) {
      MediaInfo _mediaInfo = MediaInfo();

      await _mediaInfo.getMediaInfo(thumbnailFile.path).then((mediaInfo) {
        // setStateIfMounted(() {
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
        // });
      }).catchError((onError) {
        Fiberchat.toast(getTranslated(this.context, 'failedsending'));
        debugPrint('ERROR SENDING FILE: $onError');
      });
    } else {
      FirebaseFirestore.instance
          .collection(DbPaths.collectionusers)
          .doc(widget.currentUserNo)
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
    //Navigator.of(_keyLoader34.currentContext!, rootNavigator: true).pop(); //
    return downloadedurl;
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

  void onSendMessage(
      BuildContext? context, String content, MessageType type, int? timestamp,
      {bool isForward = false}) async {
    var observer;
    if (context != null && mounted) {
      observer = Provider.of<Observer>(this.context, listen: false);
    }
    if (content.trim() != '') {
      String tempcontent = "";
      try {
        content = content.trim();
        tempcontent = content.trim();
        if (chatStatus == null || chatStatus == 4)
          ChatController.request(currentUserNo, peerNo, chatId);
        textEditingController.clear();
        final encrypted = AESEncryptData.encryptAES(content, sharedSecret!);

        // final encrypted = encryptWithCRC(content);
        if (encrypted is String) {
          Future messaging = FirebaseFirestore.instance
              .collection(DbPaths.collectionmessages)
              .doc(chatId)
              .collection(chatId!)
              .doc('$timestamp')
              .set({
            Dbkeys.isMuted: isPeerMuted,
            Dbkeys.from: currentUserNo,
            Dbkeys.to: peerNo,
            Dbkeys.timestamp: timestamp,
            Dbkeys.content: encrypted,
            Dbkeys.messageType: type.index,
            Dbkeys.hasSenderDeleted: false,
            Dbkeys.hasRecipientDeleted: false,
            Dbkeys.sendername: _cachedModel.currentUser![Dbkeys.nickname],
            Dbkeys.isReply: isReplyKeyboard,
            Dbkeys.replyToMsgDoc: replyDoc,
            Dbkeys.isForward: isForward,
            Dbkeys.latestEncrypted: true,
          }, SetOptions(merge: true));

          _cachedModel.addMessage(peerNo, timestamp, messaging);
          var tempDoc = {
            Dbkeys.isMuted: isPeerMuted,
            Dbkeys.from: currentUserNo,
            Dbkeys.to: peerNo,
            Dbkeys.timestamp: timestamp,
            Dbkeys.content: content,
            Dbkeys.messageType: type.index,
            Dbkeys.hasSenderDeleted: false,
            Dbkeys.hasRecipientDeleted: false,
            Dbkeys.sendername: _cachedModel.currentUser![Dbkeys.nickname],
            Dbkeys.isReply: isReplyKeyboard,
            Dbkeys.replyToMsgDoc: replyDoc,
            Dbkeys.isForward: isForward,
            Dbkeys.latestEncrypted: true,
            Dbkeys.tempcontent: tempcontent,
          };
          setStatusBarColor(widget.prefs);
          setStateIfMounted(() {
            isReplyKeyboard = false;
            replyDoc = null;
            messages = List.from(messages)
              ..add(Message(
                buildMessage(this.context, tempDoc),
                onTap: (tempDoc[Dbkeys.from] == widget.currentUserNo &&
                            tempDoc[Dbkeys.hasSenderDeleted] == true) ==
                        true
                    ? () {}
                    : type == MessageType.image
                        ? () {
                            Navigator.push(
                                context!,
                                MaterialPageRoute(
                                  builder: (context) => PhotoViewWrapper(
                                    prefs: widget.prefs,
                                    keyloader: _keyLoader34,
                                    imageUrl: content,
                                    message: content,
                                    tag: timestamp.toString(),
                                    imageProvider:
                                        CachedNetworkImageProvider(content),
                                  ),
                                ));
                          }
                        : null,
                onDismiss: tempDoc[Dbkeys.content] == '' ||
                        tempDoc[Dbkeys.content] == null
                    ? () {}
                    : () {
                        setStateIfMounted(() {
                          isReplyKeyboard = true;
                          replyDoc = tempDoc;
                        });
                        HapticFeedback.heavyImpact();
                        keyboardFocusNode.requestFocus();
                      },
                onDoubleTap: () {
                  // save(tempDoc);
                },
                onLongPress: () {
                  if (tempDoc.containsKey(Dbkeys.hasRecipientDeleted) &&
                      tempDoc.containsKey(Dbkeys.hasSenderDeleted)) {
                    if ((tempDoc[Dbkeys.from] == widget.currentUserNo &&
                            tempDoc[Dbkeys.hasSenderDeleted] == true) ==
                        false) {
                      //--Show Menu only if message is not deleted by current user already
                      contextMenuNew(this.context, tempDoc, true);
                    }
                  } else {
                    contextMenuOld(context!, tempDoc);
                  }
                },
                from: currentUserNo,
                timestamp: timestamp,
              ));
          });

          if (mounted) {
            unawaited(realtime.animateTo(0.0,
                duration: Duration(milliseconds: 300), curve: Curves.easeOut));
          }

          if (type == MessageType.doc ||
              type == MessageType.audio ||
              // (type == MessageType.image && !content.contains('giphy')) ||
              type == MessageType.location ||
              type == MessageType.contact &&
                  widget.isSharingIntentForwarded == false) {
            if (IsVideoAdShow == true &&
                context != null &&
                observer.isadmobshow == true &&
                IsInterstitialAdShow == false) {
              Future.delayed(const Duration(milliseconds: 800), () {
                _showRewardedAd();
              });
            } else if (IsInterstitialAdShow == true &&
                context != null &&
                observer.isadmobshow == true) {
              _showInterstitialAd();
            }
          } else if (type == MessageType.video) {
            if (IsVideoAdShow == true &&
                context != null &&
                observer.isadmobshow == true) {
              Future.delayed(const Duration(milliseconds: 800), () {
                _showRewardedAd();
              });
            }
          }
          // _playPopSound();
        } else {
          Fiberchat.toast('Nothing to encrypt');
        }
      } on Exception catch (_) {
        // debugPrint('Exception caught!');
        Fiberchat.toast("Exception: $_");
      }
    }
  }

  delete(int? ts) {
    setStateIfMounted(() {
      messages.removeWhere((msg) => msg.timestamp == ts);
      messages = List.from(messages);
    });
  }

  updateDeleteBySenderField(int? ts, updateDoc, context) {
    setStateIfMounted(() {
      int i = messages.indexWhere((msg) => msg.timestamp == ts);
      var child = buildMessage(context, updateDoc);
      var timestamp = messages[i].timestamp;
      var from = messages[i].from;
      // var onTap = messages[i].onTap;
      var onDoubleTap = messages[i].onDoubleTap;
      var onDismiss = messages[i].onDismiss;
      var onLongPress = () {};
      if (i >= 0) {
        messages.removeWhere((msg) => msg.timestamp == ts);
        messages.insert(
            i,
            Message(child,
                timestamp: timestamp,
                from: from,
                onTap: () {},
                onDoubleTap: onDoubleTap,
                onDismiss: onDismiss,
                onLongPress: onLongPress));
      }
      messages = List.from(messages);
    });
  }

  // next 3 functions added by JH to compress videos before uploading
  void showProgressIndikatorVideoUpload() {
    showDialog(
      context: this.context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return SimpleDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7),
          ),
          backgroundColor: Colors.white,
          children: [
            Column(children: [
              new CircularProgressIndicator(),
              new SizedBox(height: 10),
              new Text("Reducing file size..\nNext: Uploading")
            ])
          ],
        );
      },
    );
  }

  void popProgressIndikator() {
    Navigator.pop(this.context); //pop dialog
  }

  Future<File> compressVideoFile(
      File uncompressedVideoFile, String path) async {
    // showProgressIndikatorVideoUpload();
    final compress.MediaInfo? info = await compress.VideoCompress.compressVideo(
      uncompressedVideoFile.path,
      quality: IsVideoQualityCompress == true
          ? compress.VideoQuality.MediumQuality
          : compress.VideoQuality.HighestQuality,
      deleteOrigin: false,
      includeAudio: true,
    );
    File file = await File(path).create();
    file.writeAsBytesSync(File(info!.path!).readAsBytesSync());
    // popProgressIndikator();

    return file;
  }
  //added until here

  contextMenuForSavedMessage(
    BuildContext context,
    Map<String, dynamic> doc,
  ) {
    List<Widget> tiles = List.from(<Widget>[]);
    tiles.add(ListTile(
        dense: true,
        leading: Icon(Icons.delete_outline),
        title: Text(
          getTranslated(this.context, 'delete'),
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        onTap: () async {
          Save.deleteMessage(peerNo, doc);
          _savedMessageDocs.removeWhere(
              (msg) => msg[Dbkeys.timestamp] == doc[Dbkeys.timestamp]);
          setStateIfMounted(() {
            _savedMessageDocs = List.from(_savedMessageDocs);
          });
          Navigator.pop(context);
        }));
    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(children: tiles);
        });
  }

  //-- New context menu with Delete for Me & Delete For Everyone feature
  contextMenuNew(contextForDialog, Map<String, dynamic> mssgDoc, bool isTemp,
      {bool saved = false}) {
    List<Widget> tiles = List.from(<Widget>[]);
    //####################----------------------- Delete Msgs for SENDER ---------------------------------------------------
    if ((mssgDoc[Dbkeys.from] == currentUserNo &&
            mssgDoc[Dbkeys.hasSenderDeleted] == false) &&
        saved == false) {
      tiles.add(Builder(
          builder: (BuildContext popable) => ListTile(
              dense: true,
              leading: Icon(Icons.delete_outline),
              title: Text(
                getTranslated(popable, 'dltforme'),
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
                hidekeyboard(popable);
                Navigator.of(popable).pop();

                await FirebaseFirestore.instance
                    .collection(DbPaths.collectionmessages)
                    .doc(chatId)
                    .collection(chatId!)
                    .doc('${mssgDoc[Dbkeys.timestamp]}')
                    .get()
                    .then((chatDoc) async {
                  if (!chatDoc.exists) {
                    Fiberchat.toast('Please reload this screen !');
                  } else if (chatDoc.exists) {
                    Map<String, dynamic> realtimeDoc = chatDoc.data()!;
                    if (realtimeDoc[Dbkeys.hasRecipientDeleted] == true) {
                      if ((mssgDoc.containsKey(Dbkeys.isbroadcast) == true
                              ? mssgDoc[Dbkeys.isbroadcast]
                              : false) ==
                          true) {
                        // -------Delete broadcast message completely as recipient has already deleted
                        await FirebaseFirestore.instance
                            .collection(DbPaths.collectionmessages)
                            .doc(chatId)
                            .collection(chatId!)
                            .doc('${realtimeDoc[Dbkeys.timestamp]}')
                            .delete();
                        delete(realtimeDoc[Dbkeys.timestamp]);
                        Save.deleteMessage(peerNo, realtimeDoc);
                        _savedMessageDocs.removeWhere((msg) =>
                            msg[Dbkeys.timestamp] == mssgDoc[Dbkeys.timestamp]);
                        setStateIfMounted(() {
                          _savedMessageDocs = List.from(_savedMessageDocs);
                        });
                      } else {
                        // -------Delete message completely as recipient has already deleted
                        await deleteMsgMedia(realtimeDoc, chatId!)
                            .then((isDeleted) async {
                          if (isDeleted == false || isDeleted == null) {
                            Fiberchat.toast(
                                'Could not delete. Please try again!');
                          } else {
                            await FirebaseFirestore.instance
                                .collection(DbPaths.collectionmessages)
                                .doc(chatId)
                                .collection(chatId!)
                                .doc('${realtimeDoc[Dbkeys.timestamp]}')
                                .delete();
                            delete(realtimeDoc[Dbkeys.timestamp]);
                            Save.deleteMessage(peerNo, realtimeDoc);
                            _savedMessageDocs.removeWhere((msg) =>
                                msg[Dbkeys.timestamp] ==
                                mssgDoc[Dbkeys.timestamp]);
                            setStateIfMounted(() {
                              _savedMessageDocs = List.from(_savedMessageDocs);
                            });
                          }
                        });
                      }
                    } else {
                      //----Don't Delete Media from server, as recipient has not deleted the message from thier message list-----
                      FirebaseFirestore.instance
                          .collection(DbPaths.collectionmessages)
                          .doc(chatId)
                          .collection(chatId!)
                          .doc('${realtimeDoc[Dbkeys.timestamp]}')
                          .set({Dbkeys.hasSenderDeleted: true},
                              SetOptions(merge: true));

                      Save.deleteMessage(peerNo, mssgDoc);
                      _savedMessageDocs.removeWhere((msg) =>
                          msg[Dbkeys.timestamp] == mssgDoc[Dbkeys.timestamp]);
                      setStateIfMounted(() {
                        _savedMessageDocs = List.from(_savedMessageDocs);
                      });

                      Map<String, dynamic> tempDoc = realtimeDoc;
                      setStateIfMounted(() {
                        tempDoc[Dbkeys.hasSenderDeleted] = true;
                      });
                      updateDeleteBySenderField(realtimeDoc[Dbkeys.timestamp],
                          tempDoc, contextForDialog);
                    }
                  }
                });
              })));

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
                hidekeyboard(popable);
                Navigator.of(popable).pop();
                if ((mssgDoc.containsKey(Dbkeys.isbroadcast) == true
                        ? mssgDoc[Dbkeys.isbroadcast]
                        : false) ==
                    true) {
                  // -------Delete broadcast message completely for everyone
                  await FirebaseFirestore.instance
                      .collection(DbPaths.collectionmessages)
                      .doc(chatId)
                      .collection(chatId!)
                      .doc('${mssgDoc[Dbkeys.timestamp]}')
                      .delete();
                  delete(mssgDoc[Dbkeys.timestamp]);
                  Save.deleteMessage(peerNo, mssgDoc);
                  _savedMessageDocs.removeWhere((msg) =>
                      msg[Dbkeys.timestamp] == mssgDoc[Dbkeys.timestamp]);
                  setStateIfMounted(() {
                    _savedMessageDocs = List.from(_savedMessageDocs);
                  });
                } else {
                  // -------Delete message completely for everyone

                  await deleteMsgMedia(mssgDoc, chatId!)
                      .then((isDeleted) async {
                    if (isDeleted == false || isDeleted == null) {
                      Fiberchat.toast('Could not delete. Please try again!');
                    } else {
                      await FirebaseFirestore.instance
                          .collection(DbPaths.collectionmessages)
                          .doc(chatId)
                          .collection(chatId!)
                          .doc('${mssgDoc[Dbkeys.timestamp]}')
                          .delete();
                      delete(mssgDoc[Dbkeys.timestamp]);
                      Save.deleteMessage(peerNo, mssgDoc);
                      _savedMessageDocs.removeWhere((msg) =>
                          msg[Dbkeys.timestamp] == mssgDoc[Dbkeys.timestamp]);
                      setStateIfMounted(() {
                        _savedMessageDocs = List.from(_savedMessageDocs);
                      });
                    }
                  });
                }
              })));
    }
    //####################-------------------- Delete Msgs for RECIPIENTS---------------------------------------------------
    if ((mssgDoc[Dbkeys.to] == currentUserNo &&
            mssgDoc[Dbkeys.hasRecipientDeleted] == false) &&
        saved == false) {
      tiles.add(Builder(
          builder: (BuildContext popable) => ListTile(
              dense: true,
              leading: Icon(Icons.delete_outline),
              title: Text(
                getTranslated(popable, 'dltforme'),
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
                hidekeyboard(popable);
                Navigator.of(popable).pop();
                await FirebaseFirestore.instance
                    .collection(DbPaths.collectionmessages)
                    .doc(chatId)
                    .collection(chatId!)
                    .doc('${mssgDoc[Dbkeys.timestamp]}')
                    .get()
                    .then((chatDoc) async {
                  if (!chatDoc.exists) {
                    Fiberchat.toast('Please reload this screen !');
                  } else if (chatDoc.exists) {
                    Map<String, dynamic> realtimeDoc = chatDoc.data()!;
                    if (realtimeDoc[Dbkeys.hasSenderDeleted] == true) {
                      if ((mssgDoc.containsKey(Dbkeys.isbroadcast) == true
                              ? mssgDoc[Dbkeys.isbroadcast]
                              : false) ==
                          true) {
                        // -------Delete broadcast message completely as sender has already deleted
                        await FirebaseFirestore.instance
                            .collection(DbPaths.collectionmessages)
                            .doc(chatId)
                            .collection(chatId!)
                            .doc('${realtimeDoc[Dbkeys.timestamp]}')
                            .delete();
                        delete(realtimeDoc[Dbkeys.timestamp]);
                        Save.deleteMessage(peerNo, realtimeDoc);
                        _savedMessageDocs.removeWhere((msg) =>
                            msg[Dbkeys.timestamp] == mssgDoc[Dbkeys.timestamp]);
                        setStateIfMounted(() {
                          _savedMessageDocs = List.from(_savedMessageDocs);
                        });
                      } else {
                        // -------Delete message completely as sender has already deleted
                        await deleteMsgMedia(realtimeDoc, chatId!)
                            .then((isDeleted) async {
                          if (isDeleted == false || isDeleted == null) {
                            Fiberchat.toast(
                                'Could not delete. Please try again!');
                          } else {
                            await FirebaseFirestore.instance
                                .collection(DbPaths.collectionmessages)
                                .doc(chatId)
                                .collection(chatId!)
                                .doc('${realtimeDoc[Dbkeys.timestamp]}')
                                .delete();
                            delete(realtimeDoc[Dbkeys.timestamp]);
                            Save.deleteMessage(peerNo, realtimeDoc);
                            _savedMessageDocs.removeWhere((msg) =>
                                msg[Dbkeys.timestamp] ==
                                mssgDoc[Dbkeys.timestamp]);
                            setStateIfMounted(() {
                              _savedMessageDocs = List.from(_savedMessageDocs);
                            });
                          }
                        });
                      }
                    } else {
                      //----Don't Delete Media from server, as recipient has not deleted the message from thier message list-----
                      FirebaseFirestore.instance
                          .collection(DbPaths.collectionmessages)
                          .doc(chatId)
                          .collection(chatId!)
                          .doc('${realtimeDoc[Dbkeys.timestamp]}')
                          .set({Dbkeys.hasRecipientDeleted: true},
                              SetOptions(merge: true));

                      Save.deleteMessage(peerNo, mssgDoc);
                      _savedMessageDocs.removeWhere((msg) =>
                          msg[Dbkeys.timestamp] == mssgDoc[Dbkeys.timestamp]);
                      setStateIfMounted(() {
                        _savedMessageDocs = List.from(_savedMessageDocs);
                      });
                      if (isTemp == true) {
                        Map<String, dynamic> tempDoc = realtimeDoc;
                        setStateIfMounted(() {
                          tempDoc[Dbkeys.hasRecipientDeleted] = true;
                        });
                        updateDeleteBySenderField(realtimeDoc[Dbkeys.timestamp],
                            tempDoc, contextForDialog);
                      }
                    }
                  }
                });
              })));
    }
    if (mssgDoc.containsKey(Dbkeys.broadcastID) &&
        mssgDoc[Dbkeys.to] == widget.currentUserNo) {
      tiles.add(Builder(
          builder: (BuildContext popable) => ListTile(
              dense: true,
              leading: Icon(Icons.block),
              title: Text(
                getTranslated(popable, 'blockbroadcast'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: pickTextColorBasedOnBgColorAdvanced(
                      Thm.isDarktheme(widget.prefs)
                          ? fiberchatDIALOGColorDarkMode
                          : fiberchatDIALOGColorLightMode),
                ),
              ),
              onTap: () {
                hidekeyboard(popable);
                Navigator.of(popable).pop();

                Future.delayed(const Duration(milliseconds: 200), () {
                  FirebaseFirestore.instance
                      .collection(DbPaths.collectionbroadcasts)
                      .doc(mssgDoc[Dbkeys.broadcastID])
                      .update({
                    Dbkeys.broadcastMEMBERSLIST:
                        FieldValue.arrayRemove([widget.currentUserNo]),
                    Dbkeys.broadcastBLACKLISTED:
                        FieldValue.arrayUnion([widget.currentUserNo]),
                  }).catchError((error) {
                    Fiberchat.toast(error.toString());
                  });
                });
              })));
    }

    //####################--------------------- ALL BELOW DIALOG TILES FOR COMMON SENDER & RECIPIENT-------------------------###########################------------------------------

    if (mssgDoc[Dbkeys.messageType] == MessageType.text.index &&
        !mssgDoc.containsKey(Dbkeys.broadcastID)) {
      tiles.add(Builder(
          builder: (BuildContext popable) => ListTile(
              dense: true,
              leading: Icon(Icons.content_copy),
              title: Text(
                getTranslated(popable, 'copy'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: pickTextColorBasedOnBgColorAdvanced(
                      Thm.isDarktheme(widget.prefs)
                          ? fiberchatDIALOGColorDarkMode
                          : fiberchatDIALOGColorLightMode),
                ),
              ),
              onTap: () {
                Clipboard.setData(ClipboardData(text: mssgDoc[Dbkeys.content]));

                Fiberchat.toast(getTranslated(popable, 'copied'));
                Navigator.of(popable).pop();
              })));
    }
    if (((mssgDoc[Dbkeys.from] == currentUserNo &&
                mssgDoc[Dbkeys.hasSenderDeleted] == false) ||
            (mssgDoc[Dbkeys.to] == currentUserNo &&
                mssgDoc[Dbkeys.hasRecipientDeleted] == false)) ==
        true) {
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
                    contextForDialog,
                    MaterialPageRoute(
                        builder: (contextForDialog) => SelectContactsToForward(
                            contentPeerNo: peerNo!,
                            messageOwnerPhone: widget.peerNo!,
                            currentUserNo: widget.currentUserNo,
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
                setStateIfMounted(() {
                  isReplyKeyboard = true;
                  replyDoc = mssgDoc;
                });
                HapticFeedback.heavyImpact();
                keyboardFocusNode.requestFocus();
              })));
    }

    showDialog(
        context: contextForDialog,
        builder: (contextForDialog) {
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
        Navigator.of(this.context).pop();
      });
    } else {
      // setStateIfMounted(() {
      //   tempSendIndex = index;
      // });
      if (list[index].containsKey(Dbkeys.groupNAME)) {
        try {
          Map<dynamic, dynamic> groupDoc = list[index];
          int timestamp = DateTime.now().millisecondsSinceEpoch;

          FirebaseFirestore.instance
              .collection(DbPaths.collectiongroups)
              .doc(groupDoc[Dbkeys.groupID])
              .collection(DbPaths.collectiongroupChats)
              .doc(timestamp.toString() + '--' + widget.currentUserNo!)
              .set({
            Dbkeys.groupmsgCONTENT: mssgDoc[Dbkeys.content],
            Dbkeys.groupmsgISDELETED: false,
            Dbkeys.groupmsgLISToptional: [],
            Dbkeys.groupmsgTIME: timestamp,
            Dbkeys.groupmsgSENDBY: widget.currentUserNo!,
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
          Fiberchat.toast('Failed to send $e');
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
          // final encrypted = encryptWithCRC(content);
          final encrypted = AESEncryptData.encryptAES(content, sharedSecret);

          if (encrypted is String) {
            int timestamp2 = DateTime.now().millisecondsSinceEpoch;
            var chatId = Fiberchat.getChatId(
                widget.currentUserNo!, list[index][Dbkeys.phone]);
            if (content.trim() != '') {
              Map<String, dynamic>? targetPeer =
                  widget.model.userData[list[index][Dbkeys.phone]];
              if (targetPeer == null) {
                await ChatController.request(
                    currentUserNo,
                    list[index][Dbkeys.phone],
                    Fiberchat.getChatId(
                        widget.currentUserNo!, list[index][Dbkeys.phone]));
              }

              await FirebaseFirestore.instance
                  .collection(DbPaths.collectionmessages)
                  .doc(chatId)
                  .set({
                widget.currentUserNo!: true,
                list[index][Dbkeys.phone]: list[index][Dbkeys.lastSeen],
              }, SetOptions(merge: true)).then((value) async {
                Future messaging = FirebaseFirestore.instance
                    .collection(DbPaths.collectionusers)
                    .doc(list[index][Dbkeys.phone])
                    .collection(Dbkeys.chatsWith)
                    .doc(Dbkeys.chatsWith)
                    .set({
                  widget.currentUserNo!: 4,
                }, SetOptions(merge: true));
                await widget.model.addMessage(
                    list[index][Dbkeys.phone], timestamp2, messaging);
              }).then((value) async {
                Future messaging = FirebaseFirestore.instance
                    .collection(DbPaths.collectionmessages)
                    .doc(chatId)
                    .collection(chatId)
                    .doc('$timestamp2')
                    .set({
                  Dbkeys.isMuted: isPeerMuted,
                  Dbkeys.latestEncrypted: true,
                  Dbkeys.from: widget.currentUserNo!,
                  Dbkeys.to: list[index][Dbkeys.phone],
                  Dbkeys.timestamp: timestamp2,
                  Dbkeys.content: encrypted,
                  Dbkeys.messageType: mssgDoc[Dbkeys.messageType],
                  Dbkeys.hasSenderDeleted: false,
                  Dbkeys.hasRecipientDeleted: false,
                  Dbkeys.sendername: widget.model.currentUser![Dbkeys.nickname],
                  Dbkeys.isReply: false,
                  Dbkeys.replyToMsgDoc: null,
                  Dbkeys.isForward: true
                }, SetOptions(merge: true));
                await widget.model.addMessage(
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

  contextMenuOld(BuildContext context, Map<String, dynamic> doc,
      {bool saved = false}) {
    List<Widget> tiles = List.from(<Widget>[]);

    if ((doc[Dbkeys.from] != currentUserNo) && saved == false) {
      tiles.add(ListTile(
          dense: true,
          leading: Icon(Icons.delete),
          title: Text(
            getTranslated(this.context, 'dltforme'),
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
            await FirebaseFirestore.instance
                .collection(DbPaths.collectionmessages)
                .doc(chatId)
                .collection(chatId!)
                .doc('${doc[Dbkeys.timestamp]}')
                .update({Dbkeys.hasRecipientDeleted: true});
            Save.deleteMessage(peerNo, doc);
            _savedMessageDocs.removeWhere(
                (msg) => msg[Dbkeys.timestamp] == doc[Dbkeys.timestamp]);
            setStateIfMounted(() {
              _savedMessageDocs = List.from(_savedMessageDocs);
            });

            Future.delayed(const Duration(milliseconds: 300), () {
              Navigator.maybePop(context);
              Fiberchat.toast(
                getTranslated(this.context, 'deleted'),
              );
            });
          }));
    }

    if (doc[Dbkeys.messageType] == MessageType.text.index) {
      tiles.add(ListTile(
          dense: true,
          leading: Icon(Icons.content_copy),
          title: Text(
            getTranslated(context, 'copy'),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: pickTextColorBasedOnBgColorAdvanced(
                  Thm.isDarktheme(widget.prefs)
                      ? fiberchatDIALOGColorDarkMode
                      : fiberchatDIALOGColorLightMode),
            ),
          ),
          onTap: () {
            Clipboard.setData(ClipboardData(text: doc[Dbkeys.content]));
            Navigator.pop(context);
            Fiberchat.toast(
              getTranslated(this.context, 'copied'),
            );
          }));
    }
    if (doc.containsKey(Dbkeys.broadcastID) &&
        doc[Dbkeys.to] == widget.currentUserNo) {
      tiles.add(ListTile(
          dense: true,
          leading: Icon(Icons.block),
          title: Text(
            getTranslated(this.context, 'blockbroadcast'),
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: pickTextColorBasedOnBgColorAdvanced(
                    Thm.isDarktheme(widget.prefs)
                        ? fiberchatDIALOGColorDarkMode
                        : fiberchatDIALOGColorLightMode)),
          ),
          onTap: () {
            Fiberchat.toast(
              getTranslated(this.context, 'plswait'),
            );
            Future.delayed(const Duration(milliseconds: 500), () {
              FirebaseFirestore.instance
                  .collection(DbPaths.collectionbroadcasts)
                  .doc(doc[Dbkeys.broadcastID])
                  .update({
                Dbkeys.broadcastMEMBERSLIST:
                    FieldValue.arrayRemove([widget.currentUserNo]),
                Dbkeys.broadcastBLACKLISTED:
                    FieldValue.arrayUnion([widget.currentUserNo]),
              }).then((value) {
                Fiberchat.toast(
                  getTranslated(this.context, 'blockedbroadcast'),
                );
                hidekeyboard(context);
                Navigator.pop(context);
              }).catchError((error) {
                Fiberchat.toast(
                  getTranslated(this.context, 'blockedbroadcast'),
                );
                Navigator.pop(context);
                hidekeyboard(context);
              });
            });
          }));
    }
    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
              backgroundColor: Thm.isDarktheme(widget.prefs)
                  ? fiberchatDIALOGColorDarkMode
                  : fiberchatDIALOGColorLightMode,
              children: tiles);
        });
  }

  save(Map<String, dynamic> doc) async {
    Fiberchat.toast(
      getTranslated(this.context, 'saved'),
    );
    if (!_savedMessageDocs
        .any((_doc) => _doc[Dbkeys.timestamp] == doc[Dbkeys.timestamp])) {
      String? content;
      if (doc[Dbkeys.messageType] == MessageType.image.index) {
        content = doc[Dbkeys.content].toString().startsWith('http')
            ? await Save.getBase64FromImage(
                imageUrl: doc[Dbkeys.content] as String?)
            : doc[Dbkeys
                .content]; // if not a url, it is a base64 from saved messages
      } else {
        // If text
        content = doc[Dbkeys.content];
      }
      doc[Dbkeys.content] = content;
      Save.saveMessage(peerNo, doc);
      _savedMessageDocs.add(doc);
      setStateIfMounted(() {
        _savedMessageDocs = List.from(_savedMessageDocs);
      });
    }
  }

  Widget selectablelinkify(String? text, double? fontsize) {
    bool isContainURL = false;
    /*try { Deactivated by JH because otherwise many links (e.g. firebase links) were shown as picture with "Oops! Unable to parse the url"
      isContainURL =
          Uri.tryParse(text!) == null ? false : Uri.tryParse(text)!.isAbsolute;
    } on Exception catch (_) {
      isContainURL = false;
    } */
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
    // confirmation require
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
    //           style: TextStyle(fontSize: fontsize, color: Colors.black87),
    //           text: text!,
    //           onOpen: (link) async {
    //             custom_url_launcher(link.url);
    //           },
    //         ),
    //         errorWidget: SelectableLinkify(
    //           style: TextStyle(fontSize: fontsize, color: Colors.black87),
    //           text: text,
    //           onOpen: (link) async {
    //             custom_url_launcher(link.url);
    //           },
    //         ),
    //         link: text,
    //         linkPreviewStyle: LinkPreviewStyle.large,
    //       );
  }
  // Widget selectablelinkify(String? text, double? fontsize) {
  //   return SelectableLinkify(
  //     style: TextStyle(fontSize: fontsize, color: Colors.black87),
  //     text: text ?? "",
  //     onOpen: (link) async {
  //       if (1 == 1) {
  //         await custom_url_launcher(link.url);
  //       } else {
  //         throw 'Could not launch $link';
  //       }
  //     },
  //   );
  // }

  Widget getTextMessage(bool isMe, Map<String, dynamic> doc, bool saved) {
    return doc.containsKey(Dbkeys.isReply) == true
        ? doc[Dbkeys.isReply] == true
            ? Column(
                crossAxisAlignment: isMe == true
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: [
                  replyAttachedWidget(this.context, doc[Dbkeys.replyToMsgDoc]),
                  SizedBox(
                    height: 10,
                  ),
                  selectablelinkify(doc[Dbkeys.content], 16),
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
                          selectablelinkify(doc[Dbkeys.content], 16),
                        ],
                      )
                    : selectablelinkify(doc[Dbkeys.content], 16)
                : selectablelinkify(doc[Dbkeys.content], 16)
        : selectablelinkify(doc[Dbkeys.content], 16);
  }

  Widget getTempTextMessage(
    String message,
    Map<String, dynamic> doc,
  ) {
    final bool isMe = doc[Dbkeys.from] == currentUserNo;
    return doc.containsKey(Dbkeys.isReply) == true
        ? doc[Dbkeys.isReply] == true
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  replyAttachedWidget(this.context, doc[Dbkeys.replyToMsgDoc]),
                  SizedBox(
                    height: 10,
                  ),
                  selectablelinkify(message, 16)
                ],
              )
            : doc.containsKey(Dbkeys.isForward) == true
                ? doc[Dbkeys.isForward] == true
                    ? Column(
                        crossAxisAlignment: isMe
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
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
                          selectablelinkify(message, 16)
                        ],
                      )
                    : selectablelinkify(message, 16)
                : selectablelinkify(message, 16)
        : selectablelinkify(message, 16);
  }

  Widget getLocationMessage(Map<String, dynamic> doc, String? message,
      {bool saved = false}) {
    final bool isMe = doc[Dbkeys.from] == currentUserNo;
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
                    )
                  ],
                )
              : Image.asset(
                  'assets/images/mapview.jpg',
                )
          : Image.asset(
              'assets/images/mapview.jpg',
            ),
    );
  }

  Widget getAudiomessage(
      BuildContext context, Map<String, dynamic> doc, String message,
      {bool saved = false, bool isMe = true}) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      // width: 250,
      // height: 116,
      child: Column(
        crossAxisAlignment:
            isMe == true ? CrossAxisAlignment.start : CrossAxisAlignment.end,
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
                    keyloader: _keyLoader34,
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
      BuildContext context, Map<String, dynamic> doc, String message,
      {bool saved = false}) {
    final bool isMe = doc[Dbkeys.from] == currentUserNo;
    return SizedBox(
      width: 220,
      height: 116,
      child: Column(
        crossAxisAlignment:
            isMe == true ? CrossAxisAlignment.start : CrossAxisAlignment.end,
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
                        child: Text(getTranslated(this.context, 'preview'),
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
                              keyloader: _keyLoader34,
                              isOpenAfterDownload: true);
                        },
                        child: Text(getTranslated(this.context, 'download'),
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
                        keyloader: _keyLoader34,
                        isOpenAfterDownload: true);
                  },
                  child: Text(getTranslated(this.context, 'download'),
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.blue[400]))),
        ],
      ),
    );
  }

  //added by JH:
  saveInGallery(Map<String, dynamic> doc) async {
    // Save Image
    ///change Done
    String path = doc[Dbkeys.content] + "&ext=.jpg".replaceAll(' ', '');

    String cleanUrl =
        path.replaceAll(RegExp(r'[^\w\d\-._~:/?#\[\]@!$&\()*+,;=%]+'), '');

    Random random = new Random();
    int randomNumber = random.nextInt(100);
    String imageName = randomNumber.toString();
    final imagePath = '${Directory.systemTemp.path}/${imageName}image.jpg';
    await Dio().download('$cleanUrl', imagePath);
    await Gal.putImage(imagePath);
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

  //added by JH:
  saveThatImageWasSavedInDatabase(Map<String, dynamic> doc) {
    if (doc.isNotEmpty) {
      int? ts = doc[Dbkeys.timestamp];

      //hier wird in DB gesetzt, dass bereits heruntergeladen wurde
      FirebaseFirestore.instance
          .collection(DbPaths.collectionmessages)
          .doc(chatId)
          .collection(chatId!)
          .doc(ts.toString())
          .update({"isDownloaded": true}).onError(
              (e, _) => print("Error writing document: $e"));

      //here we set the doc itsself to true This is needed because otherwise when the user is in the chat while receiving a foto, the foto will be saved twice on his device. ABER dachte davor (hat gestimmt?): Die message in der app bleibt aber auf isDownloaded = false weil wird bei getmessage benoetigt)
      doc["isDownloaded"] = true;
      print("Downloaded new:" + doc.containsKey("isDownloaded").toString());
    }
  }

  Widget getImageMessage(Map<String, dynamic> doc, {bool saved = false}) {
    final bool isMe = doc[Dbkeys.from] == currentUserNo;
    //added by JH:
    print("Downloaded: " +
        doc.containsKey("isDownloaded").toString() +
        " isMe: " +
        isMe.toString() +
        " Will download: " +
        (!isMe &&
                (!doc.containsKey("isDownloaded") ||
                    doc["isDownloaded"] == false))
            .toString() +
        " is from in doc empty: " +
        (doc[Dbkeys.from] != null).toString() +
        " doc Dbkeys.content:  " +
        doc[Dbkeys.content]);
    if (!isMe &&
        (doc[Dbkeys.from] != null) &&
        (!doc.containsKey("isDownloaded") || doc["isDownloaded"] == false)) {
      doc["isDownloaded"] = true;

      saveInGallery(doc);
      saveThatImageWasSavedInDatabase(doc);
      //das isDownloaded in DB wird nicht hier auf true gesetzt sondern etwa in Z4606 WEIL muss für jedes doc einzeln gemacht werden
    }
    //until here

    return Container(
      child: Column(
        crossAxisAlignment:
            isMe == true ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.start,
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
                    width: doc[Dbkeys.content].contains('giphy') ? 120 : 112.0,
                    height: doc[Dbkeys.content].contains('giphy') ? 102 : 200.0,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(8.0),
                  ),
                  clipBehavior: Clip.hardEdge,
                )
              : CachedNetworkImage(
                  placeholder: (context, url) => Container(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.blueGrey[400]!),
                    ),
                    width: doc[Dbkeys.content].contains('giphy') ? 120 : 112.0,
                    height: doc[Dbkeys.content].contains('giphy') ? 120 : 150.0,
                    padding:
                        EdgeInsets.fromLTRB(30, 50, 30, 50), //changed by JH
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
                      width: doc[Dbkeys.content].contains('giphy')
                          ? 120
                          : 112.0, //all of these changed by JH
                      height:
                          doc[Dbkeys.content].contains('giphy') ? 120 : 150.0,
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(8.0),
                    ),
                    clipBehavior: Clip.hardEdge,
                  ),
                  imageUrl: doc[Dbkeys.content],
                  width: doc[Dbkeys.content].contains('giphy') ? 120 : 112.0,
                  height: doc[Dbkeys.content].contains('giphy') ? 120 : 150.0,
                  fit: BoxFit.cover,
                ),
        ],
      ),
    );
  }

  Widget getTempImageMessage({String? url}) {
    return url == null
        ? Container(
            child: Image.file(
              pickedFile!,
              width: url!.contains('giphy') ? 120 : 112.0,
              height: url.contains('giphy') ? 120 : 150.0,
              fit: BoxFit.cover,
            ),
          )
        : getImageMessage({Dbkeys.content: url});
  }

  Widget getVideoMessage(
      BuildContext context, Map<String, dynamic> doc, String message,
      {bool saved = false}) {
    Map<dynamic, dynamic>? meta =
        jsonDecode((message.split('-BREAK-')[2]).toString());
    final bool isMe = doc[Dbkeys.from] == currentUserNo;
    return InkWell(
      onTap: () {
        Navigator.push(
            this.context,
            new MaterialPageRoute(
                builder: (context) => new PreviewVideo(
                      prefs: widget.prefs,
                      isdownloadallowed: true,
                      filename: message.split('-BREAK-').length > 3
                          ? message.split('-BREAK-')[3]
                          : "Video-${DateTime.now().millisecondsSinceEpoch}.mp4",
                      id: null,
                      videourl: message.split('-BREAK-')[0],
                      aspectratio: meta!["width"] / meta["height"],
                    )));
      },
      child: Column(
        crossAxisAlignment:
            isMe == true ? CrossAxisAlignment.start : CrossAxisAlignment.end,
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
            height: 197,
            width: 197,
            child: Stack(
              children: [
                CachedNetworkImage(
                  placeholder: (context, url) => Container(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.blueGrey[400]!),
                    ),
                    width: 197,
                    height: 197,
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
                      width: 197,
                      height: 197,
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(0.0),
                    ),
                    clipBehavior: Clip.hardEdge,
                  ),
                  imageUrl: message.split('-BREAK-')[1],
                  width: 197,
                  height: 197,
                  fit: BoxFit.cover,
                ),
                Container(
                  color: Colors.black.withOpacity(0.4),
                  height: 197,
                  width: 197,
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
    );
  }

  Widget getContactMessage(
      BuildContext context, Map<String, dynamic> doc, String message,
      {bool saved = false}) {
    final bool isMe = doc[Dbkeys.from] == currentUserNo;
    return SizedBox(
      width: 250,
      height: 130,
      child: Column(
        crossAxisAlignment:
            isMe == true ? CrossAxisAlignment.start : CrossAxisAlignment.end,
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
            leading: customCircleAvatar(url: null),
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
          Divider(
            height: 7,
          ),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: Colors.transparent,
              ),
              onPressed: () async {
                String peer = message.split('-BREAK-')[1];
                String? peerphone;
                bool issearching = true;
                bool issearchraw = false;
                bool isUser = false;
                String? formattedphone;

                setStateIfMounted(() {
                  peerphone = peer.replaceAll(new RegExp(r'-'), '');
                  peerphone!.trim();
                });

                formattedphone = peerphone;

                if (!peerphone!.startsWith('+')) {
                  if ((peerphone!.length > 11)) {
                    CountryCodes.forEach((code) {
                      if (peerphone!.startsWith(code) && issearching == true) {
                        setStateIfMounted(() {
                          formattedphone = peerphone!
                              .substring(code.length, peerphone!.length);
                          issearchraw = true;
                          issearching = false;
                        });
                      }
                    });
                  } else {
                    setStateIfMounted(() {
                      setStateIfMounted(() {
                        issearchraw = true;
                        formattedphone = peerphone;
                      });
                    });
                  }
                } else {
                  setStateIfMounted(() {
                    issearchraw = false;
                    formattedphone = peerphone;
                  });
                }

                Query<Map<String, dynamic>> query = issearchraw == true
                    ? FirebaseFirestore.instance
                        .collection(DbPaths.collectionusers)
                        .where(Dbkeys.phoneRaw,
                            isEqualTo: formattedphone ?? peerphone)
                        .limit(1)
                    : FirebaseFirestore.instance
                        .collection(DbPaths.collectionusers)
                        .where(Dbkeys.phone,
                            isEqualTo: formattedphone ?? peerphone)
                        .limit(1);

                await query.get().then((user) {
                  setStateIfMounted(() {
                    isUser = user.docs.length == 0 ? false : true;
                  });
                  if (isUser) {
                    Map<String, dynamic> peer = user.docs[0].data();
                    widget.model.addUser(user.docs[0]);
                    Navigator.pushReplacement(
                        context,
                        new MaterialPageRoute(
                            builder: (context) => new ChatScreen(
                                isSharingIntentForwarded: false,
                                prefs: widget.prefs,
                                unread: 0,
                                currentUserNo: widget.currentUserNo,
                                model: widget.model,
                                peerNo: peer[Dbkeys.phone])));
                  } else {
                    Query<Map<String, dynamic>> queryretrywithoutzero =
                        issearchraw == true
                            ? FirebaseFirestore.instance
                                .collection(DbPaths.collectionusers)
                                .where(Dbkeys.phoneRaw,
                                    isEqualTo: formattedphone == null
                                        ? peerphone!
                                            .substring(1, peerphone!.length)
                                        : formattedphone!.substring(
                                            1, formattedphone!.length))
                                .limit(1)
                            : FirebaseFirestore.instance
                                .collection(DbPaths.collectionusers)
                                .where(Dbkeys.phoneRaw,
                                    isEqualTo: formattedphone == null
                                        ? peerphone!
                                            .substring(1, peerphone!.length)
                                        : formattedphone!.substring(
                                            1, formattedphone!.length))
                                .limit(1);
                    queryretrywithoutzero.get().then((user) {
                      setStateIfMounted(() {
                        // isLoading = false;
                        isUser = user.docs.length == 0 ? false : true;
                      });
                      if (isUser) {
                        Map<String, dynamic> peer = user.docs[0].data();
                        widget.model.addUser(user.docs[0]);
                        Navigator.pushReplacement(
                            context,
                            new MaterialPageRoute(
                                builder: (context) => new ChatScreen(
                                    isSharingIntentForwarded: true,
                                    prefs: widget.prefs,
                                    unread: 0,
                                    currentUserNo: widget.currentUserNo,
                                    model: widget.model,
                                    peerNo: peer[Dbkeys.phone])));
                      }
                    });
                  }
                });

                // ignore: unnecessary_null_comparison
                if (isUser == null || isUser == false) {
                  Fiberchat.toast(getTranslated(this.context, 'usernotjoined') +
                      ' $Appname');
                }
              },
              child: Text(getTranslated(this.context, 'msg'),
                  style: TextStyle(
                      fontWeight: FontWeight.w700, color: Colors.blue[400])))
        ],
      ),
    );
  }

  _onEmojiSelected(Emoji emoji) {
    // String text = textEditingController.text;
    // TextSelection textSelection = textEditingController.selection;
    // String newText =
    //     text.replaceRange(textSelection.start, textSelection.end, emoji.emoji);
    // final emojiLength = emoji.emoji.length;
    // textEditingController.text = newText;
    // textEditingController.selection = textSelection.copyWith(
    //   baseOffset: textSelection.start + emojiLength,
    //   extentOffset: textSelection.start + emojiLength,
    // );
    textEditingController
      ..text += emoji.emoji
      ..selection = TextSelection.fromPosition(
          TextPosition(offset: textEditingController.text.length));
  }

  _onBackspacePressed() {
    textEditingController
      ..text = textEditingController.text.characters.skipLast(1).toString()
      ..selection = TextSelection.fromPosition(
          TextPosition(offset: textEditingController.text.length));
  }

  Widget buildMessage(BuildContext context, Map<String, dynamic> doc,
      {bool saved = false, List<Message>? savedMsgs}) {
    final observer = Provider.of<Observer>(this.context, listen: false);
    final bool isMe = doc[Dbkeys.from] == currentUserNo;
    bool isContinuing;
    if (savedMsgs == null)
      isContinuing =
          messages.isNotEmpty ? messages.last.from == doc[Dbkeys.from] : false;
    else {
      isContinuing = savedMsgs.isNotEmpty
          ? savedMsgs.last.from == doc[Dbkeys.from]
          : false;
    }
    bool isContainURL = false;
    try {
      isContainURL = Uri.tryParse(doc[Dbkeys.content]) == null
          ? false
          : Uri.tryParse(doc[Dbkeys.content]!)!.isAbsolute;
    } on Exception catch (_) {
      isContainURL = false;
    }
    return SeenProvider(
        timestamp: doc[Dbkeys.timestamp].toString(),
        data: seenState,
        child: Bubble(
            isURLtext: doc[Dbkeys.messageType] == MessageType.text.index &&
                isContainURL == true,
            mssgDoc: doc,
            is24hrsFormat: observer.is24hrsTimeformat,
            isMssgDeleted: (doc.containsKey(Dbkeys.hasRecipientDeleted) &&
                    doc.containsKey(Dbkeys.hasSenderDeleted))
                ? isMe
                    ? (doc[Dbkeys.from] == widget.currentUserNo
                        ? doc[Dbkeys.hasSenderDeleted]
                        : false)
                    : (doc[Dbkeys.from] != widget.currentUserNo
                        ? doc[Dbkeys.hasRecipientDeleted]
                        : false)
                : false,
            isBroadcastMssg: doc.containsKey(Dbkeys.isbroadcast) == true
                ? doc[Dbkeys.isbroadcast]
                : false,
            messagetype: doc[Dbkeys.messageType] == MessageType.text.index
                ? MessageType.text
                : doc[Dbkeys.messageType] == MessageType.contact.index
                    ? MessageType.contact
                    : doc[Dbkeys.messageType] == MessageType.location.index
                        ? MessageType.location
                        : doc[Dbkeys.messageType] == MessageType.image.index
                            ? MessageType.image
                            : doc[Dbkeys.messageType] == MessageType.video.index
                                ? MessageType.video
                                : doc[Dbkeys.messageType] ==
                                        MessageType.doc.index
                                    ? MessageType.doc
                                    : doc[Dbkeys.messageType] ==
                                            MessageType.audio.index
                                        ? MessageType.audio
                                        : MessageType.text,
            child: doc[Dbkeys.messageType] == MessageType.text.index
                ? getTextMessage(isMe, doc, saved)
                : doc[Dbkeys.messageType] == MessageType.location.index
                    ? getLocationMessage(doc, doc[Dbkeys.content], saved: false)
                    : doc[Dbkeys.messageType] == MessageType.doc.index
                        ? getDocmessage(context, doc, doc[Dbkeys.content],
                            saved: false)
                        : doc[Dbkeys.messageType] == MessageType.audio.index
                            ? getAudiomessage(context, doc, doc[Dbkeys.content],
                                isMe: isMe, saved: false)
                            : doc[Dbkeys.messageType] == MessageType.video.index
                                ? getVideoMessage(
                                    context, doc, doc[Dbkeys.content],
                                    saved: false)
                                : doc[Dbkeys.messageType] ==
                                        MessageType.contact.index
                                    ? getContactMessage(
                                        context, doc, doc[Dbkeys.content],
                                        saved: false)
                                    : getImageMessage(
                                        doc,
                                        saved: saved,
                                      ),
            isMe: isMe,
            timestamp: doc[Dbkeys.timestamp],
            delivered:
                _cachedModel.getMessageStatus(peerNo, doc[Dbkeys.timestamp]),
            isContinuing: isContinuing));
  }

  replyAttachedWidget(BuildContext context, var doc) {
    return Flexible(
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
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                  child: Row(children: [
                    Container(
                      decoration: BoxDecoration(
                        color: doc[Dbkeys.from] == currentUserNo
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
                              doc[Dbkeys.from] == currentUserNo
                                  ? getTranslated(this.context, 'you')
                                  : Fiberchat.getNickname(peer!)!,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: doc[Dbkeys.from] == currentUserNo
                                      ? fiberchatPRIMARYcolor
                                      : Colors.purple),
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          doc[Dbkeys.messageType] == MessageType.text.index
                              ? Text(
                                  doc[Dbkeys.content],
                                  overflow: TextOverflow.ellipsis,
                                  // textAlign:  doc[Dbkeys.from] == currentUserNo? TextAlign.end: TextAlign.start,
                                  maxLines: 1,
                                  style: TextStyle(color: fiberchatBlack),
                                )
                              : doc[Dbkeys.messageType] == MessageType.doc.index
                                  ? Container(
                                      padding: const EdgeInsets.only(right: 70),
                                      child: Text(
                                        doc[Dbkeys.content].split('-BREAK-')[1],
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: TextStyle(color: fiberchatBlack),
                                      ),
                                    )
                                  : Text(
                                      getTranslated(
                                          this.context,
                                          doc[Dbkeys.messageType] ==
                                                  MessageType.image.index
                                              ? 'nim'
                                              : doc[Dbkeys.messageType] ==
                                                      MessageType.video.index
                                                  ? 'nvm'
                                                  : doc[Dbkeys.messageType] ==
                                                          MessageType
                                                              .audio.index
                                                      ? 'nam'
                                                      : doc[Dbkeys.messageType] ==
                                                              MessageType
                                                                  .contact.index
                                                          ? 'ncm'
                                                          : doc[Dbkeys.messageType] ==
                                                                  MessageType
                                                                      .location
                                                                      .index
                                                              ? 'nlm'
                                                              : doc[Dbkeys.messageType] ==
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
              doc[Dbkeys.messageType] == MessageType.text.index ||
                      doc[Dbkeys.messageType] == MessageType.location.index
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
                                placeholder: (context, url) => Container(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        fiberchatSECONDARYolor),
                                  ),
                                  width: doc[Dbkeys.content].contains('giphy')
                                      ? 60
                                      : 60.0,
                                  height: doc[Dbkeys.content].contains('giphy')
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
                      : doc[Dbkeys.messageType] == MessageType.video.index
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
                                      child: Container(
                                        color: Colors.blueGrey[200],
                                        height: 74,
                                        width: 74,
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
                                                width: 74,
                                                height: 74,
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
                                              imageUrl: doc[Dbkeys.content]
                                                  .split('-BREAK-')[1],
                                              width: 74,
                                              height: 74,
                                              fit: BoxFit.cover,
                                            ),
                                            Container(
                                              color:
                                                  Colors.black.withOpacity(0.4),
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
                                          bottomRight: Radius.circular(5),
                                          topLeft: Radius.circular(0),
                                          bottomLeft: Radius.circular(0)),
                                      child: Container(
                                          color: doc[Dbkeys.messageType] ==
                                                  MessageType.doc.index
                                              ? Colors.yellow[800]
                                              : doc[Dbkeys.messageType] ==
                                                      MessageType.audio.index
                                                  ? fiberchatGreenColor400
                                                  : doc[Dbkeys.messageType] ==
                                                          MessageType
                                                              .location.index
                                                      ? Colors.red[700]
                                                      : doc[Dbkeys.messageType] ==
                                                              MessageType
                                                                  .contact.index
                                                          ? Colors.blue[400]
                                                          : Colors.cyan[700],
                                          height: 74,
                                          width: 74,
                                          child: Icon(
                                            doc[Dbkeys.messageType] ==
                                                    MessageType.doc.index
                                                ? Icons.insert_drive_file
                                                : doc[Dbkeys.messageType] ==
                                                        MessageType.audio.index
                                                    ? Icons.mic_rounded
                                                    : doc[Dbkeys.messageType] ==
                                                            MessageType
                                                                .location.index
                                                        ? Icons.location_on
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
    );
  }

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
                        color: replyDoc![Dbkeys.from] == currentUserNo
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
                              replyDoc![Dbkeys.from] == currentUserNo
                                  ? getTranslated(this.context, 'you')
                                  : Fiberchat.getNickname(peer!)!,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: replyDoc![Dbkeys.from] == currentUserNo
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
                                        style: TextStyle(color: fiberchatBlack),
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
                                      maxLines: 2,
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
                                              ? Colors.yellow[800]
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

  Widget buildLoadingThumbnail() {
    return Positioned(
      child: isgeneratingSomethingLoader
          ? Container(
              child: Center(
                child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(fiberchatPRIMARYcolor)),
              ),
              color: pickTextColorBasedOnBgColorAdvanced(
                      !Thm.isDarktheme(widget.prefs)
                          ? fiberchatAPPBARcolorDarkMode
                          : fiberchatAPPBARcolorLightMode)
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
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
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
                                                  this.context,
                                                  finalUrl,
                                                  MessageType.doc,
                                                  time);
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
                            // Fiberchat.toast(getTranslated(
                            //     this.context, 'uploadingVideo')); //added by JH
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
                              int id = 0;
                              id++;
                              final int progressId = id;
                              NotificationService notificationService =
                                  NotificationService();
                              notificationService.showInitialNotification(
                                  progressId, 'Video', 'Preparing to upload');

                              ///jh
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
                                File videoFile = await compressVideoFile(file,
                                    '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.mp4'); //added by JH

                                int timeStamp =
                                    DateTime.now().millisecondsSinceEpoch;
                                String videoFileext = p.extension(file.path);
                                String videofileName =
                                    'Video-$timeStamp$videoFileext';
                                String? videoUrl =
                                    await uploadSelectedLocalFileWithProgressIndicator(
                                        videoFile,
                                        true,
                                        false,
                                        timeStamp,
                                        notificationService,

                                        /// added by JH
                                        progressId,

                                        /// added by JH
                                        filenameoptional:
                                            videofileName); //changed by JH
                                if (videoUrl != null) {
                                  String? thumnailUrl =
                                      await getThumbnail(videoUrl);
                                  if (thumnailUrl != null) {
                                    onSendMessage(
                                        context,
                                        videoUrl +
                                            '-BREAK-' +
                                            thumnailUrl +
                                            '-BREAK-' +
                                            videometadata! +
                                            '-BREAK-' +
                                            videofileName,
                                        MessageType.video,
                                        timeStamp);
                                        notificationService.clearAllNotifications();
                                    notificationService
                                        .showCompletionNotification(
                                            progressId, 'Video', 'Video Uploaded');
                  

                                    /// added by JH
                                    await file.delete();
                                    await videoFile.delete(); //added by JH
                                  }
                                }
                                /* await Navigator.push(
                                    this.context,
                                    new MaterialPageRoute(
                                        builder: (context) => new VideoEditor(
                                            prefs: widget.prefs,
                                            onClose: () {
                                              setStatusBarColor(widget.prefs);
                                            },
                                            thumbnailQuality: 90,
                                            videoQuality: 100,
                                            maxDuration: 3000,
                                            onEditExported:
                                                (uncompressedVideoFile,
                                                    thumnailFile) async {
                                              //changed by JH
                                              File videoFile =
                                                  await compressVideoFile(
                                                      uncompressedVideoFile,
                                                      '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.mp4'); //added by JH

                                              int timeStamp = DateTime.now()
                                                  .millisecondsSinceEpoch;
                                              String videoFileext =
                                                  p.extension(file.path);
                                              String videofileName =
                                                  'Video-$timeStamp$videoFileext';

                                              String? videoUrl =
                                                  await uploadSelectedLocalFileWithProgressIndicator(
                                                      videoFile,
                                                      true,
                                                      false,
                                                      timeStamp,
                                                      filenameoptional:
                                                          videofileName); //changed by JH
                                              if (videoUrl != null) {
                                                String? thumnailUrl =
                                                    await uploadSelectedLocalFileWithProgressIndicator(
                                                        thumnailFile,
                                                        false,
                                                        true,
                                                        timeStamp);
                                                if (thumnailUrl != null) {
                                                  onSendMessage(
                                                      this.context,
                                                      videoUrl +
                                                          '-BREAK-' +
                                                          thumnailUrl +
                                                          '-BREAK-' +
                                                          videometadata! +
                                                          '-BREAK-' +
                                                          videofileName,
                                                      MessageType.video,
                                                      timeStamp);

                                                  await file.delete();
                                                  await thumnailFile.delete();
                                                  await videoFile
                                                      .delete(); //added by JH
                                                }
                                              }
                                            },
                                            file: File(file.path))));*/
                              } else {
                                Fiberchat.toast(
                                    "File type not supported. Please choose a valid .mp4, .mov. \n\nSelected file was $fileExtension ");
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
                                    builder: (contexts) => MultiImagePicker(
                                          title: getTranslated(
                                              this.context, 'pickimage'),
                                          prefs: widget.prefs,
                                          callback: getFileData,
                                          writeMessage:
                                              (String? url, int time) async {
                                            if (url != null) {
                                              //  if (mounted) {
                                              onSendMessage(context, url,
                                                  MessageType.image, time);
                                              // }

                                              // ScaffoldMessenger.of(this.context).showSnackBar(
                                              //   SnackBar(
                                              //     content: Text(
                                              //         "imagesuploadingbackground"),
                                              //     duration: Duration(seconds: 3),
                                              //   ),
                                              // );
                                            }
                                          },
                                          chatId: chatId, //added by OSAMA
                                          currentUserNo: widget
                                              .currentUserNo, //added by OSAMA
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
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
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
                                    context,
                                    url +
                                        '-BREAK-' +
                                        uploadTimestamp.toString(),
                                    MessageType.audio,
                                    uploadTimestamp);
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
                                        this.context,
                                        locationstring,
                                        MessageType.location,
                                        DateTime.now().millisecondsSinceEpoch);
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
                                        currentUserNo: widget.currentUserNo,
                                        model: widget.model,
                                        biometricEnabled: false,
                                        prefs: widget.prefs,
                                        onSelect: (name, phone) {
                                          onSendMessage(
                                              context,
                                              '$name-BREAK-$phone',
                                              MessageType.contact,
                                              DateTime.now()
                                                  .millisecondsSinceEpoch);
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

  Future uploadSelectedLocalFileWithProgressIndicator(
      File selectedFile,
      bool isVideo,
      bool isthumbnail,
      int timeEpoch,
      NotificationService notificationService,
      id,
      {String? filenameoptional}) async {
    String ext = p.extension(selectedFile.path);
    String fileName = filenameoptional != null
        ? filenameoptional
        : isthumbnail == true
            ? 'Thumbnail-$timeEpoch$ext'
            : isVideo
                ? 'Video-$timeEpoch$ext'
                : 'IMG-$timeEpoch$ext';
    // isthumbnail == false
    //     ? isVideo == true
    //         ? 'Video-$timeEpoch.mp4'
    //         : '$timeEpoch'
    //     : '${timeEpoch}Thumbnail.png'
    // );
    Reference reference =
        FirebaseStorage.instance.ref("+00_CHAT_MEDIA/$chatId/").child(fileName);

    UploadTask uploading = reference.putFile(selectedFile);


    //     context: this.context,
    //     barrierDismissible: false,
    //     builder: (BuildContext context) {
    //       return new WillPopScope(
    //           onWillPop: () async => false,
    //           child: SimpleDialog(
    //               shape: RoundedRectangleBorder(
    //                 borderRadius: BorderRadius.circular(7),
    //               ),
    //               key: _keyLoader34,
    //               backgroundColor: Thm.isDarktheme(widget.prefs)
    //                   ? fiberchatDIALOGColorDarkMode
    //                   : fiberchatDIALOGColorLightMode,
    //               children: <Widget>[
    //                 Center(
    //                   child: StreamBuilder(
    //                       stream: uploading.snapshotEvents,
    //                       builder: (BuildContext context, snapshot) {
    //                         if (snapshot.hasData) {
    //                           final TaskSnapshot snap = uploading.snapshot;
    //
    //                           return openUploadDialog(
    //                             prefs: widget.prefs,
    //                             context: context,
    //                             percent: bytesTransferred(snap) / 100,
    //                             title: isthumbnail == true
    //                                 ? getTranslated(
    //                                     context, 'generatingthumbnail')
    //                                 : getTranslated(context, 'sending'),
    //                             subtitle:
    //                                 "${((((snap.bytesTransferred / 1024) / 1000) * 100).roundToDouble()) / 100}/${((((snap.totalBytes / 1024) / 1000) * 100).roundToDouble()) / 100} MB",
    //                           );
    //                         } else {
    //                           return openUploadDialog(
    //                             prefs: widget.prefs,
    //                             context: context,
    //                             percent: 0.0,
    //                             title: isthumbnail == true
    //                                 ? getTranslated(
    //                                     context, 'generatingthumbnail')
    //                                 : getTranslated(context, 'sending'),
    //                             subtitle: '',
    //                           );
    //                         }
    //                       }),
    //                 ),
    //               ]));
    //     });
    ///UK work done
         bool checkThread = await background.isRunning();
      if (checkThread) {
        background.stopForegroundTask();
      }
      print(id);
    background.startForegroundTask(
        context, 'Video is uploading', 'videoKey', 'videoValue');
    uploading.snapshotEvents.listen((snap) {
      notificationService.showProgressNotification(
          id, 'Video', 'Uploading', 1, bytesTransferred(snap) ~/ 100);
      if (snap.state == TaskState.success &&
          snap.bytesTransferred == snap.totalBytes) {
        // Stop the foreground task
        background.stopForegroundTask();
      }
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
          .doc(widget.currentUserNo)
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
    // Navigator.of(_keyLoader34.currentContext!, rootNavigator: true).pop(); //
    return downloadedurl;
  }

  FocusNode keyboardFocusNode = new FocusNode();
  Widget buildInputAndroid(BuildContext context, bool isemojiShowing,
      Function refreshThisInput, bool keyboardVisible) {
    final observer = Provider.of<Observer>(context, listen: true);
    if (chatStatus == ChatStatus.requested.index) {
      return AlertDialog(
        backgroundColor: Thm.isDarktheme(widget.prefs)
            ? fiberchatDIALOGColorDarkMode
            : fiberchatDIALOGColorLightMode,
        elevation: 10.0,
        title: Text(
          getTranslated(this.context, 'accept') + '${peer![Dbkeys.nickname]} ?',
          style: TextStyle(
            color: pickTextColorBasedOnBgColorAdvanced(
                Thm.isDarktheme(widget.prefs)
                    ? fiberchatDIALOGColorDarkMode
                    : fiberchatDIALOGColorLightMode),
          ),
        ),
        actions: <Widget>[
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: Colors.transparent,
              ),
              child: Text(
                getTranslated(this.context, 'rjt'),
                style: TextStyle(
                  color: pickTextColorBasedOnBgColorAdvanced(
                      Thm.isDarktheme(widget.prefs)
                          ? fiberchatDIALOGColorDarkMode
                          : fiberchatDIALOGColorLightMode),
                ),
              ),
              onPressed: () {
                ChatController.block(currentUserNo, peerNo);
                setStateIfMounted(() {
                  chatStatus = ChatStatus.blocked.index;
                });
              }),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: Colors.transparent,
              ),
              child: Text(getTranslated(this.context, 'acpt'),
                  style: TextStyle(color: fiberchatPRIMARYcolor)),
              onPressed: () {
                ChatController.accept(currentUserNo, peerNo);
                setStateIfMounted(() {
                  chatStatus = ChatStatus.accepted.index;
                });
              })
        ],
      );
    }
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
                            onPressed: isMessageLoading == true
                                ? null
                                : () {
                                    refreshThisInput();
                                  },
                            icon: Icon(
                              Icons.emoji_emotions,
                              size: 23,
                              color: fiberchatGrey,
                            ),
                          ),
                        ),
                        Flexible(
                          child: TextField(
                            onTap: isMessageLoading == true
                                ? null
                                : () {
                                    if (isemojiShowing == true) {
                                    } else {
                                      keyboardFocusNode.requestFocus();
                                      setStateIfMounted(() {});
                                    }
                                  },
                            // onChanged: (string) {
                            //   debugPrint(string);

                            //   if (string.substring(string.length - 1) == '/') {
                            //     Fiberchat.toast(string);
                            //   }
                            //   //  setStateIfMounted(() {});
                            // },
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
                                    ? 45 //by JH
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
                                          onPressed: isMessageLoading == true
                                              ? null
                                              : observer.ismediamessagingallowed ==
                                                      false
                                                  ? () {
                                                      Fiberchat.showRationale(
                                                          getTranslated(
                                                              this.context,
                                                              'mediamssgnotallowed'));
                                                    }
                                                  : chatStatus ==
                                                          ChatStatus
                                                              .blocked.index
                                                      ? () {
                                                          Fiberchat.toast(
                                                              getTranslated(
                                                                  this.context,
                                                                  'unlck'));
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
                                            onPressed: isMessageLoading == true
                                                ? null
                                                : observer.ismediamessagingallowed ==
                                                        false
                                                    ? () {
                                                        Fiberchat.showRationale(
                                                            getTranslated(
                                                                this.context,
                                                                'mediamssgnotallowed'));
                                                      }
                                                    : () async {
                                                        GiphyGif? gif =
                                                            await GiphyGet
                                                                .getGif(
                                                          tabColor:
                                                              fiberchatPRIMARYcolor,

                                                          context: context,
                                                          apiKey:
                                                              GiphyAPIKey, //YOUR API KEY HERE
                                                          lang: GiphyLanguage
                                                              .english,
                                                        );
                                                        if (gif != null &&
                                                            mounted) {
                                                          onSendMessage(
                                                              context,
                                                              gif
                                                                  .images!
                                                                  .original!
                                                                  .url,
                                                              MessageType.image,
                                                              DateTime.now()
                                                                  .millisecondsSinceEpoch);
                                                          hidekeyboard(context);
                                                          setStateIfMounted(
                                                              () {});
                                                        }
                                                      }),
                                      ),
                              ],
                            ))
                      ],
                    ),
                  ),
                ),
                // Button send message
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
                                      fontWeight: FontWeight.w500,
                                      fontSize: textInSendButton.length > 2
                                          ? 10.7
                                          : 17.5),
                                ),
                      onPressed: isMessageLoading == true
                          ? null
                          : observer.ismediamessagingallowed == true
                              ? textEditingController.text.length == 0
                                  ? () async {
                                      hidekeyboard(context);

                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  MultiImagePicker(
                                                      title: getTranslated(
                                                          this.context,
                                                          'pickimage'),
                                                      prefs: widget.prefs,
                                                      callback: getFileData,
                                                      writeMessage:
                                                          (String? url,
                                                              int time) async {
                                                        if (url != null) {
                                                          onSendMessage(
                                                              this.context,
                                                              url,
                                                              MessageType.image,
                                                              time);
                                                        }
                                                      },
                                                      currentUserNo: widget
                                                          .currentUserNo, //added by JH
                                                      chatId:
                                                          chatId //added by JH
                                                      )));
                                    }
                                  : observer.istextmessagingallowed == false
                                      ? () {
                                          Fiberchat.showRationale(getTranslated(
                                              this.context,
                                              'textmssgnotallowed'));
                                        }
                                      : chatStatus == ChatStatus.blocked.index
                                          ? null
                                          : () => onSendMessage(
                                              context,
                                              textEditingController.text,
                                              MessageType.text,
                                              DateTime.now()
                                                  .millisecondsSinceEpoch)
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
                      ),
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

  bool empty = true;

  loadMessagesAndListen() async {
    await FirebaseFirestore.instance
        .collection(DbPaths.collectionmessages)
        .doc(chatId)
        .collection(chatId!)
        .orderBy(Dbkeys.timestamp)
        .get()
        .then((docs) {
      if (docs.docs.isNotEmpty) {
        empty = false;

        // Added by JH: collect all image Docs and decrypt
        List<Map<String, dynamic>> imageDocs = [];

        for (var doc in docs.docs) {
          Map<String, dynamic> _imgDoc = Map.from(doc.data());
          if (_imgDoc[Dbkeys.messageType] == MessageType.image.index) {
            _imgDoc[Dbkeys.content] =
                _imgDoc.containsKey(Dbkeys.latestEncrypted) == true
                    ? AESEncryptData.decryptAES(
                        _imgDoc[Dbkeys.content], sharedSecret!)
                    : decryptWithCRC(_imgDoc[Dbkeys.content]);
            imageDocs.add(_imgDoc);
          }
        }
        for (final doc in docs.docs) {
          Map<String, dynamic> _doc = Map.from(doc.data());
          int? ts = _doc[Dbkeys.timestamp];

          // try {
          _doc[Dbkeys.content] = _doc.containsKey(Dbkeys.latestEncrypted) ==
                  true
              ? AESEncryptData.decryptAES(_doc[Dbkeys.content], sharedSecret!)
              : decryptWithCRC(_doc[Dbkeys.content]);
          messages.add(Message(buildMessage(this.context, _doc),
              onDismiss:
                  _doc[Dbkeys.content] == '' || _doc[Dbkeys.content] == null
                      ? () {}
                      : () {
                          setStateIfMounted(() {
                            isReplyKeyboard = true;
                            replyDoc = _doc;
                          });
                          HapticFeedback.heavyImpact();
                          keyboardFocusNode.requestFocus();
                        },
              onTap: (_doc[Dbkeys.from] == widget.currentUserNo &&
                          _doc[Dbkeys.hasSenderDeleted] == true) ==
                      true
                  ? () {}
                  : _doc[Dbkeys.messageType] == MessageType.image.index
                      ? () {
                          // --POI--JH
                          // Added by JH: Replace PhotoViewWrapper with PhotoViewLoader that builds a list of the wrapper into a PageViewer
                          PhotoViewLoader.push(
                            this.context,
                            prefs: widget.prefs,
                            keyloader: _keyLoader34,
                            allDocs: imageDocs,
                            imageUrl: _doc[Dbkeys.content],
                          );
                        }
                      : null,
              onDoubleTap: _doc.containsKey(Dbkeys.broadcastID) ? () {} : () {},
              onLongPress: () {
            if (_doc.containsKey(Dbkeys.hasRecipientDeleted) &&
                _doc.containsKey(Dbkeys.hasSenderDeleted)) {
              if ((_doc[Dbkeys.from] == widget.currentUserNo &&
                      _doc[Dbkeys.hasSenderDeleted] == true) ==
                  false) {
                //--Show Menu only if message is not deleted by current user already
                contextMenuNew(this.context, _doc, false);
              }
            } else {
              contextMenuOld(this.context, _doc);
            }
          }, from: _doc[Dbkeys.from], timestamp: ts));

          if (doc.data()[Dbkeys.timestamp] ==
              docs.docs.last.data()[Dbkeys.timestamp]) {
            setStateIfMounted(() {
              isMessageLoading = false;
              // debugPrint('All message loaded..........');
            });
          }
        }
        // catch (e) {
        //     if (e.toString().contains('range')) {
        //       Fiberchat.toast(getTranslated(this.context, 'failedtoloadchat'));
        //       Navigator.of(this.context).pop();
        // }
        // }
        //}
      } else {
        setStateIfMounted(() {
          isMessageLoading = false;
          // debugPrint('All message loaded..........');
        });
      }
      if (mounted) {
        setStateIfMounted(() {
          messages = List.from(messages);
        });
      }
      msgSubscription = FirebaseFirestore.instance
          .collection(DbPaths.collectionmessages)
          .doc(chatId)
          .collection(chatId!)
          .where(Dbkeys.from, isEqualTo: peerNo)
          .snapshots()
          .listen((query) {
        if (empty == true || query.docs.length != query.docChanges.length) {
          //----below action triggers when peer new message arrives
          query.docChanges.where((doc) {
            return doc.oldIndex <= doc.newIndex &&
                doc.type == DocumentChangeType.added;

            //  &&
            //     query.docs[doc.oldIndex][Dbkeys.timestamp] !=
            //         query.docs[doc.newIndex][Dbkeys.timestamp];
          }).forEach((change) {
            Map<String, dynamic> _doc = Map.from(change.doc.data()!);
            int? ts = _doc[Dbkeys.timestamp];
            _doc[Dbkeys.content] = _doc.containsKey(Dbkeys.latestEncrypted) ==
                    true
                ? AESEncryptData.decryptAES(_doc[Dbkeys.content], sharedSecret!)
                : decryptWithCRC(_doc[Dbkeys.content]);

            messages.add(Message(
              buildMessage(this.context, _doc),
              onDismiss:
                  _doc[Dbkeys.content] == '' || _doc[Dbkeys.content] == null
                      ? () {}
                      : () {
                          setStateIfMounted(() {
                            isReplyKeyboard = true;
                            replyDoc = _doc;
                          });
                          HapticFeedback.heavyImpact();
                          keyboardFocusNode.requestFocus();
                        },
              onLongPress: () {
                if (_doc.containsKey(Dbkeys.hasRecipientDeleted) &&
                    _doc.containsKey(Dbkeys.hasSenderDeleted)) {
                  if ((_doc[Dbkeys.from] == widget.currentUserNo &&
                          _doc[Dbkeys.hasSenderDeleted] == true) ==
                      false) {
                    //--Show Menu only if message is not deleted by current user already
                    contextMenuNew(this.context, _doc, false);
                  }
                } else {
                  contextMenuOld(this.context, _doc);
                }
              },
              onTap: (_doc[Dbkeys.from] == widget.currentUserNo &&
                          _doc[Dbkeys.hasSenderDeleted] == true) ==
                      true
                  ? () {}
                  : _doc[Dbkeys.messageType] == MessageType.image.index
                      ? () {
                          Navigator.push(
                              this.context,
                              MaterialPageRoute(
                                builder: (context) => PhotoViewWrapper(
                                  prefs: widget.prefs,
                                  keyloader: _keyLoader34,
                                  imageUrl: _doc[Dbkeys.content],
                                  message: _doc[Dbkeys.content],
                                  tag: ts.toString(),
                                  imageProvider: CachedNetworkImageProvider(
                                      _doc[Dbkeys.content]),
                                ),
                              ));
                        }
                      : null,
              onDoubleTap: _doc.containsKey(Dbkeys.broadcastID)
                  ? () {}
                  : () {
                      // save(_doc);
                    },
              from: _doc[Dbkeys.from],
              timestamp: ts,
            ));
          });
          //----below action triggers when peer message get deleted
          query.docChanges.where((doc) {
            return doc.type == DocumentChangeType.removed;
          }).forEach((change) {
            Map<String, dynamic> _doc = Map.from(change.doc.data()!);

            int i = messages.indexWhere(
                (element) => element.timestamp == _doc[Dbkeys.timestamp]);
            if (i >= 0) messages.removeAt(i);
            Save.deleteMessage(peerNo, _doc);
            _savedMessageDocs.removeWhere(
                (msg) => msg[Dbkeys.timestamp] == _doc[Dbkeys.timestamp]);
            setStateIfMounted(() {
              _savedMessageDocs = List.from(_savedMessageDocs);
            });
          }); //----below action triggers when peer message gets modified
          query.docChanges.where((doc) {
            return doc.type == DocumentChangeType.modified;
          }).forEach((change) {
            Map<String, dynamic> _doc = Map.from(change.doc.data()!);

            int i = messages.indexWhere(
                (element) => element.timestamp == _doc[Dbkeys.timestamp]);
            if (i >= 0) {
              messages.removeAt(i);
              setStateIfMounted(() {});
              int? ts = _doc[Dbkeys.timestamp];
              _doc[Dbkeys.content] =
                  _doc.containsKey(Dbkeys.latestEncrypted) == true
                      ? AESEncryptData.decryptAES(
                          _doc[Dbkeys.content], sharedSecret!)
                      : decryptWithCRC(_doc[Dbkeys.content]);
              messages.insert(
                  i,
                  Message(
                    buildMessage(this.context, _doc),
                    onLongPress: () {
                      if (_doc.containsKey(Dbkeys.hasRecipientDeleted) &&
                          _doc.containsKey(Dbkeys.hasSenderDeleted)) {
                        if ((_doc[Dbkeys.from] == widget.currentUserNo &&
                                _doc[Dbkeys.hasSenderDeleted] == true) ==
                            false) {
                          //--Show Menu only if message is not deleted by current user already
                          contextMenuNew(this.context, _doc, false);
                        }
                      } else {
                        contextMenuOld(this.context, _doc);
                      }
                    },
                    onTap: (_doc[Dbkeys.from] == widget.currentUserNo &&
                                _doc[Dbkeys.hasSenderDeleted] == true) ==
                            true
                        ? () {}
                        : _doc[Dbkeys.messageType] == MessageType.image.index
                            ? () {
                                Navigator.push(
                                    this.context,
                                    MaterialPageRoute(
                                      builder: (context) => PhotoViewWrapper(
                                        prefs: widget.prefs,
                                        keyloader: _keyLoader34,
                                        imageUrl: _doc[Dbkeys.content],
                                        message: _doc[Dbkeys.content],
                                        tag: ts.toString(),
                                        imageProvider:
                                            CachedNetworkImageProvider(
                                                _doc[Dbkeys.content]),
                                      ),
                                    ));
                              }
                            : null,
                    onDoubleTap: _doc.containsKey(Dbkeys.broadcastID)
                        ? () {}
                        : () {
                            // save(_doc);
                          },
                    from: _doc[Dbkeys.from],
                    timestamp: ts,
                    onDismiss: _doc[Dbkeys.content] == '' ||
                            _doc[Dbkeys.content] == null
                        ? () {}
                        : () {
                            setStateIfMounted(() {
                              isReplyKeyboard = true;
                              replyDoc = _doc;
                            });
                            HapticFeedback.heavyImpact();
                            keyboardFocusNode.requestFocus();
                          },
                  ));
            }
          });
          if (mounted) {
            setStateIfMounted(() {
              messages = List.from(messages);
            });
          }
        }
      });

      //----sharing intent action:

      if (widget.isSharingIntentForwarded == true) {
        if (widget.sharedText != null) {
          onSendMessage(this.context, widget.sharedText!, MessageType.text,
              DateTime.now().millisecondsSinceEpoch);
        } else if (widget.sharedFiles != null) {
          setStateIfMounted(() {
            isgeneratingSomethingLoader = true;
          });
          uploadEach(0);
        }
      }
    });
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
          onSendMessage(this.context, finalUrl, type, messagetime);
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

  void loadSavedMessages() {
    if (_savedMessageDocs.isEmpty) {
      Save.getSavedMessages(peerNo).then((_msgDocs) {
        // ignore: unnecessary_null_comparison
        if (_msgDocs != null) {
          setStateIfMounted(() {
            _savedMessageDocs = _msgDocs;
          });
        }
      });
    }
  }

//-- GROUP BY DATE ---
  List<Widget> getGroupedMessages() {
    List<Widget> _groupedMessages = new List.from(<Widget>[
      Card(
        elevation: 0.5,
        color: Color(0xffFFF2BE),
        margin: EdgeInsets.fromLTRB(10, 20, 10, 20),
        child: Container(
            padding: EdgeInsets.fromLTRB(8, 10, 8, 10),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  WidgetSpan(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 2.5, right: 4),
                      child: Icon(
                        Icons.lock,
                        color: Color(0xff78754A),
                        size: 14,
                      ),
                    ),
                  ),
                  TextSpan(
                      text: getTranslated(this.context, 'chatencryption'),
                      style: TextStyle(
                          color: Color(0xff78754A),
                          height: 1.3,
                          fontSize: 13,
                          fontWeight: FontWeight.w400)),
                ],
              ),
            )),
      ),
    ]);
    int count = 0;
    groupBy<Message, String>(messages, (msg) {
      // return getWhen(DateTime.fromMillisecondsSinceEpoch(msg.timestamp!));
      return "${DateTime.fromMillisecondsSinceEpoch(msg.timestamp!).year}-${DateTime.fromMillisecondsSinceEpoch(msg.timestamp!).month}-${DateTime.fromMillisecondsSinceEpoch(msg.timestamp!).day}";
    }).forEach((when, _actualMessages) {
      // debugPrint("whennnnn $when");
      List<String> li = when.split('-');
      var w = getWhen(DateTime(
          int.tryParse(li[0])!, int.tryParse(li[1])!, int.tryParse(li[2])!));
      _groupedMessages.add(Center(
          child: Chip(
        labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
        backgroundColor: Colors.blue[50],
        label: Text(
          w,
          style: TextStyle(
              color: Colors.black54, fontWeight: FontWeight.w400, fontSize: 14),
        ),
      )));
      _actualMessages.forEach((msg) {
        count++;
        if (unread != 0 && (messages.length - count) == unread! - 1) {
          _groupedMessages.add(Center(
              child: Chip(
            backgroundColor: Colors.blueGrey[50],
            label: Text(
              '$unread' + getTranslated(this.context, 'unread'),
              style: TextStyle(color: Colors.black54),
            ),
          )));
          unread = 0; // reset
        }
        _groupedMessages.add(msg.child);
      });
    });
    return _groupedMessages.reversed.toList();
  }

  Widget buildMessages(
    BuildContext context,
  ) {
    return Flexible(
        child: chatId == '' || messages.isEmpty || sharedSecret == null
            ? ListView(
                children: <Widget>[
                  Card(),
                  Padding(
                      padding: EdgeInsets.only(top: 200.0),
                      child: sharedSecret == null || isMessageLoading == true
                          ? Center(
                              child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      fiberchatSECONDARYolor)),
                            )
                          : Text(getTranslated(this.context, 'sayhi'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: pickTextColorBasedOnBgColorAdvanced(
                                          !Thm.isDarktheme(widget.prefs)
                                              ? fiberchatAPPBARcolorDarkMode
                                              : fiberchatAPPBARcolorLightMode)
                                      .withOpacity(0.6),
                                  fontSize: 18))),
                ],
                controller: realtime,
              )
            : ListView(
                padding: EdgeInsets.all(10.0),
                children: getGroupedMessages(),
                controller: realtime,
                reverse: true,
              ));
  }

  getWhen(date) {
    DateTime now = DateTime.now();
    String when;
    if (date.day == now.day)
      when = getTranslated(this.context, 'today');
    else if (date.day == now.subtract(Duration(days: 1)).day)
      when = getTranslated(this.context, 'yesterday');
    else
      when = IsShowNativeTimDate == true
          ? getTranslated(this.context, DateFormat.MMMM().format(date)) +
              ' ' +
              DateFormat.d().format(date)
          : when = DateFormat.MMMd().format(date);
    return when;
  }

  getPeerStatus(val) {
    final observer = Provider.of<Observer>(this.context, listen: false);
    if (val is bool && val == true) {
      return getTranslated(this.context, 'online');
    } else if (val is int) {
      DateTime date = DateTime.fromMillisecondsSinceEpoch(val);
      String at = observer.is24hrsTimeformat == false
              ? DateFormat.jm().format(date)
              : DateFormat('HH:mm').format(date),
          when = getWhen(date);
      return getTranslated(this.context, 'lastseen') + ' $when, $at';
    } else if (val is String) {
      if (val == currentUserNo) return getTranslated(this.context, 'typing');
      return getTranslated(this.context, 'online');
    }
    return getTranslated(this.context, 'loading');
  }

  bool isBlocked() {
    return chatStatus == ChatStatus.blocked.index;
  }

  call(BuildContext context, bool isvideocall) async {
    var mynickname = widget.prefs.getString(Dbkeys.nickname) ?? '';

    var myphotoUrl = widget.prefs.getString(Dbkeys.photoUrl) ?? '';

    // CallUtils.dial(
    //     prefs: widget.prefs,
    //     currentuseruid: widget.currentUserNo,
    //     fromDp: myphotoUrl,
    //     toDp: peer![Dbkeys.photoUrl],
    //     fromUID: widget.currentUserNo,
    //     fromFullname: mynickname,
    //     toUID: widget.peerNo,
    //     toFullname: peer![Dbkeys.nickname],
    //     context: context,
    //     isvideocall: isvideocall);
  }

  bool isemojiShowing = false;
  refreshInput() {
    setStateIfMounted(() {
      if (isemojiShowing == false) {
        // hidekeyboard(this.context);
        keyboardFocusNode.unfocus();
        isemojiShowing = true;
      } else {
        isemojiShowing = false;
        keyboardFocusNode.requestFocus();
      }
    });
  }

  showDialOptions(BuildContext context) {
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
          return Consumer<Observer>(
              builder: (context, observer, _child) => Container(
                  padding: EdgeInsets.all(12),
                  height: 130,
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        InkWell(
                          onTap: observer.iscallsallowed == false
                              ? () {
                                  Navigator.of(this.context).pop();
                                  Fiberchat.showRationale(getTranslated(
                                      this.context, 'callnotallowed'));
                                }
                              : hasPeerBlockedMe == true
                                  ? () {
                                      Navigator.of(this.context).pop();
                                      Fiberchat.toast(
                                        getTranslated(
                                            context, 'userhasblocked'),
                                      );
                                    }
                                  : () async {
                                      final observer = Provider.of<Observer>(
                                          this.context,
                                          listen: false);
                                      if (IsInterstitialAdShow == true &&
                                          observer.isadmobshow == true) {}

                                      await Permissions
                                              .cameraAndMicrophonePermissionsGranted()
                                          .then((isgranted) {
                                        if (isgranted == true) {
                                          Navigator.of(this.context).pop();
                                          call(this.context, false);
                                        } else {
                                          Navigator.of(this.context).pop();
                                          Fiberchat.showRationale(getTranslated(
                                              this.context, 'pmc'));
                                          Navigator.push(
                                              context,
                                              new MaterialPageRoute(
                                                  builder: (context) =>
                                                      OpenSettings(
                                                        permtype: 'contact',
                                                        prefs: widget.prefs,
                                                      )));
                                        }
                                      }).catchError((onError) {
                                        // Fiberchat.showRationale(
                                        //     "sdasddsadasdadsd");
                                        Navigator.push(
                                            context,
                                            new MaterialPageRoute(
                                                builder: (context) =>
                                                    OpenSettings(
                                                      permtype: 'contact',
                                                      prefs: widget.prefs,
                                                    )));
                                      });
                                    },
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width / 4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(height: 13),
                                Icon(
                                  Icons.local_phone,
                                  size: 35,
                                  color: fiberchatPRIMARYcolor,
                                ),
                                SizedBox(height: 13),
                                Text(
                                  getTranslated(context, 'audiocall'),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 14,
                                      color: pickTextColorBasedOnBgColorAdvanced(
                                          Thm.isDarktheme(widget.prefs)
                                              ? fiberchatDIALOGColorDarkMode
                                              : fiberchatDIALOGColorLightMode)),
                                ),
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                            onTap: observer.iscallsallowed == false
                                ? () {
                                    Navigator.of(this.context).pop();
                                    Fiberchat.showRationale(getTranslated(
                                        this.context, 'callnotallowed'));
                                  }
                                : hasPeerBlockedMe == true
                                    ? () {
                                        Navigator.of(this.context).pop();
                                        Fiberchat.toast(
                                          getTranslated(
                                              context, 'userhasblocked'),
                                        );
                                      }
                                    : () async {
                                        final observer = Provider.of<Observer>(
                                            this.context,
                                            listen: false);

                                        if (IsInterstitialAdShow == true &&
                                            observer.isadmobshow == true) {}

                                        await Permissions
                                                .cameraAndMicrophonePermissionsGranted()
                                            .then((isgranted) {
                                          if (isgranted == true) {
                                            Navigator.of(this.context).pop();
                                            call(this.context, true);
                                          } else {
                                            Navigator.of(this.context).pop();
                                            Fiberchat.showRationale(
                                                getTranslated(
                                                    this.context, 'pmc'));
                                            Navigator.push(
                                                context,
                                                new MaterialPageRoute(
                                                    builder: (context) =>
                                                        OpenSettings(
                                                          permtype: 'contact',
                                                          prefs: widget.prefs,
                                                        )));
                                          }
                                        }).catchError((onError) {
                                          Fiberchat.showRationale(getTranslated(
                                              this.context, 'pmc'));
                                          Navigator.push(
                                              context,
                                              new MaterialPageRoute(
                                                  builder: (context) =>
                                                      OpenSettings(
                                                        permtype: 'contact',
                                                        prefs: widget.prefs,
                                                      )));
                                        });
                                      },
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width / 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(height: 13),
                                  Icon(
                                    Icons.videocam,
                                    size: 39,
                                    color: fiberchatPRIMARYcolor,
                                  ),
                                  SizedBox(height: 13),
                                  Text(
                                    getTranslated(context, 'videocall'),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 14,
                                        color: pickTextColorBasedOnBgColorAdvanced(
                                            Thm.isDarktheme(widget.prefs)
                                                ? fiberchatDIALOGColorDarkMode
                                                : fiberchatDIALOGColorLightMode)),
                                  ),
                                ],
                              ),
                            ))
                      ])));
        });
  }

  @override
  Widget build(BuildContext context) {
    final observer = Provider.of<Observer>(context, listen: true);
    var _keyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;

    return PickupLayout(
      prefs: widget.prefs,
      scaffold: Fiberchat.getNTPWrappedWidget(WillPopScope(
          onWillPop: isgeneratingSomethingLoader == true
              ? () async {
  
                  return Future.value(false);
                }
              : isemojiShowing == true
                  ? () {  
                      setState(() {
                        isemojiShowing = false;
                        keyboardFocusNode.unfocus();
                      });
                      return Future.value(false);
                    }
                  : () async { 
                      setLastSeen();
                      WidgetsBinding.instance
                          .addPostFrameCallback((timeStamp) async {
                        var currentpeer = Provider.of<CurrentChatPeer>(
                            this.context,
                            listen: false);
                        currentpeer.setpeer(newpeerid: '');
                        if (lastSeen == peerNo)
                          await FirebaseFirestore.instance
                              .collection(DbPaths.collectionusers)
                              .doc(currentUserNo)
                              .update(
                            {Dbkeys.lastSeen: true},
                          );
                      });

                      return Future.value(true);
                    },
          child: ScopedModel<DataModel>(
              model: _cachedModel,
              child: ScopedModelDescendant<DataModel>(
                  builder: (context, child, _model) {
                _cachedModel = _model;
                updateLocalUserData(_model);
                return peer != null
                    ? peer![Dbkeys.accountstatus] == Dbkeys.sTATUSdeleted
                        ? Scaffold(
                            backgroundColor: Thm.isDarktheme(widget.prefs)
                                ? fiberchatCHATBACKGROUNDDarkMode
                                : fiberchatCHATBACKGROUNDLightMode,
                            appBar: AppBar(
                              backgroundColor: Thm.isDarktheme(widget.prefs)
                                  ? fiberchatAPPBARcolorDarkMode
                                  : fiberchatAPPBARcolorLightMode,
                              elevation: 0,
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
                                  onPressed: () {
                                      DonationPopup.showDonationPopup(context,alwaysShow: false);
                                    Navigator.of(this.context).pop();
                                  },
                                ),
                              ),
                            ),
                            body: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.delete_forever,
                                    color: Colors.red,
                                    size: 40,
                                  ),
                                  SizedBox(
                                    height: 38,
                                  ),
                                  Text(
                                    " User Account Deleted",
                                    style: TextStyle(
                                        color: Thm.isDarktheme(widget.prefs)
                                            ? fiberchatWhite
                                            : fiberchatBlack),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Stack(
                            children: [
                              Scaffold(
                                  key: _scaffold,
                                  appBar: AppBar(
                                    elevation: 0.4,
                                    titleSpacing: -14,
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
                                        onPressed: ()async {
                                          await  DonationPopup.incrementBackPressCount();

    // Get the updated count
    int currentCount = await DonationPopup.getBackPressCount();

    // Check if the threshold is reached
    if (currentCount >= 4) {
      // Reset the counter
      // await DonationPopup.resetBackPressCount();
                                           DonationPopup.showDonationPopup(context,alwaysShow: false);}
                                          if (isDeletedDoc == true) {
                                            Navigator.of(context)
                                                .pushAndRemoveUntil(
                                              MaterialPageRoute(
                                                builder:
                                                    (BuildContext context) =>
                                                        FiberchatWrapper(),
                                              ),
                                              (Route route) => false,
                                            );
                                          } else {
                                            onBackToRecents(
                                                context); //added by JH

                                            Navigator.pop(context);
                                          }
                                        },
                                      ),
                                    ),
                                    backgroundColor:
                                        Thm.isDarktheme(widget.prefs)
                                            ? fiberchatAPPBARcolorDarkMode
                                            : fiberchatAPPBARcolorLightMode,
                                    title: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            PageRouteBuilder(
                                                opaque: false,
                                                pageBuilder: (context, a1,
                                                        a2) =>
                                                    ProfileView(
                                                        peer!,
                                                        widget.currentUserNo,
                                                        _cachedModel,
                                                        widget.prefs,
                                                        messages)));
                                      },
                                      child: Consumer<
                                              SmartContactProviderWithLocalStoreData>(
                                          builder: (context, availableContacts,
                                              _child) {
                                        // _filtered = availableContacts.filtered;
                                        return Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            IsShowUserFullNameAsSavedInYourContacts ==
                                                    true
                                                ? Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(0, 7, 0, 7),
                                                    child: FutureBuilder<
                                                            LocalUserData?>(
                                                        future: availableContacts
                                                            .fetchUserDataFromnLocalOrServer(
                                                                widget.prefs,
                                                                widget.peerNo!),
                                                        builder: (BuildContext
                                                                context,
                                                            AsyncSnapshot<
                                                                    LocalUserData?>
                                                                snapshot) {
                                                          if (snapshot
                                                                  .hasData &&
                                                              snapshot.data !=
                                                                  null) {
                                                            return Fiberchat.avatar(
                                                                peer,
                                                                radius: 20,
                                                                predefinedinitials:
                                                                    Fiberchat.getInitials(
                                                                        snapshot
                                                                            .data!
                                                                            .name));
                                                          }
                                                          return Fiberchat
                                                              .avatar(peer,
                                                                  radius: 20);
                                                        }),
                                                  )
                                                : Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(0, 7, 0, 7),
                                                    child: Fiberchat.avatar(
                                                        peer,
                                                        radius: 20),
                                                  ),
                                            SizedBox(
                                              width: 7,
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  width: MediaQuery.of(
                                                              this.context)
                                                          .size
                                                          .width /
                                                      2.3,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      IsShowUserFullNameAsSavedInYourContacts ==
                                                              true
                                                          ? FutureBuilder<
                                                                  LocalUserData?>(
                                                              future: availableContacts
                                                                  .fetchUserDataFromnLocalOrServer(
                                                                      widget
                                                                          .prefs,
                                                                      widget
                                                                          .peerNo!),
                                                              builder: (BuildContext
                                                                      context,
                                                                  AsyncSnapshot<
                                                                          LocalUserData?>
                                                                      snapshot) {
                                                                if (snapshot
                                                                        .hasData &&
                                                                    snapshot.data !=
                                                                        null) {
                                                                  return Text(
                                                                    snapshot
                                                                        .data!
                                                                        .name,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    maxLines: 1,
                                                                    style: TextStyle(
                                                                        color: pickTextColorBasedOnBgColorAdvanced(Thm.isDarktheme(widget.prefs)
                                                                            ? fiberchatAPPBARcolorDarkMode
                                                                            : fiberchatAPPBARcolorLightMode),
                                                                        fontSize:
                                                                            17.0,
                                                                        fontWeight:
                                                                            FontWeight.w500),
                                                                  );
                                                                }
                                                                return Text(
                                                                  Fiberchat
                                                                      .getNickname(
                                                                          peer!)!,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  maxLines: 1,
                                                                  style: TextStyle(
                                                                      color: pickTextColorBasedOnBgColorAdvanced(Thm.isDarktheme(widget
                                                                              .prefs)
                                                                          ? fiberchatAPPBARcolorDarkMode
                                                                          : fiberchatAPPBARcolorLightMode),
                                                                      fontSize:
                                                                          17.0,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500),
                                                                );
                                                              })
                                                          : Text(
                                                              Fiberchat
                                                                  .getNickname(
                                                                      peer!)!,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              maxLines: 1,
                                                              style: TextStyle(
                                                                  color: pickTextColorBasedOnBgColorAdvanced(Thm.isDarktheme(
                                                                          widget
                                                                              .prefs)
                                                                      ? fiberchatAPPBARcolorDarkMode
                                                                      : fiberchatAPPBARcolorLightMode),
                                                                  fontSize:
                                                                      17.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                            ),
                                                      isCurrentUserMuted
                                                          ? Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      left:
                                                                          5.0),
                                                              child: Icon(
                                                                Icons
                                                                    .volume_off,
                                                                color: pickTextColorBasedOnBgColorAdvanced(Thm.isDarktheme(widget
                                                                            .prefs)
                                                                        ? fiberchatAPPBARcolorDarkMode
                                                                        : fiberchatAPPBARcolorLightMode)
                                                                    .withOpacity(
                                                                        0.5),
                                                                size: 17,
                                                              ),
                                                            )
                                                          : SizedBox(),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 4,
                                                ),
                                                chatId != null
                                                    ? Text(
                                                        getPeerStatus(peer![
                                                            Dbkeys.lastSeen]),
                                                        style: TextStyle(
                                                            color: pickTextColorBasedOnBgColorAdvanced(Thm
                                                                        .isDarktheme(widget
                                                                            .prefs)
                                                                    ? fiberchatAPPBARcolorDarkMode
                                                                    : fiberchatAPPBARcolorLightMode)
                                                                .withOpacity(
                                                                    0.9),
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w400),
                                                      )
                                                    : Text(
                                                        getTranslated(
                                                            this.context,
                                                            'loading'),
                                                        style: TextStyle(
                                                            color: pickTextColorBasedOnBgColorAdvanced(Thm
                                                                        .isDarktheme(widget
                                                                            .prefs)
                                                                    ? fiberchatAPPBARcolorDarkMode
                                                                    : fiberchatAPPBARcolorLightMode)
                                                                .withOpacity(
                                                                    0.9),
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w400),
                                                      ),
                                              ],
                                            ),
                                          ],
                                        );
                                      }),
                                    ),
                                    actions: [
                                      observer.isCallFeatureTotallyHide ==
                                                  true ||
                                              observer.isOngoingCall
                                          ? SizedBox()
                                          : SizedBox(
                                              width: 55,
                                              child: IconButton(
                                                  icon: Icon(
                                                    Icons.add_call,
                                                    color: Thm.isDarktheme(
                                                            widget.prefs)
                                                        ? fiberchatPRIMARYcolor
                                                        : fiberchatAPPBARcolorLightMode ==
                                                                Colors.white
                                                            ? fiberchatPRIMARYcolor
                                                            : pickTextColorBasedOnBgColorAdvanced(
                                                                fiberchatAPPBARcolorLightMode),
                                                  ),
                                                  onPressed: observer
                                                              .iscallsallowed ==
                                                          false
                                                      ? () {
                                                          Fiberchat.showRationale(
                                                              getTranslated(
                                                                  this.context,
                                                                  'callnotallowed'));
                                                        }
                                                      : hasPeerBlockedMe == true
                                                          ? () {
                                                              Fiberchat.toast(
                                                                getTranslated(
                                                                    context,
                                                                    'userhasblocked'),
                                                              );
                                                            }
                                                          : () async {
                                                              showDialOptions(
                                                                  this.context);
                                                            }),
                                            ),
                                      SizedBox(
                                        width:
                                            observer.isCallFeatureTotallyHide ==
                                                    true
                                                ? 45 //by JH
                                                : 25,
                                        child: PopupMenuButton(
                                            padding: EdgeInsets.all(0),
                                            icon: Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 10),
                                              child: Icon(
                                                Icons.more_vert_outlined,
                                                color: pickTextColorBasedOnBgColorAdvanced(Thm
                                                        .isDarktheme(
                                                            widget.prefs)
                                                    ? fiberchatAPPBARcolorDarkMode
                                                    : fiberchatAPPBARcolorLightMode),
                                              ),
                                            ),
                                            color: Thm.isDarktheme(widget.prefs)
                                                ? fiberchatDIALOGColorDarkMode
                                                : fiberchatDIALOGColorLightMode,
                                            onSelected: (dynamic val) {
                                              switch (val) {
                                                case 'report':
                                                  showModalBottomSheet(
                                                      backgroundColor: Thm
                                                              .isDarktheme(
                                                                  widget.prefs)
                                                          ? fiberchatDIALOGColorDarkMode
                                                          : fiberchatDIALOGColorLightMode,
                                                      isScrollControlled: true,
                                                      context: context,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.vertical(
                                                                top: Radius
                                                                    .circular(
                                                                        25.0)),
                                                      ),
                                                      builder: (BuildContext
                                                          context) {
                                                        // return your layout
                                                        var w = MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width;
                                                        return Padding(
                                                          padding: EdgeInsets.only(
                                                              bottom: MediaQuery
                                                                      .of(context)
                                                                  .viewInsets
                                                                  .bottom),
                                                          child: Container(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(16),
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height /
                                                                  2.6,
                                                              child: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .stretch,
                                                                  children: [
                                                                    SizedBox(
                                                                      height:
                                                                          12,
                                                                    ),
                                                                    SizedBox(
                                                                      height: 3,
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              7),
                                                                      child:
                                                                          Text(
                                                                        getTranslated(
                                                                            this.context,
                                                                            'reportshort'),
                                                                        textAlign:
                                                                            TextAlign.left,
                                                                        style: TextStyle(
                                                                            color: pickTextColorBasedOnBgColorAdvanced(Thm.isDarktheme(widget.prefs)
                                                                                ? fiberchatDIALOGColorDarkMode
                                                                                : fiberchatDIALOGColorLightMode),
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            fontSize: 16.5),
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      height:
                                                                          10,
                                                                    ),
                                                                    Container(
                                                                      margin: EdgeInsets
                                                                          .only(
                                                                              top: 10),
                                                                      padding: EdgeInsets
                                                                          .fromLTRB(
                                                                              0,
                                                                              0,
                                                                              0,
                                                                              0),
                                                                      // height: 63,
                                                                      height:
                                                                          63,
                                                                      width: w /
                                                                          1.24,
                                                                      child:
                                                                          InpuTextBox(
                                                                        isDark:
                                                                            Thm.isDarktheme(widget.prefs),
                                                                        controller:
                                                                            reportEditingController,
                                                                        leftrightmargin:
                                                                            0,
                                                                        showIconboundary:
                                                                            false,
                                                                        boxcornerradius:
                                                                            5.5,
                                                                        boxheight:
                                                                            50,
                                                                        hinttext: getTranslated(
                                                                            this.context,
                                                                            'reportdesc'),
                                                                        prefixIconbutton:
                                                                            Icon(
                                                                          Icons
                                                                              .message,
                                                                          color: Colors
                                                                              .grey
                                                                              .withOpacity(0.5),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      height:
                                                                          w / 10,
                                                                    ),
                                                                    myElevatedButton(
                                                                        color:
                                                                            fiberchatPRIMARYcolor,
                                                                        child:
                                                                            Padding(
                                                                          padding: const EdgeInsets
                                                                              .fromLTRB(
                                                                              10,
                                                                              15,
                                                                              10,
                                                                              15),
                                                                          child:
                                                                              Text(
                                                                            getTranslated(context,
                                                                                'report'),
                                                                            style:
                                                                                TextStyle(color: Colors.white, fontSize: 18),
                                                                          ),
                                                                        ),
                                                                        onPressed:
                                                                            () async {
                                                                          Navigator.of(context)
                                                                              .pop();

                                                                          DateTime
                                                                              time =
                                                                              DateTime.now();

                                                                          Map<String, dynamic>
                                                                              mapdata =
                                                                              {
                                                                            'title':
                                                                                'New report by User',
                                                                            'desc':
                                                                                '${reportEditingController.text}',
                                                                            'phone':
                                                                                '${widget.currentUserNo}',
                                                                            'type':
                                                                                'Individual Chat',
                                                                            'time':
                                                                                time.millisecondsSinceEpoch,
                                                                            'id':
                                                                                Fiberchat.getChatId(currentUserNo!, peerNo!),
                                                                          };

                                                                          await FirebaseFirestore
                                                                              .instance
                                                                              .collection('reports')
                                                                              .doc(time.millisecondsSinceEpoch.toString())
                                                                              .set(mapdata)
                                                                              .then((value) async {
                                                                            showModalBottomSheet(
                                                                                backgroundColor: Thm.isDarktheme(widget.prefs) ? fiberchatDIALOGColorDarkMode : fiberchatDIALOGColorLightMode,
                                                                                isScrollControlled: true,
                                                                                context: context,
                                                                                shape: RoundedRectangleBorder(
                                                                                  borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
                                                                                ),
                                                                                builder: (BuildContext context) {
                                                                                  return Container(
                                                                                    height: 220,
                                                                                    child: Padding(
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
                                                                          }).catchError((err) {
                                                                            showModalBottomSheet(
                                                                                backgroundColor: Thm.isDarktheme(widget.prefs) ? fiberchatDIALOGColorDarkMode : fiberchatDIALOGColorLightMode,
                                                                                isScrollControlled: true,
                                                                                context: this.context,
                                                                                shape: RoundedRectangleBorder(
                                                                                  borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
                                                                                ),
                                                                                builder: (BuildContext context) {
                                                                                  return Container(
                                                                                    height: 220,
                                                                                    child: Padding(
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
                                                case 'hide':
                                                  ChatController.hideChat(
                                                      currentUserNo, peerNo);
                                                  break;
                                                case 'unhide':
                                                  ChatController.unhideChat(
                                                      currentUserNo, peerNo);
                                                  break;
                                                case 'mute':
                                                  FirebaseFirestore.instance
                                                      .collection(DbPaths
                                                          .collectionmessages)
                                                      .doc(Fiberchat.getChatId(
                                                          currentUserNo!,
                                                          peerNo!))
                                                      .update({
                                                    "$currentUserNo-muted":
                                                        !isCurrentUserMuted,
                                                  });
                                                  setStateIfMounted(() {
                                                    isCurrentUserMuted =
                                                        !isCurrentUserMuted;
                                                  });

                                                  break;
                                                case 'unmute':
                                                  FirebaseFirestore.instance
                                                      .collection(DbPaths
                                                          .collectionmessages)
                                                      .doc(Fiberchat.getChatId(
                                                          currentUserNo!,
                                                          peerNo!))
                                                      .update({
                                                    "$currentUserNo-muted":
                                                        !isCurrentUserMuted,
                                                  });
                                                  setStateIfMounted(() {
                                                    isCurrentUserMuted =
                                                        !isCurrentUserMuted;
                                                  });
                                                  break;
                                                case 'lock':
                                                  if (widget.prefs.getString(Dbkeys
                                                              .isPINsetDone) !=
                                                          currentUserNo ||
                                                      widget.prefs.getString(Dbkeys
                                                              .isPINsetDone) ==
                                                          null) {
                                                    unawaited(Navigator.push(
                                                        this.context,
                                                        MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    Security(
                                                                      currentUserNo,
                                                                      prefs: widget
                                                                          .prefs,
                                                                      setPasscode:
                                                                          true,
                                                                      onSuccess:
                                                                          (newContext) async {
                                                                        ChatController.lockChat(
                                                                            currentUserNo,
                                                                            peerNo);
                                                                        Navigator.pop(
                                                                            context);
                                                                        Navigator.pop(
                                                                            context);
                                                                      },
                                                                      title: getTranslated(
                                                                          this.context,
                                                                          'authh'),
                                                                    ))));
                                                  } else {
                                                    ChatController.lockChat(
                                                        currentUserNo, peerNo);
                                                    Navigator.pop(context);
                                                  }
                                                  break;

                                                case 'deleteall':
                                                  deleteAllChats();
                                                  break;

                                                case 'unlock':
                                                  ChatController.unlockChat(
                                                      currentUserNo, peerNo);
                                                  break;
                                                case 'block':
                                                  // if (hasPeerBlockedMe == true) {
                                                  //   Fiberchat.toast(
                                                  //     getTranslated(context,
                                                  //         'userhasblocked'),
                                                  //   );
                                                  // } else {
                                                  ChatController.block(
                                                      currentUserNo, peerNo);
                                                  // }
                                                  break;
                                                case 'unblock':
                                                  // if (hasPeerBlockedMe == true) {
                                                  //   Fiberchat.toast(
                                                  //     getTranslated(context,
                                                  //         'userhasblocked'),
                                                  //   );
                                                  // } else {
                                                  ChatController.accept(
                                                      currentUserNo, peerNo);
                                                  Fiberchat.toast(getTranslated(
                                                      this.context,
                                                      'unblocked'));
                                                  // }

                                                  break;
                                                case 'tutorial':
                                                  Fiberchat.toast(getTranslated(
                                                      this.context, 'vsmsg'));

                                                  break;
                                                case 'remove_wallpaper':
                                                  _cachedModel
                                                      .removeWallpaper(peerNo!);
                                                  // Fiberchat.toast('Wallpaper removed.');
                                                  break;
                                                case 'set_wallpaper':
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
                                                                    getWallpaper,
                                                              )));
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
                                                                    widget
                                                                        .prefs)
                                                            ? fiberchatDIALOGColorDarkMode
                                                            : fiberchatDIALOGColorLightMode),
                                                      ),
                                                    ),
                                                  ),

                                                  PopupMenuItem<String>(
                                                    value: 'deleteall',
                                                    child: Text(
                                                      '${getTranslated(this.context, 'deleteallchats')}',
                                                      style: TextStyle(
                                                        color: pickTextColorBasedOnBgColorAdvanced(Thm
                                                                .isDarktheme(
                                                                    widget
                                                                        .prefs)
                                                            ? fiberchatDIALOGColorDarkMode
                                                            : fiberchatDIALOGColorLightMode),
                                                      ),
                                                    ),
                                                  ),

                                                  PopupMenuItem<String>(
                                                    value: hidden
                                                        ? 'unhide'
                                                        : 'hide',
                                                    child: Text(
                                                      '${hidden ? getTranslated(this.context, 'unhidechat') : getTranslated(this.context, 'hidechat')}',
                                                      style: TextStyle(
                                                        color: pickTextColorBasedOnBgColorAdvanced(Thm
                                                                .isDarktheme(
                                                                    widget
                                                                        .prefs)
                                                            ? fiberchatDIALOGColorDarkMode
                                                            : fiberchatDIALOGColorLightMode),
                                                      ),
                                                    ),
                                                  ),
                                                  PopupMenuItem<String>(
                                                    value: locked
                                                        ? 'unlock'
                                                        : 'lock',
                                                    child: Text(
                                                      '${locked ? getTranslated(this.context, 'unlockchat') : getTranslated(this.context, 'lockchat')}',
                                                      style: TextStyle(
                                                        color: pickTextColorBasedOnBgColorAdvanced(Thm
                                                                .isDarktheme(
                                                                    widget
                                                                        .prefs)
                                                            ? fiberchatDIALOGColorDarkMode
                                                            : fiberchatDIALOGColorLightMode),
                                                      ),
                                                    ),
                                                  ),
                                                  PopupMenuItem<String>(
                                                    value: isBlocked()
                                                        ? 'unblock'
                                                        : 'block',
                                                    child: Text(
                                                      '${isBlocked() ? getTranslated(this.context, 'unblockchat') : getTranslated(this.context, 'blockchat')}',
                                                      style: TextStyle(
                                                        color: pickTextColorBasedOnBgColorAdvanced(Thm
                                                                .isDarktheme(
                                                                    widget
                                                                        .prefs)
                                                            ? fiberchatDIALOGColorDarkMode
                                                            : fiberchatDIALOGColorLightMode),
                                                      ),
                                                    ),
                                                  ),
                                                  peer![Dbkeys.wallpaper] !=
                                                          null
                                                      ? PopupMenuItem<String>(
                                                          value:
                                                              'remove_wallpaper',
                                                          child: Text(
                                                            getTranslated(
                                                                this.context,
                                                                'removewall'),
                                                            style: TextStyle(
                                                              color: pickTextColorBasedOnBgColorAdvanced(Thm
                                                                      .isDarktheme(
                                                                          widget
                                                                              .prefs)
                                                                  ? fiberchatDIALOGColorDarkMode
                                                                  : fiberchatDIALOGColorLightMode),
                                                            ),
                                                          ))
                                                      : PopupMenuItem<String>(
                                                          value:
                                                              'set_wallpaper',
                                                          child: Text(
                                                            getTranslated(
                                                                this.context,
                                                                'setwall'),
                                                            style: TextStyle(
                                                              color: pickTextColorBasedOnBgColorAdvanced(Thm
                                                                      .isDarktheme(
                                                                          widget
                                                                              .prefs)
                                                                  ? fiberchatDIALOGColorDarkMode
                                                                  : fiberchatDIALOGColorLightMode),
                                                            ),
                                                          )),
                                                  PopupMenuItem<String>(
                                                    value: 'report',
                                                    child: Text(
                                                      '${getTranslated(this.context, 'report')}',
                                                      style: TextStyle(
                                                        color: pickTextColorBasedOnBgColorAdvanced(Thm
                                                                .isDarktheme(
                                                                    widget
                                                                        .prefs)
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
                                  body: Stack(
                                    children: <Widget>[
                                      new Container(
                                        decoration: new BoxDecoration(
                                          color: Thm.isDarktheme(widget.prefs)
                                              ? fiberchatCHATBACKGROUNDDarkMode
                                              : fiberchatCHATBACKGROUNDLightMode,
                                          image: new DecorationImage(
                                              image: peer![Dbkeys.wallpaper] ==
                                                      null
                                                  ? AssetImage(Thm.isDarktheme(
                                                          widget.prefs)
                                                      ? "assets/images/background_dark.png"
                                                      : "assets/images/background_light.png")
                                                  : Image.file(File(peer![
                                                          Dbkeys.wallpaper]))
                                                      .image,
                                              fit: BoxFit.cover),
                                        ),
                                      ),
                                      PageView(
                                        children: <Widget>[
                                          isDeletedDoc == true &&
                                                  isDeleteChatManually == false
                                              ? Center(
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(
                                                        15, 60, 15, 15),
                                                    child: Text(
                                                        getTranslated(
                                                            this.context,
                                                            'chatdeleted'),
                                                        style: TextStyle(
                                                            color:
                                                                fiberchatGrey)),
                                                  ),
                                                )
                                              : Column(
                                                  children: [
                                                    // List of messages

                                                    buildMessages(context),
                                                    // Input content
                                                    isBlocked()
                                                        ? AlertDialog(
                                                            backgroundColor: Thm
                                                                    .isDarktheme(
                                                                        widget
                                                                            .prefs)
                                                                ? fiberchatDIALOGColorDarkMode
                                                                : fiberchatDIALOGColorLightMode,
                                                            elevation: 10.0,
                                                            title: Text(
                                                              getTranslated(
                                                                      this.context,
                                                                      'unblock') +
                                                                  ' ${peer![Dbkeys.nickname]}?',
                                                              style: TextStyle(
                                                                color: pickTextColorBasedOnBgColorAdvanced(Thm
                                                                        .isDarktheme(
                                                                            widget.prefs)
                                                                    ? fiberchatDIALOGColorDarkMode
                                                                    : fiberchatDIALOGColorLightMode),
                                                              ),
                                                            ),
                                                            actions: <Widget>[
                                                              myElevatedButton(
                                                                  color: Thm.isDarktheme(
                                                                          widget
                                                                              .prefs)
                                                                      ? fiberchatDIALOGColorDarkMode
                                                                      : fiberchatDIALOGColorLightMode,
                                                                  child: Text(
                                                                    getTranslated(
                                                                        this.context,
                                                                        'cancel'),
                                                                    style:
                                                                        TextStyle(
                                                                      color: pickTextColorBasedOnBgColorAdvanced(Thm.isDarktheme(
                                                                              widget.prefs)
                                                                          ? fiberchatDIALOGColorDarkMode
                                                                          : fiberchatDIALOGColorLightMode),
                                                                    ),
                                                                  ),
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.pop(
                                                                        context);
                                                                  }),
                                                              myElevatedButton(
                                                                  color:
                                                                      fiberchatPRIMARYcolor,
                                                                  child: Text(
                                                                    getTranslated(
                                                                        this.context,
                                                                        'unblock'),
                                                                    style: TextStyle(
                                                                        color:
                                                                            fiberchatWhite),
                                                                  ),
                                                                  onPressed:
                                                                      () {
                                                                    ChatController.accept(
                                                                        currentUserNo,
                                                                        peerNo);
                                                                    setStateIfMounted(
                                                                        () {
                                                                      chatStatus = ChatStatus
                                                                          .accepted
                                                                          .index;
                                                                    });
                                                                  })
                                                            ],
                                                          )
                                                        : hasPeerBlockedMe ==
                                                                true
                                                            ? Container(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                padding:
                                                                    EdgeInsets
                                                                        .fromLTRB(
                                                                            14,
                                                                            7,
                                                                            14,
                                                                            7),
                                                                color: Colors
                                                                    .white
                                                                    .withOpacity(
                                                                        0.3),
                                                                height: 50,
                                                                width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                                child: Row(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Icon(
                                                                        Icons
                                                                            .error_outline_rounded,
                                                                        color: Colors
                                                                            .red),
                                                                    SizedBox(
                                                                        width:
                                                                            10),
                                                                    Text(
                                                                      getTranslated(
                                                                          context,
                                                                          'userhasblocked'),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style: TextStyle(
                                                                          height:
                                                                              1.3),
                                                                    ),
                                                                  ],
                                                                ),
                                                              )
                                                            : buildInputAndroid(
                                                                context,
                                                                isemojiShowing,
                                                                refreshInput,
                                                                _keyboardVisible)
                                                  ],
                                                ),
                                        ],
                                      ),
                                      // buildLoading()
                                    ],
                                  )),
                              buildLoadingThumbnail(),
                            ],
                          )
                    : Container();
              })))),
    );
  }

  deleteAllChats() async {
    if (messages.length > 0) {
      Fiberchat.toast(getTranslated(this.context, 'deleting'));
      await FirebaseFirestore.instance
          .collection(DbPaths.collectionmessages)
          .doc(chatId)
          .get()
          .then((v) async {
        if (v.exists) {
          var c = v;
          isDeleteChatManually = true;
          setStateIfMounted(() {});
          await v.reference.delete().then((value) async {
            messages = [];
            setStateIfMounted(() {});
            Future.delayed(const Duration(milliseconds: 10000), () async {
              await FirebaseFirestore.instance
                  .collection(DbPaths.collectionmessages)
                  .doc(chatId)
                  .set(c.data()!);
            });
          });
        }
      });
    } else {}
  }
}
