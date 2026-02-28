import 'package:flutter/material.dart';
import 'package:sneaker_recognizer_plateform/services/offer_service.dart'; // Ensure this path is correct

class AddOfferScreen extends StatefulWidget {
  const AddOfferScreen({super.key});

  @override
  State<AddOfferScreen> createState() => _AddOfferScreenState();
}

class _AddOfferScreenState extends State<AddOfferScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _sneakerIdsController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;

  // Date Picker Helper
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(), // Prevents selecting past dates
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  // Submit Logic using Service
  Future<void> _submitOffer() async {
    if (!_formKey.currentState!.validate()) return;

    if (_startDate == null || _endDate == null) {
      _showSnackBar("Please select both Start and End dates");
      return;
    }

    setState(() => _isLoading = true);

    final Map<String, dynamic> offerData = {
      "title": _titleController.text.trim(),
      "discountPercentage": int.parse(_discountController.text),
      "sneakerIds": _sneakerIdsController.text.isNotEmpty
          ? _sneakerIdsController.text.split(',').map((e) => e.trim()).toList()
          : [],
      "startDate": _startDate!.toIso8601String(),
      "endDate": _endDate!.toIso8601String(),
      "active": true,
    };

    // Calling the centralized service
    final success = await OfferService.addOffer(offerData);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      _showSnackBar("Offer created successfully!");
      Navigator.pop(context); // Return to Home
    } else {
      _showSnackBar("Failed to create offer. Check server connection.");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create New Offer"),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Title Field ---
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "Promotion Title",
                  hintText: "e.g., Summer Nike Sale",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (v) => v!.isEmpty ? "Please enter a title" : null,
              ),
              const SizedBox(height: 20),

              // --- Discount Field ---
              TextFormField(
                controller: _discountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Discount Percentage (%)",
                  hintText: "e.g., 30",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.percent),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return "Enter percentage";
                  if (int.tryParse(v) == null) return "Enter a valid number";
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // --- Sneaker IDs Field ---
              TextFormField(
                controller: _sneakerIdsController,
                decoration: const InputDecoration(
                  labelText: "Sneaker IDs (Optional)",
                  hintText: "Paste IDs separated by commas",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.inventory),
                ),
              ),
              const SizedBox(height: 25),

              // --- Date Selection ---
              const Text("Promotion Validity",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _selectDate(context, true),
                      icon: const Icon(Icons.calendar_today),
                      label: Text(_startDate == null
                          ? "Start Date"
                          : _startDate!.toString().split(' ')[0]),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _selectDate(context, false),
                      icon: const Icon(Icons.event),
                      label: Text(_endDate == null
                          ? "End Date"
                          : _endDate!.toString().split(' ')[0]),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // --- Submit Button ---
              ElevatedButton(
                onPressed: _submitOffer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Post Promotion", style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _discountController.dispose();
    _sneakerIdsController.dispose();
    super.dispose();
  }
}