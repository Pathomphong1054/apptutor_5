<?php
require 'db_connection.php';

$deleteQuery = "DELETE FROM port_messages WHERE created_at < NOW() - INTERVAL 7 DAY";

if (mysqli_query($con, $deleteQuery)) {
    echo json_encode(['status' => 'success', 'message' => 'Old posts deleted successfully']);
} else {
    echo json_encode(['status' => 'error', 'message' => 'Failed to delete old posts: ' . mysqli_error($con)]);
}

mysqli_close($con);
?>
