import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String word = "";
  FlutterTts _flutterTts;
  final picker = ImagePicker();

  initState() {
    super.initState();
    initializeTts();
  }

  initializeTts() async {
    _flutterTts = FlutterTts();
    bool isPlaying = false;
    if (Platform.isAndroid) {
      _getEngines();
    }
    _flutterTts.setLanguage("en-US");

    _flutterTts.setStartHandler(() {
      setState(() {
        isPlaying = true;
      });
    });

    _flutterTts.setCompletionHandler(() {
      setState(() {
        isPlaying = false;
      });
    });

    _flutterTts.setErrorHandler((err) {
      setState(() {
        print("error occurred: " + err);
        isPlaying = false;
      });
    });
  }

  Future _getEngines() async {
    var engines = await _flutterTts.getEngines;
    if (engines != null) {
      for (dynamic engine in engines) {
        print(engine);
      }
    }
  }

  Future _speak() async {
    await _flutterTts.setVolume(.5);
    await _flutterTts.setSpeechRate(1);
    await _flutterTts.setPitch(1.0);

    if (word != null) {
      if (word.isNotEmpty) {
        await _flutterTts.awaitSpeakCompletion(true);
        await _flutterTts.speak(word);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        floatingActionButton: Builder(
          builder: (context) => FloatingActionButton(
            child: Icon(
              Icons.photo,
              size: 30,
              color: Colors.white,
            ),
            onPressed: () async {
              PickedFile image;
              await showModalBottomSheet(
                context: context,
                builder: (context) {
                  return SizedBox(
                    height: 150,
                    child: Column(
                      children: [
                        RaisedButton(
                          onPressed: () async {
                            image = await picker.getImage(
                                source: ImageSource.gallery);
                            Navigator.pop(context);
                          },
                          child: Text("Gallery"),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: BorderSide(color: Colors.red)),
                        ),
                        RaisedButton(
                          onPressed: () async {
                            image = await picker.getImage(
                                source: ImageSource.camera);
                            Navigator.pop(context);

                          },
                          child: Text("Camera"),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: BorderSide(color: Colors.red)),
                        )
                      ],
                    ),
                  );
                },
                isScrollControlled: false
              );
              print(image.path);
              FormData formData = FormData();
              formData.files.addAll([
                MapEntry(
                  "url",
                  MultipartFile.fromFileSync(image.path, filename: "img.jpg"),
                ),
              ]);

              Dio dio = Dio();
              final response =
                  await dio.post("http://192.168.1.5:5000/", data: formData);
              setState(() {
                word = response.data['word'];
                print(word);
                _speak();
              });
            },
          ),
        ),
        body: SafeArea(
            child: TypewriterAnimatedTextKit(
          speed: Duration(milliseconds: 50),
          totalRepeatCount: -1,
          text: [word],
          textStyle: TextStyle(
              color: Colors.black87,
              fontSize: 32.0,
              fontWeight: FontWeight.bold),
          displayFullTextOnTap: true,
        )),
      ),
    );
  }
}
