import 'dart:developer';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_token_service/agora_token_service.dart';
import 'package:checkmate/constraints/enum_values.dart';
import 'package:checkmate/constraints/helpers/helper.dart';
import 'package:checkmate/constraints/jcolor.dart';
import 'package:checkmate/providers/firebase/firebase_live_stream_provider.dart';
import 'package:checkmate/providers/live_stream/live_stream_provider.dart';
import 'package:checkmate/providers/user/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../constraints/j_var.dart';
import '../../modals/User.dart';
import '../../modals/live_stream.dart';

class LiveStreamScreen extends StatefulWidget {
  const LiveStreamScreen({super.key});

  @override
  State<LiveStreamScreen> createState() => _LiveStreamScreenState();
}

class _LiveStreamScreenState extends State<LiveStreamScreen> {
  int? _remoteUid;
  bool _localUserJoined = false;
  String? _localUid;
  bool isBroadcaster = false;
  RtcEngine? _engine;
  bool muted = false;
  String? myTkn;
  LiveStream? liveStream;
  late final AppLifecycleListener _listener;
  List<String> statusLog = [];
  List<int> remoteUsers = [];
  bool debug = false;
  User? user;

  Future<PermissionStatus> handlePermission(Permission permission) async {
    final status = await permission.request();
    return status;
  }

  showErrorAlert(title, message) {
    showAlertDialog(context, title, message, onPress: () {
      Navigator.of(context).pop();
      _onCallEnd(context);
    }, showCancelButton: false, type: AlertType.ERROR, dismissible: false);
  }

  Future getPageData() async {
    var data = ModalRoute.of(context)!.settings.arguments;
    setState(() {
      user = context.read<ProfileProvider>().profile;
    });
    if (data != null) {
      try {
        data = data as Map;
        statusLog.add("init stream");
        liveStream = data["stream"] as LiveStream;
        if (liveStream == null) {
          log("No steam found");
          showErrorAlert("Error!", "Cannot find stream");
        }
        if (liveStream!.userId == null) {
          log("No user found");
          showErrorAlert("Error!", "Cannot find stream");
        }
        var profileProvider = context.read<ProfileProvider>();
        if (liveStream!.userId == profileProvider.profile.id) {
          setState(() {
            isBroadcaster = true;
          });
        } else {
          // _remoteUid = convertNumber(liveStream!.agoraUid);
        }
      } catch (e) {
        statusLog.add("error while getting stream");
        showErrorAlert("Error!", "Cannot find stream");
        return;
      }
    } else {
      showErrorAlert("Error!", "Cannot find stream");
      return;
    }
    statusLog.add("initialize permissions");
    var cameraStatus = await handlePermission(Permission.camera);
    var micStatus = await handlePermission(Permission.microphone);

    if (!cameraStatus.isGranted) {
      showErrorAlert("Error!", "Cannot continue without camera access");
      return;
    }
    if (!micStatus.isGranted) {
      showErrorAlert("Error!", "Cannot continue without microphone access");
      return;
    }
    statusLog.add("initialize agora");

    var firebaseLivestream = context.read<FirebaseLiveStreamProvider>();
    firebaseLivestream.initViewers(streamId: liveStream!.id, user_id: user!.id);
    initializeAgora();
  }

