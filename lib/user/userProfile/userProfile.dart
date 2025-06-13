// ignore_for_file: file_names, use_super_parameters, library_private_types_in_public_api, avoid_print, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kms2/service/database_service.dart';

import '../../service/cloudinary_service.dart';
import '../../service/zmodel/childmodel.dart';
import '../../service/zmodel/usermodel.dart';
import 'userChildDetail.dart';

class ProfilePage extends StatefulWidget {
  final String docId;

  const ProfilePage({Key? key, required this.docId}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final ImagePicker _picker = ImagePicker();
  User? _user;
  bool _isUploading = false;
  List<Child> _children = [];
  String? _userProfileImage;
  final DatabaseService _databaseService = DatabaseService();

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _loadProfileData() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.docId)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic> userData =
            userDoc.data() as Map<String, dynamic>; // Cast data to Map

        // Print the user data to check what values are being fetched
        print("User Data: $userData");

        setState(() {
          _user = User.fromDocument(userDoc);
          _userProfileImage = userData.containsKey('profileImage')
              ? userData['profileImage']
              : null; // Default to null if profileImage does not exist
        });

        if (_user!.childIds.isNotEmpty) {
          _loadChildrenData(_user!.childIds);
        }
      } else {
        print("User document does not exist");
      }
    } catch (e) {
      print("Error loading profile data: $e");
    }
  }

  Future<void> _loadChildrenData(List<String> childIds) async {
    try {
      QuerySnapshot childrenSnapshot = await FirebaseFirestore.instance
          .collection('child')
          .where(FieldPath.documentId, whereIn: childIds)
          .get();

      setState(() {
        _children = childrenSnapshot.docs.map((doc) {
          return Child.fromDocument(doc);
        }).toList();
      });
    } catch (e) {
      print("Error loading children data: $e");
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _isUploading = true;
      });

      String imageUrl = await _uploadImageToCloudinary(pickedFile.path);
      if (imageUrl.isNotEmpty) {
        _updateProfileImage(imageUrl);
      } else {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Future<String> _uploadImageToCloudinary(String filePath) async {
    try {
      return await _cloudinaryService.uploadImage(filePath);
    } catch (e) {
      print("Error uploading image: $e");
      return '';
    }
  }

  Future<void> _updateProfileImage(String imageUrl) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.docId)
          .update({'profileImage': imageUrl});

      setState(() {
        _userProfileImage = imageUrl;
        _isUploading = false;
      });

      print("Profile image updated!");
    } catch (e) {
      print("Error updating profile image: $e");
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildProfileImage(),
              const SizedBox(height: 16),
              _buildUserInfo(),
              _buildChildrenList(),
              if (_isUploading)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return _userProfileImage != null && _userProfileImage!.isNotEmpty
        ? CircleAvatar(
            radius: 80,
            backgroundImage: NetworkImage(_userProfileImage!),
          )
        : CircleAvatar(
            radius: 80,
            backgroundColor: Colors.grey[300],
            child: const Icon(Icons.person, size: 50, color: Colors.white),
          );
  }

  Widget _buildChangeProfileButton() {
    return ElevatedButton(
      onPressed: _pickImage,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        minimumSize: const Size(150, 40),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF8A2387), Color(0xFFE94057), Color(0xFFF27121)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        alignment: Alignment.center,
        child: const Text(
          'Change Profile Picture',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person, color: Colors.black54),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Name: ${_user?.name ?? 'N/A'}',
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.phone, color: Colors.black54),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Phone: ${_user?.noTel ?? 'N/A'}',
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.email, color: Colors.black54),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Email: ${_user?.email ?? 'N/A'}',
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildChangeProfileButton(),
          ElevatedButton(
            onPressed: () {
              _showEditUserDialog();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              minimumSize: const Size(150, 40),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF8A2387),
                    Color(0xFFE94057),
                    Color(0xFFF27121)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16.0),
              ),
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              alignment: Alignment.center,
              child: const Text(
                'Edit Info',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditUserDialog() {
    final TextEditingController _nameController =
        TextEditingController(text: _user?.name);
    final TextEditingController _phoneController =
        TextEditingController(text: _user?.noTel);
    final TextEditingController _emailController =
        TextEditingController(text: _user?.email);

    final GlobalKey<FormState> _formKey =
        GlobalKey<FormState>(); // Add a global key for the form

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit User Information'),
          content: SingleChildScrollView(
            child: Form(
              // Wrap in Form widget
              key: _formKey, // Assign the global key
              child: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTextField(_nameController, 'Name'),
                    _buildTextField(
                      _phoneController,
                      'Phone Number',
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        } else if (!RegExp(r'^01\d{7,9}$').hasMatch(value)) {
                          return 'Phone number must start with "01" and be 8 to 11 digits long';
                        }
                        return null;
                      },
                    ),
                    _buildTextField(
                      _emailController,
                      'Email',
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        } else if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                            .hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  // Validate the form
                  // Check if the email already exists
                  bool emailExists = await _databaseService
                      .doesEmailExist(_emailController.text.trim());
                  if (emailExists &&
                      _emailController.text.trim() != _user?.email) {
                    _showSnackBar(
                        'Email is already used. Please use a different email.');
                    return;
                  }

                  // Validate phone number
                  if (!RegExp(r'^01\d{7,9}$')
                      .hasMatch(_phoneController.text.trim())) {
                    _showSnackBar('Must start with "01" & 8-11 digits long.');
                    return;
                  }

                  // Update the user information
                  final updatedUser = {
                    'name': _nameController.text.trim(),
                    'noTel': _phoneController.text.trim(),
                    'email': _emailController.text.trim(),
                  };

                  try {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(widget.docId)
                        .update(updatedUser);

                    // Update local user data
                    setState(() {
                      _user?.name = updatedUser['name'] ?? '';
                      _user?.noTel = updatedUser['noTel'] ?? '';
                      _user?.email = updatedUser['email'] ?? '';
                    });

                    _showSnackBar('User information updated!');
                    Navigator.of(context).pop();
                  } catch (e) {
                    _showSnackBar('Failed to update user information: $e');
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool obscureText = false,
      TextInputType keyboardType = TextInputType.text,
      String? Function(String?)? validator}) {
    // Add validator parameter
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator, // Use the validator parameter
      ),
    );
  }

  Widget _buildChildrenList() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Children:',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          if (_children.isNotEmpty)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _children.length,
              itemBuilder: (context, index) {
                final child = _children[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserChildDetailPage(child: child),
                      ),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    elevation: 3,
                    color: Colors.white,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal: 16.0,
                      ),
                      leading: CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white54,
                        backgroundImage: child.profileImage != null &&
                                child.profileImage!.isNotEmpty
                            ? NetworkImage(child.profileImage!)
                            : null,
                        child: (child.profileImage == null ||
                                child.profileImage!.isEmpty)
                            ? const Icon(
                                Icons.child_care,
                                size: 24,
                                color: Colors.black,
                              )
                            : null,
                      ),
                      title: Text(
                        child.name,
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      subtitle: const Text(
                        'Tap for details',
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.black54,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                );
              },
            )
          else
            const Text(
              'No children registered.',
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.grey,
              ),
            ),
        ],
      ),
    );
  }
}
