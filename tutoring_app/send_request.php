<?php
require 'db_connection.php';

header('Content-Type: application/json');

// ตรวจสอบการเชื่อมต่อฐานข้อมูล
if ($con->connect_error) {
    die(json_encode(['status' => 'error', 'message' => 'Connection failed: ' . $con->connect_error]));
}

$input = file_get_contents("php://input");
$data = json_decode($input, true);

// ตรวจสอบว่าข้อมูลที่จำเป็นครบถ้วนหรือไม่
if (isset($data['sender_id'], $data['recipient_id'], $data['message'])) {
    $sender_id = $data['sender_id'];
    $recipient_id = $data['recipient_id'];
    $message = $data['message'];
    
    // ตรวจสอบว่า sender_id และ recipient_id เป็นตัวเลขหรือไม่
    if (!is_numeric($sender_id) || !is_numeric($recipient_id)) {
        $response['status'] = 'error';
        $response['message'] = 'Invalid sender or recipient ID';
        echo json_encode($response);
        exit();
    }

    $is_accepted = 0; // ค่าเริ่มต้นของคำขอ
    $created_at = date('Y-m-d H:i:s'); // วันที่และเวลาปัจจุบัน

    // เตรียมคำสั่ง SQL
    $sql = "INSERT INTO requests (sender_id, recipient_id, message, is_accepted, created_at) VALUES (?, ?, ?, ?, ?)";
    $stmt = $con->prepare($sql);

    // ตรวจสอบว่าเตรียมคำสั่งสำเร็จหรือไม่
    if ($stmt) {
        // ผูกค่าตัวแปรกับชนิดข้อมูลที่ถูกต้อง
        $stmt->bind_param("iisss", $sender_id, $recipient_id, $message, $is_accepted, $created_at); // แก้เป็น iisss

        // ตรวจสอบการทำงานของ execute()
        if ($stmt->execute()) {
            $response['status'] = 'success';
        } else {
            $response['status'] = 'error';
            $response['message'] = 'Failed to send request';
        }

        $stmt->close();
    } else {
        $response['status'] = 'error';
        $response['message'] = 'SQL statement preparation failed: ' . $con->error;
    }
} else {
    $response['status'] = 'error';
    $response['message'] = 'Missing required parameters';
}

// ส่งผลลัพธ์ในรูปแบบ JSON
echo json_encode($response);

$con->close();


?>
