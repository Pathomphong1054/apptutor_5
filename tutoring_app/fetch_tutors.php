<?php
require 'db_connection.php';

if (!$con) {
    echo json_encode(['status' => 'error', 'message' => 'Connection error']);
    exit();
}

// คำสั่ง SQL ที่จะดึงค่า average_rating สำหรับแต่ละ tutor
$stmt = $con->prepare("
    SELECT tutors.name, tutors.category, tutors.subject, tutors.topic, tutors.email, tutors.address, tutors.profile_images, 
           IFNULL(AVG(reviews.rating), 0) as average_rating
    FROM tutors
    LEFT JOIN reviews ON tutors.name = reviews.tutor_name
    GROUP BY tutors.name, tutors.category, tutors.subject, tutors.topic, tutors.email, tutors.address, tutors.profile_images
");

$stmt->execute();
$result = $stmt->get_result();
$tutors = [];

while ($row = $result->fetch_assoc()) {
    $tutors[] = $row;
}

echo json_encode(['status' => 'success', 'tutors' => $tutors]);

$stmt->close();
$con->close();
?>
