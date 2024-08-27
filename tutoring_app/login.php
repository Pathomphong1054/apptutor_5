<?php
require 'db_connection.php';
header('Content-Type: application/json'); // Ensure JSON header is set

if (!$con) {
    echo json_encode(['status' => 'error', 'message' => 'Connection error']);
    exit();
}

$email = $_POST['email'];
$password = $_POST['password'];

$stmt = $con->prepare("SELECT * FROM tutors WHERE email = ?");
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
            'role' => $row['role'],
            'profile_image' => $row['profile_images'] ?? null, // Ensure you have this column
            'id' => $row['id'], // Ensure you have this column
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
