<?php
require 'db_connection.php';

if (!$con) {
    echo json_encode(['status' => 'error', 'message' => 'Connection error']);
    exit();
}

<<<<<<< HEAD
$username = $_GET['username'];

$query = $con->prepare("SELECT * FROM port_messages WHERE userName = ?");
$query->bind_param("s", $username);
=======
// ตรวจสอบว่ามีการส่งค่า student_id มาหรือไม่
if (!isset($_GET['student_id'])) {
    echo json_encode(['status' => 'error', 'message' => 'Missing student ID']);
    exit();
}

$student_id = $_GET['student_id'];

// ตรวจสอบว่า student_id เป็นตัวเลขหรือไม่
if (!is_numeric($student_id)) {
    echo json_encode(['status' => 'error', 'message' => 'Invalid student ID']);
    exit();
}

$query = $con->prepare("
    SELECT port_messages.*, students.name AS userName 
    FROM port_messages 
    JOIN students ON port_messages.student_id = students.id 
    WHERE port_messages.student_id = ?
");
$query->bind_param("i", $student_id);
>>>>>>> 9fa5d0ac85e32d56780a25b46c14008d25c8661b
$query->execute();
$result = $query->get_result();

if ($result->num_rows > 0) {
    $posts = [];
    while ($row = $result->fetch_assoc()) {
        $posts[] = $row;
    }
    echo json_encode(['status' => 'success', 'posts' => $posts]);
} else {
    echo json_encode(['status' => 'error', 'message' => 'No posts found']);
}

<<<<<<< HEAD
=======

>>>>>>> 9fa5d0ac85e32d56780a25b46c14008d25c8661b
$query->close();
$con->close();
?>
