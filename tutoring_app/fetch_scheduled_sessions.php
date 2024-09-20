<?php
require 'db_connection.php';
header('Content-Type: application/json');

$tutor = $_GET['tutor'];

if (empty($tutor)) {
    echo json_encode(array("status" => "error", "message" => "Tutor parameter is required"));
    exit;
}

// Query for tutoring_sessions
$query1 = $con->prepare("SELECT * FROM tutoring_sessions WHERE tutor = ?");
$query1->bind_param("s", $tutor);
$query1->execute();
$result1 = $query1->get_result();

$sessions = array();
while ($row1 = $result1->fetch_assoc()) {
    $sessions[] = array_merge($row1, array("source" => "tutoring_sessions")); // Add source identifier
}

// Query for tutor_schedule
$query2 = $con->prepare("SELECT * FROM tutor_schedule WHERE tutor = ?");
$query2->bind_param("s", $tutor);
$query2->execute();
$result2 = $query2->get_result();

while ($row2 = $result2->fetch_assoc()) {
    $sessions[] = array_merge($row2, array("source" => "tutor_schedule")); // Add source identifier
}

echo json_encode(array("status" => "success", "sessions" => $sessions));

// Close queries and connection
$query1->close();
$query2->close();
$con->close();
?>
