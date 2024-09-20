<?php
require 'db_connection.php';
header('Content-Type: application/json');

// ตรวจสอบการเชื่อมต่อฐานข้อมูล
if (!isset($con)) {
    die(json_encode(array("status" => "error", "message" => "Database connection is not set")));
}

if ($con->connect_error) {
    die(json_encode(array("status" => "error", "message" => "Database connection failed: " . $con->connect_error)));
}

// รับค่า recipient และ user
$recipient = $_GET['recipient'] ?? '';
$user = $_GET['user'] ?? '';

if (empty($recipient) || empty($user)) {
    echo json_encode(array("status" => "error", "message" => "Recipient and user parameters are required"));
    exit;
}

// ค้นหา session ที่มีผู้ใช้เป็น student หรือติวเตอร์
$query = $con->prepare("
    SELECT id 
    FROM tutoring_sessions 
    WHERE (student_id = ? AND tutor_id = ?) OR (student_id = ? AND tutor_id = ?)
");

if ($query === false) {
    die(json_encode(array("status" => "error", "message" => "Failed to prepare query: " . $con->error)));
}

// ผูกค่าพารามิเตอร์
$query->bind_param("iiii", $user, $recipient, $recipient, $user);
$query->execute();
$query->store_result();
$query->bind_result($session_id);

if ($query->num_rows > 0) {
    // ถ้าเจอ session ให้ส่งคืน session_id
    $query->fetch();
    echo json_encode(array("status" => "success", "session_id" => $session_id));
} else {
    // ถ้าไม่เจอ session ให้สร้างใหม่
    $insert_query = $con->prepare("INSERT INTO tutoring_sessions (student_id, tutor_id) VALUES (?, ?)");
    if ($insert_query === false) {
        die(json_encode(array("status" => "error", "message" => "Failed to prepare insert query: " . $con->error)));
    }
    
    // ผูกค่าพารามิเตอร์
    $insert_query->bind_param("ii", $user, $recipient);
    if ($insert_query->execute()) {
        // ส่งคืน session_id ที่สร้างใหม่
        $new_session_id = $insert_query->insert_id;
        echo json_encode(array("status" => "success", "session_id" => $new_session_id));
    } else {
        echo json_encode(array("status" => "error", "message" => "Failed to create new session: " . $con->error));
    }

    $insert_query->close();
}

$query->close();
$con->close();
?>
