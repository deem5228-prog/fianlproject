import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../services/api_service.dart';
import '../services/local_predict_service.dart';
import '../models/prediction_result.dart';
import 'crop_screen.dart';
import 'result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  bool _useLocalModel = true;
  final TextEditingController _urlController =
      TextEditingController(text: ApiService.baseUrl);

  // Top Banner Notification Animation
  late final AnimationController _bannerController;
  late final Animation<Offset> _bannerSlideAnimation;
  late final Animation<double> _bannerFadeAnimation;
  Timer? _bannerTimer;
  String _bannerMessage = '';
  List<Color> _bannerColors = const [Color(0xFF059669), Color(0xFF10B981)];
  IconData _bannerIcon = Icons.check;

  // ── Design tokens (เพิ่มใหม่) ──────────────────────────────────────────
  static const Color _amber = Color(0xFFE8A020); // สีหลัก amber
  static const Color _bg    = Color(0xFFFAF5EB); // พื้นหลัง cream อุ่น
  static const Color _dark  = Color(0xFF1A1A1A); // ตัวอักษร/icon เข้ม

  @override
  void initState() {
    super.initState();
    _bannerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _bannerSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.8),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _bannerController,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeInCubic,
      ),
    );
    _bannerFadeAnimation = CurvedAnimation(
      parent: _bannerController,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void _triggerTopNotification(
    String message, {
    List<Color>? colors,
    IconData icon = Icons.check,
  }) {
    if (!mounted) return;
    setState(() {
      _bannerMessage = message;
      _bannerColors = colors ?? const [Color(0xFF059669), Color(0xFF10B981)];
      _bannerIcon = icon;
    });
    _bannerController.forward(from: 0.0);
    _bannerTimer?.cancel();
    _bannerTimer = Timer(const Duration(milliseconds: 2600), () {
      if (mounted) {
        _bannerController.reverse();
      }
    });
  }

  // ─── Logic ทุกตัวเหมือนเดิม 100% ────────────────────────────────────────
  Future<void> _pickAndProcessImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 90,
      );
      if (pickedFile == null) return;
      if (!mounted) return;

      final File originalFile = File(pickedFile.path);
      final File? croppedFile = await Navigator.push<File?>(
        context,
        MaterialPageRoute(builder: (_) => CropScreen(imageFile: originalFile)),
      );
      if (croppedFile == null) return;
      if (!mounted) return;

      setState(() => _isLoading = true);

      final PredictionResult result = _useLocalModel
          ? await LocalPredictService.predictImage(croppedFile)
          : await ApiService.predictImage(croppedFile);

      if (!mounted) return;
      setState(() => _isLoading = false);

      // รอจนผู้ใช้ออกจาก ResultScreen แล้วค่อยลบ temp file
      // (ถ้าลบก่อน Image.file() ใน ResultScreen จะไม่มีรูปให้แสดง)
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(imageFile: croppedFile, result: result),
        ),
      );

      // ลบ temp file หลัง ResultScreen ถูก pop แล้ว
      _deleteTempFile(croppedFile);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _triggerTopNotification(
        'เกิดข้อผิดพลาด: ${e.toString().replaceAll('Exception: ', '')}',
        colors: const [Color(0xFFB91C1C), Color(0xFFEF4444)],
        icon: Icons.error_outline,
      );
    }
  }

  /// ลบ temp file ที่ CropScreen สร้างไว้ — เรียกหลัง ResultScreen ถูก pop แล้วเท่านั้น
  void _deleteTempFile(File file) {
    file.exists().then((exists) {
      if (exists) file.delete().ignore();
    }).ignore();
  }

  void _showSettingsDialog() {
    bool tempUseLocal = _useLocalModel;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'ตั้งค่าระบบประมวลผล',
            style: GoogleFonts.kanit(color: _dark, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: tempUseLocal
                        ? const Color(0xFFECFDF5)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: tempUseLocal
                          ? const Color(0xFF10B981)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        tempUseLocal ? Icons.bolt : Icons.cloud_outlined,
                        color: tempUseLocal
                            ? const Color(0xFF059669)
                            : Colors.blueGrey,
                        size: 28,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tempUseLocal
                                  ? 'On-Device AI (ออฟไลน์)'
                                  : 'Backend API (คลาวด์)',
                              style: GoogleFonts.kanit(
                                  fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            Text(
                              tempUseLocal
                                  ? 'คำนวณในมือถือ ไม่ต้องต่อเน็ต'
                                  : 'ยิงวิเคราะห์ผ่านเซิร์ฟเวอร์ FastAPI',
                              style: GoogleFonts.kanit(
                                  fontSize: 11, color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: tempUseLocal,
                        activeTrackColor: const Color(0xFF10B981),
                        onChanged: (val) =>
                            setDialogState(() => tempUseLocal = val),
                      ),
                    ],
                  ),
                ),
                if (!tempUseLocal) ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: _urlController,
                    style: GoogleFonts.outfit(color: _dark),
                    decoration: InputDecoration(
                      labelText: 'API Base URL',
                      labelStyle: GoogleFonts.kanit(color: Colors.black54),
                      hintText: 'http://10.0.2.2:8000',
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF1A1A1A)),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color(0xFFFFC93C), width: 2),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('ยกเลิก',
                  style: GoogleFonts.kanit(color: Colors.black54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: _dark),
              onPressed: () {
                setState(() {
                  _useLocalModel = tempUseLocal;
                  ApiService.baseUrl = _urlController.text.trim();
                });
                Navigator.pop(context);
                if (_useLocalModel) {
                  _triggerTopNotification(
                    'สลับเป็นโหมด On-Device AI (ออฟไลน์ 100%) เรียบร้อย',
                    colors: const [Color(0xFF059669), Color(0xFF10B981)],
                    icon: Icons.bolt,
                  );
                } else {
                  _triggerTopNotification(
                    'สลับเป็นโหมด Backend API (${ApiService.baseUrl}) เรียบร้อย',
                    colors: const [Color(0xFF1E3A5F), Color(0xFF2563EB)],
                    icon: Icons.cloud_outlined,
                  );
                }
              },
              child: Text('บันทึก', style: GoogleFonts.kanit(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Build ───────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,                                  // ← cream แทน white
      appBar: AppBar(
        backgroundColor: _bg,                               // ← ให้กลืนกับพื้นหลัง
        elevation: 0,
        surfaceTintColor: Colors.transparent,               // ← ป้องกัน M3 tint
        title: Text(
          'Egg Yolk Analyzer',
          style: GoogleFonts.kanit(
              fontSize: 18, fontWeight: FontWeight.bold, color: _dark),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: _dark),
            onPressed: _showSettingsDialog,
          ),
        ],
      ),
      body: Stack(
        children: [
          _isLoading ? _buildLoading() : _buildBody(),
          _buildTopBannerNotification(),
        ],
      ),
    );
  }

  Widget _buildTopBannerNotification() {
    return Positioned(
      top: 10,
      left: 16,
      right: 16,
      child: AnimatedBuilder(
        animation: _bannerController,
        builder: (context, child) {
          if (_bannerController.value == 0.0) {
            return const SizedBox.shrink();
          }
          return SlideTransition(
            position: _bannerSlideAnimation,
            child: FadeTransition(
              opacity: _bannerFadeAnimation,
              child: child,
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: _bannerColors),
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [
              BoxShadow(
                color: Color(0x55000000),
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: const BoxDecoration(
                  color: Colors.white24,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _bannerIcon,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  _bannerMessage,
                  style: GoogleFonts.kanit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Loading (ปรับสีให้ match theme) ────────────────────────────────────
  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SpinKitThreeBounce(color: _amber, size: 40.0),    // ← amber แทน yellow
          const SizedBox(height: 24),
          Text(
            'กำลังสกัดค่าสีและทำนายผล...',
            style: GoogleFonts.kanit(fontSize: 16, color: _dark),
          ),
        ],
      ),
    );
  }

  // ─── Body ────────────────────────────────────────────────────────────────
  Widget _buildBody() {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: ConstrainedBox(
              // ทำให้ Column ขยายได้เต็มความสูงหน้าจอ แต่ยังเลื่อนได้เมื่อจอเล็ก
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // ── Illustration + Title ──────────────────────────────────────
                    Center(
                      child: Column(
                        children: [
                          _buildYolkLogo(),
                          const SizedBox(height: 14),
                          Text(
                            'ระบบประเมิน\nคะแนนพัดสีไข่แดง',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.kanit(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: _dark,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Steps ─────────────────────────────────────────────────────
                    _buildStepRow('1.', 'เลือกวิธีนำเข้าภาพจากการถ่ายรูปหรือคลังรูปภาพ'),
                    const SizedBox(height: 12),
                    _buildStepRow('2.', 'รอระบบวิเคราะห์'),
                    const SizedBox(height: 12),
                    _buildStepRow('3.', 'เมื่อวิเคราะห์เสร็จจะปรากฏคะแนนสีของไข่แดง'),

                    // ← Spacer ถูกแทนที่ด้วย Expanded (ใช้ได้ภายใน IntrinsicHeight)
                    const Expanded(child: SizedBox(height: 28)),

                    // ── ปุ่มถ่ายภาพ (amber filled) ───────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _amber,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () => _pickAndProcessImage(ImageSource.camera),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.camera_alt_outlined, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'ถ่ายภาพด้วยกล้อง',
                              style: GoogleFonts.kanit(
                                  fontSize: 15, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // ── ปุ่มคลัง (white outlined) ─────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _dark,
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Color(0xFFD1D5DB)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () => _pickAndProcessImage(ImageSource.gallery),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.photo_library_outlined, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'เลือกจากคลังรูปภาพ',
                              style: GoogleFonts.kanit(
                                  fontSize: 15, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32), // เพิ่มระยะห่างด้านล่างแทนที่กล่องเดิม

                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── Step row (signature เหมือนเดิม แค่ redesign visual) ────────────────
  Widget _buildStepRow(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: const Color(0xFFFDE68A),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              number.replaceAll('.', ''), // "1." → "1"
              style: GoogleFonts.kanit(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF854D0E),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              text,
              style: GoogleFonts.kanit(
                fontSize: 13,
                color: const Color(0xFF3C3C3C),
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Egg Yolk Logo (Minimalist มนสวย สอดคล้องกับ Splash Screen) ────────
  Widget _buildYolkLogo() {
    return Container(
      width: 84,
      height: 84,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFE8DEC8).withValues(alpha: 0.6),
      ),
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ไข่ขาว
          Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                color: const Color(0xFFFDE68A),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          // ไข่แดง
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: _amber,
            ),
          ),
          // Highlight บนไข่แดง
          Positioned(
            left: 26,
            top: 24,
            child: Container(
              width: 12,
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFFFCD34D),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}