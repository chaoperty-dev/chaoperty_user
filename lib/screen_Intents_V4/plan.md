# แผนย้าย `payment_subV4_InvAll.dart` เป็น MVVM

> สถานะ: ฉบับปรับปรุงหลังตรวจเทียบโค้ดจริง
>
> เอกสารนี้เป็น source of truth เดียวสำหรับงานย้าย Payment Intent V4 หากเอกสารหรือแนวทางก่อนหน้าขัดกัน ให้ยึดไฟล์นี้

## 1. เป้าหมาย

ย้ายหน้าชำระเงิน Intent V4 จาก StatefulWidget ขนาดใหญ่ไปไว้ใต้:

```text
lib/screen_Intents_V4/payment_subV4/
```

ผลลัพธ์ต้อง:

- รักษา behavior และ API contract ที่ใช้งานจริง
- แยก API, state, calculation, QR lifecycle, slip upload และ UI ชัดเจน
- ลด `setState`, state ซ้ำ และ async race
- รองรับ Android, iOS, Web และ Desktop เท่าที่โปรเจครองรับอยู่
- ปรับ presentation ตาม design reference โดยไม่เปลี่ยน payment flow
- เปิดทางให้ unit/widget test โดยไม่เรียก production API

## 2. ข้อห้ามและ baseline protection

### 2.1 ไฟล์ต้นแบบ

ไฟล์นี้เป็น read-only reference ระหว่าง migration:

```text
lib/screen_Intents_V4/payment_subV4_InvAll.dart
```

ห้าม:

- แก้ ลบ ย้าย rename หรือ format
- import class/state/helper ภายในต้นแบบมาใช้ในโค้ดใหม่
- ใช้ `git restore`, `git checkout --`, reset หรือคำสั่งอื่นเพื่อล้าง diff ของไฟล์ต้นแบบ

ไฟล์ต้นแบบมี working-tree changes อยู่ก่อนเริ่ม migration จึงห้ามใช้ “diff จาก HEAD ต้องว่าง” เป็นเกณฑ์

ขั้นตอนป้องกันข้อมูลเดิม:

1. บันทึก content hash ของ working-tree version ก่อนเริ่ม
2. สำรอง diff เดิมของไฟล์ต้นแบบไว้โดยไม่แก้ไฟล์
3. หลังจบงาน content hash ต้องตรง baseline ตอนเริ่ม
4. diff เดิมต้องยังอยู่ครบ
5. หาก hash เปลี่ยน ให้หยุดและตรวจ ไม่ restore ทับงานเดิม

### 2.2 Contract และข้อมูลอ่อนไหว

- ห้ามเดา API field, status หรือ endpoint
- ห้าม hardcode token, Basic credential, cookie, customer credential หรือ QR credential
- ห้าม log Authorization header, token prefix, `pay_encoded64`, slip bytes/base64 หรือข้อมูลส่วนบุคคลเกินจำเป็น
- ห้ามถือว่า HTTP 200/201 คือสำเร็จจนกว่าจะตรวจ response body/envelope
- ห้ามเรียก production mutation ระหว่าง automated test
- ห้ามเพิ่ม dependency ถ้าของเดิมทำงานได้

## 3. ขอบเขต

### 3.1 อยู่ใน scope

- โหลด rental, tenant, payment account, invoice, fine, history, transaction และ payment intent
- จำแนก 3 tab: ที่ต้องชำระ, รอแนบหลักฐาน, รอระบบตรวจสอบ
- คำนวณยอดและสร้าง payload เดิม
- สร้าง intent, โหลด detail, generate/renew QR และ cancel intent
- เลือก/รวม/preview/upload slip แล้ว reload สถานะ
- บันทึก/แชร์ QR และ copy account/amount
- รองรับ caller เดิมและ deep-link จาก intent card
- UI responsive และข้อความไทย/อังกฤษ

### 3.2 ไม่อยู่ใน scope

- เปลี่ยน backend หรือ API contract
- เปลี่ยนสูตรเงินโดยไม่มี fixture/หลักฐาน
- refactor model หรือ auth architecture ทั้งโปรเจค
- ลบไฟล์ต้นแบบ
- เปลี่ยนหน้าชำระเงิน V3 หรือหน้าอื่นเกินส่วน caller compatibility
- เพิ่ม payment method selector ให้ผู้ใช้ หากช่องทางถูกกำหนดจาก caller/admin
- เพิ่ม invoice selection ใหม่ในหน้า V4 หาก caller เลือกมาแล้ว

