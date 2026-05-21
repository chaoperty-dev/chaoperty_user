# Chaoperty User — สรุปโปรเจค

> **Version:** 1.0.9+9 | **Framework:** Flutter (Dart 3.6+) | **วันที่วิเคราะห์:** 25 เมษายน 2569

---

## สารบัญ

1. [ภาพรวมโปรเจค](#1-ภาพรวมโปรเจค)
2. [โครงสร้างไดเรกทอรี](#2-โครงสร้างไดเรกทอรี)
3. [Tech Stack และ Dependencies หลัก](#3-tech-stack-และ-dependencies-หลัก)
4. [สถาปัตยกรรมและ State Management](#4-สถาปัตยกรรมและ-state-management)
5. [ฟีเจอร์หลัก](#5-ฟีเจอร์หลัก)
6. [ระบบ PDF Generation](#6-ระบบ-pdf-generation)
7. [ระบบชำระเงิน](#7-ระบบชำระเงิน)
8. [API Integration & Security](#8-api-integration--security)
9. [Multi-Language Support](#9-multi-language-support)
10. [Platform Support & Build](#10-platform-support--build)
11. [สรุปสถาปัตยกรรมและข้อสังเกต](#11-สรุปสถาปัตยกรรมและข้อสังเกต)

---

## 1. ภาพรวมโปรเจค

**Chaoperty User** คือแอปพลิเคชัน Flutter สำหรับระบบจัดการอสังหาริมทรัพย์และการชำระค่าเช่า (Property Management & Billing) รองรับผู้เช่าหลายประเภทและหลายบริษัทจัดการทรัพย์สิน (Multi-Tenant)

| รายการ | ข้อมูล |
|--------|--------|
| ภาษา | Dart + Flutter |
| ไฟล์ Dart ทั้งหมด | 444+ ไฟล์ |
| Dependencies | 130+ packages |
| Template ที่รองรับ | TP1–TP10, Choice, Market, Lamphun, NichadaThani, Lao |
| กลุ่มผู้ใช้งาน | ผู้เช่า, ผู้จัดการทรัพย์สิน |

---

## 2. โครงสร้างไดเรกทอรี

```
chaoperty_user/
├── lib/
│   ├── main.dart                    # Entry point — Provider setup, localization
│   ├── color.dart                   # Color scheme และ PDF constants
│   ├── ThaiBaht.dart               # แปลงตัวเลขเป็นตัวอักษรภาษาไทย
│   ├── Translate.dart              # Google Translator integration
│   ├── File_s.dart                 # File download/upload utilities
│   │
│   ├── Constant/                   # Config หลักของแอป
│   │   ├── Myconstant.dart         # API endpoints (chaoperties.com)
│   │   └── global_http.dart        # HTTP client + HMAC-SHA256 signing
│   │
│   ├── Model/                      # Data Models (156 ไฟล์)
│   │   ├── GetInvoice_Model.dart
│   │   ├── GetPayMent_Model.dart
│   │   ├── GetRenTal_Model.dart
│   │   ├── electricity_model.dart
│   │   └── ...
│   │
│   ├── screen/                     # UI Screens (67 ไฟล์)
│   │   ├── loginscreen.dart
│   │   ├── home_screen.dart
│   │   ├── pay_bill_screen.dart
│   │   ├── meter_screen.dart
│   │   ├── provider/               # State providers
│   │   └── Screen_new/             # Architecture ใหม่ (โมดูลแยกตาม feature)
│   │       ├── fitness_app_home_screen.dart  # Shell หลัก
│   │       ├── invoice/
│   │       ├── paystatus/
│   │       ├── mitter/
│   │       └── my_diary/
│   │
│   ├── PDF/                        # PDF templates หลัก (50 ไฟล์)
│   ├── PDF_TP2/ ... PDF_TP10/      # Templates เฉพาะแต่ละ property (10 โฟลเดอร์)
│   ├── PDF_Market/                 # Market property templates
│   ├── Man_PDF/                    # Manual PDF generation utilities (19 ไฟล์)
│   │
│   ├── Api_V2/                     # Payment Intent APIs V2
│   ├── screen_Intents/             # Payment flow V2 (14 ไฟล์)
│   ├── screen_Intents_V3/          # Payment flow V3 (13 ไฟล์)
│   ├── Beam/                       # Beam Checkout gateway integration
│   └── CRC_16_Prompay/             # Thai PromptPay QR generation
│
├── assets/                         # รูปภาพ, ดีไซน์, animation
├── fonts/                          # Thai/Lao/International fonts
├── android/, ios/, web/            # Platform-specific configs
└── pubspec.yaml                    # Dependencies & metadata
```

---

## 3. Tech Stack และ Dependencies หลัก

### Core
| หมวด | Package | Version |
|------|---------|---------|
| Framework | Flutter + Dart | 3.x / ≥3.6.0 |
| HTTP Client | http, dio | 1.1.0, 5.0.1 |
| State Management | provider | 6.0.5 |
| Local Storage | shared_preferences | 2.0.15 |
| WebView | webview_flutter | 4.4.0 |
| Database Driver | mysql1 | 0.20.0 |

### PDF & Document
| Package | ใช้ทำอะไร |
|---------|-----------|
| pdf, printing | สร้างและพิมพ์ PDF |
| syncfusion_flutter_pdf | PDF viewer/editor |
| syncfusion_flutter_pdfviewer | แสดง PDF ในแอป |
| syncfusion_flutter_barcodes | Barcode/QR ใน PDF |
| syncfusion_flutter_xlsio | Export Excel |
| syncfusion_flutter_signaturepad | ลายเซ็นดิจิทัล |

### Payment & QR
| Package | ใช้ทำอะไร |
|---------|-----------|
| qr_flutter, pretty_qr_code | แสดง QR code |
| crc, crc32_checksum | คำนวณ CRC สำหรับ PromptPay |
| crypto | HMAC-SHA256 signing |

### UI
| Package | ใช้ทำอะไร |
|---------|-----------|
| auto_size_text | ข้อความปรับขนาดอัตโนมัติ |
| animated_notch_bottom_bar | Bottom navigation bar |
| carousel_slider | Carousel/slider |
| dropdown_button2 | Dropdown ขั้นสูง |
| loading_animation_widget | Loading indicators |
| awesome_snackbar_content | Snackbar notifications |

---

## 4. สถาปัตยกรรมและ State Management

### Provider Pattern (State Management)
```
MultiProvider
├── WaitPayListProvider    → จัดการรายการบิลที่ค้างชำระ, เลือกบิล, คำนวณยอด
├── PayFormProvider        → จัดการฟอร์มการชำระเงิน
└── PayHisProvider         → จัดการประวัติการชำระ
```

### Data Flow
```
User Action
    → Screen (UI)
    → Provider (State)
    → API Call (global_http + HMAC-SHA256)
    → Model (JSON parsing)
    → Provider update
    → Screen rebuild
```

### Local Storage (SharedPreferences)
- `custno` — รหัสลูกค้า
- `renTalSer` — Rental Service ID
- `username`, password (MD5)
- ภาษาที่เลือก, URL รูปโลโก้
- รายการบิลที่เลือก

### Architecture แบบใหม่ (Screen_new/)
โปรเจคกำลัง refactor จาก single-file screens → feature modules:
```
FitnessAppHomeScreen (Shell)
├── invoice/        → ใบแจ้งหนี้
├── paystatus/      → สถานะการชำระ
├── mitter/         → มิเตอร์ไฟฟ้า
├── rental_contact/ → ข้อมูลการเช่า
├── training/       → คู่มือการใช้งาน
└── my_diary/       → บันทึกส่วนตัว
```

---

## 5. ฟีเจอร์หลัก

### 5.1 Authentication
- Login ด้วย email/password (MD5 hash)
- Auto-login ผ่าน URL parameters (รองรับ Web)
- Session management ด้วย SharedPreferences

### 5.2 Dashboard & Home
- แสดงบิลค้างชำระ
- ประวัติธุรกรรม
- Carousel sliders ข้อความประกาศ
- Floating bottom navigation (4 tabs)

### 5.3 Billing & Invoice
- รายการบิล / ประวัติบิล
- ค้นหาและกรองบิล
- Credit note
- Export PDF / Excel
- ใบเสร็จชั่วคราว

### 5.4 Payment
- PromptPay QR Code (สร้างตามมาตรฐาน CRC-16 ไทย)
- โอนเงินพร้อมอัพโหลด Slip
- Beam Checkout (WebView)
- Payment Intents V2 & V3

### 5.5 Meter Management
- บันทึกมิเตอร์ไฟฟ้า
- ประวัติการอ่านมิเตอร์
- ติดตามการใช้งาน

### 5.6 Rental Area
- ดูรายละเอียดพื้นที่เช่า
- ข้อมูลการติดต่อ
- แผนที่ / Location info

### 5.7 Document Management
- PDF viewer พร้อม annotation
- 60+ PDF templates
- รองรับ watermark และลายเซ็น
- QR code ในเอกสาร

### 5.8 User Profile
- แก้ไขข้อมูลส่วนตัว
- เลือกภาษา (ไทย/อังกฤษ/ลาว)
- ประวัติการชำระ

### 5.9 QR Scanner
- สแกน QR เพื่อค้นหาบิล
- Mobile camera integration

---

## 6. ระบบ PDF Generation

ระบบ PDF เป็นส่วนที่ซับซ้อนที่สุดในโปรเจค มี **60+ templates** สำหรับแต่ละประเภททรัพย์สิน

### โครงสร้าง Templates
```
PDF/                    → Base templates (Agreement, Billing, Receipt)
PDF_TP2/ → PDF_TP10/   → Templates เฉพาะแต่ละบริษัท (x9)
  ├── Billing/
  ├── Receipt/
  ├── CreditNote/
  ├── Pakan/            → ใบฝากเงิน
  └── Temporary_Receipt/

PDF_TP7_Ama1000/        → Ama1000 variant
PDF_TP8_Choice/         → Choice property
PDF_TP8_Ortorkor/       → อ.ต.ก. variant
PDF_TP9_Lao/            → รุ่นภาษาลาว
PDF_Market/             → ตลาด
Man_PDF/                → Manual generation utilities
```

### ความสามารถ PDF
- Thai font rendering (Sarabun, LINESeed)
- ตัวเลขเป็นตัวอักษรไทย (ThaiBaht.dart)
- QR Code และ Barcode ในเอกสาร
- Watermark, ลายเซ็นดิจิทัล
- Table layout หลายหน้า
- Chart/Report generation
- Export Excel ด้วย Syncfusion

---

## 7. ระบบชำระเงิน

มี 3 ชั้นของ Payment integration (iterative improvements):

### Layer 1 — PromptPay QR (CRC_16_Prompay/)
```
generate_qrcode.dart  → สร้าง TLV-encoded QR ตามมาตรฐานไทย
crc16.dart            → คำนวณ CRC-16 checksum
format_amount.dart    → จัดรูปแบบจำนวนเงิน
```

### Layer 2 — Beam Checkout (Beam/)
- WebView-based payment gateway
- API password management
- Payment validation & status check
- รองรับ disabled/maintenance mode

### Layer 3 — Payment Intents (Api_V2/, screen_Intents/, screen_Intents_V3/)
```
V2: screen_Intents/APIS-V2/
    ├── config-intents.dart
    ├── payment-intents.dart
    ├── payment-intents-upslip.dart   → อัพโหลดสลิป
    └── payment-qr-session.dart       → QR session management

V3: screen_Intents_V3/APIS-V3/       → ปรับปรุงจาก V2
```

### Bank Code Map
`screen_Intents/bankCodeMap.dart` — แมป bank code สำหรับระบุธนาคาร

---

## 8. API Integration & Security

### Endpoints (Myconstant.dart)
| ชื่อ | URL |
|------|-----|
| Primary API | `https://chaoperties.com/user/chao_api_user` |
| Image/Media | `https://chaoperties.com/chao_api` |
| V2 Choice | `https://chaoperties.com/chao_api/v2/choice` |
| Choice Template | `https://chaoperties.com/Choice/chao_api` |

### Security (global_http.dart)
- **HMAC-SHA256** signing บน request ทุก request
- **Timestamp-based** authentication
- **PHP serialization** compatibility layer (backend compatibility)
- Custom `GlobalHttp` class ที่ auto-sign ทุก request

---

## 9. Multi-Language Support

| ภาษา | Locale | Font |
|------|--------|------|
| ไทย (หลัก) | th_TH | Sarabun, LINESeed TH |
| อังกฤษ | en_US | WorkSans, Roboto |
| ลาว | lo_LA | Phetsarath-OT, NotoSansLao |

- **Google Translator API** สำหรับ dynamic translation (Translate.dart)
- เลือกภาษาได้ใน app และบันทึกด้วย SharedPreferences
- PDF_TP9_Lao/ — template พิเศษสำหรับ output ภาษาลาว
- Syncfusion localizations รองรับ Thai calendar

---

## 10. Platform Support & Build

### รองรับ Platform
| Platform | สถานะ |
|----------|--------|
| Android | ✅ |
| iOS | ✅ |
| Web (Chrome) | ✅ |
| Windows | ✅ |
| macOS | ✅ |
| Linux | ✅ |

### Build Commands
```bash
# Development
flutter run --enable-software-rendering
flutter run -d chrome --web-renderer html
flutter run -d chrome --web-browser-flag "--disable-web-security"

# Production Web
flutter build web --web-renderer html --release
flutter build web --dart-define=BROWSER_IMAGE_DECODING_ENABLED=false
```

### Platform Abstractions
- `fake_html.dart` — mock `dart:html` สำหรับ non-web platforms
- `fake_js.dart` — mock `dart:js` สำหรับ non-web platforms
- `Responsive/responsive.dart` — responsive layout utilities

---

## 11. สรุปสถาปัตยกรรมและข้อสังเกต

### จุดเด่น
1. **Multi-Template System** — รองรับ 10+ บริษัทจัดการทรัพย์สิน แต่ละที่มี PDF templates ของตัวเอง
2. **Security-First HTTP** — ทุก API request มี HMAC-SHA256 signing อัตโนมัติ
3. **Iterative Payment** — มี 3 layer ของระบบชำระเงิน (Beam → V2 → V3) แสดงถึงการพัฒนาแบบ incremental
4. **Cross-Platform** — รันได้ทุก platform โดยใช้ abstraction layer สำหรับ web-specific APIs
5. **Thai-First Design** — ออกแบบมาสำหรับตลาดไทยเป็นหลัก รวมถึง PromptPay มาตรฐาน, font Thai, Thai Baht text

### Pattern ที่ใช้
| Pattern | ใช้ที่ไหน |
|---------|-----------|
| Provider Pattern | State management ทั้งแอป |
| Repository Pattern | API calls ผ่าน model classes |
| Singleton Pattern | MyConstant configuration |
| Factory Pattern | Model.fromJson() ทั่วไป |

### สิ่งที่กำลัง Refactor
- จาก `screen/` (flat structure) → `screen/Screen_new/` (feature modules)
- Shell screen ใหม่: `FitnessAppHomeScreen` แทน `home_screen.dart`
- แยก Payment V1 → V2 → V3 แบบ backward compatible

### Tech Debt ที่สังเกตเห็น
- มีการใช้ `// ignore_for_file` จำนวนมาก (legacy code)
- 156 model files — บางส่วนอาจ overlap กัน
- หลาย Payment layer ทำงานคู่ขนาน (V2 และ V3 ยังอยู่พร้อมกัน)
- PDF templates 60+ ไฟล์ มีโค้ดซ้ำกันจำนวนมากระหว่าง template

---

*สร้างโดย Claude Code — วิเคราะห์จาก 444 Dart files ใน d:\NEW\chaoperty_user*
