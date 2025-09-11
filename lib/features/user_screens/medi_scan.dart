import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mediscan_plus/main.dart';

class ScanMedi_Screen extends StatefulWidget {
  const ScanMedi_Screen({super.key});

  @override
  State<ScanMedi_Screen> createState() => _ScanMedi_ScreenState();
}

class _ScanMedi_ScreenState extends State<ScanMedi_Screen> {
  File? _imageFile;
  String _extractedText = '';
  bool _isLoading = false;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _extractedText = '';
      });
      await _processImage();
    }
  }

  Future<void> _processImage() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final inputImage = InputImage.fromFilePath(_imageFile!.path);
      final textRecognizer =
      TextRecognizer(script: TextRecognitionScript.latin);

      final RecognizedText recognizedText =
      await textRecognizer.processImage(inputImage);
      await textRecognizer.close();

      setState(() {
        _extractedText = recognizedText.text;
      });
    } catch (e) {
      setState(() {
        _extractedText = "Error recognizing text: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _clearScreen() {
    setState(() {
      _imageFile = null;
      _extractedText = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(padding: const EdgeInsets.all(8.0),
          child: Image.asset('assets/images/surface_logo.png',fit: BoxFit.contain,height: 32),
        ),

        title: const Text("Scan Medicine", style: TextStyle(fontSize: 22)),
        centerTitle: true,
      ),

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _imageFile == null
                  ? Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppTheme.textPrimary,
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/images/scan_medi.png',
                    fit: BoxFit.cover,
                  ),
                ),
              )
                  : AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 250,
                child: Image.file(_imageFile!),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () => _showPickOptionsDialog(context),
                child: const Text("FLASH-SCAN"),
              ),
              
              const SizedBox(height: 20),

              _isLoading
                  ? Center(child: const CircularProgressIndicator())
                  : _extractedText.isNotEmpty
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Extracted Text:",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _extractedText,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _clearScreen,
                    icon: const Icon(Icons.clear),
                    label: const Text("Clear ×"),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent),
                  ),
                ],
              )
                  : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _optionButtons(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {
            Navigator.of(context).pop();
            _pickImage(ImageSource.gallery);
          },
          icon: const Icon(Icons.photo_library),
          label: const Text(
            "Pick from Gallery",
            style: TextStyle(fontSize: 16),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {
            Navigator.of(context).pop();
            _pickImage(ImageSource.camera);
          },
          icon: const Icon(Icons.camera_alt),
          label: const Text(
            "Use Camera",
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  void _showPickOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Select Image Source", style: TextStyle(fontWeight: FontWeight.bold)),
        content: _optionButtons(context),
      ),
    );
  }

}
