# การส่งงาน / Contributing

แนวทางสำหรับผู้พัฒนาโปรเจกต์ Flutter นี้ อ่าน Issue และคำสั่งเฉพาะงานก่อนเริ่ม ตรวจไฟล์ `AGENTS.md` ที่เกี่ยวข้องเมื่อมี และรักษางานที่ผู้อื่นแก้ค้างไว้

## เตรียมเครื่อง / Setup

- ติดตั้ง Flutter ตามเวอร์ชันที่ระบุใน `.fvmrc` (ปัจจุบัน `3.10.5`) และตรวจเงื่อนไข Dart SDK ใน `pubspec.yaml` หากใช้ FVM ให้รัน `fvm install` แล้วตรวจด้วย `fvm flutter --version`
- รัน `fvm flutter pub get` จากโฟลเดอร์หลักเพื่อเตรียม dependencies หากเวอร์ชันใน `.fvmrc` ใช้งานร่วมกับ `pubspec.lock` หรือ dependencies ไม่ได้ ให้บันทึกข้อผิดพลาดและตกลงเวอร์ชันกับทีมก่อนเปลี่ยนไฟล์
- เปิด Web ด้วย `fvm flutter run -d chrome` เมื่อมีอุปกรณ์และ environment พร้อม ตรวจ environment และสิทธิ์ก่อนเชื่อมต่อ API ห้ามใส่ credentials ใน source code
- `.github/workflows/flutter.yml` ใน working tree กำหนดขั้นตอน CI สำหรับ PR และ push ไป `main`; การมีไฟล์นี้ไม่ได้ยืนยันว่า workflow เปิดใช้งานหรือ CI ผ่านแล้ว

## ก่อนเริ่ม / Before starting

- งานแต่ละชิ้นต้องมี GitHub Issue ระบุเป้าหมาย ขอบเขต เกณฑ์ยอมรับ และงานที่ต้องทำก่อน โดยสร้างหรือเชื่อม Issue ก่อนเปิด PR
- สำหรับฟีเจอร์หรือการย้าย workflow ให้บันทึกพฤติกรรมเดิม ข้อเสนอ และเกณฑ์ยอมรับใน Issue หรือเอกสารที่ทีมตกลงก่อนเปลี่ยนพฤติกรรม; เพิ่ม spec หรือ ADR เมื่อเหมาะสม
- ตรวจ flow, สิทธิ์, API และ UI เดิมก่อนตัดสินใจ ห้ามบันทึกรหัสผ่าน token ข้อมูลส่วนบุคคล หรือข้อมูลจริงจาก staging/production ใน repository, test และ logs
- รักษาโครงสร้างและ API contract ของส่วนที่แก้; งานใหม่ที่ตกลงใช้ MVVM ให้แยก View, ViewModel, Model และ Service ตามขอบเขตงาน โดยไม่บังคับย้ายโค้ดเดิมที่ไม่เกี่ยวข้อง

## โครงสร้าง MVVM สำหรับงานใหม่

ใช้โครงสร้างแบบ feature-based จากโปรเจกต์ `chiangMai-municipality` เป็นแนวทาง โดยปรับให้เข้ากับระบบเดิมของ repository นี้ ไม่คัดลอก configuration หรือ endpoint จากโปรเจกต์ตัวอย่าง

```text
lib/Account/Account_Invoce_pay/
  models/       ข้อมูลและการแปลงข้อมูลของ feature
  view/         หน้าจอและ widgets
  viewmodels/   state และการตอบสนองต่อผู้ใช้
  services/     ติดต่อ API และ storage
  repositories/ ประสานแหล่งข้อมูล เมื่อจำเป็น
```

โครงสร้างนี้เป็นแนวทางสำหรับงานใหม่ ไม่ได้หมายความว่าทุกโฟลเดอร์หรือการย้ายจาก `lib/Account/Account_Invoce_pay.dart` เสร็จแล้ว View แสดงผลและส่ง action ให้ ViewModel; ViewModel จัดการ state และเรียก service/repository; service ดูแลรายละเอียดการติดต่อภายนอก