## 4. Public input และ caller compatibility

ใช้ parameter object:

```dart
class PaymentSubV4Params {
  const PaymentSubV4Params({
    this.tenants,
    this.customerLanguage,
    this.paymentSerial,
    this.paymentTypeSerial,
    this.selectedDocNos,
    this.fromIntent = false,
    this.targetIntentUuid,
    this.targetPaymentIntentNo,
  });

  final List<TeNantModel>? tenants;
  final String? customerLanguage;
  final String? paymentSerial;
  final String? paymentTypeSerial;
  final List<String>? selectedDocNos;
  final bool fromIntent;
  final String? targetIntentUuid;
  final String? targetPaymentIntentNo;
}
```

กฎ:

- `paymentSerial` (`serPayment`) ระบุ payment account/bank ที่ caller/admin เลือกไว้
- `paymentTypeSerial` (`serptPayment`) เป็น compatibility/fallback; ค่าหลัก derive จาก `PayMentModel` ที่ match `paymentSerial`
- `selectedDocNos` คือ invoice ที่ caller เลือกมา ไม่ใช่ state สำหรับเลือกใหม่ใน V4
- หาก `selectedDocNos` null/empty ให้ใช้ invoice ที่เข้าเงื่อนไขทั้งหมดเหมือนต้นแบบ
- `fromIntent` ควบคุม filter/auto-tab behavior เดิม
- Animation controller/animation อยู่ใน compatibility entry หรือ View เท่านั้น ห้ามส่งเข้า Service/ViewModel

การ resolve intent ต้องใช้ลำดับนี้:

1. `targetIntentUuid`
2. `targetPaymentIntentNo`
3. `selectedDocNos` เทียบ `invoice.billReference`

เหตุผล: caller My Diary อาจไม่มี `billReferences` และ fallback เป็น `paymentIntentNo`; เทียบเฉพาะ `billReference` ไม่พอ

## 5. Architecture ที่เลือก

ใช้ `ChangeNotifier + immutable state + service หลักหนึ่งตัว` ให้ตรง Provider ที่โปรเจคมีอยู่

```text
payment_subV4/
├─ payment_subv4_page.dart
├─ models/
│  └─ payment_subv4_models.dart
├─ services/
│  └─ payment_subv4_service.dart
├─ viewmodels/
│  └─ payment_subv4_view_model.dart
├─ platform/
│  ├─ payment_subv4_file_actions.dart
│  ├─ payment_subv4_file_actions_io.dart
│  └─ payment_subv4_file_actions_web.dart
└─ widgets/
   ├─ payment_subv4_header.dart
   ├─ payment_subv4_tabs.dart
   ├─ payment_subv4_payment_card.dart
   └─ payment_subv4_bottom_action.dart
```

หลักแบ่ง responsibility:

- Model: immutable page-specific view data, request/response wrapper และ money
- Service: network/session orchestration และ response validation
- ViewModel: state transition, command guard, classification, calculation และ lifecycle
- View: dialog/navigation/snackbar/clipboard/picker/layout
- Platform adapter: save/share/pick behavior ที่ต่างระหว่าง Web กับ IO
- Widget: presentation เท่านั้น ไม่มี API/payload construction

ไม่สร้าง facade ซ้อน service ไม่แยก helper ที่ใช้จุดเดียว และแยกไฟล์เพิ่มเมื่อมี ownership ชัดหรือไฟล์อ่าน/ทดสอบยากจริง

## 6. Model design

### 6.1 Reuse model เดิม

ตรวจและ reuse ก่อนสร้างใหม่:

- `TeNantModel`
- `PayMentModel`
- `RenTalModel`
- `InvoiceModel`, `InvoiceReModel`, `InvoicePayModel`
- `TransModel`, `TransBillModel`, `TransBillStringModel`, `TransFineModel`
- `IntentsContractxFineModel`
- `IntentsInvoiceHistoryModel`
- `PaymentIntent` และ nested invoice model

ห้าม duplicate model กลางทั้งก้อน ห้ามแก้ model กลางเพื่อความสะดวกของหน้าเดียวโดยไม่วิเคราะห์ผลกระทบ

### 6.2 Wrapper เฉพาะหน้า

`payment_subv4_models.dart` เก็บเท่าที่จำเป็น:

