# 🥚 ระบบประเมินสีไข่แดง (Egg Yolk Color Predictor)

ระบบทำนายระดับสีไข่แดงตามมาตรฐาน **DSM Yolk Color Fan (สเกล 1–15)** จากภาพถ่าย โดยใช้การสกัดค่าสีมาตรฐาน CIELAB และโมเดล Machine Learning แบบ SVR (Support Vector Regression) โปรเจกต์นี้ประกอบด้วย 3 ส่วนหลักที่ทำงานร่วมกัน ตั้งแต่การวิจัยพัฒนาโมเดล ไปจนถึงแอปมือถือที่ใช้งานได้จริงแบบออฟไลน์

---

## 📁 โครงสร้างโปรเจกต์ทั้งหมด

```
egg_yolk_final_project/
│
├── README.md                        ← ไฟล์นี้ (คู่มือและภาพรวมโปรเจกต์)
├── requirements.txt                 ← รายการไลบรารี Python รวมของทั้งโปรเจกต์
├── presentation.html                ← สไลด์นำเสนอผลงานวิจัย (HTML แบบ Interactive)
├── ml_presentation_slides.html      ← สไลด์ ML Pipeline ฉบับโดยละเอียด (HTML)
│
├── 🧠 model_dev/                    ← ส่วนวิจัย: เตรียมข้อมูล เทรน และส่งออกโมเดล AI
├── 🌐 egg_api/                      ← ส่วน Backend: REST API สำหรับทำนายผลจากรูปภาพ
└── 📱 egg_yolk_app/                 ← ส่วนแอป: Flutter App (100% Offline On-Device AI)
```

---

## 🧠 ส่วนที่ 1: model_dev/ — การวิจัยและพัฒนาโมเดล AI

โฟลเดอร์นี้เก็บกระบวนการทำงานทั้งหมดตั้งแต่ต้นจนจบในการสร้างโมเดล AI

### Pipeline หลัก (ทำงานตามลำดับ)

| ไฟล์ | หน้าที่ |
|---|---|
| `batch_auto_crop.py` | **ขั้นตอนที่ 1** — ประมวลภาพไข่แดงทั้งชุดข้อมูล ตรวจจับไข่แดงอัตโนมัติด้วย HSV Color Mask + Flood-Fill แล้ว Crop เฉพาะส่วนไข่แดงออกมาบันทึกเป็นไฟล์ใหม่ |
| `build_features.py` | **ขั้นตอนที่ 2** — สกัดค่าสี RGB เฉลี่ยและค่าสี CIELAB (L\*, a\*, b\*) ด้วย Circular Mask 42% จากกลางภาพ บันทึกผลลัพธ์เป็น `data/features.csv` |
| `train_compare_models.py` | **ขั้นตอนที่ 3** — แข่งขันและเปรียบเทียบประสิทธิภาพของโมเดล ML 6 ประเภท (Linear, Ridge, Lasso, KNN, SVR, Random Forest) โดยใช้ Cross-Validation |
| `export_best_model.py` | **ขั้นตอนที่ 4** — ส่งออกโมเดล SVR ที่ดีที่สุดในรูปแบบ 2 รูปแบบ คือ `model.pkl` (สำหรับ Python) และ `model_weights.json` (สำหรับ Mobile App) |

### โมดูลและบริการเสริม

| ไฟล์ | หน้าที่ |
|---|---|
| `color_service.py` | โมดูลกลางสำหรับคำนวณสีทุกประเภท (RGB → HSV, RGB → CIELAB D65, Chroma, Hue Angle) ใช้ร่วมกันระหว่างขั้นตอนต่างๆ |
| `compare_crop_experiments.py` | สคริปต์ทดลองเปรียบเทียบผลการ Crop แบบต่างๆ เพื่อหาวิธีที่ดีที่สุดก่อนใช้งานจริง |
| `stats_inspect.py` | สคริปต์สำรวจสถิติเบื้องต้นของข้อมูล (Distribution, Outlier, Correlation) |

### การสร้างกราฟและรายงาน

