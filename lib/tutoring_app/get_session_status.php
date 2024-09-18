<?php
// get_session_status.php

include 'db_connection.php';

$session_id = $_GET['session_id'];

$sql = "SELECT status FROM tutoring_sessions WHERE id = '$session_id'";
$result = $conn->query($sql);

if ($result->num_rows > 0) {
    $row = $result->fetch_assoc();
    echo json_encode([
        'status' => 'success',
        'session_status' => $row['status']
    ]);
} else {
    echo json_encode([
        'status' => 'error',
        'message' => 'Session not found'
    ]);
}

$conn->close();
?>
