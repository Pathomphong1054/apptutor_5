<?php
require 'db_connection.php';

header('Content-Type: application/json');

$sender = $_GET['sender'] ?? '';

// ตรวจสอบว่า sender ถูกส่งมาหรือไม่
if (empty($sender)) {
    echo json_encode(['status' => 'error', 'message' => 'Sender parameter is missing']);
    exit();
}

// แก้ไขชื่อคอลัมน์เป็น 'profile_images'
$query = "SELECT r.*, s.profile_images FROM requests r LEFT JOIN students s ON r.recipient = s.name WHERE r.sender = ?";
$stmt = $con->prepare($query);

if (!$stmt) {
    echo json_encode(['status' => 'error', 'message' => 'Prepare statement failed: ' . $con->error]);
    exit();
}

$stmt->bind_param('s', $sender);
$stmt->execute();
$result = $stmt->get_result();

// ตรวจสอบผลลัพธ์การ query
error_log("Sender received: " . $sender);
error_log("Number of rows found: " . $result->num_rows);

$requests = array();
while ($row = $result->fetch_assoc()) {
    $requests[] = [
        'id' => $row['id'],
        'sender' => $row['sender'],
        'recipient' => $row['recipient'],
        'message' => $row['message'],
        'is_accepted' => $row['is_accepted'],
        'created_at' => $row['created_at'],
        // ใช้ 'profile_images' จากตาราง students
        'profile_image' => isset($row['profile_images']) ? $row['profile_images'] : null,
    ];
}

if (empty($requests)) {
    echo json_encode(['status' => 'error', 'message' => 'No requests found']);
} else {
    echo json_encode(['status' => 'success', 'requests' => $requests]);
}

$stmt->close();
$con->close();
?>