| ไฟล์ | หน้าที่ |
|---|---|
| `generate_plots.py` | สร้างกราฟพื้นฐาน (Scatter Plot, Residual Plot) สำหรับวิเคราะห์ผลโมเดล |
| `generate_feature_plots.py` | สร้างกราฟแสดงความสัมพันธ์ระหว่างค่าสีแต่ละช่อง (L\*, a\*, b\*) กับคะแนน DSM |
| `generate_all_plots.py` | รันสร้างกราฟทุกประเภทพร้อมกันในครั้งเดียว บันทึกผลลงโฟลเดอร์ `plots/` |
| `plot_detailed_tube_count.py` | กราฟแสดงการกระจายตัวของตัวอย่างในแต่ละช่วงคะแนน (1-15) |
| `plot_real_svr_visual.py` | กราฟภาพแสดงการทำงานของ SVR ในมิติ 2D สำหรับอธิบายในรายงาน |
| `plot_updated_svr_tube.py` | กราฟ SVR ฉบับอัปเดตพร้อม Decision Boundary |

### ชุดทดสอบความถูกต้อง (Validation Tests)

| ไฟล์ | หน้าที่ |
|---|---|
| `test_hsv_equivalence.py` | ยืนยันว่าสูตร HSV Mask ใน Python ตรงกับผลของ OpenCV 100% |
| `test_lab_equivalence.py` | ยืนยันว่าสูตรแปลง CIELAB ใน Python ตรงกับ Scikit-image (ต่างกันไม่เกิน 0.01) |
| `test_crop_consistency.py` | ยืนยันว่าการ Crop ภาพได้ผลสม่ำเสมอบนภาพจริง 5 ภาพ |
| `test_score_comparison.py` | ยืนยันว่าคะแนนทำนายของโมเดล Python ตรงกับโมเดลบนมือถือ (ต่างกันไม่เกิน 0.1) |

### เอกสารและโมเดลที่สร้างเสร็จแล้ว

| ไฟล์ | หน้าที่ |
|---|---|
| `model.pkl` | ไฟล์โมเดล Scikit-Learn Pipeline พร้อมใช้งาน (ใช้ใน Python โดยตรง) |
| `model_weights.json` | ค่าพารามิเตอร์คณิตศาสตร์ SVR ในรูปแบบ JSON (ส่งออกไปใช้ในมือถือ) |
| `models/best_model.joblib` | โมเดลที่เซฟในรูปแบบ Joblib (สำรองสำหรับโหลดเร็วกว่า Pickle) |
| `ML_PIPELINE_TUTORIAL.md` | คู่มือการอธิบายหลักการ ML Pipeline ทั้งหมดแบบละเอียด |
| `ml_pipeline_tutorial.html` | คู่มือเดิมแต่ในรูปแบบ HTML อ่านสวยงามในเบราว์เซอร์ |
| `ml_presentation.html` | สไลด์นำเสนอผลงาน ML แบบ Interactive สำหรับพรีเซนต์ |
| `ml_slides.html` | สไลด์ ML อีกเวอร์ชันสำหรับใช้ในสถานการณ์ต่างๆ |
| `README.md` | คู่มือสำหรับโฟลเดอร์ model_dev โดยเฉพาะ |
| `requirements.txt` | ไลบรารี Python ที่ต้องติดตั้ง (opencv-python, scikit-learn, scikit-image, matplotlib) |
| `data/` | โฟลเดอร์ชุดข้อมูล (features.csv, crop_comparison_results.csv, รูปภาพตัวอย่าง) |
| `plots/` | โฟลเดอร์กราฟผลลัพธ์ทั้งหมด 12+ รูป สำหรับใส่รายงาน |

---

## 🌐 ส่วนที่ 2: egg_api/ — Backend REST API (FastAPI)

ระบบเซิร์ฟเวอร์ Python สำหรับให้แอปมือถือส่งรูปภาพมาแล้วรับคะแนนกลับ (สำหรับโหมด Online/API)

