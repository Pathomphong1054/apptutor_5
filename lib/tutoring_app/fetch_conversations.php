<?php
require 'db_connection.php';

// Enable error reporting
error_reporting(E_ALL);
ini_set('display_errors', 1);

header('Content-Type: application/json');

$user = $_GET['user'] ?? '';

if (empty($user)) {
    echo json_encode(['status' => 'error', 'message' => 'User parameter is missing']);
    exit();
}

// Log incoming request for debugging
error_log("Fetching conversations for user: " . $user);

$query = "
    SELECT sender, recipient, message, timestamp 
    FROM messages 
    WHERE sender='$user' OR recipient='$user' 
    ORDER BY timestamp DESC";

$result = mysqli_query($con, $query);

if (!$result) {
    echo json_encode(['status' => 'error', 'message' => mysqli_error($con)]);
    exit();
}

$conversations = array();
$seen = array();
while ($row = mysqli_fetch_assoc($result)) {
    $conversation_with = $row['sender'] === $user ? $row['recipient'] : $row['sender'];
    
    if (in_array($conversation_with, $seen)) {
        continue;
    }
    
    $seen[] = $conversation_with;
    
    $recipient_query = "
        SELECT name, profile_images 
        FROM students WHERE name='$conversation_with' 
        UNION 
        SELECT name, profile_images 
        FROM tutors WHERE name='$conversation_with'";
    $recipient_result = mysqli_query($con, $recipient_query);
    $recipient_info = mysqli_fetch_assoc($recipient_result);

    $conversations[] = [
        'conversation_with' => $conversation_with,
        'last_message' => $row['message'] ?? '',
        'timestamp' => $row['timestamp'] ?? '',
        'recipient_image' => $recipient_info['profile_images'] ?? '',
        'recipient_username' => $recipient_info['name'] ?? ''
    ];
}

echo json_encode(['status' => 'success', 'conversations' => $conversations]);
?>
