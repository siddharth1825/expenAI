import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dashboard.dart'; // Make sure you have this file created for navigation.

class GoogleSignInScreen extends StatefulWidget {
  const GoogleSignInScreen({Key? key}) : super(key: key);

  @override
  State<GoogleSignInScreen> createState() => _GoogleSignInScreenState();
}

class _GoogleSignInScreenState extends State<GoogleSignInScreen> {
  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      }
    } catch (e) {
      print('Sign in with Google failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFC7B6A1), // Set the background color to black
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              right: 0,
              top: 175,
              child: Image.asset('assets/Ellipse_3.png'), // Adjust the asset path as needed
            ),
            Positioned(
            left: MediaQuery.of(context).size.width * -0.2, // Adjust to position Ellipse 4
            bottom: MediaQuery.of(context).size.height * 0.3, // Adjust to position Ellipse 4
            child: Image.asset('assets/Ellipse_4.png'), // Adjust the asset path as needed
          ),
          // This Positioned widget will lay out Ellipse 5 to overlap with Ellipse 4
          Positioned(
            left: MediaQuery.of(context).size.width * -0.2, // Adjust to position Ellipse 5 for overlap
            bottom: MediaQuery.of(context).size.height * 0.32, // Adjust to position Ellipse 5 for overlap
            child: Image.asset('assets/Ellipse_5.png'), // Adjust the asset path as needed
          ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.15), // Adjust the height as needed to move closer to the middle
                    Text(
                      'expenAI',
                      style: TextStyle(
                        color: Color(0xFF292015), // The color you provided
                        fontSize: 48, // Adjust the font size as needed
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 30), // Adjust the space between the text and the button
                    ElevatedButton.icon(
                      icon: Icon(Icons.login), // Replace with your Google logo
                      label: Text('Sign in with Google'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFF0E7D5),
                        minimumSize: Size(double.infinity, 50), // Set the button size
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30), // Rounded corners
                        ),
                      ),
                      onPressed: signInWithGoogle,
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.25), // Adjust the height as needed to move closer to the middle
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
