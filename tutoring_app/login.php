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
        // ตรวจสอบ profile_image ว่ามีหรือไม่
        $profileImage = isset($row['profile_images']) ? $row['profile_images'] : null;

        // ส่งข้อมูลกลับไปใน JSON response
        echo json_encode([
            'status' => 'success', 
            'message' => 'Login successful', 
            'name' => $row['name'], 
            'role' => $row['role'],
            'profile_image' => $profileImage,  // ส่ง profile_image กลับไปด้วย
            'id' => $row['id'],  // ส่งค่า id ของติวเตอร์ไปด้วย (tutor_id)
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
