<?php
require 'db_connection.php';

// Receive input data from request body
$data = json_decode(file_get_contents('php://input'), true);

$sender_id = $data['sender_id'] ?? '';
$recipient_id = $data['recipient_id'] ?? '';
$message = $data['message'] ?? '';
$latitude = $data['latitude'] ?? null;
$longitude = $data['longitude'] ?? null;
$session_id = $data['session_id'] ?? '';

if (empty($sender_id) || empty($recipient_id) || empty($message)) {
    echo json_encode(['status' => 'error', 'message' => 'Invalid input data']);
    exit();
}

// Validate latitude and longitude to ensure they are decimals or null
$latitude = is_numeric($latitude) ? (float)$latitude : null;
$longitude = is_numeric($longitude) ? (float)$longitude : null;

// Prepare SQL statement to prevent SQL injection
$query = "INSERT INTO messages (sender_id, recipient_id, message, latitude, longitude, session_id) 
          VALUES (?, ?, ?, ?, ?, ?)";

$stmt = $con->prepare($query);
if ($stmt === false) {
    echo json_encode(['status' => 'error', 'message' => 'Failed to prepare statement: ' . $con->error]);
    exit();
}

$stmt->bind_param('iissss', $sender_id, $recipient_id, $message, $latitude, $longitude, $session_id);

// Execute the SQL query
if ($stmt->execute()) {
    echo json_encode(['status' => 'success']);
} else {
    echo json_encode(['status' => 'error', 'message' => 'Failed to send message: ' . $stmt->error]);
}

$stmt->close();
$con->close();
?>
