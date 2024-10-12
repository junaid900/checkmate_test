import 'dart:io';

import 'package:checkmate/constraints/jcolor.dart';
import 'package:checkmate/ui/common/touchable_opacity.dart';
import 'package:checkmate/ui/create_post/component/widgets/crop_page.dart';
import 'package:checkmate/ui/create_post/component/widgets/export_result.dart';
import 'package:checkmate/ui/create_post/component/widgets/export_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:video_editor/video_editor.dart';

class VideoEditor extends StatefulWidget {
  const VideoEditor({super.key, required this.file});

  final File file;

  @override
  State<VideoEditor> createState() => _VideoEditorState();
}

class _VideoEditorState extends State<VideoEditor> {
  final _exportingProgress = ValueNotifier<double>(0.0);
  final _isExporting = ValueNotifier<bool>(false);
  final double height = 60;

  late final VideoEditorController _controller = VideoEditorController.file(
    widget.file,
    minDuration: const Duration(seconds: 1),
    maxDuration: const Duration(seconds: 30),
  );

  @override
  void initState() {
    super.initState();
    _controller
        .initialize(aspectRatio: 9 / 16)
        .then((_) => setState(() {}))
        .catchError((error) {
      // handle minumum duration bigger than video duration error
      Navigator.pop(context);
    }, test: (e) => e is VideoMinDurationError);
  }

