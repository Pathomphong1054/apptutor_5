<?php

require 'db_connection.php';

header('Content-Type: application/json');

// ตรวจสอบการเชื่อมต่อ
if ($con->connect_error) {
    die(json_encode(['status' => 'error', 'message' => 'Connection failed: ' . $con->connect_error]));
}

// รับค่าจาก Flutter
$input = json_decode(file_get_contents('php://input'), true);
$sender = $input['sender'] ?? null;
$recipient = $input['recipient'] ?? null;
$message = $input['message'] ?? null;
$role = $input['role'] ?? null;
$type = $input['type'] ?? null;

// ตรวจสอบว่ามีค่าที่จำเป็นทั้งหมดหรือไม่
if (!$sender || !$recipient || !$message || !$role || !$type) {
    echo json_encode(['status' => 'error', 'message' => 'Missing required fields']);
    exit();
}

// เพิ่มการแจ้งเตือนลงในฐานข้อมูล
$query = "INSERT INTO notifications (sender, recipient, message, role, type) VALUES (?, ?, ?, ?, ?)";
$stmt = $con->prepare($query);
$stmt->bind_param('sssss', $sender, $recipient, $message, $role, $type);

if ($stmt->execute()) {
    echo json_encode(['status' => 'success']);
} else {
    echo json_encode(['status' => 'error', 'message' => 'Failed to create notification']);
}

$stmt->close();
$con->close();

?>
