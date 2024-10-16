<?php
require 'db_connection.php';

header('Content-Type: application/json');

$sender_id = $_GET['sender_id'] ?? '';
$recipient_id = $_GET['recipient_id'] ?? '';
$session_id = $_GET['session_id'] ?? '';

if (empty($sender_id) || empty($recipient_id) || empty($session_id)) {
    echo json_encode(['status' => 'error', 'message' => 'Sender_id, recipient_id, or session ID parameter is missing']);
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
        'sender_id' => $row['sender_id'],
        'recipient_id' => $row['recipient_id'],
        'message' => $row['message'],
        'timestamp' => $row['timestamp'],
        'latitude' => !empty($row['latitude']) ? $row['latitude'] : null,  // ส่งค่า null ถ้าไม่มีค่า
        'longitude' => !empty($row['longitude']) ? $row['longitude'] : null, // ส่งค่า null ถ้าไม่มีค่า
        'session_id' => !empty($row['session_id']) ? $row['session_id'] : null, // ส่งค่า null ถ้าไม่มีค่า
        'image_url' => !empty($row['file_path']) ? $row['file_path'] : null  // ส่งค่า null ถ้าไม่มีค่า
    ];
}

echo json_encode(['status' => 'success', 'messages' => $messages]);

$stmt->close();
$con->close();
?>
