import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';

Widget showAndCloseDialog(title, content) {
  return AlertDialog(
    backgroundColor: Colors.green[500],
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    title: Text(title),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(content),
      ],
    ),
    titleTextStyle: const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 20,
    ),
    contentTextStyle: const TextStyle(
      color: Colors.white,
    ),
    icon: const Icon(
      Icons.check_circle,
      color: Colors.white,
    ),
  );
}
