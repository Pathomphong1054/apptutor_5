<?php
// Include database connection
include 'db_connection.php';

// Enable error reporting for debugging
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// Get the session_id from the request
$data = json_decode(file_get_contents('php://input'), true);
$session_id = $data['session_id'] ?? null;

if ($session_id) {
    // Prepare the SQL statement
    $stmt = $con->prepare("DELETE FROM tutoring_sessions WHERE id = ?");
    
    // Check if the prepare() was successful
    if ($stmt === false) {
        echo json_encode([
            'status' => 'error',
            'message' => 'Failed to prepare statement: ' . $con->error
        ]);
        exit;
    }

    // Bind the parameter
    $stmt->bind_param('i', $session_id);

    // Execute the query
    if ($stmt->execute()) {
        echo json_encode([
            'status' => 'success',
            'message' => 'Session canceled successfully'
        ]);
    } else {
        echo json_encode([
            'status' => 'error',
            'message' => 'Failed to execute statement: ' . $stmt->error
        ]);
    }

    // Close the statement
    $stmt->close();
} else {
    echo json_encode([
        'status' => 'error',
        'message' => 'Invalid session ID'
    ]);
}

// Close the database connection
$con->close();
