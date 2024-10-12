import 'package:checkmate/constraints/jcolor.dart';
import 'package:checkmate/ui/common/touchable_opacity.dart';
import 'package:flutter/material.dart';
import 'package:fraction/fraction.dart';
import 'package:video_editor/video_editor.dart';

class CropPage extends StatelessWidget {
  const CropPage({super.key, required this.controller});

  final VideoEditorController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30),
          child: Column(children: [
            Row(children: [
              Expanded(
                child: IconButton(
                  onPressed: () =>
                      controller.rotate90Degrees(RotateDirection.left),
                  icon: const Icon(Icons.rotate_left),
                ),
              ),
              Expanded(
                child: IconButton(
                  onPressed: () =>
                      controller.rotate90Degrees(RotateDirection.right),
                  icon: const Icon(Icons.rotate_right),
                ),
              )
            ]),
            // const SizedBox(height: 15),
            Expanded(
              child: CropGridViewer.edit(
                controller: controller,
                rotateCropArea: false,
                margin: const EdgeInsets.symmetric(horizontal: 20),
              ),
            ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     IconButton(
            //       onPressed: () => controller.preferredCropAspectRatio =
            //           controller.preferredCropAspectRatio
            //               ?.toFraction()
            //               .inverse()
            //               .toDouble(),
            //       icon: Row(
            //         children: [
            //           controller.preferredCropAspectRatio != null &&
            //                   controller.preferredCropAspectRatio! < 1
            //               ? const Icon(Icons.panorama_vertical_select_rounded)
            //               : const Icon(Icons.panorama_vertical_rounded),
            //           SizedBox(width: 4,),
            //           Text("Portrait")
            //         ],
            //       ),
            //     ),
            //     IconButton(
            //       onPressed: () => controller.preferredCropAspectRatio =
            //           controller.preferredCropAspectRatio
            //               ?.toFraction()
            //               .inverse()
            //               .toDouble(),
            //       icon: Row(
            //         children: [
            //           controller.preferredCropAspectRatio != null &&
            //                   controller.preferredCropAspectRatio! > 1
            //               ? const Icon(Icons.panorama_horizontal_select_rounded)
            //               : const Icon(Icons.panorama_horizontal_rounded),
            //           SizedBox(width: 4,),
            //           Text("Landscape")
            //         ],
            //       ),
            //     ),
            //   ],
            // ),
            const SizedBox(height: 15),
            Row(crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
              Expanded(
                flex: 2,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Center(
                    child: Text(
                      "Cancel",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: AnimatedBuilder(
                  animation: controller,
                  builder: (_, __) => Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildCropButton(context, null),
                          _buildCropButton(context, 1.toFraction()),
                          _buildCropButton(
                              context, Fraction.fromString("9/16")),
                          _buildCropButton(context, Fraction.fromString("3/4")),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: IconButton(
                  onPressed: () {
                    // WAY 1: validate crop parameters set in the crop view
                    controller.applyCacheCrop();
                    // WAY 2: update manually with Offset values
                    // controller.updateCrop(const Offset(0.2, 0.2), const Offset(0.8, 0.8));
                    Navigator.pop(context);
                  },
                  icon: Center(
                    child: Text(
                      "Done",
                      style: TextStyle(
                        color: const CropGridStyle().selectedBoundariesColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _buildCropButton(BuildContext context, Fraction? f) {
    if (controller.preferredCropAspectRatio != null &&
        controller.preferredCropAspectRatio! > 1) f = f?.inverse();

    return TouchableOpacity(
      onTap: (){
        controller.preferredCropAspectRatio = f?.toDouble();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
            color: controller.preferredCropAspectRatio == f?.toDouble()
                ? JColor.primaryColor
                : Colors.transparent,
            borderRadius: BorderRadius.circular(4)),
        // style: ElevatedButton.styleFrom(
        //   elevation: 0,
        //   backgroundColor: controller.preferredCropAspectRatio == f?.toDouble()
        //       ? Colors.grey.shade800
        //       : null,
        //   foregroundColor: controller.preferredCropAspectRatio == f?.toDouble()
        //       ? Colors.white
        //       : null,
        //   textStyle: Theme.of(context).textTheme.bodySmall,
        // ),
        // onPressed: () =>
        child: Text(
          f == null ? 'None' : '${f.numerator}:${f.denominator}',
          maxLines: 1,
          style: TextStyle(
            color: controller.preferredCropAspectRatio == f?.toDouble()
                ? Colors.white
                : null,
            fontSize: 13
          ),
        ),
      ),
    );
  }
}
