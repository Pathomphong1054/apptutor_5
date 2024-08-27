<?php
require 'db_connection.php';

header('Content-Type: application/json');

$input = json_decode(file_get_contents('php://input'), true);

$sender = $input['sender'] ?? '';
$recipient = $input['recipient'] ?? '';
$message = $input['message'] ?? '';
$session_id = $input['session_id'] ?? '';
$latitude = $input['location']['latitude'] ?? null;
$longitude = $input['location']['longitude'] ?? null;

if (empty($sender) || empty($recipient) || empty($message) || empty($session_id)) {
    echo json_encode(['status' => 'error', 'message' => 'Message, sender, recipient, and session ID cannot be empty']);
    exit();
}

$query = "INSERT INTO messages (sender, recipient, message, session_id, latitude, longitude) VALUES ('$sender', '$recipient', '$message', '$session_id', '$latitude', '$longitude')";

if (mysqli_query($con, $query)) {
    echo json_encode(['status' => 'success']);
} else {
    echo json_encode(['status' => 'error', 'message' => mysqli_error($con)]);
}
?>
