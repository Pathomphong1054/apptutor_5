<?php
require 'db_connection.php';

$data = json_decode(file_get_contents('php://input'), true);

$session_id = $data['session_id'] ?? '';
$response_status = $data['response_status'] ?? '';

if (empty($session_id) || empty($response_status)) {
    echo json_encode(['status' => 'error', 'message' => 'Invalid input data']);
    exit();
}

// ตรวจสอบว่า session_id เป็นตัวเลข
if (!is_numeric($session_id)) {
    echo json_encode(['status' => 'error', 'message' => 'Session ID must be a number']);
    exit();
}

// อัปเดต response_status ในฐานข้อมูล
$query = "UPDATE tutoring_sessions SET response_status = ? WHERE id = ?";
$stmt = $con->prepare($query);

if ($stmt === false) {
    echo json_encode(['status' => 'error', 'message' => 'Failed to prepare statement: ' . $con->error]);
    exit();
}

$stmt->bind_param('si', $response_status, $session_id);

if ($stmt->execute()) {
    echo json_encode(['status' => 'success']);
} else {
    echo json_encode(['status' => 'error', 'message' => 'Failed to update response status: ' . $stmt->error]);
}

$stmt->close();
$con->close();
?>
