import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ResultContainer extends StatefulWidget {
  final String inputText;
  final String resultText;

  const ResultContainer({
    Key? key,
    required this.inputText,
    required this.resultText,
  }) : super(key: key);

  @override
  State<ResultContainer> createState() => _ResultContainerState();
}

class _ResultContainerState extends State<ResultContainer> {
  final FlutterTts flutterTts = FlutterTts();
  bool voicePlaying = false;

  void copyToClipboard() {
    Clipboard.setData(
      ClipboardData(text: widget.resultText),
    );

    const snackBar = SnackBar(
      content: Text('Text Copied!'),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> share() async {
    await FlutterShare.share(
      title: 'Share Translation',
      text: widget.resultText,
    );
  }

  void speakText() async {
    await flutterTts.speak(widget.resultText);
    setState(() => voicePlaying = true);
  }

  void stopSpeakText() async {
    await flutterTts.stop();
    setState(() => voicePlaying = false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.inputText,
            style: const TextStyle(
              fontSize: 24.0,
            ),
          ),
          const SizedBox(height: 4.0),
          const Divider(),
          const SizedBox(height: 4.0),
          Text(
            widget.resultText,
            style: TextStyle(
              fontSize: 24.0,
              color: Colors.indigoAccent[700],
            ),
          ),
          const SizedBox(height: 15.0),
          Row(
            children: [
              IconButton(
                onPressed: copyToClipboard,
                icon: const Icon(Icons.copy),
                tooltip: 'Copy Text',
              ),
              IconButton(
                onPressed: share,
                icon: const Icon(Icons.share),
                tooltip: 'Share Text',
              ),
              IconButton(
                onPressed: speakText,
                icon: const Icon(Icons.volume_up),
                tooltip: 'Speak Text',
              ),
            ],
          ),
          const SizedBox(height: 100.0),
        ],
      ),
    );
  }

  @override
  void dispose() async {
    super.dispose();
    stopSpeakText();
  }
}
