import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/prediction_result.dart';

class DetailScreen extends StatelessWidget {
  final PredictionResult result;

  const DetailScreen({
    super.key,
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
          'รายละเอียดข้อมูลวิทยาศาสตร์',
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
              // ── Card 1: สรุปคะแนนสี ──────────────────────────────────────
              _buildCard(
                icon: Icons.auto_awesome,
                iconColor: _amber,
                title: 'ผลคะแนนพัดสีไข่แดง (DSM Fan Score)',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '${result.predictedScore}',
                          style: GoogleFonts.outfit(
                            fontSize: 38,
                            fontWeight: FontWeight.bold,
                            color: _amber,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '/ 15 ระดับ',
                          style: GoogleFonts.kanit(
                            fontSize: 15,
                            color: _gray,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ค่าคะแนนดิบจากการคำนวณ: ${result.rawScore.toStringAsFixed(2)}',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        color: _dark,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // ── Card 2: ค่าสี RGB ────────────────────────────────────────
              _buildCard(
                icon: Icons.palette_outlined,
                iconColor: const Color(0xFFEF4444),
                title: 'ค่าเฉลี่ยสีปริภูมิ RGB (Mean RGB)',
                child: Column(
                  children: [
                    _buildMetricRow('Red (แดง)', '${result.rgb.r.round()}', const Color(0xFFEF4444)),
                    const Divider(height: 16, color: Color(0xFFF3F4F6)),
                    _buildMetricRow('Green (เขียว)', '${result.rgb.g.round()}', const Color(0xFF10B981)),
                    const Divider(height: 16, color: Color(0xFFF3F4F6)),
                    _buildMetricRow('Blue (น้ำเงิน)', '${result.rgb.b.round()}', const Color(0xFF3B82F6)),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // ── Card 3: ค่าสี CIELAB ─────────────────────────────────────
              _buildCard(
                icon: Icons.science_outlined,
                iconColor: const Color(0xFF8B5CF6),
                title: 'ค่าสีมาตรฐาน CIELAB (CIE 1976 D65)',
                child: Column(
                  children: [
                    _buildMetricRow('L* (ความสว่าง 0-100)', '${result.cielab.l.round()}', _dark),
                    const Divider(height: 16, color: Color(0xFFF3F4F6)),
                    _buildMetricRow('a* (แกนสีเขียว - แดง)', '${result.cielab.a.round()}', const Color(0xFFDC2626)),
                    const Divider(height: 16, color: Color(0xFFF3F4F6)),
                    _buildMetricRow('b* (แกนสีน้ำเงิน - เหลือง)', '${result.cielab.b.round()}', const Color(0xFFD97706)),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // ── Card 4: Chroma & Hue Angle ──────────────────────────────
              _buildCard(
                icon: Icons.tune_rounded,
                iconColor: const Color(0xFF059669),
                title: 'คุณลักษณะเชิงสี (Color Attributes)',
                child: Column(
                  children: [
                    _buildMetricRow('Chroma C* (ความสดของสี)', result.cielab.chroma.toStringAsFixed(2), _dark),
                    const Divider(height: 16, color: Color(0xFFF3F4F6)),
                    _buildMetricRow('Hue Angle h° (มุมโทนสี)', '${result.cielab.hueAngle.toStringAsFixed(2)}°', _dark),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // ── Card 5: คำอธิบายทางเทคนิค ────────────────────────────────
              _buildCard(
                icon: Icons.info_outline,
                iconColor: _gray,
                title: 'คำอธิบายทางเทคนิค',
                child: Text(
                  'คะแนนระดับพัดสีไข่แดง (DSM Yolk Color Fan 1–15) ถูกประเมินด้วยโมเดล Support Vector Regression (SVR) แบบ RBF Kernel บนสมาร์ตโฟนโดยตรง (Edge AI) โดยสกัดค่าเฉลี่ยสีเฉพาะบริเวณกึ่งกลางวงกลม Center Circular Mask 42% เพื่อป้องกันสัญญาณรบกวนและแสงสะท้อน',
                  style: GoogleFonts.kanit(
                    fontSize: 13,
                    color: const Color(0xFF4B5563),
                    height: 1.6,
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.kanit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _dark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.kanit(fontSize: 13, color: const Color(0xFF4B5563)),
        ),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
