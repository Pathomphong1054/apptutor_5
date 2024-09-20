<?php
require 'db_connection.php';

header('Content-Type: application/json');

// รับข้อมูลจาก request body
$input = json_decode(file_get_contents('php://input'), true);
$sender_id = $input['sender_id'];      // เปลี่ยนจาก 'sender' เป็น 'sender_id'
$recipient_id = $input['recipient_id']; // เปลี่ยนจาก 'recipient' เป็น 'recipient_id'
$message = $input['message'];
$role = $input['role'];
$type = $input['type'];

// ใช้ชื่อคอลัมน์ที่ถูกต้องในตาราง notifications
$query = "INSERT INTO notifications (sender_id, recipient_id, message, role, type) VALUES (?, ?, ?, ?, ?)";
$stmt = $con->prepare($query);
$stmt->bind_param('sssss', $sender_id, $recipient_id, $message, $role, $type);

if ($stmt->execute()) {
    echo json_encode(['status' => 'success']);
} else {
    echo json_encode(['status' => 'error', 'message' => 'Failed to create notification']);
}

$stmt->close();
$con->close();
?>
