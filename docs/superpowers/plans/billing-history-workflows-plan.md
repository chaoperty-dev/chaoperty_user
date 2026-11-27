# Plan: Billing history PDF / Excel / QR / LINE and cancellation eligibility

วันที่: 2026-11-14 (Asia/Bangkok)
สถานะ: ลงมือแล้วใน codex/issue-216-billing-history-workflows; ผลตรวจและขอบเขตที่ยังไม่ยืนยันอยู่ท้ายเอกสาร

## เป้าหมายและข้อจำกัด

- ต่อ action ที่ legacy รองรับเข้ากับ MVVM ให้ใช้งานจริง ไม่จบเพียงเพิ่ม callback หรือ mock callback ผ่าน
- คงสูตรยอด ส่วนลด VAT WHT rounding และ output ตามแต่ละเส้นทาง legacy ไม่บังคับให้ยอด display/PDF/QR ใช้สูตรเดียวกันเอง
- legacy ใช้อ่านเท่านั้น ไม่แก้ PHP/API contract/server และห้ามเข้าถึงหรือแก้ฐานข้อมูล
- ทดสอบด้วย synthetic fixtures; ดัก HTTP, image load, printer, download และ paper counter ทั้งหมด ไม่ส่ง LINE/ยกเลิก/สร้าง QR กับระบบจริง
- รหัสยืนยันเป็นเลขสุ่มสองหลักในเครื่อง ไม่ใช่ server PIN หรือ permission; ยกเลิกต้องมีเหตุผลและรหัสถูกต้อง
- ใช้ Account core และ dependency เดิม ไม่สร้างโฟลเดอร์หรือ abstraction เผื่ออนาคต
- แต่ละไฟล์เป้าหมายไม่เกิน 2,000 บรรทัด; หากจำเป็นต้องเกินให้ระบุเหตุผล และห้ามเกิน 3,000 บรรทัด

## Baseline ก่อนลงมือ

1. Detail panel มี callback PDF/Excel/QR/LINE แต่ MVVM screen ยังไม่ส่ง callback เหล่านี้
2. มี single cancellation พร้อม reason/code และ guard ผลไม่แน่นอน แต่ eligibility ยังไม่ครบ
3. `Billing_Screen.dart` ยังเลือก legacy widgets; widget test ไม่ได้ยืนยันว่าเมนูจริงใช้ MVVM
4. มี legacy browser tests ของ XLSX และ batch export แล้ว แต่ยังไม่ใช่หลักฐาน MVVM integration
5. `Verifi_Exc_Billing.dart` มี Excel import ด้วย ห้ามเหมาว่าเป็น exporter; output tests ใช้ `Report/Excel_Historybills_Report.dart` และ `Report/Excel_HistorybillsCancel_Report.dart`

## แหล่งเทียบ: อ่านอย่างเดียว

- `lib/Account/Ac_Sub/Account_Bill_Invoce.dart`: normal, cancellation gates, QR, LINE, PDF entry
- `lib/Account/Ac_Sub/Account_Bill_Invoce_Success.dart`: paid history และ PDF แยกเส้นทาง
- `lib/Man_PDF/Man_BillingNoteInvlice_PDF.dart`: template, preview/download, paper counter
- `lib/Report/Excel_Historybills_Report.dart`, `lib/Report/Excel_HistorybillsCancel_Report.dart`: XLSX
- `lib/Constant-APIS-V2-Payment/Intent-API/POST/n9-bill-reference-available.dart`: intents contract
- `CONTRIBUTING.md`, `DESIGN.md`, `docs/specs/billing-history-baseline.md`, `docs/specs/billing-history-214-contract.md`

## ไฟล์ที่จะรับผิดชอบ

พาธต่อไปนี้อยู่ใต้ `lib/Account/Billing_Screen/` เว้นแต่ระบุเป็นอย่างอื่น