  @override
  void dispose() async {
    _exportingProgress.dispose();
    _isExporting.dispose();
    _controller.dispose();
    ExportService.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 1),
        ),
      );

  void _exportVideo() async {
    _exportingProgress.value = 0;
    _isExporting.value = true;

    final config = VideoFFmpegVideoEditorConfig(
      _controller,
      // format: VideoExportFormat.gif,
      // commandBuilder: (config, videoPath, outputPath) {
      //   final List<String> filters = config.getExportFilters();
      //   filters.add('hflip'); // add horizontal flip

      //   return '-i $videoPath ${config.filtersCmd(filters)} -preset ultrafast $outputPath';
      // },
    );

    await ExportService.runFFmpegCommand(
      await config.getExecuteConfig(),
      onProgress: (stats) {
        _exportingProgress.value =
            config.getFFmpegProgress(stats.getTime() as int);
      },
      onError: (e, s) => _showErrorSnackBar("Error on export video :("),
      onCompleted: (file) {
        _isExporting.value = false;
        if (!mounted) return;

        showDialog(
          context: context,
          builder: (_) => VideoResultPopup(video: file),
        );
      },
    );
  }

  void _saveVideo() async {
    Navigator.pop(context, _controller.file);
  }

  void _exportCover() async {
    final config = CoverFFmpegVideoEditorConfig(_controller);
    final execute = await config.getExecuteConfig();
    if (execute == null) {
      _showErrorSnackBar("Error on cover exportation initialization.");
      return;
    }

    await ExportService.runFFmpegCommand(
      execute,
      onError: (e, s) => _showErrorSnackBar("Error on cover exportation :("),
      onCompleted: (cover) {
        if (!mounted) return;

        showDialog(
          context: context,
          builder: (_) => CoverResultPopup(cover: cover),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: _controller.initialized
            ? SafeArea(
                child: Stack(
                  children: [
                    Column(
                      children: [
                        Expanded(
                          child: DefaultTabController(
                            length: 2,
                            child: Column(
                              children: [
                                Expanded(
                                  child: TabBarView(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    children: [
                                      Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          CropGridViewer.preview(
                                              controller: _controller),
                                          AnimatedBuilder(
                                            animation: _controller.video,
                                            builder: (_, __) => AnimatedOpacity(
                                              opacity:
                                                  _controller.isPlaying ? 0 : 1,
                                              duration: kThemeAnimationDuration,
                                              child: GestureDetector(
                                                onTap: _controller.video.play,
                                                child: Container(
                                                  width: 40,
                                                  height: 40,
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Colors.white,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(
                                                    Icons.play_arrow,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Align(
                                              alignment: Alignment.topRight,
                                              child: _topNavBar()),
                                        ],
                                      ),
                                      CoverViewer(
                                        controller: _controller,
                                      )
                                    ],
                                  ),
                                ),
                                ValueListenableBuilder(
                                  valueListenable: _isExporting,
                                  builder: (_, bool export, Widget? child) =>
                                      AnimatedSize(
                                    duration: kThemeAnimationDuration,
                                    child: export ? child : null,
                                  ),
                                  child: AlertDialog(
                                    title: ValueListenableBuilder(
                                      valueListenable: _exportingProgress,
                                      builder: (_, double value, __) => Text(
                                        "Exporting video ${(value * 100).ceil()}%",
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: 160,
                        margin: const EdgeInsets.only(top: 10),
                        color: Colors.grey.withOpacity(.3),
                        child: Column(
                          children: [
                            // TabBar(
                            //   tabs: [
                            //     Row(
                            //         mainAxisAlignment:
                            //         MainAxisAlignment.center,
                            //         children: const [
                            //           Padding(
                            //               padding: EdgeInsets.all(5),
                            //               child: Icon(
                            //                   Icons.content_cut)),
                            //           Text('Trim')
                            //         ]),
                            //     Row(
                            //       mainAxisAlignment:
                            //       MainAxisAlignment.center,
                            //       children: const [
                            //         Padding(
                            //             padding: EdgeInsets.all(5),
                            //             child:
                            //             Icon(Icons.video_label)),
                            //         Text('Cover')
                            //       ],
                            //     ),
                            //   ],
                            // ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: _trimSlider(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  ],
                ),
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _topNavBar() {
    return SafeArea(
      child: SizedBox(
        // height: height,
        child: Container(
          decoration: BoxDecoration(
              gradient:
                  LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [JColor.black.withOpacity(.7), Colors.transparent])),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              TouchableOpacity(
                onTap: _saveVideo,
                child:
                Container(
                    padding: EdgeInsets.symmetric(horizontal: 10,vertical: 2),
                    margin: EdgeInsets.only(right: 10,top: 24,bottom: 10),
                    decoration: BoxDecoration(
                        color: JColor.grey.withOpacity(.8) ,
                        borderRadius: BorderRadius.circular(8)
                    ), child: Text("Done",
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.white
                  ),)),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Row(
                  // mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Exit",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    SizedBox(width: 3),
                    const Icon(
                      Icons.exit_to_app_sharp,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ),
                tooltip: 'Leave editor',
              ),
              IconButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => CropPage(controller: _controller),
                  ),
                ),
                icon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Crop",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    SizedBox(width: 3),
                    const Icon(
                      Icons.crop,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ),
                tooltip: 'Open crop screen',
              ),
              // const VerticalDivider(endIndent: 22, indent: 22),
              IconButton(
                onPressed: () =>
                    _controller.rotate90Degrees(RotateDirection.left),
                icon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Rotate Left",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    SizedBox(width: 3),
                    const Icon(
                      Icons.rotate_left,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ),
                tooltip: 'Rotate Left',
              ),

              IconButton(
                onPressed: () =>
                    _controller.rotate90Degrees(RotateDirection.right),
                icon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Rotate Right",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    SizedBox(width: 3),
                    const Icon(
                      Icons.rotate_right,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ),
                tooltip: 'Rotate clockwise',
              ),

              // const VerticalDivider(endIndent: 22, indent: 22),

              // PopupMenuButton(
              //   tooltip: 'Save Video',
              //   icon: const Icon(Icons.save),
              //   itemBuilder: (context) => [
              //     PopupMenuItem(
              //       onTap: _saveVideo,
              //       child: const Text('Save Video'),
              //     ),
              //     // PopupMenuItem(
              //     //   onTap: _exportVideo,
              //     //   child: const Text('Export video'),
              //     // ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }

  String formatter(Duration duration) => [
        duration.inMinutes.remainder(60).toString().padLeft(2, '0'),
        duration.inSeconds.remainder(60).toString().padLeft(2, '0')
      ].join(":");

  List<Widget> _trimSlider() {
    return [
      AnimatedBuilder(
        animation: Listenable.merge([
          _controller,
          _controller.video,
        ]),
        builder: (_, __) {
          final int duration = _controller.videoDuration.inSeconds;
          final double pos = _controller.trimPosition * duration;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: height / 4),
            child: Row(children: [
              Text(formatter(Duration(seconds: pos.toInt())),style: TextStyle(
                  color: JColor.white,
                  fontSize: 12
              ),),
              const Expanded(child: SizedBox()),
              AnimatedOpacity(
                opacity: _controller.isTrimming ? 1 : 0,
                duration: kThemeAnimationDuration,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(formatter(_controller.startTrim),
                  style: TextStyle(
                    color: JColor.white,
                    fontSize: 12
                  ),),
                  const SizedBox(width: 10),
                  Text(formatter(_controller.endTrim),style: TextStyle(
                      color: JColor.white,
                      fontSize: 12
                  ),),
                ]),
              ),
            ]),
          );
        },
      ),
      SizedBox(height: 6,),
      Container(
        width: MediaQuery.of(context).size.width,
        // margin: EdgeInsets.symmetric(vertical: height / 4),
        child: TrimSlider(
          controller: _controller,
          height: height,
          horizontalMargin: height / 4,

          child: TrimTimeline(
            controller: _controller,
            padding: const EdgeInsets.only(top: 10),
            textStyle: TextStyle(
              color: Colors.white,
              fontSize: 10
            ),
          ),
        ),
      )
    ];
  }

  Widget _coverSelection() {
    return SingleChildScrollView(
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(15),
          child: CoverSelection(
            controller: _controller,
            size: height + 10,
            quantity: 8,
            selectedCoverBuilder: (cover, size) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  cover,
                  Icon(
                    Icons.check_circle,
                    color: const CoverSelectionStyle().selectedBorderColor,
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
