import 'package:fiberchat/Configs/Dbkeys.dart';
import 'package:fiberchat/Configs/Dbpaths.dart';
import 'package:fiberchat/Services/helpers/jh_progressService.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_compress/video_compress.dart' as compress;
import 'dart:io';
import 'package:workmanager/workmanager.dart';
import 'package:fiberchat/Configs/Enum.dart';


Future<List<File>> compressFiles(
    List<File> files, String? currentUserNo, String? chatId, String tempPath,
    {int? timestamp, bool isThumbnail = false}) async {
  List<File> filesToUpload = [];
  int index = 0;
  for (var file in files) {
    var fileToUpload;
    bool isImageFile = file.path.toLowerCase().endsWith('.png') ||
        file.path.toLowerCase().endsWith('.jpg') ||
        file.path.toLowerCase().endsWith('.jpeg');
    bool isVideoFile = file.path.toLowerCase().endsWith('.mp4');

    final targetPath = '$tempPath/temp$index.jpg';
    index += 1;
    // Compress image or video if needed
    if (isImageFile) {
      fileToUpload = await FlutterImageCompress.compressAndGetFile(
            file.absolute.path,
            targetPath,
            quality: 50, // Example quality value
          ) ??
          file;
    } else if (isVideoFile) {
      final compress.MediaInfo? info =
          await compress.VideoCompress.compressVideo(
        file.path,
        quality: compress.VideoQuality.MediumQuality,
        deleteOrigin: false,
        includeAudio: true,
      );
      if (info != null) fileToUpload = File(info.path!);
    }
    filesToUpload.add(fileToUpload);
  }
  return filesToUpload;
}

// Modified uploadEach function
 uploadEach(
    List<File> files,
    int index,
    String? currentUserNo,
    String? chatId,
    String textimageupload,
    String textimageuploadsuccess,
    NotificationService _notificationService) async {
  // Check if Firebase is already initialized
  if (Firebase.apps.isEmpty) {
    // This checks if any Firebase app is initialized
    await Firebase.initializeApp();
    print("Initialized Firebase in uploadEach");
  }

    /*
  if (index >= files.length) {
    // Show completion notification
    _notificationService.showCompletionNotification(
        0, textimageupload, textimageuploadsuccess);
    return;
  }
  print("uploadEach running");

  // Update the notification with the progress
  _notificationService.showProgressNotification(
      0,
      textimageupload,
      '$textimageupload ${index + 1} / ${files.length}',
      files.length,
      index + 1);
*/
    // Perform the upload

    var file = files[index];

  // Determine if the file is an image or a video
  bool isImageFile = file.path.toLowerCase().endsWith('.png') ||
      file.path.toLowerCase().endsWith('.jpg') ||
      file.path.toLowerCase().endsWith('.jpeg');

  // Initialize variables
  File fileToUpload = file;
  String mimeType = isImageFile
      ? 'image/jpeg'
      : 'video/mp4'; // Simplified, you can refine this
  int uploadTimestamp = DateTime.now().millisecondsSinceEpoch;
  String fileName = "$currentUserNo-$uploadTimestamp";

  // Upload file to Firebase Storage
  Reference reference =
      FirebaseStorage.instance.ref("+00_CHAT_MEDIA/$chatId/").child(fileName);
  UploadTask uploadTask =
      reference.putFile(fileToUpload, SettableMetadata(contentType: mimeType));
  TaskSnapshot taskSnapshot = await uploadTask;
  String downloadUrl = await taskSnapshot.ref.getDownloadURL();

  // Update Firestore database
  FirebaseFirestore.instance
      .collection(DbPaths.collectionusers)
      .doc(currentUserNo)
      .set({
    Dbkeys.mssgSent: FieldValue.increment(1),
  }, SetOptions(merge: true));

  FirebaseFirestore.instance
      .collection(DbPaths.collectiondashboard)
      .doc(DbPaths.docchatdata)
      .set({
    Dbkeys.mediamessagessent: FieldValue.increment(1),
  }, SetOptions(merge: true));

  // Continue with the next file
  uploadEach(files, index + 1, currentUserNo, chatId, textimageupload,
      textimageuploadsuccess, _notificationService);
}

// Call this function when starting the upload process
void uploadInBackground(List<File> files, String? currentUserNo, String? chatId,
    String textimageupload, String textimageuploadsuccess) {
  print("uploadInBackground running");
  const String taskName = "uploadTask";

  getTemporaryDirectory().then((directory) {
    var tempPath = directory.path;
    compressFiles(files, currentUserNo, chatId, tempPath).then((filesToUpload) {
      List<String> filePaths =
          filesToUpload.map((filesToUpload) => filesToUpload.path).toList();

      // Workmanager().registerOneOffTask(
      //   taskName,
      //   taskName,
      //   inputData: <String, dynamic>{
      //     'filePaths': filePaths,
      //     'currentUserNo': currentUserNo,
      //     'chatId': chatId,
      //     'textimageupload': textimageupload,
      //     'textimageuploadsuccess': textimageuploadsuccess
      //   },
      // );
    });
  });
}
