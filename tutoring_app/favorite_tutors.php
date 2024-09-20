<?php
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "final_tutoringapp";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// ตัวอย่างการใช้ $conn
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $student_id = $_POST['student_id'];
    $tutor_id = $_POST['tutor_id'];
    $action = $_POST['action'];

    if ($action === 'add') {
        $sql = "INSERT INTO favorite_tutors (student_id, tutor_id) VALUES ('$student_id', '$tutor_id')";
    } else if ($action === 'remove') {
        $sql = "DELETE FROM favorite_tutors WHERE student_id='$student_id' AND tutor_id='$tutor_id'";
    }

    if ($conn->query($sql) === TRUE) {
        echo json_encode(["status" => "success"]);
    } else {
        echo json_encode(["status" => "error", "message" => $conn->error]);
    }
}

$conn->close();
?>
