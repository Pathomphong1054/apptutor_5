<?php
require 'db_connection.php';

header('Content-Type: application/json');

$targetDir = "uploads/";
$targetFile = $targetDir . basename($_FILES["file"]["name"]);
$response = [];

if (move_uploaded_file($_FILES["file"]["tmp_name"], $targetFile)) {
    $response = [
        'status' => 'success',
        'file_url' => 'http://10.5.50.82/tutoring_app/' . $targetFile
    ];
} else {
    $response = [
        'status' => 'error',
        'message' => 'Failed to upload file'
    ];
}

echo json_encode($response);
?>