| ไฟล์ | หน้าที่ |
|---|---|
| `main.py` | จุดเริ่มต้นเซิร์ฟเวอร์ FastAPI — ตั้งค่า CORS, เปิด Swagger Docs ที่ `/docs`, โหลดโมเดลเมื่อเริ่มระบบ |
| `schemas.py` | กำหนดโครงสร้างข้อมูล (Pydantic Model) สำหรับ Request และ Response ของ API |
| `routers/predict.py` | API Endpoint หลัก `POST /api/predict` — รับไฟล์รูปภาพ, ตรวจสอบขนาดไฟล์ (ป้องกัน DoS), ส่งต่อให้ประมวลผล |
| `services/color_service.py` | เซอร์วิสสกัดค่าสีจากรูปภาพ: แปลง RGB → CIELAB, คำนวณ Chroma, Hue Angle |
| `services/predict_service.py` | เซอร์วิสโหลดโมเดล `.pkl` และทำนายคะแนน DSM จากค่าสีที่สกัดมา |
| `web_app.html` | เว็บแอปพลิเคชัน HTML5/JS แบบ Drag & Drop สำหรับทดสอบ API ผ่านเบราว์เซอร์โดยไม่ต้องใช้มือถือ |
| `requirements.txt` | ไลบรารี Python สำหรับ Backend (fastapi, uvicorn, python-multipart, opencv-python, scikit-learn) |

### วิธีเปิดใช้งาน Backend API

```bash
cd egg_api
pip install -r requirements.txt
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

เปิดเบราว์เซอร์ไปที่ `http://localhost:8000/docs` เพื่อดู API Document แบบ Interactive

---

## 📱 ส่วนที่ 3: egg_yolk_app/ — แอปพลิเคชันมือถือ (Flutter)

แอปมือถือ Android พัฒนาด้วย Flutter ที่ฝังโมเดล AI ไว้ในตัว ทำงานได้โดยไม่ต้องเชื่อมต่ออินเทอร์เน็ต

### ไฟล์ตั้งค่าโปรเจกต์

| ไฟล์ | หน้าที่ |
|---|---|
| `pubspec.yaml` | ไฟล์กำหนดค่าหลักของแอป Flutter — ชื่อแอป, เวอร์ชัน, รายการ Dependencies และ Assets |
| `pubspec.lock` | ไฟล์ล็อคเวอร์ชันของทุก Package (สร้างอัตโนมัติ ไม่ต้องแก้ไขเอง) |
| `README.md` | คู่มือสำหรับส่วนแอปโดยเฉพาะ |

### Assets (ทรัพยากรในตัวแอป)

| ไฟล์ | หน้าที่ |
|---|---|
| `assets/model_weights.json` | **หัวใจของ On-Device AI** — ไฟล์พารามิเตอร์โมเดล SVR ขนาด ~107 KB ถูกฝังไว้ในตัวแอปให้คำนวณได้โดยไม่ต้องออนไลน์ |

### lib/ — โค้ดหลักของแอป

**จุดเริ่มต้น**

| ไฟล์ | หน้าที่ |
|---|---|
| `lib/main.dart` | จุดเริ่มต้นแอป — ตั้งค่า Theme สีครีม/แอมเบอร์, กำหนด Font (Kanit/Outfit), เปิด SplashScreen |

**Models (โครงสร้างข้อมูล)**

| ไฟล์ | หน้าที่ |
|---|---|
| `lib/models/prediction_result.dart` | คลาสสำหรับเก็บผลลัพธ์ทำนาย — คะแนน DSM, Raw Score, ค่า RGB, ค่า CIELAB รองรับทั้งผลจาก API และการคำนวณในเครื่อง |

**Services (บริการเบื้องหลัง)**

| ไฟล์ | หน้าที่ |
|---|---|
| `lib/services/local_predict_service.dart` | **หัวใจของ On-Device AI** — โหลด `model_weights.json`, สกัดสี RGB เฉลี่ยด้วย Circular Mask 42%, แปลง RGB → CIELAB ด้วยคณิตศาสตร์ล้วนๆ, คำนวณสมการ SVR RBF Kernel เพื่อทำนายคะแนน |
| `lib/services/auto_crop_service.dart` | ระบบหาพิกัดไข่แดงอัตโนมัติ — แปลงภาพเป็น Grayscale ย่อขนาดเพื่อความเร็ว, ใช้ Flood-Fill (BFS) หาก้อนสีไข่แดงในภาพ, คืนค่าพิกัด Bounding Box สำหรับวาดวงกลมบนหน้าจอ |
| `lib/services/api_service.dart` | เซอร์วิสสื่อสารกับ Backend — ส่งรูปภาพผ่าน HTTP Multipart POST ไปยัง FastAPI, รองรับทั้ง Android Emulator (`10.0.2.2`) และเครื่องจริง |

