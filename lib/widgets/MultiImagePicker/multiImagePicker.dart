//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'dart:io';
import 'package:fiberchat/Configs/app_constants.dart';
import 'package:fiberchat/Screens/status/components/VideoPicker/VideoPicker.dart';
import 'package:fiberchat/Services/Providers/Observer.dart';
import 'package:fiberchat/Services/helpers/jh_uploadInBackground.dart';
import 'package:fiberchat/Services/helpers/jh_wifiPermissions.dart';
import 'package:fiberchat/Services/localization/language_constants.dart';
import 'package:fiberchat/Utils/color_detector.dart';
import 'package:fiberchat/Utils/open_settings.dart';
import 'package:fiberchat/Utils/theme_management.dart';
import 'package:fiberchat/Utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MultiImagePicker extends StatefulWidget {
  MultiImagePicker(
      {Key? key,
      required this.title,
      required this.prefs,
      required this.callback,
      this.writeMessage,
      this.profile = false,
      this.currentUserNo = '', //added by JH
      this.chatId //added by JH
      })
      : super(key: key);

  final String title;
  final SharedPreferences prefs;
  final Function callback;
  final bool profile;
  final Future<void> Function(String url, int timestamp)? writeMessage;
  final String? currentUserNo; //added by JH
  final String? chatId;

  @override
  _MultiImagePickerState createState() => new _MultiImagePickerState();
}

class _MultiImagePickerState extends State<MultiImagePicker> {
  ImagePicker picker = ImagePicker();
  bool isLoading = false;
  String? error;
  String mode = 'single';
  List<XFile> selectedImages = [];
  int currentUploadingIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  bool checkTotalNoOfFilesIfExceeded() {
    final observer = Provider.of<Observer>(this.context, listen: false);
    if (selectedImages.length > observer.maxNoOfFilesInMultiSharing) {
      return true;
    } else {
      return false;
    }
  }

  bool checkIfAnyFileSizeExceeded() {
    final observer = Provider.of<Observer>(this.context, listen: false);
    int index = selectedImages.indexWhere((file) =>
        File(file.path).lengthSync() / 1000000 >
        observer.maxFileSizeAllowedInMB);
    if (index >= 0) {
      return true;
    } else {
      return false;
    }
  }

  void captureSingleImage(ImageSource captureMode) async {
    final observer = Provider.of<Observer>(this.context, listen: false);
    error = null;
    try {
      XFile? pickedImage = await (picker.pickImage(source: captureMode));
      if (pickedImage != null) {
        if (File(pickedImage.path).lengthSync() / 1000000 >
            observer.maxFileSizeAllowedInMB) {
          error =
              '${getTranslated(this.context, 'maxfilesize')} ${observer.maxFileSizeAllowedInMB}MB\n\n${getTranslated(this.context, 'selectedfilesize')} ${(File(pickedImage.path).lengthSync() / 1000000).round()}MB';

          setState(() {
            mode = "single";
            selectedImages = [];
          });
        } else {
          setState(() {
            mode = "single";
            selectedImages.add(pickedImage);
          });
        }
      }
    } catch (e) {}
  }

  void captureMultiPageImage(bool isAddOnly) async {
    final observer = Provider.of<Observer>(this.context, listen: false);
    error = null;
    try {
      if (isAddOnly) {
        //--- Is adding to already selected images list.
        List<XFile>? images = await picker.pickMultiImage();
        if (images.length > 0) {
          images.forEach((image) {
            if (!selectedImages.contains(image)) {
              selectedImages.add(image);
            }
          });

          mode = 'multi';
          error = null;
          setState(() {});
        }
      } else {
        //--- Is adding to empty selected image list.
        List<XFile>? images = await picker.pickMultiImage();
        if (images.length > 1) {
          selectedImages = images;
          mode = 'multi';
          error = null;
          setState(() {});
        } else if (images.length == 1) {
          if (File(images[0].path).lengthSync() / 1000000 >
              observer.maxFileSizeAllowedInMB) {
            error =
                '${getTranslated(this.context, 'maxfilesize')} ${observer.maxFileSizeAllowedInMB}MB\n\n${getTranslated(this.context, 'selectedfilesize')} ${(File(images[0].path).lengthSync() / 1000000).round()}MB';

            setState(() {
              mode = "single";
            });
          } else {
            setState(() {
              mode = "single";
              selectedImages = images;
            });
          }
        }
      }
    } catch (e) {}
  }

