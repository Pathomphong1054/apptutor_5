<?php
header('Content-Type: application/json');

// เชื่อมต่อฐานข้อมูล
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "final_tutoringapp";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die(json_encode(['status' => 'error', 'message' => 'Database connection failed']));
}

// รับข้อมูลจาก POST request
$user = $_POST['user'] ?? '';
$recipient = $_POST['recipient'] ?? '';

if (empty($user) || empty($recipient)) {
    echo json_encode(['status' => 'error', 'message' => 'Invalid input']);
    $conn->close();
    exit();
}

// ลบแชททั้งหมดที่มี sender_id และ recipient_id ตรงกัน
$sql = "DELETE FROM messages WHERE (sender_id = ? AND recipient_id = ?) OR (sender_id = ? AND recipient_id = ?)";
$stmt = $conn->prepare($sql);

if ($stmt === false) {
    echo json_encode(['status' => 'error', 'message' => 'Failed to prepare SQL statement']);
    $conn->close();
    exit();
}

// ผูกพารามิเตอร์เพื่อป้องกัน SQL Injection
$stmt->bind_param('iiii', $user, $recipient, $recipient, $user);

if ($stmt->execute()) {
    echo json_encode(['status' => 'success', 'message' => 'Conversation deleted']);
} else {
    echo json_encode(['status' => 'error', 'message' => 'Failed to delete conversation']);
}

$stmt->close();
$conn->close();
?>
