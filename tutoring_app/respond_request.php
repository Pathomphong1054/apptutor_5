<?php

require 'db_connection.php';  // เชื่อมต่อกับฐานข้อมูลของคุณ

header('Content-Type: application/json');

// ตรวจสอบการเชื่อมต่อฐานข้อมูล
if ($con->connect_error) {
    echo json_encode(['status' => 'error', 'message' => 'Connection failed: ' . $con->connect_error]);
    exit();
}

// ตรวจสอบว่ามีการส่งค่าพารามิเตอร์ที่จำเป็นเข้ามา
$input = file_get_contents('php://input');
$data = json_decode($input, true);

$request_id = isset($data['request_id']) ? intval($data['request_id']) : null;
$is_accepted = isset($data['is_accepted']) ? intval($data['is_accepted']) : null;

if (is_null($request_id) || is_null($is_accepted)) {
    echo json_encode(['status' => 'error', 'message' => 'Missing required parameters']);
    exit();
}

// อัปเดตสถานะคำขอ
$query = "UPDATE requests SET is_accepted = ? WHERE id = ?";
$stmt = $con->prepare($query);

if ($stmt === false) {
    echo json_encode(['status' => 'error', 'message' => 'Failed to prepare statement: ' . $con->error]);
    exit();
}

$stmt->bind_param('ii', $is_accepted, $request_id);

if ($stmt->execute()) {
    // ตรวจสอบว่าการตอบรับคำขอเป็นการยอมรับหรือไม่
    if ($is_accepted == 1) {
        // ถ้ารับคำขอเรียบร้อย อาจสร้าง sessionId หรือจัดการเพิ่มเติม
        $sessionId = uniqid();  // ตัวอย่าง sessionId ที่สร้างขึ้นใหม่
        echo json_encode([
            'status' => 'success', 
            'message' => 'Request status updated', 
            'sessionId' => $sessionId
        ]);
    } else {
        echo json_encode([
            'status' => 'success', 
            'message' => 'Request status updated'
        ]);
    }
} else {
    echo json_encode([
        'status' => 'error', 
        'message' => 'Failed to update request status: ' . $stmt->error
    ]);
}

$stmt->close();
$con->close();
?>
