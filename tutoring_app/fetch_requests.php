<?php
require 'db_connection.php';

header('Content-Type: application/json');

// รับค่า recipient (ผู้รับคำขอ)
$recipient = $_GET['recipient_id'] ?? '';

if (empty($recipient)) {
    echo json_encode(['status' => 'error', 'message' => 'Recipient parameter is missing']);
    exit();
}

// แก้ไข Query: ทำการ JOIN กับตาราง students เท่านั้น
$query = "
SELECT requests.id, requests.sender_id, requests.recipient_id, requests.message, requests.created_at, students.profile_images as profile_image, students.name as sender_name, requests.is_accepted 
FROM requests 
JOIN students ON requests.sender_id = students.id 
WHERE requests.recipient_id = ?";

$stmt = $con->prepare($query);
if (!$stmt) {
    echo json_encode(['status' => 'error', 'message' => 'Prepare statement failed: ' . $con->error]);
    exit();
}

// ผูกค่าตัวแปร recipient_id (สมมติว่าเป็น ID)
$stmt->bind_param('i', $recipient);
$stmt->execute();
$result = $stmt->get_result();

$requests = array();
while ($row = $result->fetch_assoc()) {
    $requests[] = [
        'id' => $row['id'],
        'sender_name' => $row['sender_name'], // แสดงชื่อของผู้ส่ง
        'recipient_id' => $row['recipient_id'],
        'message' => $row['message'],
        'profile_image' => $row['profile_image'], // รูปภาพของผู้ส่ง
        'created_at' => $row['created_at'],
        'is_accepted' => $row['is_accepted'],
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
