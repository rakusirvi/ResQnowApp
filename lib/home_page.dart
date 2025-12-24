import 'package:flutter/material.dart';
import 'package:flutter_swipe_button/flutter_swipe_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class EmergencyContact {
  final String name;
  final String phoneNumber;
  final String userId;

  EmergencyContact({
    required this.name,
    required this.phoneNumber,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
      'userId': userId,
    };
  }

  factory EmergencyContact.fromMap(Map<String, dynamic> map) {
    return EmergencyContact(
      name: map['name'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      userId: map['userId'] ?? '',
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<EmergencyContact> _emergencyContacts = [];
  bool _isLoading = false;
  String _userPhone = '';
  String _userName = '';
  String _userId = '';
  String _userEmail = '';
  String _userAddress = '';
  int _userAge = 0;
  String _bloodGroup = '';
  String _primaryEmergencyContact = '';
  Position? _currentPosition;
  String _currentAddress = "Fetching location...";

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _getCurrentLocation();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? 'User';
      _userPhone = prefs.getString('userPhone') ?? '';
      _userId = prefs.getString('userId') ?? '';
      _userEmail = prefs.getString('userEmail') ?? '';
      _userAddress = prefs.getString('userAddress') ?? '';
      _userAge = prefs.getInt('userAge') ?? 0;
      _bloodGroup = prefs.getString('bloodGroup') ?? '';
      _primaryEmergencyContact = prefs.getString('emergencyContact') ?? '';
    });

    await _loadEmergencyContactsFromFirebase();
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _currentAddress = "Location permission denied";
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _currentAddress = "Location permission permanently denied";
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      String address = await _getAddressFromLatLng(position);

      setState(() {
        _currentPosition = position;
        _currentAddress = address;
      });
    } catch (e) {
      print("Location error: $e");
      setState(() {
        _currentAddress = "Location unavailable";
      });
    }
  }

  Future<String> _getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        List<String> addressParts = [];

        if (place.street != null && place.street!.isNotEmpty)
          addressParts.add(place.street!);
        if (place.locality != null && place.locality!.isNotEmpty)
          addressParts.add(place.locality!);
        if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty)
          addressParts.add(place.administrativeArea!);
        if (place.country != null && place.country!.isNotEmpty)
          addressParts.add(place.country!);

        return addressParts.isNotEmpty ? addressParts.join(', ') : 'Unknown Location';
      }
      return '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
    } catch (e) {
      return '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
    }
  }

  Future<void> _loadEmergencyContactsFromFirebase() async {
    try {
      if (_userId.isEmpty) return;

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('emergencyContacts')
          .where('userId', isEqualTo: _userId)
          .orderBy('createdAt', descending: true)
          .limit(2)
          .get();

      setState(() {
        _emergencyContacts = querySnapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          return EmergencyContact(
            name: data['name'] ?? '',
            phoneNumber: data['phoneNumber'] ?? '',
            userId: data['userId'] ?? _userId,
          );
        }).toList();
      });
    } catch (e) {
      print("Error loading contacts from Firebase: $e");
      await _loadEmergencyContactsFromPrefs();
    }
  }

  Future<void> _loadEmergencyContactsFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? contactsData = prefs.getStringList('emergencyContacts');

    if (contactsData != null) {
      List<String> limitedContacts = contactsData.take(2).toList();

      setState(() {
        _emergencyContacts.addAll(limitedContacts.map((contactString) {
          List<String> parts = contactString.split('|');
          return EmergencyContact(
            name: parts[0],
            phoneNumber: parts.length > 1 ? parts[1] : '',
            userId: _userId,
          );
        }).toList());
      });
    }
  }

  Future<void> _addEmergencyContact() async {
    if (_emergencyContacts.length >= 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum 2 emergency contacts allowed'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    TextEditingController nameController = TextEditingController();
    TextEditingController phoneController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Color(0xFF5BADFF),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.person_add_rounded, color: Colors.white, size: 30),
              ),
              SizedBox(height: 16),
              Text(
                'Add Emergency Contact',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '${_emergencyContacts.length}/2 contacts added',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 24),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Contact Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Color(0xFF5BADFF), width: 2),
                  ),
                  prefixIcon: Icon(Icons.person_rounded, color: Color(0xFF5BADFF)),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Color(0xFF5BADFF), width: 2),
                  ),
                  prefixIcon: Icon(Icons.phone_rounded, color: Color(0xFF5BADFF)),
                  hintText: '9920200597',
                ),
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (nameController.text.isNotEmpty && phoneController.text.isNotEmpty) {
                          _addNewContact(
                            nameController.text.trim(),
                            phoneController.text.trim(),
                          );
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF5BADFF),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        'Add Contact',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addNewContact(String name, String phone) async {
    if (_emergencyContacts.length >= 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum 2 emergency contacts reached'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    EmergencyContact newContact = EmergencyContact(
      name: name,
      phoneNumber: phone,
      userId: _userId,
    );

    try {
      Map<String, dynamic> contactData = {
        'name': name,
        'phoneNumber': phone,
        'userId': _userId,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('emergencyContacts')
          .add(contactData);

      setState(() {
        _emergencyContacts.add(newContact);
      });

      await _saveContactsToPrefs();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Contact added: $name'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print("Error saving contact to Firebase: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add contact: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _sendSOS() async {
    setState(() {
      _isLoading = true;
    });

    try {
      Position? position;
      String address = "Location unavailable";
      String googleMapsUrl = "";

      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation,
        );
        address = await _getAddressFromLatLng(position);
        googleMapsUrl = 'https://maps.google.com/?q=${position.latitude},${position.longitude}';
      } catch (e) {
        print("Location error: $e");
        address = _userAddress.isNotEmpty ? _userAddress : "Address not available";
      }

      List<Map<String, dynamic>> emergencyContactsData = _emergencyContacts.map((contact) {
        return {
          'name': contact.name,
          'phoneNumber': contact.phoneNumber,
          'userId': contact.userId,
        };
      }).toList();

      Map<String, dynamic> emergencyData = {
        'userId': _userId,
        'userName': _userName,
        'userPhone': _userPhone,
        'userEmail': _userEmail,
        'userAge': _userAge,
        'bloodGroup': _bloodGroup,
        'userAddress': _userAddress,
        'emergencyContact': _primaryEmergencyContact,
        'emergencyContacts': emergencyContactsData,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'active',
        'emergencyType': 'sos_alert',
        'priority': 'high',
        'contactsCount': _emergencyContacts.length,
      };

      if (position != null) {
        emergencyData.addAll({
          'latitude': position.latitude,
          'longitude': position.longitude,
          'accuracy': position.accuracy,
          'googleMapsUrl': googleMapsUrl,
          'formattedAddress': address,
        });
      } else {
        emergencyData['formattedAddress'] = address;
      }

      DocumentReference emergencyRef = await FirebaseFirestore.instance
          .collection('emergencies')
          .add(emergencyData);

      String emergencyId = emergencyRef.id;
      print("Emergency saved to Firebase with ID: $emergencyId");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🚨 EMERGENCY ALERT SENT! Help is on the way!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 5),
        ),
      );

    } catch (e) {
      print("SOS Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending alert: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveContactsToPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> contactsData = _emergencyContacts.map((contact) =>
    '${contact.name}|${contact.phoneNumber}').toList();
    await prefs.setStringList('emergencyContacts', contactsData);
  }

  Future<void> _deleteContact(int index) async {
    EmergencyContact contact = _emergencyContacts[index];

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('emergencyContacts')
          .where('userId', isEqualTo: _userId)
          .where('name', isEqualTo: contact.name)
          .where('phoneNumber', isEqualTo: contact.phoneNumber)
          .get();

      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        await doc.reference.delete();
      }

      setState(() {
        _emergencyContacts.removeAt(index);
      });

      await _saveContactsToPrefs();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Contact deleted: ${contact.name}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print("Error deleting contact: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete contact: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    // SOS Button - Centered and prominent
                    _buildSOSButton(),

                    SizedBox(height: 24),

                    // Quick Actions
                    _buildQuickActions(),

                    SizedBox(height: 24),

                    // Location Card
                    _buildLocationCard(),

                    SizedBox(height: 24),

                    // Emergency Contacts
                    _buildEmergencyContacts(),

                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // User Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF5BADFF), Color(0xFF3A8DE0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(width: 12),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  _userName,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  _userPhone,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSOSButton() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [Color(0xFFFF4757), Color(0xFFFF6B6B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFFF4757).withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.emergency_rounded,
            color: Colors.white,
            size: 48,
          ),
          SizedBox(height: 16),
          Text(
            'EMERGENCY SOS',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Swipe to send immediate alert to your emergency contacts',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          Container(
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
            ),
            child: _isLoading
                ? Container(
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            )
                : SwipeButton(
              thumbPadding: EdgeInsets.all(8),
              activeThumbColor: Colors.white,
              activeTrackColor: Colors.red[800],
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.red[400],
              elevationThumb: 4,
              elevationTrack: 2,
              child: Text(
                'SWIPE TO SEND SOS',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              onSwipe: _sendSOS,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        _buildQuickActionItem(
          Icons.contacts_outlined,
          'Contacts',
          _addEmergencyContact,
          Color(0xFF5BADFF),
        ),
        SizedBox(width: 12),
        _buildQuickActionItem(
          Icons.location_on_outlined,
          'Location',
          _getCurrentLocation, // Add the missing 'r' here
          Color(0xFF34C759),
        ),

        SizedBox(width: 12),
        _buildQuickActionItem(
          Icons.refresh_outlined,
          'Refresh',
          _getCurrentLocation,
          Color(0xFF164660),
        ),
      ],
    );
  }

  Widget _buildQuickActionItem(IconData icon, String title, VoidCallback onTap, Color color) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on_outlined, color: Color(0xFF5BADFF), size: 20),
              SizedBox(width: 8),
              Text(
                'Current Location',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              Spacer(),
              IconButton(
                icon: Icon(Icons.refresh_rounded, color: Color(0xFF5BADFF), size: 20),
                onPressed: _getCurrentLocation,
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            _currentAddress,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          if (_currentPosition != null) ...[
            SizedBox(height: 4),
            Text(
              '${_currentPosition!.latitude.toStringAsFixed(6)}, ${_currentPosition!.longitude.toStringAsFixed(6)}',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmergencyContacts() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Emergency Contacts',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_emergencyContacts.length}/2',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),

          if (_emergencyContacts.isEmpty)
            _buildEmptyContactsState()
          else
            Column(
              children: _emergencyContacts.asMap().entries.map((entry) {
                int index = entry.key;
                EmergencyContact contact = entry.value;
                return _buildContactItem(contact, index);
              }).toList(),
            ),

          if (_emergencyContacts.length < 2)
            TextButton(
              onPressed: _addEmergencyContact,
              style: TextButton.styleFrom(
                foregroundColor: Color(0xFF5BADFF),
                padding: EdgeInsets.zero,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, size: 18),
                  SizedBox(width: 4),
                  Text('Add Contact'),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyContactsState() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Icon(
            Icons.contact_phone_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          SizedBox(height: 12),
          Text(
            'No Emergency Contacts',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add contacts to be notified during emergencies',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _addEmergencyContact,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF5BADFF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(
              'Add First Contact',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(EmergencyContact contact, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Color(0xFF5BADFF).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_outlined,
              color: Color(0xFF5BADFF),
              size: 18,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  contact.phoneNumber,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.grey[500], size: 18),
            onPressed: () => _deleteContact(index),
          ),
        ],
      ),
    );
  }
}