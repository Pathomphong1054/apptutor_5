<?php
require 'db_connection.php';

header('Content-Type: application/json');

if (!$con) {
    echo json_encode(['status' => 'error', 'message' => 'Connection error']);
    exit();
}

// กรองค่าจาก GET เพื่อป้องกันปัญหาการโจมตี
$username = filter_input(INPUT_GET, 'username', FILTER_SANITIZE_STRING);
$role = filter_input(INPUT_GET, 'role', FILTER_SANITIZE_STRING);

if (!$username || !$role) {
    echo json_encode(['status' => 'error', 'message' => 'Invalid input']);
    exit();
}

// ตรวจสอบค่า role และเตรียมคำสั่ง SQL ตามบทบาทที่แตกต่างกัน
if ($role === 'Tutor') {
    $stmt = $con->prepare("SELECT * FROM tutors WHERE name = ?");
} elseif ($role === 'student') {
    $stmt = $con->prepare("SELECT * FROM students WHERE name = ?");
} else {
    echo json_encode(['status' => 'error', 'message' => 'Invalid role']);
    exit();
}

$stmt->bind_param("s", $username);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $profile = $result->fetch_assoc();

    // เตรียมข้อมูล JSON ตามโครงสร้างตาราง
    $response = [
        'status' => 'success',
        'name' => $profile['name'],
        'email' => $profile['email'],
        'address' => $profile['address'],
        'profile_image' => $profile['profile_images'],
    ];

    // เพิ่มข้อมูลเฉพาะ tutor ถ้า role เป็น Tutor
    if ($role === 'Tutor') {
        $response['category'] = $profile['category'];
        $response['subject'] = $profile['subject'];
        $response['topic'] = $profile['topic'];
    }

    echo json_encode($response);

} else {
    echo json_encode(['status' => 'error', 'message' => 'User not found']);
}

$stmt->close();
$con->close();
?>