- `PaymentSubV4Params`
- `PaymentSubV4State`
- `PaymentInvoiceRow`
- `PaymentSummary`
- `PaymentQrState`
- `PaymentSlipState`
- typed request/result สำหรับ Service
- status/operation enums
- `Money` หรือ helper จำนวนสตางค์

### 6.3 Money correctness

ใช้จำนวนสตางค์แบบ `int` เป็น canonical value ใน calculation:

```dart
class Money {
  final int satang;
}
```

กฎ:

- parse string ที่มี comma/null/empty อย่างปลอดภัย
- round เป็น 2 ตำแหน่งตาม behavior เดิมครั้งเดียวที่ boundary
- ห้ามใช้ formatted string คำนวณ
- แปลงเป็น `double` เฉพาะตอนสร้าง API payload ที่ contract ต้องการ
- payload test ต้องเทียบทุก field ไม่ตรวจเฉพาะ total
- VAT, WHT, discount, fine, deposit, insurance และ metadata ต้องคงค่าที่ต้นแบบส่งจริง ห้าม “แก้ให้สมเหตุผล” โดยไม่มีหลักฐาน

สูตรต้นแบบที่ต้อง freeze ด้วย fixture ก่อน refactor:

```text
sum_pvat
+ sum_tran_fine
- dis_sum_Pakan
- (sum_disamt + sum_disamt_in)
+ (sum_amt_in + sum_tran_fine_in)
+ fine_total
```

ต้องตรวจความหมายแต่ละ accumulator จาก fixture จริงก่อนตั้งชื่อใหม่

## 7. State design

ห้ามใช้ enum phase เดียวแทนทุก async operation เพราะ QR อาจ active พร้อม upload และบาง section อาจ error ขณะที่ส่วนอื่น ready

```text
PageStatus:
  idle, loading, ready, fatalError

PaymentOperation:
  none, creatingIntent, loadingIntent, renewingQr,
  uploadingSlip, cancelling

QrStatus:
  none, loading, active, expired, unavailable

AsyncSectionStatus:
  idle, loading, ready, error
```

`PaymentSubV4State` ต้องมี:

- `pageStatus`, `operation`, `qrStatus`
- section state/error สำหรับ rental, payment, invoice, fine, intent, history, transaction, slip
- `selectedTab` และ count ทั้ง 3 tab
- invoice rows, intents, history, transactions, fines
- resolved payment method/account
- `PaymentSummary`
- `PaymentQrState`
- `PaymentSlipState`
- `hasAutoSwitched`
- consumable UI event ID หรือ command result

ห้ามเก็บ `errorMessage`/`successMessage` แบบค้างแล้วให้ build แสดงซ้ำ ใช้ event ที่ consume ได้ครั้งเดียว หรือคืน typed command result ให้ View

`PaymentQrState` ต้องแยก:

- `intentUuid`, `paymentIntentNo`
- `ref1`, `ref2`, `ref3`, `payload`
- intent `softExpireAt` ตามชื่อ field จริง
- active QR session `softExpireAt`
- `secondsRemaining`
- `isSessionExpired`
- `isIntentExpired` เมื่อมีข้อมูล server ยืนยัน
- `hasUploadedSlip`

ห้ามสร้าง field `expiresAt` หรือ bill expiry ใหม่ถ้า API ไม่ได้ส่งจริง

## 8. Service contract และ testability

`PaymentSubV4Service` รับ dependency ผ่าน constructor:

```dart
PaymentSubV4Service({
  required http.Client client,
  required PaymentSessionReader sessionReader,
  required DateTime Function() now,
});
```

Public methods ที่ ViewModel เรียกได้:

```text
loadInitialData(...)
loadPaymentIntents(...)
loadIntentDetail(...)
createPaymentIntent(...)
generateQr(...)
uploadSlip(...)
cancelIntent(...)
loadHistory(...)
loadTransactions(...)
```

เฉพาะ parser, URI builder และ endpoint-specific helpers เป็น private

Service ต้อง:

- ใช้ `Uri.replace(queryParameters: ...)`
- ใช้ injected client เพื่อ mock ได้
- ใส่ timeout ที่ endpoint boundary
- ตรวจ status code, content type เมื่อจำเป็น, JSON shape และ success envelope
- แปลง error เป็น typed failure โดยไม่กลืน exception
- ไม่ใช้ `BuildContext`, Widget, controller, dialog, navigation หรือ `setState`
- ไม่เลือกไฟล์ ไม่เปิด clipboard และไม่บันทึกรูป
- log เฉพาะ endpoint path, status, operation ID และ row count

