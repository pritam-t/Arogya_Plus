import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
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

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeAnimations();
    getUsers();
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

  Future<void> getUsers() async {
    try {
      final result = await dbref.getUsers();
      if (result.isNotEmpty) {
        setState(() {
          userinfo = result.first;
          _updateControllers();
          isLoading = false;
        });
      } else {
        setState(() {
          userinfo = null;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching user: $e");
      _showSnackBar("Error loading user data", isError: true);
      setState(() {
        isLoading = false;
      });
    }
  }

  void _updateControllers() {
    if (userinfo != null) {
      nameController.text = userinfo![DBHelper.COL_NAME] ?? '';
      ageController.text = userinfo![DBHelper.COL_AGE].toString();
      genderController.text = userinfo![DBHelper.COL_GENDER] ?? '';
      heightController.text = userinfo![DBHelper.COL_HEIGHT].toString();
      weightController.text = userinfo![DBHelper.COL_WEIGHT].toString();
      bloodController.text = userinfo![DBHelper.COL_BLOOD] ?? '';
    }
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
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildImageOption(
                        icon: Icons.photo_library,
                        title: "Gallery",
                        onTap: () => _pickImage(ImageSource.gallery),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildImageOption(
                        icon: Icons.camera_alt,
                        title: "Camera",
                        onTap: () => _pickImage(ImageSource.camera),
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
                      onTap: _removeProfileImage,
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
  }) {
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

  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context);
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 512,
        maxHeight: 512,
      );

      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });
        _showSnackBar("Profile picture updated successfully!");
      }
    } catch (e) {
      print("Error picking image: $e");
      _showSnackBar("Error selecting image", isError: true);
    }
  }

  void _removeProfileImage() {
    Navigator.pop(context);
    setState(() {
      _profileImage = null;
    });
    _showSnackBar("Profile picture removed");
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
      );

      setState(() {
        isEditing = false;
      });

      await getUsers();
      _showSnackBar("Profile updated successfully!");
    } catch (e) {
      print("Error updating user: $e");
      _showSnackBar("Error updating profile", isError: true);
    }
  }

  Future<void> _deleteAccount() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child:
              const Text("Delete", style: TextStyle(color: Colors.white)),
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
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child:
              const Text("Logout", style: TextStyle(color: Colors.white)),
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
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userinfo == null
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off, size: 80, color: Colors.grey),
            SizedBox(height: 20),
            Text(
              "No user found",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      )
          : FadeTransition(
        opacity: _fadeController,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Profile Header Section
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Padding(
                  padding:
                  const EdgeInsets.fromLTRB(20, 20, 20, 30),
                  child: Column(
                    children: [
                      // Profile Picture
                      Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.grey[200],
                              backgroundImage: _profileImage != null
                                  ? FileImage(_profileImage!)
                                  : null,
                              child: _profileImage == null
                                  ? Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.grey[400],
                              )
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        userinfo![DBHelper.COL_NAME] ??
                            'Unknown User',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 25),
                      Row(
                        children: [
                          Expanded(
                            child: _buildActionButton(
                              icon: Icons.photo_camera,
                              label: "Update Photo",
                              color: Colors.blue,
                              onPressed:
                              _showImagePickerBottomSheet,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: _buildActionButton(
                              icon: isEditing
                                  ? Icons.save
                                  : Icons.edit,
                              label: isEditing
                                  ? "Save Changes"
                                  : "Edit Info",
                              color: isEditing
                                  ? Colors.green
                                  : Colors.orange,
                              onPressed: () {
                                if (isEditing) {
                                  _saveChanges();
                                } else {
                                  setState(() {
                                    isEditing = true;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildInfoCard("Personal Information", [
                      _buildInfoRow(Icons.person, "Name",
                          nameController, true),
                      _buildInfoRow(Icons.cake, "Age",
                          ageController, true, TextInputType.number),
                      _buildInfoRow(Icons.wc, "Gender",
                          genderController, true),
                    ]),
                    const SizedBox(height: 20),
                    _buildInfoCard("Health Information", [
                      _buildInfoRow(Icons.height, "Height",
                          heightController, true,
                          TextInputType.number, "cm"),
                      _buildInfoRow(Icons.monitor_weight, "Weight",
                          weightController, true,
                          TextInputType.number, "kg"),
                      _buildInfoRow(Icons.bloodtype, "Blood Group",
                          bloodController, true),
                    ]),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDangerButton(
                            icon: Icons.logout,
                            label: "Logout",
                            color: Colors.orange,
                            onPressed: _logout,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _buildDangerButton(
                            icon: Icons.delete_forever,
                            label: "Delete Account",
                            color: Colors.red,
                            onPressed: _deleteAccount,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
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
      ]) {
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
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 10, horizontal: 15),
              ),
            )
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
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

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14),
        elevation: 3,
      ),
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDangerButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14),
        elevation: 3,
      ),
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