| ไฟล์ | หน้าที่ |
|---|---|
| `models/billing_history_models.dart` | identity/session และ immutable action snapshot เพิ่มเฉพาะ field ที่ใช้จริง |
| `models/billing_history_cancellation_eligibility.dart` (ใหม่) | allowed/blocked พร้อมเหตุผลและ local date/settings policy ไม่ทำ HTTP |
| `services/billing_history_service.dart` | list/detail/cancel contract เดิม ไม่ใส่ UI หรือสูตร output |
| `services/billing_history_workflow_service.dart` (ใหม่) | QR/LINE และ async preflight ผ่าน transport ที่ mock ได้ |
| `services/billing_history_export_service.dart` (ใหม่) | adapter ไป exporter เดิมและขอบเขต side effect ไม่เขียน template/สูตรใหม่ซ้ำ |
| `viewmodels/billing_history_view_model.dart` | busy/error/eligibility, stale selection และ duplicate-submit guard |
| `view/billing_history_mvvm_screen.dart` | ต่อ action จริงและเปิด dialog/preview |
| `view/widgets/billing_history_detail_panel.dart` | ปุ่มตาม tab/status และเหตุผลที่กดไม่ได้ |
| `view/widgets/billing_history_cancel_dialog.dart` | reason/code/progress/error ตาม core |
| `view/widgets/billing_history_workflow_dialog.dart` (ใหม่เมื่อจำเป็น) | PDF options, LINE recipient, QR preview ไม่ใส่ HTTP/สูตรใน widget |
| `docs/specs/billing-history-214-contract.md` | action matrix และข้อจำกัดตามผลจริง |

ชื่อไฟล์ใหม่เป็นขอบเขตเสนอ ไม่สร้าง stub ล่วงหน้าทั้งหมด ถ้ารวม service ได้อย่างชัดเจนให้รวม ไม่สร้าง interface/repository ที่ไม่มีเหตุผลใช้งานจริง

## ลำดับดำเนินงาน

### A. ล็อก legacy parity และ safe harness

**A1: Action matrix**

- บันทึก normal/paid/canceled, single/batch, เงื่อนไขแสดงปุ่ม, input, endpoint/method/body, output, สูตรและ side effect พร้อม source reference
- แยก LINE แจ้งยอดกับส่งรูป QR; แยก PDF preview/download/print/batch ตาม legacy ไม่เพิ่ม action ใน tab ที่ไม่มี
- ตรวจว่า Excel export ใช้ selected bill, current filter หรือ batch ห้ามเลือก scope ใหม่เอง
- เกณฑ์ผ่าน: ทุก action มีเส้นทาง source และ input ครบ ไม่ใช้ config สมมติ

**A2: Synthetic fixtures และ outbound deny-by-default**

- ดัก HTTP/image/printer/download/counter; request ที่ไม่ได้กำหนด fixture ต้องทำ test ล้มทันที
- ใช้ tests เดิมเป็น baseline แยก legacy regression จาก MVVM integration
- เกณฑ์ผ่าน: baseline รันได้โดยไม่มี real network, browser security bypass หรือ database access

**Dependency:** A1 ก่อน A2; ทุกช่วงต่อไปต้องใช้ harness นี้ก่อนทดลอง generator/helper ที่อาจยิง global HTTP

### B. Eligibility ยกเลิกครบก่อนเปิด mutation

**B1: Local policy**

- `Cancell_bill == 1` คือปิดการยกเลิก ไม่ใช่เปิด
- `Day_Cancell_bill == 0` คือไม่จำกัดวัน; ค่าอื่นใช้ `daterec` เติมเวลา 00:00:00 บวกวันและเทียบ `isBefore` ตาม source
- ตรวจเวลาที่ legacy ใช้จริง ทดสอบก่อน/เท่ากับ/หลังขอบเขต ห้ามเปลี่ยนเป็นสิ้นวันหรือเปลี่ยน timezone เอง
- missing/invalid settings, วันไม่ถูกต้อง, tab/status ไม่รองรับ และเอกสารไม่ครบ ต้องไม่เปิด mutation; ระบุเหตุผลและบันทึก safety difference สำหรับข้อมูลผิดรูป

**B2: Async gates ตาม branch เดิม**

