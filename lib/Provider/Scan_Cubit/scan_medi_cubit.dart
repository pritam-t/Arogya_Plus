// scan_medi_cubit.dart
import 'dart:convert';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'scan_state.dart';

class ScanMediCubit extends Cubit<ScanState> {
  final ImagePicker _picker;

  ScanMediCubit({ImagePicker? picker})
      : _picker = picker ?? ImagePicker(),
        super(const ScanState());

  /// Pick image and trigger recognition
  Future<void> pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source, imageQuality: 80);
      if (pickedFile == null) return;

      final file = File(pickedFile.path);

      // Show loading with selected image
      emit(state.copyWith(
        status: ScanStatus.loading,
        imageFile: file,
        extractedText: '',
        error: null,
      ));

      await _processImage(file);
    } catch (e) {
      emit(state.copyWith(status: ScanStatus.failure, error: e.toString()));
    }
  }

  /// Process file with ML Kit text recognizer
  Future<void> _processImage(File file) async {
    TextRecognizer? textRecognizer;
    try {
      final inputImage = InputImage.fromFilePath(file.path);
      textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final recognizedText = await textRecognizer.processImage(inputImage);

      final cleaned = recognizedText.text;

      // Fetch drug info and generate AI summary
      await _fetchDrugInfo(cleaned, file, recognizedText.text);
      await _fetchDrugInfo(cleaned, file, recognizedText.text);
    } catch (e) {
      emit(state.copyWith(status: ScanStatus.failure, error: 'OCR Error: $e'));
    } finally {
      await textRecognizer?.close();
    }
  }

  /// Clean raw OCR text (basic filtering)

  /// Fetch drug info from OpenFDA and generate AI summary
  Future<void> _fetchDrugInfo(String cleanedText, File file, String rawExtracted) async {
    try {
      final drugName = cleanedText.split(" ").first;
      final formattedDrug = drugName[0].toUpperCase() + drugName.substring(1);
      final url =
          "https://api.fda.gov/drug/label.json?search=openfda.brand_name:$formattedDrug&limit=1";

      final response = await http.get(Uri.parse(url));

      String? fdaName, usage, dosage, warnings;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data["results"] != null && data["results"].isNotEmpty) {
          final drug = data["results"][0];
          fdaName = drug["openfda"]?["brand_name"]?[0] ?? drugName;
          usage = drug["indications_and_usage"]?[0] ?? "Not available";
          dosage = drug["dosage_and_administration"]?[0] ?? "Not available";
          warnings = drug["warnings"]?[0] ?? "Not available";
        }
      }

      // Emit intermediate state with OCR + drug info (loading summary)
      emit(state.copyWith(
        status: ScanStatus.loading,
        imageFile: file,
        extractedText: rawExtracted,
        drugName: fdaName ?? "Not found",
        drugUsage: usage,
        drugDosage: dosage,
        drugWarnings: warnings,
      ));

      // Generate AI summary
      final summary = await _rewriteWithGemini(
        drugName: fdaName ?? drugName,
        usage: usage ?? "Not available",
        dosage: dosage ?? "Not available",
        warnings: warnings ?? "Not available",
        userProfile: "Adult male, 25 years old", // replace with actual user profile
      );

      // Emit final success state with summary
      emit(state.copyWith(
        status: ScanStatus.success,
        aiSummary: summary,
      ));
    } catch (e) {
      emit(state.copyWith(status: ScanStatus.failure, error: 'API Error: $e'));
    }
  }

  /// AI rewrite using Gemini API
  Future<String> _rewriteWithGemini({
    required String drugName,
    required String usage,
    required String dosage,
    required String warnings,
    required String userProfile,
  }) async { 
    final apiKey = dotenv.env['API_KEY'] ?? "No API Key";;
    final url =
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey";

    final prompt = """
You are a health assistant.
Rewrite this medicine info in simple, user-friendly bullet points.
Always add a disclaimer that this is not medical advice.

Drug: $drugName
Usage: $usage
Dosage: $dosage
Warnings: $warnings
User Profile: $userProfile
""";

    final body = {
      "contents": [
        {
          "parts": [
            {"text": prompt}
          ]
        }
      ]
    };

    final resp = await http.post(Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body));

    if (resp.statusCode == 200) {
      final data = json.decode(resp.body);
      return data["candidates"][0]["content"]["parts"][0]["text"] ??
          "No summary available";
    } else {
      return "Could not generate summary.";
    }
  }

  /// Clear state
  void clear() => emit(const ScanState());
}
