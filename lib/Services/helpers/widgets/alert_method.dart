import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

void alertMethod(
    {context,
    childrenData,
    click,
    buttonText,
    titleText,
    theme,
    isButtonShow = false,
    onClose,
    CrossAxisAlignment align = CrossAxisAlignment.center}) {
  Alert(
    closeFunction: onClose ?? () {},
    // closeFunction: () {},
    context: context,
    title: titleText,
    content: Container(
      child: Column(
        crossAxisAlignment: align,
        children: childrenData,
      ),
    ),
    style: AlertStyle(
      isButtonVisible: isButtonShow,
      isOverlayTapDismiss: false,
      isCloseButton: false,
      titleStyle:
          TextStyle(fontSize: 20, color: theme, fontWeight: FontWeight.w400),
      backgroundColor: Colors.white,
      animationDuration: Duration(milliseconds: 400),
      animationType: AnimationType.grow,
    ),
  ).show();
}
