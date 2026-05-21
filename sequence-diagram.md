# Sequence Diagrams — App Payments

> เอกสารนี้รวม Sequence Diagram หลัก ๆ ของระบบ `app_payments` เพื่อให้เห็นภาพ flow การทำงานของแต่ละส่วน

---

## 📋 สารบัญ

1. [Flow 1: Payment Intent & QR Code Generation](#flow-1-payment-intent--qr-code-generation)
2. [Flow 2: Slip Upload & Verification](#flow-2-slip-upload--verification)
3. [Flow 3: Bank Transaction Reconciliation](#flow-3-bank-transaction-reconciliation)
4. [Flow 4: Admin Approval Queue](#flow-4-admin-approval-queue)
5. [Flow 5: Client Registration](#flow-5-client-registration)
6. [Flow 6: Property Management](#flow-6-property-management)
7. [Flow 7: Customer Token Issuance](#flow-7-customer-token-issuance)

---

## Flow 1: Payment Intent & QR Code Generation

```mermaid
sequenceDiagram
    autonumber
    actor Client as Client/Frontend
    participant API as Laravel API
    participant Auth as Auth Middleware
    participant PaymentSvc as PaymentIntentService
    participant QRSvc as QrSessionService
    participant DB as Database

    rect rgb(230, 245, 255)
        Note over Client,DB: สร้างรายการชำระเงิน และสร้าง QR Code

        Client->>API: POST /v1/payment/intent
        Note right of Client: Body: amount, currency,<br/>description, metadata, etc.

        API->>Auth: payment.auth + client.activity
        Note right of Auth: ตรวจสอบ Client Key +<br/>บันทึก Client Activity Log
        Auth-->>API: Authenticated

        API->>PaymentSvc: createIntent(data)
        Note right of PaymentSvc: สร้าง PaymentIntent<br/>ตรวจสอบข้อมูล + สร้าง UUID

        PaymentSvc->>DB: INSERT l_payment_intents
        Note right of DB: บันทึก: uuid, amount, currency,<br/>status=pending, client_id, etc.
        DB-->>PaymentSvc: PaymentIntent Model

        PaymentSvc-->>API: PaymentIntent
        API-->>Client: 201 Created + { uuid, amount, status }

        Client->>API: POST /v1/payment/intent/{uuid}/generate
        API->>Auth: payment.auth + client.activity
        Auth-->>API: Authenticated

        API->>QRSvc: generateQrCode(intent)
        Note right of QRSvc: สร้าง QR Code payload<br/>(PromptPay / Thai QR)

        QRSvc->>DB: INSERT l_qr_sessions
        Note right of DB: บันทึก: session_id, qr_data,<br/>expires_at, payment_intent_id
        DB-->>QRSvc: QrSession

        QRSvc-->>API: { qr_code_image, session_id, expires_at }
        API-->>Client: 200 OK + QR Code Data
    end
```

### รายละเอียดเพิ่มเติม

| ขั้นตอน | รายละเอียด                                                                    |
| ------- | ----------------------------------------------------------------------------- |
| 1       | Client ส่งคำขอสร้าง Payment Intent พร้อมข้อมูลการชำระเงิน                     |
| 2       | Middleware `payment.auth` ตรวจสอบ Client Key และ `client.activity` บันทึก log |
| 3       | `PaymentIntentService::createIntent()` ตรวจสอบข้อมูลและสร้าง UUID             |
| 4       | บันทึกลงตาราง `l_payment_intents` สถานะเริ่มต้นเป็น `pending`                 |
| 5       | ส่งคืน Payment Intent UUID ให้ Client                                         |
| 6       | Client ขอสร้าง QR Code จาก Payment Intent UUID                                |
| 7       | `QrSessionService::generateQrCode()` สร้าง QR payload ตามมาตรฐาน PromptPay    |
| 8       | บันทึก QR Session ลง `l_qr_sessions` พร้อมกำหนดเวลาหมดอายุ                    |
| 9       | ส่ง QR Code (base64 image) กลับให้ Client แสดงผล                              |

---

## Flow 2: Slip Upload & Verification

```mermaid
sequenceDiagram
    autonumber
    actor Customer as Customer/Mobile
    participant API as Laravel API
    participant Auth as Auth Middleware
    participant Feature as ClientFeatureService
    participant AttachSvc as PaymentAttachService
    participant MatchSvc as PaymentMatchingService
    participant DB as Database
    participant SlipAPI as Slip Verify API (External)

    rect rgb(255, 245, 230)
        Note over Customer,SlipAPI: อัปโหลดสลิป (สลิปเข้า Approval Queue เสมอ)

        Customer->>API: POST /v1/payment/intent/{uuid}/upload/slip
        Note right of Customer: FormData: file (jpg/png/pdf),<br/>notes (optional)

        API->>Auth: payment.auth + client.activity
        Auth-->>API: Authenticated

        API->>Feature: can('slip_verify')
        Note right of Feature: ตรวจสอบ Feature Flag +<br/>Quota รายวัน (ไม่บล็อกการอัปโหลด)
        Feature-->>API: auto_verify = true/false

        API->>AttachSvc: uploadSlip(data, file, metadata)
        Note right of AttachSvc: ตรวจสอบไฟล์: mime, size,<br/>สร้างชื่อไฟล์ unique

        %% Phase 1: Optional Auto-Verify (outside DB transaction)
        alt auto_verify == true AND NOT PDF
            AttachSvc->>SlipAPI: POST /verify (slip image)
            Note right of SlipAPI: ตรวจสอบข้อมูลในสลิป:<br/>ธนาคาร, วันที่, จำนวนเงิน, ref
            SlipAPI-->>AttachSvc: verifyResult {status, code, details}
        else auto_verify == false OR PDF
            Note over AttachSvc: Skip external verification<br/>verifyResult = null
        end

        %% Phase 2: DB writes (always happen)
        AttachSvc->>DB: INSERT l_payment_slips
        Note right of DB: บันทึก: slip_no, file_path,<br/>original_filename, status=pending<br/>(ไม่ขึ้นกับ verify)
        DB-->>AttachSvc: Slip Record

        AttachSvc->>MatchSvc: createSlipUploadApproval(intent, slip, qr, verifyResult)
        Note right of MatchSvc: สร้าง AdminApprovalQueue เสมอ<br/>confidence_score จาก verifyResult (ถ้ามี)
        MatchSvc->>DB: INSERT l_admin_approval_queue
        Note right of DB: status=pending, type=payment_slip<br/>priority ขึ้นกับ confidence
        DB-->>MatchSvc: ApprovalQueue

        alt verifyResult confidence สูง
            MatchSvc->>MatchSvc: autoApprovalService.process()
            Note right of MatchSvc: อาจ auto-approve ทันที<br/>ถ้าคะแนนสูงพอ
        end

        AttachSvc->>DB: UPDATE l_payment_intents
        Note right of DB: status = awaiting_approval

        AttachSvc-->>API: Slip Data
        API-->>Customer: 201 Created + { slip_no, status, amount }
    end
```

### รายละเอียดเพิ่มเติม

| ขั้นตอน | รายละเอียด                                                                                                                                                     |
| ------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1       | Customer อัปโหลดสลิปการโอนเงิน (รองรับ jpg, jpeg, png, pdf)                                                                                                    |
| 2       | ตรวจสอบสิทธิ์ Client และบันทึก Activity Log                                                                                                                    |
| 3       | `ClientFeatureService::can('slip_verify')` ตรวจสอบว่าลูกค้าเปิดใช้งานฟีเจอร์นี้และยังมี quota เหลือหรือไม่ — **ไม่บล็อกการอัปโหลด** แค่ส่งค่า `auto_verify` ไป |
| 4       | `PaymentAttachService::uploadSlip()` ตรวจสอบไฟล์และสร้างชื่อ unique                                                                                            |
| 5       | **ถ้า `auto_verify=true` และไม่ใช่ PDF** → เรียก External Slip Verify API (non-blocking, ถ้าล้มเหลว upload ยังดำเนินต่อ)                                       |
| 6       | **บันทึกสลิปลง `l_payment_slips`** สถานะ `pending` — **เกิดขึ้นเสมอ**                                                                                          |
| 7       | **สร้าง `AdminApprovalQueue`** สถานะ `pending` — **เกิดขึ้นเสมอ** โดย `confidence_score` และ `priority` จะสูงขึ้นถ้ามี verifyResult                            |
| 8       | **ถ้า confidence สูงพอ** → `autoApprovalService` อาจอนุมัติอัตโนมัติทันที                                                                                      |
| 9       | อัปเดต Payment Intent เป็น `awaiting_approval`                                                                                                                 |

### สรุป Logic `slip_verify`

```
┌─────────────────────────────────────────────────────────────┐
│  อัปโหลดสลิป ──► สร้าง Slip Record ──► สร้าง Approval Queue   │
│       ▲              (เสมอ)              (เสมอ)             │
│       │                                                     │
│  slip_verify feature?                                       │
│       │                                                     │
│       ├── YES ──► เรียก SlipVerifyService (ภายนอก)         │
│       │              │                                      │
│       │              └──► เพิ่ม confidence_score          │
│       │                   เพิ่ม priority                    │
│       │                   อาจ trigger auto-approval           │
│       │                                                     │
│       └── NO ──► verifyResult = null                        │
│                     confidence_score = 0 (default)            │
│                     priority = ปกติ                         │
│                     รอ Admin อนุมัติตามปกติ                 │
└─────────────────────────────────────────────────────────────┘
```

**หลักการสำคัญ:** `slip_verify` เป็น **optional enhancement** ที่ช่วยเพิ่มความน่าเชื่อถือของสลิป แต่ไม่ว่าจะ verify หรือไม่ สลิปก็จะถูกสร้างและส่งเข้า `admin_approval_queue` เสมอ — ต่างกันแค่ **ความเร็วในการได้รับการอนุมัติ** (auto-approve vs รอ manual approve)

---

## Flow 3: Bank Transaction Reconciliation

```mermaid
sequenceDiagram
    autonumber
    actor Admin as Admin/Backend
    participant API as Laravel API
    participant Auth as Auth Middleware
    participant Feature as ClientFeatureService
    participant UploadCtrl as BankTransactionUploadController
    participant ImportSvc as BankTransactionImportService
    participant MatchSvc as PaymentMatchingService
    participant DB as Database
    participant Queue as Queue Worker
    participant External as External Database

    rect rgb(230, 255, 230)
        Note over Admin,External: อัปโหลดไฟล์ธนาคารและ Reconcile

        Admin->>API: POST /v1/reconcile/bank-transaction-uploads
        Note right of Admin: FormData: bank_file (csv/xlsx),<br/>bank_merchant_id, pattern_id

        API->>Auth: verify.basicauth + client.feature:bank_transaction_upload
        Auth-->>API: Authenticated

        API->>UploadCtrl: store(request)
        UploadCtrl->>ImportSvc: processUpload(file, config)
        Note right of ImportSvc: ตรวจสอบไฟล์: extension, size<br/>ตรวจจับ pattern อัตโนมัติ

        ImportSvc->>DB: INSERT l_bank_transaction_uploads
        Note right of DB: บันทึก: uuid, file_path,<br/>status=processing, total_rows
        DB-->>ImportSvc: Upload Record

        ImportSvc->>Queue: dispatch(ProcessBankTransactionFileJob)
        Note right of Queue: ประมวลผลไฟล์เป็น chunks<br/>ตาม config chunk_size

        Queue->>DB: INSERT l_bank_transactions (bulk)
        Note right of DB: บันทึกธุรกรรมแต่ละรายการ:<br/>bank_ref_no, amount, date, status=unmatched

        Queue->>Queue: dispatch(MatchBankTransactionsJob)
        Queue->>DB: SELECT l_payment_intents<br/>WHERE status=pending
        DB-->>Queue: Pending Intents

        Queue->>MatchSvc: findCandidates(transaction)
        Note right of MatchSvc: จับคู่ตาม:<br/>- amount (± tolerance)<br/>- time (± tolerance)<br/>- ref_no

        alt Match Found
            MatchSvc->>DB: UPDATE l_bank_transactions<br/>SET status=matched, intent_id=?
            MatchSvc->>DB: INSERT l_admin_approval_queue
            Note right of DB: สร้างรายการรออนุมัติ:<br/>approval_type=auto_match, status=pending
        else No Match
            MatchSvc->>DB: UPDATE l_bank_transactions<br/>SET status=unmatched
        end

        Queue->>Queue: dispatch(SyncPaymentToExternalDatabaseJob)
        Queue->>External: INSERT/UPDATE external_payments
        External-->>Queue: Synced

        Queue->>DB: UPDATE l_bank_transaction_uploads<br/>SET status=completed
    end
```

### รายละเอียดเพิ่มเติม

| ขั้นตอน | รายละเอียด                                                                    |
| ------- | ----------------------------------------------------------------------------- |
| 1       | Admin อัปโหลดไฟล์ธุรกรรมธนาคาร (รองรับ CSV, XLSX, XLS)                        |
| 2       | ตรวจสอบสิทธิ์ Basic Auth และ Feature Flag `bank_transaction_upload`           |
| 3       | `BankTransactionImportService::processUpload()` ตรวจสอบไฟล์และ detect pattern |
| 4       | บันทึกข้อมูลการอัปโหลดลง `l_bank_transaction_uploads`                         |
| 5       | Dispatch `ProcessBankTransactionFileJob` ประมวลผลไฟล์เป็น chunks              |
| 6       | บันทึกธุรกรรมแต่ละรายการลง `l_bank_transactions`                              |
| 7       | Dispatch `MatchBankTransactionsJob` ค้นหา Payment Intent ที่ตรงกัน            |
| 8       | `PaymentMatchingService::findCandidates()` จับคู่ตามจำนวนเงิน, วันที่, ref    |
| 9       | ถ้าจับคู่ได้ สร้างรายการใน `l_admin_approval_queue` รออนุมัติ                 |
| 10      | Sync ข้อมูลไปยัง External Database                                            |

---

## Flow 4: Admin Approval Queue

```mermaid
sequenceDiagram
    autonumber
    actor Admin as Admin/Backend
    participant API as Laravel API
    participant Auth as Auth Middleware
    participant ApprovalCtrl as AdminApprovalController
    participant BankCtrl as AdminBankController
    participant DB as Database
    participant Queue as Queue Worker
    participant External as External Database

    rect rgb(255, 230, 245)
        Note over Admin,External: อนุมัติธุรกรรมธนาคาร

        Admin->>API: GET /v1/reconcile/approvals/pending
        API->>Auth: verify.basicauth
        Auth-->>API: Authenticated

        API->>ApprovalCtrl: pendingApprovals()
        ApprovalCtrl->>DB: SELECT l_admin_approval_queue<br/>WHERE status=pending
        DB-->>ApprovalCtrl: Pending Approvals
        ApprovalCtrl-->>API: { approvals[], meta{} }
        API-->>Admin: 200 OK + Pending List

        Admin->>API: GET /v1/reconcile/approvals/{uuid}
        API->>ApprovalCtrl: show(approval)
        ApprovalCtrl->>DB: SELECT approval + relations
        DB-->>ApprovalCtrl: Approval Detail
        ApprovalCtrl-->>API: { approval, transaction, intent }
        API-->>Admin: 200 OK + Detail

        alt Admin Approves
            Admin->>API: POST /v1/reconcile/approvals/{uuid}/approve
            API->>ApprovalCtrl: approve(approval)
            ApprovalCtrl->>DB: UPDATE l_admin_approval_queue<br/>SET status=approved, approved_by=admin
            ApprovalCtrl->>DB: UPDATE l_bank_transactions<br/>SET status=approved
            ApprovalCtrl->>DB: UPDATE l_payment_intents<br/>SET status=paid, paid_at=now

            ApprovalCtrl->>Queue: dispatch(ProcessApprovedBankTransactionJob)
            Queue->>External: UPDATE external_payments<br/>SET status=paid
            External-->>Queue: Updated
        else Admin Rejects
            Admin->>API: POST /v1/reconcile/approvals/{uuid}/reject
            API->>ApprovalCtrl: reject(approval)
            ApprovalCtrl->>DB: UPDATE l_admin_approval_queue<br/>SET status=rejected, rejected_by=admin
            ApprovalCtrl->>DB: UPDATE l_bank_transactions<br/>SET status=rejected
            ApprovalCtrl->>DB: UPDATE l_payment_intents<br/>SET status=pending (rollback)
        end

        API-->>Admin: 200 OK + Result
    end
```

### รายละเอียดเพิ่มเติม

| ขั้นตอน | รายละเอียด                                                                                |
| ------- | ----------------------------------------------------------------------------------------- |
| 1       | Admin ขอดูรายการรออนุมัติ                                                                 |
| 2       | ตรวจสอบสิทธิ์ด้วย Basic Auth                                                              |
| 3       | ดึงรายการจาก `l_admin_approval_queue` ที่สถานะ `pending`                                  |
| 4       | Admin ดูรายละเอียดการอนุมัติ (รวมข้อมูลธุรกรรมและ Payment Intent)                         |
| 5       | **กรณีอนุมัติ:** อัปเดตสถานะ approval, ธุรกรรมธนาคาร, และ Payment Intent เป็น `paid`      |
| 6       | Dispatch job sync ข้อมูลไป External Database                                              |
| 7       | **กรณีปฏิเสธ:** อัปเดตสถานะเป็น `rejected` และ rollback Payment Intent กลับเป็น `pending` |

---

## Flow 5: Client Registration

```mermaid
sequenceDiagram
    autonumber
    actor SuperAdmin as Super Admin
    participant API as Laravel API
    participant Auth as BasicAuth Middleware
    participant ClientCtrl as ClientRegisterController
    participant Property as Property Model
    participant DB as Database

    rect rgb(240, 248, 255)
        Note over SuperAdmin,DB: ลงทะเบียน Client ใหม่

        SuperAdmin->>API: POST /v1/client/register
        Note right of SuperAdmin: Body: client_name, type,<br/>property_id, is_active

        API->>Auth: basic.auth
        Auth-->>API: Authenticated

        API->>ClientCtrl: store(ClientRegisterRequest)
        ClientCtrl->>Property: find(property_id)
        Property-->>ClientCtrl: Property Exists

        ClientCtrl->>ClientCtrl: Generate Credentials
        Note right of ClientCtrl: api_key = Str::random(40)<br/>client_key = base64(Str::random(64))<br/>signature_secret = Str::random(64)

        ClientCtrl->>DB: INSERT client_registers
        Note right of DB: บันทึก: client_name, type,<br/>property_id, api_key, client_key,<br/>signature_secret, is_active=true
        DB-->>ClientCtrl: ClientRegister Model

        ClientCtrl->>DB: INSERT client_activity_logs
        Note right of DB: บันทึก: action=register,<br/>client_id, ip_address, user_agent

        ClientCtrl-->>API: { client, credentials }
        Note left of ClientCtrl: credentials แสดงครั้งเดียว<br/>signature_secret จะไม่แสดงอีก
        API-->>SuperAdmin: 201 Created + Credentials
    end
```

### รายละเอียดเพิ่มเติม

| ขั้นตอน | รายละเอียด                                                     |
| ------- | -------------------------------------------------------------- |
| 1       | Super Admin ส่งคำขอลงทะเบียน Client ใหม่                       |
| 2       | ตรวจสอบสิทธิ์ด้วย Basic Auth                                   |
| 3       | ตรวจสอบข้อมูลด้วย `ClientRegisterRequest` (validation rules)   |
| 4       | ตรวจสอบว่า Property ที่ระบุมีอยู่จริง                          |
| 5       | สร้าง credentials: `api_key`, `client_key`, `signature_secret` |
| 6       | บันทึกข้อมูล Client ลง `client_registers`                      |
| 7       | บันทึก Activity Log ลง `client_activity_logs`                  |
| 8       | ส่งคืนข้อมูล Client พร้อม credentials (แสดงครั้งเดียวเท่านั้น) |

---

## Flow 6: Property Management

```mermaid
sequenceDiagram
    autonumber
    actor SuperAdmin as Super Admin
    participant API as Laravel API
    participant Auth as BasicAuth Middleware
    participant PropCtrl as PropertyController
    participant PropPkgCtrl as PropertyPackageController
    participant DB as Database

    rect rgb(255, 250, 240)
        Note over SuperAdmin,DB: จัดการอสังหาริมทรัพย์และแพ็คเกจ

        %% Create Property
        SuperAdmin->>API: POST /v1/properties
        Note right of SuperAdmin: Body: property_no, name, is_active

        API->>Auth: basic.auth
        Auth-->>API: Authenticated

        API->>PropCtrl: store(request)
        PropCtrl->>DB: INSERT properties
        Note right of DB: บันทึก: uuid, property_no, name,<br/>is_active=true
        DB-->>PropCtrl: Property Model

        PropCtrl->>DB: INSERT property_packages
        Note right of DB: Auto-create: property_id,<br/>client_package_id=1 (default)
        DB-->>PropCtrl: PropertyPackage

        PropCtrl-->>API: { property, propertyPackage }
        API-->>SuperAdmin: 201 Created

        %% Assign Package
        SuperAdmin->>API: PUT /v1/properties/{id}/package
        Note right of SuperAdmin: Body: client_package_id,<br/>settings, expires_at

        API->>Auth: basic.auth
        Auth-->>API: Authenticated

        API->>PropPkgCtrl: upsert(request, propertyId)
        PropPkgCtrl->>DB: SELECT properties WHERE id=?
        DB-->>PropPkgCtrl: Property Exists

        PropPkgCtrl->>DB: UPDATE/INSERT property_packages
        Note right of DB: Update: client_package_id,<br/>settings (JSON), expires_at
        DB-->>PropPkgCtrl: PropertyPackage

        PropPkgCtrl->>PropPkgCtrl: effectiveSettings()
        Note right of PropPkgCtrl: Merge: package.settings +<br/>property_package.settings override

        PropPkgCtrl-->>API: { propertyPackage, effective_settings }
        API-->>SuperAdmin: 200 OK

        %% View Property with Details
        SuperAdmin->>API: GET /v1/properties/{id}
        API->>PropCtrl: show(id)
        PropCtrl->>DB: SELECT property + package + clients
        DB-->>PropCtrl: Property with Relations
        PropCtrl-->>API: { property, effective_settings }
        API-->>SuperAdmin: 200 OK
    end
```

### รายละเอียดเพิ่มเติม

| ขั้นตอน | รายละเอียด                                                                |
| ------- | ------------------------------------------------------------------------- |
| 1       | Super Admin สร้าง Property ใหม่                                           |
| 2       | ตรวจสอบสิทธิ์ด้วย Basic Auth                                              |
| 3       | บันทึก Property ลง `properties` (auto-generate UUID)                      |
| 4       | **Auto-create** PropertyPackage ด้วย `client_package_id=1` (default)      |
| 5       | Super Admin กำหนด/อัปเดตแพ็คเกจให้ Property                               |
| 6       | `PropertyPackageController::upsert()` ใช้ `updateOrCreate()`              |
| 7       | `effectiveSettings()` รวม settings จากแพ็คเกจหลัก + override ของ property |
| 8       | ดูรายละเอียด Property พร้อมข้อมูลแพ็คเกจและ clients ที่ลงทะเบียน          |

---

## Flow 7: Customer Token Issuance

```mermaid
sequenceDiagram
    autonumber
    actor Customer as Customer App
    participant API as Laravel API
    participant Auth as BasicAuth Middleware
    participant TokenCtrl as CustomerTokenController
    participant ClientSvc as ClientFeatureService
    participant DB as Database

    rect rgb(245, 255, 250)
        Note over Customer,DB: ออก Token สำหรับลูกค้า (Frontend)

        Customer->>API: POST /v1/payment/customer-token
        Note right of Customer: Body: customer_id,<br/>customer_email, amount

        API->>Auth: verify.basicauth
        Auth-->>API: Authenticated (ClientRegister)

        API->>TokenCtrl: issue(request)
        TokenCtrl->>ClientSvc: validateClient(client)
        ClientSvc-->>TokenCtrl: Active & Valid

        TokenCtrl->>TokenCtrl: Generate JWT
        Note right of TokenCtrl: Payload: customer_id,<br/>client_id, amount, exp

        TokenCtrl->>DB: INSERT/UPDATE customer_tokens
        Note right of DB: บันทึก: token_hash, customer_id,<br/>expires_at, status=active
        DB-->>TokenCtrl: Token Record

        TokenCtrl-->>API: { token, expires_at }
        API-->>Customer: 200 OK + JWT Token
    end
```

### รายละเอียดเพิ่มเติม

| ขั้นตอน | รายละเอียด                                                            |
| ------- | --------------------------------------------------------------------- |
| 1       | Customer App (Frontend) ขอ Token เพื่อเรียก API ชำระเงิน              |
| 2       | ตรวจสอบสิทธิ์ Client ด้วย Basic Auth (ไม่บันทึก activity log)         |
| 3       | `CustomerTokenController::issue()` ตรวจสอบข้อมูลลูกค้า                |
| 4       | `ClientFeatureService::validateClient()` ตรวจสอบว่า Client ยัง active |
| 5       | สร้าง JWT Token ที่มีข้อมูล customer_id, client_id, amount, expiry    |
| 6       | บันทึก Token ลงฐานข้อมูล (เพื่อ revoke ได้ในอนาคต)                    |
| 7       | ส่ง JWT Token กลับให้ Customer App ใช้เรียก API ถัดไป                 |

---

## ตารางสรุป Endpoints

| Flow | Method | Endpoint                                 | Middleware                            | คำอธิบาย             |
| ---- | ------ | ---------------------------------------- | ------------------------------------- | -------------------- |
| 1    | POST   | `/v1/payment/intent`                     | `payment.auth`                        | สร้าง Payment Intent |
| 1    | POST   | `/v1/payment/intent/{uuid}/generate`     | `payment.auth`                        | สร้าง QR Code        |
| 2    | POST   | `/v1/payment/intent/{uuid}/upload/slip`  | `payment.auth`                        | อัปโหลดสลิป          |
| 3    | POST   | `/v1/reconcile/bank-transaction-uploads` | `verify.basicauth` + `client.feature` | อัปโหลดไฟล์ธนาคาร    |
| 4    | GET    | `/v1/reconcile/approvals/pending`        | `verify.basicauth`                    | ดูรายการรออนุมัติ    |
| 4    | POST   | `/v1/reconcile/approvals/{uuid}/approve` | `verify.basicauth`                    | อนุมัติธุรกรรม       |
| 4    | POST   | `/v1/reconcile/approvals/{uuid}/reject`  | `verify.basicauth`                    | ปฏิเสธธุรกรรม        |
| 5    | POST   | `/v1/client/register`                    | `basic.auth`                          | ลงทะเบียน Client     |
| 6    | POST   | `/v1/properties`                         | `basic.auth`                          | สร้าง Property       |
| 6    | PUT    | `/v1/properties/{id}/package`            | `basic.auth`                          | กำหนดแพ็คเกจ         |
| 7    | POST   | `/v1/payment/customer-token`             | `verify.basicauth`                    | ออก Token ลูกค้า     |

---

## โน้ต

- ทุก Flow ที่เกี่ยวข้องกับ `payment.auth` จะบันทึก `client_activity_logs` อัตโนมัติ
- การอัปโหลดไฟล์ธนาคารรองรับไฟล์ CSV, XLSX, XLS ขนาดสูงสุด 10MB
- QR Code สร้างตามมาตรฐาน PromptPay / Thai QR
- Slip Verification เป็น optional feature ควบคุมด้วย `ClientFeatureService`
