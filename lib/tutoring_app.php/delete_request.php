<?php
require 'db_connection.php';

header('Content-Type: application/json');

$data = json_decode(file_get_contents("php://input"), true);

$request_id = $data['request_id'] ?? '';

if (empty($request_id)) {
    echo json_encode(['status' => 'error', 'message' => 'Request ID is missing']);
    exit();
}

// ลบคำขอจากฐานข้อมูล
$query = "DELETE FROM requests WHERE id = ?";
$stmt = $con->prepare($query);
$stmt->bind_param("i", $request_id);

if ($stmt->execute()) {
    echo json_encode(['status' => 'success']);
} else {
    echo json_encode(['status' => 'error', 'message' => 'Failed to delete request']);
}

$stmt->close();
$con->close();
?>
