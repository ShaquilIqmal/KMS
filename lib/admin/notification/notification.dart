import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotificationPage extends StatefulWidget {
  final String adminDocId;

  const NotificationPage({Key? key, required this.adminDocId})
      : super(key: key);
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> _filteredUsers = [];
  List<Map<String, dynamic>> _filteredTeachers = [];
  List<Map<String, dynamic>> _selectedUsers = []; // Store as dynamic
  List<Map<String, dynamic>> _selectedTeachers = []; // Store as dynamic

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Send Notification',
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
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitleField(),
                    const SizedBox(height: 16),
                    _buildMessageField(),
                    const SizedBox(height: 16),
                    _buildRecipientHeader("Send To"),
                    const SizedBox(height: 8),
                    _buildUserSearchField(),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _buildSelectAllUsersButton(),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildSelectedUsersDisplay(),
                    const SizedBox(height: 16),
                    _buildFilteredUserList(),
                    _buildTeacherSearchField(),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _buildSelectAllTeachersButton(),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildSelectedTeachersDisplay(),
                    const SizedBox(height: 16),
                    _buildFilteredTeacherList(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildSendNotificationButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: InputDecoration(
        labelText: 'Title',
        labelStyle: TextStyle(color: Colors.grey[800]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey.shade800),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      validator: (value) => value!.isEmpty ? 'Please enter a title' : null,
    );
  }

  Widget _buildMessageField() {
    return TextFormField(
      controller: _messageController,
      decoration: InputDecoration(
        labelText: 'Message',
        labelStyle: TextStyle(color: Colors.grey[800]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey.shade800),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      maxLines: 4,
      validator: (value) => value!.isEmpty ? 'Please enter a message' : null,
    );
  }

  Widget _buildRecipientHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildUserSearchField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Search Users',
        labelStyle: TextStyle(color: Colors.grey[800]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey.shade800),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        filled: true,
        fillColor: Colors.grey[100],
        prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
      ),
      onChanged: _searchUsers,
    );
  }

  Widget _buildSelectAllUsersButton() {
    return TextButton(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
        backgroundColor: Colors.grey.shade300,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
          side: BorderSide(color: Colors.grey.shade800, width: 2.0),
        ),
        textStyle: const TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
      onPressed: _selectAllUsers,
      child: Text(
        'Select All Users',
        style: TextStyle(
          color: Colors.grey.shade800,
        ),
      ),
    );
  }

  Widget _buildSelectedUsersDisplay() {
    return Wrap(
      children: _selectedUsers.map((user) {
        return Container(
          margin: const EdgeInsets.only(right: 8, bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                user['name']!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () {
                  _toggleUserSelection(user);
                },
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFilteredUserList() {
    return _filteredUsers.isNotEmpty
        ? ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _filteredUsers.length,
            itemBuilder: (context, index) {
              final user = _filteredUsers[index];
              return ListTile(
                title: Text(user['name']),
                onTap: () {
                  _toggleUserSelection(user);
                },
              );
            },
          )
        : Container();
  }

  Widget _buildTeacherSearchField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Search Teachers',
        labelStyle: TextStyle(color: Colors.grey[800]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey.shade800),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        filled: true,
        fillColor: Colors.grey[100],
        prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
      ),
      onChanged: _searchTeachers,
    );
  }

  Widget _buildSelectAllTeachersButton() {
    return TextButton(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
        backgroundColor: Colors.grey.shade300,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
          side: BorderSide(color: Colors.grey.shade800, width: 2.0),
        ),
        textStyle: const TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
      onPressed: _selectAllTeachers,
      child: Text(
        'Select All Teachers',
        style: TextStyle(
          color: Colors.grey.shade800,
        ),
      ),
    );
  }

  Widget _buildSelectedTeachersDisplay() {
    return Wrap(
      children: _selectedTeachers.map((teacher) {
        return Container(
          margin: const EdgeInsets.only(right: 8, bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade800,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                teacher['name']!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () {
                  _toggleTeacherSelection(teacher);
                },
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFilteredTeacherList() {
    return _filteredTeachers.isNotEmpty
        ? ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _filteredTeachers.length,
            itemBuilder: (context, index) {
              final teacher = _filteredTeachers[index];
              return ListTile(
                title: Text(teacher['name']),
                onTap: () {
                  _toggleTeacherSelection(teacher);
                },
              );
            },
          )
        : Container();
  }

  Widget _buildSendNotificationButton() {
    return SizedBox(
      width: double.infinity,
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
          onPressed: _sendNotification,
          child: const Text(
            'Send Notification',
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

  // Backend Functions
  void _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() {
        _filteredUsers.clear();
      });
      return;
    }

    final snapshot = await FirebaseFirestore.instance.collection('users').get();
    setState(() {
      _filteredUsers = snapshot.docs
          .where((user) => user['name']
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()))
          .map((user) => {
                'id': user.id,
                'name': user['name'],
              })
          .toList();
    });
  }

  void _selectAllUsers() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').get();
    final allUsers = snapshot.docs
        .map((user) => {
              'id': user.id,
              'name': user['name'],
            })
        .toList();

    setState(() {
      if (_selectedUsers.length == allUsers.length) {
        _selectedUsers.clear();
      } else {
        _selectedUsers = List.from(allUsers);
      }
    });
  }

  void _searchTeachers(String query) async {
    if (query.isEmpty) {
      setState(() {
        _filteredTeachers.clear();
      });
      return;
    }

    final snapshot =
        await FirebaseFirestore.instance.collection('teachers').get();
    setState(() {
      _filteredTeachers = snapshot.docs
          .where((teacher) => teacher['name']
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()))
          .map((teacher) => {
                'id': teacher.id,
                'name': teacher['name'],
              })
          .toList();
    });
  }

  void _selectAllTeachers() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('teachers').get();
    final allTeachers = snapshot.docs
        .map((teacher) => {
              'id': teacher.id,
              'name': teacher['name'],
            })
        .toList();

    setState(() {
      if (_selectedTeachers.length == allTeachers.length) {
        _selectedTeachers.clear();
      } else {
        _selectedTeachers = List.from(allTeachers);
      }
    });
  }

  Future<void> _sendNotificationToUser(
      String notificationId, String userId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId)
        .set({
      'notificationId': notificationId,
      'title': _titleController.text,
      'message': _messageController.text,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    });
  }

  Future<void> _sendNotification() async {
    if (!_formKey.currentState!.validate()) return;

    // Ensure at least one recipient is selected
    if (_selectedUsers.isEmpty && _selectedTeachers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one recipient")),
      );
      return;
    }

    try {
      // Add notification document to the Firestore 'notifications' collection
      DocumentReference notificationRef =
          await FirebaseFirestore.instance.collection('notifications').add({
        'title': _titleController.text,
        'message': _messageController.text,
        'senderId': widget.adminDocId, // Replace with actual admin ID
        'timestamp': FieldValue.serverTimestamp(),
        'recipients': [
          ..._selectedUsers
              .map((user) => {'id': user['id'], 'name': user['name']}),
          ..._selectedTeachers
              .map((teacher) => {'id': teacher['id'], 'name': teacher['name']}),
        ],
      });

      // Send notification to selected users
      for (var user in _selectedUsers) {
        String? userId = user['id'];
        if (userId != null) {
          await _sendNotificationToUser(notificationRef.id, userId);
        }
      }

      // Send notification to selected teachers
      for (var teacher in _selectedTeachers) {
        String? teacherId = teacher['id'];
        if (teacherId != null) {
          await _sendNotificationToUser(notificationRef.id, teacherId);
        }
      }

      // Confirmation message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Notification sent successfully")),
      );

      // Clear fields and selections
      _titleController.clear();
      _messageController.clear();
      setState(() {
        _selectedUsers.clear();
        _selectedTeachers.clear();
        _filteredUsers.clear();
        _filteredTeachers.clear();
      });
    } catch (e) {
      print("Error sending notification: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error sending notification")),
      );
    }
  }

  void _toggleUserSelection(Map<String, dynamic> user) {
    setState(() {
      if (_selectedUsers.contains(user)) {
        _selectedUsers.remove(user);
      } else {
        _selectedUsers.add(user);
      }
    });
  }

  void _toggleTeacherSelection(Map<String, dynamic> teacher) {
    setState(() {
      if (_selectedTeachers.contains(teacher)) {
        _selectedTeachers.remove(teacher);
      } else {
        _selectedTeachers.add(teacher);
      }
    });
  }
}
