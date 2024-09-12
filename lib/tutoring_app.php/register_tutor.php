<?php
require 'db_connection.php';

if (!$con) {
    echo json_encode(['status' => 'error', 'message' => 'Connection error']);
    exit();
}

$name = $_POST['name'];
$password = $_POST['password'];
$email = $_POST['email'];
$category = $_POST['category'];
$subject = $_POST['subject'];
$topic = $_POST['topic'];
$address = $_POST['address'];
$bankName = $_POST['bank_name'];
$accountName = $_POST['account_name'];
$accountNumber = $_POST['account_number'];
$educationLevel = $_POST['education_level'];  // รับค่า education level
$role = 'Tutor';
$encrypted_pwd = password_hash($password, PASSWORD_BCRYPT);

function handleFileUpload($file, $uploadDir, $allowedTypes) {
    $fileName = basename($file["name"]);
    $targetFilePath = $uploadDir . $fileName;
    $fileType = pathinfo($targetFilePath, PATHINFO_EXTENSION);
    
    if (in_array($fileType, $allowedTypes)) {
        if (move_uploaded_file($file["tmp_name"], $targetFilePath)) {
            return $fileName;
        }
    }
    return false;
}

$uploadDir = "uploads/";
$allowedTypes = array('jpg', 'png', 'jpeg');

$profileImage = isset($_FILES['profile_image']) ? handleFileUpload($_FILES['profile_image'], $uploadDir, $allowedTypes) : null;
$resumeFile = isset($_FILES['resume']) ? handleFileUpload($_FILES['resume'], $uploadDir, $allowedTypes) : null;

$stmt = $con->prepare("SELECT * FROM tutors WHERE email = ?");
$stmt->bind_param("s", $email);
$stmt->execute();
$result = $stmt->get_result();
$count = $result->num_rows;

if ($count > 0) {
    echo json_encode(['status' => 'error', 'message' => 'Email already exists']);
} else {
    // เริ่ม transaction
    $con->begin_transaction();

    try {
        // Insert tutor data
        $stmt = $con->prepare("INSERT INTO tutors(name, password, email, category, subject, topic, address, profile_images, resumes_images, education_level, role) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
        $stmt->bind_param("sssssssssss", $name, $encrypted_pwd, $email, $category, $subject, $topic, $address, $profileImage, $resumeFile, $educationLevel, $role);

        if ($stmt->execute()) {
            $tutorId = $stmt->insert_id;

            // Insert bank account data
            $stmt = $con->prepare("INSERT INTO bank_accounts(tutor_id, bank_name, account_name, account_number) VALUES (?, ?, ?, ?)");
            $stmt->bind_param("isss", $tutorId, $bankName, $accountName, $accountNumber);

            if ($stmt->execute()) {
                // หากสำเร็จ, commit transaction
                $con->commit();
                echo json_encode(['status' => 'success', 'message' => 'Registration succeeded']);
            } else {
                // หากล้มเหลว, rollback transaction
                $con->rollback();
                echo json_encode(['status' => 'error', 'message' => 'Bank account registration failed']);
            }
        } else {
            // หากล้มเหลว, rollback transaction
            $con->rollback();
            echo json_encode(['status' => 'error', 'message' => 'Registration failed']);
        }
    } catch (Exception $e) {
        // ในกรณีที่เกิดข้อผิดพลาด, rollback transaction
        $con->rollback();
        echo json_encode(['status' => 'error', 'message' => 'Transaction failed: ' . $e->getMessage()]);
    }
}

$stmt->close();
$con->close();
?>
