<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

require 'db_connection.php';

header('Content-Type: application/json');

// ตรวจสอบการเชื่อมต่อฐานข้อมูล
if (!$con) {
    echo json_encode(['status' => 'error', 'message' => 'Connection error']);
    exit();
}

// รับค่าจาก request
$username = $_POST['username'];
$new_name = $_POST['name'];
$category = $_POST['category'];
$subject = $_POST['subject'];
$topic = $_POST['topic'];
$email = $_POST['email'];
$address = $_POST['address'];
$latitude = $_POST['latitude'];
$longitude = $_POST['longitude'];

$profileImage = null;

// ตรวจสอบว่ามีการอัปโหลดไฟล์รูปภาพโปรไฟล์หรือไม่
if (!empty($_FILES['profile_images']['name'])) {
    $targetDir = "uploads/";
    $fileName = basename($_FILES['profile_images']['name']);
    $targetFilePath = $targetDir . $fileName;
    $fileType = pathinfo($targetFilePath, PATHINFO_EXTENSION);

    $allowTypes = array('jpg', 'png', 'jpeg', 'gif');
    if (in_array($fileType, $allowTypes)) {
        // ย้ายไฟล์ไปยังโฟลเดอร์ที่กำหนด
        if (move_uploaded_file($_FILES['profile_images']['tmp_name'], $targetFilePath)) {
            $profileImage = $fileName;
        } else {
            echo json_encode(['status' => 'error', 'message' => 'Failed to upload profile image']);
            exit();
        }
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Invalid file type']);
        exit();
    }
}

// ถ้ามีการอัปโหลดรูปภาพใหม่ จะอัปเดตรวมรูปภาพด้วย
if ($profileImage) {
    $stmt = $con->prepare("UPDATE tutors SET name=?, category=?, subject=?, topic=?, email=?, address=?, latitude=?, longitude=?, profile_images=? WHERE name=?");
    $stmt->bind_param("ssssssssss", $new_name, $category, $subject, $topic, $email, $address, $latitude, $longitude, $profileImage, $username);
} else {
    // ถ้าไม่มีการอัปโหลดรูปภาพใหม่ จะอัปเดตข้อมูลอื่น ๆ
    $stmt = $con->prepare("UPDATE tutors SET name=?, category=?, subject=?, topic=?, email=?, address=?, latitude=?, longitude=? WHERE name=?");
    $stmt->bind_param("sssssssss", $new_name, $category, $subject, $topic, $email, $address, $latitude, $longitude, $username);
}

// ตรวจสอบว่าการอัปเดตสำเร็จหรือไม่
if ($stmt->execute()) {
    echo json_encode(['status' => 'success', 'message' => 'Profile updated successfully', 'image_url' => $profileImage]);
} else {
    echo json_encode(['status' => 'error', 'message' => 'Failed to update profile']);
}

// ปิดการเชื่อมต่อฐานข้อมูล
$stmt->close();
$con->close();
?>
