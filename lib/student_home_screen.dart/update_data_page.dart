import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../consts/constant_assets.dart';
import '../helpers/update_data_provider.dart';

class UpdateDataPage extends StatefulWidget {
  const UpdateDataPage({super.key});

  @override
  State<UpdateDataPage> createState() => _UpdateDataPageState();
}

class _UpdateDataPageState extends State<UpdateDataPage> {
  final ImagePicker _picker = ImagePicker();
  XFile? _profileImage;

  Future<void> _updateProfilePicture(UserDataProvider userData) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = pickedFile;
      });
      // Additional code for uploading to Firebase Storage and updating Firestore can go here
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserDataProvider>(
      builder: (context, userData, _) {
        final nameController = TextEditingController(text: userData.name);
        final emailController = TextEditingController(text: userData.email);

        return Scaffold(
          appBar: AppBar(
            title: const Text("Update Profile"),
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: GestureDetector(
                    onTap: userData.isEditing
                        ? () => _updateProfilePicture(userData)
                        : null,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: _profileImage != null
                          ? FileImage(File(_profileImage!.path))
                          : (userData.profilePictureUrl != null
                                  ? NetworkImage(userData.profilePictureUrl!)
                                  : const AssetImage(kDefaultUserProfile))
                              as ImageProvider,
                      child: userData.isEditing
                          ? const Icon(Icons.camera_alt,
                              size: 24, color: Colors.white)
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildEditableField(
                  controller: nameController,
                  label: "Name",
                  isEditable: userData.isEditing,
                ),
                const SizedBox(height: 16),
                _buildEditableField(
                  controller: emailController,
                  label: "Email",
                  isEditable: userData.isEditing,
                ),
                const SizedBox(height: 24),
                Center(
                  child: userData.isEditing
                      ? ElevatedButton(
                          onPressed: () {
                            userData.saveUpdates(
                                nameController.text, emailController.text);
                          },
                          child: const Text("Save"),
                        )
                      : ElevatedButton.icon(
                          onPressed: userData.toggleEditing,
                          icon: const Icon(Icons.edit),
                          label: const Text("Edit"),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEditableField({
    required TextEditingController controller,
    required String label,
    bool isEditable = false,
  }) {
    return TextFormField(
      controller: controller,
      enabled: isEditable,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
