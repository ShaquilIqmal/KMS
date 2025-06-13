import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../service/cloudinary_service.dart';
import '../../service/database_service.dart';
import '../../service/zmodel/teachermodel.dart';
import 'addTeacher.dart';

class ViewTeacherPage extends StatelessWidget {
  const ViewTeacherPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'View Teachers',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Expanded(
                child: StreamProvider<List<Teacher>>.value(
                  value: DatabaseService().getTeachers(),
                  initialData: const [],
                  child: Consumer<List<Teacher>>(
                    builder: (context, teachers, _) => teachers.isEmpty
                        ? const Center(child: Text('No teachers available'))
                        : ListView.builder(
                            itemCount: teachers.length,
                            itemBuilder: (context, index) =>
                                _buildTeacherTile(context, teachers[index]),
                          ),
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildAddTeacherButton(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddTeacherButton(BuildContext context) {
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
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddTeacherPage(),
              ),
            );
          },
          child: const Text(
            'Add Teachers',
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

  Widget _buildTeacherTile(BuildContext context, Teacher teacher) {
    return Card(
      elevation: 4.0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ExpansionTile(
            tilePadding: EdgeInsets.zero,
            leading: CircleAvatar(
              radius: 25,
              backgroundImage: teacher.profileImage != null &&
                      teacher.profileImage!.isNotEmpty
                  ? NetworkImage(teacher.profileImage!)
                  : null,
              child:
                  teacher.profileImage == null || teacher.profileImage!.isEmpty
                      ? const Icon(Icons.person, size: 30, color: Colors.grey)
                      : null,
            ),
            title: Text(
              teacher.name,
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                    left: 16.0, right: 16.0, bottom: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DOB: ${teacher.dateOfBirth}',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey[700],
                      ),
                    ),
                    Text(
                      'Gender: ${teacher.gender}',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey[700],
                      ),
                    ),
                    Text(
                      'Position: ${teacher.employmentInfo.position}',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey[700],
                      ),
                    ),
                    Text(
                      'Classes: ${teacher.assignedClasses.join(', ')}',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey[700],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.grey[800]),
                          onPressed: () => _showEditDialog(context, teacher),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _showDeleteDialog(context, teacher),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, Teacher teacher) {
    final _editFormKey = GlobalKey<FormState>();
    final TextEditingController nameController =
        TextEditingController(text: teacher.name);
    final TextEditingController dateOfBirthController =
        TextEditingController(text: teacher.dateOfBirth);
    final TextEditingController genderController =
        TextEditingController(text: teacher.gender);
    final TextEditingController idNumberController =
        TextEditingController(text: teacher.idNumber);
    final TextEditingController phoneNumberController =
        TextEditingController(text: teacher.contactInfo.phoneNumber);
    final TextEditingController emailController =
        TextEditingController(text: teacher.contactInfo.email);
    final TextEditingController homeAddressController =
        TextEditingController(text: teacher.contactInfo.homeAddress);
    final TextEditingController positionController =
        TextEditingController(text: teacher.employmentInfo.position);
    final TextEditingController joiningDateController =
        TextEditingController(text: teacher.employmentInfo.joiningDate);
    final TextEditingController employmentStatusController =
        TextEditingController(text: teacher.employmentInfo.employmentStatus);
    final TextEditingController salaryController =
        TextEditingController(text: teacher.employmentInfo.salary);

    List<String> selectedClasses = List.from(teacher.assignedClasses);
    String? newProfileImageUrl; // Variable to hold the new image URL

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          backgroundColor: Colors.black.withOpacity(0.7),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return SingleChildScrollView(
                  child: Form(
                    key: _editFormKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () async {
                            final imagePicker = ImagePicker();
                            final pickedFile = await imagePicker.pickImage(
                                source: ImageSource.gallery);
                            if (pickedFile != null) {
                              // Upload the image to Cloudinary
                              final cloudinaryService = CloudinaryService();
                              newProfileImageUrl = await cloudinaryService
                                  .uploadImage(pickedFile.path);
                              setState(
                                  () {}); // Refresh the dialog to show the new image
                            }
                          },
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            backgroundImage: newProfileImageUrl != null
                                ? NetworkImage(newProfileImageUrl!)
                                : teacher.profileImage != null &&
                                        teacher.profileImage!.isNotEmpty
                                    ? NetworkImage(teacher.profileImage!)
                                    : null,
                            child: newProfileImageUrl == null &&
                                    (teacher.profileImage == null ||
                                        teacher.profileImage!.isEmpty)
                                ? const Icon(Icons.camera_alt,
                                    size: 50,
                                    color: Colors
                                        .grey) // Show camera icon if no image
                                : null,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildTextFormField(
                          controller: nameController,
                          labelText: 'Name',
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please enter the teacher\'s name'
                              : null,
                        ),
                        _buildTextFormField(
                          controller: dateOfBirthController,
                          labelText: 'Date of Birth',
                          hintText: 'YYYY-MM-DD',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the date of birth';
                            }
                            if (!RegExp(r'^\d{4}-\d{2}-\d{2}$')
                                .hasMatch(value)) {
                              return 'Date of Birth must be in YYYY-MM-DD format';
                            }
                            return null;
                          },
                        ),
                        _buildTextFormField(
                          controller: genderController,
                          labelText: 'Gender',
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please enter the gender'
                              : null,
                        ),
                        _buildTextFormField(
                          controller: phoneNumberController,
                          labelText: 'Phone Number',
                          hintText: 'Phone Number',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the phone number';
                            }
                            if (!RegExp(r'^\d{8,12}$').hasMatch(value)) {
                              return 'Phone number must be 8-12 digits long and contain only numbers';
                            }
                            return null;
                          },
                        ),
                        _buildTextFormField(
                          controller: emailController,
                          labelText: 'Email',
                          hintText: 'Email',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        _buildTextFormField(
                          controller: homeAddressController,
                          labelText: 'Home Address',
                          hintText: 'Home Address',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the home address';
                            }
                            if (!RegExp(r'\b\d{5}\b').hasMatch(value)) {
                              return 'Address must include a valid postcode (5 digits)';
                            }
                            return null;
                          },
                        ),
                        _buildTextFormField(
                          controller: positionController,
                          labelText: 'Position',
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please enter the position'
                              : null,
                        ),
                        _buildTextFormField(
                          controller: joiningDateController,
                          labelText: 'Joining Date',
                          hintText: 'YYYY-MM-DD',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the joining date';
                            }
                            if (!RegExp(r'^\d{4}-\d{2}-\d{2}$')
                                .hasMatch(value)) {
                              return 'Joining Date must be in YYYY-MM-DD format';
                            }
                            return null;
                          },
                        ),
                        _buildTextFormField(
                          controller: employmentStatusController,
                          labelText: 'Employment Status',
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please enter the employment status'
                              : null,
                        ),
                        _buildTextFormField(
                          controller: salaryController,
                          labelText: 'Salary',
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please enter the salary'
                              : null,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 16.0),
                          child: Text('Assign Classes',
                              style: TextStyle(
                                  fontSize: 16.0, color: Colors.white)),
                        ),
                        _buildCheckboxListTile(
                            'Year 4', selectedClasses, setState),
                        _buildCheckboxListTile(
                            'Year 5', selectedClasses, setState),
                        _buildCheckboxListTile(
                            'Year 6', selectedClasses, setState),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            TextButton(
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 16.0),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            const SizedBox(width: 8),
                            TextButton(
                              child: const Text(
                                'Save',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              onPressed: () async {
                                if (_editFormKey.currentState?.validate() ??
                                    false) {
                                  try {
                                    await DatabaseService().editTeacher(
                                      teacher.id,
                                      {
                                        'name': nameController.text,
                                        'dateOfBirth':
                                            dateOfBirthController.text,
                                        'gender': genderController.text,
                                        'idNumber': idNumberController.text,
                                        'contactInfo': {
                                          'phoneNumber':
                                              phoneNumberController.text,
                                          'email': emailController.text,
                                          'homeAddress':
                                              homeAddressController.text,
                                        },
                                        'employmentInfo': {
                                          'position': positionController.text,
                                          'joiningDate':
                                              joiningDateController.text,
                                          'employmentStatus':
                                              employmentStatusController.text,
                                          'salary': salaryController.text,
                                        },
                                        'assignedClasses': selectedClasses,
                                        'profileImage': newProfileImageUrl ??
                                            teacher
                                                .profileImage, // Save new image URL or keep old one
                                      },
                                    );
                                    Navigator.of(context)
                                        .pop(); // Close the dialog
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Teacher edited successfully')),
                                    );
                                  } catch (e) {
                                    print('Failed to edit teacher: $e');
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    String? hintText,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: const TextStyle(color: Colors.white),
          hintText: hintText,
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
          ),
        ),
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
      ),
    );
  }

  Widget _buildCheckboxListTile(
      String className, List<String> selectedClasses, StateSetter setState) {
    return CheckboxListTile(
      title: Text(
        className,
        style: const TextStyle(color: Colors.white),
      ),
      value: selectedClasses.contains(className),
      onChanged: (bool? value) {
        setState(() {
          if (value == true) {
            selectedClasses.add(className);
          } else {
            selectedClasses.remove(className);
          }
        });
      },
      checkColor: Colors.black,
      activeColor: Colors.white,
    );
  }

  void _showDeleteDialog(BuildContext context, Teacher teacher) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          backgroundColor: Colors.black.withOpacity(0.7),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Delete Teacher',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16.0),
                Text(
                  'Are you sure you want to delete ${teacher.name}?',
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    TextButton(
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16.0,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    const SizedBox(width: 8.0),
                    TextButton(
                      child: const Text(
                        'Delete',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () async {
                        try {
                          await DatabaseService().deleteTeacher(teacher.id);
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Teacher deleted successfully'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } catch (e) {
                          print('Failed to delete teacher: $e');
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
