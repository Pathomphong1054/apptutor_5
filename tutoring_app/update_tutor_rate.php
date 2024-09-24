<?php
header('Content-Type: application/json');

// เชื่อมต่อฐานข้อมูล
require 'db_connection.php';

// ตรวจสอบการเชื่อมต่อฐานข้อมูล
if ($con->connect_error) {
    die(json_encode(['status' => 'error', 'message' => 'Connection failed: ' . $con->connect_error]));
}

// รับข้อมูลจาก Request ที่ส่งมา
$data = json_decode(file_get_contents('php://input'), true);
$tutor_name = $data['tutor_name'];
$hourly_rate = $data['hourly_rate'];
$level = $data['level'];

// ตรวจสอบข้อมูลที่จำเป็นต้องมี
if (!$tutor_name || !$hourly_rate || !$level) {
    echo json_encode(['status' => 'error', 'message' => 'Missing required fields']);
    exit();
}

// อัปเดตอัตราค่าบริการของติวเตอร์ในฐานข้อมูล
$sql = "UPDATE tutors SET hourly_rate = ?, level = ? WHERE tutor_name = ?";
$stmt = $con->prepare($sql);

if ($stmt) {
    $stmt->bind_param("sss", $hourly_rate, $level, $tutor_name);
    $stmt->execute();
    
    if ($stmt->affected_rows > 0) {
        echo json_encode(['status' => 'success', 'message' => 'อัปเดตอัตราค่าบริการสำเร็จ']);
    } else {
        echo json_encode(['status' => 'error', 'message' => 'ไม่พบข้อมูลที่ต้องการอัปเดต']);
    }
    $stmt->close();
} else {
    echo json_encode(['status' => 'error', 'message' => 'SQL Error: ' . $con->error]);
}

$con->close();
?>
