<?php

require 'db_connection.php';

header('Content-Type: application/json');

// ตรวจสอบการเชื่อมต่อ
if ($con->connect_error) {
    die(json_encode(['status' => 'error', 'message' => 'Connection failed: ' . $con->connect_error]));
}

// Get notification_id from POST parameters
$notification_id = $_POST['notification_id'];

if (!$notification_id) {
    echo json_encode(['status' => 'error', 'message' => 'Missing required parameters']);
    exit();
}

// Update notification status
$query = "UPDATE notifications SET is_read = 1 WHERE id = ?";
$stmt = $con->prepare($query);
$stmt->bind_param('i', $notification_id);

if ($stmt->execute()) {
    echo json_encode(['status' => 'success', 'message' => 'Notification status updated']);
} else {
    echo json_encode(['status' => 'error', 'message' => 'Failed to update notification status']);
}

$stmt->close();
$con->close();
?>
