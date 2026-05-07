-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: May 08, 2026 at 12:05 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `real_estate_portal_db`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `AddOrUpdateUser` (IN `rep_userId` INT, IN `rep_userName` VARCHAR(50), IN `rep_contactInfo` VARCHAR(200), IN `rep_passwordHash` VARCHAR(255), IN `rep_userType` ENUM('agent','buyer','renter'))   BEGIN
    IF rep_userId IS NULL THEN
        INSERT INTO Users (userName, contactInfo, passwordHash, userType)
        VALUES (rep_userName, rep_contactInfo, rep_passwordHash, rep_userType);
    ELSE
        UPDATE Users
        SET userName = rep_userName,
            contactInfo = rep_contactInfo,
            passwordHash = rep_passwordHash,
            userType = rep_userType
        WHERE userID = rep_userId;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ProcessTransaction` (IN `rep_propertyId` INT, IN `rep_userId` INT, IN `rep_type` ENUM('sale','rental'), IN `rep_amount` DECIMAL(12,2))   BEGIN
    INSERT INTO Transactions (propertyId, userId, transactionType, transactionDate, amount)
    VALUES (rep_propertyId, rep_userId, rep_type, NOW(), rep_amount);

    IF rep_type = 'sale' THEN
        UPDATE Properties
        SET status = 'sold'
        WHERE propertyID = rep_propertyId;
    ELSE
        UPDATE Properties
        SET status = 'rented'
        WHERE propertyID = rep_propertyId;
    END IF;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `favorites`
--

CREATE TABLE `favorites` (
  `favoriteId` int(11) NOT NULL,
  `userId` int(11) DEFAULT NULL,
  `propertyId` int(11) DEFAULT NULL,
  `savedDate` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `favorites`
--

INSERT INTO `favorites` (`favoriteId`, `userId`, `propertyId`, `savedDate`) VALUES
(1, 2, 1, '2026-05-04 14:35:38'),
(2, 3, 2, '2026-05-04 14:35:38'),
(3, 2, 3, '2026-05-04 14:35:38');

-- --------------------------------------------------------

--
-- Table structure for table `inquiries`
--

CREATE TABLE `inquiries` (
  `inquiryID` int(11) NOT NULL,
  `userId` int(11) DEFAULT NULL,
  `propertyId` int(11) DEFAULT NULL,
  `message` varchar(255) DEFAULT NULL,
  `inquiryDate` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `inquiries`
--

INSERT INTO `inquiries` (`inquiryID`, `userId`, `propertyId`, `message`, `inquiryDate`) VALUES
(1, 2, 1, 'Is this available?', '2026-05-04 14:35:38'),
(2, 3, 2, 'Can I schedule a viewing?', '2026-05-04 14:35:38'),
(3, 2, 3, 'What is included?', '2026-05-04 14:35:38'),
(4, 4, 1, 'I am interested in this property. Do you know if it\'s available?', '2026-05-06 14:05:42'),
(5, 4, 1, 'I am interested in this property. Do you know if it\'s available?', '2026-05-07 12:48:16'),
(6, 4, 1, 'I am interested in this property. Do you know if it\'s available?', '2026-05-07 13:38:42'),
(7, 4, 1, 'I am interested in this property. Do you know if it\'s available?', '2026-05-07 18:03:41');

-- --------------------------------------------------------

--
-- Table structure for table `properties`
--

CREATE TABLE `properties` (
  `propertyID` int(11) NOT NULL,
  `title` varchar(100) NOT NULL,
  `propertyType` varchar(50) NOT NULL,
  `address` varchar(200) NOT NULL,
  `city` varchar(100) NOT NULL,
  `price` decimal(12,2) NOT NULL,
  `status` enum('available','sold','rented') DEFAULT 'available',
  `agentID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `properties`
--

INSERT INTO `properties` (`propertyID`, `title`, `propertyType`, `address`, `city`, `price`, `status`, `agentID`) VALUES
(1, 'Modern Apartment', 'Apartment', '123 Main St', 'New York', 2500.00, 'available', 1),
(2, 'Luxury House', 'House', '456 Park Ave', 'New York', 950000.00, 'available', 1),
(3, 'Epic Studio', 'Studio', '789 Broadway', 'New York', 1800.00, 'available', 1);

-- --------------------------------------------------------

--
-- Stand-in structure for view `propertylistingview`
-- (See below for the actual view)
--
CREATE TABLE `propertylistingview` (
`title` varchar(100)
,`propertyType` varchar(50)
,`city` varchar(100)
,`price` decimal(12,2)
,`status` enum('available','sold','rented')
,`agentName` varchar(50)
);

-- --------------------------------------------------------

--
-- Table structure for table `transactions`
--