- rental `106`: choice QR request ใช้ method/body เดิม รวม invoice ที่มี quote ตาม contract; HTTP 200 และ body ไม่ว่างบล็อกตาม legacy ไม่แปลงข้อความ `null` เป็นอนุญาตเอง
- rental อื่น: ตรวจ payment-intent เฉพาะเมื่อ legacy ระบุว่ามี intents auth ไม่เพิ่ม gate ให้ทุก rental
- payment-intent `available` ต้องเป็น boolean `true` จึงผ่าน; false/null/error ไม่ส่ง cancellation
- config/auth ยังโหลดไม่เสร็จต้องไม่ถูกตีความเป็นไม่ต้องตรวจ แยก loading, not applicable และ error
- บาง legacy error branch อาจปล่อยผ่าน: เสนอให้ preflight ที่ยืนยันไม่ได้หยุด mutation และแจ้งผู้ใช้ ต้องบันทึกเป็น safety difference ไม่เปลี่ยนเงียบ ๆ

**B3: ยืนยันและส่งคำขอ**

- เก็บ snapshot `(rental, user, tab, document, customer)` เมื่อเปิดยืนยัน ตรวจซ้ำก่อน mutation และหลัง async preflight; ห้ามส่งให้ selection ใหม่แทนรายการเดิม
- เมื่อกดยืนยันประเมิน local policy และ gates อีกครั้ง เหตุผลต้องไม่ว่าง รหัสสุ่มสองหลักต้องตรง
- ป้องกัน double tap; timeout/ผลไม่ทราบไม่ retry อัตโนมัติ ต้อง refresh ตรวจสถานะก่อนอนุญาตให้ทำใหม่ และไม่อ้างว่า refresh เป็นหลักประกัน backend idempotency
- เกณฑ์ผ่าน: blocked/error/stale/รหัสผิดไม่มี cancellation request; สำเร็จ request เดียวและ refresh ถูก session

### C. PDF และ Excel output จริง

**C1: PDF adapter**

- ส่ง document/customer/template/header/paper format/filename/preview mode และ billing config ตามแต่ละ tab ให้ครบ
- ใช้ generator/template เดิม ไม่สร้าง PDF ใหม่จากยอดในตารางซึ่งอาจเป็นคนละฐานคำนวณ
- ตรวจว่า inject transport/side effect ได้หรือไม่ก่อนเรียก ถ้าไม่ได้ให้หา seam ในไฟล์ใหม่โดยไม่แก้ legacy; หากทำไม่ได้ภายใต้ข้อจำกัด ต้องเสนอทางเลือกและขออนุมัติก่อนเปลี่ยนไฟล์ที่ห้ามแตะ ไม่ใช้ stub แทนงานจริง
- จับ output bytes จริง ตรวจ PDF เปิดอ่านได้ จำนวนหน้า รายการ ยอด ส่วนลด VAT WHT และ render หน้าตัวอย่างตรวจ layout
- ดัก `UP_Paper_Run.php` ตรวจเงื่อนไข ค่า counter ลำดับและจำนวนครั้ง รวม render/download ล้มเหลว ห้ามสมมติว่าเพิ่มเฉพาะ download หรือหลังสำเร็จ
- ถ้า counter ถูกส่งแล้วขั้นตอนถัดไปล้มเหลว ต้องรายงานตามจริง ไม่ retry หรืออ้าง rollback สำเร็จ

**C2: Excel adapter**

- ใช้ exporter ที่ A1 ยืนยัน ไม่เอา Excel import มาแทน output
- เปิด XLSX bytes จริง ตรวจ workbook/sheet/header/จำนวนแถว/ลำดับ/ตัวเลข/วันที่/ยอดและเหตุผลยกเลิกตามประเภท
- ต่อจาก browser output test เดิม และเพิ่ม MVVM-to-exporter test ว่าส่งข้อมูล scope ถูกต้อง ไม่ตรวจเพียง ZIP signature
- เกณฑ์ผ่าน: กดผ่าน MVVM ได้ output จริงที่ตรวจเนื้อหาได้; counter ถูก mock และไม่ส่งออกข้อมูลคนละรายการ/filter

