<?php
include 'db_connection.php';

header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (isset($_POST['postId'], $_POST['message'], $_POST['location'], $_POST['subject'], $_POST['dateTime'])) {
        $postId = $_POST['postId'];
        $message = $_POST['message'];
        $location = $_POST['location'];
        $subject = $_POST['subject'];
        $dateTime = $_POST['dateTime'];

        $sql = "UPDATE port_messages SET message = ?, location = ?, subject = ?, dateTime = ? WHERE id = ?";
        $stmt = $con->prepare($sql);

        if ($stmt) {
            $stmt->bind_param('ssssi', $message, $location, $subject, $dateTime, $postId);

            if ($stmt->execute()) {
                $response = ['status' => 'success', 'message' => 'Post updated successfully'];
            } else {
                $response = ['status' => 'error', 'message' => 'Failed to update post'];
            }

            $stmt->close();
        } else {
            $response = ['status' => 'error', 'message' => 'Failed to prepare statement'];
        }
    } else {
        $response = ['status' => 'error', 'message' => 'Missing required fields'];
    }
} else {
    $response = ['status' => 'error', 'message' => 'Invalid request method'];
}

echo json_encode($response);
$con->close();
?>
