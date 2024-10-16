<?php
require 'db_connection.php';

header('Content-Type: application/json');

// เตรียมคำสั่ง SQL สำหรับดึงข้อมูล
$query = "SELECT port_messages.*, students.name AS student_name, students.profile_images AS profileImageUrl 
          FROM port_messages
          JOIN students ON port_messages.student_id = students.id
          ORDER BY port_messages.created_at DESC"; 
 // แก้ไขเป็น created_at

$result = mysqli_query($con, $query);

if (!$result) {
    // แสดงข้อผิดพลาดหากคำสั่ง SQL ล้มเหลว
    echo json_encode(['status' => 'error', 'message' => mysqli_error($con)]);
    exit();
}

// เก็บผลลัพธ์ในรูปแบบ array
$messages = array();
while ($row = mysqli_fetch_assoc($result)) {
    $messages[] = $row;
}

// ส่งผลลัพธ์กลับในรูปแบบ JSON
echo json_encode(['status' => 'success', 'messages' => $messages]);

mysqli_close($con);
?>