### D. QR และ LINE

**D1: QR**

- คงเงื่อนไขแสดง QR และ amount/ref/customer ตาม QR source โดยเฉพาะ ไม่แทนด้วยยอด display เพราะดูเท่ากัน
- ใช้ snapshot สร้าง URI ตาม contract แสดง loading/error/preview ป้องกันงานซ้อนและผลลัพธ์ข้ามเอกสาร
- ทดสอบ URI/query/rounding/image loading รวม ref หาย selection เปลี่ยน และสร้างภาพไม่สำเร็จ

**D2: LINE**

- คงผู้รับที่ลงทะเบียน quota/config และ mode แจ้งยอด/รูปตาม legacy
- เลือกและยืนยันผู้รับก่อนส่ง ใช้ rental/customer/document/amount จาก snapshot เดียวกัน
- ตรวจ acknowledgement ก่อนรายงานสำเร็จ; timeout แสดงผลไม่แน่นอน ไม่ resend อัตโนมัติ
- เกณฑ์ผ่าน: payload/ผู้รับตรง source ไม่มีผู้รับไม่ส่ง error ไม่รายงานสำเร็จ และไม่มี real send

**Dependency:** C/D หลัง A; ต่อ UI เต็มรูปแบบหลัง B/C/D เพื่อไม่เหลือปุ่มที่มีแค่ dialog แต่ไม่มี workflow

### E. UI integration และจุดเข้าเมนูจริง

**E1: ปุ่มและ dialog**

- ต่อทุก action กับ ViewModel/service จริง มี busy/error ตามงาน รองรับปิดหน้าระหว่าง await
- ใช้ `AccountUiTheme`, `AccountDialogScaffold`, `AccountConfirmationPin` และ image viewer ที่มีอยู่เมื่อรองรับ ไม่คัดลอก font/padding/style
- ไม่สร้างปุ่มปิดซ้ำกับ X; ระหว่าง mutation ต้องไม่ให้การปิด dialog สื่อว่า request ถูกยกเลิกแล้ว
- ทดสอบตกลง/X/keyboard/mouse ทั้งสำเร็จและ error ตรวจ overflow, render box no size และ mouse tracker regression

**E2: Production entry**

- trace ปัจจุบันจาก `Account_Screen.dart` ไป `BillingScreen` และ legacy child เทียบตำแหน่งเปิด MVVM จริง
- ห้ามถือว่าครบถ้าเปิดได้เฉพาะ injected test screen หรือ callback ยังเป็น null
- หากต้องแก้ host/navigation ที่เป็นไฟล์เดิม ให้เสนอ diff จุดเรียกเล็กที่สุดและขออนุมัติเฉพาะไฟล์ก่อน ไม่แก้เองภายใต้คำสั่งห้ามแตะ legacy
- เกณฑ์ผ่าน: มี entry ที่ได้รับอนุมัติและ runtime settings จริง โดย legacy business logic/สูตรไม่เปลี่ยน

### F. ตรวจรับและส่งงาน

- รัน targeted tests แล้ว billing-history/core regression, analyze และ web build ตาม toolchain ที่ตกลง บันทึกคำสั่งและผลจริง ไม่เปลี่ยน Flutter/dependency เพื่อหลบปัญหา
- แคป UI synthetic: list/detail, cancel blocked/confirm/error, PDF preview, QR, LINE และขนาดจอที่กระทบ ตรวจว่ารูปใน PR เปิดได้จริง
- ตรวจ diff ไม่รวม legacy, PHP/API/server, generated/cache หรือข้อมูลจริง
- อัปเดต Issue/PR checklist ตามผลจริง ใช้ `Refs` จน acceptance ครบ ไม่อ้าง server/database verified จาก mock
- commit/push/ready/merge ตามคำอนุญาตและกฎ repo ตรวจ CI ของ SHA ล่าสุดและ review ก่อน merge; ปิด Issue เมื่อขอบเขตเสร็จจริง

## แผนทดสอบและหลักฐาน

