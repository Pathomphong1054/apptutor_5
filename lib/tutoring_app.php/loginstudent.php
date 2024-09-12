<?php
require 'db_connection.php';

if (!$con) {
    echo json_encode(['status' => 'error', 'message' => 'Connection error']);
    exit();
}

$email = $_POST['email'];
$password = $_POST['password'];

$stmt = $con->prepare("SELECT * FROM students WHERE email = ?");
$stmt->bind_param("s", $email);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows == 1) {
    $row = $result->fetch_assoc();
    if (password_verify($password, $row['password'])) {
        echo json_encode([
            'status' => 'success', 
            'message' => 'Login successful', 
            'name' => $row['name'], 
            'role' => 'student',
            'id' => $row['id'],  // ส่ง id
            'profile_image' => $row['profile_image'] ?? null // ส่ง profile_image ถ้ามี
        ]);
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Incorrect password']);
    }
    
} else {
    echo json_encode(['status' => 'error', 'message' => 'Email not found']);
}

$stmt->close();
$con->close();
?>
