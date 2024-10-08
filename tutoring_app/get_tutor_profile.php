<?php
require 'db_connection.php';

header('Content-Type: application/json');

if (!$con) {
    echo json_encode(['status' => 'error', 'message' => 'Connection error']);
    exit();
}

if (isset($_GET['username'])) {
    $username = $_GET['username'];
    $stmt = $con->prepare("SELECT name, education_level, category, subject, topic, email, address, profile_images, resumes_images, latitude, longitude FROM tutors WHERE name = ?");
    $stmt->bind_param("s", $username);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        $row = $result->fetch_assoc();
        echo json_encode([
            'status' => 'success',
            'name' => $row['name'],
            'education_level' => $row['education_level'],
            'category' => $row['category'],
            'subject' => $row['subject'],
            'topic' => $row['topic'],
            'email' => $row['email'],
            'address' => $row['address'],
            'profile_image' => $row['profile_images'],
            'resume_image' => $row['resumes_images'],
            'latitude' => $row['latitude'],
            'longitude' => $row['longitude']
        ]);
    } else {
        echo json_encode(['status' => 'error', 'message' => 'User not found']);
    }

    $stmt->close();
} else {
    echo json_encode(['status' => 'error', 'message' => 'Username not provided']);
}

$con->close();
?>
