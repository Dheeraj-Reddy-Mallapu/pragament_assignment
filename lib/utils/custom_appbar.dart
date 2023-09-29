import 'package:flutter/material.dart';

import 'back_screen_button.dart';

AppBar customAppBar(
  String title, {
  bool hvBack = true,
  bool centerTitle = true,
  bool hvClose = false,
  bool hvActions = false,
  List<Widget>? actions,
}) =>
    AppBar(
      title: Text(
        title,
      ),
      centerTitle: centerTitle,
      leading: hvBack
          ? hvClose
              ? CloseButton()
              : BackScreenButton()
          : null,
      actions: hvActions ? actions : null,
    );
