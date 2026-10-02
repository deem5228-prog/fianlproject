# 🥚 Egg Yolk Color Predictor (Full Project)

โปรเจกต์ระบบทำนายระดับสีไข่แดง (DSM Yolk Color Fan Score 1-15) แบบครบวงจร ประกอบไปด้วยส่วนการวิจัยและเทรนโมเดล (Machine Learning), ระบบ Backend API (FastAPI), และแอปพลิเคชันมือถือ (Flutter) ที่ทำงานด้วย AI แบบออฟไลน์ 100%

## 🗂️ โครงสร้างและแผนผังโปรเจกต์ (Project Structure)

```text
egg_yolk_final_project/
├── README.md                      # เอกสารสรุปโครงงานและคู่มือการใช้งาน
│
├── 🧠 model_dev/                  # กระบวนการพัฒนาโมเดล AI และ Data Pipeline
│   ├── batch_auto_crop.py         # ขั้นตอนที่ 1: ตรวจจับและครอบตัดภาพไข่แดงทั้งชุดข้อมูลอัตโนมัติ
│   ├── build_features.py          # ขั้นตอนที่ 2: สกัดค่าสี RGB และ CIELAB (Circular Mask 42%) บันทึกเป็น CSV
│   ├── color_service.py           # โมดูลฟังก์ชันหลักสำหรับการคำนวณสี HSV และ CIELAB (CIE D65)
│   ├── compare_crop_experiments.py# สคริปต์เปรียบเทียบผลการทดลอง Auto-Crop vs ภาพดั้งเดิม
│   ├── train_compare_models.py    # ขั้นตอนที่ 3: แข่งขันและเปรียบเทียบโมเดล Machine Learning 6 อัลกอริทึม
│   ├── export_best_model.py       # ขั้นตอนที่ 4: ส่งออกโมเดล SVR เป็น model_weights.json และ model.pkl
│   │
│   ├── test_hsv_equivalence.py    # ชุดทดสอบ A: ยืนยันความตรงกันของ HSV Mask กับ OpenCV 100%
│   ├── test_lab_equivalence.py    # ชุดทดสอบ B: ยืนยันความตรงกันของ CIELAB กับ Scikit-image (diff < 0.01)
│   ├── test_crop_consistency.py   # ชุดทดสอบ C: ยืนยันความแม่นยำของการครอปภาพจริง 5 ภาพ
│   ├── test_score_comparison.py   # ชุดทดสอบ D: ยืนยันคะแนนทำนาย SVR ตรงกัน 20 ภาพ (diff < 0.1)
│   │
│   ├── data/                      # ชุดข้อมูลและตารางฟีเจอร์ (features.csv, crop_comparison_results.csv)
│   ├── plots/                     # กราฟสรุปผลการวิจัย 12 รูปภาพ สำหรับนำไปใส่เล่มรายงาน
│   ├── model.pkl                  # โมเดล Scikit-Learn Pipeline ที่เทรนสมบูรณ์แล้ว
│   ├── model_weights.json         # ค่าพารามิเตอร์คณิตศาสตร์ SVR สำหรับ Mobile App
│   ├── ml_presentation.html       # หน้าเว็บสไลด์นำเสนอผลงานวิจัยแบบ Interactive
│   ├── ML_PIPELINE_TUTORIAL.md    # คู่มืออธิบายหลักการทางคณิตศาสตร์อย่างละเอียด
│   └── requirements.txt           # ไลบรารี Python ที่จำเป็น (opencv, scikit-learn, scikit-image)
│
├── 🌐 egg_api/                    # ระบบ Backend REST API (FastAPI) และเว็บแอปพลิเคชัน
│   ├── main.py                    # จุดเริ่มต้นเซิร์ฟเวอร์ FastAPI พร้อม CORS & Swagger Docs
│   ├── routers/predict.py         # API Endpoint POST /api/predict ทำนายคะแนนจากรูปภาพ
│   ├── schemas.py                 # โครงสร้าง Pydantic Data Model สำหรับ Request/Response
│   ├── services/                  # เซอร์วิสประมวลผลภาพ สกัดสี และทำนายผลด้วยโมเดล SVR
│   ├── web_app.html               # เว็บแอปพลิเคชัน HTML5/JS สำหรับทดสอบทำนายผ่าน Browser
│   └── requirements.txt           # ไลบรารี Python สำหรับรัน FastAPI Backend
│
└── 📱 egg_yolk_app/               # แอปพลิเคชันมือถือ Flutter (100% On-Device AI)
    ├── assets/
    │   └── model_weights.json     # โมเดลสมองกล SVR 107 KB ฝังในตัวแอป
    ├── lib/                       
    ├── test/                      # ชุด Unit Test บน Flutter (ผ่าน 100%)
    └── pubspec.yaml               # การกำหนดค่าและ Assets ของแอป Flutter
```

## 🚀 การใช้งานแต่ละส่วน

* **[📱 แอปมือถือ (egg_yolk_app)](egg_yolk_app/README.md)**: คลิกเพื่อดูวิธีติดตั้ง รันแอปพลิเคชัน Flutter และสร้างไฟล์ APK
* **[🌐 เซิร์ฟเวอร์ (egg_api)](egg_api/)**: ส่วนสำหรับเปิดใช้งาน REST API Backend ด้วย Python FastAPI
* **[🧠 การวิจัย (model_dev)](model_dev/)**: ดูขั้นตอนการสกัดสีจากภาพและโค้ดเทรนโมเดล SVR ทั้งหมด
