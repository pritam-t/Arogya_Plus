import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:mediscan_plus/Provider/Assistant_Cubit/search_state.dart';

import '../../data/Private.dart';

class SearchCubit extends Cubit<SearchState>{

  static List<Map<String,dynamic>> chatList = [];

  SearchCubit() : super(SearchInitalState());

  //Event
  Future<void> getSearchResponse({required String query}) async {
    emit(SearchLoadingState());

    // Add user query to chat list
    chatList.add({
      "role": "user",
      "parts": [
        {"text": query}
      ]
    });

    String apiKey = Keys.gemini;
    String geminiUrl =
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey";

    String finalPrompt = query; // default prompt = user query

    // ---------------------------
    // Step 1: Detect query type
    // ---------------------------
    bool isMedicineQuery = false;
    bool isSymptomQuery = false;

    // Basic medicine detection
    List<String> medicineKeywords = [
      "tablet",
      "tab",
      "capsule",
      "syrup",
      "medicine",
      "mg",
      "drug",
      "injection"
    ];

    for (String word in medicineKeywords) {
      if (query.toLowerCase().contains(word)) {
        isMedicineQuery = true;
        break;
      }
    }

    // If it's just a single word (likely a medicine name)
    if (query.trim().split(" ").length == 1) {
      isMedicineQuery = true;
    }

    // Basic symptom detection (very simple for now)
    List<String> symptomKeywords = [
      "pain",
      "ache",
      "fever",
      "cough",
      "cold",
      "rash",
      "blur",
      "dizzy",
      "headache",
      "sore",
      "infection"
    ];

    for (String word in symptomKeywords) {
      if (query.toLowerCase().contains(word)) {
        isSymptomQuery = true;
        break;
      }
    }

    // ---------------------------
    // Step 2: Medicine Query → OpenFDA
    // ---------------------------
    if (isMedicineQuery) {
      String openFdaUrl =
          "https://api.fda.gov/drug/label.json?search=openfda.brand_name:$query&limit=1";

      try {
        var fdaResponse = await http.get(Uri.parse(openFdaUrl));

        if (fdaResponse.statusCode == 200) {
          var fdaData = json.decode(fdaResponse.body);

          if (fdaData["results"] != null && fdaData["results"].isNotEmpty) {
            var drug = fdaData["results"][0];

            // Build structured drug info
            String drugInfo = """
Name: ${drug["openfda"]?["brand_name"]?[0] ?? "Unknown"}
Generic: ${drug["openfda"]?["generic_name"]?[0] ?? "Unknown"}
Usage: ${drug["indications_and_usage"]?[0] ?? "Not available"}
Dosage: ${drug["dosage_and_administration"]?[0] ?? "Not available"}
Warnings: ${drug["warnings"]?[0] ?? "Not available"}
""";

            // Update prompt for Gemini
            finalPrompt =
            "Explain this drug information in simple, supportive language for the user:\n$drugInfo";
          }
        }
      } catch (e) {
        print("OpenFDA Error: $e");
      }
    }

    // ---------------------------
    // Step 3: Symptom Query → Placeholder for Infermedica
    // ---------------------------
    else if (isSymptomQuery) {
      // TODO: Replace this with Infermedica API or your own symptom model
      // For now, let Gemini handle the symptom query directly

      finalPrompt =
      "The user is describing a possible health symptom. Provide possible explanations, simple lifestyle tips, and when they should see a doctor. Be supportive, avoid scary wording. Always add disclaimer.\n\nUser query: $query";
    }

    // ---------------------------
    // Step 4: General Query → Gemini only
    // ---------------------------
    else {
      finalPrompt =
      "General health query from user. Explain clearly, short paragraphs or bullet points. Always add disclaimer.\n\nUser query: $query";
    }

    // ---------------------------
    // Step 5: Send request to Gemini
    // ---------------------------
    Map<String, dynamic> bodyParams = {
      "contents": [
        {
          "role": "user",
          "parts": [
            {"text": finalPrompt}
          ]
        }
      ]
    };

    var response = await http.post(Uri.parse(geminiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(bodyParams));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var res = data["candidates"][0]["content"]["parts"][0]["text"];

      chatList.add({
        "role": "model",
        "parts": [
          {"text": res}
        ]
      });

      emit(SearchLoadedState(res: res));
    } else {
      emit(SearchErrorState(errorMsg: "Error: ${response.statusCode}"));
    }
  }




}