import 'dart:io';
import 'dart:ui';

import 'package:flutter/rendering.dart';

class Helpers {
  static Future<Image> checkImageSize(File image) async {
    var decodedImage = await decodeImageFromList(image.readAsBytesSync());
    return decodedImage;
  }
}
