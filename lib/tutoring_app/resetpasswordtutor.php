<?php
require 'db_connection.php';

if (!$con) {
    echo json_encode(['status' => 'error', 'message' => 'Connection error']);
    exit();
}

$email = $_POST['email'];
$oldPassword = $_POST['old_password'];
$newPassword = $_POST['new_password'];

// Validate new password length
if (strlen($newPassword) < 8) {
    echo json_encode(['status' => 'error', 'message' => 'Password must be at least 8 characters long']);
    exit();
}

// Hash the new password
$encrypted_new_pwd = password_hash($newPassword, PASSWORD_BCRYPT);

// Prepare and execute a query to get user data
$stmt = $con->prepare("SELECT password FROM tutors WHERE email = ?");
$stmt->bind_param("s", $email);
$stmt->execute();
$result = $stmt->get_result();
$user = $result->fetch_assoc();

if ($user) {
    // Verify the old password
    if (password_verify($oldPassword, $user['password'])) {
        // Old password is correct; update to the new password
        $stmt = $con->prepare("UPDATE tutors SET password = ? WHERE email = ?");
        $stmt->bind_param("ss", $encrypted_new_pwd, $email);
        if ($stmt->execute()) {
            echo json_encode(['status' => 'success', 'message' => 'Password has been reset successfully']);
        } else {
            echo json_encode(['status' => 'error', 'message' => 'Password reset failed']);
        }
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Old password is incorrect']);
    }
} else {
    echo json_encode(['status' => 'error', 'message' => 'Invalid email']);
}

$stmt->close();
$con->close();
?>