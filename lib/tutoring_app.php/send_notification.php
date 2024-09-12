<?php
require 'db_connection.php';

header('Content-Type: application/json');

$input = json_decode(file_get_contents('php://input'), true);

$sender = $input['sender'] ?? '';
$recipient = $input['recipient'] ?? '';
$message = $input['message'] ?? '';

if (empty($sender) || empty($recipient) || empty($message)) {
    echo json_encode(['status' => 'error', 'message' => 'Invalid input']);
    exit();
}

// Logic to send notification
// Here you can add the logic to send the notification, for example, save it in the database
$query = "INSERT INTO notifications (sender, recipient, message) VALUES ('$sender', '$recipient', '$message')";

if (mysqli_query($con, $query)) {
    echo json_encode(['status' => 'success']);
} else {
    echo json_encode(['status' => 'error', 'message' => mysqli_error($con)]);
}
?>
