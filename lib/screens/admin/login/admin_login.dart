import 'package:flutter/material.dart';
import 'package:lms/provider/authprovider.dart';
import 'package:lms/screens/admin/login/admin_register.dart';
import 'package:provider/provider.dart';

class AdminLoginScreen extends StatefulWidget {
  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 2, 64, 95),
              Colors.black,
              Color.fromARGB(255, 2, 64, 95)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              bool isLargeScreen = constraints.maxWidth > 800;
              double formWidth = isLargeScreen
                  ? constraints.maxWidth * 0.4
                  : constraints.maxWidth * 0.8;
              double imageWidth =
                  isLargeScreen ? constraints.maxWidth * 0.2 : 0;

              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left Section: Login Form
                  Container(
                    width: formWidth,
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Image.asset('assets/gtecwhite.png',
                                  height: 60, width: 60),
                              const SizedBox(width: 8),
                              Image.asset('assets/golwhite.png', height: 60),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Welcome Back!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Enter your details to login',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Email',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.9),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            style: const TextStyle(color: Colors.black),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter an email';
                              }
                              if (!RegExp(r'^[\w-]+@([\w-]+\.)+[\w]{2,4}$')
                                  .hasMatch(value)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Password',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.9),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            style: const TextStyle(color: Colors.black),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 26),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  // Pass context to the login method
                                  Provider.of<AdminAuthProvider>(context,
                                          listen: false)
                                      .adminloginprovider(
                                    _emailController.text,
                                    _passwordController.text,
                                    context, // Pass context here
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 39, 220, 244),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              child: const Text(
                                'Login',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AdminregisterScreen()),
                               );
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                            ),
                            child: const Text(
                              'Don’t have an account? Sign Up?',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                                          ForgotPasswordHandler.showEmailPopup(
                                              context);
                                        },
                            child: const Text(
                              'Forgot Password?',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (isLargeScreen)
                    Container(
                      width: imageWidth,
                      padding: const EdgeInsets.all(16),
                      child: Image.asset(
                        'assets/youcannot.png',
                        height: 600,
                        fit: BoxFit.contain,
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class ForgotPasswordHandler {
  static void showEmailPopup(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final provider = Provider.of<AdminAuthProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Forgot Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Enter your email',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
          actions: [
            provider.isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () {
                      provider
                          .sendResetEmail(emailController.text, context)
                          .then((_) {
                        Navigator.pop(context); // Close the email dialog
                        showOtpPopup(context, emailController.text);
                      });
                    },
                    child: Text('Send'),
                  ),
          ],
        );
      },
    );
  }

  static void showOtpPopup(BuildContext context, String email) {
    final TextEditingController otpController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final provider = Provider.of<AdminAuthProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Reset Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: otpController,
                decoration: InputDecoration(
                  labelText: 'Enter OTP from Email',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
          actions: [
            provider.isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () {
                      provider
                          .resetPassword(
                        email,
                        otpController.text,
                        passwordController.text,
                        context,
                      )
                          .then((_) {
                        Navigator.pop(context); // Close the OTP dialog
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Password reset successful!')),
                        );
                      });
                    },
                    child: Text('Reset Password'),
                  ),
          ],
        );
      },
    );
  }
}