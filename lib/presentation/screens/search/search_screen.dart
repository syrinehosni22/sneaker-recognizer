import 'package:flutter/material.dart';
import '../../../domain/models/sneaker.dart';
import '../../../services/sneaker_api_service.dart';
import '../productDetails/details.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String query = "";
  bool loading = false;
  List<Sneaker> results = [];

  Future<void> search(String value) async {
    setState(() {
      loading = true;
      query = value;
    });

    try {
      final response = await SneakerApiService.searchSneakerByName(value);

      final List<dynamic> rawResults = response["results"];

      setState(() {
        results = rawResults.map((e) => Sneaker.fromJson(e)).toList();
      });
    } catch (e) {
      setState(() {
        results = [];
      });
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              const Text(
                "Search Sneakers",
                style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              /// SEARCH INPUT
              TextField(
                onChanged: (value) {
                  if (value.length > 2) {
                    search(value);
                  }
                },
                decoration: InputDecoration(
                  hintText: "Search sneakers...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// RESULTS
              Expanded(
                child: loading
                    ? const Center(child: CircularProgressIndicator())
                    : results.isEmpty
                    ? const Center(child: Text("No results found"))
                    : ListView.builder(
                        itemCount: results.length,
                        itemBuilder: (context, index) {
                          final sneaker = results[index];

                          return Card(
                            child: ListTile(
                              leading: Image.network(
                                sneaker.imageUrl ??
                                    "https://via.placeholder.com/60",
                                width: 60,
                                fit: BoxFit.cover,
                              ),
                              title: Text(sneaker.title),
                              subtitle: Text(
                                "€${sneaker.price.toStringAsFixed(2)}",
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ProductDetailsPage(
                                      sneaker: sneaker,
                                      allSneakers: results, // still valid here
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
