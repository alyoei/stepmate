import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart'; 

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  
  Future<void> _register() async {
    
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError("Semua kolom harus diisi!");
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showError("Konfirmasi password tidak cocok!");
      return;
    }

    setState(() => _isLoading = true);

    try {
      
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      
      await userCredential.user?.updateDisplayName(_nameController.text.trim());

      
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user?.uid).set({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'total_steps': 0, 
        'created_at': DateTime.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Akun berhasil dibuat! Silakan masuk."), backgroundColor: Colors.green),
      );
      
      Navigator.pop(context); 
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? "Terjadi kesalahan");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

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
                style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Text(
                "Mulai langkah baru Anda bersama StepMate", 
                style: GoogleFonts.poppins(color: Colors.white60, fontSize: 15),
              ),
              SizedBox(height: 40),
              
             
              _buildTextField("Nama Lengkap", Icons.person_outline, _nameController),
              SizedBox(height: 20),
              _buildTextField("Email", Icons.email_outlined, _emailController),
              SizedBox(height: 20),
              _buildTextField("Password", Icons.lock_outline, _passwordController, isObscure: true),
              SizedBox(height: 20),
              _buildTextField("Konfirmasi Password", Icons.lock_reset_outlined, _confirmPasswordController, isObscure: true),
              
              SizedBox(height: 40),
              
              Container(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  onPressed: _isLoading ? null : _register, 
                  child: _isLoading 
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        "DAFTAR SEKARANG", 
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.5),
                      ),
                ),
              ),
              
              SizedBox(height: 30),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Sudah punya akun? ", style: GoogleFonts.poppins(color: Colors.white54, fontSize: 14)),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        "Masuk",
                        style: GoogleFonts.poppins(color: Colors.blueAccent, fontWeight: FontWeight.bold),
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

  Widget _buildTextField(String label, IconData icon, TextEditingController controller, {bool isObscure = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: TextField(
        controller: controller, 
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