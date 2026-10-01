# 🥚 Egg Yolk Color Predictor (Mobile App)

แอปพลิเคชันบนมือถือ (พัฒนาด้วย Flutter) สำหรับประเมินระดับสีของไข่แดงเทียบกับมาตรฐาน **DSM Yolk Color Fan (สเกล 1-15)** จากภาพถ่าย

## ✨ ฟีเจอร์หลัก (Key Features)

* 🤖 **On-Device AI (100% Offline)**: ประมวลผลและทำนายคะแนนด้วยโมเดล SVR (Support Vector Regression) ภายในตัวมือถือโดยไม่ต้องใช้อินเทอร์เน็ต
* 🎯 **Auto Yolk Detection**: ระบบค้นหาและตีกรอบไข่แดงอัตโนมัติด้วยอัลกอริทึม Connected Component (Flood-Fill)
* 🎨 **Color Science**: สกัดค่าสี RGB พื้นฐาน และแปลงเป็นมาตรฐาน CIELAB (CIE 1976 D65) อย่างแม่นยำเต็มสเกลทศนิยม
* ☁️ **API Mode**: สามารถสลับโหมดไปใช้การประมวลผลผ่าน Backend (FastAPI Python) ได้
* ⚡ **Performance Optimized**: ไม่มีปัญหา Memory Leak จากการสร้างไฟล์ภาพชั่วคราวซ้ำซ้อน และลบโค้ดที่ไม่ได้ใช้ออกทั้งหมด

## 🚀 การติดตั้งและการใช้งาน (Getting Started)

### สิ่งที่ต้องเตรียม
* [Flutter SDK](https://flutter.dev/) (อัปเดตล่าสุด)
* Android Emulator หรือมือถือ Android เครื่องจริง

### วิธีการรันแอปพลิเคชัน
1. ติดตั้งแพ็กเกจที่จำเป็นทั้งหมด:
   ```bash
   flutter pub get
   ```
2. รันแอปพลิเคชันเพื่อทดสอบ:
   ```bash
   flutter run
   ```
3. สร้างไฟล์ `.apk` สำหรับนำไปติดตั้งใช้งานจริงบนมือถือ:
   ```bash
   flutter build apk --release
   ```

## 🛠️ โครงสร้างไฟล์ที่สำคัญ (Core Architecture)

* **`lib/services/local_predict_service.dart`**: หัวใจหลักของ On-Device AI ทำหน้าที่อ่านพารามิเตอร์จาก `assets/model_weights.json` และคำนวณสมการ SVR ด้วยคณิตศาสตร์
* **`lib/services/auto_crop_service.dart`**: อัลกอริทึมสำหรับค้นหาพิกัดไข่แดงบนภาพอัตโนมัติ
* **`lib/services/api_service.dart`**: ระบบเชื่อมต่อกับเซิร์ฟเวอร์ Backend (เมื่อเปิดใช้งาน API Mode)
* **`lib/screens/`**: ส่วนของ User Interface (UI) ทั้งหมด เช่น หน้าตีกรอบภาพ หน้าแสดงคะแนน และหน้าข้อมูลวิทยาศาสตร์เชิงลึก

## 🔄 การตั้งค่า Backend API (สำหรับเครื่องจริง)
หากต้องการใช้งานแอปโดยเปิดโหมดประมวลผลบนเซิร์ฟเวอร์ (API) คุณต้องเข้าไปแก้ไข IP Address ของเซิร์ฟเวอร์ที่ไฟล์:
`lib/services/api_service.dart`
ให้ตรงกับ IP ในวง LAN ของเครื่องคอมพิวเตอร์ที่รัน FastAPI รันอยู่ (เช่น `http://192.168.1.100:8000`)
