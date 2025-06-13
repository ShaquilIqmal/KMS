import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../service/cloudinary_service.dart';
import '../../service/database_service.dart';
import '../../service/zmodel/childmodel.dart';
import '../../service/zmodel/usermodel.dart';
import 'viewUserChildInfo.dart';

class UserInformationPage extends StatefulWidget {
  final User user;

  UserInformationPage({required this.user});

  @override
  _UserInformationPageState createState() => _UserInformationPageState();
}

class _UserInformationPageState extends State<UserInformationPage> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _isUploading = true;
      });
      String imageUrl = await _uploadImageToCloudinary(pickedFile.path);
      if (imageUrl.isNotEmpty) {
        await _updateProfileImage(imageUrl);
      } else {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Future<String> _uploadImageToCloudinary(String filePath) async {
    try {
      String imageUrl = await CloudinaryService().uploadImage(filePath);
      return imageUrl;
    } catch (e) {
      print("Error uploading image: $e");
      return '';
    }
  }

  Future<void> _updateProfileImage(String imageUrl) async {
    try {
      await DatabaseService().updateUserProfileImage(widget.user.id, imageUrl);
      setState(() {
        widget.user.profileImage = imageUrl; // Update local state for display
        _isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile image updated successfully')),
      );
    } catch (e) {
      print("Error updating profile image: $e");
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _editUserData() {
    final TextEditingController nameController =
        TextEditingController(text: widget.user.name);
    final TextEditingController emailController =
        TextEditingController(text: widget.user.email);
    final TextEditingController phoneController =
        TextEditingController(text: widget.user.noTel);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          backgroundColor:
              Colors.black.withOpacity(0.7), // Transparent black background
          title: const Text(
            'Edit User Information',
            style: TextStyle(color: Colors.white), // White text color
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  style:
                      const TextStyle(color: Colors.white), // White text color
                  decoration: InputDecoration(
                    labelText: 'Name',
                    labelStyle: const TextStyle(
                        color: Colors.white70), // Light grey label
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(color: Colors.white70),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  style:
                      const TextStyle(color: Colors.white), // White text color
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: const TextStyle(
                        color: Colors.white70), // Light grey label
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(color: Colors.white70),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  style:
                      const TextStyle(color: Colors.white), // White text color
                  decoration: InputDecoration(
                    labelText: 'Telephone',
                    labelStyle: const TextStyle(
                        color: Colors.white70), // Light grey label
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(color: Colors.white70),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () async {
                String newName = nameController.text;
                String newEmail = emailController.text;
                String newPhone = phoneController.text;

                // Update user data in Firestore
                await DatabaseService().updateUserData(
                    widget.user.id, newName, newEmail, newPhone);
                setState(() {
                  widget.user.name = newName;
                  widget.user.email = newEmail;
                  widget.user.noTel = newPhone;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('User information updated successfully')),
                );
                Navigator.of(context).pop();
              },
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'User Information',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // User Profile Image
            Center(
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: _pickImage, // Change image on tap
                    child: CircleAvatar(
                      radius: 60, // Adjust the radius as needed
                      backgroundImage: widget.user.profileImage != null &&
                              widget.user.profileImage!.isNotEmpty
                          ? NetworkImage(widget.user.profileImage!)
                          : null,
                      child: widget.user.profileImage == null ||
                              widget.user.profileImage!.isEmpty
                          ? const Icon(Icons.person,
                              size: 60) // Default icon if no image
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage, // Trigger image picker on icon tap
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Icon(Icons.camera_alt,
                              color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_isUploading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Center(child: CircularProgressIndicator()),
              ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildUserDetails(widget.user),
            ),

            _buildEditButton(context),
            const SizedBox(height: 16),
            const Text(
              'Children',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            if (widget.user.children.isEmpty)
              const Text(
                'No children registered.',
                style: TextStyle(color: Colors.black54),
              )
            else
              ..._buildChildrenList(context, widget.user.children),
          ],
        ),
      ),
    );
  }

  Widget _buildUserDetails(User user) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 4,
        color: Colors.white,
        shadowColor: Colors.grey.withOpacity(0.3),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Name: ${user.name}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Email: ${user.email}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Telephone: ${user.noTel}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF8A2387), Color(0xFFE94057), Color(0xFFF27121)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24.0),
            ),
            padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
          ),
          onPressed: _editUserData, // Call the edit function
          child: const Text(
            'Edit User Information',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildChildrenList(BuildContext context, List<Child> children) {
    return children.map<Widget>((child) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 4,
        color: Colors.white,
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage:
                child.profileImage != null && child.profileImage!.isNotEmpty
                    ? NetworkImage(child.profileImage!)
                    : null,
            child: child.profileImage == null || child.profileImage!.isEmpty
                ? const Icon(Icons.child_care, size: 40)
                : null,
          ),
          title: Text(
            child.sectionA['nameC'] ?? 'No Name',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                child: Text('View',
                    style: TextStyle(
                        color: Colors.grey[800], fontWeight: FontWeight.bold)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewUserChildInfoPage(
                          child: child, user: widget.user),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  await _confirmDelete(context, child.id, widget.user.id);
                },
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Future<void> _confirmDelete(
      BuildContext context, String childId, String userId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        backgroundColor:
            Colors.black.withOpacity(0.7), // Transparent black background
        title: const Text(
          'Delete Child',
          style: TextStyle(color: Colors.white), // White text color
        ),
        content: const Text(
          'Are you sure you want to delete this child?',
          style: TextStyle(color: Colors.white70), // Light grey text color
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      //attendanceCollection
      // Call the delete method from the DatabaseService
      await DatabaseService().deleteChild(childId, userId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Child deleted successfully')),
      );
      setState(() {
        widget.user.children.removeWhere((child) => child.id == childId);
      });
    }
  }
}
