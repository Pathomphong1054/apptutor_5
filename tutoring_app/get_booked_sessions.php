<?php
// Enable error reporting
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Database connection
$servername = "localhost";
$username = "root"; // Replace with your DB username
$password = ""; // Replace with your DB password
$dbname = "tutoring_app"; // Replace with your DB name

$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Get tutor name from GET request
$tutor = isset($_GET['tutor']) ? $_GET['tutor'] : '';

if (empty($tutor)) {
    echo json_encode(['status' => 'error', 'message' => 'Tutor name is missing']);
    exit();
}

// SQL query to fetch the booked sessions for a tutor
$sql = "SELECT id as session_id, student, date, start_time, end_time, rate, amount 
        FROM tutoring_sessions 
        WHERE tutor = ? AND status = 'pending'";

$stmt = $conn->prepare($sql);
if ($stmt === false) {
    echo json_encode(['status' => 'error', 'message' => 'Failed to prepare statement']);
    exit();
}

$stmt->bind_param("s", $tutor);
$stmt->execute();
$result = $stmt->get_result();

$sessions = [];
while ($row = $result->fetch_assoc()) {
    $sessions[] = $row;
}

echo json_encode(['status' => 'success', 'sessions' => $sessions]);

$stmt->close();
$conn->close();
