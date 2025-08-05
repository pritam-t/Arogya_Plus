import 'package:flutter/material.dart';

class UserProfileProvider extends ChangeNotifier
{

  final List<Map<String, dynamic>> _medications = [ ];

  //events
void addData(Map<String,dynamic> data)
{
  _medications.add(data);
  notifyListeners();
}

List<Map<String,dynamic>> getdata()
{
  return _medications;
}

void deleteData(int indx)
{
  _medications.removeAt(indx);
  notifyListeners();
}
}