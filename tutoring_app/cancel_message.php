<?php
include 'db_connection.php'; // Include your database connection

// Enable error reporting for debugging
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// Read JSON input data
$data = json_decode(file_get_contents('php://input'), true);

// Log the input data for debugging
file_put_contents('cancel_message_log.txt', print_r($data, true), FILE_APPEND);

$sender = $data['sender'] ?? null;
$recipient = $data['recipient'] ?? null;
$message = $data['message'] ?? null;
$session_id = $data['session_id'] ?? null;

if ($sender && $recipient && $message && $session_id) {
    // Prepare the SQL statement to insert the message into the 'messages' table
    $stmt = $con->prepare("INSERT INTO messages (sender, recipient, message, session_id, timestamp) VALUES (?, ?, ?, ?, NOW())");

    if ($stmt) {
        // Bind the parameters and execute the query
        $stmt->bind_param('sssi', $sender, $recipient, $message, $session_id);

        if ($stmt->execute()) {
            echo json_encode([
                'status' => 'success',
                'message' => 'Message sent successfully'
            ]);
        } else {
            echo json_encode([
                'status' => 'error',
                'message' => 'Failed to send message: ' . $stmt->error
            ]);
        }

        $stmt->close(); // Close the prepared statement
    } else {
        echo json_encode([
            'status' => 'error',
            'message' => 'Failed to prepare statement: ' . $con->error
        ]);
    }
} else {
    echo json_encode([
        'status' => 'error',
        'message' => 'Invalid input data'
    ]);
}

$con->close(); // Close the database connection
?>
