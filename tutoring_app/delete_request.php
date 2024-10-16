<?php
require 'db_connection.php';

header('Content-Type: application/json');

// รับข้อมูล JSON ที่ส่งเข้ามา
$data = json_decode(file_get_contents("php://input"), true);

$request_id = $data['request_id'] ?? '';

// ตรวจสอบว่า request_id มีค่าถูกส่งมา
if (is_null($request_id) || is_null($is_accepted)) {
    echo json_encode(['status' => 'error', 'message' => 'Missing required parameters']);
    exit();
}

// อัปเดตสถานะคำขอ
$query = "UPDATE requests SET is_accepted = ? WHERE id = ?";
$stmt = $con->prepare($query);

if ($stmt === false) {
    echo json_encode(['status' => 'error', 'message' => 'Failed to prepare statement: ' . $con->error]);
    exit();
}

$stmt->bind_param('ii', $is_accepted, $request_id);

if ($stmt->execute()) {
    // ตรวจสอบว่า update สำเร็จหรือไม่
    if ($stmt->affected_rows > 0) {
        echo json_encode(['status' => 'success', 'message' => 'Request status updated']);
    } else {
        echo json_encode(['status' => 'error', 'message' => 'No rows updated. Invalid request ID.']);
    }
} else {
    echo json_encode(['status' => 'error', 'message' => 'Failed to update request status: ' . $stmt->error]);
}



$stmt->close();
$con->close();
?>
