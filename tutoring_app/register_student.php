<?php
require 'db_connection.php';

if (!$con) {
    echo json_encode(['status' => 'error', 'message' => 'Connection error']);
    exit();
}

$name = $_POST['name'];
$password = $_POST['password'];
$email = $_POST['email'];
$address = $_POST['address'];
$role = 'student'; // ตั้งค่า role เป็น 'student' โดยค่าเริ่มต้น
$encrypted_pwd = password_hash($password, PASSWORD_BCRYPT);
$latitude = $_POST['latitude'];
$longitude = $_POST['longitude'];

function handleFileUpload($file, $uploadDir, $allowedTypes) {
    $fileName = basename($file["name"]);
    $targetFilePath = $uploadDir . $fileName;
    $fileType = pathinfo($targetFilePath, PATHINFO_EXTENSION);
    
    if (in_array(strtolower($fileType), $allowedTypes)) {
        if (move_uploaded_file($file["tmp_name"], $targetFilePath)) {
            return $fileName;
        }
    }
    return false;
}

$uploadDir = "uploads/";
$allowedTypes = array('jpg', 'png', 'jpeg', 'gif');

$profileImage = isset($_FILES['profile_image']) ? handleFileUpload($_FILES['profile_image'], $uploadDir, $allowedTypes) : null;

$stmt = $con->prepare("SELECT * FROM students WHERE email = ?");
$stmt->bind_param("s", $email);
$stmt->execute();
$result = $stmt->get_result();
$count = $result->num_rows;

if ($count > 0) {
    echo json_encode(['status' => 'error', 'message' => 'Email already exists']);
} else {
<<<<<<< HEAD
    // เพิ่ม latitude และ longitude ลงในคำสั่ง SQL
=======
    // เปลี่ยน profile_images เป็น profile_image ให้ตรงกับฐานข้อมูล
>>>>>>> 9fa5d0ac85e32d56780a25b46c14008d25c8661b
    $stmt = $con->prepare("INSERT INTO students(name, password, email, address, profile_images, role, latitude, longitude) VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
    $stmt->bind_param("ssssssdd", $name, $encrypted_pwd, $email, $address, $profileImage, $role, $latitude, $longitude);
    if ($stmt->execute()) {
        echo json_encode(['status' => 'success', 'message' => 'Registration succeeded']);
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Registration failed']);
    }
}

$stmt->close();
$con->close();
?>