## 9. Auth gate — ต้องผ่านก่อนเรียก Payment API

ก่อน request ใดไป `pay-api.chaoperties.com`:

1. เรียก `MyHeadersIntents.checkauthpaymentintents()`
2. ถ้า false ห้ามยิง Payment API
3. ใช้ `MyHeadersIntents.build()` หลัง gate ผ่าน
4. ตรวจ Authorization header ไม่ว่างก่อนส่ง
5. หาก token refresh ล้มเหลว ให้คืน auth failure และหยุด flow

ห้าม duplicate เงื่อนไข rental/property ที่รองรับ auth เข้า ViewModel; ให้ helper เดิมเป็น source of truth

Shared helper ปัจจุบันมีการ log token prefix และ headers ทั้งก้อน ต้องแก้เพื่อลบข้อมูลอ่อนไหวก่อน acceptance ด้าน log จะผ่าน การแก้นี้เป็น security prerequisite ที่อยู่นอกโฟลเดอร์ใหม่ได้ แต่ต้องแยก diff และทดสอบไม่ให้ auth behavior เปลี่ยน

Preferences ที่ flow ใช้จริง:

- `renTalSer`
- `custno`
- `usercid`
- `ser`
- `qutser`

`pay_encoded64` ให้ auth helper อ่านเท่านั้น ไม่ส่งขึ้น ViewModel/state

## 10. Endpoint reachability map

ก่อน implement Service ต้องทำตารางจาก call site จริง แบ่งทุก method เป็น:

- Active และต้องย้าย
- Active เฉพาะ payment channel
- Legacy fallback ที่มีหลักฐานว่ายังเรียก
- Dead/unreachable และไม่ย้าย

### 10.1 Payment Intent API ที่ active

| Flow | Method/helper เดิม | Contract สำคัญ |
|---|---|---|
| Auth gate | `checkauthpaymentintents` | false แล้วห้ามยิง pay API |
| โหลด intents | `postPaymentIntentsState` | `POST /v1/payment/intents/state`; payload customer/property |
| สร้าง intent | `postPaymentIntents` | `POST /v1/payment/intent`; payload invoices/trans/customer_data/account |
| โหลด detail | `getDetailsPaymentIntents` | `GET /v1/payment/intent/{uuid}` |
| Generate/Renew QR | `postGeneratePaymentIntents` | `POST /v1/payment/intent/{uuid}/generate` |
| Cancel | `DeletePaymentIntents_UuidCanceled` | `DELETE /v1/payment/intent/{uuid}?force=1` |
| Upload slip | `_uploadSlipImage` | `POST /v1/payment/intent/{uuid}/upload/slip` multipart |

Upload slip fields ที่ต้องคง:

```text
file
amount
transfer_date
transfer_ref_no
transfer_type
notes
```

หลัง upload สำเร็จต้องโหลด intent detail/intents ใหม่ แล้วใช้ server state ตัดสิน tab ห้ามเปลี่ยน UI จาก HTTP status อย่างเดียว

### 10.2 Legacy PHP ที่ต้องตรวจ reachability

- `GC_rental_setring.php`
- `GC_payMent.php`
- `GC_fine.php`
- `GC_selectFine_inv.php`
- `GC_bill_invoice.php`
- `GC_bill_invoiceHistory_v2.php`
- `In_tran_select_fine_inv.php`
- `In_tran_select_fine.php`
- `GC_tenantlookAS.php`
- `GC_tran_select.php`
- `GC_tran_select_fin.php`
- `In_tran_select_Chao_user.php`
- `D_tran_select_ser_User.php`
- `In_tran_financet_User.php`
- `File_uploadSlip_NewEdit.php`

`File_uploadSlip_NewEdit.php` ไม่ใช่ active Payment Intent upload โดยอัตโนมัติ ย้ายเฉพาะเมื่อ reachability table ยืนยันว่ามี active branch ใช้จริง

Helper `payment-intents-upslip.dart` ใช้ endpoint/header contract ต่างจาก active V4 flow ห้ามนำมาใช้เพียงเพราะชื่อใกล้กัน ต้องพิสูจน์ contract ก่อน

## 11. Status classification

