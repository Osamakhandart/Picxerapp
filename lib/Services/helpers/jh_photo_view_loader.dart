import 'package:cached_network_image/cached_network_image.dart';
import 'package:fiberchat/Configs/Dbkeys.dart';
import 'package:fiberchat/Configs/app_constants.dart';
import 'package:fiberchat/Screens/chat_screen/utils/photo_view.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PhotoViewLoader extends StatefulWidget {
  PhotoViewLoader({
    required this.keyloader,
    required this.prefs,
    required this.imageUrl,
    required this.allDocs,
  });

  final GlobalKey keyloader;
  final SharedPreferences prefs;
  final String imageUrl;
  final List<Map<String, dynamic>> allDocs;

  static void push(
    BuildContext context, {
    required GlobalKey keyloader,
    required SharedPreferences prefs,
    required List<Map<String, dynamic>> allDocs,
    required String imageUrl,
  }) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PhotoViewLoader(
            prefs: prefs,
            keyloader: keyloader,
            allDocs: allDocs,
            imageUrl: imageUrl,
          ),
        ));
  }

  @override
  State<PhotoViewLoader> createState() => _PhotoViewLoaderState();
}

class _PhotoViewLoaderState extends State<PhotoViewLoader> {
  late int currentIndex;

  late PageController controller;

  @override
  void initState() {
    super.initState();

    final currentList = widget.allDocs
        .where((element) => element[Dbkeys.content] == widget.imageUrl)
        .toList();

    if (currentList.isNotEmpty) {
      currentIndex = widget.allDocs.indexOf(currentList.first);
    }

    controller = PageController(initialPage: currentIndex);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0.4,
        // Add option to hide back button to work with swipe photos function
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
      body: widget.allDocs.isNotEmpty
          ? PageView.builder(
              controller: controller,
              itemCount: widget.allDocs.length,
              itemBuilder: (context, index) {
                final imgDoc = widget.allDocs[index];
                final content = imgDoc[Dbkeys.content];
                final imgProvider = CachedNetworkImageProvider(content);

                return PhotoViewWrapper(
                  prefs: widget.prefs,
                  keyloader: widget.keyloader,
                  imageUrl: content,
                  message: content,
                  tag: imgDoc[Dbkeys.timestamp].toString(),
                  imageProvider: imgProvider,
                  hideBackButton: true,
                );
              },
            )
          : const SizedBox(),
    );
  }
}