**Screens (หน้าจอต่างๆ)**

| ไฟล์ | หน้าที่ |
|---|---|
| `lib/screens/splash_screen.dart` | หน้าเปิดแอป — แสดงโลโก้และชื่อแอป พร้อมโหลดโมเดล AI ล่วงหน้าในเบื้องหลัง เพื่อให้หน้าหลักพร้อมใช้งานทันที |
| `lib/screens/home_screen.dart` | หน้าหลัก — ปุ่ม "ถ่ายภาพด้วยกล้อง" และ "เลือกจากคลังรูปภาพ", จัดการ Permission กล้อง, ส่งต่อภาพไปหน้า Crop |
| `lib/screens/crop_screen.dart` | หน้าตีกรอบ — วาดวงกลมสีส้มให้ผู้ใช้ลากครอบไข่แดง, เรียก `AutoCropService` วางวงกลมอัตโนมัติ, Crop ภาพเมื่อกดยืนยัน (พร้อม Padding 8%) |
| `lib/screens/result_screen.dart` | หน้าผลลัพธ์หลัก — แสดงคะแนน DSM ขนาดใหญ่บน Card สีแอมเบอร์, ตาราง RGB และ CIELAB, ค่า Chroma และ Hue Angle |
| `lib/screens/detail_screen.dart` | หน้ารายละเอียดวิทยาศาสตร์ — อธิบายความหมายของค่าสี, Bar Chart เปรียบเทียบค่าสี, คำอธิบายหลักการทำงานของโมเดล |

### test/ — ชุดทดสอบอัตโนมัติ

| ไฟล์ | หน้าที่ |
|---|---|
| `test/yolk_detector_test.dart` | ทดสอบความแม่นยำของการแปลง CIELAB, ทดสอบ Fallback ของ AutoCropService เมื่อหาไข่แดงไม่พบ |
| `test/on_device_verification_test.dart` | ทดสอบยืนยันว่าผลการคำนวณบนมือถือ (Dart) ตรงกับผลการคำนวณใน Python ในระดับความคลาดเคลื่อนไม่เกิน 0.1 |

---

## ⚙️ วิธีติดตั้งและรันแอปมือถือ

```bash
cd egg_yolk_app
flutter pub get       # ติดตั้ง Package ทั้งหมด
flutter run           # รันบน Emulator หรือมือถือที่ต่ออยู่
flutter test          # รัน Unit Test ทั้งหมด
flutter build apk --release   # สร้างไฟล์ .apk สำหรับนำไปติดตั้งในมือถือ Android
```

ไฟล์ APK สำเร็จรูปจะอยู่ที่:
`egg_yolk_app/build/app/outputs/flutter-apk/app-release.apk`

---

## 🔄 ภาพรวมการทำงานของระบบ

```
ผู้ใช้ถ่ายรูปไข่แดง
        ↓
[Crop Screen] — AutoCropService วางวงกลมอัตโนมัติ
        ↓
ผู้ใช้กดยืนยัน — ตัดเฉพาะส่วนไข่แดง (+ Padding 8%)
        ↓
    ┌─────────────────────────────────┐
    │  โหมด Offline (On-Device AI)   │  ← ค่าเริ่มต้น
    │  LocalPredictService            │
    │  · Circular Mask 42% → RGB     │
    │  · RGB → CIELAB (CIE D65)      │
    │  · CIELAB → SVR → คะแนน DSM   │
    └─────────────────────────────────┘
              หรือ
    ┌─────────────────────────────────┐
    │  โหมด Online (Backend API)     │
    │  ApiService → FastAPI Server   │
    │  → color_service.py            │
    │  → predict_service.py (model.pkl)│
    └─────────────────────────────────┘
        ↓
[Result Screen] แสดงคะแนน DSM Fan Score (1-15)
        ↓
[Detail Screen] ดูค่า RGB, CIELAB, Chroma, Hue เพิ่มเติม
```