  Widget _buildSingleImage({File? file}) {
    if (file != null) {
      return new Image.file(file);
    } else {
      return new Text(getTranslated(context, 'takeimage'),
          style: new TextStyle(
            fontSize: 18.0,
            color: fiberchatGrey,
          ));
    }
  }

  Widget _buildMultiImageLoading() {
    return Container(
      child: Center(
          child: SizedBox(
              width: 300,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${currentUploadingIndex + 1}/${selectedImages.length}',
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 26,
                        color: pickTextColorBasedOnBgColorAdvanced(
                            //changed from color: fiberchatPRIMARYcolor by JH
                            Thm.isDarktheme(widget.prefs)
                                ? fiberchatAPPBARcolorDarkMode
                                : fiberchatAPPBARcolorLightMode)),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    getTranslated(this.context, 'sending'),
                    textAlign: TextAlign.center, //added by JH
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 17,
                        color: pickTextColorBasedOnBgColorAdvanced(
                            Thm.isDarktheme(widget.prefs)
                                ? fiberchatAPPBARcolorDarkMode
                                : fiberchatAPPBARcolorLightMode)),
                  )
                ],
              ))),
      color: Thm.isDarktheme(
              widget.prefs) //deleted pickTextColorBasedOnBgColorAdvanced( by JH
          ? fiberchatAPPBARcolorDarkMode
          : fiberchatAPPBARcolorLightMode.withOpacity(0.8),
    );
  }

  Widget _buildMultiImage() {
    final observer = Provider.of<Observer>(this.context, listen: false);
    if (selectedImages.length > 0) {
      return GridView.builder(
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              childAspectRatio: 1,
              crossAxisSpacing: 7,
              mainAxisSpacing: 7),
          itemCount: selectedImages.length,
          itemBuilder: (BuildContext context, i) {
            return Container(
              alignment: Alignment.center,
              child: Stack(
                children: [
                  Container(
                    height: (MediaQuery.of(context).size.width / 2) - 20,
                    width: (MediaQuery.of(context).size.width / 2) - 20,
                    color: fiberchatGrey.withOpacity(0.4),
                  ),
                  new Image.file(
                    File(selectedImages[i].path),
                    fit: BoxFit.cover,
                    height: (MediaQuery.of(context).size.width / 2) - 20,
                    width: (MediaQuery.of(context).size.width / 2) - 20,
                  ),
                  File(selectedImages[i].path).lengthSync() / 1000000 >
                          observer.maxFileSizeAllowedInMB
                      ? Container(
                          height: (MediaQuery.of(context).size.width / 2) - 20,
                          width: (MediaQuery.of(context).size.width / 2) - 20,
                          color: Colors.white70,
                          child: Center(
                            child: Padding(
                              padding: EdgeInsetsDirectional.all(10),
                              child: Text(
                                '${getTranslated(this.context, 'maxfilesize')} ${observer.maxFileSizeAllowedInMB}MB\n${getTranslated(this.context, 'selectedfilesize')} ${(File(selectedImages[i].path).lengthSync() / 1000000).round()}MB',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: fiberchatREDbuttonColor,
                                    fontWeight: FontWeight.w700),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 6,
                              ),
                            ),
                          ),
                        )
                      : SizedBox(),
                  Positioned(
                    right: 7,
                    top: 7,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          selectedImages.removeAt(i);
                          if (selectedImages.length <= 1) {
                            mode = "single";
                          }
                        });
                      },
                      child: Container(
                        width: 25,
                        height: 25,
                        decoration: new BoxDecoration(
                          color: Colors.black.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: new Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 17,
                        ),
                      ),
                    ),
                  )
                ],
              ),
              // decoration: BoxDecoration(
              //     color: Colors.amber, borderRadius: BorderRadius.circular(15)),
            );
          });
    } else {
      return new Text(getTranslated(context, 'takeimage'),
          style: new TextStyle(
            fontSize: 18.0,
            color: fiberchatGrey,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final observer = Provider.of<Observer>(this.context, listen: false);
    return Fiberchat.getNTPWrappedWidget(WillPopScope(
      child: Scaffold(
        backgroundColor: Thm.isDarktheme(widget.prefs)
            ? fiberchatBACKGROUNDcolorDarkMode
            : fiberchatBACKGROUNDcolorLightMode,
        appBar: new AppBar(
            elevation: 0.4,
            leading: IconButton(
              onPressed: () {
                if (!isLoading) {
                  Navigator.of(context).pop();
                }
              },
              icon: Icon(
                Icons.keyboard_arrow_left,
                size: 30,
                color: pickTextColorBasedOnBgColorAdvanced(
                    Thm.isDarktheme(widget.prefs)
                        ? fiberchatAPPBARcolorDarkMode
                        : fiberchatAPPBARcolorLightMode),
              ),
            ),
            title: new Text(
              selectedImages.length > 0
                  ? '${selectedImages.length} ${getTranslated(this.context, 'selected')}'
                  : widget.title,
              style: TextStyle(
                fontSize: 18,
                color: pickTextColorBasedOnBgColorAdvanced(
                    Thm.isDarktheme(widget.prefs)
                        ? fiberchatAPPBARcolorDarkMode
                        : fiberchatAPPBARcolorLightMode),
              ),
            ),
            backgroundColor: Thm.isDarktheme(widget
                    .prefs) //pickTextColorBasedOnBgColorAdvanced( removed by JH
                ? fiberchatAPPBARcolorDarkMode
                : fiberchatAPPBARcolorLightMode,
            actions: selectedImages.length != 0 && !isLoading
                ? <Widget>[
                    IconButton(
                        icon: Icon(
                          Icons.check,
                          color: pickTextColorBasedOnBgColorAdvanced(
                              Thm.isDarktheme(widget.prefs)
                                  ? fiberchatAPPBARcolorDarkMode
                                  : fiberchatAPPBARcolorLightMode),
                        ),
                        onPressed: checkTotalNoOfFilesIfExceeded() == false
                            ? (checkIfAnyFileSizeExceeded() == false
                                ? () async {
                                    //changed by JH beginning
                                    setState(() {
                                      isLoading = false;
                                    });
                                    // int i=0;
                                    // for(int i =0 ; i<selectedImages.length;i++)
                                    //   {
                                    await uploadEach(0);
                                    // }
                                    // List<File> filesToUpload = selectedImages
                                    //     .map((xfile) async {
                                    //   await uploadEach(i);
                                    //   i++;
                                    //   return File(xfile.path);
                                    // })
                                    //     .toList();
                                    // ScaffoldMessenger.of(context).showSnackBar(
                                    //   SnackBar(
                                    //     content: Text(getTranslated(context,
                                    //         "imagesuploadingbackground")),
                                    //     duration: Duration(seconds: 3),
                                    //   ),
                                    // );
                                    // uploadEach(0);
                                    // uploadInBackground(
                                    //   filesToUpload,
                                    //   widget.currentUserNo,
                                    //   widget.chatId,
                                    //   getTranslated(context, "imageupload"),
                                    //   getTranslated(
                                    //       context, "imageuploadsuccess"),
                                    // );

                                    // Navigator.of(context).pop();
                                    //changed by JH end
                                  }
                                : () {
                                    final observer = Provider.of<Observer>(
                                        this.context,
                                        listen: false);
                                    Fiberchat.toast(getTranslated(
                                            context, 'filesizeexceeded') +
                                        ': ${observer.maxFileSizeAllowedInMB}MB');
                                  })
                            : () {
                                Fiberchat.toast(
                                    '${getTranslated(this.context, 'maxnooffiles')}: ${observer.maxNoOfFilesInMultiSharing}');
                              }),
                    SizedBox(
                      width: 8.0,
                    )
                  ]
                : []),
        body: Stack(children: [
          new Column(children: [
            mode == 'single'
                ? new Expanded(
                    child: new Center(
                        child: error != null
                            ? fileSizeErrorWidget(error!)
                            : _buildSingleImage(
                                file: selectedImages.length > 0
                                    ? File(selectedImages[0].path)
                                    : null)))
                : new Expanded(child: new Center(child: _buildMultiImage())),
            _buildButtons()
          ]),
          Positioned(
            child: isLoading
                ? mode == "multi" && selectedImages.length > 1
                    ? _buildMultiImageLoading()
                    : Container(
                        child: Center(
                          child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  fiberchatSECONDARYolor)),
                        ),
                        color: pickTextColorBasedOnBgColorAdvanced(
                                !Thm.isDarktheme(widget.prefs)
                                    ? fiberchatAPPBARcolorDarkMode
                                    : fiberchatAPPBARcolorLightMode)
                            .withOpacity(0.6),
                      )
                : Container(),
          )
        ]),
      ),
      onWillPop: () => Future.value(!isLoading),
    ));
  }

  uploadEach(int index) async {
    if (mounted) {
      Navigator.of(context).pop();
    }
    if (index > selectedImages.length) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    } else {
      int messagetime = DateTime.now().millisecondsSinceEpoch;
      // setState(() {
      currentUploadingIndex = index;
      // });
      // if(index<selectedImages.length) {
      await widget
          .callback(File(selectedImages[index].path),
              timestamp: messagetime, totalFiles: selectedImages.length)
          .then((imageUrl) async {
        await widget.writeMessage!(imageUrl, messagetime).then((value) {
          if (selectedImages.last == selectedImages[index]) {
            if (mounted) {
              Navigator.of(context).pop();
            }
          } else {
            uploadEach(currentUploadingIndex + 1);
          }
        });
      });
      // }
    }
  }

  Widget _buildButtons() {
    final observer = Provider.of<Observer>(this.context, listen: false);
    return new ConstrainedBox(
        constraints: BoxConstraints.expand(height: 80.0),
        child: new Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _buildActionButton(
                  new Key('multi'),
                  Icons.photo_library,
                  checkTotalNoOfFilesIfExceeded() == false
                      ? () {
                          //changed by JH
                          PermissionService permissionService =
                              PermissionService();
                          permissionService
                              .requestPermission(
                                  Permission.storage, "Gallery", context)
                              //changed by JH until here
                              .then((res) {
                            if (res == true) {
                              captureMultiPageImage(false);
                            } else if (res == false) {
                              Fiberchat.showRationale(
                                  getTranslated(context, 'pgi'));
                              Navigator.pushReplacement(
                                  context,
                                  new MaterialPageRoute(
                                      builder: (context) => OpenSettings(
                                            prefs: widget.prefs,
                                          )));
                            } else {}
                          });
                        }
                      : () {
                          Fiberchat.toast(
                              '${getTranslated(this.context, 'maxnooffiles')}: ${observer.maxNoOfFilesInMultiSharing}');
                        }),
              selectedImages.length < 1
                  ? SizedBox()
                  : _buildActionButton(
                      new Key('multi'),
                      Icons.add,
                      checkTotalNoOfFilesIfExceeded() == false
                          ? () {
                              Fiberchat.checkAndRequestPermission(
                                      Permission.storage)
                                  .then((res) {
                                if (res == true) {
                                  captureMultiPageImage(true);
                                } else if (res == false) {
                                  Fiberchat.showRationale(
                                      getTranslated(context, 'pgi'));
                                  Navigator.pushReplacement(
                                      context,
                                      new MaterialPageRoute(
                                          builder: (context) => OpenSettings(
                                                prefs: widget.prefs,
                                              )));
                                } else {}
                              });
                            }
                          : () {
                              Fiberchat.toast(
                                  '${getTranslated(this.context, 'maxnooffiles')}: ${observer.maxNoOfFilesInMultiSharing}');
                            }),
              _buildActionButton(
                  new Key('upload'),
                  Icons.photo_camera,
                  checkTotalNoOfFilesIfExceeded() == false
                      ? () {
                          Fiberchat.checkAndRequestPermission(Permission.camera)
                              .then((res) {
                            if (res == true) {
                              captureSingleImage(ImageSource.camera);
                            } else if (res == false) {
                              getTranslated(context, 'pci');
                              Navigator.pushReplacement(
                                  context,
                                  new MaterialPageRoute(
                                      builder: (context) => OpenSettings(
                                            prefs: widget.prefs,
                                          )));
                            } else {}
                          });
                        }
                      : () {
                          Fiberchat.toast(
                              '${getTranslated(this.context, 'maxnooffiles')}: ${observer.maxNoOfFilesInMultiSharing}');
                        }),
            ]));
  }

  Widget _buildActionButton(Key key, IconData icon, Function onPressed) {
    return new Expanded(
      child: new IconButton(
          key: key,
          icon: Icon(icon, size: 30.0),
          color: fiberchatSECONDARYolor,
          onPressed: onPressed as void Function()?),
    );
  }
}
