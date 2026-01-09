import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  
  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Email dan Password tidak boleh kosong!")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      
      String message = "Terjadi kesalahan";
      if (e.code == 'user-not-found') message = "Email tidak terdaftar";
      else if (e.code == 'wrong-password') message = "Password salah";

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      setState(() => _isLoading = false);
    }
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
              SizedBox(height: 100),
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
                "Selamat Datang",
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
              Text(
                "Silakan masuk untuk melanjutkan navigasi Anda",
                style: GoogleFonts.poppins(
                  color: Colors.white60,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 50),
              
              
              _buildTextField("Email", Icons.email_outlined, _emailController),
              SizedBox(height: 20),
              _buildTextField("Password", Icons.lock_outline, _passwordController, isObscure: true),
              
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    "Lupa Password?",
                    style: GoogleFonts.poppins(color: Colors.blueAccent, fontSize: 13),
                  ),
                ),
              ),
              SizedBox(height: 30),

              // Tombol Login
              Container(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  onPressed: _isLoading ? null : _login, 
                  child: _isLoading 
                    ? CircularProgressIndicator(color: Colors.white) 
                    : Text(
                        "MASUK SEKARANG",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                ),
              ),
              
              SizedBox(height: 40),
              Center(
                child: Column(
                  children: [
                    Text(
                      "Belum punya akun?",
                      style: GoogleFonts.poppins(color: Colors.white54, fontSize: 14),
                    ),
                    TextButton(
                      onPressed: () {
                         Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterScreen()));
                      },
                      child: Text(
                        "Daftar Sekarang",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
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