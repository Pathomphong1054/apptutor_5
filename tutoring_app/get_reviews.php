<?php
require 'db_connection.php';

// รับค่า tutor_id จาก request
$tutor_id = isset($_GET['tutor_id']) ? $_GET['tutor_id'] : null;

// ตรวจสอบค่า tutor_id ว่ามีการส่งมาหรือไม่
if (!$tutor_id) {
    echo json_encode(['status' => 'error', 'message' => 'tutor_id missing']);
    exit();
}

// เตรียม SQL และการทำงานกับฐานข้อมูล
$sql = "SELECT rating, comment FROM reviews WHERE tutor_id = ?";
$stmt = $con->prepare($sql);

// ตรวจสอบว่าค่า tutor_id เป็นจำนวนเต็มหรือไม่
if (!$stmt) {
    echo json_encode(['status' => 'error', 'message' => 'Failed to prepare statement']);
    exit();
}

$stmt->bind_param("i", $tutor_id);
$stmt->execute();
$result = $stmt->get_result();

$response = array();
$response['status'] = 'success';
$response['reviews'] = array();

// ตรวจสอบว่ามีรีวิวหรือไม่
if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $review = array();
        $review['rating'] = $row['rating'];
        $review['comment'] = $row['comment'];
        $response['reviews'][] = $review;
    }
} else {
    // ถ้าไม่มีรีวิวให้แสดงข้อความว่าไม่มีข้อมูล
    $response['message'] = 'No reviews found';
}

$stmt->close();
$con->close();

// ส่งผลลัพธ์ในรูปแบบ JSON
echo json_encode($response);
?>
