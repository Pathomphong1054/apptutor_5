<?php
include 'db_connection.php';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $id = $_POST['id'];
    $role = $_POST['role']; // "student" หรือ "tutor"
    $latitude = $_POST['latitude'];
    $longitude = $_POST['longitude'];

    if ($role == 'student') {
        $query = "UPDATE students SET latitude = ?, longitude = ? WHERE id = ?";
    } elseif ($role == 'tutor') {
        $query = "UPDATE tutors SET latitude = ?, longitude = ? WHERE id = ?";
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Invalid role']);
        exit();
    }

    $stmt = $con->prepare($query);
    $stmt->bind_param('ddi', $latitude, $longitude, $id);

    if ($stmt->execute()) {
        echo json_encode(['status' => 'success']);
    } else {
        echo json_encode(['status' => 'error', 'message' => $stmt->error]);
    }

    $stmt->close();
    $con->close();
} else {
    echo json_encode(['status' => 'error', 'message' => 'Invalid request method']);
}
?>
