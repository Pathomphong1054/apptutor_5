<?php
// เชื่อมต่อฐานข้อมูล
require 'db_connection.php';

header('Content-Type: application/json');

// รับข้อมูล JSON ที่ถูกส่งมา
$input = json_decode(file_get_contents('php://input'), true);

// ตรวจสอบว่ามี 'id' ถูกส่งมาหรือไม่
if (!isset($input['id']) || empty($input['id'])) {
    echo json_encode(['status' => 'error', 'message' => 'Session ID is required']);
    exit();
}

$session_id = $input['id'];

// สร้าง query เพื่อทำการลบ session จากฐานข้อมูล
$query = "DELETE FROM tutoring_sessions WHERE id = ?";

$stmt = $con->prepare($query);
$stmt->bind_param('i', $session_id);  // 'i' หมายถึง integer

if ($stmt->execute()) {
    echo json_encode(['status' => 'success', 'message' => 'Session deleted successfully']);
} else {
    echo json_encode(['status' => 'error', 'message' => 'Failed to delete session']);
}

// ปิดการเชื่อมต่อ
$stmt->close();
$con->close();
?>