ห้ามใช้ substring กว้าง เช่น `contains('pay')`, `contains('pending')`, `contains('รอการ')` เป็น final logic

สร้าง normalized classifier จาก fixture response จริง โดยพิจารณาร่วมกัน:

- `status`
- `systemStatus`
- `statusExtended.statusVerbose`
- `statusExtended.statusThai`
- `statusExtended.isActive`
- `statusExtended.isExpired`
- `latestSlip`
- detail `attaches`

ผล classifier:

```text
payable
awaitingSlip
awaitingVerification
completed
expired
cancelled
failed
unknown
```

กฎ:

- unknown status ต้องไม่ถูกจัดเป็น payable โดยเดา
- เก็บ unknown telemetry แบบไม่ log PII
- tab count และ action availability ใช้ classifier เดียวกัน
- มี table-driven test สำหรับทุก status fixture

## 12. Initialization และ refresh

ลำดับ:

1. เริ่ม operation generation ใหม่และตั้ง page loading
2. validate params และอ่าน session context
3. ตรวจ auth gate
4. โหลด rental, payment account และ tenant prerequisites
5. โหลด intents ก่อน invoice classification
6. โหลด invoice/fine/history/transaction ตาม dependency จริง
7. normalize เป็น view rows
8. resolve payment method จาก `paymentSerial`
9. derive payment type จาก matched `PayMentModel`; ใช้ `paymentTypeSerial` เป็น fallback
10. resolve target intent ตาม UUID/intent no/bill reference
11. คำนวณ summary และ tab counts จาก source เดียว
12. auto-switch tabครั้งเดียว
13. emit ready เฉพาะเมื่อ operation ID ยังเป็นรุ่นล่าสุด

ใช้ `Future.wait` เฉพาะ request ที่ไม่พึ่งกัน ห้าม parallelize flow ที่ต้องใช้ผลก่อนหน้า

Refresh:

- รักษาข้อมูล section ที่โหลดสำเร็จเมื่อ section อื่นล้ม
- แสดง section error และ retry แยก
- response รุ่นเก่าห้ามทับ state รุ่นใหม่
- tab change ไม่ควร reload ทุก API โดยอัตโนมัติ; reload เมื่อ user refresh หรือ flow mutation ต้อง reconcile

## 13. ViewModel commands

Public commands เฉพาะที่ View ต้องเรียก:

```text
initialize()
refresh()
selectTab(tab)
createPaymentIntent()
openIntent(intentIdentity)
renewQr()
reloadIntent()
setSlip(bytes, fileName, mimeType)
clearSlip()
uploadSlip()
cancelPayment()
consumeEvent(eventId)
```

ไม่มี `selectPaymentMethod()` และ `toggleInvoice()` ใน parity scope เพราะ account และ selected invoices มาจาก caller/admin

ViewModel ห้ามใช้:

- `BuildContext`
- `Navigator`
- `ScaffoldMessenger`
- `showDialog`/toast
- `MediaQuery`
- `TextEditingController`
- picker/clipboard/save/share
- `setState`

ทุก mutation command ต้องมี operation guard กัน double tap

สำหรับ create intent:

- สร้าง idempotency/reconciliation strategy ตาม API ที่มีจริง
- หาก request timeout หลังส่ง ให้ reload intents เทียบ selected bill references ก่อน retry
- ห้ามสร้าง intent ซ้ำเพราะ client ไม่ได้รับ response
- UUID จาก serverเป็น source of truth ห้าม generate UUID แทน server

## 14. QR lifecycle

รองรับ channel mapping เดิม:

| `ptser` | การแสดงผล/แหล่ง payload |
|---|---|
| `2` | Bank transfer/image |
| `5` | PromptPay generator |
| `6` | Bill Payment payload |
| `7` | Server QR payload |
| `11` | e-Wallet generator |

กฎ:

- ตรวจ account/bank/payload ก่อนแสดง QR
- หลัง create intent โหลด intents/detail เพื่อยืนยัน UUID/ref/session
- หากมี `active_qr_session` ที่ยัง valid ให้ใช้เดิม ไม่ยิง generate จนได้ 409
- renew ใช้ intent UUID เดิม
- 409 ต้อง reload detail และ reconcile session ก่อน retry
- timer ใช้ server `active_qr_session.soft_expire_at` เป็น source of truth
- timer มีหน้าที่ render ไม่แก้ server stateเอง
- แยก intent `soft_expire_at` กับ session `soft_expire_at`; ไม่อนุมาน bill expiry จากชื่อใหม่ที่ไม่มีใน response
- หากมี slip แล้ว ห้าม auto-renew/cancel โดยไม่ดู server status
- timer/subscription ต้อง cancel ใน `dispose()`
- inject clock เพื่อทดสอบ boundary โดยไม่รอเวลาจริง

