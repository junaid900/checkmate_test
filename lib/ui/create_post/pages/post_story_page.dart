import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:camerawesome/pigeon.dart';
import 'package:camerawesome/src/orchestrator/models/camera_flashes.dart'
    as flash;
import 'package:checkmate/utils/route/route_names.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../../constraints/enum_values.dart';
import '../../../constraints/helpers/helper.dart';
import '../../../constraints/jcolor.dart';
import '../../common/touchable_opacity.dart';
import 'package:image/image.dart' as img;

import '../component/video_editor.dart';

class PostStoryPage extends StatefulWidget {
  const PostStoryPage({super.key});

  @override
  State<PostStoryPage> createState() => _PostStoryPageState();
}

class _PostStoryPageState extends State<PostStoryPage> {
  CameraController? controller;
  late List<CameraDescription> _cameras;
  int currentTab = 0;
  late img.Image _image;
  int selectedCamera = 0;
  Timer? timer;
  Duration time = Duration.zero;


  getPageData() async {
    WidgetsFlutterBinding.ensureInitialized();
    _cameras = await availableCameras();
    if (_cameras.length < 1) {
      showAlertDialog(context, "Error!", "No Available Camera Found",
          type: AlertType.ERROR);
      return;
    }
    controller = CameraController(
      _cameras[this.selectedCamera],
      ResolutionPreset.medium,
    );
    controller!.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            // Handle access errors here.
            break;
          default:
            // Handle other errors here.
            break;
        }
      }
    });
  }
  void _startTimer() {
    timer = Timer.periodic(Duration(milliseconds: 200), (timer) {
      setState(() {
        time = Duration(milliseconds: time.inMilliseconds + 200);
      });
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    final milSeconds = twoDigits(duration.inMilliseconds.remainder(60));
    return '$minutes:$seconds:$milSeconds';
  }
  @override
  void dispose() {
    // TODO: implement dispose
    if (controller != null) controller!.dispose();
    if(timer != null) timer!.cancel();
    super.dispose();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getPageData();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).orientation == Orientation.landscape) {
      // xScale = 1.0;
    }
    final yScale = 1.0;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(color: JColor.black),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              width: getWidth(context),
              height: getHeight(context),
              child: controller == null
                  ? cameraInitializeError()
                  : controller!.value.isInitialized
                      ? Center(child: Builder(builder: (context) {
                          var tmp = MediaQuery.of(context).size;

                          final screenH = math.max(tmp.height, tmp.width);
                          final screenW = math.min(tmp.height, tmp.width);

                          tmp = controller!.value.previewSize!;

                          final previewH = math.max(tmp.height, tmp.width);
                          final previewW = math.min(tmp.height, tmp.width);
                          final screenRatio = screenH / screenW;
                          final previewRatio = previewH / previewW;
                          return OverflowBox(
                              maxHeight: screenRatio > previewRatio
                                  ? screenH
                                  : screenW / previewW * previewH,
                              maxWidth: screenRatio > previewRatio
                                  ? screenH / previewH * previewW
                                  : screenW,
                              child: CameraPreview(
                                controller!,
                              ));
                        }))
                      : cameraInitializeError(),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                      color: JColor.greyTextColor.withOpacity(.5),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(Icons.close, color: Colors.white),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                      color: JColor.greyTextColor.withOpacity(.5),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: IconButton(
                      onPressed: () async {
                        _cameras = await availableCameras();
                        if (_cameras.length < 1) {
                          showAlertDialog(
                              context, "Error!", "No No Available Camera Found",
                              type: AlertType.ERROR);
                          return;
                        }
                        setState(() {
                          selectedCamera = selectedCamera == 0 ? 1 : 0;
                        });
                        if (selectedCamera > 0) {
                          if (!(_cameras.length > 1)) {
                            showAlertDialog(context, "Error!",
                                "No No Available Camera Found",
                                type: AlertType.ERROR);
                            return;
                          }
                        }
                        controller = null;
                        controller = CameraController(
                          _cameras[this.selectedCamera],
                          ResolutionPreset.high,
                        );
                        controller!.initialize().then((value) {
                          setState(() {});
                        });
                      },
                      icon:
                          Icon(Icons.flip_camera_android, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              // height: 90,
              padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
              decoration: BoxDecoration(
                color: JColor.black.withOpacity(.6),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TouchableOpacity(
                    onTap: () {
                      pickVideoFromGallery();
                    },
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: JColor.black.withOpacity(.6),
                      ),
                      child: Image.asset("assets/icons/gallary.png",
                          width: 42, height: 42),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TouchableOpacity(
                        onTap: () async {
                          if (controller == null) {
                            return;
                          }
                          print(controller!.value.isRecordingVideo);
                          if (controller!.value.isRecordingVideo) {
                            controller?.stopVideoRecording().then((value) async {
                              setState(() {});
                              if (value != null) {
                                if(timer!= null) {
                                  timer!.cancel();
                                  time = Duration.zero;
                                }
                                print("file1 ----");
                                print(value.path);
                                final Directory tempDir = await getTemporaryDirectory();
                                final String tempPath = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.mp4';
                                final videoFile = await File(value.path).rename(tempPath);
                                editVideo(videoFile);
                              }
                            });
                          } else {
                            controller?.startVideoRecording().then((value) {
                              _startTimer();
                              setState(() {});
                            });
                          }
                        },
                        child: AnimatedSwitcher(
                          duration: Duration(milliseconds: 700),
                          child:  controller != null &&
                              controller!.value.isRecordingVideo
                              ?Image.asset(
                            "assets/icons/stop_recording.png",
                            width: 70,
                          ):Image.asset(
                            "assets/icons/recording.png",
                            width: 70,
                          ),
                        ),
                      ),
                      SizedBox(height: 2,),
                      AnimatedSwitcher(
                        duration: Duration(milliseconds: 100),
                        child: (time == Duration.zero) ? SizedBox():Text("${_formatDuration(time)}",
                        style: TextStyle(
                          color: JColor.grey
                        ),),
                      )
                    ],
                  ),
                  SizedBox(
                    width: 60,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget cameraInitializeError() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      child: Center(
        child: Text(
          "",
          style: TextStyle(color: JColor.white),
        ),
      ),
    );
  }
  editVideo(File videoFile) async {
    var data = await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) =>
            VideoEditor(file: videoFile),
      ),
    );
    File? file = (data as File);
    if (file != null) {
      Navigator.of(context).pushNamed(
          JRoutes.postStoryScreen,
          arguments: file);
      return;
    }
  }
  pickVideoFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? video =
        await picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      editVideo(File(video.path));
    }
  }
}

