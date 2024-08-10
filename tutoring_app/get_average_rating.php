<?php
require 'db_connection.php';

header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $tutor_id = $_GET['tutor_id'] ?? null;

    if ($tutor_id) {
        $query = "SELECT AVG(rating) as averageRating FROM reviews WHERE tutor_id = ?";
        $stmt = $con->prepare($query);
        $stmt->bind_param("i", $tutor_id);
        $stmt->execute();
        $result = $stmt->get_result();
        $averageRating = $result->fetch_assoc()['averageRating'];

        if ($averageRating !== null) {
            echo json_encode(['status' => 'success', 'average_rating' => round($averageRating, 1)]);
        } else {
            echo json_encode(['status' => 'success', 'average_rating' => 0]);
        }
        $stmt->close();
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Missing tutor ID']);
    }
} else {
    echo json_encode(['status' => 'error', 'message' => 'Invalid request method']);
}
?>
