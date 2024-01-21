import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:translator/translator.dart';
import 'package:language_translator/components/language_selector.dart';
import 'package:language_translator/components/result_container.dart';
import 'package:language_translator/data/language.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GoogleTranslator _translator = GoogleTranslator();
  final SpeechToText _speechToText = SpeechToText();

  bool isShowingResult = false;
  String from = 'en';
  String to = 'ta';
  String inputText = '';
  String resultText = '';
  bool speechEnabled = false;
  String speechResults = '';

  void translateText(String input) async {
    if (input.isEmpty) {
      setState(() {
        inputText = '';
        resultText = '';
        speechEnabled = false;
        isShowingResult = false;
        speechResults = '';
      });

      return;
    }

    var result = await _translator.translate(
      input.trim(),
      to: to,
    );

    setState(() {
      inputText = result.source;
      resultText = result.text;
      speechEnabled = false;
      isShowingResult = true;
      speechResults = '';
    });
  }

  void onTextInput() {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(20.0),
            ),
          ),
          child: SizedBox(
            height: 230.0,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Text(
                      'Enter Text To Translate',
                      style: TextStyle(fontSize: 20.0),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: textController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'Type here...',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.multiline,
                      minLines: 2,
                      maxLines: 10,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('CANCEL'),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              translateText(textController.text);
                              Navigator.pop(context);
                            });
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void onVoiceInput() async {
    speechEnabled = await _speechToText.initialize();

    await _speechToText.listen(
      onResult: onSpeechResult,
      cancelOnError: true,
      localeId: from,
    );

    _speechToText.errorListener = (err) {
      translateText(speechResults);
    };

    setState(() {});
  }

  void stopListening() async {
    await _speechToText.stop();
    translateText(speechResults);
  }

  void onSpeechResult(SpeechRecognitionResult result) {
    if (_speechToText.isNotListening) {
      translateText(result.recognizedWords);
      return;
    }

    setState(() {
      speechResults = result.recognizedWords;
    });
  }

  void onImageInput() async {
    TextRecognitionScript? script = giveTextRecognitionScriptForLanguage(
      from,
    );

    if (script == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '"${languageList[from]}" is Not Supported in Text Recognition',
            ),
          ),
        );

        return;
      }
    }

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image == null) {
      return;
    }

    // To make the compiler understand it's not null
    if (script == null) {
      return;
    }

    try {
      final textRecognizer = TextRecognizer(script: script);

      final result = await textRecognizer.processImage(
        InputImage.fromFilePath(
          image.path,
        ),
      );

      if (result.text.isNotEmpty) {
        translateText(result.text);
      }

      await textRecognizer.close();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Something Went Wrong!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Translator",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.grey[100],
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LanguageSelector(
                from: from,
                to: to,
                onFromChange: (String? value) {
                  setState(() => from = value ?? 'en');
                  translateText(inputText);
                },
                onToChange: (String? value) {
                  setState(() => to = value ?? 'ta');
                  translateText(inputText);
                },
              ),
              Visibility(
                visible: speechResults.isNotEmpty,
                child: Column(
                  children: [
                    const SizedBox(height: 20.0),
                    Text(
                      "$speechResults...",
                      style: const TextStyle(
                        fontSize: 24.0,
                      ),
                    ),
                    const SizedBox(height: 5.0),
                  ],
                ),
              ),
              Visibility(
                visible: isShowingResult,
                child: ResultContainer(
                  inputText: inputText,
                  resultText: resultText,
                ),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isShowingResult
            ? ElevatedButton(
                onPressed: () {
                  setState(() {
                    isShowingResult = false;
                    inputText = '';
                    resultText = '';
                  });
                },
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(20.0),
                ),
                child: const Icon(
                  Icons.done,
                  size: 40.0,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Visibility(
                    visible: !speechEnabled,
                    child: ElevatedButton(
                      onPressed: onTextInput,
                      style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(12.0),
                          primary: Colors.white),
                      child: const Icon(
                        Icons.text_snippet_sharp,
                        size: 32.0,
                        color: Colors.deepOrange,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  ElevatedButton(
                    onPressed: speechEnabled ? stopListening : onVoiceInput,
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(20.0),
                    ),
                    child: Icon(
                      speechEnabled ? Icons.stop_circle_outlined : Icons.mic,
                      size: 40.0,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Visibility(
                    visible: !speechEnabled,
                    child: ElevatedButton(
                      onPressed: onImageInput,
                      style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(12.0),
                          primary: Colors.white),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 32.0,
                        color: Colors.deepOrange,
                      ),
                    ),
                  )
                ],
              ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
