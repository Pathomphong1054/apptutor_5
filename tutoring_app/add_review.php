<?php
require 'db_connection.php';
header('Content-Type: application/json');

// รับข้อมูล JSON จาก client
$data = json_decode(file_get_contents('php://input'), true);

// ตรวจสอบข้อมูลที่ได้รับ
if (isset($data['tutor_id'], $data['student_id'], $data['rating'], $data['comment'])) {
    $tutor_id = $data['tutor_id'];  // ตรวจสอบว่าได้ค่า tutor_id ถูกต้อง
    $student_id = $data['student_id'];  // ตรวจสอบว่าได้ค่า student_id ถูกต้อง
    $rating = $data['rating'];
    $comment = $data['comment'];

    // เตรียมคำสั่ง SQL เพื่อบันทึกลงฐานข้อมูล
    $stmt = $con->prepare("INSERT INTO reviews (tutor_id, student_id, rating, comment) VALUES (?, ?, ?, ?)");
    $stmt->bind_param("iiis", $tutor_id, $student_id, $rating, $comment);

    if ($stmt->execute()) {
        echo json_encode(['status' => 'success', 'message' => 'Review added successfully']);
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Failed to add review']);
    }

    $stmt->close();
} else {
    echo json_encode(['status' => 'error', 'message' => 'Invalid input']);
}

$con->close();
?>
