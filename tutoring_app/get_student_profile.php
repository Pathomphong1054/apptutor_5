<?php
require 'db_connection.php';

header('Content-Type: application/json');

if (!$con) {
    echo json_encode(['status' => 'error', 'message' => 'Connection error']);
    exit();
}

if (isset($_GET['username'])) {
    $username = $_GET['username'];
    $stmt = $con->prepare("SELECT name, email, address, role, profile_images FROM students WHERE name = ?");
    $stmt->bind_param("s", $username);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        $row = $result->fetch_assoc();
        echo json_encode([
            'status' => 'success',
            'name' => $row['name'],
            'email' => $row['email'],
            'address' => $row['address'],
            'role' => $row['role'],
            'profile_image' => $row['profile_images']
        ]);
    } else {
        echo json_encode(['status' => 'error', 'message' => 'User not found']);
    }

    $stmt->close();
} else {
    echo json_encode(['status' => 'error', 'message' => 'Username not provided']);
}

$con->close();
?>
