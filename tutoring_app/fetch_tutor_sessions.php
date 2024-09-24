<?php
// เชื่อมต่อฐานข้อมูล
require 'db_connection.php'; 
header('Content-Type: application/json');

// ตรวจสอบว่ามีการส่งพารามิเตอร์ tutor หรือไม่
if (!isset($_GET['tutor']) || empty($_GET['tutor'])) {
    echo json_encode(array("status" => "error", "message" => "Tutor parameter is required"));
    exit;
}

// รับค่าชื่อติวเตอร์จาก query string
$tutor = $_GET['tutor'];

// เตรียม statement SQL เพื่อดึงข้อมูลเวลาที่นัดหมายสำหรับติวเตอร์นี้
$query = $con->prepare("SELECT * FROM tutoring_sessions WHERE tutor = ? AND status = 'pending'");
$query->bind_param("s", $tutor);
$query->execute();
$result = $query->get_result();

// เตรียม array เพื่อเก็บเวลาที่นัดหมายแล้ว
$sessions = array();

// ดึงข้อมูลจากฐานข้อมูลแล้วเก็บไว้ใน array
while ($row = $result->fetch_assoc()) {
    $sessions[] = array(
        'id' => $row['id'],
        'student' => $row['student'],
        'date' => $row['date'],
        'start_time' => $row['start_time'],
        'end_time' => $row['end_time'],
        'rate' => $row['rate'],
        'amount' => $row['amount']
    );
}

// ส่งข้อมูลกลับไปในรูปแบบ JSON
echo json_encode(array("status" => "success", "sessions" => $sessions));

// ปิดการเชื่อมต่อ
$query->close();
$con->close();
?>
