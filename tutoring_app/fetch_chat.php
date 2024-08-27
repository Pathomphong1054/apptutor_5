<?php
require 'db_connection.php';

header('Content-Type: application/json');

$sender = $_GET['sender'] ?? '';
$recipient = $_GET['recipient'] ?? '';

if (empty($sender) || empty($recipient)) {
    echo json_encode(['status' => 'error', 'message' => 'Sender or recipient parameter is missing']);
    exit();
}

$query = "SELECT * FROM messages 
          WHERE (sender='$sender' AND recipient='$recipient') 
          OR (sender='$recipient' AND recipient='$sender') 
          ORDER BY timestamp ASC";

$result = mysqli_query($con, $query);

if (!$result) {
    echo json_encode(['status' => 'error', 'message' => mysqli_error($con)]);
    exit();
}

$messages = array();
while ($row = mysqli_fetch_assoc($result)) {
    $messages[] = [
        'id' => $row['id'],
        'sender' => $row['sender'],
        'recipient' => $row['recipient'],
        'message' => $row['message'],
        'timestamp' => $row['timestamp'],
        'latitude' => $row['latitude'] ?? '',
        'longitude' => $row['longitude'] ?? '',
        'session_id' => $row['session_id'] ?? '',
        'image_url' => $row['file_path'] ?? ''  // Added file_path to response
    ];
}

echo json_encode(['status' => 'success', 'messages' => $messages]);
?>
