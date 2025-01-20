import 'package:flutter/material.dart';
import 'package:lms/provider/authprovider.dart';
import 'package:lms/screens/admin/login/admin_login.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminAuthProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'GTEC LMS',
        theme: ThemeData(primarySwatch: Colors.blue),
        home:  AdminLoginScreen(),
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future.microtask(() {
      final authProvider = Provider.of<AdminAuthProvider>(context, listen: false);
      authProvider.AdmincheckAuthprovider(context);
    });

    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
