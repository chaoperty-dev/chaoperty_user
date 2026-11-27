<?php
/**
 * ============================================================================
 *  api_intents_v3.php
 *  --------------------------------------------------------------------------
 *  รับไฟล์ (multipart หรือ base64) → แปลงเป็น PNG → ตั้งชื่อให้เรียบร้อย
 *  → บันทึกลง server → ตอบกลับชื่อไฟล์ + สกุลไฟล์ (JSON)
 *
 *  Flutter ฝั่ง client เรียกแบบ multipart:
 *      POST /api_intents_v3.php
 *      field: file (ไฟล์ที่จะอัปโหลด)
 *      field: Foder (โฟลเดอร์ลูกค้า เช่น "C001" จะถูกเก็บใน files/C001/slip/)
 *      field: name  (ชื่อไฟล์ที่ต้องการ ไม่ต้องใส่นามสกุล)
 *
 *  หรือส่งแบบ base64 (เหมือนของเดิม):
 *      POST /api_intents_v3.php
 *      field: image (base64)
 *      field: Foder (โฟลเดอร์)
 *      field: name  (ชื่อไฟล์)
 *      field: ex    (สกุลเดิม เช่น jpg/png — optional)
 *
 *  ตอบกลับ (JSON):
 *      {
 *        "success": true,
 *        "message": "Image uploaded successfully",
 *        "filename": "slip_xxx_C001_20260716_201234.png",
 *        "extension": "png",
 *        "size": 123456,
 *        "url": "/files/C001/slip/.../slip_xxx_C001_20260716_201234.png"
 *      }
 *
 *  ตั้งค่าก่อนใช้งาน:
 *    - php.ini : upload_max_filesize / post_max_size / memory_limit ต้องสูงพอ
 *    - chmod 755 ที่โฟลเดอร์หลัก
 * ============================================================================
 */

// บังคับใช้ upload limit สูง (กัน shared host ตั้งค่ามาน้อย)
@ini_set('memory_limit',         '2048M');
@ini_set('upload_max_filesize',  '2048M');
@ini_set('post_max_size',        '2048M');
@ini_set('max_input_time',       '3600');
@ini_set('max_execution_time',   '3600');
while (ob_get_level()) { ob_end_clean(); }

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, Accept, Origin');
header('Access-Control-Max-Age: 86400');

if (($_SERVER['REQUEST_METHOD'] ?? '') === 'OPTIONS') {
    http_response_code(200); exit;
}

// รับเฉพาะ POST
if (($_SERVER['REQUEST_METHOD'] ?? '') !== 'POST') {
    http_response_code(405);
    echo json_encode([
        'success' => false,
        'message' => 'Method not allowed (use POST)',
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

// ตรวจ GD
if (!extension_loaded('gd')) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'GD extension is required on server',
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

/* =====================================================================
 *  CONFIG
 * ===================================================================== */
$BASE_DIR     = __DIR__;                       // โฟลเดอร์หลักของไฟล์นี้
$UPLOAD_ROOT  = $BASE_DIR . '/files';           // โฟลเดอร์เก็บไฟล์ทั้งหมด
$URL_PREFIX   = '/files';                       // URL สำหรับเรียกดูไฟล์
$MAX_WIDTH    = 800;                            // resize ความกว้างเป็น 800px
$ALLOWED_EXT  = ['jpg','jpeg','png','gif','webp','bmp','heic'];

/* =====================================================================
 *  รับค่าจาก POST (รองรับทั้ง multipart/form-data และ application/x-www-form-urlencoded)
 * ===================================================================== */
$Foder = trim((string)($_POST['Foder'] ?? $_REQUEST['Foder'] ?? ''));
$name  = trim((string)($_POST['name']  ?? $_REQUEST['name']  ?? ''));
$extIn = strtolower(trim((string)($_POST['ex'] ?? $_REQUEST['ex'] ?? '')));

if ($Foder === '') {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Missing Foder (folder)']);
    exit;
}

// sanitize folder name กัน path traversal
$Foder = preg_replace('/[^A-Za-z0-9_\-\.]/', '_', $Foder);
if ($Foder === '' || $Foder === null) $Foder = 'unknown';

/* =====================================================================
 *  แยกแยะรูปแบบ input
 *  - แบบ A: multipart file  (field = "file")
 *  - แบบ B: base64 (field = "image")
 * ===================================================================== */
$tmpPath = null;
$origExt = $extIn;
$origName = $name;

if (isset($_FILES['file']) && is_array($_FILES['file']) && ($_FILES['file']['error'] ?? UPLOAD_ERR_NO_FILE) === UPLOAD_ERR_OK) {
    // ============ Multipart ============
    $tmpPath = $_FILES['file']['tmp_name'];
    if (!$origName) $origName = $_FILES['file']['name'] ?? 'upload';
    if (!$origExt)  $origExt  = strtolower(pathinfo($_FILES['file']['name'] ?? '', PATHINFO_EXTENSION));
} elseif (!empty($_POST['image']) || !empty($_REQUEST['image'])) {
    // ============ Base64 ============
    $imageB64 = (string)($_POST['image'] ?? $_REQUEST['image']);
    // ตัด prefix data:image/xxx;base64, ออก
    if (preg_match('#^data:image/\w+;base64,#i', $imageB64)) {
        $imageB64 = preg_replace('#^data:image/\w+;base64,#i', '', $imageB64);
    }
    $decoded = base64_decode($imageB64, true);
    if ($decoded === false || strlen($decoded) === 0) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'Invalid base64 image data']);
        exit;
    }
    if (!$origName) $origName = 'slip_' . date('Ymd_His');
    $tmpPath = tempnam(sys_get_temp_dir(), 'up_');
    if ($tmpPath === false || file_put_contents($tmpPath, $decoded) === false) {
        http_response_code(500);
        echo json_encode(['success' => false, 'message' => 'Cannot write temp file']);
        exit;
    }
    if (!$origExt) $origExt = $extIn ?: 'png';
} else {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'No file uploaded (send multipart field "file" or base64 field "image")']);
    exit;
}

