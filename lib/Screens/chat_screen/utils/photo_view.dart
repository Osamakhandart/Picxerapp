//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************
import 'package:fiberchat/Configs/app_constants.dart';
import 'package:fiberchat/Utils/utils.dart';
import 'package:fiberchat/widgets/DownloadManager/save_image_videos_in_gallery.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PhotoViewWrapper extends StatelessWidget {
  PhotoViewWrapper(
      {this.imageProvider,
      this.message,
      this.loadingChild,
      this.backgroundDecoration,
      this.minScale,
      this.maxScale,
      this.hideBackButton = false,
      required this.keyloader,
      required this.prefs,
      required this.imageUrl,
      required this.tag});

  final String tag;
  final String? message;
  final GlobalKey keyloader;
  final SharedPreferences prefs;
  final ImageProvider? imageProvider;
  final Widget? loadingChild;
  final Decoration? backgroundDecoration;
  final dynamic minScale;
  final String imageUrl;
  final dynamic maxScale;
  final bool hideBackButton;

  final GlobalKey<ScaffoldState> _scaffoldd = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Fiberchat.getNTPWrappedWidget(Scaffold(
        backgroundColor: Colors.black,
        key: _scaffoldd,
        // Added by JH: Add option to hide back button to work with swipe photos function
        appBar: hideBackButton
            ? null
            : AppBar(
                elevation: 0.4,
                leading: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    size: 24,
                    color: fiberchatWhite,
                  ),
                ),
                backgroundColor: Colors.transparent,
              ),

        //added by JH. Chatgp: In this code I want the floatingActionButton only to show if the storage permission was given. This can be checked with Fiberchat.checkAndRequestPermission(Permission.storage)

        floatingActionButton: FutureBuilder<bool>(
          future: Fiberchat.checkAndRequestPermission(Permission.storage),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Permission is being checked, show a loading indicator or placeholder.
              return CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(fiberchatSECONDARYolor),
              );
            } else if (snapshot.hasError) {
              // Error occurred while checking permission.
              // Handle the error appropriately.
              return Text('Error checking permission');
            } else if (snapshot.data == false) {
              // Storage permission not granted, show the FloatingActionButton.
              return FloatingActionButton(
                heroTag: "dfs32231t834",
                backgroundColor: fiberchatSECONDARYolor,
                onPressed: () async {
                  GalleryDownloader saver = GalleryDownloader();
                  saver.saveInGallery(imageUrl, context);
                  // Fiberchat.showRationale(
                  //   getTranslated(context, 'ps'),
                  // );
                },
                child: Icon(
                  Icons.file_download,
                ),
              );
            } else {
              // Storage permission granted, so download is automated
              return SizedBox.shrink();
            }
          },
        ),
        //added by JH until here

        body: Container(
            color: Colors.black,
            constraints: BoxConstraints.expand(
              height: MediaQuery.of(context).size.height,
            ),
            child: PhotoView(
              loadingBuilder: (BuildContext context, var image) {
                return loadingChild ??
                    Center(
                      child: Align(
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              fiberchatSECONDARYolor),
                        ),
                      ),
                    );
              },
              imageProvider: imageProvider,
              backgroundDecoration: backgroundDecoration as BoxDecoration?,
              minScale: minScale,
              maxScale: maxScale,
            ))));
  }
}
