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
    SELECT sender_id, recipient_id, message, timestamp 
    FROM messages 
    WHERE sender_id='$user' OR recipient_id='$user' 
    ORDER BY timestamp DESC";

$result = mysqli_query($con, $query);

if (!$result) {
    echo json_encode(['status' => 'error', 'message' => mysqli_error($con)]);
    exit();
}

$conversations = array();
$seen = array();
while ($row = mysqli_fetch_assoc($result)) {
    $conversation_with = $row['sender_id'] == $user ? $row['recipient_id'] : $row['sender_id'];
    
    if (in_array($conversation_with, $seen)) {
        continue;
    }
    
    $seen[] = $conversation_with;
    
    // Fetch recipient information from students and tutors tables by ID
    $recipient_query = "
        SELECT id, name, profile_images 
        FROM students WHERE id='$conversation_with' 
        UNION 
        SELECT id, name, profile_images 
        FROM tutors WHERE id='$conversation_with'";
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
