<?php
require 'db_connection.php';

header('Content-Type: application/json');

$query = "SELECT port_messages.*, students.profile_images AS profileImageUrl 
          FROM port_messages
          JOIN students ON port_messages.userName = students.name
          ORDER BY created_at DESC";

$result = mysqli_query($con, $query);

if (!$result) {
    echo json_encode(['status' => 'error', 'message' => mysqli_error($con)]);
    exit();
}

$messages = array();
while ($row = mysqli_fetch_assoc($result)) {
    $messages[] = $row;
}

echo json_encode(['status' => 'success', 'messages' => $messages]);
?>