class CameraPainter extends CustomPainter {
  final img.Image image;

  CameraPainter(this.image);

  @override
  void paint(Canvas canvas, Size size) async {
    final uiImage = await _convertImageToUiImage(image);
    canvas.drawImage(uiImage, Offset.zero, Paint());
  }

  Future<ui.Image> _convertImageToUiImage(img.Image image) async {
    final completer = Completer<ui.Image>();
    final byteData = Uint8List.fromList(img.encodePng(image));
    ui.decodeImageFromList(byteData, (img) {
      completer.complete(img);
    });
    return completer.future;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class AwesomeCameraCustomWidget extends StatefulWidget {
  const AwesomeCameraCustomWidget({super.key});

  @override
  State<AwesomeCameraCustomWidget> createState() =>
      _AwesomeCameraCustomWidgetState();
}

class _AwesomeCameraCustomWidgetState extends State<AwesomeCameraCustomWidget> {
  @override
  Widget build(BuildContext context) {
    return CameraAwesomeBuilder.awesome(
      saveConfig: SaveConfig.video(
        // initialCaptureMode: CaptureMode.video,
        // photoPathBuilder: (sensors) async {
        //   final Directory extDir = await getTemporaryDirectory();
        //   final testDir = await Directory(
        //     '${extDir.path}/camerawesome',
        //   ).create(recursive: true);
        //   if (sensors.length == 1) {
        //     final String filePath =
        //         '${testDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
        //     return SingleCaptureRequest(filePath, sensors.first);
        //   } else {
        //     // Separate pictures taken with front and back camera
        //     return MultipleCaptureRequest(
        //       {
        //         for (final sensor in sensors)
        //           sensor:
        //           '${testDir.path}/${sensor.position == SensorPosition.front ? 'front_' : "back_"}${DateTime.now().millisecondsSinceEpoch}.jpg',
        //       },
        //     );
        //   }
        // },

        videoOptions: VideoOptions(
          enableAudio: true,
          ios: CupertinoVideoOptions(
            fps: 10,
          ),
          android: AndroidVideoOptions(
            bitrate: 6000000,
            fallbackStrategy: QualityFallbackStrategy.lower,
          ),
        ),
      ),
      enablePhysicalButton: true,
      previewAlignment: Alignment.center,
      previewFit: CameraPreviewFit.contain,
      onMediaTap: (mediaCapture) {
        mediaCapture.captureRequest.when(
          single: (single) {},
        );
      },
      availableFilters: awesomePresetFiltersList,
      defaultFilter: AwesomeFilter.AddictiveRed,
    );
  }
}
