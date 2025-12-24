import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import 'TermsCondition.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emergencyContactController = TextEditingController();

  bool _isLoading = false;
  bool _agreeToTerms = false;
  bool _isNotRobot = false;
  String? _selectedBloodGroup;

  // Blood group options
  final List<String> _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  Future<void> _registerUser() async {
    if (!_validateForm()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      String userId = 'user_${DateTime.now().millisecondsSinceEpoch}_${_phoneController.text.trim()}';

      Map<String, dynamic> userData = {
        'userId': userId,
        'name': _nameController.text.trim(),
        'age': int.parse(_ageController.text.trim()),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'emergencyContact': _emergencyContactController.text.trim(),
        'bloodGroup': _selectedBloodGroup, // Added blood group
        'createdAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
        'isActive': true,
        'userType': 'citizen',
        'registrationCompleted': true,
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .set(userData);

      await _saveLoginStatus(userId, userData);

      // Direct navigation without dialog for better performance
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
            (route) => false,
      );

    } catch (e) {
      _showErrorSnackBar(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _validateForm() {
    if (_nameController.text.isEmpty ||
        _ageController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _emergencyContactController.text.isEmpty ||
        _selectedBloodGroup == null) { // Added blood group validation
      _showSnackBar('Please fill all fields', Colors.red);
      return false;
    }

    final age = int.tryParse(_ageController.text.trim());
    if (age == null || age < 5 || age > 120) {
      _showSnackBar('Please enter a valid age (5-120)', Colors.red);
      return false;
    }

    final phone = _phoneController.text.trim();
    if (phone.length != 10 || !RegExp(r'^[6-9]\d{9}$').hasMatch(phone)) {
      _showSnackBar('Please enter a valid 10-digit phone number', Colors.red);
      return false;
    }

    if (!_agreeToTerms || !_isNotRobot) {
      _showSnackBar('Please agree to terms and confirm you are not a robot', Colors.red);
      return false;
    }

    return true;
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Registration failed: $error'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 5),
      ),
    );
  }

  Future<void> _saveLoginStatus(String userId, Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();

    // Batch set for better performance
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userId', userId);
    await prefs.setString('userName', userData['name']);
    await prefs.setString('userPhone', userData['phone']);
    await prefs.setString('userEmail', userData['email'] ?? '');
    await prefs.setString('userAddress', userData['address']);
    await prefs.setString('emergencyContact', userData['emergencyContact']);
    await prefs.setString('bloodGroup', userData['bloodGroup'] ?? ''); // Added blood group
    await prefs.setInt('userAge', userData['age']);
    await prefs.setBool('registrationCompleted', true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF164660),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // Header Section - Simplified
              _buildHeaderSection(),

              // Form Section - Simplified
              _buildFormSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        color: Color(0xFF164660),
      ),
      child: Column(
        children: [
          // Simple Back Button
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),

          // Simple Logo
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Color(0xFF5BADFF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Icons.person_add_alt_1_rounded, color: Colors.white, size: 40),
          ),
          SizedBox(height: 20),

          // Title
          Text(
            'Create Account',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),

          // Subtitle
          Text(
            'Join our safety community',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Personal Information
          _buildSectionHeader('Personal Information'),
          _buildSimpleTextField(_nameController, 'Full Name', Icons.person),
          _buildSimpleTextField(_ageController, 'Age', Icons.cake, keyboardType: TextInputType.number),

          // Blood Group Dropdown
          _buildBloodGroupDropdown(),

          _buildSimpleTextField(_emailController, 'Email Address', Icons.email),
          _buildPhoneField(_phoneController, 'Phone Number', Icons.phone),

          SizedBox(height: 20),
          _buildSectionHeader('Address Information'),
          _buildSimpleTextField(_addressController, 'Complete Address', Icons.home, maxLines: 2),

          SizedBox(height: 20),
          _buildSectionHeader('Emergency Contact'),
          _buildPhoneField(_emergencyContactController, 'Emergency Contact Number', Icons.contact_emergency),
          SizedBox(height: 8),
          Text(
            'This contact will be notified during emergencies',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),

          SizedBox(height: 20),
          _buildTermsButton(),

          SizedBox(height: 15),
          // Simple Checkboxes
          _buildSimpleCheckbox(
            value: _agreeToTerms,
            onChanged: (value) => setState(() => _agreeToTerms = value ?? false),
            text: 'I agree to the Terms and Conditions',
          ),

          SizedBox(height: 10),
          _buildSimpleCheckbox(
            value: _isNotRobot,
            onChanged: (value) => setState(() => _isNotRobot = value ?? false),
            text: 'I confirm I am not a robot',
          ),

          SizedBox(height: 25),
          // Register Button
          _buildRegisterButton(),

          SizedBox(height: 20),
          _buildSimpleEmergencyFeatures(),
        ],
      ),
    );
  }

  Widget _buildBloodGroupDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Blood Group',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
              color: Colors.grey[50],
            ),
            child: DropdownButtonFormField<String>(
              value: _selectedBloodGroup,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedBloodGroup = newValue;
                });
              },
              items: _bloodGroups.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[800],
                    ),
                  ),
                );
              }).toList(),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                prefixIcon: Icon(Icons.bloodtype_rounded, color: Color(0xFF5BADFF)),
                hintText: 'Select Blood Group',
                hintStyle: TextStyle(color: Colors.grey[500]),
              ),
              validator: (value) {
                if (value == null) {
                  return 'Please select blood group';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Color(0xFF164660),
        ),
      ),
    );
  }

  Widget _buildSimpleTextField(
      TextEditingController controller,
      String label,
      IconData icon, {
        int maxLines = 1,
        TextInputType keyboardType = TextInputType.text,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: TextStyle(
          color: Colors.grey[800],
          fontSize: 16,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[600]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFF5BADFF), width: 2),
          ),
          prefixIcon: Icon(icon, color: Color(0xFF5BADFF)),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
    );
  }

  Widget _buildPhoneField(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.phone,
        style: TextStyle(
          color: Colors.grey[800],
          fontSize: 16,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[600]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFF5BADFF), width: 2),
          ),
          prefixIcon: Icon(icon, color: Color(0xFF5BADFF)),
          prefix: Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: Text('+91 ', style: TextStyle(color: Colors.grey[700])),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
    );
  }

  Widget _buildTermsButton() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF5BADFF).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFF5BADFF).withOpacity(0.3)),
      ),
      child: TextButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => TermsCondition()));
        },
        child: Text(
          "Read Terms & Conditions",
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF5BADFF),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleCheckbox({
    required bool value,
    required ValueChanged<bool?> onChanged,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: Color(0xFF5BADFF),
        ),
        SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: () => onChanged(!value),
            child: Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _registerUser,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF5BADFF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 4,
        ),
        child: _isLoading
            ? SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'COMPLETE REGISTRATION',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleEmergencyFeatures() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF164660).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.security_rounded, color: Color(0xFF5BADFF), size: 24),
              SizedBox(width: 12),
              Text(
                'Emergency Features',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF164660),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          ..._buildSimpleFeatureItems(),
        ],
      ),
    );
  }

  List<Widget> _buildSimpleFeatureItems() {
    final features = [
      'Swipe SOS button for instant alerts',
      'Real-time location sharing',
      'Emergency contacts notification',
      'Police and emergency services dispatch',
    ];

    return features.map((feature) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.circle, color: Color(0xFF5BADFF), size: 8),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              feature,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    )).toList();
  }
}