import 'package:flutter/material.dart';

/// Widget that is displayed when local/remote Audio is disabled.
class DisabledAudioWidget extends StatefulWidget {
  const DisabledAudioWidget({Key? key}) : super(key: key);

  @override
  State<DisabledAudioWidget> createState() => _DisabledAudioWidgetState();
}

class _DisabledAudioWidgetState extends State<DisabledAudioWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(8.0),
      child: Center(
          child: Icon(
        Icons.person_rounded,
        color: Colors.white,
      )),
    );
  }
}
