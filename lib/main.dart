import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  XFile? imageFile;
  String recognizedText = 'No text recognized';

  Future<void> pickImageFromGallery() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        imageFile = pickedFile;
      });
      performTextRecognition(pickedFile);
    }
  }

  Future<void> pickImageFromCamera() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );
    if (pickedFile != null) {
      setState(() {
        imageFile = pickedFile;
      });
      performTextRecognition(pickedFile);
    }
  }

  // Function to perform text recognition
  Future<void> performTextRecognition(XFile file) async {
    final inputImage = InputImage.fromFilePath(file.path);
    final textRecognizer = TextRecognizer(
      script: TextRecognitionScript.latin,
    );
    try {
      final RecognizedText recognized =
          await textRecognizer.processImage(inputImage);
      setState(() {
        recognizedText = recognized.text.isNotEmpty
            ? recognized.text
            : 'No text found in the image.';
      });
    } catch (e) {
      setState(() {
        recognizedText = 'Error occurred while recognizing text: $e';
      });
    } finally {
      textRecognizer.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Text Recognition App',
      home: Builder(
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: const Text('Text Recognition App'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: recognizedText));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Text copied to clipboard!'),
                        duration: Durations.short4,
                      ),
                    );
                  },
                  tooltip: 'Copy Text',
                ),
              ],
            ),
            body: Center(
              child: Column(
                children: [
                  imageFile == null
                      ? const Text('No image selected')
                      : Image.file(
                          File(imageFile!.path),
                          width: 300,
                          height: 300,
                        ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(2.0),
                      child: SelectableText(
                        recognizedText,
                        textAlign: TextAlign.start,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            bottomSheet: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: pickImageFromGallery,
                      icon: const Icon(Icons.photo),
                      label: const Text('Gallery'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: pickImageFromCamera,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Camera'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
