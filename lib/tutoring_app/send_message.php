<?php
require 'db_connection.php';

// รับข้อมูลจาก request body
$data = json_decode(file_get_contents('php://input'), true);

$sender = $data['sender'] ?? '';
$recipient = $data['recipient'] ?? '';
$message = $data['message'] ?? '';
$latitude = $data['latitude'] ?? null;
$longitude = $data['longitude'] ?? null;
$session_id = $data['session_id'] ?? '';

if (empty($sender) || empty($recipient) || empty($message)) {
    echo json_encode(['status' => 'error', 'message' => 'Invalid input data']);
    exit();
}

// ตรวจสอบให้แน่ใจว่า latitude และ longitude ถูกบันทึกอย่างถูกต้อง
$query = "INSERT INTO messages (sender, recipient, message, latitude, longitude, session_id) VALUES (?, ?, ?, ?, ?, ?)";
$stmt = $con->prepare($query);
$stmt->bind_param('sssdss', $sender, $recipient, $message, $latitude, $longitude, $session_id);

if ($stmt->execute()) {
    echo json_encode(['status' => 'success']);
} else {
    echo json_encode(['status' => 'error', 'message' => 'Failed to send message']);
}

$stmt->close();
$con->close();
?>
