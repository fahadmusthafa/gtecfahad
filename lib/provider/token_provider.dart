// import 'package:flutter/material.dart';
// import 'package:gtec/contants/gtec_token.dart';

// class TokenProvider with ChangeNotifier {
//   String? _token;
//   String? get token => _token;

//   // Initialize token
//   Future<void> initializeToken() async {
//     _token = await getToken();
//     notifyListeners();
//   }

//   // Set token
//   Future<void> setToken(String token) async {
//     _token = token;
//     await saveToken(token);
//     notifyListeners();
//   }

//   // Clear token
//   Future<void> clearToken() async {
//     await clearToken();
//     _token = null;
//     notifyListeners();
//   }
// }