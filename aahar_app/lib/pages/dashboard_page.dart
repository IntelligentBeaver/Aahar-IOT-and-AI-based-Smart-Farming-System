import 'dart:io';
import 'package:aahar_app/components/dashboard_content.dart';
import 'package:aahar_app/components/response_page.dart';
import 'package:aahar_app/components/secrets.dart';
import 'package:aahar_app/pages/control.dart';
import 'package:aahar_app/pages/farm.dart';
import 'package:aahar_app/pages/forecasting.dart';
import 'package:aahar_app/pages/login_page.dart';
import 'package:aahar_app/pages/news.dart';
import 'package:aahar_app/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final ScrollController _scrollingController = ScrollController();
  int _selectedIndex = 2; // Set default index to 1 (second tab - Dashboard)
  String _appBarTitle = 'Dashboard'; // Default title for the SliverAppBar

  File? _image;
  final _picker = ImagePicker();

  pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      setState(() {
        uploadImage();
      });
    }
  }

  // Function to upload the image to the server
  Future<void> uploadImage() async {
    final prefs = await SharedPreferences.getInstance();
    final String accessToken = prefs.getString("accessToken") ?? '';
    if (_image == null) {
      print("No image selected");
      return print("No Image Selected");
    }
    final _imageUrl = imageUrl;

    // Navigate to ResponsePage with the responseFuture
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResponsePage(
          responseFuture: _uploadImageToServer(_image!, _imageUrl, accessToken),
        ),
      ),
    );
  }

  Future<String> _uploadImageToServer(
      File image, String url, String accessToken) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(url),
      );

      request.files.add(await http.MultipartFile.fromPath(
        'image',
        image.path,
      ));
      request.headers['Authorization'] = 'Bearer $accessToken';

      var response = await request.send();

      if (response.statusCode == 200) {
        // Return the response body
        return await response.stream.bytesToString();
      } else {
        // Handle error and return status code with message
        return "Failed to upload image. Status Code: ${response.statusCode}";
      }
    } catch (e) {
      return "Error uploading image: $e";
    }
  }

  final List<Widget> _pages = [
    Farm(),
    Forecasting(),
    DashboardContent(),
    Control(),
    News(),
  ];

  final List<String> _titles = [
    'Farm',
    'Forecasting',
    'Dashboard',
    'Control',
    'News',
  ];

  @override
  void initState() {
    super.initState();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _appBarTitle =
          _titles[index]; // Update the selected index when a tab is clicked
    });
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Logout'),
          content: Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: signOut,
              child: Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all saved data
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (route) => false,
    );
  }

  void _changeTheme(BuildContext context) {
    Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.camera_alt_rounded),
          onPressed: () {
            pickImage();
          },
        ),
        body: CustomScrollView(
          physics: BouncingScrollPhysics(
              decelerationRate: ScrollDecelerationRate.fast),
          controller: _scrollingController,
          slivers: [
            SliverAppBar(
              expandedHeight: 150.0,
              floating: true,
              centerTitle: true,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text(
                  _appBarTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800 // Ensure readable text
                      ),
                ),
                background: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () => _changeTheme(context),
                  icon: Icon(
                    Provider.of<ThemeProvider>(context).currentIcon,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _showLogoutDialog(
                        context); // Show logout confirmation dialog
                  },
                  icon: Icon(
                    Icons.login_rounded,
                  ),
                ),
              ],
            ),
            SliverFillRemaining(
              hasScrollBody: true,
              child: _pages[_selectedIndex], // Display the selected screen
            ),
          ],
        ),
        bottomNavigationBar: GNav(
          duration: Duration(milliseconds: 300),
          haptic: true,
          backgroundColor: Theme.of(context).colorScheme.surface,
          color: Theme.of(context).colorScheme.onSecondaryContainer,
          tabMargin: EdgeInsets.symmetric(horizontal: 10, vertical: 18),
          tabActiveBorder: Border.all(
              width: 1, color: Theme.of(context).colorScheme.primary),

          activeColor: Theme.of(context)
              .colorScheme
              .primary, // Red color for active icon
          iconSize: 24,
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          gap: 8,
          onTabChange: _onItemTapped,
          selectedIndex: _selectedIndex,
          tabs: const [
            GButton(
              icon: Icons.grass,
              text: 'Farm',
            ),
            GButton(
              icon: Icons.cloud,
              text: 'Forecasting',
            ),
            GButton(
              icon: Icons.dashboard,
              text: 'Dashboard',
            ),
            GButton(
              icon: Icons.settings_input_component,
              text: 'Control',
            ),
            GButton(
              icon: Icons.newspaper,
              text: 'News',
            ),
          ],
        ));
  }
}
