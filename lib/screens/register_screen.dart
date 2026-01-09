import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F172A), Color(0xFF020617)],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 80),
              
             
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                ),
              ),
              
              SizedBox(height: 30),
              
              // Header
              Container(
                height: 5,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Buat Akun", 
                style: GoogleFonts.poppins(
                  fontSize: 32, 
                  fontWeight: FontWeight.bold, 
                  color: Colors.white,
                  letterSpacing: 1
                )
              ),
              Text(
                "Mulai langkah baru Anda bersama StepMate", 
                style: GoogleFonts.poppins(
                  color: Colors.white60, 
                  fontSize: 15,
                )
              ),
              
              SizedBox(height: 40),
              
              // Input Fields
              _buildTextField("Nama Lengkap", Icons.person_outline),
              SizedBox(height: 20),
              _buildTextField("Email", Icons.email_outlined),
              SizedBox(height: 20),
              _buildTextField("Password", Icons.lock_outline, isObscure: true),
              SizedBox(height: 20),
              _buildTextField("Konfirmasi Password", Icons.lock_reset_outlined, isObscure: true),
              
              SizedBox(height: 40),
              
              
              Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.3),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    )
                  ],
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    
                    
                    // Setelah sukses, kembali ke halaman login
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Akun berhasil dibuat! Silakan masuk."),
                        backgroundColor: Colors.blueAccent,
                      ),
                    );
                    Navigator.pop(context);
                  },
                  child: Text(
                    "DAFTAR SEKARANG", 
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold, 
                      color: Colors.white, 
                      letterSpacing: 1.5
                    )
                  ),
                ),
              ),
              
              SizedBox(height: 30),
              
             
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Sudah punya akun? ",
                      style: GoogleFonts.poppins(color: Colors.white54, fontSize: 14),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        "Masuk",
                        style: GoogleFonts.poppins(
                          color: Colors.blueAccent, 
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, {bool isObscure = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: TextField(
        obscureText: isObscure,
        style: GoogleFonts.poppins(color: Colors.white),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 20),
          prefixIcon: Icon(icon, color: Colors.blueAccent, size: 22),
          labelText: label,
          labelStyle: GoogleFonts.poppins(color: Colors.white38),
          border: InputBorder.none,
        ),
      ),
    );
  }
}