<?php
header('Content-Type: application/json');

// เชื่อมต่อฐานข้อมูล
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "tutoring_app";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die(json_encode(['status' => 'error', 'message' => 'Database connection failed']));
}

// รับข้อมูลจาก POST request
$user = $_POST['user'];
$recipient = $_POST['recipient'];

if (empty($user) || empty($recipient)) {
    echo json_encode(['status' => 'error', 'message' => 'Invalid input']);
    $conn->close();
    exit();
}

// ลบแชททั้งหมดที่มี sender และ recipient ตรงกัน
$sql = "DELETE FROM messages WHERE (sender = '$user' AND recipient = '$recipient') OR (sender = '$recipient' AND recipient = '$user')";

if ($conn->query($sql) === TRUE) {
    echo json_encode(['status' => 'success', 'message' => 'Conversation deleted']);
} else {
    echo json_encode(['status' => 'error', 'message' => 'Failed to delete conversation']);
}

$conn->close();
?>