| ชุด | ต้องพิสูจน์ | ไฟล์ |
|---|---|---|
| Local eligibility | flag, unlimited days, time boundary, invalid date/config, tab/status | `test/billing_history_eligibility_test.dart` (ใหม่) |
| Service/preflight | choice/intents branch, exact request, true/false/null/non-200/timeout, ไม่หลุดไป mutation | `test/billing_history_actions_test.dart`, `test/billing_history_workflows_test.dart` (ใหม่) |
| Async/action state | selection/session/tab เปลี่ยน, double tap, dispose, ผลไม่ทราบ, refresh | `test/billing_history_mvvm_test.dart`, `test/billing_history_actions_test.dart` |
| Financial parity | ฐานยอดแต่ละ workflow ส่วนลด VAT WHT null และ rounding | `test/billing_history_financial_parity_test.dart` |
| PDF/XLSX output | bytes จริง, เนื้อหา/ยอด/จำนวนหน้า/แถว, mocked counter trace | เพิ่ม `test/billing_history_pdf_output_browser_test.dart`; ต่อ `test/billing_history_excel_output_browser_test.dart` |
| QR/LINE browser | UI ถึง service, ผู้รับ/URI/amount, image/error, no real send | `test/billing_history_workflows_browser_test.dart` (ใหม่) |
| Legacy regression | cancel/batch เดิมไม่ถอยหลัง ไม่ใช่หลักฐาน MVVM integration | `test/billing_history_cancel_browser_test.dart`, `test/billing_history_batch_export_browser_test.dart` |
| UI integration | entry ที่อนุมัติ, action availability, dialog lifecycle, layout/keyboard/mouse | `test/billing_history_ui_test.dart` และ browser fixture |

ทุก test ต้อง assert ผลจริง ไม่ใช้ callback counter อย่างเดียว ไม่เพิ่ม framework ใหม่ แยกสถานะ source-reviewed, mocked-test-passed, output-verified, UI-verified และ live-unverified

คำสั่งด้านล่างเป็นแผนสำหรับช่วงลงมือ ไม่ได้รันหรือรับรองว่าผ่านในการเขียนแผนนี้:

```powershell
fvm flutter test test/billing_history_actions_test.dart test/billing_history_mvvm_test.dart test/billing_history_financial_parity_test.dart --no-pub
fvm flutter test test/billing_history_excel_output_browser_test.dart test/billing_history_batch_export_browser_test.dart --platform chrome --no-pub
fvm dart analyze lib/Account/Billing_Screen --no-fatal-warnings
fvm flutter build web --no-pub --no-tree-shake-icons
```

เมื่อเพิ่มไฟล์ทดสอบใหม่ให้เพิ่มชื่อในชุด targeted/browser ตามตาราง และรัน Account core regression เฉพาะส่วนที่เปลี่ยน ตรวจ SDK/dependencies ที่ติดตั้งจริงก่อนรัน ไม่ถือว่า browser fixture แทน server acceptance

## เกณฑ์ถือว่าครบ

- [ ] ทุก action ตาม legacy ต่อใช้งานจริงจาก MVVM; action ที่ไม่รองรับไม่โผล่หรือมีเหตุผล disabled ชัดเจน
- [ ] local/choice/intents eligibility และ reason/code ผ่าน matrix ทั้งอนุญาตและปฏิเสธ โดยไม่สร้าง permission ใหม่
- [ ] PDF/XLSX เปิดและตรวจเนื้อหาได้ ไม่ใช่เพียง mock callback สำเร็จ
- [ ] QR/LINE ใช้ identity/ผู้รับ/ฐานยอดถูก workflow โดยไม่ส่งหรือ mutate จริงระหว่าง test
- [ ] paper counter มีหลักฐานลำดับ/จำนวนครั้งจาก intercepted requests และระบุข้อจำกัด retry/rollback
- [ ] legacy test ไม่ถูกใช้แทน MVVM-to-service/output integration
- [ ] entry MVVM ได้รับอนุมัติ ไม่มีการฝ่าฝืนคำสั่งห้ามแตะ legacy
- [ ] regression/analyze/build/screenshots/CI มีผลจริงครบ หรือระบุ blocker โดยไม่ติ๊กผ่าน

