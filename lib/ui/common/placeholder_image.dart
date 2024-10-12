import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:checkmate/constraints/jcolor.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../constraints/j_var.dart';

class ImageWithPlaceholder extends StatelessWidget {
  const ImageWithPlaceholder({
    Key? key,
    required this.image,
    required this.prefix,
    this.width = 80,
    this.height = 80,
    this.fit = BoxFit.cover,
  }) : super(key: key);

  final String? image;
  final String? prefix;
  final double? height;
  final double? width;
  final BoxFit? fit;

  @override
  Widget build(BuildContext context) {
    return image != null && image != ""
        ? CachedNetworkImage(
            imageUrl: "$prefix$image",
            height: height,
            width: width,
            fit: fit,
            imageBuilder: (context, imageProvider) => Container(
                  width: width,
                  height: height,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                      // colorFilter:
                      //     ColorFilter.mode(Colors.red, BlendMode.colorBurn),
                    ),
                  ),
                ),
            // progressIndicatorBuilder: (context, str, progress) {
            //   return
            // },
            placeholder: (context, url) => Shimmer.fromColors(
              baseColor: Colors.grey,
              highlightColor: Colors.white,
              child: Container(
                width: width,
                height: height,
                color: Colors.red,
              ),
            ),
            // errorWidget: (context, url, error) => Icon(Icons.error),
            errorWidget: (context, url, error) => Image.asset(
                  JVar.PLACEHOLDER_IMAGE_PATH,
                  height: height,
                  width: width,
                  fit: fit,
                ))
        : Image.asset(
            JVar.PLACEHOLDER_IMAGE_PATH,
            height: height,
            width: width,
            fit: fit,
          );
  }
}
