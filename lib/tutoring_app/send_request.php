
<?php
require 'db_connection.php';

$data = json_decode(file_get_contents('php://input'), true);

if ($con->connect_error) {
    die("Connection failed: " . $con->connect_error);
}

$input = file_get_contents("php://input");
$data = json_decode($input, true);

$sender = $data['sender'];
$recipient = $data['recipient'];
$message = $data['message'];
$is_accepted = 0; // หรือค่าเริ่มต้นของคำขอ
$created_at = date('Y-m-d H:i:s'); // วันที่และเวลาปัจจุบัน

$sql = "INSERT INTO requests (sender, recipient, message, is_accepted, created_at) VALUES (?, ?, ?, ?, ?)";
$stmt = $con->prepare($sql);
$stmt->bind_param("sssds", $sender, $recipient, $message, $is_accepted, $created_at);

$response = [];

if ($stmt->execute()) {
    $response['status'] = 'success';
} else {
    $response['status'] = 'error';
    $response['message'] = 'Failed to send request';
}

echo json_encode($response);

$stmt->close();
$con->close();
?>