  Future<void> initializeAgora() async {
    statusLog.add("create engine");
    _engine = createAgoraRtcEngine();
    statusLog.add("init engine");
    await _engine!.initialize(const RtcEngineContext(
      appId: JVar.agoraAppId,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));
    statusLog.add("init engine listners");
    _engine!.registerEventHandler(
      RtcEngineEventHandler(
        onError: (code, type) {
          statusLog.add("error occured $code $type");
          final info = 'LOG::onError: $code --';
          debugPrint(info);
          showErrorAlert("Error!", "Error occurred while streaming $code");
        },
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) async {
          debugPrint("local user ${connection.localUid} joined");
          statusLog.add("local user ${connection.localUid} joined");

          if (isBroadcaster) {
            debugPrint("local user ${connection.localUid} joined");
            var liveStreamProvider = context.read<LiveStreamProvider>();
            var updatedStream = await liveStreamProvider.updateLiveStream(
                liveStream!.id, {
              "status": "Live",
              "token": myTkn ?? "",
              "uid": connection.localUid.toString()
            });
            if (updatedStream == null) {
              print("Update stream error occured");
              _engine!.leaveChannel();
              showErrorAlert("Error!",
                  "Internal Server Error while joining stream please try again later");
              return;
            }
            if (updatedStream.status != "Live") {
              _engine!.leaveChannel();
              showErrorAlert("Error!", "Error while going live....");
              return;
            }
            setState(() {
              _localUserJoined = true;
              liveStream = updatedStream;
            });
          } else {
            setState(() {
              _localUserJoined = true;
              _localUid = connection.localUid.toString();
            });
          }
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          statusLog.add(
              "remote user $remoteUid joined and uid is ${liveStream!.agoraUid}");
          setState(() {
            remoteUsers.add(remoteUid);
            if (liveStream!.agoraUid == remoteUid.toString()) {
              _remoteUid = remoteUid;
            }
          });
          debugPrint(
              "remote user $remoteUid joined and uid is ${liveStream!.agoraUid}");
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) async {
          statusLog.add("remote user $remoteUid left channel");
          debugPrint("remote user $remoteUid left channel");
          setState(() {
            remoteUsers.remove(remoteUid);
            if (liveStream!.agoraUid == remoteUid.toString()) {
              showAlertDialog(context, "Offline!", "Host left the stream",
                  type: AlertType.WARNING);
              _remoteUid = null;
            }
          });
          if (_engine != null) {
            await _engine!.leaveChannel();
            await _engine!.release();
          }
        },
        onLeaveChannel: (RtcConnection connection, RtcStats stats) {
          statusLog.add("On Leave Channel");
          logWarning("On Leave Channel");
        },
        onFirstRemoteAudioFrame: (RtcConnection connection, num1, num2) {
          logWarning("onFirstRemoteAudioFrame");
        },
        onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
          statusLog.add("onTokenPrivilegeWillExpire");

          debugPrint(
              '[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token');
          showErrorAlert(
              "Error!", "Your stream expired please try again later");
          return;
        },
      ),
    );
    setState(() {});
    var userProvider = context.read<ProfileProvider>();
    int uid = 0;
    var role = RtcRole.publisher;
    statusLog.add("enable clientRoleBroadcaster and clientRoleAudience");
    if (isBroadcaster) {
      await _engine!.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
      await _engine!.enableVideo();
      // await _engine!.enableCameraCenterStage(true);
    } else {
      await _engine!.setClientRole(role: ClientRoleType.clientRoleAudience);
      await _engine!.enableVideo();
      // await _engine!.setVideoEncoderConfiguration(VideoEncoderConfiguration(
      //     dimensions: VideoDimensions(
      //   width: 420,
      //   height: 530,
      // )));
      role = RtcRole.subscriber;
    }

    final expirationInSeconds = 3600;
    final currentTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final expireTimestamp = currentTimestamp + expirationInSeconds;
    statusLog.add("get token");
    var token = RtcTokenBuilder.build(
      appId: JVar.agoraAppId,
      appCertificate: JVar.agoraAppCertificate,
      channelName: liveStream!.channelName ?? generateRandomId(),
      uid: uid.toString(),
      role: role,
      expireTimestamp: expireTimestamp,
    );
    myTkn = token;
    // print("token");
    // print(token);
    // var token = "007eJxTYOiKeCz3Yi6vd1aRZpmuykZxjwyn+HLtre2B7xc2Pznv3qbAYGZpkGqWbGhqkmppYZJsYJJoYWBokWKUZmKRmGySmmbku35FWkMgI8PF37qsjAwQCOLzMGSV5iVmpuRk+lsmFzIwAADjzSGn";
    print(
        "channel user id" + convertNumber(userProvider.profile.id).toString());
    statusLog.add("join channel" + liveStream!.channelName!);
    await _engine!.joinChannel(
      token: token,
      channelId: liveStream!.channelName!,
      uid: 0,
      options: const ChannelMediaOptions(),
    );
    setState(() {});
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    _engine!.muteLocalAudioStream(muted);
  }

  void _onSwitchCamera() {
    _engine!.switchCamera();
  }

  void _onCallEnd(BuildContext context) async {
    if (_engine != null) await _engine!.leaveChannel();
    Navigator.pop(context);
  }

  Widget _videoView() {
    print("agora video view=>" + _remoteUid.toString());
    print("isBroadCaster ${isBroadcaster}");
    if (isBroadcaster) {
      return !_localUserJoined
          ? Center(child: Text("Joining..."))
          : FocusDetector(
              onFocusLost: () {
                if (liveStream != null) {
                  FirebaseLiveStreamProvider()
                      .setSteamStatus(liveStream!, "Offline");
                }
              },
              onFocusGained: () {
                if (liveStream != null) {
                  FirebaseLiveStreamProvider()
                      .setSteamStatus(liveStream!, "Live");
                }
              },
              child: AgoraVideoView(
                onAgoraVideoViewCreated: (val) {
                  print("Agora video view created");
                },
                controller: VideoViewController(
                    rtcEngine: _engine!, canvas: VideoCanvas(uid: 0)),
              ),
            );
    } else if (_remoteUid != null) {
      return !_localUserJoined && _localUid != null
          ? Center(child: Text("Joining..."))
          : FocusDetector(
              onFocusLost: () {
                if (liveStream != null) {
                  FirebaseLiveStreamProvider().removeViewer(
                      streamId: liveStream!.id, user_id: user!.id.toString());
                }
              },
              onFocusGained: () {
                if (liveStream != null) {
                  FirebaseLiveStreamProvider().insertViewer(
                      user_id: user!.id.toString(),
                      uid: _localUid,
                      status: "Online",
                      streamId: liveStream!.id);
                }
              },
              child: AgoraVideoView(
                controller: VideoViewController.remote(
                  rtcEngine: _engine!,
                  canvas: VideoCanvas(
                    uid: _remoteUid!,
                  ),
                  connection: RtcConnection(channelId: liveStream!.channelName),
                ),
              ),
            );
    } else {
      return const Center(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.hide_image),
          SizedBox(
            width: 10,
          ),
          Text('Offline'),
        ],
      ));
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getPageData();
    });
    _listener = AppLifecycleListener(
      onShow: () => log('=>show'),
      onResume: () {
        log('onResume');
        if (isBroadcaster)
          LiveStreamProvider()
              .updateLiveStream(liveStream!.id, {"status": "Live"});
      },
      onHide: () => log('=>hide'),
      onInactive: () {
        log('inactive');
        if (isBroadcaster)
          LiveStreamProvider()
              .updateLiveStream(liveStream!.id, {"status": "Offline"});
      },
      onPause: () => log('=>pause'),
      onDetach: () => log('=>detach'),
      onRestart: () => log('restart'),
    );
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() async {
    if (liveStream != null && isBroadcaster)
      LiveStreamProvider()
          .updateLiveStream(liveStream!.id, {"status": "Ended"});
    _listener.dispose();
    super.dispose();
    if (_engine != null) {
      await _engine!.leaveChannel();
      await _engine!.release();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        elevation: 0,
        title: Text("Live Stream"),
      ),
      body: Stack(
        children: [
          _engine == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(),
                      ),
                      // Container(
                      //   height: 400,
                      //   child: ListView(
                      //     children: [
                      //       ...statusLog.map((e) => Container(
                      //             padding: EdgeInsets.symmetric(
                      //                 horizontal: 10, vertical: 8),
                      //             decoration: BoxDecoration(
                      //               color: JColor.grey,
                      //               borderRadius: BorderRadius.circular(10),
                      //             ),
                      //             child: Text("$e"),
                      //           ))
                      //     ],
                      //   ),
                      // )
                    ],
                  ),
                )
              : isBroadcaster
                  ? Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Container(
                            width: getWidth(context),
                            height: getHeight(context),
                            child: _videoView()),
                        Container(
                          height: 160,
                          color: JColor.grey.withOpacity(.5),
                          alignment: Alignment.bottomCenter,
                          padding: const EdgeInsets.symmetric(vertical: 48),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              RawMaterialButton(
                                onPressed: _onToggleMute,
                                child: Icon(
                                  muted ? Icons.mic_off : Icons.mic,
                                  color:
                                      muted ? Colors.white : Colors.blueAccent,
                                  size: 20.0,
                                ),
                                shape: CircleBorder(),
                                elevation: 2.0,
                                fillColor:
                                    muted ? Colors.blueAccent : Colors.white,
                                padding: const EdgeInsets.all(12.0),
                              ),
                              RawMaterialButton(
                                onPressed: () => _onCallEnd(context),
                                child: Icon(
                                  Icons.call_end,
                                  color: Colors.white,
                                  size: 35.0,
                                ),
                                shape: CircleBorder(),
                                elevation: 2.0,
                                fillColor: Colors.redAccent,
                                padding: const EdgeInsets.all(15.0),
                              ),
                              RawMaterialButton(
                                onPressed: _onSwitchCamera,
                                child: Icon(
                                  Icons.switch_camera,
                                  color: Colors.blueAccent,
                                  size: 20.0,
                                ),
                                shape: CircleBorder(),
                                elevation: 2.0,
                                fillColor: Colors.white,
                                padding: const EdgeInsets.all(12.0),
                              ),
                              // RawMaterialButton(
                              //   onPressed: () {},
                              //   child: Icon(
                              //     Icons.message_rounded,
                              //     color: Colors.blueAccent,
                              //     size: 20.0,
                              //   ),
                              //   shape: CircleBorder(),
                              //   elevation: 2.0,
                              //   fillColor: Colors.white,
                              //   padding: const EdgeInsets.all(12.0),
                              // ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Stack(
                      children: [
                        Container(
                            width: getWidth(context),
                            height: getHeight(context),
                            color: JColor.lighterGrey,
                            child: _videoView()),
                        // Container(
                        //     alignment: Alignment.bottomCenter,
                        //     padding: EdgeInsets.only(bottom: 48),
                        //     child: RawMaterialButton(
                        //       onPressed: () {},
                        //       child: Icon(
                        //         Icons.message_rounded,
                        //         color: Colors.blueAccent,
                        //         size: 20.0,
                        //       ),
                        //       shape: CircleBorder(),
                        //       elevation: 2.0,
                        //       fillColor: Colors.white,
                        //       padding: const EdgeInsets.all(12.0),
                        //     ),
                        //   ),
                      ],
                    ),
          Consumer<FirebaseLiveStreamProvider>(builder: (key, provider, child) {
            return Align(
                alignment: Alignment.topCenter,
                child: Container(
                  height: 120,
                  padding: EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          JColor.black.withOpacity(.6),
                          JColor.black.withOpacity(.3),
                          Colors.transparent
                        ]
                      )
                    ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration:BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.red
                        ),
                        child: Text("Live",
                        style: TextStyle(
                          color: Colors.white
                        ),),
                      ),
                      SizedBox(width: 10,),
                      Icon(
                        Icons.remove_red_eye,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 4,
                      ),
                      Text(
                        "${provider.viewersCount}",
                        style: TextStyle(color: Colors.white,
                        fontSize: 17),
                      )
                    ],
                  ),
                ));
          }),
        ],
      ),
    );
  }
}
