// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../service/database_service.dart';
import '../../service/zmodel/usermodel.dart';
import 'addUser.dart';
import 'viewUserInfoPage.dart';

class ViewUserPage extends StatelessWidget {
  const ViewUserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'View Users',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamProvider<List<User>>.value(
              value: DatabaseService().getUsersWithChildren(),
              initialData: [],
              child: Consumer<List<User>>(
                builder: (context, users, _) {
                  if (users.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  List<User> usersWithChildren = [];
                  List<User> usersWithoutChildren = [];

                  for (var user in users) {
                    if (user.name != 'admin') {
                      if (user.children.isNotEmpty) {
                        usersWithChildren.add(user);
                      } else {
                        usersWithoutChildren.add(user);
                      }
                    }
                  }

                  return ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child:
                            _buildUsersWithChildren(context, usersWithChildren),
                      ),
                      _buildUsersWithoutChildren(context, usersWithoutChildren),
                    ],
                  );
                },
              ),
            ),
          ),
          _buildAddUserButton(context), // Move the button to the bottom
        ],
      ),
    );
  }

  Widget _buildAddUserButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16.0),
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
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddUserPage(),
            ),
          );
        },
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '+ Add Users',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersWithChildren(BuildContext context, List<User> users) {
    return ExpansionTile(
      title: const Text(
        'Users With Children',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      tilePadding: const EdgeInsets.symmetric(horizontal: 16.0),
      childrenPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      children: users.map((user) {
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserInformationPage(user: user),
              ),
            );
          },
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            elevation: 4,
            color: Colors.white,
            child: ListTile(
              leading: CircleAvatar(
                radius: 25,
                backgroundImage:
                    user.profileImage != null && user.profileImage!.isNotEmpty
                        ? NetworkImage(user.profileImage!)
                        : null,
                child: user.profileImage == null || user.profileImage!.isEmpty
                    ? const Icon(Icons.person, size: 25)
                    : null,
              ),
              title: Text(
                user.name,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: user.children.map((child) {
                  return Text(
                    child.name,
                    style: const TextStyle(color: Colors.grey),
                  );
                }).toList(),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildUsersWithoutChildren(BuildContext context, List<User> users) {
    return ExpansionTile(
      title: const Text(
        'Users Without Children',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      tilePadding: const EdgeInsets.symmetric(horizontal: 16.0),
      childrenPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      children: users.map((user) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 4,
          color: Colors.white,
          child: ListTile(
            leading: CircleAvatar(
              radius: 25,
              backgroundImage:
                  user.profileImage != null && user.profileImage!.isNotEmpty
                      ? NetworkImage(user.profileImage!)
                      : null,
              child: user.profileImage == null || user.profileImage!.isEmpty
                  ? const Icon(Icons.person, size: 25)
                  : null,
            ),
            title: Text(
              user.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle:
                const Text('No children', style: TextStyle(color: Colors.grey)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.grey[800]),
                  onPressed: () {
                    _showEditDialog(context, user);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    // Confirm deletion
                    final bool? confirmDelete = await showDialog<bool>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Confirm Deletion'),
                          content: const Text(
                              'Are you sure you want to delete this user?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Delete'),
                            ),
                          ],
                        );
                      },
                    );

                    if (confirmDelete == true) {
                      // Call the deleteUser method from DatabaseService
                      await DatabaseService().deleteUser(user.id);
                      // Optionally, show a Snackbar or Toast to indicate success
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('${user.name} has been deleted')),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showEditDialog(BuildContext context, User user) {
    final TextEditingController _nameController =
        TextEditingController(text: user.name);
    final TextEditingController _emailController =
        TextEditingController(text: user.email);
    final TextEditingController _phoneController =
        TextEditingController(text: user.noTel);
    final TextEditingController _passwordController =
        TextEditingController(text: user.password);

    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    final DatabaseService _databaseService =
        DatabaseService(); // Initialize your database service

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit User'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: double.maxFinite,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTextField(_nameController, 'Name'),
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
                    _buildTextField(_passwordController, 'Password',
                        obscureText: true),
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
                // Validate the form
                if (_formKey.currentState?.validate() ?? false) {
                  // Check if the email already exists
                  bool emailExists = await _databaseService
                      .doesEmailExist(_emailController.text.trim());

                  if (emailExists &&
                      _emailController.text.trim() != user.email) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Email is already used. Please use a different email.')),
                    );
                    return; // Stop further execution
                  }

                  // Update the user information
                  final updatedUser = {
                    'name': _nameController.text.trim(),
                    'email': _emailController.text.trim(),
                    'noTel': _phoneController.text.trim(),
                    'password': _passwordController.text.trim(),
                  };

                  try {
                    await _databaseService.updateUser(user.id, updatedUser);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${user.name} has been updated')),
                    );
                    Navigator.of(context).pop();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to update user: $e')),
                    );
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

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator, // Add the validator parameter
  }) {
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
        validator: validator, // Use the validator parameter here
      ),
    );
  }
}
