<!-- <?php
require 'db_connection.php'; // ตรวจสอบว่า db_connection.php มีการสร้างการเชื่อมต่อฐานข้อมูลที่ถูกต้อง

header('Content-Type: application/json');

// ตรวจสอบว่ามีการส่งค่าชื่อของติวเตอร์มา
if (isset($_GET['tutor'])) {
    $tutorName = $_GET['tutor'];

    // เชื่อมต่อฐานข้อมูล (ตรวจสอบให้แน่ใจว่าการเชื่อมต่อ $conn มีอยู่ใน db_connection.php)
    $conn = new mysqli('localhost', 'root', '', 'tutoring_app'); // ตรวจสอบให้แน่ใจว่าฐานข้อมูลชื่อ 'tutoring_app_db' มีอยู่

    // ตรวจสอบการเชื่อมต่อ
    if ($conn->connect_error) {
        die(json_encode(['status' => 'error', 'message' => 'Connection failed: ' . $conn->connect_error]));
    }

    // คำสั่ง SQL ดึงข้อมูลบัญชีธนาคารของติวเตอร์
    $sql = "
        SELECT bank_accounts.bank_name, bank_accounts.account_name, bank_accounts.account_number
        FROM bank_accounts
        JOIN tutors ON bank_accounts.tutor_id = tutors.id
        WHERE tutors.name = ?
    ";

    $stmt = $conn->prepare($sql);
    $stmt->bind_param('s', $tutorName);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        // หากพบข้อมูล
        $accountData = $result->fetch_assoc();
        echo json_encode([
            'status' => 'success',
            'account' => [
                'bank_name' => $accountData['bank_name'],
                'account_name' => $accountData['account_name'],
                'account_number' => $accountData['account_number'],
            ]
        ]);
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Bank account not found']);
    }

    $stmt->close();
    $conn->close(); // ปิดการเชื่อมต่อฐานข้อมูลอย่างถูกต้อง
} else {
    echo json_encode(['status' => 'error', 'message' => 'Missing tutor name']);
}
?> -->
