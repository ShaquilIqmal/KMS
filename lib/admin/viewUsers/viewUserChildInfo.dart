import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../service/cloudinary_service.dart';
import '../../service/database_service.dart';
import '../../service/zmodel/childmodel.dart';
import '../../service/zmodel/usermodel.dart';
import 'viewUserInfoPage.dart'; // Adjust based on your project structure

class ViewUserChildInfoPage extends StatefulWidget {
  final Child child;
  final User user;

  const ViewUserChildInfoPage(
      {Key? key, required this.child, required this.user})
      : super(key: key);

  @override
  _ViewUserChildInfoPageState createState() => _ViewUserChildInfoPageState();
}

class _ViewUserChildInfoPageState extends State<ViewUserChildInfoPage> {
  late Child child;
  final ImagePicker _picker = ImagePicker();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    child = widget.child;
    fetchUpdatedChildData(widget.child.id).then((fetchedChild) {
      setState(() {
        child = fetchedChild;
      });
    }).catchError((error) {
      // Handle error if needed
      print('Error fetching child data: $error');
    });
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
      String imageUrl = await _cloudinaryService.uploadImage(filePath);
      return imageUrl;
    } catch (e) {
      print("Error uploading image: $e");
      return '';
    }
  }

  Future<void> _updateProfileImage(String imageUrl) async {
    try {
      await FirebaseFirestore.instance.collection('child').doc(child.id).update(
          {'profileImage': imageUrl}); // Save directly under child document
      setState(() {
        child.profileImage = imageUrl; // Update local state for display
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

  Future<Child> fetchUpdatedChildData(String childId) async {
    DocumentSnapshot doc =
        await FirebaseFirestore.instance.collection('child').doc(childId).get();

    if (doc.exists) {
      return Child.fromDocument(doc);
    } else {
      throw Exception('Child not found');
    }
  }

  void refreshChildData() async {
    try {
      final updatedChild = await fetchUpdatedChildData(child.id);
      setState(() {
        child = updatedChild; // Update the local state with the new data
      });
      // Show success dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Success'),
            content: const Text('Child data has been successfully updated!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching updated data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => UserInformationPage(
                        user: widget.user,
                      )));
            },
          ),
          title: Text(
            child.sectionA['nameC'] ?? 'Child Details',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          backgroundColor: Colors.grey[100],
          centerTitle: true,
          actions: [
            Visibility(
              visible: false,
              child: IconButton(
                onPressed: refreshChildData, // Refresh data when icon pressed
                icon: const Icon(Icons.refresh, color: Colors.black),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: _pickImage, // Change image on tap
                        child: CircleAvatar(
                          radius: 60, // Adjust the radius as needed
                          backgroundImage: child.profileImage != null &&
                                  child.profileImage!.isNotEmpty
                              ? NetworkImage(child.profileImage!)
                              : null,
                          backgroundColor: Colors.grey[300],
                          child: child.profileImage == null ||
                                  child.profileImage!.isEmpty
                              ? const Icon(Icons.child_care,
                                  size: 50, color: Colors.white)
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
                const SizedBox(height: 16),
                TabBar(
                  isScrollable: true,
                  indicatorColor: Colors.grey[800],
                  labelColor: Colors.grey[800],
                  labelStyle: const TextStyle(fontWeight: FontWeight.w800),
                  unselectedLabelColor: Colors.grey,
                  indicatorPadding: EdgeInsets.zero,
                  tabs: const [
                    Tab(text: "Child's Info"),
                    Tab(text: "Guardian's Info"),
                    Tab(text: "Medical Info"),
                    Tab(text: "Emergency Contact"),
                    Tab(text: "Transport Needs"),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 800, // Height to allow scrolling within tabs
                  child: TabBarView(
                    children: [
                      _buildSectionA('Section A: Child\'s Particulars',
                          child.sectionA, context, 'A'),
                      _buildSectionB('Section B: Guardian\'s Particulars',
                          child.sectionB, context, 'B'),
                      _buildSectionC('Section C: Medical Information',
                          child.sectionC, context, 'C'),
                      _buildSectionD('Section D: Emergency Contact',
                          child.sectionD, context, 'D'),
                      _buildSectionE('Section E: Transportation Needs',
                          child.sectionE, context, 'E'),
                    ],
                  ),
                ),
                if (_isUploading)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionA(String title, Map<String, dynamic> details,
      BuildContext context, String section) {
    return _buildSection(title, details, context, section, [
      {'label': 'Child Name', 'key': 'nameC'},
      {'label': 'Year', 'key': 'yearID'},
      {'label': 'My Kid', 'key': 'myKidC'},
      {'label': 'Gender', 'key': 'genderC'},
      {'label': 'Date Of Birth', 'key': 'dateOfBirthC'},
      {'label': 'Address', 'key': 'addressC'},
      {'label': 'Religion', 'key': 'religionC'},
    ]);
  }

  Widget _buildSectionB(String title, Map<String, dynamic> details,
      BuildContext context, String section) {
    return _buildSection(title, details, context, section, [
      {'label': 'Name', 'key': 'nameF'},
      {'label': 'Address', 'key': 'addressF'},
      {'label': 'Email', 'key': 'emailF'},
      {'label': 'Tel No', 'key': 'handphoneF'},
      {'label': 'Home Tel No', 'key': 'homeTelF'},
      {'label': 'IC', 'key': 'icF'},
      {'label': 'Income', 'key': 'incomeF'},
    ]);
  }

  Widget _buildSectionC(String title, Map<String, dynamic> details,
      BuildContext context, String section) {
    return _buildSection(title, details, context, section, [
      {'label': 'Clinic/Hospital Name', 'key': 'clinicHospital'},
      {'label': 'Doctor Tel', 'key': 'doctorTel'},
      {'label': 'Medical Condition', 'key': 'medicalCondition'},
    ]);
  }

  Widget _buildSectionD(String title, Map<String, dynamic> details,
      BuildContext context, String section) {
    return _buildSection(title, details, context, section, [
      {'label': 'Name', 'key': 'nameM'},
      {'label': 'Relationship', 'key': 'relationshipM'},
      {'label': 'Emergency Tel', 'key': 'telM'},
    ]);
  }

  Widget _buildSectionE(String title, Map<String, dynamic> details,
      BuildContext context, String section) {
    return _buildSection(title, details, context, section, [
      {'label': 'Drop Address', 'key': 'dropAddress'},
      {'label': 'Pickup Address', 'key': 'pickupAddress'},
      {'label': 'Transportation', 'key': 'transportation'},
    ]);
  }

  Widget _buildSection(String title, Map<String, dynamic> details,
      BuildContext context, String section, List<Map<String, String>> fields) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 4,
      color: Colors.grey[100],
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...fields.map((field) =>
                _buildDetailRow(field['label']!, details[field['key']])),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
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
                onPressed: () {
                  _showEditDialog(
                      context, widget.child.id, details, section, fields);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 24.0),
                ),
                child: const Text(
                  'Edit',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            _getIconForLabel(label),
            color: Colors.blueGrey[700],
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForLabel(String label) {
    switch (label) {
      case 'Child Name':
        return Icons.child_care;
      case 'Year':
        return Icons.calendar_today;
      case 'My Kid':
        return Icons.badge;
      case 'Gender':
        return Icons.wc;
      case 'Date Of Birth':
        return Icons.cake;
      case 'Address':
        return Icons.home;
      case 'Name':
        return Icons.person;
      case 'Email':
        return Icons.email;
      case 'Tel No':
        return Icons.phone;
      case 'Home Tel No':
        return Icons.home_filled;
      case 'IC':
        return Icons.credit_card;
      case 'Income':
        return Icons.money;
      case 'Clinic/Hospital Name':
        return Icons.local_hospital;
      case 'Doctor Tel':
        return Icons.local_phone;
      case 'Medical Condition':
        return Icons.medical_services;
      case 'Relationship':
        return Icons.family_restroom;
      case 'Emergency Tel':
        return Icons.phone_in_talk;
      case 'Drop Address':
        return Icons.location_on;
      case 'Pickup Address':
        return Icons.location_on;
      case 'Transportation':
        return Icons.directions_bus;
      default:
        return Icons.info_outline;
    }
  }

  void _showEditDialog(
      BuildContext context,
      String childId,
      Map<String, dynamic> details,
      String section,
      List<Map<String, String>> fields) {
    final controllers = {
      for (var field in fields)
        field['key']!: TextEditingController(text: details[field['key']])
    };

    String? selectedGender = details['genderC'];
    String? selectedIncomeRange = details['incomeF'];
    String? selectedTransportation = details['transportation'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor:
                  Colors.black.withOpacity(0.8), // Transparent black background
              title: Text(
                'Edit Section $section',
                style: const TextStyle(color: Colors.white), // White text color
              ),
              content: SingleChildScrollView(
                child: Column(
                  children: fields.map((field) {
                    switch (field['key']) {
                      case 'dateOfBirthC':
                        return _buildDatePickerTextField(field['label']!,
                            controllers[field['key']]!, context, controllers);
                      case 'genderC':
                        return _buildGenderRadioListTile(
                            field['label']!, selectedGender, (value) {
                          setState(() {
                            selectedGender = value;
                            controllers[field['key']]!.text = value!;
                          });
                        });
                      case 'handphoneF':
                        return _buildPhoneNumberTextField(
                            field['label']!, controllers[field['key']]!);
                      case 'incomeF':
                        return _buildDropdownFormField(
                            field['label']!, selectedIncomeRange, [
                          '0-RM2000',
                          'RM2000-RM4000',
                          'RM4000-RM6000',
                          'RM6000-RM8000',
                          'RM8000 and above'
                        ], (value) {
                          setState(() {
                            selectedIncomeRange = value;
                            controllers[field['key']]!.text = value!;
                          });
                        });
                      case 'transportation':
                        return _buildTransportationRadioListTile(
                            field['label']!, selectedTransportation, (value) {
                          setState(() {
                            selectedTransportation = value;
                            controllers[field['key']]!.text = value!;
                          });
                        });
                      case 'yearID': // Year field should be uneditable
                        return _buildUneditableYearTextField(
                            field['label']!, controllers[field['key']]!);
                      case 'addressC':
                        return _buildDialogTextField(
                            field['label']!, controllers[field['key']]!,
                            validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return "Please enter child's address";
                          } else if (!RegExp(r'\b\d{5}\b').hasMatch(value!)) {
                            // 5 digits anywhere in the text
                            return "Address must include a valid postcode (5 digits)";
                          }
                          return null;
                        });
                      case 'myKidC':
                        return _buildDialogTextField(
                            field['label']!, controllers[field['key']]!,
                            validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return "Please enter child's myKid number";
                          } else if (!RegExp(r'^\d{12}$').hasMatch(value!)) {
                            // Check for exactly 12 digits
                            return "myKid No. must be exactly 12 digits long and contain only numbers";
                          }
                          return null;
                        });
                      case 'dropAddress':
                      case 'pickupAddress':
                        return _buildDialogTextField(
                            field['label']!, controllers[field['key']]!,
                            enabled: false);
                      default:
                        return _buildDialogTextField(
                            field['label']!, controllers[field['key']]!);
                    }
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel',
                      style: TextStyle(color: Colors.white)),
                ),
                Container(
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
                    onPressed: () async {
                      if (_validateFields(controllers)) {
                        Map<String, dynamic> updatedDetails = {};
                        for (var field in fields) {
                          updatedDetails[field['key']!] =
                              controllers[field['key']]!.text;
                        }
                        await _saveUpdatedDetails(
                            childId, updatedDetails, section);
                        refreshChildData(); // Refresh the data
                        Navigator.of(context).pop(); // Close the dialog
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Please fill in all required fields')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 24.0),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  bool _validateFields(Map<String, TextEditingController> controllers) {
    for (var controller in controllers.values) {
      if (controller.text.isEmpty) {
        return false;
      }
    }
    return true;
  }

  Widget _buildUneditableYearTextField(
      String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        enabled: false, // Make the text field uneditable
        style: const TextStyle(color: Colors.white), // White text color
        decoration: InputDecoration(
          labelText: label,
          labelStyle:
              const TextStyle(color: Colors.white70), // Light grey label
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: Colors.white70),
          ),
        ),
      ),
    );
  }

  Widget _buildDialogTextField(String label, TextEditingController controller,
      {String? Function(String?)? validator, bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white), // White text color
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          labelStyle:
              const TextStyle(color: Colors.white70), // Light grey label
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: Colors.white70),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: Colors.white),
          ),
          errorText: validator != null ? validator(controller.text) : null,
        ),
      ),
    );
  }

  Widget _buildDatePickerTextField(
      String label,
      TextEditingController controller,
      BuildContext context,
      Map<String, TextEditingController> controllers) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: () async {
          DateTime now = DateTime.now();
          DateTime initialDate = now.subtract(const Duration(days: 365 * 5));
          DateTime firstDate = now.subtract(const Duration(days: 365 * 7));
          DateTime lastDate = now.subtract(const Duration(days: (365 * 4) + 1));

          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: initialDate,
            firstDate: firstDate,
            lastDate: lastDate,
          );

          if (pickedDate != null) {
            controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
            _calculateAgeAndYear(pickedDate, controllers);
          }
        },
        child: AbsorbPointer(
          child: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white), // White text color
            decoration: InputDecoration(
              labelText: label,
              labelStyle:
                  const TextStyle(color: Colors.white70), // Light grey label
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
        ),
      ),
    );
  }

  void _calculateAgeAndYear(
      DateTime birthDate, Map<String, TextEditingController> controllers) {
    int age = DateTime.now().year - birthDate.year;
    if (DateTime.now().month < birthDate.month ||
        (DateTime.now().month == birthDate.month &&
            DateTime.now().day < birthDate.day)) {
      age--;
    }
    String yearID = 'Year $age';

    // Ensure the controllers are initialized
    if (controllers.containsKey('yearID') && controllers['yearID'] != null) {
      controllers['yearID']!.text = yearID;
    }
    if (controllers.containsKey('age') && controllers['age'] != null) {
      controllers['age']!.text = age.toString();
    }
  }

  Widget _buildGenderRadioListTile(
      String label, String? groupValue, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white70)), // Light grey label
        RadioListTile<String>(
          title: const Text('Male', style: TextStyle(color: Colors.white)),
          value: 'Male',
          groupValue: groupValue,
          onChanged: onChanged,
        ),
        RadioListTile<String>(
          title: const Text('Female', style: TextStyle(color: Colors.white)),
          value: 'Female',
          groupValue: groupValue,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildPhoneNumberTextField(
      String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.phone, // Use numeric keyboard
        style: const TextStyle(color: Colors.white), // White text color
        decoration: InputDecoration(
          labelText: label,
          labelStyle:
              const TextStyle(color: Colors.white70), // Light grey label
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
    );
  }

  Widget _buildDropdownFormField(String label, String? value,
      List<String> items, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: value,
        onChanged: onChanged,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle:
              const TextStyle(color: Colors.white70), // Light grey label
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: Colors.white70),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: Colors.white),
          ),
        ),
        dropdownColor: Colors.black.withOpacity(0.8),
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item, style: const TextStyle(color: Colors.white)),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTransportationRadioListTile(
      String label, String? groupValue, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white70)), // Light grey label
        RadioListTile<String>(
          title: const Text('Own', style: TextStyle(color: Colors.white)),
          value: 'Own',
          groupValue: groupValue,
          onChanged: onChanged,
        ),
        RadioListTile<String>(
          title: const Text('School\'s', style: TextStyle(color: Colors.white)),
          value: 'School\'s',
          groupValue: groupValue,
          onChanged: null, // Disable the School's radio button
        ),
      ],
    );
  }

  Future<void> _saveUpdatedDetails(String childId,
      Map<String, dynamic> updatedDetails, String section) async {
    Map<String, dynamic> sectionData = {};

    switch (section) {
      case 'A':
        sectionData = {
          'SectionA': {
            'nameC': updatedDetails['nameC'],
            'yearID': updatedDetails['yearID'],
            'myKidC': updatedDetails['myKidC'],
            'genderC': updatedDetails['genderC'],
            'dateOfBirthC': updatedDetails['dateOfBirthC'],
            'addressC': updatedDetails['addressC'],
            'religionC': updatedDetails['religionC'],
          }
        };
        break;
      case 'B':
        sectionData = {
          'SectionB': {
            'nameF': updatedDetails['nameF'],
            'addressF': updatedDetails['addressF'],
            'emailF': updatedDetails['emailF'],
            'handphoneF': updatedDetails['handphoneF'],
            'homeTelF': updatedDetails['homeTelF'],
            'icF': updatedDetails['icF'],
            'incomeF': updatedDetails['incomeF'],
          }
        };
        break;
      case 'C':
        sectionData = {
          'SectionC': {
            'clinicHospital': updatedDetails['clinicHospital'],
            'doctorTel': updatedDetails['doctorTel'],
            'medicalCondition': updatedDetails['medicalCondition'],
          }
        };
        break;
      case 'D':
        sectionData = {
          'SectionD': {
            'nameM': updatedDetails['nameM'],
            'relationshipM': updatedDetails['relationshipM'],
            'telM': updatedDetails['telM'],
          }
        };
        break;
      case 'E':
        sectionData = {
          'SectionE': {
            'dropAddress': updatedDetails['dropAddress'],
            'pickupAddress': updatedDetails['pickupAddress'],
            'transportation': updatedDetails['transportation'],
          }
        };
        break;
    }

    await DatabaseService().updateChildDetails(childId, sectionData);
  }
}
