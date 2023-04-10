import 'dart:math';

import 'package:flutter/material.dart';

class SellsServices {
  final BuildContext context;

  SellsServices(this.context);

  String generateRandomString(int length, bool number) {
    final random = Random();
    var availableChars =
        number ? '1234567890' : 'QWERTYUIOPASDFGHJKLZXCVBNM1234567890';
    final randomString = List.generate(length,
            (index) => availableChars[random.nextInt(availableChars.length)])
        .join();

    return randomString;
  }
}