/* =====================================================================
 *  เปิดรูปด้วย GD
 * ===================================================================== */
$im = @imagecreatefromstring(file_get_contents($tmpPath));
if ($im === false) {
    @unlink($tmpPath);
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Cannot decode image (unsupported format)']);
    exit;
}
$sw = imagesx($im); $sh = imagesy($im);
if ($sw <= 0 || $sh <= 0) {
    imagedestroy($im); @unlink($tmpPath);
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Invalid image dimensions']);
    exit;
}

/* =====================================================================
 *  resize เป็น width 800 (เหมือนของเดิม) — รักษาอัตราส่วน
 * ===================================================================== */
$newW = (int)$MAX_WIDTH;
$newH = (int)round($sh * ($newW / $sw));
if ($newH <= 0) $newH = 1;

$thumb = imagecreatetruecolor($newW, $newH);
$transparency = imagecolorallocatealpha($thumb, 255, 255, 255, 127);
imagefilledrectangle($thumb, 0, 0, $newW, $newH, $transparency);
imagecopyresampled($thumb, $im, 0, 0, 0, 0, $newW, $newH, $sw, $sh);
imagedestroy($im);

/* =====================================================================
 *  สร้าง path ปลายทาง
 *  โครงสร้าง: files/{Foder}/slip/
 *  (ตรงกับที่หน้าโชว์สลิปฝั่ง Flutter ดึงรูป: files/{Foder}/slip/{fileNameSlip})
 * ===================================================================== */
$targetDir = $UPLOAD_ROOT . '/' . $Foder . '/slip';
if (!is_dir($targetDir)) {
    @mkdir($targetDir, 0775, true);
}

/* =====================================================================
 *  ตั้งชื่อไฟล์ให้เรียบร้อย
 *  รูปแบบ: ถ้า client ส่ง name มา → ใช้ชื่อนั้นตรง ๆ (ไม่เติม timestamp)
 *  ถ้าไม่ส่ง name → slip_{Foder}_{timestamp}_{rand}.png
 * ===================================================================== */
if ($name === '') {
    $name = 'slip_' . $Foder;
}
// sanitize ชื่อไฟล์
$safeName = preg_replace('/[^A-Za-z0-9_\-]/', '_', pathinfo($name, PATHINFO_FILENAME));
if ($safeName === '') $safeName = 'slip_' . $Foder;

// ถ้าฝั่ง client ส่ง name มา (เช่น slip_00007_<unique>.png ที Flutter สร้างให้ unique แล้ว)
// ให้ใช้ชื่อนั้นตรง ๆ ไม่ต้องเติม timestamp/rand
// เพื่อให้ชื่อไฟล์ที่บันทึกตรงกับ fileNameSlip ที่ส่งต่อให้ API อื่น
// (กันปัญหา slip หาไม่เจอตอนโหลดรูปกลับมาแสดง)
if ($name !== '' && $name !== null) {
    $finalName = $safeName . '.png';
} else {
    $uniq      = date('Ymd_His') . '_' . substr(md5(uniqid('', true)), 0, 6);
    $finalName = $safeName . '_' . $uniq . '.png';
}
$fullPath   = $targetDir . '/' . $finalName;

/* =====================================================================
 *  บันทึกไฟล์เป็น PNG (quality สูงสุด)
 * ===================================================================== */
$ok = imagepng($thumb, $fullPath, 9);
imagedestroy($thumb);
@unlink($tmpPath);

if (!$ok) {
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Cannot save image to ' . $fullPath]);
    exit;
}

$fileSize = filesize($fullPath);
// $fullPath = /var/www/html/chao_api/files/pasikatest/slip/2026/07_2026/xxx.png
// ตัด BASE_DIR (/var/www/html/chao_api) ทิ้ง → เหลือ "/files/pasikatest/..." เรียบร้อย
// (ห้ามนำหน้าด้วย $URL_PREFIX อีก เพราะจะซ้ำเป็น /files/files/...)
$relUrl   = str_replace('\\', '/', str_replace($BASE_DIR, '', $fullPath));
$relUrl   = '/' . ltrim($relUrl, '/');
$publicUrl = $relUrl;

/* =====================================================================
 *  ตอบกลับ: ชื่อไฟล์ + สกุลไฟล์ (+ ข้อมูลอื่น ๆ เผื่อ Flutter ใช้)
 * ===================================================================== */
echo json_encode([
    'success'           => true,
    'message'           => 'Image uploaded successfully',
    'filename'          => $finalName,         // <-- ชื่อไฟล์ที่ Flutter ต้องการ
    'extension'         => 'png',              // <-- สกุลไฟล์ (ตามที่ Flutter ต้องการ)
    'size'              => (int)$fileSize,
    'width'             => $newW,
    'height'            => $newH,
    'original_filename' => $origName,
    'original_extension'=> $origExt,
    'folder'            => $Foder,
    'url'               => $publicUrl,
    'path'              => $fullPath,
], JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
exit;