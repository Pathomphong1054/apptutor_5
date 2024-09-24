<?php
// เชื่อมต่อฐานข้อมูล
$host = 'localhost';
$dbname = 'tutoring_app';
$username = 'root';
$password = '';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    die(json_encode(['status' => 'error', 'message' => 'Database connection failed: ' . $e->getMessage()]));
}

// รับข้อมูล JSON ที่ส่งมาจาก Flutter
$data = json_decode(file_get_contents('php://input'), true);

if (!isset($data['tutor']) || !isset($data['date']) || !isset($data['isNotTeaching'])) {
    echo json_encode(['status' => 'error', 'message' => 'Missing required fields']);
    exit;
}

$tutor = $data['tutor'];
$date = $data['date'];
$isNotTeaching = $data['isNotTeaching'];

$startTime = isset($data['startTime']) ? $data['startTime'] : "00:00:00";
$endTime = isset($data['endTime']) ? $data['endTime'] : "00:00:00";
$hourlyRate = isset($data['hourlyRate']) ? $data['hourlyRate'] : 0.00;

try {
    // ตรวจสอบว่ามีตารางซ้ำหรือไม่
    $stmt = $pdo->prepare("SELECT * FROM tutor_schedule WHERE tutor = :tutor AND date = :date");
    $stmt->execute([
        ':tutor' => $tutor,
        ':date' => $date,
    ]);

    if ($stmt->rowCount() > 0) {
        echo json_encode(['status' => 'error', 'message' => 'Schedule already exists']);
        exit;
    }

    // ตรวจสอบว่าติวเฉพาะเวลา หรือไม่รับติว
    if ($isNotTeaching == 'true') {
        // ถ้าติ๊ก "ไม่รับติว" ให้บันทึก "ไม่รับติว" ในคอลัมน์ is_not_teaching
        $teachingStatus = "ไม่รับติว";
    } else if ($startTime != "00:00:00" && $endTime != "00:00:00") {
        // ถ้าเลือกเวลาสำหรับติวเฉพาะเวลา ให้บันทึก "รับติวเฉพาะเวลา"
        $teachingStatus = "รับติวเฉพาะเวลา";
    } else {
        // กรณีไม่เลือกไม่รับติวและไม่มีเวลา ให้บันทึก "รับติว"
        $teachingStatus = "รับติว";
    }

    // บันทึกข้อมูลลงในตาราง `tutor_schedule`
    $stmt = $pdo->prepare("INSERT INTO tutor_schedule (tutor, date, start_time, end_time, hourly_rate, is_not_teaching) 
                          VALUES (:tutor, :date, :start_time, :end_time, :hourly_rate, :is_not_teaching)");
    $stmt->execute([
        ':tutor' => $tutor,
        ':date' => $date,
        ':start_time' => $startTime,
        ':end_time' => $endTime,
        ':hourly_rate' => $hourlyRate,
        ':is_not_teaching' => $teachingStatus,
    ]);

    echo json_encode(['status' => 'success', 'message' => 'Schedule saved successfully']);
} catch (PDOException $e) {
    echo json_encode(['status' => 'error', 'message' => 'Failed to save schedule: ' . $e->getMessage()]);
}
