<?php
require 'db_connection.php';

header('Content-Type: application/json');

<<<<<<< HEAD
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
=======
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
>>>>>>> 9fa5d0ac85e32d56780a25b46c14008d25c8661b
$stmt->execute();
$result = $stmt->get_result();

// ตรวจสอบผลลัพธ์การ query
<<<<<<< HEAD
error_log("Sender received: " . $sender);
error_log("Number of rows found: " . $result->num_rows);

=======
>>>>>>> 9fa5d0ac85e32d56780a25b46c14008d25c8661b
$requests = array();
while ($row = $result->fetch_assoc()) {
    $requests[] = [
        'id' => $row['id'],
        'sender_id' => $row['sender_id'],
        'recipient_id' => $row['recipient_id'],
        'message' => $row['message'],
        'is_accepted' => $row['is_accepted'],
        'created_at' => $row['created_at'],
<<<<<<< HEAD
        // ใช้ 'profile_images' จากตาราง students
        'profile_image' => isset($row['profile_images']) ? $row['profile_images'] : null,
    ];
}

=======
        'profile_image' => isset($row['profile_image']) ? $row['profile_image'] : null,
        'student_name' => isset($row['student_name']) ? $row['student_name'] : 'Unknown', // เพิ่มชื่อผู้รับ
    ];
}


>>>>>>> 9fa5d0ac85e32d56780a25b46c14008d25c8661b
if (empty($requests)) {
    echo json_encode(['status' => 'error', 'message' => 'No requests found']);
} else {
    echo json_encode(['status' => 'success', 'requests' => $requests]);
}

$stmt->close();
$con->close();
?>
