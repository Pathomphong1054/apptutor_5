<?php
require 'db_connection.php';

header('Content-Type: application/json');

$input = json_decode(file_get_contents('php://input'), true);

$student = $input['student'] ?? '';
$tutor = $input['tutor'] ?? '';
$date = $input['date'] ?? '';
$startTime = $input['startTime'] ?? '';
$endTime = $input['endTime'] ?? '';
$rate = $input['rate'] ?? '';

if (empty($student) || empty($tutor) || empty($date) || empty($startTime) || empty($endTime) || empty($rate)) {
    echo json_encode(['status' => 'error', 'message' => 'Invalid input']);
    exit();
}

$query = "INSERT INTO tutoring_sessions (student, tutor, date, start_time, end_time, rate, status) 
          VALUES ('$student', '$tutor', '$date', '$startTime', '$endTime', '$rate', 'pending')";

if (mysqli_query($con, $query)) {
    $session_id = mysqli_insert_id($con); // Get the ID of the inserted row
    echo json_encode(['status' => 'success', 'session_id' => $session_id]);
} else {
    echo json_encode(['status' => 'error', 'message' => mysqli_error($con)]);
}
?>