## 15. Slip flow และ platform handling

ลำดับ:

1. View/platform adapter เลือกรูป
2. validate MIME, extension, count และ size
3. รวม/resize นอก main isolate เมื่อเหมาะสม
4. ViewModel รับ bytes/name/MIME ที่พร้อมใช้
5. preview จาก bytes ชุดเดียว
6. confirm แล้ว `uploadSlip()` พร้อม duplicate guard
7. ตรวจ HTTP และ response body
8. reload detail/intents
9. classify status ใหม่จาก server
10. ค่อยแสดง success/navigation

กฎ:

- ไม่เก็บ bytes/base64 ซ้ำหลาย state
- จำกัดจำนวนและขนาดรูปด้วยค่าที่ระบุชัดก่อน implement
- timeout image processing แล้ว fallback ต้องแจ้งผู้ใช้ ไม่เงียบ
- ใช้ conditional import ห้ามกระจาย `dart:io` และ `universal_html` ใน business/UI files
- Web cancel picker ต้อง complete command ไม่ปล่อย Future ค้าง
- navigation หลัง upload เกิดเมื่อ server ยืนยันสำเร็จเท่านั้น

## 16. UI specification

### 16.1 Tokens

```text
brandNavy       #002B49
brandBlue       #0E5C9E
brandAccent     #FF6B00
brandAccentDark #E05E00
pageBackground  #F1F5F9
surface         #F8FAFC
textPrimary     #0F172A
textSecondary   #64748B
amberBg         #FEF3C7
amberFg         #B45309
skyAction       #0284C7
success         #10B981
```

ใช้ `LINESeed1`/`LINESeed2` ที่ประกาศใน `pubspec.yaml`; ไม่เพิ่ม Google Fonts runtime

### 16.2 Composition

```text
Scaffold
├─ PaymentTopBar
├─ PaymentCountdownBar
├─ PaymentStatusTabs
├─ scroll content
│  ├─ invoice/intent section
│  ├─ PaymentChannelCard
│  ├─ PaymentQrCard หรือ PaymentBankTransferCard
│  ├─ PaymentInstructionsCard
│  └─ history/transaction details
└─ PaymentStickyActionBar
```

Top bar:

- white, safe area, back targetอย่างน้อย 44 px
- title ไทย/อังกฤษ
- status indicator มี semantic label
- help callback อยู่ View

Countdown:

- แสดงเฉพาะ active session
- ใช้ amber เมื่อ active, red เมื่อ expired
- number ใช้ tabular/monospace style
- pulse เฉพาะ indicator และเคารพ reduced motion

Tabs:

- 3 status พร้อม count badge
- label truncate โดยไม่ overflow
- tab changeเรียก ViewModel commandเท่านั้น

Payment card:

- shared anatomy สำหรับ QR/bank transfer
- ref และ expiry 2 บรรทัด
- account/amount copy แยก action
- QR widgetรับ `PaymentQrState` เท่านั้น
- ไม่มี calculation/API ใน widget

Sticky action:

- mobile แสดงยอดรวมและ CTA
- disabled เมื่อ amount ไม่ถูกต้อง, ไม่มีรายการ, operation กำลังทำงาน, session/action ใช้ไม่ได้
- CTA เรียก command เดียว
- มี bottom paddingไม่บัง content

### 16.3 Responsive และ accessibility

- Mobile 390–430 px: single column
- Tablet: split เมื่อ constraint พอจริง
- Desktop: จำกัด max width และ split detail/payment
- ทดสอบ text scale 100%, 125%, 150%
- touch target สำคัญอย่างน้อย 44 px
- รองรับ keyboard focus บน Web/Desktop
- icon-only button มี tooltip/semantic label
- status ห้ามสื่อด้วยสีอย่างเดียว
- QR, account, ref, amount และ CTA ห้ามถูกตัด

ต้องแนบ path/URL/screenshot ของ HTML design reference ก่อนตัดสิน visual parity; ปัจจุบัน repo ไม่มี reference ดังกล่าว

