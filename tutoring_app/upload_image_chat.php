<?php
require 'db_connection.php';

header('Content-Type: application/json');

if (isset($_FILES['file']) && isset($_POST['sender']) && isset($_POST['recipient']) && isset($_POST['session_id'])) {
    $sender = $_POST['sender'];
    $recipient = $_POST['recipient'];
    $session_id = $_POST['session_id'];

    $targetDir = "uploads/";
    $fileName = basename($_FILES["file"]["name"]);
<<<<<<< HEAD
    $targetFilePath = $targetDir . $fileName;
    $fullUrl = "http://10.5.50.138/tutoring_app/$targetFilePath"; 
=======
    $fileType = strtolower(pathinfo($fileName, PATHINFO_EXTENSION));

    // ตรวจสอบชนิดไฟล์
    $allowedTypes = ['jpg', 'jpeg', 'png', 'gif'];
    if (!in_array($fileType, $allowedTypes)) {
        echo json_encode(['status' => 'error', 'message' => 'Invalid file type']);
        exit();
    }

    // เพิ่มตัวระบุสุ่มในชื่อไฟล์เพื่อป้องกันไฟล์ชื่อซ้ำกัน
    $newFileName = uniqid() . '.' . $fileType;
    $targetFilePath = $targetDir . $newFileName;
    $fullUrl = "http://10.5.50.82/tutoring_app/$targetFilePath"; 
>>>>>>> 9fa5d0ac85e32d56780a25b46c14008d25c8661b

    if (move_uploaded_file($_FILES["file"]["tmp_name"], $targetFilePath)) {
        // ใช้ prepared statement เพื่อป้องกัน SQL injection
        $query = "INSERT INTO messages (sender_id, recipient_id, message, session_id, file_path) VALUES (?, ?, '[Image]', ?, ?)";
        $stmt = $con->prepare($query);
        $stmt->bind_param('ssss', $sender, $recipient, $session_id, $fullUrl);

        if ($stmt->execute()) {
            echo json_encode(['status' => 'success', 'file_path' => $fullUrl]);
        } else {
            echo json_encode(['status' => 'error', 'message' => $stmt->error]);
        }

        $stmt->close();
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Failed to upload image']);
    }
} else {
    echo json_encode(['status' => 'error', 'message' => 'Invalid input']);
}

$con->close();
?>
