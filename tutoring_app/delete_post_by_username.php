<?php
require 'db_connection.php';

header('Content-Type: application/json');

$data = json_decode(file_get_contents("php://input"), true);

$user_name = $data['user_name'] ?? '';

if (empty($user_name)) {
    echo json_encode(['status' => 'error', 'message' => 'User name is missing']);
    exit();
}

// ลบโพสต์ออกจากฐานข้อมูลตาม userName
$query = "DELETE FROM port_messages WHERE userName = ?";
$stmt = $con->prepare($query);
$stmt->bind_param("s", $user_name);

if ($stmt->execute()) {
    echo json_encode(['status' => 'success']);
} else {
    echo json_encode(['status' => 'error', 'message' => 'Failed to delete post']);
}

$stmt->close();
$con->close();
?>