## จุดส่งงานย่อย

แยก diff ที่ตรวจรับได้เป็น A (matrix/harness), B (eligibility), C (exports), D (QR/LINE), E (UI integration), F (evidence/PR) แต่ละส่วนต้องมี test ที่เกี่ยวข้องก่อนบอกว่าเสร็จ ไม่เปิด PR ซ้อนหรือสร้าง branch ใหม่โดยไม่ตรวจงานปัจจุบัน และไม่ commit จากคำขอวางแผนเพียงอย่างเดียว

## ความเสี่ยงและ rollback

- PDF/helper เดิมใช้ global HTTP/SharedPreferences: ต้องปิด outbound ให้ครบก่อนรัน ไม่ตั้ง live client เป็น fallback ของ test
- การเปลี่ยน session/config อาจกระทบ caller/tests เดิม ต้องค้นทั้ง repository ไม่ใช้ default สมมติแทน config ที่ยังไม่พร้อม
- client preflight ไม่ใช่ server authorization และไม่ป้องกันสถานะเปลี่ยนหลังเช็ก ห้ามอ้างว่ามี transaction/rollback/idempotency โดยไม่มีหลักฐาน
- ไม่ retry cancel, LINE หรือ paper counter ที่ผลไม่ทราบอัตโนมัติ
- Rollback ผ่าน revert PR ที่เจาะจง; ถ้ามี host toggle ที่ได้รับอนุมัติให้กลับ legacy ได้โดยไม่แตะฐานข้อมูล การ revert ไม่ย้อน side effect ที่ส่งแล้ว
- จุดต้องตัดสินใจก่อนลงมือ: PDF seam ที่ทดสอบได้โดยไม่แก้ legacy และ host entry ที่เปิด MVVM จริง หากข้อจำกัดทำให้ทำไม่ได้ให้ขออนุมัติเฉพาะจุด ไม่ใส่ stub/route ที่ไม่ถูกเรียกแล้วประกาศครบ

## ผลดำเนินการ 2026-11-14 / Local execution evidence

- [x] ต่อเมนูจริงผ่าน `Account_Screen.dart` โดยใช้ `uiNew`; false ยังคง legacy และมีทางกลับไป workflow Excel เดิม ผู้ใช้อนุมัติจุดเชื่อมนี้แล้ว
- [x] ต่อ PDF, Excel บิลที่เลือก, QR, LINE ข้อความ/รูป และ cancellation preflight เข้าหน้า MVVM; paid tab ซ่อน workflow ที่ไม่มี legacy exporter รองรับ
- [x] คืนชื่อผู้เช่าและรายการโลโก้ให้ PDF adapter; ไม่ส่ง `null` แทนรายการรูป และไม่แก้ template/generator เดิม
- [x] ตรวจ rental/document/customer และค่า paper counter ถัดไปก่อนส่งผ่าน HTTP transport; mock ยืนยัน counter จาก 2 เป็น 3 เพียงหนึ่ง request ในเส้นทางสำเร็จ
- [x] QR ตรวจ decode รูปก่อนเปิด viewer; HTTP 200 ที่ไม่ใช่รูปและ HTTP 500 แสดง error dialog ไม่ปล่อย image exception ค้าง
- [x] Unit/widget tests ของ billing history ทั้งหมด: 68 ผ่าน ด้วย Flutter 3.10.5 (`Get-ChildItem test -Filter 'billing_history*test.dart'` โดยตัด browser files)
- [x] Browser output/regression: 20 tests ของ Excel/batch/legacy cancellation ผ่าน และ PDF output อีก 3 tests ผ่านแยกรัน รวม 23 กรณี
- [x] หลังแก้ lint รันซ้ำเฉพาะ PDF/Excel browser tests 6 ผ่าน และ workflow tests 11 ผ่าน; เป็นกรณีเดิมใน 91 tests ไม่บวกยอดซ้ำ
- [x] `dart analyze lib/Account/Billing_Screen --no-fatal-warnings`: No issues found
- [x] หลังเก็บ lint 7 จุด ตรวจ source และ tests ของ workflows/workflow UI/PDF/Excel: No issues found; ใช้ binary messenger API ปัจจุบันและ HTTP client เดิมโหลด font จาก local test server
- [x] `git diff --check`: ผ่าน; ไฟล์ Dart ใต้ MVVM นี้ยาวสูงสุด 581 บรรทัด ณ วันที่ตรวจ
- [x] Web build ด้วย Flutter 3.10.5: `build web --no-pub --no-tree-shake-icons` ผ่าน (exit 0, 209.6 วินาที); ใช้ผล process เดิม ไม่ build ซ้ำ
- [ ] Screenshot ของหน้า runtime และ PDF visual parity ของฟอนต์ไทย/โลโก้/ลายเซ็น/ทุก template ยังไม่ได้ยืนยัน
- [x] รวมงานและผลตรวจใน commit ของ feature branch โดยไม่รวม `.cache/` หรือ `.tmp-appdata/`
- [ ] Push/PR screenshots และ CI ยังไม่ได้ยืนยัน; ไม่อ้างว่า merge-ready