## 17. Dialog, navigation และ feedback

Dialog อยู่ View และรับ state/callback:

- attach-slip notice
- payment confirmation
- QR detail/expiry
- slip preview/progress
- cancel confirmation
- success/error

Dialog ห้ามยิง API เอง

Navigation rules:

- back/pay later behavior ต้องเทียบ caller เดิม
- ห้าม `pushAndRemoveUntil` ก่อนรู้ว่า mutation สำเร็จ
- View ตรวจ `context.mounted` หลัง await
- ViewModel ตรวจ disposed/operation generation ก่อน notify
- Snackbar/toast ใช้ consumable event ป้องกันแสดงซ้ำจาก rebuild

## 18. Migration sequence

### Phase 0 — Freeze behavior

1. บันทึก baseline hash/diff ของต้นแบบ
2. ทำ caller inventory
3. ทำ method reachability table
4. ทำ endpoint/payload/status fixtures จาก response ที่ได้รับอนุญาตและ redact แล้ว
5. ระบุ design reference
6. บันทึก analyzer/test baseline

### Phase 1 — Pure models/tests

1. สร้าง params, money, row, summary, QR/slip state และ classifiers
2. เขียน table-driven status tests
3. เขียน summary calculation tests
4. เขียน payload golden tests

### Phase 2 — Service

1. inject client/session/clock
2. ย้าย read endpoint ทีละ flow
3. เพิ่ม auth gate
4. ย้าย create/detail/generate/upload/cancel
5. เพิ่ม timeout/error parser/reconciliation tests
6. ไม่ย้าย dead method

### Phase 3 — ViewModel

1. initialize/refresh และ generation guard
2. tab classification/auto-switch
3. payment method resolution
4. create/open/reload/renew
5. slip upload/cancel
6. event consumption และ dispose

### Phase 4 — UI

1. page entry/provider
2. top bar/countdown/tabs
3. invoice/intent cards
4. QR/bank transfer/instructions
5. sticky action/dialogs
6. platform adapters
7. responsive/accessibility tests

### Phase 5 — Migration gate

ยังไม่แก้ caller จนกว่า:

1. parser/payload tests ผ่าน
2. summary fixtures ตรงต้นแบบ
3. intent/detail/QR/upload/cancel flow ผ่านด้วย mock/staging ที่ได้รับอนุญาต
4. widget states ผ่าน
5. baseline hash ต้นแบบยังตรง
6. auth gate ป้องกัน unauthorized request ได้
7. log ไม่มี credential/token/slip data

จากนั้น:

1. เพิ่ม compatibility constructor/entry
2. แก้ caller ทีละจุด
3. ส่ง `targetIntentUuid`/`targetPaymentIntentNo` เมื่อ caller มีค่า
4. smoke test หลังแต่ละ caller
5. เก็บ rollback ง่าย: caller สามารถสลับกลับ legacy entry ได้จนจบ rollout

## 19. Test plan

### 19.1 Unit tests

- response parser: valid, null, empty list, malformed JSON, wrong envelope, non-2xx
- URI/query encoding ทุก legacy endpoint ที่ active
- auth gate false แล้ว client ไม่ถูกเรียก
- Authorization ว่างแล้วไม่ส่ง request
- money parse/round และ formula fixtures
- payload golden: receiving account, invoices, metadata, list fee, trans, customer data
- status classifier ทุก known/unknown combination
- resolve intent ด้วย UUID, intent no และ bill reference
- derive payment type จาก `PayMentModel` และ nullable fallback
- QR active/expired/409/retry/detail reconciliation
- duplicate create/upload/cancel
- create timeout แล้วพบ intent ที่ server สร้างแล้ว
- stale response และ dispose

### 19.2 Widget tests

- loading, empty, section error, fatal error, ready
- tab counts และ auto-switchครั้งเดียว
- deep-link intent เปิด tab ถูกต้อง
- QR/bank transfer channel variants
- countdown boundary ด้วย fake clock
- slip preview/upload progress/success/error
- CTA disabled matrix
- consumable feedback ไม่แสดงซ้ำหลัง rebuild
- viewport 390, 430, tablet, desktop
- text scale 1.0, 1.25, 1.5
- semantics/tooltip/focus

### 19.3 Manual integration

ใช้ test customer/property หรือ staging ที่ได้รับอนุญาตเท่านั้น:

