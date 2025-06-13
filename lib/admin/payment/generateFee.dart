import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kms2/service/database_service.dart';

class GenerateFeesPage extends StatefulWidget {
  final String adminDocId;

  const GenerateFeesPage({Key? key, required this.adminDocId})
      : super(key: key);

  @override
  _GenerateFeesPageState createState() => _GenerateFeesPageState();
}

class _GenerateFeesPageState extends State<GenerateFeesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DatabaseService _databaseService = DatabaseService();
  List<DocumentSnapshot> _feesList = [];
  List<String> _selectedFees = [];
  List<DocumentSnapshot> _childrenList = [];
  List<String> _selectedChildren = [];
  String? _selectedYear = 'Year 4'; // Set default year
  bool _selectAll = false;
  bool _isLoadingFees = true;
  bool _isLoadingChildren = false;

  @override
  void initState() {
    super.initState();
    _fetchFees();
    _fetchChildren(_selectedYear!); // Fetch children for Year 4
  }

  Future<void> _fetchFees() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('fees').get();
      setState(() {
        _feesList = snapshot.docs;
        _isLoadingFees = false;
      });
    } catch (e) {
      _showErrorSnackBar('Error fetching fees: $e');
    }
  }

  Future<void> _fetchChildren(String yearID) async {
    setState(() {
      _isLoadingChildren = true; // Start loading
    });

    try {
      QuerySnapshot snapshot = await _firestore
          .collection('child')
          .where('SectionA.yearID', isEqualTo: yearID)
          .get();

      List<Map<String, dynamic>> processedChildren = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;

        // Safely retrieve profileImage using null-aware operators
        String? profileImage = data['profileImage'] != null
            ? data['profileImage'] as String
            : null;

        return {
          ...data, // Include all other fields
          'profileImage':
              profileImage ?? '', // Default to an empty string if null
        };
      }).toList();

      setState(() {
        _childrenList = snapshot.docs; // Store the original document snapshots
        _selectedChildren.clear();
        _selectAll = false;
        _isLoadingChildren = false; // Stop loading
      });

      // Debug output to verify children processing
      print(processedChildren);
    } catch (e) {
      _showErrorSnackBar('Error fetching children: $e');
      setState(() {
        _isLoadingChildren = false; // Stop loading
      });
    }
  }

  void _toggleSelectAll() {
    setState(() {
      _selectAll = !_selectAll;
      _selectedChildren.clear();
      if (_selectAll) {
        _selectedChildren.addAll(_childrenList.map((child) => child.id));
      }
    });
  }

  Future<void> _generateFeesForSelectedChildren() async {
    if (_selectedFees.isEmpty) {
      _showSelectFeesDialog();
      return;
    }

    if (_selectedChildren.isEmpty) {
      _showSelectChildrenDialog();
      return;
    }

    DateTime dueDate = DateTime.now().add(const Duration(days: 10));
    String formattedDueDate = DateFormat('yyyy-MM-dd').format(dueDate);

    List<String> successfullyGeneratedChildIds = []; // List to store child IDs
    List<String> userIdsToNotify =
        []; // List to store user IDs for notifications

    for (var child in _childrenList
        .where((child) => _selectedChildren.contains(child.id))) {
      for (var feeId in _selectedFees) {
        DocumentSnapshot paymentSnapshot = await _firestore
            .collection('child')
            .doc(child.id)
            .collection('payments')
            .doc(feeId)
            .get();

        if (paymentSnapshot.exists) {
          _showErrorSnackBar(
              'Fee $feeId already exists for ${child['SectionA']['nameC']}!');
        } else {
          var fee = _feesList.firstWhere((fee) => fee.id == feeId);
          await _firestore
              .collection('child')
              .doc(child.id)
              .collection('payments')
              .doc(feeId)
              .set({
            'feeType': fee['feeType'],
            'amount': fee['amount'],
            'category': fee['category'],
            'dueDate': formattedDueDate,
            'paid': false,
          });

          successfullyGeneratedChildIds.add(child.id); // Add ID to the list

          // Check for matches in users collection
          QuerySnapshot userSnapshot = await _firestore
              .collection('users')
              .where('childIds', arrayContains: child.id)
              .get();

          for (var userDoc in userSnapshot.docs) {
            print('Matching user document ID: ${userDoc.id}');
            userIdsToNotify
                .add(userDoc.id); // Collect user IDs for notifications

            // Create a personalized message for the notification
            String childName =
                child['SectionA']['nameC']; // Get the child's name
            String message =
                'Fees have been generated for your child, $childName.';

            // Send notification
            await _databaseService.sendNotification(
              adminDocId: 'GENERATED', // Replace with actual admin ID
              userIds: [userDoc.id], // Send to the specific user
              title: 'New Fees Generated',
              message: message,
            );
          }
        }
      }
    }

    if (successfullyGeneratedChildIds.isNotEmpty) {
      print(
          'Successfully generated fees for children with IDs: $successfullyGeneratedChildIds');
    }

    _showSuccessSnackBar(
        'Fees generated for selected children in $_selectedYear!');
  }

  void _showSelectFeesDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor:
              Colors.black.withOpacity(0.8), // Black transparent background
          title: const Text(
            'No Fees Selected',
            style: TextStyle(
              color: Colors.white, // White text color
            ),
          ),
          content: const Text(
            'Please select fees to add to the selected children.',
            style: TextStyle(
              color: Colors.white, // White text color
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Colors.white, // White text color
                ),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        );
      },
    );
  }

  void _showSelectChildrenDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor:
              Colors.black.withOpacity(0.8), // Black transparent background
          title: const Text(
            'No Children Selected',
            style: TextStyle(
              color: Colors.white, // White text color
            ),
          ),
          content: const Text(
            'Please select children to add the fees to.',
            style: TextStyle(
              color: Colors.white, // White text color
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Colors.white, // White text color
                ),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        );
      },
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Generate Fees',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fees Section
              _buildSectionTitle('Select Fees:'),
              const SizedBox(height: 8.0),
              _buildFeesContainer(),

              const SizedBox(height: 20),

              // Year Selection Buttons
              _buildSectionTitle('Select Year:'),
              const SizedBox(height: 8.0),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildYearButton('Year 4'),
                    const SizedBox(width: 5), // Closer spacing
                    _buildYearButton('Year 5'),
                    const SizedBox(width: 5), // Closer spacing
                    _buildYearButton('Year 6'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Children Section
              _buildSectionTitle('Select Children:'),
              const SizedBox(height: 10), // Spacing for visual clarity
              _buildChildrenContainer(),

              const SizedBox(height: 20),

              // Generate Fees Button
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: _buildGenerateFeesButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge!.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
    );
  }

  Widget _buildFeesContainer() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.3,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: _isLoadingFees
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: _feesList.length,
                itemBuilder: (context, index) {
                  final fee = _feesList[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: CheckboxListTile(
                      title: Text(
                        fee['feeType'],
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      value: _selectedFees.contains(fee.id),
                      onChanged: (bool? selected) {
                        setState(() {
                          if (selected == true) {
                            _selectedFees.add(fee.id);
                          } else {
                            _selectedFees.remove(fee.id);
                          }
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: Colors.black,
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildChildrenContainer() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Select All'),
                  Checkbox(
                    value: _selectAll,
                    onChanged: (bool? selected) {
                      setState(() {
                        _toggleSelectAll();
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            if (_isLoadingChildren)
              const Center(child: CircularProgressIndicator())
            else if (_childrenList.isEmpty)
              Center(
                child: Text(
                  'No children found for this year.',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              )
            else
              SizedBox(
                height: 200,
                child: ListView.builder(
                  itemCount: _childrenList.length,
                  itemBuilder: (context, index) {
                    final childData =
                        _childrenList[index].data() as Map<String, dynamic>;
                    final String childId = _childrenList[index]
                        .id; // Ensure we get the document ID

                    // Safely retrieve profileImage with default fallback
                    String? profileImage = childData['profileImage'] as String?;

                    // Use a fallback if profileImage is null or empty
                    String imageUrl =
                        (profileImage != null && profileImage.isNotEmpty)
                            ? profileImage
                            : 'assets/placeholder.png';

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            spreadRadius: 2,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: CheckboxListTile(
                        secondary: CircleAvatar(
                          backgroundImage: imageUrl.startsWith('assets/')
                              ? AssetImage(imageUrl) as ImageProvider
                              : NetworkImage(imageUrl),
                          radius: 20,
                        ),
                        title:
                            Text(childData['SectionA']['nameC'] ?? 'No Name'),
                        value: _selectedChildren.contains(childId),
                        onChanged: (bool? selected) {
                          setState(() {
                            if (selected == true) {
                              _selectedChildren.add(childId);
                            } else {
                              _selectedChildren.remove(childId);
                            }
                            print(
                                'Updated Selected Children: $_selectedChildren'); // Debugging
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: Colors.grey[800],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenerateFeesButton() {
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
          onPressed: _generateFeesForSelectedChildren,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24.0),
            ),
            padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
          ),
          child: const Text(
            'Add Fees to Selected Children',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildYearButton(String year) {
    bool isSelected = _selectedYear == year;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0), // Rounded corners
        ),
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
        backgroundColor: isSelected
            ? Colors.black.withOpacity(0.1)
            : Colors.white, // Background color for selected state
      ),
      onPressed: () {
        _fetchChildren(year);
        setState(() {
          _selectedYear = year;
        });
      },
      child: Text(
        year,
        style: TextStyle(
          color: isSelected ? Colors.black : Colors.black87,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
