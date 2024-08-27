<?php
require 'db_connection.php';

header('Content-Type: application/json');

$sender = $_GET['sender'] ?? '';

if (empty($sender)) {
    echo json_encode(['status' => 'error', 'message' => 'Sender parameter is missing']);
    exit();
}

$query = "SELECT * FROM requests WHERE sender = '$sender' ORDER BY created_at ASC";

$result = mysqli_query($con, $query);

if (!$result) {
    echo json_encode(['status' => 'error', 'message' => mysqli_error($con)]);
    exit();
}

$requests = array();
while ($row = mysqli_fetch_assoc($result)) {
    $requests[] = [
        'id' => $row['id'],
        'sender' => $row['sender'],
        'recipient' => $row['recipient'],
        'message' => $row['message'],
        'is_accepted' => $row['is_accepted'],
        // 'profileImage' => $row['profileImage'], // ลบหรือแก้ไขให้สอดคล้องกับฟิลด์ที่มีจริงๆ
    ];
}

echo json_encode(['status' => 'success', 'requests' => $requests]);
?>
