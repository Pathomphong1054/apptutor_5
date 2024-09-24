<?php
include 'db_connection.php';

if ($_SERVER['REQUEST_METHOD'] == 'GET') {
    $tutor_id = $_GET['tutor_id'];

    $query = "SELECT latitude, longitude FROM tutors WHERE id = ?";
    $stmt = $con->prepare($query);
    $stmt->bind_param('i', $tutor_id);
    $stmt->execute();
    $stmt->bind_result($latitude, $longitude);

    if ($stmt->fetch()) {
        echo json_encode(['status' => 'success', 'latitude' => $latitude, 'longitude' => $longitude]);
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Tutor not found']);
    }

    $stmt->close();
    $con->close();
} else {
    echo json_encode(['status' => 'error', 'message' => 'Invalid request method']);
}
?>
