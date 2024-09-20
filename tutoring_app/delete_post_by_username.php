<?php
require 'db_connection.php';

header('Content-Type: application/json');

$data = json_decode(file_get_contents("php://input"), true);

$student_id = $data['student_id'] ?? ''; // เปลี่ยนเป็น student_id

if (empty($student_id)) {
    echo json_encode(['status' => 'error', 'message' => 'Student ID is missing']);
    exit();
}

// ลบโพสต์ออกจากฐานข้อมูลตาม student_id
$query = "DELETE FROM port_messages WHERE student_id = ?";
$stmt = $con->prepare($query);
$stmt->bind_param("i", $student_id); // เปลี่ยนเป็น integer (i)

if ($stmt->execute()) {
    echo json_encode(['status' => 'success']);
} else {
    echo json_encode(['status' => 'error', 'message' => 'Failed to delete post']);
}

$stmt->close();
$con->close();
?>
