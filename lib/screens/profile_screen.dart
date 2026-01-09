import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0F172A),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1E293B), Color(0xFF020617)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              children: [
                SizedBox(height: 20),
                _buildAppBar(context),
                SizedBox(height: 40),
                _buildProfileHeader(),
                SizedBox(height: 40),
                _buildStatsSection(),
                SizedBox(height: 40),
                _buildMenuSection(),
                SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // AppBar Custom yang Senada
  Widget _buildAppBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          ),
        ),
        Text(
          "PROFIL",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        SizedBox(width: 40), // Spacing penyeimbang
      ],
    );
  }

  // Foto Profil dengan Efek Glow
  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.3),
                    blurRadius: 40,
                    spreadRadius: 5,
                  )
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blueAccent, width: 2),
              ),
              child: CircleAvatar(
                radius: 55,
                backgroundColor: Color(0xFF1E293B),
                child: Icon(Icons.person, size: 60, color: Colors.white),
              ),
            ),
            Positioned(
              bottom: 5,
              right: 5,
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  shape: BoxShape.circle,
                  border: Border.all(color: Color(0xFF0F172A), width: 2),
                ),
                child: Icon(Icons.edit, color: Colors.white, size: 15),
              ),
            )
          ],
        ),
        SizedBox(height: 20),
        Text(
          "Alya",
          style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        Text(
          "Pengguna StepMate Setia",
          style: GoogleFonts.poppins(color: Colors.white38, fontSize: 14),
        ),
      ],
    );
  }

  // Statistik (Total Langkah, dll)
  Widget _buildStatsSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem("1.2k", "Langkah"),
        Container(width: 1, height: 30, color: Colors.white10),
        _buildStatItem("42", "Tujuan"),
        Container(width: 1, height: 30, color: Colors.white10),
        _buildStatItem("Level 5", "Pemandu"),
      ],
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: GoogleFonts.poppins(fontSize: 12, color: Colors.white38)),
      ],
    );
  }

  // Daftar Menu dengan Glassmorphism
  Widget _buildMenuSection() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          _buildMenuItem(Icons.notifications_none, "Notifikasi"),
          Divider(color: Colors.white10),
          _buildMenuItem(Icons.security, "Keamanan & Privasi"),
          Divider(color: Colors.white10),
          _buildMenuItem(Icons.language, "Bahasa"),
          Divider(color: Colors.white10),
          _buildMenuItem(Icons.help_outline, "Pusat Bantuan"),
          Divider(color: Colors.white10),
          _buildMenuItem(Icons.logout, "Keluar", color: Colors.redAccent),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {Color color = Colors.white70}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color == Colors.redAccent 
                  ? Colors.redAccent.withOpacity(0.1) 
                  : Colors.blueAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color == Colors.redAccent ? Colors.redAccent : Colors.blueAccent, size: 20),
          ),
          SizedBox(width: 20),
          Text(title, style: GoogleFonts.poppins(color: color, fontSize: 15, fontWeight: FontWeight.w500)),
          Spacer(),
          Icon(Icons.chevron_right, color: Colors.white24, size: 20),
        ],
      ),
    );
  }
}