- caller จาก payment main และ My Diary
- ไม่มี invoice, invoice เดียว, หลาย invoice, fine หลายแบบ
- intent เดิมไม่มี invoice array
- intent มี active session
- QR หมดอายุระหว่าง dialog
- generate ตอบ 409
- upload มี/ไม่มี existing slip
- cancel ก่อนและหลัง slip
- ปิดหน้าเร็วระหว่าง request
- Android, iOS, Web และ Desktop ตาม support matrix
- network timeout/offline/token refresh failure

## 20. Acceptance criteria

- content hash ของต้นแบบตรง baseline ตอนเริ่ม และ diff เดิมไม่สูญหาย
- โค้ดใหม่ไม่ import implementation จากต้นแบบ
- API/payload/status ที่ย้ายมี source fixture หรือ call-site evidence
- ไม่มี API call/payload construction ใน View/Dialog
- ไม่มี `BuildContext` ใน Service/ViewModel
- calculation ใช้ canonical numeric source เดียว
- payment account มาจาก caller/admin ไม่เกิด selector ใหม่โดยไม่อนุมัติ
- deep-link intent resolve ได้แม้ไม่มี bill references
- auth gate false แล้วไม่มี request ไป Payment API
- ไม่มี Authorization/token/credential/slip bytes ใน log
- create intent ป้องกัน duplicate หลัง timeout/retry
- QR ใช้ UUID และ session expiry จาก server
- upload/cancel เปลี่ยน UI หลัง server reconciliation
- timer/subscription/controller ถูก dispose
- mobile/tablet/desktop ไม่ overflow และ accessibility checks ผ่าน
- `dart format` ผ่านสำหรับไฟล์ที่แก้
- ไม่มี analyzer error ใหม่เทียบ baseline; เป้าหมายสุดท้ายคือ analyzer ไม่มี error
- unit/widget tests ที่เพิ่มผ่าน
- caller migration ทำทีละจุดและ rollback ได้
- ไม่มี dead code, debug print หรือ dependency ใหม่ที่ไม่จำเป็น

## 21. Checklist ก่อนเริ่ม implement

- [x] ตรวจว่า `payment_subV4_page.dart` และโครงสร้าง MVVM สร้างเสร็จสมบูรณ์
- [x] สร้าง Model (Money, Params, Enums, Summary, QR/Slip State)
- [x] สร้าง Service Facade จัดการทุก Endpoint
- [x] สร้าง ViewModel คุมสถานะ, คำนวณเงิน, และ flow การทำงาน
- [x] ลบ sensitive logging ออกจาก `MyHeadersIntents` (ป้องกัน token รั่วใน log)
- [x] สร้าง Unit Tests (Money calculation & Intent status classification)
- [x] สร้าง Widget Smoke Test สำหรับ PaymentSubV4Page
- [ ] ทดสอบ manual รันแอปในเครื่องเพื่อความมั่นใจ 100% ก่อนสลับ caller

## 22. Checklist ก่อนเชื่อม caller

- [ ] public entry รับ params และ animation compatibility ครบ
- [ ] payment main ส่ง selected docs/payment serial/type ถูกต้อง
- [ ] My Diary ส่ง target intent UUID/no เมื่อมี
- [ ] `fromIntent` behavior ผ่าน test
- [ ] `cuslang` ครอบคลุมข้อความ/action/error
- [ ] ไม่มี payment/invoice selector ใหม่เกิน parity scope
- [ ] auth unavailable มี fallback/error ที่ไม่ยิง API
- [ ] mock/staging flow create/detail/generate/upload/cancel ผ่าน
- [ ] baseline hash ต้นแบบยังตรง

## 23. Checklist ก่อน merge

- [ ] format/analyze/test ผ่านตาม baseline policy
- [ ] ตรวจ diff ทุกไฟล์และแยก security helper change ชัดเจน
- [ ] ตรวจไม่มี secret/PII/sensitive log
- [ ] ตรวจไม่มี production fixture ที่มีข้อมูลจริง commit เข้า repo
- [ ] ทดสอบ responsive/text scale/accessibility
- [ ] ทดสอบ caller ทุกจุด
- [ ] ทดสอบ retry/offline/expired/409/duplicate submit
- [ ] บันทึก known limitations และ API assumptions
- [ ] ยืนยัน rollback path
- [ ] ขอ review ก่อน merge
