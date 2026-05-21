<?php
header("Content-Type: application/json; charset=utf-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

error_reporting(E_ERROR | E_PARSE);

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

include 'config.php';

$host       = $config['DB_HOST'];
$dbname     = $config['DB_DATABASE'];
$dbuser     = $config['DB_USERNAME'];
$dbpassword = $config['DB_PASSWORD'];

$link = mysqli_connect($host, $dbuser, $dbpassword, $dbname);

if (!$link) {
    echo json_encode([
        "status" => false,
        "message" => "Unable to connect to MySQL"
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

$link->set_charset("utf8mb4");

$input = json_decode(file_get_contents("php://input"), true);

$isAdd       = $input['isAdd']       ?? $_POST['isAdd']       ?? '';
$userName    = $input['username']    ?? $_POST['username']    ?? '';
$tokenId     = $input['idtoken']    ?? $_POST['idtoken']     ?? '';
$lineRser    = $input['line_rser']  ?? $_POST['line_rser']   ?? '';
$isLineOAuth = $input['is_line_oauth'] ?? $_POST['is_line_oauth'] ?? '0';
$password    = $input['password']   ?? $_POST['password']    ?? '';

if ($isAdd !== 'true') {
    echo json_encode([
        "status" => true,
        "message" => "Successfully connected"
    ], JSON_UNESCAPED_UNICODE);
    mysqli_close($link);
    exit;
}

$output = [];

// กรณี LINE OAuth Login (ไม่ต้องตรวจสอบ password)
if ($isLineOAuth === '1') {
    
    // ค้นหาด้วย username (LINE userId) โดยไม่ตรวจสอบ password
    $sql = "
        SELECT 
            c_regis.*,
            c_rental.payment_secret,
            JSON_UNQUOTE(JSON_EXTRACT(c_rental.payment_secret, '$.token')) AS pay_token,
            JSON_UNQUOTE(JSON_EXTRACT(c_rental.payment_secret, '$.base64_encoded')) AS pay_encoded64,
            JSON_UNQUOTE(JSON_EXTRACT(c_rental.payment_secret, '$.fid')) AS fid
        FROM c_regis
        LEFT JOIN c_rental 
            ON c_rental.ser = c_regis.rser
        WHERE c_regis.username = ?
    ";

    $stmt = mysqli_prepare($link, $sql);
    mysqli_stmt_bind_param($stmt, "s", $userName);
    
} 
// กรณี Web Auto Login ด้วย token (มี password จาก URL)
elseif ($tokenId !== '') {

    $sql = "
        SELECT 
            c_regis.*,
            c_rental.payment_secret,
            JSON_UNQUOTE(JSON_EXTRACT(c_rental.payment_secret, '$.token')) AS pay_token,
            JSON_UNQUOTE(JSON_EXTRACT(c_rental.payment_secret, '$.base64_encoded')) AS pay_encoded64,
            JSON_UNQUOTE(JSON_EXTRACT(c_rental.payment_secret, '$.fid')) AS fid
        FROM c_regis
        LEFT JOIN c_rental 
            ON c_rental.ser = c_regis.rser
        WHERE c_regis.userid = ?
          AND c_regis.rser = ?
    ";

    $stmt = mysqli_prepare($link, $sql);
    mysqli_stmt_bind_param($stmt, "ss", $tokenId, $lineRser);
}
// กรณี Normal Login (ต้องใส่ password)
else {

    $sql = "
        SELECT 
            c_regis.*,
            c_rental.payment_secret,
            JSON_UNQUOTE(JSON_EXTRACT(c_rental.payment_secret, '$.token')) AS pay_token,
            JSON_UNQUOTE(JSON_EXTRACT(c_rental.payment_secret, '$.base64_encoded')) AS pay_encoded64,
            JSON_UNQUOTE(JSON_EXTRACT(c_rental.payment_secret, '$.fid')) AS fid
        FROM c_regis
        LEFT JOIN c_rental 
            ON c_rental.ser = c_regis.rser
        WHERE c_regis.username = ?
    ";

    $stmt = mysqli_prepare($link, $sql);
    mysqli_stmt_bind_param($stmt, "s", $userName);
}

if (!$stmt) {
    echo json_encode([
        "status" => false,
        "message" => "Prepare statement failed"
    ], JSON_UNESCAPED_UNICODE);
    mysqli_close($link);
    exit;
}

mysqli_stmt_execute($stmt);
$result = mysqli_stmt_get_result($stmt);

while ($row = mysqli_fetch_assoc($result)) {
    
    // ตรวจสอบ password ถ้าไม่ใช่ LINE OAuth mode
    if ($isLineOAuth !== '1') {
        // ถ้ามี password ส่งมาและไม่ตรงกับในฐานข้อมูล
        if ($password !== '' && $password !== $row['passwd']) {
            continue; // ข้าม record นี้
        }
    }
    
    $output[] = $row;
}

// ถ้าไม่พบข้อมูลหลังจากตรวจสอบ password
if (empty($output) && $isLineOAuth !== '1') {
    echo json_encode([
        "status" => false,
        "message" => "Invalid username or password"
    ], JSON_UNESCAPED_UNICODE);
    mysqli_stmt_close($stmt);
    mysqli_close($link);
    exit;
}

echo json_encode([
    "status" => true,
    "data" => $output
], JSON_UNESCAPED_UNICODE);

mysqli_stmt_close($stmt);
mysqli_close($link);
?>