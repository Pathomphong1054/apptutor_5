-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Aug 09, 2024 at 10:57 PM
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
-- Table structure for table `favorites`
--

CREATE TABLE `favorites` (
  `id` int(11) NOT NULL,
  `student_id` int(11) NOT NULL,
  `tutor_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `favorites`
--

INSERT INTO `favorites` (`id`, `student_id`, `tutor_id`) VALUES
(2, 0, 0),
(16, 2, 3);

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
  `session_id` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `messages`
--

INSERT INTO `messages` (`id`, `sender`, `recipient`, `message`, `timestamp`, `latitude`, `longitude`, `session_id`) VALUES
(8, 'z', 'n', 'A new tutoring session has been scheduled with you on 2024-08-19 00:00:00.000Z\n  from 1:00 PM to 3:00 PM.\n  The rate is 1 people at 360.00 THB.', '2024-08-09 20:56:04', NULL, NULL, '3'),
(9, 'z', 'n', 'hello', '2024-08-09 20:56:19', NULL, NULL, '3');

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
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `notifications`
--

INSERT INTO `notifications` (`id`, `sender`, `recipient`, `message`, `role`, `type`, `created_at`) VALUES
(1, 'php', 'a', 'คุณมีคำขอติวใหม่', 'student', '', '2024-08-09 16:47:57'),
(2, 'a', 'b', 'hello', 'student', 'chat', '2024-08-09 16:49:26'),
(3, 'b', 'a', 'คุณมีคำขอติวใหม่', 'student', '', '2024-08-09 16:57:06'),
(4, 'java', 'b', 'hello', 'student', 'chat', '2024-08-09 17:00:45'),
(5, 'php', 'java', 'คุณมีคำขอติวใหม่', 'student', '', '2024-08-09 17:11:52'),
(6, 'b', 'java', 'hello', 'tutor', 'chat', '2024-08-09 17:12:36'),
(7, 'b', 'a', 'hello', 'tutor', 'chat', '2024-08-09 17:12:41'),
(8, 'php', 'java', 'คุณมีคำขอติวใหม่', 'student', '', '2024-08-09 17:41:39'),
(9, 'ss', 'java', 'คุณมีคำขอติวใหม่', 'student', '', '2024-08-09 19:08:56'),
(10, 'ss', 'java', 'คุณมีคำขอติวใหม่', 'student', '', '2024-08-09 19:09:08'),
(11, 'ss', 'z', 'คุณมีคำขอติวใหม่', 'student', '', '2024-08-09 19:14:55'),
(12, 'ss', 'z', 'คุณมีคำขอติวใหม่', 'student', '', '2024-08-09 19:15:22'),
(13, 'z', 'ss', 'hello', 'student', 'chat', '2024-08-09 19:50:54'),
(14, 'z', 'n', 'hello', 'student', 'chat', '2024-08-09 20:56:19');

-- --------------------------------------------------------

--
-- Table structure for table `port_messages`
--

CREATE TABLE `port_messages` (
  `id` int(11) UNSIGNED NOT NULL,
  `userName` varchar(255) NOT NULL,
  `profileImageUrl` varchar(255) NOT NULL,
  `message` text NOT NULL,
  `dateTime` datetime NOT NULL,
  `location` varchar(255) NOT NULL,
  `subject` varchar(255) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `port_messages`
--

INSERT INTO `port_messages` (`id`, `userName`, `profileImageUrl`, `message`, `dateTime`, `location`, `subject`, `created_at`) VALUES
(1, 'a', 'http://10.5.50.82/tutoring_app/uploads/default_profile.jpg', 'gggg', '0000-00-00 00:00:00', 'ggg', 'Programming', '2024-08-09 16:28:43'),
(2, 'java', 'images/default_profile.jpg', 'i', '0000-00-00 00:00:00', 'y', 'Programming', '2024-08-09 17:01:27'),
(3, 'z', 'http://10.5.50.82/tutoring_app/uploads/default_profile.jpg', 'hello', '0000-00-00 00:00:00', 'sdf', 'Algebra', '2024-08-09 19:14:14');

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
(3, 'php', 'java', 'คุณมีคำขอติวใหม่', 0, '2024-08-09 15:09:11');

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
(32, 'php', 3, 'f', '2024-08-09 20:51:22');

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
  `profile_images` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Dumping data for table `students`
--

INSERT INTO `students` (`id`, `role`, `name`, `email`, `password`, `address`, `profile_images`) VALUES
(2, 'student', 'a', 'a@gmail.com', '$2y$10$tsv4srFgirKdWetokkbVyuN8kaJcgvrh7Um3t7xRl9AVf3Srebipq', 'Bangkok', '66abaa90e963e-images.jpg'),
(3, 'student', 'java', 'java@gmail.com', '$2y$10$ov0aAjadkB.FdtjgQVc4A.G2mHCsvc6DB4f8W29fi/aFQ4qIiWFvG', 'Bangkok', '336666817_762937638486356_4128242660743559988_n.jpg'),
(4, 'student', 'F', 'f@gmail.com', '$2y$10$gue7n0G.JRo.MWxtCFpILuGTOX2hRdZqOcf7n2l1mohCiP3.b6b4y', 'Bangkok', 'images (1).jpg'),
(5, 'student', 'z', 'zz@gmail.com', '$2y$10$WZUawOLcPKT3FG2138lAgOiDPN8fHmZZ.UrXdH6sCRuowK6nF2Mf6', 'Bangkok', '66abaa90e963e-images.jpg');

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
  `rate` decimal(10,2) NOT NULL,
  `status` enum('pending','confirmed','completed','cancelled') NOT NULL DEFAULT 'pending',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tutoring_sessions`
--

INSERT INTO `tutoring_sessions` (`id`, `student`, `tutor`, `date`, `start_time`, `end_time`, `rate`, `status`, `created_at`) VALUES
(1, 'a', 'b', '2024-08-10', '01:00:00', '03:00:00', 1.00, 'pending', '2024-08-09 16:49:16'),
(2, 'java', 'b', '2024-08-12', '01:00:00', '03:00:00', 1.00, 'pending', '2024-08-09 17:00:30'),
(3, 'z', 'n', '2024-08-19', '01:00:00', '03:00:00', 1.00, 'pending', '2024-08-09 20:56:04');

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
  `address` varchar(255) DEFAULT NULL,
  `profile_images` varchar(255) DEFAULT NULL,
  `resumes_images` varchar(255) DEFAULT NULL,
  `role` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Dumping data for table `tutors`
--

INSERT INTO `tutors` (`id`, `name`, `password`, `email`, `category`, `subject`, `topic`, `address`, `profile_images`, `resumes_images`, `role`) VALUES
(7, 'php', '$2y$10$sz5w6slnkFswZDfaAvFwAeI8qg2Vaklz9WXaqUUdMhQOuEQ6j3BbO', 'php@gmail.com', 'Computer', 'Programming', 'Java', 'Bangkok', 'images (1).jpg', 'images (5).jpg', 'Tutor'),
(8, 'n', '$2y$10$vYZc7NWmQxepIZOvlrr4PuKR3E1fegM4Z7loUvIpHd4ipPbX51bk6', 'n@gmail.com', 'Computer', 'Data Science', 'Data Analysis', 'Bangkok', '336666817_762937638486356_4128242660743559988_n.jpg', 'images (5).jpg', 'Tutor');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `favorites`
--
ALTER TABLE `favorites`
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
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `favorites`
--
ALTER TABLE `favorites`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT for table `messages`
--
ALTER TABLE `messages`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `notifications`
--
ALTER TABLE `notifications`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `port_messages`
--
ALTER TABLE `port_messages`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `requests`
--
ALTER TABLE `requests`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `reviews`
--
ALTER TABLE `reviews`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=33;

--
-- AUTO_INCREMENT for table `students`
--
ALTER TABLE `students`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `tutoring_sessions`
--
ALTER TABLE `tutoring_sessions`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `tutors`
--
ALTER TABLE `tutors`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
