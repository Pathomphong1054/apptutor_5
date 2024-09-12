<?php
require 'db_connection.php';
header('Content-Type: application/json');

$tutor_id = $_GET['tutor_id'];

if (empty($tutor_id)) {
    echo json_encode(['status' => 'error', 'message' => 'Tutor ID is missing']);
    exit();
}

$query = "SELECT bank_name, account_number FROM bank_accounts WHERE tutor_id = ?";
$stmt = $con->prepare($query);
$stmt->bind_param("s", $tutor_id);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $row = $result->fetch_assoc();
    echo json_encode(['status' => 'success', 'bank_name' => $row['bank_name'], 'account_number' => $row['account_number']]);
} else {
    echo json_encode(['status' => 'error', 'message' => 'No account found']);
}

$stmt->close();
$con->close();
?>
