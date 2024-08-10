<?php
include 'config.php';

$username = $_GET['username'];

$sql = "SELECT address FROM students WHERE email='$username'";
$result = mysqli_query($conn, $sql);

if ($result && mysqli_num_rows($result) > 0) {
    $row = mysqli_fetch_assoc($result);
    echo json_encode(['status' => 'success', 'address' => $row['address']]);
} else {
    echo json_encode(['status' => 'error', 'message' => 'User not found']);
}

mysqli_close($conn);
?>