ก่อนย้ายแต่ละส่วนให้ตรวจ flow เดิมและระบุสิ่งที่ต้องรักษา โดยเฉพาะ API, สิทธิ์, navigation, การเลือกรายการ และยอดรับชำระ งานย้ายโครงสร้างเพียงอย่างเดียวไม่ควรเปลี่ยนพฤติกรรมหรืออ้างว่าแก้ปัญหาเดิม เว้นแต่มีการแก้และทดสอบจริง

## Branch และ commit / Branches and commits

- แตก branch จาก default branch หรือ baseline ที่ตกลงและอัปเดตแล้ว ใช้ชื่อ `codex/issue-<number>-<subject>` สำหรับงานที่ agent สร้าง หรือชื่ออื่นที่ทีมตกลง หนึ่ง issue ต่อ branch และหนึ่งเรื่องต่อ PR
- ใช้ Conventional Commits พร้อม scope ตามความเหมาะสม เช่น `fix(auth): restore session (#25)` เลข issue ต้องเป็นเลข GitHub จริง ห้ามเดาหรือใช้เลข local แทน
- แยกปัญหานอกขอบเขตเป็น issue หรือ PR ใหม่ ตรวจ staged diff ทุกครั้ง และ commit เฉพาะเมื่อได้รับอนุญาตตามกฎโครงการ

## ป้องกัน PR ซ้อนและ Draft ค้าง / PR backlog discipline

- ตรวจ PR ที่เปิดอยู่ก่อนเริ่มงานใหม่ แตก branch จาก default branch ล่าสุดเป็นค่าเริ่มต้น ห้ามซ้อน branch หรือ PR เว้นแต่ผู้ใช้อนุมัติชัดเจน / Review open PRs first and branch from the current default branch; stack only with explicit user approval.
- เมื่อจำเป็นต้องซ้อน ให้ระบุ PR แม่ base ลำดับ merge blocker และวิธีทดสอบบนฐานจริงใน PR ทุกชั้น / For an approved stack, document its parent, base, integration order, blockers and verification against the actual base.
- ใช้ Draft เฉพาะเมื่อยังไม่พร้อมรีวิว พร้อมระบุ blocker และขั้นตอนถัดไป เมื่อพร้อมให้เปลี่ยนเป็น Ready for review โดยไม่ถือว่าอนุมัติ merge / Use Draft only while not reviewable, record the blocker and next action, and mark it ready promptly; review readiness is not merge approval.
- ห้ามปิด ลบ หรือ merge PR เพียงเพื่อลดจำนวนงานค้าง ตรวจ diff, CI และ tests บนฐานล่าสุดก่อน merge ทุกครั้ง / Never close, delete or merge work just to reduce the backlog; verify the exact diff, checks and tests on the current base.
- กฎเอกสารไม่ใช่ branch protection หรือ CI enforcement; ตรวจและขออนุมัติแยกก่อนเปลี่ยนการตั้งค่า GitHub / Documentation is not automated enforcement; inspect and obtain separate approval before changing GitHub settings.

## ตรวจสอบก่อนเปิด PR / Validation

รันคำสั่งที่เกี่ยวข้องและบันทึกผลจริง ไม่ถือว่า hook หรือ CI ทำงานแทนหากยังไม่ได้ตั้งค่า:

