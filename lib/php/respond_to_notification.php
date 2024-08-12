<?php
require 'db_connection.php'; // เชื่อมต่อกับฐานข้อมูล

header('Content-Type: application/json');

$request_id = $_POST['notification_id'] ?? '';
$is_accepted = $_POST['is_accepted'] ?? '';

if (empty($request_id) || !isset($is_accepted)) {
    echo json_encode(['status' => 'error', 'message' => 'Invalid parameters']);
    exit();
}

// อัปเดตสถานะของ request เป็นยอมรับหรือปฏิเสธ
$query = "UPDATE notifications SET is_read = 1, is_accepted = ? WHERE id = ?";
$stmt = $con->prepare($query);
$stmt->bind_param("ii", $is_accepted, $request_id);
$stmt->execute();

if ($stmt->affected_rows > 0) {
    echo json_encode(['status' => 'success', 'message' => 'Request has been responded']);
} else {
    echo json_encode(['status' => 'error', 'message' => 'Failed to respond to request']);
}

$stmt->close();
$con->close();
?>
