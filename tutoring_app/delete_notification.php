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
$notification_id = $_POST['notification_id'];

if (empty($notification_id)) {
    echo json_encode(['status' => 'error', 'message' => 'Invalid input']);
    $conn->close();
    exit();
}

// ลบการแจ้งเตือนจากฐานข้อมูล
$sql = "DELETE FROM notifications WHERE id = '$notification_id'";

if ($conn->query($sql) === TRUE) {
    echo json_encode(['status' => 'success', 'message' => 'Notification deleted']);
} else {
    echo json_encode(['status' => 'error', 'message' => 'Failed to delete notification']);
}

$conn->close();
?>
