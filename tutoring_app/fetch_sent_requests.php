<?php
require 'db_connection.php';

header('Content-Type: application/json');

// ตรวจสอบการเชื่อมต่อฐานข้อมูล
if ($con->connect_error) {
    echo json_encode(['status' => 'error', 'message' => 'Database connection failed: ' . $con->connect_error]);
    exit();
}

$sender_id = $_GET['sender_id'] ?? '';

// ตรวจสอบว่า sender_id ถูกส่งมาหรือไม่
if (empty($sender_id)) {
    echo json_encode(['status' => 'error', 'message' => 'Sender ID parameter is missing']);
    exit();
}

// Query ข้อมูลโดย JOIN กับตาราง students
$query = "SELECT r.*, s.name AS student_name, s.profile_images AS profile_image 
          FROM requests r 
          LEFT JOIN students s ON r.recipient_id = s.id
          WHERE r.sender_id = ?";

$stmt = $con->prepare($query);

if (!$stmt) {
    echo json_encode(['status' => 'error', 'message' => 'Prepare statement failed: ' . $con->error]);
    exit();
}

$stmt->bind_param('i', $sender_id);
$stmt->execute();
$result = $stmt->get_result();

// ตรวจสอบผลลัพธ์การ query
$requests = array();
while ($row = $result->fetch_assoc()) {
    $requests[] = [
        'id' => $row['id'],
        'sender_id' => $row['sender_id'],
        'recipient_id' => $row['recipient_id'],
        'message' => $row['message'],
        'is_accepted' => $row['is_accepted'],
        'created_at' => $row['created_at'],
        'profile_image' => isset($row['profile_image']) ? $row['profile_image'] : null,
        'student_name' => isset($row['student_name']) ? $row['student_name'] : 'Unknown', // เพิ่มชื่อผู้รับ
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
