<?php
require 'db_connection.php';

$data = json_decode(file_get_contents('php://input'), true);

$session_id = $data['session_id'] ?? '';
$response_status = $data['response_status'] ?? '';

if (empty($session_id) || empty($response_status)) {
    echo json_encode(['status' => 'error', 'message' => 'Invalid input data']);
    exit();
}

// อัปเดต response_status ในฐานข้อมูล
$query = "UPDATE tutoring_sessions SET response_status = ? WHERE id = ?";
$stmt = $con->prepare($query);
$stmt->bind_param('si', $response_status, $session_id);

if ($stmt->execute()) {
    echo json_encode(['status' => 'success']);
} else {
    echo json_encode(['status' => 'error', 'message' => 'Failed to update response status']);
}

$stmt->close();
$con->close();
?>
