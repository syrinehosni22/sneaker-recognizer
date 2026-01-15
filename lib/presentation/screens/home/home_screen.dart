import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sneaker_recognizer_plateform/presentation/screens/searchResult/search_result.dart';
import 'package:sneaker_recognizer_plateform/presentation/widgets/SneakerScan/SneakerScanButton.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  XFile? _image;
  bool _loading = false;
  final picker = ImagePicker();

  // Membres fictifs pour tri
  final Set<String> memberShops = {
    "Nike Store",
    "Foot Locker",
    "Decathlon",
    "JD Sports",
    "Sneaker World",
  };

  // 📸 Pick image
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

  // Charger JSON test
  Future<List<Map<String, dynamic>>> loadTestSneakers() async {
    final data = await rootBundle.loadString('test_sneaker_results.json');
    final List<dynamic> jsonList = jsonDecode(data);
    final results = jsonList.map((e) => e as Map<String, dynamic>).toList();

    // Ajouter flag isMember
    for (final item in results) {
      final shopName = item['shop'] ?? "";
      item['isMember'] = memberShops.contains(shopName);
    }

    // Tri: membres d'abord
    results.sort((a, b) {
      final aMember = a['isMember'] == true ? 1 : 0;
      final bMember = b['isMember'] == true ? 1 : 0;
      return bMember.compareTo(aMember);
    });

    return results;
  }

  Future<void> sendImageAndNavigate(XFile image) async {
    try {
      setState(() => _loading = true);

      // Remplacer par SneakerApiService.getSneakerData(image) plus tard
      final data = await loadTestSneakers();

      setState(() => _loading = false);

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
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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

                // 🖼 IMAGE PREVIEW
                if (_image != null)
                  FutureBuilder<Uint8List>(
                    future: _image!.readAsBytes(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData)
                        return const CircularProgressIndicator();
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.memory(
                          snapshot.data!,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),

          // 📸 Floating scan button
          Positioned(
            top: 20,
            right: 20,
            child: SneakerScanButton(onTap: pickImage),
          ),

          // ⏳ LOADING OVERLAY
          if (_loading)
            Container(
              color: Colors.black.withOpacity(0.4),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
