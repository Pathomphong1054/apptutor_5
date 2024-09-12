<?php
require 'db_connection.php';

header('Content-Type: application/json');

$input = json_decode(file_get_contents('php://input'), true);
$sender = $input['sender'];
$recipient = $input['recipient'];
$message = $input['message'];
$role = $input['role'];
$type = $input['type'];

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
