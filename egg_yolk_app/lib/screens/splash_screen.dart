import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  // ── สีให้ตรงกับ HomeScreen ──────────────────────────────────────────────
  static const Color _bg    = Color(0xFFFAF5EB); // cream เหมือน HomeScreen
  static const Color _amber = Color(0xFFE8A020); // amber หลัก
  static const Color _dark  = Color(0xFF1A1A1A); // ตัวอักษรเข้ม

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // ── ภาพไข่ (cross-section: ไข่ขาว + ไข่แดง) ─────────────────
              SizedBox(
                width: 168,
                height: 168,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // วงแหวนเงา / จาน
                    Container(
                      width: 168,
                      height: 168,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFE8DEC8),
                      ),
                    ),
                    // ไข่ขาว
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(
                          color: const Color(0xFFFDE68A),
                          width: 1.5,
                        ),
                      ),
                    ),
                    // ไข่แดง
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: _amber,
                      ),
                    ),
                    // Highlight บนไข่แดง
                    Positioned(
                      left: 50,
                      top: 50,
                      child: Container(
                        width: 22,
                        height: 14,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFCD34D),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              // ── ชื่อแอป ────────────────────────────────────────────────────
              Text(
                'ระบบประเมิน',
                textAlign: TextAlign.center,
                style: GoogleFonts.kanit(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: _dark,
                  height: 1.2,
                ),
              ),
              Text(
                'คะแนนพัดสีไข่แดง',
                textAlign: TextAlign.center,
                style: GoogleFonts.kanit(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: _amber,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 12),

              // ── คำอธิบายสั้น ────────────────────────────────────────────────
              Text(
                'วิเคราะห์สีไข่แดงด้วย On-Device AI\nบน DSM Yolk Color Fan Scale 1–15',
                textAlign: TextAlign.center,
                style: GoogleFonts.kanit(
                  fontSize: 13,
                  color: const Color(0xFF6B7280),
                  height: 1.7,
                ),
              ),

              const SizedBox(height: 20),

              // ── Mini DSM scale strip (15 ระดับสีหัวท้ายมนแบบ Pill) ──────────
              SizedBox(
                height: 8,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: _buildDsmStrip(),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '1',
                    style: GoogleFonts.kanit(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
                  Text(
                    'DSM Scale',
                    style: GoogleFonts.kanit(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
                  Text(
                    '15',
                    style: GoogleFonts.kanit(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),

              const Spacer(flex: 2),

              // ── ปุ่มเริ่มต้น ────────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _amber,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    // Navigation เหมือนเดิม 100%
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                    );
                  },
                  child: Text(
                    'เริ่มต้นใช้งาน',
                    style: GoogleFonts.kanit(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── On-Device badge ─────────────────────────────────────────────
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: Color(0xFF22C55E),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, size: 10, color: Colors.white),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'On-Device AI · 100% Offline',
                      style: GoogleFonts.kanit(
                        fontSize: 12,
                        color: const Color(0xFF059669),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }

  // ── สร้างแถบสี DSM 1–15 ──────────────────────────────────────────────────
  static List<Widget> _buildDsmStrip() {
    const colors = [
      Color(0xFFFFF9C4), Color(0xFFFFF59D), Color(0xFFFFF176),
      Color(0xFFFFFF4D), Color(0xFFFFCA28), Color(0xFFFFB300),
      Color(0xFFFFA000), Color(0xFFFF8F00), Color(0xFFFF6F00),
      Color(0xFFE65100), Color(0xFFD84315), Color(0xFFBF360C),
      Color(0xFF870000), Color(0xFF5D0000), Color(0xFF3E0000),
    ];
    return colors
        .map((c) => Expanded(
              child: SizedBox.expand(
                child: ColoredBox(color: c),
              ),
            ))
        .toList();
  }
}