import 'package:flutter/material.dart';

class AppConstants {
  static const String replaceableText = "file://";
  static const List<String> imageExtensions = ['jpg', 'png', 'jpeg', 'gif'];
}

class ColorConstants {
  static const Color primaryColor = Color(0xff003664);
  static const Color appBarShadowColor = Color(0x4D202020);
  static const Color whiteColor = Color(0xffffffff);
  static const Color offWhiteColor = Color(0xffF5F5F5);
  static const Color greyColor = Colors.grey;
  static const Color blackColor = Colors.black;
}

class DimensionConstants {
  //Circular
  static const double circular20 = 20.0;

  //Padding
  static const double bottomPadding8 = 8.0;
  static const double bottomPadding10 = 10.0;
  static const double topPadding5 = 5.0;
  static const double topPadding10 = 10.0;
  static const double leftPadding15 = 15.0;
  static const double rightPadding20 = 20.0;
  static const double horizontalPadding5 = 5.0;
  static const double horizontalPadding10 = 10.0;
  static const double horizontalPadding34 = 34.0;
  static const double padding8 = 8.0;

  //Height
  static const double imageHeight30 = 30.0;
  static const double containerHeight50 = 50.0;
  static const double containerHeight60 = 60.0;
  static const double sizedBoxHeight5 = 5.0;

  //Width
  static const double sizedBoxWidth10 = 10.0;
  static const double imageWidth30 = 30.0;
}

class FileConstants {
  static const String icFile = "assets/images/ic_file.png";
  static const String icSend = "assets/images/ic_send.png";
  static const String icBack = "assets/images/ic_back.png";
  static const String icShareMedia = "assets/images/ic_share_media.png";
}

class FontSizeWeightConstants {
  //Font Size
  static const double fontSize14 = 14.0;
  static const double fontSize20 = 20.0;
  static const double fontSize24 = 24.0;

  //Font Weight
  static const FontWeight fontWeightBold = FontWeight.bold;
  static const FontWeight fontWeightNormal = FontWeight.normal;
  static const FontWeight fontWeight500 = FontWeight.w500;
}
