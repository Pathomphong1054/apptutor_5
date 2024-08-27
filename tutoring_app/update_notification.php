<?php
require 'db_connection.php'; // เชื่อมต่อกับฐานข้อมูล

header('Content-Type: application/json');

$notification_id = $_POST['notification_id'] ?? '';

if (empty($notification_id)) {
    echo json_encode(['status' => 'error', 'message' => 'Invalid notification ID']);
    exit();
}

$query = "UPDATE notifications SET is_read = 1 WHERE id = ?";
$stmt = $con->prepare($query);
$stmt->bind_param("i", $notification_id);
$stmt->execute();

if ($stmt->affected_rows > 0) {
    echo json_encode(['status' => 'success', 'message' => 'Notification updated']);
} else {
    echo json_encode(['status' => 'error', 'message' => 'Failed to update notification']);
}

$stmt->close();
$con->close();
?>