CREATE TABLE `transactions` (
  `transactionId` int(11) NOT NULL,
  `propertyId` int(11) DEFAULT NULL,
  `userId` int(11) DEFAULT NULL,
  `transactionType` enum('sale','rental') DEFAULT NULL,
  `transactionDate` datetime DEFAULT NULL,
  `amount` decimal(12,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `transactions`
--

INSERT INTO `transactions` (`transactionId`, `propertyId`, `userId`, `transactionType`, `transactionDate`, `amount`) VALUES
(1, 2, 2, 'sale', '2026-05-04 14:35:38', 950000.00),
(2, 3, 3, 'rental', '2026-05-04 14:35:38', 1800.00),
(3, 1, 2, 'rental', '2026-05-04 14:35:38', 2500.00);

--
-- Triggers `transactions`
--
DELIMITER $$
CREATE TRIGGER `AfterTransactionInsert` AFTER INSERT ON `transactions` FOR EACH ROW BEGIN
    IF NEW.transactionType = 'sale' THEN
        UPDATE Properties
        SET status = 'sold'
        WHERE propertyID = NEW.propertyId;
    ELSE
        UPDATE Properties
        SET status = 'rented'
        WHERE propertyID = NEW.propertyId;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `userID` int(11) NOT NULL,
  `userName` varchar(50) NOT NULL,
  `contactInfo` varchar(200) DEFAULT NULL,
  `passwordHash` varchar(255) NOT NULL,
  `userType` enum('agent','buyer','renter') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`userID`, `userName`, `contactInfo`, `passwordHash`, `userType`) VALUES
(1, 'agent1', 'agent1@email.com', 'test123', 'agent'),
(2, 'buyer1', 'buyer1@email.com', 'test123', 'buyer'),
(3, 'renter1', 'renter1@email.com', 'test123', 'renter'),
(4, 'testuser', 'user123', '$2y$10$R2/rMrFJ7kIF8/qsxdU7T.WF5KyvUnns2pOfGk46HG2jj6/Q/ZQeq', 'buyer'),
(7, 'agent2', 'agent2', '$2y$10$ICcJiuJei6YvCpAyeWnhrevtHzyVBTMqpsaiAH2KQtoLdCqrUZhoy', 'agent');

-- --------------------------------------------------------

--
-- Structure for view `propertylistingview`
--
DROP TABLE IF EXISTS `propertylistingview`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `propertylistingview`  AS SELECT `p`.`title` AS `title`, `p`.`propertyType` AS `propertyType`, `p`.`city` AS `city`, `p`.`price` AS `price`, `p`.`status` AS `status`, `u`.`userName` AS `agentName` FROM (`properties` `p` join `users` `u` on(`p`.`agentID` = `u`.`userID`)) ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `favorites`
--
ALTER TABLE `favorites`
  ADD PRIMARY KEY (`favoriteId`),
  ADD KEY `userId` (`userId`),
  ADD KEY `propertyId` (`propertyId`);

--
-- Indexes for table `inquiries`
--
ALTER TABLE `inquiries`
  ADD PRIMARY KEY (`inquiryID`),
  ADD KEY `userId` (`userId`),
  ADD KEY `propertyId` (`propertyId`);

--
-- Indexes for table `properties`
--
ALTER TABLE `properties`
  ADD PRIMARY KEY (`propertyID`),
  ADD KEY `agentID` (`agentID`);

--
-- Indexes for table `transactions`
--
ALTER TABLE `transactions`
  ADD PRIMARY KEY (`transactionId`),
  ADD KEY `propertyId` (`propertyId`),
  ADD KEY `userId` (`userId`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`userID`),
  ADD UNIQUE KEY `userName` (`userName`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `favorites`
--
ALTER TABLE `favorites`
  MODIFY `favoriteId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `inquiries`
--
ALTER TABLE `inquiries`
  MODIFY `inquiryID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `properties`
--
ALTER TABLE `properties`
  MODIFY `propertyID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `transactions`
--
ALTER TABLE `transactions`
  MODIFY `transactionId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `userID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `favorites`
--
ALTER TABLE `favorites`
  ADD CONSTRAINT `favorites_ibfk_1` FOREIGN KEY (`userId`) REFERENCES `users` (`userID`),
  ADD CONSTRAINT `favorites_ibfk_2` FOREIGN KEY (`propertyId`) REFERENCES `properties` (`propertyID`);

--
-- Constraints for table `inquiries`
--
ALTER TABLE `inquiries`
  ADD CONSTRAINT `inquiries_ibfk_1` FOREIGN KEY (`userId`) REFERENCES `users` (`userID`),
  ADD CONSTRAINT `inquiries_ibfk_2` FOREIGN KEY (`propertyId`) REFERENCES `properties` (`propertyID`);

--
-- Constraints for table `properties`
--
ALTER TABLE `properties`
  ADD CONSTRAINT `properties_ibfk_1` FOREIGN KEY (`agentID`) REFERENCES `users` (`userID`);

--
-- Constraints for table `transactions`
--
ALTER TABLE `transactions`
  ADD CONSTRAINT `transactions_ibfk_1` FOREIGN KEY (`propertyId`) REFERENCES `properties` (`propertyID`),
  ADD CONSTRAINT `transactions_ibfk_2` FOREIGN KEY (`userId`) REFERENCES `users` (`userID`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
