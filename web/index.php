<?php
// บังคับให้ browser ไม่ cache ไฟล์นี้เด็ดขาด
header('Cache-Control: no-cache, no-store, must-revalidate');
header('Pragma: no-cache');
header('Expires: 0');
header('Content-Type: text/html; charset=UTF-8');

// อ่านและส่ง index.html ปกติ
readfile(__DIR__ . '/index.html');
