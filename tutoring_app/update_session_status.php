<?php
require 'db_connection.php';

header('Content-Type: application/json');

$input = json_decode(file_get_contents('php://input'), true);

$session_id = $input['session_id'] ?? '';
$status = $input['status'] ?? '';

if (empty($session_id) || empty($status)) {
    echo json_encode(['status' => 'error', 'message' => 'Invalid input']);
    exit();
}

$query = "UPDATE tutoring_sessions SET status='$status' WHERE id='$session_id'";

if (mysqli_query($con, $query)) {
    echo json_encode(['status' => 'success']);
} else {
    echo json_encode(['status' => 'error', 'message' => mysqli_error($con)]);
}
?>
