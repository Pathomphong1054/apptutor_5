<?php
require 'db_connection.php';

if ($con->connect_error) {
    die("Connection failed: " . $con->connect_error);
}

// รับข้อมูล JSON จาก client
$data = json_decode(file_get_contents('php://input'), true);

// ตรวจสอบว่าข้อมูลครบถ้วน
if (isset($data['userName'], $data['profileImageUrl'], $data['message'], $data['dateTime'], $data['location'], $data['subject'])) {
    $userName = $data['userName'];
    $profileImageUrl = $data['profileImageUrl'];
    $message = $data['message'];
    $dateTime = $data['dateTime'];
    $location = $data['location'];
    $subject = $data['subject'];
    $created_at = $date('Y-m-d H:i:s'); // วันที่และเวลาปัจจุบัน

    // เตรียมคำสั่ง SQL
    $sql = "INSERT INTO port_messages (userName, profileImageUrl, message, dateTime, location, subject) 
            VALUES ('$userName', '$profileImageUrl', '$message', '$dateTime', '$location', '$subject')";

    if ($con->query($sql) === TRUE) {
        echo json_encode(["status" => "success"]);
    } else {
        echo json_encode(["status" => "error", "message" => $con->error]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "Invalid input"]);
}

$con->close();
?>
