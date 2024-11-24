import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:student_management_system/consts/constant_color.dart';

// import 'package:supabase_flutter/supabase_flutter.dart';

import '../consts/constant_assets.dart';

class AddProfilePictureScreen extends StatefulWidget {
  const AddProfilePictureScreen({super.key});

  @override
  State<AddProfilePictureScreen> createState() =>
      _AddProfilePictureScreenState();
}

class _AddProfilePictureScreenState extends State<AddProfilePictureScreen> {
  XFile? _image;
  String? localPath; // Declare localPath as a member variable
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final directory = await getApplicationDocumentsDirectory();
      localPath =
          '${directory.path}/${pickedFile.name}'; // Store in the member variable
      final localImage = File(localPath!);
      await localImage.writeAsBytes(await pickedFile.readAsBytes());

      setState(() {
        _image = XFile(localPath!);
      });
    }
  }

  // Future<void> _uploadProfilePicture() async {
  //   if (_image == null || localPath == null) {
  //     return; // Check if localPath is null
  //   }

  //   try {
  //     // Upload the image to Supabase Storage
  //     final filePath =
  //         'profile_pictures/${_image!.name}'; // Define your storage path
  //     final fileToUpload = File(localPath!); // Use the member variable
  //     await Supabase.instance.client.storage
  //         .from('your-bucket-name') // Use your actual bucket name
  //         .upload(filePath, fileToUpload); // Pass the File instance

  //     // Get the public URL of the uploaded image
  //     final publicUrl = Supabase.instance.client.storage
  //         .from('your-bucket-name')
  //         .getPublicUrl(filePath);

  //     // Update user profile with the image URL
  //     final user = Supabase.instance.client.auth.currentUser;
  //     if (user != null) {
  //       final userId = user.id;
  //       final updates = {
  //         'profile_picture_url': publicUrl, // Update the profile picture URL
  //       };

  //       final res = await Supabase.instance.client
  //           .from('users') // Assuming you have a 'users' table
  //           .update(updates)
  //           .eq('id', userId);
  //       // Adjust as needed based on the library version

  //       // Check for errors in the update response
  //       if (res.error != null) {
  //         print('Error updating profile: ${res.error!.message}');
  //       } else {
  //         print('Profile updated successfully with image URL: $publicUrl');
  //       }
  //     }
  //   } catch (e) {
  //     print('Error: $e');
  //   }
  // }

  void _saveAndContinue() async {
    // await _uploadProfilePicture(); // Upload the profile picture before navigating
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/loginscreen',
      (route) => false,
      arguments: {
        'message': "Enter the credentials provided by your organization",
        'showRegister': true,
      },
    );
  }

  void _skip() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/loginscreen',
      (route) => false,
      arguments: {
        'message': "Enter the credentials provided by your organization",
        'showRegister': true,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Profile Picture"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 80,
                  backgroundImage: _image != null
                      ? FileImage(File(_image!.path))
                      : const AssetImage(kDefaultUserProfile),
                  child: _image == null
                      ? const Icon(Icons.add_a_photo,
                          size: 40, color: Colors.grey)
                      : null,
                ),
              ),
              const SizedBox(height: 24),
              InkWell(
                onTap: _saveAndContinue,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: kBackGroundColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "Save and Continue",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              TextButton(
                onPressed: _skip,
                child: const Text("Skip"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
