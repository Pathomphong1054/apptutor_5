<?php
require 'db_connection.php';

if ($con->connect_error) {
    die(json_encode(["status" => "error", "message" => "Connection failed: " . $con->connect_error]));
}

// รับข้อมูล JSON จาก client
$data = json_decode(file_get_contents('php://input'), true);

// พิมพ์ข้อมูลที่รับเข้ามาเพื่อตรวจสอบ
error_log(print_r($data, true));

// ตรวจสอบว่าข้อมูลครบถ้วน
if (isset($data['student_id'], $data['profileImageUrl'], $data['message'], $data['dateTime'], $data['location'], $data['subject'])) {
    $student_id = $data['student_id'];
    $profileImageUrl = $data['profileImageUrl'];
    $message = $data['message'];
    $dateTime = $data['dateTime'];
    $location = $data['location'];
    $subject = $data['subject'];
    $created_at = $date('Y-m-d H:i:s'); // วันที่และเวลาปัจจุบัน

    // เตรียมคำสั่ง SQL ด้วย prepared statement
    $stmt = $con->prepare("INSERT INTO port_messages (student_id, profileImageUrl, message, dateTime, location, subject) VALUES (?, ?, ?, ?, ?, ?)");
    
    // ตรวจสอบว่าเตรียมคำสั่งสำเร็จหรือไม่
    if ($stmt) {
        $stmt->bind_param("isssss", $student_id, $profileImageUrl, $message, $dateTime, $location, $subject);

        if ($stmt->execute()) {
            echo json_encode(["status" => "success"]);
        } else {
            echo json_encode(["status" => "error", "message" => $stmt->error]);
        }
        $stmt->close();
    } else {
        echo json_encode(["status" => "error", "message" => $con->error]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "Invalid input"]);
}

$con->close();
?>
