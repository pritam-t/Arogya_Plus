import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../Provider/Dashboard/DashboardProvider.dart';
import '../../data/local/db_helper.dart';

class UserSetting_Screen extends StatefulWidget {
  const UserSetting_Screen({super.key});

  @override
  State<UserSetting_Screen> createState() => _UserSetting_ScreenState();
}

class _UserSetting_ScreenState extends State<UserSetting_Screen>
    with TickerProviderStateMixin {
  Map<String, dynamic>? userinfo;
  final DBHelper dbref = DBHelper.getInstance;
  bool isEditing = false;
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  late AnimationController _fadeController;
  late AnimationController _scaleController;

  // Controllers for editable fields
  late TextEditingController nameController;
  late TextEditingController ageController;
  late TextEditingController genderController;
  late TextEditingController heightController;
  late TextEditingController weightController;
  late TextEditingController bloodController;

  // Health data
  List<Map<String, dynamic>> healthIssues = [];
  List<Map<String, dynamic>> allergies = [];
  List<Map<String, dynamic>> emergencyContacts = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeAnimations();
    loadUserData();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fadeController.forward();
  }

  void _initializeControllers() {
    nameController = TextEditingController();
    ageController = TextEditingController();
    genderController = TextEditingController();
    heightController = TextEditingController();
    weightController = TextEditingController();
    bloodController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    genderController.dispose();
    heightController.dispose();
    weightController.dispose();
    bloodController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> loadUserData() async {
    try {
      final users = await dbref.getUsers();
      final healthData = await dbref.getAllHealthIssues();
      final allergyData = await dbref.getAllAllergies();
      final contactData = await dbref.getAllEmergencyContacts();

      setState(() {
        if (users.isNotEmpty) {
          userinfo = users.first;
          _updateControllers();
          _loadProfileImage();
        }
        healthIssues = healthData;
        allergies = allergyData;
        emergencyContacts = contactData;
        isLoading = false;
      });
    } catch (e) {
      print("Error loading data: $e");
      _showSnackBar("Error loading data", isError: true);
      setState(() {
        isLoading = false;
      });
    }
  }

  void _updateControllers() {
    if (userinfo != null) {
      nameController.text = userinfo![DBHelper.COL_NAME] ?? '';
      ageController.text = userinfo![DBHelper.COL_AGE]?.toString() ?? '';
      genderController.text = userinfo![DBHelper.COL_GENDER] ?? '';
      heightController.text = userinfo![DBHelper.COL_HEIGHT]?.toString() ?? '';
      weightController.text = userinfo![DBHelper.COL_WEIGHT]?.toString() ?? '';
      bloodController.text = userinfo![DBHelper.COL_BLOOD] ?? '';
    }
  }

  void _loadProfileImage() {
    final imagePath = userinfo?[DBHelper.COL_PROFILE_IMAGE];
    if (imagePath != null && File(imagePath).existsSync()) {
      _profileImage = File(imagePath);
    }
  }

  Future<String?> _saveImageToAppDirectory(File imageFile) async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String newPath = '${appDir.path}/$fileName';

      // Copy the file to app's directory
      final File newImage = await imageFile.copy(newPath);
      return newImage.path;
    } catch (e) {
      print('Error saving image: $e');
      return null;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 512,
        maxHeight: 512,
      );

      if (image != null && userinfo != null) {
        final File tempImage = File(image.path);
        final String? savedPath = await _saveImageToAppDirectory(tempImage);

        if (savedPath != null) {
          setState(() {
            _profileImage = File(savedPath);
          });

          await dbref.updateUserProfileImage(
            id: userinfo![DBHelper.COL_ID],
            profileImage: savedPath, // Now this is a permanent path
          );
          Provider.of<DashboardProvider>(context, listen: false).loadAllData();
          loadUserData();

          _showSnackBar("Profile picture updated successfully!");
        } else {
          _showSnackBar("Error saving image", isError: true);
        }
      }
    } catch (e) {
      print("Error picking image: $e");
      _showSnackBar("Error selecting image", isError: true);
    }
  }

  Future<void> _removeProfileImage() async {
    if (userinfo != null) {
      setState(() {
        _profileImage = null;
      });

      await dbref.updateUserProfileImage(
        id: userinfo![DBHelper.COL_ID],
        profileImage: null,
      );

      _showSnackBar("Profile picture removed");
    }
  }

  Future<void> _saveChanges() async {
    if (userinfo == null) return;

    try {
      final age = int.tryParse(ageController.text);
      final height = int.tryParse(heightController.text);
      final weight = int.tryParse(weightController.text);

      if (age == null || age <= 0) {
        _showSnackBar("Please enter a valid age", isError: true);
        return;
      }
      if (height == null || height <= 0) {
        _showSnackBar("Please enter a valid height", isError: true);
        return;
      }
      if (weight == null || weight <= 0) {
        _showSnackBar("Please enter a valid weight", isError: true);
        return;
      }
      if (nameController.text.trim().isEmpty) {
        _showSnackBar("Name cannot be empty", isError: true);
        return;
      }

      await dbref.updateUser(
        id: userinfo![DBHelper.COL_ID],
        name: nameController.text.trim(),
        age: age,
        gender: genderController.text.trim(),
        height: height,
        weight: weight,
        blood: bloodController.text.trim(),
        profileImage: _profileImage?.path,
      );

      setState(() {
        isEditing = false;
      });

      Provider.of<DashboardProvider>(context, listen: false).loadAllData();
      await loadUserData();
      _showSnackBar("Profile updated successfully!");
    } catch (e) {
      print("Error updating user: $e");
      _showSnackBar("Error updating profile", isError: true);
    }
  }

  // Health Issues Methods
  Future<void> _addHealthIssue() async {
    final result = await _showTextInputDialog(
      title: "Add Health Issue",
      hintText: "Enter health issue...",
    );
    if (result != null && result.isNotEmpty) {
      await dbref.addHealthIssue(healthIssue: result);
      Provider.of<DashboardProvider>(context, listen: false).loadAllData();
      loadUserData();
      _showSnackBar("Health issue added successfully!");
    }
  }

  Future<void> _deleteHealthIssue(int id) async {
    await dbref.deleteHealthIssue(id: id);
    Provider.of<DashboardProvider>(context, listen: false).loadAllData();
    loadUserData();
    _showSnackBar("Health issue removed");
  }

  // Allergy Methods
  Future<void> _addAllergy() async {
    final result = await _showAllergyDialog();
    if (result != null) {
      await dbref.addAllergy(
        allergyName: result['name'],
        severity: result['severity'],
      );
      Provider.of<DashboardProvider>(context, listen: false).loadAllData();
      loadUserData();
      _showSnackBar("Allergy added successfully!");
    }
  }

  Future<void> _deleteAllergy(int id) async {
    await dbref.deleteAllergy(id: id);
    Provider.of<DashboardProvider>(context, listen: false).loadAllData();
    loadUserData();
    _showSnackBar("Allergy removed");
  }

  Future<void> _addEmergencyContact() async {
    final result = await _showEmergencyContactDialog();
    if (result != null) {
      await dbref.addEmergencyContact(
        contactName: result['name'],
        phoneNumber: result['phone'],
        relationship: result['relationship'],
        isPrimary: result['isPrimary'],
      );
      Provider.of<DashboardProvider>(context, listen: false).loadAllData();
      loadUserData();
      _showSnackBar("Emergency contact added successfully!");
    }
  }

  Future<void> _editEmergencyContact(Map<String, dynamic> contact) async {
    final result = await _showEmergencyContactDialog(contact: contact);
    if (result != null) {
      await dbref.updateEmergencyContact(
        id: contact[DBHelper.COL_EMERGENCY_ID],
        contactName: result['name'],
        phoneNumber: result['phone'],
        relationship: result['relationship'],
        isPrimary: result['isPrimary'],
      );
      Provider.of<DashboardProvider>(context, listen: false).loadAllData();

      loadUserData();
      _showSnackBar("Emergency contact updated successfully!");
    }
  }

  Future<void> _deleteEmergencyContact(int id) async {
    await dbref.deleteEmergencyContact(id: id);
    Provider.of<DashboardProvider>(context, listen: false).loadAllData();
    loadUserData();
    _showSnackBar("Emergency contact removed");
  }

  // Dialog Methods
  Future<String?> _showTextInputDialog({
    required String title,
    required String hintText,
    String? initialValue,
  }) async
  {
    final controller = TextEditingController(text: initialValue);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: hintText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>?> _showAllergyDialog() async {
    final nameController = TextEditingController();
    String severity = 'Mild';

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Add Allergy"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(hintText: "Allergy name..."),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: severity,
                decoration: const InputDecoration(labelText: "Severity"),
                items: ['Mild', 'Moderate', 'Severe']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (value) => setState(() => severity = value!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, {
                'name': nameController.text,
                'severity': severity,
              }),
              child: const Text("Add"),
            ),
          ],
        ),
      ),
    );
  }

  Future<Map<String, dynamic>?> _showEmergencyContactDialog({
    Map<String, dynamic>? contact,
  }) async
  {
    final nameController = TextEditingController(
        text: contact?[DBHelper.COL_EMERGENCY_NAME] ?? '');
    final phoneController = TextEditingController(
        text: contact?[DBHelper.COL_EMERGENCY_PHONE] ?? '');
    final relationshipController = TextEditingController(
        text: contact?[DBHelper.COL_EMERGENCY_RELATIONSHIP] ?? '');
    bool isPrimary = contact?[DBHelper.COL_EMERGENCY_IS_PRIMARY] == 1;

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(contact == null ? "Add Emergency Contact" : "Edit Emergency Contact"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(hintText: "Contact name..."),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(hintText: "Phone number..."),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: relationshipController,
                decoration: const InputDecoration(hintText: "Relationship..."),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: isPrimary,
                    onChanged: (value) => setState(() => isPrimary = value!),
                  ),
                  const Text("Primary Contact"),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, {
                'name': nameController.text,
                'phone': phoneController.text,
                'relationship': relationshipController.text,
                'isPrimary': isPrimary,
              }),
              child: Text(contact == null ? "Add" : "Update"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteAccount() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.red, size: 28),
              const SizedBox(width: 10),
              const Text("Delete Account"),
            ],
          ),
          content: const Text(
            "Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently lost.",
            style: TextStyle(height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Delete", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirmed == true && userinfo != null) {
      try {
        await dbref.deleteUser(id: userinfo![DBHelper.COL_ID]);
        _showSnackBar("Account deleted successfully");
        Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
      } catch (e) {
        print("Error deleting user: $e");
        _showSnackBar("Error deleting account", isError: true);
      }
    }
  }

  Future<void> _logout() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.logout, color: Colors.orange, size: 28),
              const SizedBox(width: 10),
              const Text("Logout"),
            ],
          ),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Logout", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        _showSnackBar("Logged out successfully");
        Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
      } catch (e) {
        print("Error during logout: $e");
        _showSnackBar("Error logging out", isError: true);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error : Icons.check_circle,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red[600] : Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : userinfo == null
            ? _buildNoUserFoundWidget()
            : FadeTransition(
          opacity: _fadeController,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
            child: Column(
              children: [
                _buildProfileHeader(),
                const SizedBox(height: 20),
                _buildPersonalInfoCard(),
                const SizedBox(height: 20),
                _buildHealthInfoCard(),
                const SizedBox(height: 20),
                _buildHealthIssuesCard(),
                const SizedBox(height: 20),
                _buildAllergiesCard(),
                const SizedBox(height: 20),
                _buildEmergencyContactsCard(),
                const SizedBox(height: 30),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoUserFoundWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text(
            "No user found",
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, "/signup"),
            icon: const Icon(Icons.person_add),
            label: const Text("Create Account"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Profile Picture with Long Press
          GestureDetector(
            onLongPress: () => _showImagePickerBottomSheet(),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey[200],
                backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                child: _profileImage == null
                    ? Icon(Icons.person, size: 40, color: Colors.grey[400])
                    : null,
              ),
            ),
          ),
          const SizedBox(width: 20),
          // Name and Edit Button
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userinfo![DBHelper.COL_NAME] ?? 'Unknown User',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "${userinfo![DBHelper.COL_AGE]} years • ${userinfo![DBHelper.COL_GENDER]}",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // Small Edit Button
          IconButton(
            onPressed: () {
              if (isEditing) {
                _saveChanges();
              } else {
                setState(() {
                  isEditing = true;
                });
              }
            },
            icon: Icon(
              isEditing ? Icons.save : Icons.edit,
              color: isEditing ? Colors.green : Colors.blue,
            ),
            style: IconButton.styleFrom(
              backgroundColor: (isEditing ? Colors.green : Colors.blue).withOpacity(0.1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showImagePickerBottomSheet() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Update Profile Photo",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildImageOption(
                        icon: Icons.photo_library,
                        title: "Gallery",
                        onTap: () {
                          Navigator.pop(context);
                          _pickImage(ImageSource.gallery);
                        },
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildImageOption(
                        icon: Icons.camera_alt,
                        title: "Camera",
                        onTap: () {
                          Navigator.pop(context);
                          _pickImage(ImageSource.camera);
                        },
                      ),
                    ),
                  ],
                ),
                if (_profileImage != null) ...[
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    child: _buildImageOption(
                      icon: Icons.delete,
                      title: "Remove Photo",
                      color: Colors.red,
                      onTap: () {
                        Navigator.pop(context);
                        _removeProfileImage();
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  })
  {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Icon(icon, size: 30, color: color ?? Colors.blue),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: color ?? Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoCard() {
    return _buildInfoCard("Personal Information", [
      _buildInfoRow(Icons.person, "Name", nameController, true),
      _buildInfoRow(Icons.cake, "Age", ageController, true, TextInputType.number),
      _buildInfoRow(Icons.wc, "Gender", genderController, true),
    ]);
  }

  Widget _buildHealthInfoCard() {
    return _buildInfoCard("Health Information", [
      _buildInfoRow(Icons.height, "Height", heightController, true, TextInputType.number, "cm"),
      _buildInfoRow(Icons.monitor_weight, "Weight", weightController, true, TextInputType.number, "kg"),
      _buildInfoRow(Icons.bloodtype, "Blood Group", bloodController, true),
    ]);
  }

  Widget _buildHealthIssuesCard() {
    return _buildExpandableCard(
      title: "Current Health Issues",
      icon: Icons.medical_services,
      items: healthIssues,
      onAdd: _addHealthIssue,
      itemBuilder: (item) => _buildHealthIssueItem(item),
    );
  }

  Widget _buildAllergiesCard() {
    return _buildExpandableCard(
      title: "Current Allergies",
      icon: Icons.warning_amber,
      items: allergies,
      onAdd: _addAllergy,
      itemBuilder: (item) => _buildAllergyItem(item),
    );
  }

  Widget _buildEmergencyContactsCard() {
    return _buildExpandableCard(
      title: "Emergency Contacts",
      icon: Icons.emergency,
      items: emergencyContacts,
      onAdd: _addEmergencyContact,
      itemBuilder: (item) => _buildEmergencyContactItem(item),
    );
  }

  Widget _buildExpandableCard({
    required String title,
    required IconData icon,
    required List<Map<String, dynamic>> items,
    required VoidCallback onAdd,
    required Widget Function(Map<String, dynamic>) itemBuilder,
  })
  {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add_circle, color: Colors.green),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.green.withOpacity(0.1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
            if (items.isEmpty) ...[
              const SizedBox(height: 15),
              Center(
                child: Column(
                  children: [
                    Icon(Icons.inbox_outlined, size: 40, color: Colors.grey[400]),
                    const SizedBox(height: 10),
                    Text(
                      "No items added yet",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ] else ...[
              const SizedBox(height: 15),
              ...items.map(itemBuilder).toList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHealthIssueItem(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.medical_services, color: Colors.red[600], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              item[DBHelper.COL_HEALTH_ISSUE],
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          IconButton(
            onPressed: () => _deleteHealthIssue(item[DBHelper.COL_HEALTH_ID]),
            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildAllergyItem(Map<String, dynamic> item) {
    Color severityColor = item[DBHelper.COL_ALLERGY_SEVERITY] == 'Severe'
        ? Colors.red
        : item[DBHelper.COL_ALLERGY_SEVERITY] == 'Moderate'
        ? Colors.orange
        : Colors.yellow[700]!;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: severityColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: severityColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber, color: severityColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item[DBHelper.COL_ALLERGY_NAME],
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  item[DBHelper.COL_ALLERGY_SEVERITY],
                  style: TextStyle(fontSize: 12, color: severityColor),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _deleteAllergy(item[DBHelper.COL_ALLERGY_ID]),
            icon: Icon(Icons.delete, color: severityColor, size: 20),
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyContactItem(Map<String, dynamic> item) {
    bool isPrimary = item[DBHelper.COL_EMERGENCY_IS_PRIMARY] == 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isPrimary ? Colors.blue.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPrimary ? Colors.blue.withOpacity(0.3) : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isPrimary ? Icons.star : Icons.person,
            color: isPrimary ? Colors.blue[600] : Colors.grey[600],
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      item[DBHelper.COL_EMERGENCY_NAME],
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    if (isPrimary) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          "Primary",
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  "${item[DBHelper.COL_EMERGENCY_PHONE]} • ${item[DBHelper.COL_EMERGENCY_RELATIONSHIP]}",
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => _editEmergencyContact(item),
                icon: const Icon(Icons.edit, size: 18),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
              const SizedBox(width: 5),
              IconButton(
                onPressed: () => _deleteEmergencyContact(item[DBHelper.COL_EMERGENCY_ID]),
                icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 15),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
      IconData icon,
      String label,
      TextEditingController controller,
      bool editable, [
        TextInputType? keyboardType,
        String? suffix,
      ])
  {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.blue, size: 22),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: isEditing && editable
                ? TextField(
              controller: controller,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                labelText: label,
                suffixText: suffix,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              ),
            )
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 5),
                Text(
                  "${controller.text} ${suffix ?? ''}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "Account Actions",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout, size: 20),
                    label: const Text("Logout"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[100],
                      foregroundColor: Colors.orange[700],
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(color: Colors.orange[300]!),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Container(
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _deleteAccount,
                    icon: const Icon(Icons.delete_forever, size: 20),
                    label: const Text("Delete"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[100],
                      foregroundColor: Colors.red[700],
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(color: Colors.red[300]!),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}