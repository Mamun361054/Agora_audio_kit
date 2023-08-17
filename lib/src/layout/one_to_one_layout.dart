import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_uikit/agora_uikit.dart';
import 'package:agora_uikit/src/layout/widgets/disabled_audio_widget.dart';
import 'package:agora_uikit/src/layout/widgets/text_with_tap.dart';
import 'package:flutter/material.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class OneToOneLayout extends StatefulWidget {
  final AgoraClient client;

  /// Widget that will be displayed when the local or remote user has disabled it's video.
  final Widget? disabledAudioWidget;

  /// Display the camera and microphone status of a user. This feature is only available in the [Layout.floating]
  final bool? showAVState;

  /// Display the host controls. This feature is only available in the [Layout.floating]
  final bool? enableHostControl;

  /// Render mode for local and remote video
  final RenderModeType? renderModeType;

   OneToOneLayout({
    Key? key,
    required this.client,
    this.disabledAudioWidget = const DisabledAudioWidget(),
    this.showAVState,
    this.enableHostControl,
    this.renderModeType = RenderModeType.renderModeHidden,
  }) : super(key: key);

  @override
  State<OneToOneLayout> createState() => _OneToOneLayoutState();
}

class _OneToOneLayoutState extends State<OneToOneLayout> {

  final StopWatchTimer _stopWatchTimer = StopWatchTimer();
  String callDuration = "00:00";

  Offset position = Offset(5, 5);


  Widget _getRemoteViews(int uid) {

    _stopWatchTimer.onStartTimer();

    return AgoraVideoView(
          controller: VideoViewController.remote(
            rtcEngine: widget.client.sessionController.value.engine!,
            canvas: VideoCanvas(uid: uid, renderMode: widget.renderModeType),
            connection: RtcConnection(
              channelId:
              widget.client.sessionController.value.connectionData!.channelName,
            ),
          ),
        );
  }

  /// Video view wrapper
  Widget _videoView(view) {
    return Expanded(
      child: Container(
        child: view,
      ),
    );
  }

  Widget _oneToOneLayout() {
    return widget.client.users.isNotEmpty
        ? Expanded(
            child: Stack(
              children: [
                Container(
                  child: widget.client.sessionController.value.users[0]
                          .videoDisabled
                      ? widget.disabledAudioWidget
                      : Stack(
                          children: [
                            Container(
                              color: Colors.black,
                              padding: const EdgeInsets.all(16.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.all(Radius.circular(12.0)),
                                child: ColoredBox(
                                  color: Colors.grey.withOpacity(0.5),
                                  child: Center(
                                    child: Text(
                                      'You',
                                      style: TextStyle(color: Colors.white,fontSize: 24.0),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned.fill(
                              child: Column(
                                children: [
                                  _videoView(
                                    _getRemoteViews(widget.client.users[0]),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
                Positioned(
                  top: 55.0,
                  left: 0.0,
                  right: 0.0,
                  child: StreamBuilder<int>(
                    stream: _stopWatchTimer.secondTime,
                    initialData: 0,
                    builder: (context, snap) {
                      final value = snap.data;
                      callDuration = formatTime(value!);
                      return Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: TextWithTap(
                              formatTime(value),
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          )
        : Expanded(
            child: Container(
              child: widget.client.sessionController.value.isLocalVideoDisabled
                  ? widget.disabledAudioWidget
                  : Stack(
                      children: [
                        Container(
                          color: Colors.black,
                          padding: const EdgeInsets.all(16.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(12.0)),
                            child: ColoredBox(
                              color: Colors.grey.withOpacity(0.5),
                              child: Center(
                                child: Text(
                                  'You',
                                  style: TextStyle(color: Colors.white,fontSize: 24.0),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          );
  }

  @override
  void dispose() async {
    _stopWatchTimer.onStopTimer();
    await _stopWatchTimer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: widget.client.sessionController,
        builder: (context, counter, widgetx) {
          return Column(
            children: [
              _oneToOneLayout(),
            ],
          );
        });
  }
}


String formatTime(int second) {
var hour = (second / 3600).floor();
var minutes = ((second - hour * 3600) / 60).floor();
var seconds = (second - hour * 3600 - minutes * 60).floor();

var secondExtraZero = (seconds < 10) ? "0" : "";
var minuteExtraZero = (minutes < 10) ? "0" : "";
var hourExtraZero = (hour < 10) ? "0" : "";

if (hour > 0) {
return "$hourExtraZero$hour:$minuteExtraZero$minutes:$secondExtraZero$seconds";
} else {
return "$minuteExtraZero$minutes:$secondExtraZero$seconds";
}
}