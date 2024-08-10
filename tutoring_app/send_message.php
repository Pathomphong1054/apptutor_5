<?php
require 'db_connection.php';

header('Content-Type: application/json');

$input = json_decode(file_get_contents('php://input'), true);

$sender = $input['sender'] ?? '';
$recipient = $input['recipient'] ?? '';
$message = $input['message'] ?? '';
$session_id = $input['session_id'] ?? '';

if (empty($sender) || empty($recipient) || empty($message) || empty($session_id)) {
    echo json_encode(['status' => 'error', 'message' => 'Message and session ID cannot be empty']);
    exit();
}

$query = "INSERT INTO messages (sender, recipient, message, session_id) VALUES ('$sender', '$recipient', '$message', '$session_id')";

if (mysqli_query($con, $query)) {
    echo json_encode(['status' => 'success']);
} else {
    echo json_encode(['status' => 'error', 'message' => mysqli_error($con)]);
}
?>
