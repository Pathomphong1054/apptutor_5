-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Sep 18, 2024 at 05:44 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `tutoring_app`
--

-- --------------------------------------------------------

--
-- Table structure for table `favorite_tutors`
--

CREATE TABLE `favorite_tutors` (
  `id` int(11) NOT NULL,
  `student_id` varchar(255) DEFAULT NULL,
  `tutor_id` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `favorite_tutors`
--

INSERT INTO `favorite_tutors` (`id`, `student_id`, `tutor_id`, `created_at`) VALUES
(23, '3', '11', '2024-08-12 10:11:00'),
(24, '7', '11', '2024-08-12 11:52:21'),
(26, '7', '7', '2024-08-14 13:43:16'),
(28, '9', '13', '2024-08-30 01:58:59'),
(30, '9', '9', '2024-09-04 19:18:35'),
(32, '9', 'null', '2024-09-04 19:19:20'),
(34, '9', '14', '2024-09-04 19:19:35'),
(40, '12', '13', '2024-09-13 03:31:29');

-- --------------------------------------------------------

--
-- Table structure for table `messages`
--

CREATE TABLE `messages` (
  `id` int(11) UNSIGNED NOT NULL,
  `sender` varchar(255) NOT NULL,
  `recipient` varchar(255) NOT NULL,
  `message` text NOT NULL,
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp(),
  `latitude` decimal(10,8) DEFAULT NULL,
  `longitude` decimal(11,8) DEFAULT NULL,
  `session_id` varchar(255) NOT NULL,
  `file_path` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `messages`
--

INSERT INTO `messages` (`id`, `sender`, `recipient`, `message`, `timestamp`, `latitude`, `longitude`, `session_id`, `file_path`) VALUES
(220, 'Pathomphong Bunkue', 'qq', 'ติวเตอร์ตอบรับที่จะสอนแล้ว', '2024-09-12 09:38:39', NULL, NULL, '122', NULL),
(221, 'Love ', 'Pathomphong Bunkue', 'ได้มีการนัดเรียนกับคุณในวันที่ 16/9/2024, \nตั้งแต่เวลา 13:00 ถึง 15:00. \nราคาสำหรับ 1 คน คือ 200.00 บาท.', '2024-09-12 09:40:43', NULL, NULL, '124', NULL),
(222, 'Pathomphong Bunkue', 'Love ', 'ติวเตอร์ตอบรับที่จะสอนแล้ว', '2024-09-12 09:40:59', NULL, NULL, '124', NULL),
(223, 'Pathomphong Bunkue', 'Love ', 'Location: Lat: 16.2348629, Lng: 103.2698131', '2024-09-12 09:46:13', 16.23486290, 103.26981310, '124', NULL),
(224, 'Pathomphong Bunkue', 'Love ', 'Location: Lat: 16.24290376830812, Lng: 103.27274098992348', '2024-09-12 09:46:45', 16.24290377, 103.27274099, '124', NULL),
(225, 'Pathomphong Bunkue', 'qq', 'Location: Lat: 16.239008175630794, Lng: 103.2664693146944', '2024-09-12 09:48:29', 16.23900818, 103.26646931, '123', NULL),
(226, 'Pathomphong Bunkue', 'Love ', 'ติวเตอร์ตอบรับที่จะสอนแล้ว', '2024-09-12 09:50:28', NULL, NULL, '124', NULL),
(227, 'Pathomphong Bunkue', 'Love ', 'Location: Lat: 16.2348627, Lng: 103.2698167', '2024-09-12 09:51:41', 16.23486270, 103.26981670, '124', NULL),
(228, 'Love ', 'Pathomphong Bunkue', 'Location: Lat: 16.2348563, Lng: 103.269815', '2024-09-12 09:53:47', 16.23485630, 103.26981500, '124', NULL),
(229, 'Love ', 'Pathomphong Bunkue', 'Location: Lat: 16.23171668838428, Lng: 103.26788552105427', '2024-09-12 10:04:18', 16.23171669, 103.26788552, '124', NULL),
(230, 'Love ', 'Pathomphong Bunkue', 'Location: Lat: 13.736717, Lng: 100.523186', '2024-09-12 10:09:59', 13.73671700, 100.52318600, '124', NULL),
(231, 'Love ', 'FBI', 'ได้มีการนัดเรียนกับคุณในวันที่ 15/9/2024, \nตั้งแต่เวลา 13:00 ถึง 15:00. \nราคาสำหรับ 1 คน คือ 200.00 บาท.', '2024-09-12 10:13:42', NULL, NULL, '125', NULL),
(232, 'Love ', 'FBI', 'Location: Lat: 13.736717, Lng: 100.523186', '2024-09-12 10:13:58', 13.73671700, 100.52318600, '125', NULL),
(233, 'Love ', 'Pathomphong Bunkue', 'สวัสดี', '2024-09-12 10:31:19', NULL, NULL, '124', NULL),
(234, 'Pathomphong Bunkue', 'Love ', '[Image]', '2024-09-12 10:31:59', NULL, NULL, '124', 'http://10.5.50.138/tutoring_app/uploads/1000008031.jpg'),
(235, 'qq', 'Pathomphong Bunkue', 'ได้มีการนัดเรียนกับคุณในวันที่ 17/9/2024, \nตั้งแต่เวลา 13:00 ถึง 15:00. \nราคาสำหรับ 1 คน คือ 200.00 บาท.', '2024-09-12 10:33:06', NULL, NULL, '126', NULL),
(236, 'next', 'Pathomphong Bunkue', 'ได้มีการนัดเรียนกับคุณในวันที่ 17/9/2024, \nตั้งแต่เวลา 07:00 ถึง 10:00. \nราคาสำหรับ 3 คน คือ 1260.00 บาท.', '2024-09-12 10:47:23', NULL, NULL, '127', NULL),
(237, 'Pathomphong Bunkue', 'qq', 'ติวเตอร์ตอบรับที่จะสอนแล้ว', '2024-09-12 11:18:22', NULL, NULL, '123', NULL),
(238, 'Pathomphong Bunkue', 'next', 'ติวเตอร์ตอบรับที่จะสอนแล้ว', '2024-09-12 11:18:43', NULL, NULL, '127', NULL),
(239, 'Pathomphong Bunkue', 'next', 'ติวเตอร์ตอบรับที่จะสอนแล้ว', '2024-09-12 11:30:56', NULL, NULL, '127', NULL),
(240, 'Pathomphong Bunkue', 'next', 'ติวเตอร์ปฏิเสธการสอน', '2024-09-12 11:31:03', NULL, NULL, '127', NULL),
(241, 'Pathomphong Bunkue', 'qq', 'ติวเตอร์ตอบรับที่จะสอนแล้ว', '2024-09-12 11:31:08', NULL, NULL, '123', NULL),
(242, 'Pathomphong Bunkue', 'next', 'ติวเตอร์ตอบรับที่จะสอนแล้ว', '2024-09-12 11:35:45', NULL, NULL, '127', NULL),
(243, 'Pathomphong Bunkue', 'next', 'สวัสดี', '2024-09-12 11:35:52', NULL, NULL, '127', NULL),
(244, 'ปฐมพงษ์ บุญเกื้อ', 'Pathomphong Bunkue', 'ได้มีการนัดเรียนกับคุณในวันที่ 26/9/2024, 27/9/2024, \nตั้งแต่เวลา 09:00 ถึง 15:00. \nราคาสำหรับ 3 คน คือ 3240.00 บาท.', '2024-09-12 13:51:38', NULL, NULL, '128, 129', NULL),
(245, 'Pathomphong Bunkue', 'ปฐมพงษ์ บุญเกื้อ', 'ติวเตอร์ตอบรับที่จะสอนแล้ว', '2024-09-12 13:53:27', NULL, NULL, '128', NULL),
(246, 'ปฐมพงษ์ บุญเกื้อ', 'Pathomphong Bunkue', 'สวัสดีครับ ผมอยากติว เรื่อง การเขียนโปรแกรมภาษา python', '2024-09-12 13:54:36', NULL, NULL, '128', NULL),
(247, 'Pathomphong Bunkue', 'ปฐมพงษ์ บุญเกื้อ', 'ได้เลยครับ', '2024-09-12 13:55:20', NULL, NULL, '128', NULL),
(248, 'Pathomphong Bunkue', 'ปฐมพงษ์ บุญเกื้อ', 'สะดวกที่จะติวที่ไหนครับ นัดสถานที่มาเลย', '2024-09-12 13:55:40', NULL, NULL, '128', NULL),
(249, 'ปฐมพงษ์ บุญเกื้อ', 'Pathomphong Bunkue', 'งั้น ที่ตึง IT มมส ไหมครับ', '2024-09-12 13:56:21', NULL, NULL, '128', NULL),
(250, 'ปฐมพงษ์ บุญเกื้อ', 'Pathomphong Bunkue', 'เดี๋ยวส่งแผนที่ให้', '2024-09-12 13:56:30', NULL, NULL, '128', NULL),
(251, 'ปฐมพงษ์ บุญเกื้อ', 'Pathomphong Bunkue', 'Location: Lat: 16.246188341275424, Lng: 103.25220163911581', '2024-09-12 13:56:47', 16.24618834, 103.25220164, '128', NULL),
(252, 'Pathomphong Bunkue', 'ปฐมพงษ์ บุญเกื้อ', 'ครับผม', '2024-09-12 13:58:26', NULL, NULL, '128', NULL),
(253, 'Pathomphong Bunkue', 'ปฐมพงษ์ บุญเกื้อ', '[Image]', '2024-09-12 13:59:35', NULL, NULL, '128', 'http://10.5.50.138/tutoring_app/uploads/1000008027.png'),
(254, 'Pathomphong Bunkue', 'ปฐมพงษ์ บุญเกื้อ', 'หลังเรียนเสร็จค่อยจ่ายก็ได้นะครับ', '2024-09-12 14:00:00', NULL, NULL, '128', NULL),
(255, 'ปฐมพงษ์ บุญเกื้อ', 'Pathomphong Bunkue', 'ครับ', '2024-09-12 14:00:24', NULL, NULL, '128', NULL),
(256, 'QQ', 'Pathomphong Bunkue', 'ได้มีการนัดเรียนกับคุณในวันที่ 11/9/2024, \nตั้งแต่เวลา 13:00 ถึง 15:00. \nราคาสำหรับ 1 คน คือ 200.00 บาท.', '2024-09-12 14:18:08', NULL, NULL, '130', NULL),
(257, 'QQ', 'Pathomphong Bunkue', 'ติวเตอร์ปฏิเสธการสอน', '2024-09-12 14:18:15', NULL, NULL, '130', NULL),
(266, 'ปฐมพงษ์ บุญเกื้อ', 'Pathomphong Bunkue', 'ได้มีการนัดเรียนกับคุณในวันที่ 26/10/2024, 25/9/2024, 26/9/2024, \nตั้งแต่เวลา 12:00 ถึง 15:00. \nราคาสำหรับ 1 คน คือ 300.00 บาท.', '2024-09-17 19:37:14', NULL, NULL, '181, 182, 183', NULL),
(267, 'ปฐมพงษ์ บุญเกื้อ', 'Pathomphong Bunkue', 'ได้มีการนัดเรียนกับคุณในวันที่ 24/9/2024, \nตั้งแต่เวลา 13:00 ถึง 15:00. \nราคาสำหรับ 3 คน คือ 1200.00 บาท.', '2024-09-18 13:57:39', NULL, NULL, '185', NULL),
(268, 'ปฐมพงษ์ บุญเกื้อ', 'Pathomphong Bunkue', '[Image]', '2024-09-18 14:01:17', NULL, NULL, '181', 'http://10.5.50.138/tutoring_app/uploads/0366eaf3-38fe-4ee0-9321-b2df54091157-1_all_195584.jpg'),
(269, 'ปฐมพงษ์ บุญเกื้อ', 'Pathomphong Bunkue', 'ได้มีการนัดเรียนกับคุณในวันที่ 25/9/2024, 26/9/2024, 27/9/2024, \nตั้งแต่เวลา 08:00 ถึง 12:00. \nราคาสำหรับ 3 คน คือ 2640.00 บาท.', '2024-09-18 14:06:02', NULL, NULL, '186, 187, 188', NULL),
(270, 'ปฐมพงษ์ บุญเกื้อ', 'Pathomphong Bunkue', 'ได้มีการนัดเรียนกับคุณในวันที่ 22/9/2024, \nตั้งแต่เวลา 08:00 ถึง 12:00. \nราคาสำหรับ 3 คน คือ 2640.00 บาท.', '2024-09-18 14:06:20', NULL, NULL, '189', NULL),
(271, 'ปฐมพงษ์ บุญเกื้อ', 'Pathomphong Bunkue', 'การนัดหมายวันที่ 26/9/2024 ถูกยกเลิกแล้ว.\n', '2024-09-18 14:09:08', NULL, NULL, '187', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `notifications`
--

CREATE TABLE `notifications` (
  `id` int(11) UNSIGNED NOT NULL,
  `sender` varchar(255) NOT NULL,
  `recipient` varchar(255) NOT NULL,
  `message` text NOT NULL,
  `role` enum('student','tutor','admin') NOT NULL,
  `type` varchar(255) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `is_read` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `notifications`
--

INSERT INTO `notifications` (`id`, `sender`, `recipient`, `message`, `role`, `type`, `created_at`, `is_read`) VALUES
(1, 'php', 'a', 'คุณมีคำขอติวใหม่', 'student', '', '2024-08-09 16:47:57', 0),
(2, 'a', 'b', 'hello', 'student', 'chat', '2024-08-09 16:49:26', 0),
(3, 'b', 'a', 'คุณมีคำขอติวใหม่', 'student', '', '2024-08-09 16:57:06', 0),
(4, 'java', 'b', 'hello', 'student', 'chat', '2024-08-09 17:00:45', 0),
(7, 'b', 'a', 'hello', 'tutor', 'chat', '2024-08-09 17:12:41', 0),
(8, 'php', 'java', 'คุณมีคำขอติวใหม่', 'student', '', '2024-08-09 17:41:39', 1),
(11, 'ss', 'z', 'คุณมีคำขอติวใหม่', 'student', '', '2024-08-09 19:14:55', 1),
(12, 'ss', 'z', 'คุณมีคำขอติวใหม่', 'student', '', '2024-08-09 19:15:22', 1),
(13, 'z', 'ss', 'hello', 'student', 'chat', '2024-08-09 19:50:54', 0),
(14, 'z', 'n', 'hello', 'student', 'chat', '2024-08-09 20:56:19', 0),
(15, 'java', 'm', 'hello', 'student', 'chat', '2024-08-10 07:28:49', 0),
(16, 'java', 'php', 'hello', 'student', 'chat', '2024-08-10 08:04:13', 1),
(18, 'java', 'php', 'hello', 'student', 'chat', '2024-08-10 11:52:53', 1),
(19, 'z', 'php', 'hello', 'student', 'chat', '2024-08-10 12:35:46', 1),
(20, 'a', 'php', 'hello', 'student', 'chat', '2024-08-10 12:44:01', 1),
(21, 'a', 'm', 'gg', 'student', 'chat', '2024-08-10 12:55:34', 0),
(22, 'java', 'n', 'hello', 'student', 'chat', '2024-08-10 13:31:50', 0),
(23, 'next', 'go', 'hello', 'student', 'chat', '2024-08-10 14:24:47', 1),
(24, 'go', 'next', 'hello', 'tutor', 'chat', '2024-08-10 14:25:36', 1),
(25, 'go', 'next', 'Ms go to', 'tutor', 'chat', '2024-08-10 14:25:48', 1),
(26, 'php', 'a', 'hello', 'tutor', 'chat', '2024-08-12 10:22:37', 0),
(27, 'next', 'phpAB', 'hello', 'student', 'chat', '2024-08-12 11:06:52', 1),
(28, 'phpAB', 'next', 'hello', 'tutor', 'chat', '2024-08-12 11:21:28', 0),
(29, 'next', 'phpAB', 'hello', 'student', 'chat', '2024-08-12 11:47:58', 0),
(30, 'next', 'phpAB', 'rf', 'student', 'chat', '2024-08-12 11:49:51', 0),
(31, 'next', 'Pathomphong Bunkue', 'hello', 'student', 'chat', '2024-08-12 14:58:10', 0),
(32, 'next', 'Pathomphong Bunkue', 'rrr', 'student', 'chat', '2024-08-12 16:54:32', 0),
(33, 'next', 'Pathomphong Bunkue', 'gjd', 'student', 'chat', '2024-08-12 17:03:30', 0),
(34, 'next', 'Pathomphong Bunkue', 'ttgh', 'student', 'chat', '2024-08-12 17:04:58', 0),
(35, 'next', 'Pathomphong Bunkue', 'hello', 'student', 'chat', '2024-08-12 17:08:15', 1),
(36, 'next', 'Pathomphong Bunkue', 'hello', 'student', 'chat', '2024-08-12 17:11:07', 1),
(37, 'next', 'Pathomphong Bunkue', 'ff', 'student', 'chat', '2024-08-12 17:14:32', 1),
(38, 'Pathomphong Bunkue', 'next', 'hello', 'tutor', 'chat', '2024-08-14 11:16:59', 0),
(39, 'Pathomphong Bunkue', 'next', 'สวัสดี', 'tutor', 'chat', '2024-08-14 13:39:08', 0),
(40, 'next', 'Pathomphong Bunkue', 'juh', 'student', 'chat', '2024-08-16 16:47:51', 0),
(41, 'next', 'Pathomphong Bunkue', 'Location: Lat: 13.99871808351876, Lng: 100.66613338887691', 'student', 'location', '2024-08-18 07:11:11', 0),
(42, 'next', 'Pathomphong Bunkue', 'Location: Lat: 14.104845363847591, Lng: 100.92156048864126', 'student', 'location', '2024-08-18 07:17:47', 0),
(43, 'next', 'phpAB', 'Location: Lat: 13.7563, Lng: 100.5018', 'student', 'location', '2024-08-18 07:27:50', 0),
(44, 'next', 'phpAB', 'Location: Lat: 14.077204732870575, Lng: 100.84944427013397', 'student', 'location', '2024-08-18 07:36:34', 0),
(45, 'next', 'phpAB', 'Location: Lat: 13.956737066439073, Lng: 100.7306757196784', 'student', 'location', '2024-08-18 07:44:28', 0),
(46, 'next', 'phpAB', 'Location: Lat: 13.90187179203532, Lng: 100.63821360468864', 'student', 'location', '2024-08-18 07:44:41', 0),
(47, 'next', 'phpAB', 'Location: Lat: 13.7563, Lng: 100.5018', 'student', 'location', '2024-08-18 07:48:58', 0),
(48, 'next', 'phpAB', 'ดีครับ', 'student', 'chat', '2024-08-18 07:49:05', 0),
(49, 'Pathomphong Bunkue', 'next', 'Location: Lat: 13.822318471094254, Lng: 100.57961974292994', 'tutor', 'location', '2024-08-18 07:51:11', 1),
(50, 'Pathomphong Bunkue', 'next', 'Location: Lat: 13.7563, Lng: 100.5018', 'tutor', 'location', '2024-08-18 07:59:14', 0),
(51, 'Pathomphong Bunkue', 'next', 'ดีครับ', 'tutor', 'chat', '2024-08-18 08:01:32', 0),
(52, 'Pathomphong Bunkue', 'next', 'ดีครับ', 'tutor', 'chat', '2024-08-18 08:01:41', 1),
(53, 'Pathomphong Bunkue', 'java', 'หวัดดี', 'tutor', 'chat', '2024-08-18 08:10:35', 0),
(54, 'Pathomphong Bunkue', 'next', 'ดีครับ', 'tutor', 'chat', '2024-08-18 08:11:18', 1),
(55, 'Pathomphong Bunkue', 'next', 'สวัสดี', 'tutor', 'chat', '2024-08-18 08:27:15', 1),
(56, 'Pathomphong Bunkue', 'next', 'สวัสดี', 'tutor', 'chat', '2024-08-18 08:28:25', 1),
(57, 'Pathomphong Bunkue', 'next', 'วง', 'tutor', 'chat', '2024-08-18 08:35:21', 1),
(58, 'Pathomphong Bunkue', 'java', 'วำวำ', 'tutor', 'chat', '2024-08-18 08:35:33', 0),
(59, 'Pathomphong Bunkue', 'java', 'วำวำ', 'tutor', 'chat', '2024-08-18 08:35:33', 0),
(60, 'next', 'Pathomphong Bunkue', 'Location: Lat: 15.983203551794423, Lng: 101.92580334842205', 'student', 'location', '2024-08-18 09:00:23', 0),
(61, 'next', 'Pathomphong Bunkue', 'Location: Lat: 16.240706833486136, Lng: 103.25605731457472', 'student', 'location', '2024-08-18 09:31:03', 0),
(62, 'next', 'Pathomphong Bunkue', 'Location: Lat: 15.030089867142562, Lng: 102.05343190580606', 'student', 'location', '2024-08-18 15:13:10', 0),
(63, 'next', 'Pathomphong Bunkue', 'Location: Lat: 16.24653855514836, Lng: 103.25189620256424', 'student', 'location', '2024-08-19 07:39:22', 0),
(64, 'Love ', 'FBI', 'สวัสดี', 'student', 'chat', '2024-08-19 09:25:55', 0),
(65, 'Love ', 'Pathomphong Bunkue', 'สวัสดีครับ', 'student', 'chat', '2024-08-30 02:00:53', 1),
(66, 'Love ', 'Pathomphong Bunkue', 'ผมต้องการติววิชาคณิตศาสตร์', 'student', 'chat', '2024-08-30 02:01:05', 1),
(67, 'Love ', 'Pathomphong Bunkue', 'Location: Lat: 16.2348849, Lng: 103.2698251', 'student', 'location', '2024-08-30 02:01:16', 1),
(68, 'Pathomphong Bunkue', 'Love ', 'สวัสดีครับ', 'tutor', 'chat', '2024-08-30 02:01:58', 0),
(69, 'Pathomphong Bunkue', 'Love ', 'ได้ครับ', 'tutor', 'chat', '2024-08-30 02:02:03', 0),
(70, 'Pathomphong Bunkue', 'Love ', 'ต้องการติวในส่วนในหรอครับ', 'tutor', 'chat', '2024-08-30 02:02:12', 0),
(71, 'Love ', 'Pathomphong Bunkue', '🥲🥲🥲', 'student', 'chat', '2024-08-30 07:43:17', 0),
(72, 'Love ', 'Pathomphong Bunkue', '😢😢😢', 'student', 'chat', '2024-08-30 07:43:18', 1),
(73, 'Love ', 'Pathomphong Bunkue', 'Location: Lat: 16.2465395, Lng: 103.2522775', 'student', 'location', '2024-08-30 07:46:28', 0),
(74, 'Pathomphong Bunkue', 'Love ', 'Location: Lat: 16.242905055881767, Lng: 103.25671043246984', 'tutor', 'location', '2024-09-03 07:53:26', 0),
(75, 'Pathomphong Bunkue', 'Love ', 'Location: Lat: 16.237343302873942, Lng: 103.26641097664833', 'tutor', 'location', '2024-09-03 07:54:41', 0),
(76, 'Pathomphong Bunkue', 'Love ', 'Location: Lat: 16.246440057559646, Lng: 103.25213391333818', 'tutor', 'location', '2024-09-04 16:30:51', 0),
(77, 'Pathomphong Bunkue', 'java', 'Location: Lat: 16.246185766171106, Lng: 103.25191531330347', 'tutor', 'location', '2024-09-04 16:33:52', 0),
(78, 'Pathomphong Bunkue', 'java', 'Location: Lat: 16.240775719434172, Lng: 103.261872343719', 'tutor', 'location', '2024-09-04 16:36:04', 0),
(79, 'Pathomphong Bunkue', 'java', 'สวัสดี', 'tutor', 'chat', '2024-09-04 16:38:29', 0),
(80, 'Pathomphong Bunkue', 'Love ', 'สวัสดีดี', 'tutor', 'chat', '2024-09-04 16:38:36', 1),
(81, 'Love ', 'Pathomphong Bunkue', 'สวัสดี', 'student', 'chat', '2024-09-04 16:44:31', 0),
(82, 'Love ', 'Pathomphong Bunkue', 'Location: Lat: 16.235626589277818, Lng: 103.26520163565874', 'student', 'location', '2024-09-04 16:45:40', 0),
(83, 'Love ', 'Pathomphong Bunkue', 're', 'student', 'chat', '2024-09-04 16:48:38', 0),
(84, 'Love ', 'Pathomphong Bunkue', 'happy', 'student', 'chat', '2024-09-04 16:53:54', 0),
(85, 'Love ', 'Pathomphong Bunkue', 'Location: Lat: 16.23521358431541, Lng: 103.2632389292121', 'student', 'location', '2024-09-04 17:06:58', 0),
(86, 'Love ', 'Pathomphong Bunkue', 'สวัสดี', 'student', 'chat', '2024-09-04 17:13:39', 0),
(87, 'Love ', 'Pathomphong Bunkue', 'สวัสดี', 'student', 'chat', '2024-09-04 17:14:12', 0),
(88, 'Love ', 'FBI', 'สวัสดี', 'student', 'chat', '2024-09-04 17:18:27', 0),
(89, 'Pathomphong Bunkue', 'Love ', 'สวัสดี', 'tutor', 'chat', '2024-09-04 17:36:32', 1),
(90, 'Love ', 'Pathomphong Bunkue', 'สวัสดี', 'student', 'chat', '2024-09-04 17:41:52', 1),
(91, 'Love ', 'FBI', 'Location: Lat: 13.7563309, Lng: 100.5017651', 'student', 'location', '2024-09-04 18:50:23', 1),
(92, 'Love ', 'FBI', 'Location: Lat: 16.2348788, Lng: 103.2698118', 'student', 'location', '2024-09-04 19:03:23', 1),
(93, 'Love ', 'FBI', 'Location: Lat: 16.250791, Lng: 103.2500398', 'student', 'location', '2024-09-04 19:18:22', 1),
(94, 'Pathomphong Bunkue', 'Love ', 'สวัสดีค่ะ', 'tutor', 'chat', '2024-09-05 16:04:11', 1),
(95, 'Love ', 'Pathomphong Bunkue', 'a', 'student', 'chat', '2024-09-05 19:06:08', 0),
(96, 'Love ', 'Pathomphong Bunkue', 'Location: Lat: 16.243593262792544, Lng: 103.25140938162804', 'student', 'location', '2024-09-06 03:29:02', 0),
(97, 'Pathomphong Bunkue', 'Love ', 'Location: Lat: 16.250791, Lng: 103.2500398', 'tutor', 'location', '2024-09-06 03:44:16', 0),
(98, 'next', 'Pathomphong Bunkue', 'Location: Lat: 16.2348917, Lng: 103.2698003', 'student', 'location', '2024-09-09 21:29:40', 0),
(99, 'Love ', 'Pathomphong Bunkue', 'สวัสดีค่ะ', 'student', 'chat', '2024-09-11 16:58:01', 0),
(100, 'Love ', 'Pathomphong Bunkue', 'สวัสดีค่ะ', 'student', 'chat', '2024-09-11 16:58:01', 0),
(101, 'Love ', 'Pathomphong Bunkue', 'สวัสดี', 'student', 'chat', '2024-09-11 17:10:56', 0),
(102, 'Love ', 'Pathomphong Bunkue', 'Location: Lat: 16.243861398883638, Lng: 103.25619108974934', 'student', 'location', '2024-09-11 17:22:21', 0),
(103, 'Love ', 'js', 'สวัสดี', 'student', 'chat', '2024-09-11 17:26:54', 0),
(104, 'Pathomphong Bunkue', 'Love ', 'สวัสดี', 'tutor', 'chat', '2024-09-11 17:37:53', 0),
(105, 'Love ', 'Pathomphong Bunkue', 'Location: Lat: 16.248777269715955, Lng: 103.25339522212744', 'student', 'location', '2024-09-11 18:21:47', 0),
(106, 'Love ', 'Pathomphong Bunkue', 'Location: Lat: 16.2348645, Lng: 103.2698046', 'student', 'location', '2024-09-11 18:48:56', 0),
(107, 'Pathomphong Bunkue', 'Love ', 'สวัสดีค่ะ', 'tutor', 'chat', '2024-09-11 20:09:40', 0),
(108, 'Pathomphong Bunkue', 'Love ', 'สวัสดี', 'tutor', 'chat', '2024-09-11 20:55:32', 0),
(109, 'Love ', 'Pathomphong Bunkue', 'สวัสดี', 'student', 'chat', '2024-09-11 21:10:19', 0),
(110, 'Love ', 'Pathomphong Bunkue', 'สวัสดี', 'student', 'chat', '2024-09-11 21:18:05', 0),
(111, 'Pathomphong Bunkue', 'qq', 'happy', 'tutor', 'chat', '2024-09-11 22:04:06', 0),
(112, 'qq', 'Pathomphong Bunkue', 'สวัสดี', 'student', 'chat', '2024-09-11 22:27:13', 0),
(113, 'Pathomphong Bunkue', 'Love ', 'Location: Lat: 16.2348629, Lng: 103.2698131', 'tutor', 'location', '2024-09-12 09:46:13', 0),
(114, 'Pathomphong Bunkue', 'Love ', 'Location: Lat: 16.24290376830812, Lng: 103.27274098992348', 'tutor', 'location', '2024-09-12 09:46:45', 0),
(115, 'Pathomphong Bunkue', 'qq', 'Location: Lat: 16.239008175630794, Lng: 103.2664693146944', 'tutor', 'location', '2024-09-12 09:48:29', 0),
(116, 'Pathomphong Bunkue', 'Love ', 'Location: Lat: 16.2348627, Lng: 103.2698167', 'tutor', 'location', '2024-09-12 09:51:41', 0),
(117, 'Love ', 'Pathomphong Bunkue', 'Location: Lat: 16.2348563, Lng: 103.269815', 'student', 'location', '2024-09-12 09:53:47', 0),
(118, 'Love ', 'Pathomphong Bunkue', 'Location: Lat: 16.23171668838428, Lng: 103.26788552105427', 'student', 'location', '2024-09-12 10:04:18', 0),
(119, 'Love ', 'Pathomphong Bunkue', 'Location: Lat: 13.736717, Lng: 100.523186', 'student', 'location', '2024-09-12 10:09:59', 0),
(120, 'Love ', 'FBI', 'Location: Lat: 13.736717, Lng: 100.523186', 'student', 'location', '2024-09-12 10:13:58', 0),
(121, 'Love ', 'Pathomphong Bunkue', 'สวัสดี', 'student', 'chat', '2024-09-12 10:31:19', 0),
(122, 'Pathomphong Bunkue', 'next', 'สวัสดี', 'tutor', 'chat', '2024-09-12 11:35:53', 0),
(123, 'ปฐมพงษ์ บุญเกื้อ', 'Pathomphong Bunkue', 'สวัสดีครับ ผมอยากติว เรื่อง การเขียนโปรแกรมภาษา python', 'student', 'chat', '2024-09-12 13:54:36', 0),
(124, 'Pathomphong Bunkue', 'ปฐมพงษ์ บุญเกื้อ', 'ได้เลยครับ', 'tutor', 'chat', '2024-09-12 13:55:20', 0),
(125, 'Pathomphong Bunkue', 'ปฐมพงษ์ บุญเกื้อ', 'สะดวกที่จะติวที่ไหนครับ นัดสถานที่มาเลย', 'tutor', 'chat', '2024-09-12 13:55:40', 0),
(126, 'ปฐมพงษ์ บุญเกื้อ', 'Pathomphong Bunkue', 'งั้น ที่ตึง IT มมส ไหมครับ', 'student', 'chat', '2024-09-12 13:56:21', 0),
(127, 'ปฐมพงษ์ บุญเกื้อ', 'Pathomphong Bunkue', 'เดี๋ยวส่งแผนที่ให้', 'student', 'chat', '2024-09-12 13:56:30', 0),
(128, 'ปฐมพงษ์ บุญเกื้อ', 'Pathomphong Bunkue', 'Location: Lat: 16.246188341275424, Lng: 103.25220163911581', 'student', 'location', '2024-09-12 13:56:47', 1),
(129, 'Pathomphong Bunkue', 'ปฐมพงษ์ บุญเกื้อ', 'ครับผม', 'tutor', 'chat', '2024-09-12 13:58:26', 0),
(130, 'Pathomphong Bunkue', 'ปฐมพงษ์ บุญเกื้อ', 'หลังเรียนเสร็จค่อยจ่ายก็ได้นะครับ', 'tutor', 'chat', '2024-09-12 14:00:00', 0),
(131, 'ปฐมพงษ์ บุญเกื้อ', 'Pathomphong Bunkue', 'ครับ', 'student', 'chat', '2024-09-12 14:00:24', 1);

-- --------------------------------------------------------

--
-- Table structure for table `port_messages`
--

CREATE TABLE `port_messages` (
  `id` int(11) UNSIGNED NOT NULL,
  `userName` varchar(255) NOT NULL,
  `profileImageUrl` varchar(255) NOT NULL,
  `message` text NOT NULL,
  `dateTime` varchar(255) NOT NULL,
  `location` varchar(255) NOT NULL,
  `subject` varchar(255) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `port_messages`
--

INSERT INTO `port_messages` (`id`, `userName`, `profileImageUrl`, `message`, `dateTime`, `location`, `subject`, `created_at`) VALUES
(9, 'Love ', 'images/default_profile.jpg', 'สวัสดีครับผมต้องการติว', 'ทุกๆวันเสาร์อาทิตย์ เวลา 12.00-16.00', 'msu', 'Mobile Development', '2024-08-19 09:15:21'),
(10, 'Love ', 'images/default_profile.jpg', 'สวัสดีครับผมต้องการติว', 'ทุกๆวันเสาร์อาทิตย์ เวลา 12.00-16.00', 'msu', 'Mobile Development', '2024-08-19 09:15:32'),
(12, 'ปฐมพงษ์ บุญเกื้อ', 'images/default_profile.jpg', 'สวัสดีครับ ผมชื่อ บีม\nผมอยากเรียน การเขียนโปรแกมpython\nมีใครพอจะรับติวไหมครับ', 'ทุกวัน เสาอาทิตย์ เวลา 10:00-15:00', 'สถานที่ ตึกIT มมส', 'Programming', '2024-09-12 14:05:26');

-- --------------------------------------------------------

--
-- Table structure for table `requests`
--

CREATE TABLE `requests` (
  `id` int(11) UNSIGNED NOT NULL,
  `sender` varchar(255) NOT NULL,
  `recipient` varchar(255) NOT NULL,
  `message` text NOT NULL,
  `is_accepted` tinyint(1) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `requests`
--

INSERT INTO `requests` (`id`, `sender`, `recipient`, `message`, `is_accepted`, `created_at`) VALUES
(1, 'ss', 'z', 'คุณมีคำขอติวใหม่', 1, '2024-08-09 14:45:22'),
(2, 'ss', 'z', 'คุณมีคำขอติวใหม่', 0, '2024-08-09 14:47:37'),
(4, 'php', 'a', 'คุณมีคำขอติวใหม่', 0, '2024-08-10 01:57:21'),
(7, 'php', 'a', 'คุณมีคำขอติวใหม่', 0, '2024-08-10 07:43:27'),
(8, 'm', 'a', 'คุณมีคำขอติวใหม่', 0, '2024-08-10 07:50:57'),
(10, 'php', 'z', 'คุณมีคำขอติวใหม่', 0, '2024-08-10 08:38:06'),
(12, 'php', 'java', 'คุณมีคำขอติวใหม่', 0, '2024-08-12 05:18:36'),
(13, 'php', 'java', 'คุณมีคำขอติวใหม่', 0, '2024-08-12 05:18:56'),
(14, 'phpABCD', 'next', 'คุณมีคำขอติวใหม่', 0, '2024-08-12 06:04:46'),
(25, 'f', 'Love ', 'คุณมีคำขอติวใหม่', 0, '2024-08-19 04:20:19'),
(26, 'f', 'Love ', 'คุณมีคำขอติวใหม่', 0, '2024-08-19 04:20:24'),
(42, 'FBI', 'Love ', 'คุณมีคำขอติวใหม่', 0, '2024-09-04 14:56:15'),
(44, 'Pathomphong Bunkue', 'qq', 'คุณมีคำขอติวใหม่', 0, '2024-09-11 17:05:43'),
(47, 'Pathomphong Bunkue', 'ปฐมพงษ์ บุญเกื้อ', 'คุณมีคำขอติวใหม่', 0, '2024-09-12 23:03:03'),
(48, 'Pathomphong Bunkue', 'ปฐมพงษ์ บุญเกื้อ', 'คุณมีคำขอติวใหม่', 0, '2024-09-12 23:03:31');

-- --------------------------------------------------------

--
-- Table structure for table `reviews`
--

CREATE TABLE `reviews` (
  `id` int(11) UNSIGNED NOT NULL,
  `tutor_name` varchar(255) NOT NULL,
  `rating` int(1) NOT NULL CHECK (`rating` >= 1 and `rating` <= 5),
  `comment` text NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `reviews`
--

INSERT INTO `reviews` (`id`, `tutor_name`, `rating`, `comment`, `created_at`) VALUES
(30, 'n', 5, 'D', '2024-08-09 20:45:51'),
(31, 'n', 5, 'g', '2024-08-09 20:47:51'),
(32, 'php', 3, 'f', '2024-08-09 20:51:22'),
(33, 'm', 5, 'c', '2024-08-10 07:24:34'),
(34, 'DDD', 1, 'f', '2024-08-10 11:47:30'),
(35, 'DDD', 3, 'o', '2024-08-10 11:51:25'),
(36, 'n', 5, 'g', '2024-08-10 11:52:07'),
(37, 'm', 2, 'g', '2024-08-10 11:52:21'),
(38, 'DDD', 2, 'g', '2024-08-10 13:03:52'),
(39, 'm', 5, 'f', '2024-08-10 13:04:07'),
(40, 'go', 5, 'good ', '2024-08-10 14:28:26'),
(41, 'DDD', 5, 'good ', '2024-08-10 15:36:05'),
(42, 'n', 5, 'f', '2024-08-12 08:28:20'),
(43, 'phpAB', 5, 'v', '2024-08-12 11:51:36'),
(44, 'Pathomphong Bunkue', 5, 'ok', '2024-08-12 14:29:16'),
(45, 'Pathomphong Bunkue', 5, 'ติวดีมากเลยครับ', '2024-08-19 07:13:54'),
(46, 'FBI', 5, 'ดีมาก', '2024-09-04 17:07:38'),
(47, 'FBI', 5, 'สุดยอดมากครับ', '2024-09-04 19:47:03');

-- --------------------------------------------------------

--
-- Table structure for table `students`
--

CREATE TABLE `students` (
  `id` int(11) NOT NULL,
  `role` varchar(50) NOT NULL,
  `name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `address` varchar(255) DEFAULT NULL,
  `profile_images` varchar(255) DEFAULT NULL,
  `latitude` double DEFAULT NULL,
  `longitude` double DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Dumping data for table `students`
--

INSERT INTO `students` (`id`, `role`, `name`, `email`, `password`, `address`, `profile_images`, `latitude`, `longitude`) VALUES
(2, 'student', 'a', 'a@gmail.com', '$2y$10$tsv4srFgirKdWetokkbVyuN8kaJcgvrh7Um3t7xRl9AVf3Srebipq', 'Bangkok', '66abaa90e963e-images.jpg', NULL, NULL),
(3, 'student', 'java', 'java@gmail.com', '$2y$10$ov0aAjadkB.FdtjgQVc4A.G2mHCsvc6DB4f8W29fi/aFQ4qIiWFvG', 'Bangkok', '336666817_762937638486356_4128242660743559988_n.jpg', NULL, NULL),
(4, 'student', 'F', 'f@gmail.com', '$2y$10$gue7n0G.JRo.MWxtCFpILuGTOX2hRdZqOcf7n2l1mohCiP3.b6b4y', 'Bangkok', 'images (1).jpg', NULL, NULL),
(5, 'student', 'z', 'zz@gmail.com', '$2y$10$WZUawOLcPKT3FG2138lAgOiDPN8fHmZZ.UrXdH6sCRuowK6nF2Mf6', 'Bangkok', '66abaa90e963e-images.jpg', NULL, NULL),
(6, 'student', 'R', 'R@gmail.com', '$2y$10$.p4ATTG47b2ytu.rjdzblu9tyrqqKbq1wtFDB6mJLiFkfxTI36Y8y', 'Bangkok', '0e57949d-bf16-4ce3-9954-40be82379ac2.jpg', NULL, NULL),
(7, 'student', 'next', 'next@gmail.com', '$2y$10$GHIVxn7UhXEHtIeAsWIcuuQ1WIia6pIVghH0ixPiH8pzfAbMGK61.', 'Bangkok', '36.jpg', 16.2349037, 103.2698166),
(9, 'student', 'Love ', 'L@gmail.com', '$2y$10$MSRRBfMQoZBB/csPtR.pguIqjkYG1rYBHhKjlq6ci/U7BfY2oUMXO', 'Chachoengsao', '66abaa90e963e-images.jpg', 16.2348997, 103.2697895),
(11, 'student', 'QQ', 'qq@gmail.com', '$2y$10$zhVw7yXDJcIoCSRttrgiu.aqLvi/O1sRoZmj5OFYe3AWk9S9S4.vW', '262 ม.4 ท่าขอนยาง Tambon Tha Khon Yang, Amphoe Kantharawichai, Chang Wat Maha Sarakham 44150, Thailand', '1000007779.png', 16.2348671, 103.2698086),
(12, 'student', 'ปฐมพงษ์ บุญเกื้อ', 'pathomphong@gmail.com', '$2y$10$sfpX3xcUjtZs.gNtgFniGu64Uy7tVZo/pvYWHnvubVLxxoN5jdVLW', '262 ม.4 ท่าขอนยาง Tambon Tha Khon Yang, Amphoe Kantharawichai, Chang Wat Maha Sarakham 44150, Thailand', '1000007729.jpg', 16.234986962362086, 103.26987270265818),
(13, 'student', '', 'AL@gmail.com', '$2y$10$HmDaaGUY53oDNi0sWmv/FOBpIiHZ2TUHm76MmDHS6/fYpMlCaEtQa', '262 ม.4 ท่าขอนยาง Tambon Tha Khon Yang, Amphoe Kantharawichai, Chang Wat Maha Sarakham 44150, Thailand', '0366eaf3-38fe-4ee0-9321-b2df54091157-1_all_194897.jpg', NULL, NULL),
(14, 'student', 'AA', 'AI@gmail.com', '$2y$10$cnIn1X7LXtwgl05ZRfzzg.1WUpQfp.ocxsJgbl3qFJSnSvjp1wQUy', '262 ม.4 ท่าขอนยาง Tambon Tha Khon Yang, Amphoe Kantharawichai, Chang Wat Maha Sarakham 44150, Thailand', '0366eaf3-38fe-4ee0-9321-b2df54091157-1_all_194897.jpg', NULL, NULL),
(15, 'student', 'บีม', 'jjk@gmail.com', '$2y$10$esmeKyUJ5csHtCQa72gbSOlNb78ERf..r1mxyWKO7AGQz5La8Bwra', '262 ม.4 ท่าขอนยาง Tambon Tha Khon Yang, Amphoe Kantharawichai, Chang Wat Maha Sarakham 44150, Thailand', '', 16.2348739, 103.2698043),
(16, 'student', 'ปฐมนิเทศ', 'x@gmail.com', '$2y$10$82PyIC9Mwvx7VQqHLXrCO.ewFv8X4Wjy3CpI8quwhtOOT9zFN6tiG', '262 ม.4 ท่าขอนยาง Tambon Tha Khon Yang, Amphoe Kantharawichai, Chang Wat Maha Sarakham 44150, Thailand', '', 16.2348936, 103.2698164);

-- --------------------------------------------------------

--
-- Table structure for table `tutoring_sessions`
--

CREATE TABLE `tutoring_sessions` (
  `id` int(11) UNSIGNED NOT NULL,
  `student` varchar(255) NOT NULL,
  `tutor` varchar(255) NOT NULL,
  `date` date NOT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  `rate` varchar(255) NOT NULL,
  `amount` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `response_status` enum('pending','accepted','declined') NOT NULL DEFAULT 'pending',
  `status` enum('pending','confirmed','completed','cancelled') NOT NULL DEFAULT 'pending'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tutoring_sessions`
--

INSERT INTO `tutoring_sessions` (`id`, `student`, `tutor`, `date`, `start_time`, `end_time`, `rate`, `amount`, `created_at`, `response_status`, `status`) VALUES
(188, 'ปฐมพงษ์ บุญเกื้อ', 'Pathomphong Bunkue', '2024-09-27', '08:00:00', '12:00:00', '3', '2640', '2024-09-18 14:06:02', 'pending', 'pending');

-- --------------------------------------------------------

--
-- Table structure for table `tutors`
--

CREATE TABLE `tutors` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `email` varchar(100) NOT NULL,
  `category` varchar(100) NOT NULL,
  `subject` varchar(100) NOT NULL,
  `topic` varchar(100) NOT NULL,
  `education_level` varchar(255) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `profile_images` varchar(255) DEFAULT NULL,
  `resumes_images` varchar(255) DEFAULT NULL,
  `role` varchar(255) NOT NULL,
  `latitude` double DEFAULT NULL,
  `longitude` double DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Dumping data for table `tutors`
--

INSERT INTO `tutors` (`id`, `name`, `password`, `email`, `category`, `subject`, `topic`, `education_level`, `address`, `profile_images`, `resumes_images`, `role`, `latitude`, `longitude`) VALUES
(7, 'phpAB', '$2y$10$sz5w6slnkFswZDfaAvFwAeI8qg2Vaklz9WXaqUUdMhQOuEQ6j3BbO', 'php@gmail.com', 'Computer', 'Programming', 'Java', NULL, 'Bangkok', 'images (1).jpg', 'images (5).jpg', 'Tutor', 16.059415901909404, 103.65121576935053),
(8, 'n', '$2y$10$vYZc7NWmQxepIZOvlrr4PuKR3E1fegM4Z7loUvIpHd4ipPbX51bk6', 'n@gmail.com', 'Computer', 'Data Science', 'Data Analysis', NULL, 'Bangkok', '336666817_762937638486356_4128242660743559988_n.jpg', 'images (5).jpg', 'Tutor', NULL, NULL),
(9, 'm', '$2y$10$0j9GkK632TY3H5Zxzd6Bk.gr8qVqfR5ZoVz6h0bSJQqjkM7FC.S/S', 'mm@gmail.com', 'Business', 'Economics', 'Microeconomics', NULL, 'Chiang Rai', '66abaa90e963e-images.jpg', 'images (5).jpg', 'Tutor', 14.974762348542928, 102.09829956293106),
(10, 'DDD', '$2y$10$.De8mjnJ4NBAJkeua5Y41.qLRZRZm0P90K1UZAhYNoV.bzWapyId.', 'DDD@gmail.com', 'Language', 'Thai', 'Grammar', NULL, 'Bangkok', '336666817_762937638486356_4128242660743559988_n.jpg', 'images (5).jpg', 'Tutor', NULL, NULL),
(11, 'go', '$2y$10$hc6oHVPlarQLKgE5WdmpbuQSVwyvA//Fy1Dt23/b0ppaUfTEZh5Ja', 'go@gmail.com', 'Computer', 'Programming', 'Java', NULL, 'Bangkok', '336666817_762937638486356_4128242660743559988_n.jpg', 'images (5).jpg', 'Tutor', NULL, NULL),
(12, 'js', '$2y$10$dpQ1Qx3CEgvb9jngt/lS8.HlyWdqeXutdJPXY3kllkiRwKBLoWd36', 'js@gmail.com', 'Language', 'English', 'Grammar', NULL, 'Bangkok', '426580967_3759426214293178_6173174797507677249_n.jpg', 'images (3).jpg', 'Tutor', NULL, NULL),
(13, 'Pathomphong Bunkue', '$2y$10$q6fRcWbOsbkAKJ8l3yN/6ONT9F6zCucB3f5Bu0Zcb7VeE/qpOV22y', 'PP@gmail.com', 'Programmer ', 'Algebra', 'Equations', 'มัธยม4-6', '67W2+MR6, Kham Riang, Kantharawichai District, Maha Sarakham 44150, Thailand', '66e1d52014abb-1000007947.webp', 'images (5).jpg', 'Tutor', 16.246610014152424, 103.25201891362667),
(14, 'FBI', '$2y$10$wxHtQmQ8Cxh663jy6jCBJuCGJfPa1XGjb8KoopYBe680TIljEvi0i', 'f@gmail.com', 'Computer', 'Data Science', 'Data Analysis', 'ป.ตรี', 'Roi Et', 'images (1).jpg', 'images (5).jpg', 'Tutor', 16.19855634607197, 103.26404560357332),
(15, 'agg', '$2y$10$rGarZjho00xvNRmI5GydRuY2ycbrKQoNEIwCyX/9mE47MByRrkCLO', 'agg@gmail.com', 'Math', 'Algebra', 'Equations', 'ป.ตรี', 'Bangkok', '', '1000007674.jpg', 'Tutor', NULL, NULL),
(24, 'ไอซ์', '$2y$10$puai5TsZhxtlvnITSNoZyODtFxVw87A0L.9/699cJnOU6lMqMuEIC', 'e@gmail.com', 'Math', 'Algebra', 'Equations', 'ปวส', '262 ม.4 ท่าขอนยาง Tambon Tha Khon Yang, Amphoe Kantharawichai, Chang Wat Maha Sarakham 44150, Thailand', '1000007781.png', '0366eaf3-38fe-4ee0-9321-b2df54091157-1_all_195012.jpg', 'Tutor', NULL, NULL),
(25, 'ไอซ์', '$2y$10$TuzY9wpqP/L5PSP6sW5V2uSZnVxBeVIvUHTVXK5yVAz56CyPrej0O', 'qw@gmail.com', 'Math', 'Algebra', 'Equations', 'ปวส', '262 ม.4 ท่าขอนยาง Tambon Tha Khon Yang, Amphoe Kantharawichai, Chang Wat Maha Sarakham 44150, Thailand', '1000007781.png', '0366eaf3-38fe-4ee0-9321-b2df54091157-1_all_195012.jpg', 'Tutor', NULL, NULL),
(26, 'r', '$2y$10$jZED42gJoZ7gGpQbpQQ0G.56Pkg56KvwTFUh/jkifxIPVTqgyD.F2', 'r@gmail.com', 'Language', 'Thai', 'Grammar', 'ปวช', '262 ม.4 ท่าขอนยาง Tambon Tha Khon Yang, Amphoe Kantharawichai, Chang Wat Maha Sarakham 44150, Thailand', '66e33c5f7cd4b-1000007476.webp', '1000008108.jpg', 'Tutor', NULL, NULL),
(27, 'r', '$2y$10$VMQiTmoNs4pmSKnXpMc.A.jIc2ScWKp5p1TAnyGY3K2UV3AQYf7Oy', 'LOL@gmail.com', 'Language', 'Thai', 'Grammar', 'ปวช', '262 ม.4 ท่าขอนยาง Tambon Tha Khon Yang, Amphoe Kantharawichai, Chang Wat Maha Sarakham 44150, Thailand', '66e33c5f7cd4b-1000007476.webp', '1000008108.jpg', 'Tutor', 16.2348647, 103.2698138),
(28, 'เพชรณภา', '$2y$10$kkwFBsYmiE3gKH5dxkvQz.xdSwtxYryDr3ESvCUNIY59EcGa9Jzh2', 'gg@gmail.com', 'Computer', 'Data Science', 'Machine Learning', 'ปวส', '262 ม.4 ท่าขอนยาง Tambon Tha Khon Yang, Amphoe Kantharawichai, Chang Wat Maha Sarakham 44150, Thailand', '0366eaf3-38fe-4ee0-9321-b2df54091157-1_all_195584.jpg', '0366eaf3-38fe-4ee0-9321-b2df54091157-1_all_195012.jpg', 'Tutor', 16.234879, 103.2698051);

-- --------------------------------------------------------

--
-- Table structure for table `tutor_schedule`
--

CREATE TABLE `tutor_schedule` (
  `id` int(11) NOT NULL,
  `tutor` varchar(100) NOT NULL,
  `date` date NOT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  `hourly_rate` decimal(10,2) NOT NULL,
  `is_not_teaching` varchar(255) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tutor_schedule`
--

INSERT INTO `tutor_schedule` (`id`, `tutor`, `date`, `start_time`, `end_time`, `hourly_rate`, `is_not_teaching`) VALUES
(10, 'Pathomphong Bunkue', '2024-10-23', '12:04:00', '16:04:00', 100.00, 'ไม่รับติว'),
(11, 'Pathomphong Bunkue', '2024-10-20', '12:04:00', '16:04:00', 100.00, 'ไม่รับติว'),
(12, 'Pathomphong Bunkue', '2024-10-27', '00:00:00', '00:00:00', 0.00, 'ไม่รับติว'),
(13, 'Pathomphong Bunkue', '2024-10-31', '12:07:00', '00:07:00', 100.00, 'ไม่รับติว'),
(14, 'Pathomphong Bunkue', '2024-10-30', '00:00:00', '00:00:00', 0.00, 'ไม่รับติว'),
(15, 'Pathomphong Bunkue', '2024-10-29', '00:00:00', '00:00:00', 0.00, 'ไม่รับติว'),
(16, 'Pathomphong Bunkue', '2024-10-28', '12:00:00', '17:00:00', 100.00, 'ไม่รับติว'),
(17, 'Pathomphong Bunkue', '2024-10-26', '12:00:00', '17:00:00', 100.00, 'รับติวเฉพาะเวลา'),
(18, 'Pathomphong Bunkue', '2024-09-23', '12:22:00', '04:22:00', 100.00, 'รับติวเฉพาะเวลา'),
(19, 'Pathomphong Bunkue', '2024-10-25', '12:00:00', '18:00:00', 100.00, 'รับติวเฉพาะเวลา'),
(20, 'Pathomphong Bunkue', '2024-09-30', '12:08:00', '16:08:00', 200.00, 'รับติวเฉพาะเวลา');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `favorite_tutors`
--
ALTER TABLE `favorite_tutors`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `messages`
--
ALTER TABLE `messages`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `port_messages`
--
ALTER TABLE `port_messages`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `requests`
--
ALTER TABLE `requests`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `reviews`
--
ALTER TABLE `reviews`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `students`
--
ALTER TABLE `students`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tutoring_sessions`
--
ALTER TABLE `tutoring_sessions`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tutors`
--
ALTER TABLE `tutors`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `tutor_schedule`
--
ALTER TABLE `tutor_schedule`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `favorite_tutors`
--
ALTER TABLE `favorite_tutors`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=41;

--
-- AUTO_INCREMENT for table `messages`
--
ALTER TABLE `messages`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=272;

--
-- AUTO_INCREMENT for table `notifications`
--
ALTER TABLE `notifications`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=132;

--
-- AUTO_INCREMENT for table `port_messages`
--
ALTER TABLE `port_messages`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `requests`
--
ALTER TABLE `requests`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=49;

--
-- AUTO_INCREMENT for table `reviews`
--
ALTER TABLE `reviews`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=48;

--
-- AUTO_INCREMENT for table `students`
--
ALTER TABLE `students`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT for table `tutoring_sessions`
--
ALTER TABLE `tutoring_sessions`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=190;

--
-- AUTO_INCREMENT for table `tutors`
--
ALTER TABLE `tutors`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=29;

--
-- AUTO_INCREMENT for table `tutor_schedule`
--
ALTER TABLE `tutor_schedule`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
