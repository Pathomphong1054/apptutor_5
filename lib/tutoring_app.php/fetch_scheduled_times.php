<?php
// เชื่อมต่อฐานข้อมูล
require 'db_connection.php'; 
header('Content-Type: application/json');

// ตรวจสอบว่ามีการส่งพารามิเตอร์ tutor และ date หรือไม่
if (!isset($_GET['tutor']) || empty($_GET['tutor']) || !isset($_GET['date']) || empty($_GET['date'])) {
    echo json_encode(array("status" => "error", "message" => "Tutor and date parameters are required"));
    exit;
}

// รับค่าชื่อติวเตอร์และวันที่จาก query string
$tutor = $_GET['tutor'];
$date = $_GET['date'];

// ดึงข้อมูลการจองในวันนั้น ๆ สำหรับติวเตอร์
$query = $con->prepare("SELECT start_time, end_time FROM tutoring_sessions WHERE tutor = ? AND date = ? AND status = 'pending'");
$query->bind_param("ss", $tutor, $date);
$query->execute();
$result = $query->get_result();

// เตรียม array เพื่อเก็บเวลาที่จองแล้ว
$sessions = array();

// ดึงข้อมูลจากฐานข้อมูลแล้วเก็บไว้ใน array
while ($row = $result->fetch_assoc()) {
    $sessions[] = array(
        'start_time' => $row['start_time'],
        'end_time' => $row['end_time']
    );
}

// ส่งข้อมูลกลับไปในรูปแบบ JSON
echo json_encode(array("status" => "success", "times" => $sessions));

// ปิดการเชื่อมต่อ
$query->close();
$con->close();
?>
