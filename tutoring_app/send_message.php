<?php
require 'db_connection.php';

<<<<<<< HEAD
// รับข้อมูลจาก request body
$data = json_decode(file_get_contents('php://input'), true);

$sender = $data['sender'] ?? '';
$recipient = $data['recipient'] ?? '';
=======
// Receive input data from request body
$data = json_decode(file_get_contents('php://input'), true);

$sender_id = $data['sender_id'] ?? '';
$recipient_id = $data['recipient_id'] ?? '';
>>>>>>> 9fa5d0ac85e32d56780a25b46c14008d25c8661b
$message = $data['message'] ?? '';
$latitude = $data['latitude'] ?? null;
$longitude = $data['longitude'] ?? null;
$session_id = $data['session_id'] ?? '';

<<<<<<< HEAD
if (empty($sender) || empty($recipient) || empty($message)) {
=======
if (empty($sender_id) || empty($recipient_id) || empty($message)) {
>>>>>>> 9fa5d0ac85e32d56780a25b46c14008d25c8661b
    echo json_encode(['status' => 'error', 'message' => 'Invalid input data']);
    exit();
}

<<<<<<< HEAD
// ตรวจสอบให้แน่ใจว่า latitude และ longitude ถูกบันทึกอย่างถูกต้อง
$query = "INSERT INTO messages (sender, recipient, message, latitude, longitude, session_id) VALUES (?, ?, ?, ?, ?, ?)";
$stmt = $con->prepare($query);
$stmt->bind_param('sssdss', $sender, $recipient, $message, $latitude, $longitude, $session_id);

if ($stmt->execute()) {
    echo json_encode(['status' => 'success']);
} else {
    echo json_encode(['status' => 'error', 'message' => 'Failed to send message']);
=======
// Validate latitude and longitude to ensure they are decimals or null
$latitude = is_numeric($latitude) ? (float)$latitude : null;
$longitude = is_numeric($longitude) ? (float)$longitude : null;

// Prepare SQL statement to prevent SQL injection
$query = "INSERT INTO messages (sender_id, recipient_id, message, latitude, longitude, session_id) 
          VALUES (?, ?, ?, ?, ?, ?)";

$stmt = $con->prepare($query);
if ($stmt === false) {
    echo json_encode(['status' => 'error', 'message' => 'Failed to prepare statement: ' . $con->error]);
    exit();
}

$stmt->bind_param('iissss', $sender_id, $recipient_id, $message, $latitude, $longitude, $session_id);

// Execute the SQL query
if ($stmt->execute()) {
    echo json_encode(['status' => 'success']);
} else {
    echo json_encode(['status' => 'error', 'message' => 'Failed to send message: ' . $stmt->error]);
>>>>>>> 9fa5d0ac85e32d56780a25b46c14008d25c8661b
}

$stmt->close();
$con->close();
?>
