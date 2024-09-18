<?php
require 'db_connection.php';
header('Content-Type: application/json');

if (!isset($con)) {
    die(json_encode(array("status" => "error", "message" => "Database connection is not set")));
}

if ($con->connect_error) {
    die(json_encode(array("status" => "error", "message" => "Database connection failed: " . $con->connect_error)));
}

$recipient = $_GET['recipient'];
$user = $_GET['user'];

if (empty($recipient) || empty($user)) {
    echo json_encode(array("status" => "error", "message" => "Recipient and user parameters are required"));
    exit;
}

// Fetch session ID where the user is either a student or tutor
$query = $con->prepare("SELECT id FROM tutoring_sessions WHERE (student = ? AND tutor = ?) OR (student = ? AND tutor = ?)");
if ($query === false) {
    die(json_encode(array("status" => "error", "message" => "Failed to prepare query: " . $con->error)));
}

$query->bind_param("ssss", $user, $recipient, $recipient, $user);
$query->execute();
$query->store_result();
$query->bind_result($session_id);

if ($query->num_rows > 0) {
    $query->fetch();
    echo json_encode(array("status" => "success", "session_id" => $session_id));
} else {
    // If session not found, create a new one
    $insert_query = $con->prepare("INSERT INTO tutoring_sessions (student, tutor) VALUES (?, ?)");
    if ($insert_query === false) {
        die(json_encode(array("status" => "error", "message" => "Failed to prepare insert query: " . $con->error)));
    }
    
    $insert_query->bind_param("ss", $user, $recipient);
    if ($insert_query->execute()) {
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
