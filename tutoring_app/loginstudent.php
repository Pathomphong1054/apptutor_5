<?php
require 'db_connection.php';  // เชื่อมต่อฐานข้อมูล

if (!$con) {
    echo json_encode(['status' => 'error', 'message' => 'Connection error']);
    exit();
}

$email = $_POST['email'];
$password = $_POST['password'];

<<<<<<< HEAD
=======
// ตรวจสอบข้อมูล email และ password
>>>>>>> 9fa5d0ac85e32d56780a25b46c14008d25c8661b
$stmt = $con->prepare("SELECT * FROM students WHERE email = ?");
$stmt->bind_param("s", $email);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows == 1) {
    $row = $result->fetch_assoc();

    // ตรวจสอบว่ารหัสผ่านถูกต้องหรือไม่
    if (password_verify($password, $row['password'])) {
        // กำหนด profile_image ให้ null หากไม่มีค่าในฐานข้อมูล
        $profileImage = isset($row['profile_image']) ? $row['profile_image'] : null;

        echo json_encode([
            'status' => 'success', 
            'message' => 'Login successful', 
            'name' => $row['name'], 
            'role' => 'student',
<<<<<<< HEAD
            'id' => $row['id'],  // ส่ง id
            'profile_image' => $row['profile_image'] ?? null // ส่ง profile_image ถ้ามี
=======
            'id' => $row['id'],  // ส่ง id ของผู้ใช้
            'profile_image' => $profileImage // ส่ง profile_image หรือ null
>>>>>>> 9fa5d0ac85e32d56780a25b46c14008d25c8661b
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
