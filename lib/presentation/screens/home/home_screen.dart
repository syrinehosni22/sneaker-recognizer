import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// --- EXISTING IMPORTS ---
import 'package:sneaker_recognizer_plateform/presentation/screens/searchResult/search_result.dart';
import 'package:sneaker_recognizer_plateform/presentation/widgets/SneakerScan/SneakerScanButton.dart';
import 'package:sneaker_recognizer_plateform/presentation/widgets/cards/popular_sneaker_card.dart';
import 'package:sneaker_recognizer_plateform/services/sneaker_api_service.dart';

// --- NEW IMPORTS ---
import 'package:sneaker_recognizer_plateform/presentation/widgets/cards/offer_carousel.dart';
import 'package:sneaker_recognizer_plateform/presentation/screens/offer/add_offer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  XFile? _image;
  bool _loading = false;
  final picker = ImagePicker();

  Future<void> pickImage() async {
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (pickedFile == null) return;
    setState(() {
      _image = pickedFile;
      _loading = true;
    });
    await sendImageAndNavigate(pickedFile);
  }

  Future<void> sendImageAndNavigate(XFile image) async {
    try {
      setState(() => _loading = true);
      final data = await SneakerApiService.getProductData(image);
      setState(() => _loading = false);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => SneakerResultPage(result: data)),
      );
    } catch (e) {
      setState(() => _loading = false);
      debugPrint("Request failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ Floating action button to add new offers
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddOfferScreen()),
          ).then((_) {
            // When returning from AddOfferScreen, refresh the UI
            setState(() {});
          });
        },
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 50),

                // 🔍 SEARCH BAR
                TextField(
                  decoration: InputDecoration(
                    hintText: "Search sneakers...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 🖼 IMAGE PREVIEW (Shows after camera scan)
                if (_image != null) ...[
                  FutureBuilder<Uint8List>(
                    future: _image!.readAsBytes(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const LinearProgressIndicator();
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.memory(
                          snapshot.data!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 25),
                ],

                // ⭐ SPECIAL OFFERS (Now Dynamic using Icons)
                const Text(
                  "Special Offers",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                // Use the component we built earlier
                 DynamicOfferCarousel(),

                const SizedBox(height: 30),

                // 🔥 MOST POPULAR
                const Text(
                  "Most Popular",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                SizedBox(
                  height: 160,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: const [
                      PopularSneakerCard("Nike Air Max", "assets/images/nike-air-max.png"),
                      PopularSneakerCard("Yeezy Boost", "assets/images/yeezy-bost.png"),
                      PopularSneakerCard("Air Jordan 4", "assets/images/air-jordan-4.png"),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 📸 Floating scan button (Positioned at top right)
          Positioned(
            top: 40,
            right: 20,
            child: SneakerScanButton(onTap: pickImage),
          ),

          // ⏳ LOADING OVERLAY (Blurs background during AI scan)
          if (_loading)
            Container(
              color: Colors.black.withOpacity(0.4),
              child: const Center(child: CircularProgressIndicator(color: Colors.white)),
            ),
        ],
      ),
    );
  }
}