- `fvm flutter analyze --no-pub`
- `fvm flutter test --no-pub`
- `fvm flutter build web --no-pub --no-tree-shake-icons` สำหรับงานที่กระทบ Web build หรือก่อน release; เมนูใช้รหัสไอคอนจาก API จึงต้องเก็บ icon font ทั้งชุด ซึ่งอาจเพิ่มขนาด build
- รันทดสอบเฉพาะส่วนก่อน เช่น `fvm flutter test test/password_policy_test.dart` เมื่อแก้ policy ที่เกี่ยวข้อง แล้วจึงขยายขอบเขตตามความเสี่ยง
- สำหรับงาน Web auth หรือ browser storage ให้เพิ่มหรือรันทดสอบ browser ที่มีอยู่จริงในงานนั้น และบันทึกข้อจำกัดหากยังไม่มี; การทดสอบ fixture ไม่แทนการตรวจ environment จริง

ใช้ `fvm flutter pub get` ก่อนเมื่อ dependencies ยังไม่พร้อม ตรวจ format ของไฟล์ Dart ที่เปลี่ยน และบันทึกเหตุผลหากข้ามการตรวจใด ทดสอบ UI หลายขนาดและ staging ตามขอบเขตโดยไม่เปิดเผยข้อมูลจริง ห้ามปิด browser security เพื่อข้าม CORS

ใช้ `fvm dart format --output=none --set-exit-if-changed <ไฟล์.dart>` เพื่อตรวจ format โดยไม่เขียนไฟล์ และใช้ `fvm dart format <ไฟล์.dart>` เมื่อต้องการจัดรูปแบบ ตรวจ diff ก่อน format ไฟล์ขนาดใหญ่เพื่อไม่ให้กระทบงานที่ไม่เกี่ยวข้อง

สำหรับงานรับชำระ ให้ตรวจค่าจาก API และยอดก่อน/หลังส่วนลด, VAT และ WHT รวมถึงกรณี null และกรณีไม่มีรายการ อย่าสร้างหรือยืนยันธุรกรรมจริงเพื่อทดสอบโดยไม่ได้รับอนุญาต

## Pull request

- เมื่อได้รับอนุญาตให้ส่งงาน ให้ push feature branch แล้วเปิด PR ผ่าน GitHub โดยใช้ [PR template](.github/pull_request_template.md) เมื่อมี ชื่อและเนื้อหาควรสื่อสารให้ผู้รีวิวเข้าใจทั้งภาษาไทยและอังกฤษตามความเหมาะสม
- ใส่ `Closes #<issue_number>` เฉพาะ GitHub Issue จริงที่ PR นี้แก้ครบและควรปิดเมื่อ merge; หากยังไม่ครบให้ใช้ `Refs #<issue_number>` หรือลิงก์แทน อย่าใช้เลขสมมติ
- สรุปสิ่งที่เปลี่ยนและเหตุผล เชื่อม spec/ADR ระบุผลต่อ API และสิทธิ์ พร้อมภาพ UI ก่อน/หลังสำหรับขนาดที่ได้รับผลกระทบ หากไม่เกี่ยวข้องระบุ N/A
- Bug fix ต้องระบุวิธีเกิด หลักฐาน root cause วิธีแก้ และ regression test หากยังไม่ยืนยัน root cause ให้ระบุชัดเจน
- รายงานคำสั่งและผลที่รันจริง ข้อจำกัด ความเสี่ยง วิธี deploy/rollback หากเกี่ยวข้อง และสิ่งที่ยังไม่ได้ทำ ผู้เปิด PR รับผิดชอบงานที่ AI ช่วยเขียนเช่นเดียวกับงานที่เขียนเอง
- รอการ review และอนุมัติจากผู้ใช้หรือผู้มีสิทธิ์ก่อน merge ผ่าน GitHub PR ไม่ push หรือ merge โดยพลการ และอย่าอ้างว่ามีการ review หรือ CI ผ่านหากยังไม่มีหลักฐาน

## Test ที่ดี / Useful tests

Test ต้องตรวจพฤติกรรมและ regression ได้จริง ครอบคลุมกรณีผิดพลาดตามความเสี่ยง ไม่บันทึก secrets และไม่อ้างว่าผ่านเมื่อยังไม่ได้รัน
