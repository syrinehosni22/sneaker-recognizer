import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../../domain/models/sneaker.dart';
import '../../widgets/sneaker_card.dart';
import 'home_controller.dart';
import '../search/search_screen.dart';
import '../favorites/favorites_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Navigation index
  int _currentIndex = 0;

  // For image recognition
  File? _image;
  Sneaker? _sneaker;
  bool _loading = false;

  final picker = ImagePicker();
  final HomeController controller = HomeController();

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    setState(() {
      _image = File(pickedFile.path);
      _sneaker = null;
      _loading = true;
    });

    final sneaker = await controller.recognize(_image!);

    setState(() {
      _sneaker = sneaker;
      _loading = false;
    });
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  // Navigation screens list
  List<Widget> get _screens => [
    _buildSneakerRecognitionScreen(),
    const SearchScreen(),
    FavoritesScreen(),
    const ProfileScreen(),
  ];

  /// HOME TAB UI (your original screen)
  Widget _buildSneakerRecognitionScreen() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _image != null
              ? Image.file(_image!, height: 200)
              : Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: const Center(child: Text("No Image")),
                ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: pickImage,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.button),
            child: const Text(AppStrings.pickImage),
          ),
          const SizedBox(height: 20),
          if (_loading) const CircularProgressIndicator(),
          if (_sneaker != null)
            SneakerCard(
              name: _sneaker!.name,
              links: _sneaker!.links,
              onLinkTap: _launchURL,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sneaker Recognizer"),
        backgroundColor: AppColors.primary,
      ),

      body: _screens[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: "Favorites",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
