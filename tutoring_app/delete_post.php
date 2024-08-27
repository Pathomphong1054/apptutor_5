<?php
require 'db_connection.php';

header('Content-Type: application/json');

$data = json_decode(file_get_contents("php://input"), true);

$sender = $data['sender'] ?? '';

if (empty($sender)) {
    echo json_encode(['status' => 'error', 'message' => 'Sender is missing']);
    exit();
}

// ลบโพสต์จากฐานข้อมูล
$query = "DELETE FROM port_messages WHERE userName = ?";
$stmt = $con->prepare($query);
$stmt->bind_param("s", $sender);

if ($stmt->execute()) {
    echo json_encode(['status' => 'success']);
} else {
    echo json_encode(['status' => 'error', 'message' => 'Failed to delete post']);
}

$stmt->close();
$con->close();
?>
