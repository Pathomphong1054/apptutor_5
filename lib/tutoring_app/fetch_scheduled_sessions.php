<?php
require 'db_connection.php';
header('Content-Type: application/json');

$tutor = $_GET['tutor'];

if (empty($tutor)) {
    echo json_encode(array("status" => "error", "message" => "Tutor parameter is required"));
    exit;
}

$query = $con->prepare("SELECT * FROM tutoring_sessions WHERE tutor = ?");
$query->bind_param("s", $tutor);
$query->execute();
$result = $query->get_result();

$sessions = array();
while ($row = $result->fetch_assoc()) {
    $sessions[] = $row;
}

echo json_encode(array("status" => "success", "sessions" => $sessions));

$query->close();
$con->close();
?>
