import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:sneaker_recognizer_plateform/services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker picker = ImagePicker();
  XFile? _image;

  Future<void> pickImage(AuthService auth) async {
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (picked == null) return;

    setState(() => _image = picked);

    await auth.updateProfileImage(picked.path);
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final user = auth.currentUser;

    return Scaffold(
      body: Center(
        child: user == null
            ? const Text("Not logged in")
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => pickImage(auth),
                    child: CircleAvatar(
                      radius: 55,
                      backgroundImage: _image != null
                          ? FileImage(File(_image!.path))
                          : auth.profileImage != null
                          ? FileImage(File(auth.profileImage!))
                          : const NetworkImage(
                              "https://via.placeholder.com/150",
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(user.email),

                  const SizedBox(height: 30),

                  ElevatedButton(
                    onPressed: () async {
                      await auth.logout();

                      if (context.mounted) {
                        Navigator.pushReplacementNamed(context, '/login');
                      }
                    },
                    child: const Text("Logout"),
                  ),
                ],
              ),
      ),
    );
  }
}
