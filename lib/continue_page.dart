import 'package:flutter/material.dart';
import 'login_page.dart';

class ContinuePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF164660),
      body: SafeArea(
        child: Stack(
          children: [
            // Simple static background
            _buildStaticBackground(),

            // Main content without heavy animations
            Column(
              children: [
                // Logo Section
                Expanded(
                  flex: 2,
                  child: Center(
                    child: _buildLogoSection(),
                  ),
                ),
                Expanded(flex: 1, child: SizedBox()),
              ],
            ),

            // Bottom Sheet
            _buildBottomSheet(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStaticBackground() {
    return Stack(
      children: [
        // Simple static circles - no animations
        Positioned(
          top: -30,
          right: -30,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  Color(0xFF1E5777).withOpacity(0.3),
                  Color(0xFF164660).withOpacity(0.1),
                ],
              ),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          bottom: 150,
          left: -60,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  Color(0xFF1E5777).withOpacity(0.2),
                  Color(0xFF164660).withOpacity(0.1),
                ],
              ),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogoSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(35),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Center(
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.asset(
                  'Assets/img.png',  // Changed from 'Assets/img.png'
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Color(0xFF5BADFF),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Icon(
                        Icons.security_rounded,
                        color: Colors.white,
                        size: 50,
                      ),
                    );
                  },
                ),
                ),
              ),
            ),
          ),
        SizedBox(height: 40),
      ],
    );
  }

  Widget _buildBottomSheet(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.all(20),
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Feature Icons - Simple row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSimpleFeatureIcon(Icons.location_on_rounded, 'Location'),
                _buildSimpleFeatureIcon(Icons.emergency_rounded, 'Alert'),
                _buildSimpleFeatureIcon(Icons.people_alt_rounded, 'Contacts'),
                _buildSimpleFeatureIcon(Icons.security_rounded, 'Police'),
              ],
            ),

            SizedBox(height: 20),

            // Security Badge
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Color(0xFF164660).withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Color(0xFF164660).withOpacity(0.1),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.verified_user_rounded,
                    color: Color(0xFF164660),
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'TRUSTED • SECURE • RELIABLE',
                    style: TextStyle(
                      color: Color(0xFF164660),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Main Heading
            Text(
              'Your Safety is Our Priority',
              style: TextStyle(
                fontSize: 22,
                color: Color(0xFF164660),
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 12),

            // Description
            Text(
              'Join thousands of users who trust Rudhra SOS for emergency protection.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 24),

            // Simple Continue Button
            _buildSimpleContinueButton(context),

            SizedBox(height: 16),

            // Security Info
            Text(
              '100% Secure • Encrypted • Private',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleFeatureIcon(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Color(0xFF5BADFF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Color(0xFF5BADFF).withOpacity(0.3),
            ),
          ),
          child: Icon(
            icon,
            color: Color(0xFF5BADFF),
            size: 22,
          ),
        ),
        SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleContinueButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LoginPage(),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF5BADFF), Color(0xFF3A8DE0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF5BADFF).withOpacity(0.3),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'GET STARTED',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: Colors.white,
                  letterSpacing: 1.0,
                ),
              ),
              SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}