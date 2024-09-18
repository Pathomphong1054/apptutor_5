// accept_request.php
<?php
require 'db_connection.php';

$data = json_decode(file_get_contents('php://input'), true);

if (isset($data['notification_id'], $data['recipient'])) {
    $notification_id = $data['notification_id'];
    $recipient = $data['recipient'];

    // อัปเดตสถานะของการแจ้งเตือน
    $stmt = $con->prepare("UPDATE notifications SET is_read = 1 WHERE id = ? AND recipient = ?");
    $stmt->bind_param('is', $notification_id, $recipient);

    if ($stmt->execute()) {
        echo json_encode(['status' => 'success']);
    } else {
        echo json_encode(['status' => 'error', 'message' => $con->error]);
    }

    $stmt->close();
} else {
    echo json_encode(['status' => 'error', 'message' => 'Invalid input']);
}

$con->close();
?>