### คำสั่งตรวจเฉพาะงาน

```powershell
$flutter = 'C:\Users\Jittr\fvm\versions\3.10.5\bin\flutter.bat'
$tests = Get-ChildItem test -Filter 'billing_history*test.dart' | Where-Object { $_.Name -notmatch 'browser' } | ForEach-Object { $_.FullName }
& $flutter test @tests --no-pub
& $flutter test test/billing_history_pdf_output_browser_test.dart --platform chrome --no-pub
& $flutter test test/billing_history_excel_output_browser_test.dart test/billing_history_batch_export_browser_test.dart test/billing_history_cancel_browser_test.dart --platform chrome --no-pub
& 'C:\Users\Jittr\fvm\versions\3.10.5\bin\cache\dart-sdk\bin\dart.exe' analyze lib/Account/Billing_Screen --no-fatal-warnings
& $flutter build web --no-pub --no-tree-shake-icons
```

### ขอบเขตหลักฐานและข้อจำกัดที่ยังต้องคงไว้

PDF browser test สร้าง bytes จาก generator จริง เปิดด้วย PDF parser และตรวจหน้า/เลขเอกสาร/ยอด 95.00 รวมถึงลำดับและค่า paper counter ที่ดักไว้ ใช้ Ahem TTF จาก test server เพราะ Flutter 3.10 browser harness ไม่โหลด application assets ให้อัตโนมัติ จึงไม่ใช่หลักฐานว่าฟอนต์ไทยและหน้าตา PDF จริงผ่านแล้ว ข้อจำกัดนี้ไม่ถูกเปลี่ยนเป็น test ที่ skip หรือ claim ว่าครบทุก template

Excel adapter ใช้ exporter เดิมที่เป็น asynchronous `void`; UI แจ้งเริ่มส่งออก ไม่แจ้งว่ายืนยันบันทึกไฟล์สำเร็จแล้ว Browser test ดัก XLSX จริงและตรวจข้อมูลบิลที่เลือก แต่การเปลี่ยน lifetime ของ legacy exporter ต้องเป็นการแก้ที่ได้รับอนุมัติแยกต่างหาก

การเพิ่ม paper counter เกิดตามเวลาเดิมก่อน render/download เสร็จ; ไม่มี rollback และไม่ retry อัตโนมัติหลังผลไม่แน่นอน ยังไม่ได้ทดสอบ failure ของทุก template/download sink หรือทำ live acceptance

ทุก HTTP ใน regression/output tests ใช้ mock และทุก download sink ถูกดักไว้; ไม่ยิง API จริง ไม่ส่ง LINE จริง ไม่ยกเลิกบิลจริง และไม่เปิด อ่าน หรือแก้ฐานข้อมูล ไม่มี PHP/API/server file ถูกแก้ คง `.cache/` และ `.tmp-appdata/` ที่มีอยู่ไว้ ไม่รวมเป็นงานส่ง