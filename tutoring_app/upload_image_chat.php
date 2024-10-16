<?php
require 'db_connection.php';

header('Content-Type: application/json');

if (isset($_FILES['file']) && isset($_POST['sender']) && isset($_POST['recipient']) && isset($_POST['session_id'])) {
    $sender = $_POST['sender'];
    $recipient = $_POST['recipient'];
    $session_id = $_POST['session_id'];

    $targetDir = "uploads/";
    $fileName = basename($_FILES["file"]["name"]);
    $targetFilePath = $targetDir . $fileName;
    $fullUrl = "http://10.5.50.138/tutoring_app/$targetFilePath"; 

    if (move_uploaded_file($_FILES["file"]["tmp_name"], $targetFilePath)) {
        $query = "INSERT INTO messages (sender, recipient, message, session_id, file_path) VALUES ('$sender', '$recipient', '[Image]', '$session_id', '$fullUrl')";
        if (mysqli_query($con, $query)) {
            echo json_encode(['status' => 'success', 'file_path' => $fullUrl]);
        } else {
            echo json_encode(['status' => 'error', 'message' => mysqli_error($con)]);
        }
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Failed to upload image']);
    }
} else {
    echo json_encode(['status' => 'error', 'message' => 'Invalid input']);
}

?>
