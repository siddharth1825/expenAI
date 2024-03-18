import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import "package:dio/dio.dart";
import 'package:path_provider/path_provider.dart'; // For accessing the file system
import 'package:flutter_image_compress/flutter_image_compress.dart';
import './bill.dart';
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:firebase_database/firebase_database.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Inside DashboardScreen class
  void _openCamera(BuildContext context) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.rear,
      imageQuality: 85, // Adjust the quality for size
    );

    if (photo != null) {
      // Get the temporary directory
      final Directory tempDir = await getTemporaryDirectory();
      final String tempPath = '${tempDir.path}/file.jpg';

      // Convert to jpeg using the image_picker's imageQuality parameter
      // and save to a temporary file
      final File imageFile = File(photo.path);
      final File newImage = await imageFile.copy(tempPath);

      print('File path: ${imageFile.path}');
      print('File size: ${await imageFile.length()}');
      print('File extension: ${imageFile.path.split('.').last}');

      // Create form data
      final FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'file.jpg',
          contentType:
              MediaType('image', 'jpeg'), // Set the correct content type
        ),
      });

      formData.files.forEach((multipartFile) {
        print('File field: ${multipartFile.key}');
        print('File value: ${multipartFile.value.filename}');
        print('File content-type: ${multipartFile.value.contentType}');
      });

      // Use dio to send the request
      final Dio dio = Dio();
      try {
        final response = await dio.post(
          'https://fast-api-8gmn.onrender.com/uploadphoto/',
          data: formData,
        );

        if (response.statusCode == 200) {
          // Success response handling
          final responseData = response.data;
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => BillScreen(data: responseData)),
          );
        } else {
          // Error response handling
          print('Failed to upload photo: ${response.statusCode}');
        }
      } on DioError catch (e) {
        // Dio error handling
        print('DioError: $e');
      }
    }
  }

  final TextEditingController _balanceController = TextEditingController();
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  bool _isEditing = false;
  
  String _balance = '0'; // Placeholder for balance

  @override
  void initState() {
    super.initState();
    _fetchBalance();

    // TODO: Fetch the balance from Firebase on init and set it to _balance
  }

  void _fetchBalance() {
    _databaseRef.child('balance').get().then((snapshot) {
      if (snapshot.exists) {
        setState(() {
          _balance = snapshot.value.toString();
        });
      } else {
        _databaseRef.child('balance').set('0'); // Create balance node with 0 if it doesn't exist
      }
    });
  }

  void _updateBalance() async {
    int currentBalance = int.tryParse(_balance) ?? 0;
    // Save the new balance to Firebase
    await _databaseRef.child('balance').set(_balanceController.text);
    // Update the UI
    setState(() {
      _balance = _balanceController.text;
      _isEditing = false;
    });
  }

  void _manuallyUpdateBalance() async {
    await _databaseRef.child('balance').set(_balanceController.text);
    setState(() {
      _balance = _balanceController.text;
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    _balanceController.text = _balance; // Set the current balance as the controller's text
    // Calculate the width of the screen minus padding and divided by the number of columns
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonWidth =
        (screenWidth - 48) / 2; // Assuming padding of 16 on all sides

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor:
          Color(0xFFC7B6A1), // Replace with your actual background color
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Icon(Icons.menu,
            color: Colors.white), // Replace with an actual icon if necessary
      ),
      body: Stack(
        children: [
          Positioned.fill(
            top: -500,
            left: -200,
            child: Image.asset(
              'assets/Ellipse_6.png',
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
                16.0, 60.0, 16.0, 16.0), // Added extra padding at the top
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 32),
                // Top balance text
                Text(
                  'Your Balance',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF292015),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: _isEditing
                          ? TextField(
                              controller: _balanceController,
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF292015),
                              ),
                            )
                          : Text(
                              _balance,
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF292015),
                              ),
                            ),
                    ),
                    IconButton(
                      icon: Icon(_isEditing ? Icons.check : Icons.edit),
                      onPressed: () {
                        if (_isEditing) {
                          _manuallyUpdateBalance();
                        } else {
                          setState(() {
                            _isEditing = true;
                          });
                        }
                      },
                    ),
                  ],
                ),
                // Grid of buttons
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: <Widget>[
                      // Scan button (2x height)
                      _buildGridItem(
                        child: _buildDashboardButton(
                            context, 'Scan', Icons.qr_code_scanner,
                            color: Color(0xFFF0E7D5),
                            textColor: Color(0xFF92806A),
                            onPressed: () => _openCamera(context)),
                        heightFactor: 2,
                      ),
                      // Analytics button
                      _buildGridItem(
                        child: _buildDashboardButton(
                            context, 'Voice', Icons.voice_chat,
                            color: Color(0xFFDCD4C5),
                            textColor: Color(0xFF92806A),
                            onPressed: () {
                              print("pressed");
                            },
                            ),
                        heightFactor: 1,
                      ),
                      // Placeholder for spacing
                      SizedBox.shrink(),
                      // Bills button
                      _buildGridItem(
                        child: _buildDashboardButton(
                            context, 'Bills', Icons.receipt_long,
                            color: Color(0xFF92806A),
                            textColor: Color(0xFFF0E7D5),
                            onPressed: () {
                              print("pressed");
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => BillScreen()), // Make sure the constructor matches your BillScreen
                              );
                            },),
                            
                        heightFactor: 0.9,
                      ),
                      // Categories button (2x width)
                      _buildGridItem(
                        child: _buildDashboardButton(
                            context, 'Categories', Icons.dashboard_customize,
                            color: Color(0xFF292015),
                            textColor: Color(0xFFF0E7D5),
                            onPressed: () {
                              print("bruh");
                            }),
                        widthFactor: 2.1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // A helper method to build grid items with a specific size factor
  Widget _buildGridItem(
      {required Widget child,
      double widthFactor = 1,
      double heightFactor = 1,
      VoidCallback? onPressed}) {
    return FractionallySizedBox(
      alignment: Alignment.topLeft,
      widthFactor: widthFactor.toDouble(),
      heightFactor: heightFactor.toDouble(),
      child: child,
    );
  }

  Widget _buildDashboardButton(
      BuildContext context, String title, IconData icon,
      {Color color = Colors.white,
      textColor = Colors.black,
      VoidCallback? onPressed}) {
    return ElevatedButton.icon(
      icon: Icon(icon, color: textColor),
      label: Text(title, style: TextStyle(color: textColor)),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color, // Background color
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
