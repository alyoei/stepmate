import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'navigation_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("StepMate", style: GoogleFonts.exo2(fontWeight: FontWeight.bold)),
        actions: [CircleAvatar(backgroundColor: Colors.blueAccent, child: Icon(Icons.person, color: Colors.white)), SizedBox(width: 20)],
      ),
      body: Padding(
        padding: EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Halo, Alya", style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            Text("Mau pergi ke mana hari ini?", style: GoogleFonts.poppins(color: Colors.white60)),
            SizedBox(height: 30),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                children: [
                  _buildMenuCard(context, "Lobby Utama", Icons.business, Colors.orangeAccent),
                  _buildMenuCard(context, "Ruang Lift", Icons.elevator, Colors.blueAccent),
                  _buildMenuCard(context, "Toilet", Icons.wc, Colors.greenAccent),
                  _buildMenuCard(context, "Pintu Keluar", Icons.logout, Colors.redAccent),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, IconData icon, Color color) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => NavigationScreen(target: title))),
      child: Container(
        decoration: BoxDecoration(color: Color(0xFF1E293B), borderRadius: BorderRadius.circular(25)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: color),
            SizedBox(height: 15),
            Text(title, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}