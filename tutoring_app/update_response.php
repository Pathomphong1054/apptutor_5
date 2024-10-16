<?php
require 'db_connection.php';

$data = json_decode(file_get_contents('php://input'), true);

$session_id = $data['session_id'] ?? '';
$response_status = $data['response_status'] ?? '';

if (empty($session_id) || empty($response_status)) {
    echo json_encode(['status' => 'error', 'message' => 'Invalid input data']);
    exit();
}

<<<<<<< HEAD
// อัปเดต response_status ในฐานข้อมูล
$query = "UPDATE tutoring_sessions SET response_status = ? WHERE id = ?";
$stmt = $con->prepare($query);
=======
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

>>>>>>> 9fa5d0ac85e32d56780a25b46c14008d25c8661b
$stmt->bind_param('si', $response_status, $session_id);

if ($stmt->execute()) {
    echo json_encode(['status' => 'success']);
} else {
<<<<<<< HEAD
    echo json_encode(['status' => 'error', 'message' => 'Failed to update response status']);
=======
    echo json_encode(['status' => 'error', 'message' => 'Failed to update response status: ' . $stmt->error]);
>>>>>>> 9fa5d0ac85e32d56780a25b46c14008d25c8661b
}

$stmt->close();
$con->close();
?>
