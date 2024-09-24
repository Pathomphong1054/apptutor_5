<?php
require 'db_connection.php';

header('Content-Type: application/json');

$sender = $_GET['sender'] ?? '';
$recipient = $_GET['recipient'] ?? '';

if (empty($sender) || empty($recipient)) {
    echo json_encode(['status' => 'error', 'message' => 'Sender or recipient parameter is missing']);
    exit();
}

// ใช้ prepared statement เพื่อป้องกัน SQL Injection
$query = "SELECT * FROM messages 
          WHERE (sender = ? AND recipient = ?) 
          OR (sender = ? AND recipient = ?) 
          ORDER BY timestamp ASC";

$stmt = $con->prepare($query);
$stmt->bind_param('ssss', $sender, $recipient, $recipient, $sender);
$stmt->execute();

$result = $stmt->get_result();

if (!$result) {
    echo json_encode(['status' => 'error', 'message' => mysqli_error($con)]);
    exit();
}

$messages = array();
while ($row = $result->fetch_assoc()) {
    $messages[] = [
        'id' => $row['id'],
        'sender' => $row['sender'],
        'recipient' => $row['recipient'],
        'message' => $row['message'],
        'timestamp' => $row['timestamp'],
        'latitude' => !empty($row['latitude']) ? $row['latitude'] : null,  // ส่งค่า null ถ้าไม่มีค่า
        'longitude' => !empty($row['longitude']) ? $row['longitude'] : null, // ส่งค่า null ถ้าไม่มีค่า
        'session_id' => !empty($row['session_id']) ? $row['session_id'] : null, // ส่งค่า null ถ้าไม่มีค่า
        'image_url' => !empty($row['file_path']) ? $row['file_path'] : null  // ส่งค่า null ถ้าไม่มีค่า
    ];
}

echo json_encode(['status' => 'success', 'messages' => $messages]);
?>
