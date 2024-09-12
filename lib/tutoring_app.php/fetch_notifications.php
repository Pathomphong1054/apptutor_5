<?php
require 'db_connection.php'; // เชื่อมต่อกับฐานข้อมูล

header('Content-Type: application/json');

// ตรวจสอบว่ามีการส่งค่าพารามิเตอร์ที่จำเป็นเข้ามา
$username = $_GET['username'] ?? '';
$role = $_GET['role'] ?? '';

if (empty($username) || empty($role)) {
    echo json_encode(['status' => 'error', 'message' => 'Invalid parameters']);
    exit();
}

// ปรับคำสั่ง SQL โดยใช้เฉพาะคอลัมน์ที่มีในตาราง
$query = "SELECT id, sender, message, created_at, type, is_read 
          FROM notifications 
          WHERE recipient = ? 
          ORDER BY created_at DESC";

$stmt = $con->prepare($query);

if (!$stmt) {
    echo json_encode(['status' => 'error', 'message' => 'Failed to prepare statement: ' . $con->error]);
    exit();
}

$stmt->bind_param('s', $username);
$stmt->execute();
$result = $stmt->get_result();

$notifications = [];
while ($row = $result->fetch_assoc()) {
    $notifications[] = $row;
}

if (count($notifications) > 0) {
    echo json_encode(['status' => 'success', 'notifications' => $notifications]);
} else {
    echo json_encode(['status' => 'error', 'message' => 'No notifications found']);
}

$stmt->close();
$con->close();
?>
