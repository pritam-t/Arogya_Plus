import 'dart:convert';

import 'package:flutter/animation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:mediscan_plus/Provider/Cubit/search_state.dart';

class SearchCubit extends Cubit<SearchState>{

  static List<Map<String,dynamic>> chatList = [];

  SearchCubit() : super(SearchInitalState());

  //Event
void getSearchResponse({required String query}) async
{
emit(SearchLoadingState());

chatList.add({
  "role": "user",
  "parts": [
    {
      "text": query
    }
  ]
});

String Key = "AIzaSyA8LN4kAciLh1ktEa774o-VJ8DW6FCpp3w";
String url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$Key";
// Map<String,dynamic> bodyParams = {
//   "contents": [
//     {
//       "parts": [
//         {
//           "text": query
//         }
//       ]
//     }
//   ]
// };

  Map<String,dynamic> bodyParams = {
    "contents": chatList,
    
  };

var response = await http.post(Uri.parse(url),
    body: jsonEncode(bodyParams));

if(response.statusCode == 200)
{
  var data = json.decode(response.body.toString());
  var res= data["candidates"][0]["content"]["parts"][0]["text"];
  chatList.add({
    "role": "model",
    "parts": [
      {
        "text": res
      }
    ]
  });
  emit(SearchLoadedState(res: res));
}
else
{
 var error = "Error: ${response.statusCode}";
 emit(SearchErrorState(errorMsg: error));
}
}

}