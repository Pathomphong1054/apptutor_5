<?php
require 'db_connection.php';

// ตรวจสอบว่ามีการส่ง request_id มาหรือไม่
if (isset($_POST['request_id'])) {
    $request_id = $_POST['request_id'];

    // ตรวจสอบการเชื่อมต่อกับฐานข้อมูล
    if (!$con) {
        echo json_encode([
            'status' => 'error',
            'message' => 'Connection error'
        ]);
        exit();
    }

    // เตรียมคำสั่ง SQL สำหรับลบคำขอ
    $stmt = $con->prepare("DELETE FROM requests WHERE id = ?");
    $stmt->bind_param("i", $request_id);

    if ($stmt->execute()) {
        echo json_encode([
            'status' => 'success',
            'message' => 'Request deleted successfully'
        ]);
    } else {
        echo json_encode([
            'status' => 'error',
            'message' => 'Failed to delete request'
        ]);
    }

    // ปิด statement และการเชื่อมต่อฐานข้อมูล
    $stmt->close();
    $con->close();
} else {
    echo json_encode([
        'status' => 'error',
        'message' => 'No request_id provided'
    ]);
}
?>
