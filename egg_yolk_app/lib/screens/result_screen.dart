import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/prediction_result.dart';
import 'detail_screen.dart';

class ResultScreen extends StatelessWidget {
  final File imageFile;
  final PredictionResult result;

  const ResultScreen({
    super.key,
    required this.imageFile,
    required this.result,
  });

  // ── Design tokens ให้ตรงกันทั้งแอป ──────────────────────────────────────
  static const Color _bg    = Color(0xFFFAF5EB); // cream อุ่น
  static const Color _amber = Color(0xFFE8A020); // amber หลัก
  static const Color _dark  = Color(0xFF1A1A1A); // ตัวอักษรเข้ม
  static const Color _gray  = Color(0xFF6B7280); // สีคำอธิบายรอง

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: _dark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'ผลการวิเคราะห์สีไข่แดง',
          style: GoogleFonts.kanit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _dark,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Image Thumbnail ─────────────────────────────────────────
              Center(
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFFDE68A), width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x15000000),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.file(
                      imageFile,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Hero Score Card (Amber Gradient) ────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_amber, Color(0xFFF59E0B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33E8A020),
                      blurRadius: 16,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'ระดับพัดสีไข่แดง (DSM Fan Score)',
                      style: GoogleFonts.kanit(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: const [
                          Shadow(
                            color: Color(0x33000000),
                            offset: Offset(0, 1),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${result.predictedScore}',
                      style: GoogleFonts.outfit(
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.1,
                        shadows: const [
                          Shadow(
                            color: Color(0x40000000),
                            offset: Offset(0, 4),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'คะแนนดิบ (Raw): ${result.rawScore.toStringAsFixed(2)} · สเกล 1-15',
                        style: GoogleFonts.kanit(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── 2 White Cards for RGB & Lab ─────────────────────────────
              Row(
                children: [
                  // RGB Card
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x08000000),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ค่าเฉลี่ยสี RGB',
                            style: GoogleFonts.kanit(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _dark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildColorRow('R', result.rgb.r.round(), const Color(0xFFEF4444)),
                          _buildColorRow('G', result.rgb.g.round(), const Color(0xFF10B981)),
                          _buildColorRow('B', result.rgb.b.round(), const Color(0xFF3B82F6)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // CIELAB Card
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x08000000),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ค่าสี CIELAB (D65)',
                            style: GoogleFonts.kanit(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _dark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildColorRow('L*', result.cielab.l.round(), _dark),
                          _buildColorRow('a*', result.cielab.a.round(), const Color(0xFFDC2626)),
                          _buildColorRow('b*', result.cielab.b.round(), const Color(0xFFD97706)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ── 2 Cards for Chroma & Hue Angle ──────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Chroma (C*)', style: GoogleFonts.kanit(fontSize: 12, color: _gray)),
                          Text(
                            result.cielab.chroma.toStringAsFixed(1),
                            style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: _dark),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Hue (h°)', style: GoogleFonts.kanit(fontSize: 12, color: _gray)),
                          Text(
                            '${result.cielab.hueAngle.toStringAsFixed(1)}°',
                            style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: _dark),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // ── Link to Detail ──────────────────────────────────────────
              Center(
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailScreen(result: result),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Text(
                      'ดูข้อมูลวิทยาศาสตร์และรายละเอียดเพิ่มเติม →',
                      style: GoogleFonts.kanit(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _amber,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── Back to Home Button ─────────────────────────────────────
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
                  onPressed: () => Navigator.pop(context),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.arrow_back, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'กลับสู่หน้าหลัก',
                        style: GoogleFonts.kanit(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorRow(String label, int value, Color dotColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.kanit(fontSize: 13, fontWeight: FontWeight.w500, color: _dark),
              ),
            ],
          ),
          Text(
            '$value',
            style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: _dark),
          ),
        ],
      ),
    );
  }
}
