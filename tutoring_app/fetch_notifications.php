<?php

require 'db_connection.php';

header('Content-Type: application/json');

// ตรวจสอบการเชื่อมต่อ
if ($con->connect_error) {
    die(json_encode(['status' => 'error', 'message' => 'Connection failed: ' . $con->connect_error]));
}

// Get username and role from GET parameters
$username = $_GET['username'];
$role = $_GET['role'];

if (!$username || !$role) {
    echo json_encode(['status' => 'error', 'message' => 'Missing required parameters']);
    exit();
}

// Fetch notifications from database
$query = "SELECT * FROM notifications WHERE recipient = ? AND role = ?";
$stmt = $con->prepare($query);
$stmt->bind_param('ss', $username, $role);

$stmt->execute();
$result = $stmt->get_result();

$notifications = [];

while ($row = $result->fetch_assoc()) {
    $notifications[] = $row;
}

echo json_encode($notifications);

$stmt->close();
$con->close();
?>
