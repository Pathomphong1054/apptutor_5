<?php
<<<<<<< HEAD
include 'db_connection.php'; // ตรวจสอบว่ามีการเชื่อมต่อฐานข้อมูลถูกต้อง

header('Content-Type: application/json'); // ระบุว่าเป็น JSON
=======
include 'db_connection.php'; // เชื่อมต่อฐานข้อมูล

header('Content-Type: application/json'); // ระบุว่าเป็น JSON response

$response = []; // สร้างตัวแปรสำหรับ response
>>>>>>> 9fa5d0ac85e32d56780a25b46c14008d25c8661b

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (isset($_POST['postId'])) {
        $postId = $_POST['postId'];

<<<<<<< HEAD
        // เตรียมคำสั่ง SQL สำหรับการลบ
        $sql = "DELETE FROM port_messages WHERE id = ?";
        $stmt = $con->prepare($sql);

        if ($stmt) {
            $stmt->bind_param('i', $postId);

            if ($stmt->execute()) {
                if ($stmt->affected_rows > 0) {
                    $response = ['status' => 'success', 'message' => 'Post deleted successfully'];
                } else {
                    $response = ['status' => 'error', 'message' => 'Post not found'];
                }
            } else {
                $response = ['status' => 'error', 'message' => 'Failed to delete post'];
            }

            $stmt->close();
        } else {
            $response = ['status' => 'error', 'message' => 'Failed to prepare statement'];
=======
        // ตรวจสอบว่า postId เป็นตัวเลขหรือไม่
        if (is_numeric($postId)) {
            // เตรียมคำสั่ง SQL สำหรับการลบ
            $sql = "DELETE FROM port_messages WHERE id = ?";
            $stmt = $con->prepare($sql);

            if ($stmt) {
                $stmt->bind_param('i', $postId);

                if ($stmt->execute()) {
                    if ($stmt->affected_rows > 0) {
                        $response = ['status' => 'success', 'message' => 'Post deleted successfully'];
                    } else {
                        $response = ['status' => 'error', 'message' => 'Post not found'];
                    }
                } else {
                    $response = ['status' => 'error', 'message' => 'Failed to execute delete'];
                }

                $stmt->close();
            } else {
                $response = ['status' => 'error', 'message' => 'Failed to prepare statement'];
            }
        } else {
            $response = ['status' => 'error', 'message' => 'Invalid postId'];
>>>>>>> 9fa5d0ac85e32d56780a25b46c14008d25c8661b
        }
    } else {
        $response = ['status' => 'error', 'message' => 'Post ID is required'];
    }
} else {
    $response = ['status' => 'error', 'message' => 'Invalid request method'];
}

<<<<<<< HEAD
echo json_encode($response); // ส่ง JSON กลับไป
=======
echo json_encode($response); // ส่ง JSON response กลับไป
>>>>>>> 9fa5d0ac85e32d56780a25b46c14008d25c8661b
$con->close(); // ปิดการเชื่อมต่อฐานข้อมูล
?>
