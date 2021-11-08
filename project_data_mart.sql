-- phpMyAdmin SQL Dump
-- version 5.1.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Erstellungszeit: 08. Nov 2021 um 08:42
-- Server-Version: 10.4.18-MariaDB
-- PHP-Version: 7.3.27

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Datenbank: `project data mart`
--

DELIMITER $$
--
-- Prozeduren
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `AccommodationCreation` (IN `host_email_adress` VARCHAR(100), IN `host_phone_number` VARCHAR(100), IN `accommodation_name` VARCHAR(100), IN `accommodation_description` TEXT, IN `accommodation_type` VARCHAR(100), IN `accommodation_rules` VARCHAR(100), IN `location_country` VARCHAR(100), IN `location_region` VARCHAR(100), IN `location_town` VARCHAR(100), IN `location_street` VARCHAR(100), IN `location_house_number` VARCHAR(100), IN `location_ZIPcode` VARCHAR(100), IN `location_description` TEXT, IN `initial_price` DECIMAL(20,2), IN `number_of_nights` DECIMAL(2,0), IN `discount` DECIMAL(3,0), IN `interior_description` TEXT, OUT `message` VARCHAR(128))  BEGIN
    -- Declare variables
    DECLARE host_id INT;
    DECLARE accommodation_id INT;

    -- Check if the exact location of the accommodation exists
    IF NOT EXISTS(SELECT * FROM locations WHERE locations.LocationCountry = location_country AND locations.LocationRegion = location_region AND locations.LocationTown = location_town AND locations.LocationStreet = location_street AND locations.LocationHouseNumber = location_house_number AND locations.LocationZIPCode = location_ZIPcode) THEN

        -- Check if the host exists
        IF EXISTS(SELECT * FROM hostcontacts WHERE hostcontacts.HostEmailAdress = host_email_adress AND hostcontacts.HostPhoneNumber = host_phone_number) THEN

            -- Query the HostID
            SELECT HostID INTO host_id FROM hostcontacts WHERE hostcontacts.HostEmailAdress = host_email_adress AND hostcontacts.HostPhoneNumber = host_phone_number;

                -- Create the Accommodation
                START TRANSACTION;
                    -- Insert the accommodation information into the accommodations table
                    INSERT INTO accommodations (AccommodationName, AccommodationDescription, AccommodationType, AccommodationRules, HostID) VALUES (accommodation_name, accommodation_description, accommodation_type, accommodation_rules, host_id);
                    -- Query the AccommodationID of the accommodation registration
                    SELECT LAST_INSERT_ID() INTO accommodation_id;

                    -- Insert location information in the locations table
                    INSERT INTO locations (LocationCountry,LocationRegion,LocationTown,LocationStreet,LocationHouseNumber,LocationZIPCode,LocationDescription,AccommodationID) VALUES (location_country, location_region, location_town, location_street, location_house_number, location_ZIPcode, location_description, accommodation_id);

                    -- Insert price information in the price table
                    INSERT INTO prices (IntialPrice,NumberOfNights,Discount,TotalPrice,AccommodationID) VALUES (initial_price, number_of_nights, discount, initial_price/number_of_nights - initial_price/number_of_nights*discount/100 ,accommodation_id);

                    -- Insert the interior information in the interior table
                    INSERT INTO interiors (InteriorDescription,RoomNumber,AccommodationID) VALUES (interior_description,0,accommodation_id);

                    SET message = "Accommodation creation success";
                COMMIT;

        -- Host does not exist
        ELSE 
            SET message = 'Accommodation creation failed - host does not exist';
        END IF;
    -- Location already already exists
    ELSE 
        SET message = 'Accommodation creation failed - location of the accommodation already exists';
    END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `AccommodationReview` (IN `guest_email_adress` VARCHAR(100), IN `accommodation_name` VARCHAR(100), IN `accommodation_score` DECIMAL(1,0), IN `accommodation_text` TEXT, OUT `message` VARCHAR(128))  BEGIN

    -- Declare Variables
    DECLARE guest_id INT;
    DECLARE accommodation_id INT;

    -- Check if the accommodation exists
    IF EXISTS(SELECT * FROM accommodations WHERE accommodations.AccommodationName = accommodation_name) THEN

        -- Query the AccommodationID
        SELECT AccommodationID INTO accommodation_id FROM accommodations WHERE accommodations.AccommodationName = accommodation_name;

        -- Check if the guest exists
        IF EXISTS(SELECT * FROM guestcontacts WHERE guestcontacts.GuestEmailAdress = guest_email_adress) THEN

            -- Query the GuestID
            SELECT GuestID INTO guest_id FROM guestcontacts WHERE guestcontacts.GuestEmailAdress = guest_email_adress;

             -- Check if the score is a number between 1 and 5
            IF accommodation_score BETWEEN 1 AND 5 THEN

                -- Create the host review
                START TRANSACTION;
                    -- Insert the information in the hostreviews table
                    INSERT INTO accommodationreviews (AccommodationScore,AccommodationText,AccommodationReviewDate,GuestID,AccommodationID) VALUES (accommodation_score,accommodation_text,CURRENT_DATE,guest_id,accommodation_id);

                        SET message = "Review was successfull";
                    COMMIT;
            -- Score is not a number between 1 and 5
            ELSE 
                SET message = 'Review failed - the score must be between 1 and 5';
            END IF;
        -- Guest does not exist
        ELSE 
            SET message = 'Review failed - guest not found';
        END IF;            
    -- Accommodation does not exist
    ELSE 
        SET message = 'Review failed - accommodation not found';
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `BathroomCreation` (IN `accommodation_name` VARCHAR(100), IN `bathroom_name` VARCHAR(100), IN `bathroom_description` TEXT, OUT `message` VARCHAR(128))  BEGIN
    -- Declare variables
    DECLARE accommodation_id INT;
    DECLARE interior_id INT;

    -- Check if the accommodation exists
    IF EXISTS(SELECT * FROM accommodations WHERE accommodations.AccommodationName = accommodation_name) THEN

        -- Query the AccommodationID
        SELECT AccommodationID INTO accommodation_id FROM accommodations WHERE accommodations.AccommodationName = accommodation_name;

        -- Check if the interior exists
        IF EXISTS(SELECT * FROM interiors WHERE interiors.AccommodationID = accommodation_id) THEN

            -- Query the interiorID
            SELECT InteriorID INTO interior_id FROM interiors WHERE interiors.AccommodationID = accommodation_id;

            -- Create the bathroom
            START TRANSACTION;
                -- Insert the bathroom data in the bathrooms table
                INSERT INTO bathrooms (BathroomName,BathroomDescription,InteriorID) VALUES (bathroom_name, bathroom_description,interior_id);

                -- Change the number of rooms the interior has +1
                UPDATE interiors SET RoomNumber = RoomNumber + 1 WHERE interiors.AccommodationID = accommodation_id;

                SET message = "Bathroom creation success";
            COMMIT;

        -- Interior does not exist
        ELSE 
            SET message = 'Bathroom creation failed - Interior does not exist';
        END IF;

    -- Accommodation does not exist
    ELSE 
        SET message = 'Bathroom creation failed - accommodation does not exist';
    END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `BedroomCreation` (IN `accommodation_name` VARCHAR(100), IN `bedroom_name` VARCHAR(100), IN `bedroom_beds_number` DECIMAL(2,0), IN `bedroom_description` TEXT, OUT `message` VARCHAR(128))  BEGIN
    -- Declare variables
    DECLARE accommodation_id INT;
    DECLARE interior_id INT;

    -- Check if the accommodation exists
    IF EXISTS(SELECT * FROM accommodations WHERE accommodations.AccommodationName = accommodation_name) THEN

        -- Query the AccommodationID
        SELECT AccommodationID INTO accommodation_id FROM accommodations WHERE accommodations.AccommodationName = accommodation_name;

        -- Check if the interior exists
        IF EXISTS(SELECT * FROM interiors WHERE interiors.AccommodationID = accommodation_id) THEN

            -- Query the interiorID
            SELECT InteriorID INTO interior_id FROM interiors WHERE interiors.AccommodationID = accommodation_id;

            -- Create the bedroom
            START TRANSACTION;
                -- Insert the bedroom data in the bedrooms table
                INSERT INTO bedrooms (BedroomName,BedsNumber,BedroomDescription,InteriorID) VALUES (bedroom_name,bedroom_beds_number,bedroom_description,interior_id);

                -- Change the number of rooms the interior has +1
                UPDATE interiors SET RoomNumber = RoomNumber + 1 WHERE interiors.AccommodationID = accommodation_id;

                SET message = "Bedroom creation success";
            COMMIT;

        -- Interior does not exist
        ELSE 
            SET message = 'Bedroom creation failed - Interior does not exist';
        END IF;

    -- Accommodation does not exist
    ELSE 
        SET message = 'Bedroom creation failed - accommodation does not exist';
    END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `DeleteAccommodation` (IN `host_email_adress` VARCHAR(100), IN `host_phone_number` VARCHAR(100), IN `accommodation_name` VARCHAR(100), OUT `message` VARCHAR(128))  BEGIN

    -- Declare Variables
    DECLARE host_id INT;
    DECLARE accommodation_id INT;

    -- Check if the host email and phone number exists
    IF EXISTS(SELECT * FROM hostcontacts WHERE hostcontacts.HostEmailAdress = host_email_adress AND hostcontacts.HostPhoneNumber = host_phone_number) THEN

        -- Query the HostID
        SELECT HostID INTO host_id FROM hostcontacts WHERE hostcontacts.HostEmailAdress = host_email_adress AND hostcontacts.HostPhoneNumber = host_phone_number;

        -- Check if the accommodation exists
        IF EXISTS(SELECT * FROM accommodations WHERE accommodations.AccommodationName = accommodation_name) THEN

            -- Query the AccommodationID
            SELECT AccommodationID INTO accommodation_id FROM accommodations WHERE accommodations.AccommodationName = accommodation_name;

            -- Check if there are open or current reservations
            IF NOT EXISTS(SELECT * FROM reservations WHERE reservations.AccommodationID = accommodation_id AND reservations.CheckOutDate >= CURRENT_DATE) THEN

                -- Check if the host has at least 1 other accommodation
                IF 1 < (SELECT COUNT(*) FROM accommodations WHERE accommodations.HostID = host_id GROUP BY accommodations.HostID) THEN

                    -- Start the deletion process of the accommodation table and all cascading tables
                    START TRANSACTION;
                        -- Delete the accommodation from the accommodations table
                        DELETE FROM accommodations WHERE accommodations.AccommodationID = accommodation_id;

                        SET message = "Accommodation deletion was successfull";
                    COMMIT;
                -- No other accommodation
                ELSE
                    SET message = 'Accommodation deletion failed - A host must have at least one accommodation';
                END IF;        
            -- Open or current reservations
            ELSE
                SET message = 'Accommodation deletion failed - There are open or current reservations';
            END IF;
        -- Accommodation does not exist
        ELSE
            SET message = 'Accommodation deletion failed - accommodation does not exist';
        END IF;
    -- Invalid email or phone number
    ELSE
    	SET message = 'Accommodation deletion failed - invalid email or phone number';
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `DeleteAccommodationReview` (IN `guest_email_adress` VARCHAR(100), IN `accommodation_name` VARCHAR(100), OUT `message` VARCHAR(128))  BEGIN

    -- Declare Variables
    DECLARE guest_id INT;
    DECLARE accommodation_id INT;

    -- Check if the guest email exists
    IF EXISTS(SELECT * FROM guestcontacts WHERE guestcontacts.GuestEmailAdress = guest_email_adress) THEN

        -- Query the GuestID
        SELECT GuestID INTO guest_id FROM guestcontacts WHERE guestcontacts.GuestEmailAdress = guest_email_adress;

        -- Check if the accommodation exists
        IF EXISTS(SELECT * FROM accommodations WHERE accommodations.AccommodationName = accommodation_name) THEN

            -- Query the AccommodationID
            SELECT AccommodationID INTO accommodation_id FROM accommodations WHERE accommodations.AccommodationName = accommodation_name;

            -- Check if the review exists
            IF EXISTS(SELECT * FROM accommodationreviews WHERE accommodationreviews.GuestID = guest_id AND accommodationreviews.AccommodationID = accommodation_id) THEN

                -- Start the deletion process of the accommodation review
                START TRANSACTION;
                    -- Delete the accommodation review from the accommodationreviews table
                    DELETE FROM accommodationreviews WHERE accommodationreviews.GuestID = guest_id AND accommodationreviews.AccommodationID = accommodation_id;

                    SET message = "Accommodation review deletion was successfull";
                COMMIT; 

            -- Review does not exist
            ELSE 
                SET message = 'Review deletion failed - review does not exist';
            END IF;  
        -- Accommodation does not exist
        ELSE 
            SET message = 'Review deletion failed - accommodation does not exist';
        END IF;        
    -- Guest email does not exist
    ELSE 
        SET message = 'Review deletion failed - guest email does not exist';
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `DeleteGuestProfile` (IN `guest_email_adress` VARCHAR(100), IN `guest_phone_number` VARCHAR(100), OUT `message` VARCHAR(128))  BEGIN

    -- Declare Variables
    DECLARE guest_id INT;

    -- Check if the guest contacts exists
    IF EXISTS(SELECT * FROM guestcontacts WHERE guestcontacts.GuestEmailAdress = guest_email_adress AND guestcontacts.GuestPhoneNumber = guest_phone_number) THEN

        -- Query the GuestID
        SELECT GuestID INTO guest_id FROM guestcontacts WHERE guestcontacts.GuestEmailAdress = guest_email_adress AND guestcontacts.GuestPhoneNumber = guest_phone_number;

        -- Check if the guest exists in the guest table
        IF EXISTS(SELECT * FROM guests WHERE guests.GuestID = guest_id) THEN

            -- Check if there are open or current reservations
            IF NOT EXISTS(SELECT * FROM reservations WHERE reservations.GuestID = guest_id AND reservations.CheckOutDate >= CURRENT_DATE) THEN

                -- Start the deletion process of the guest table and all cascading tables
                START TRANSACTION;
                    -- Delete the guest from the guest table
                    DELETE FROM guests WHERE guests.GuestID = guest_id;

                    SET message = "Guest profile deletion was successfull";
                COMMIT;
            -- Open or current reservations
            ELSE
    	        SET message = 'Guest profile deletion failed - There are open or current reservations';
            END IF;
        -- Guest does not exist
        ELSE
    	    SET message = 'Guest profile deletion failed - guest does not exist';
        END IF;
    -- Invalid email or phone number
    ELSE
    	SET message = 'Guest profile deletion failed - invalid email or phone number';
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `DeleteGuestReview` (IN `guest_email_adress` VARCHAR(100), IN `host_email_adress` VARCHAR(100), OUT `message` VARCHAR(128))  BEGIN

    -- Declare Variables
    DECLARE guest_id INT;
    DECLARE host_id INT;

    -- Check if the guest email exists
    IF EXISTS(SELECT * FROM guestcontacts WHERE guestcontacts.GuestEmailAdress = guest_email_adress) THEN

        -- Query the GuestID
        SELECT GuestID INTO guest_id FROM guestcontacts WHERE guestcontacts.GuestEmailAdress = guest_email_adress;

        -- Check if the host email exists
        IF EXISTS(SELECT * FROM hostcontacts WHERE hostcontacts.HostEmailAdress = host_email_adress) THEN

            -- Query the HostID
            SELECT HostID INTO host_id FROM hostcontacts WHERE hostcontacts.HostEmailAdress = host_email_adress;

            -- Check if the review exists
            IF EXISTS(SELECT * FROM guestreviews WHERE guestreviews.HostID = host_id AND guestreviews.GuestID = guest_id) THEN

                -- Start the deletion process of the guest review
                START TRANSACTION;
                    -- Delete the guest review from the guestreviews table
                    DELETE FROM guestreviews WHERE guestreviews.HostID = host_id AND guestreviews.GuestID = guest_id;

                    SET message = "Guest review deletion was successfull";
                COMMIT; 

             -- Review does not exist
            ELSE 
                SET message = 'Review deletion failed - review does not exist';
            END IF;  
        -- Host email does not exist
        ELSE 
            SET message = 'Review deletion failed - host email does not exist';
        END IF;        
    -- Guest email does not exist
    ELSE 
        SET message = 'Review deletion failed - guest email does not exist';
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `DeleteHostProfile` (IN `host_email_adress` VARCHAR(100), IN `host_phone_number` VARCHAR(100), OUT `message` VARCHAR(128))  BEGIN

    -- Declare Variables
    DECLARE host_id INT;
    DECLARE accommodation_id INT;

    -- Check if the host email and phone number exists
    IF EXISTS(SELECT * FROM hostcontacts WHERE hostcontacts.HostEmailAdress = host_email_adress AND hostcontacts.HostPhoneNumber = host_phone_number) THEN

        -- Query the HostID
        SELECT HostID INTO host_id FROM hostcontacts WHERE hostcontacts.HostEmailAdress = host_email_adress AND hostcontacts.HostPhoneNumber = host_phone_number;

        -- Check if the host exists in the host table
        IF EXISTS(SELECT * FROM host WHERE host.HostID = host_id) THEN

            -- Check if the accommodation exists
            IF EXISTS(SELECT * FROM accommodations WHERE accommodations.HostID = host_id) THEN

                -- Query the AccommodationID
                SELECT AccommodationID INTO accommodation_id FROM accommodations WHERE accommodations.HostID = host_id;

                -- Check if there are open or current reservations
                IF NOT EXISTS(SELECT * FROM reservations WHERE reservations.AccommodationID = accommodation_id AND reservations.CheckOutDate >= CURRENT_DATE) THEN

                    -- Start the deletion process of the host table and all cascading tables
                    START TRANSACTION;
                        -- Delete the host from the host table
                        DELETE FROM host WHERE host.HostID = host_id;

                        SET message = "Host profile deletion was successfull";
                    COMMIT;

                -- Open or current reservations
                ELSE
                    SET message = 'Host profile deletion failed - There are open or current reservations';
                END IF;
            -- Accommodation does not exist
            ELSE 
                SET message = 'Host profile deletion failed - accommodation not found';
            END IF;
        -- Host does not exist
        ELSE
    	    SET message = 'Host profile deletion failed - host does not exist';
        END IF;
    -- Invalid email or phone number
    ELSE
    	SET message = 'Host profile deletion failed - invalid email or phone number';
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `DeleteHostReview` (IN `guest_email_adress` VARCHAR(100), IN `host_email_adress` VARCHAR(100), OUT `message` VARCHAR(128))  BEGIN

    -- Declare Variables
    DECLARE guest_id INT;
    DECLARE host_id INT;

    -- Check if the guest email exists
    IF EXISTS(SELECT * FROM guestcontacts WHERE guestcontacts.GuestEmailAdress = guest_email_adress) THEN

        -- Query the GuestID
        SELECT GuestID INTO guest_id FROM guestcontacts WHERE guestcontacts.GuestEmailAdress = guest_email_adress;

        -- Check if the host email exists
        IF EXISTS(SELECT * FROM hostcontacts WHERE hostcontacts.HostEmailAdress = host_email_adress) THEN

            -- Query the HostID
            SELECT HostID INTO host_id FROM hostcontacts WHERE hostcontacts.HostEmailAdress = host_email_adress;

            -- Check if the review exists
            IF EXISTS(SELECT * FROM hostreviews WHERE hostreviews.HostID = host_id AND hostreviews.GuestID = guest_id) THEN
        
                -- Start the deletion process of the host review
                START TRANSACTION;
                    -- Delete the host review from the hostreviews table
                    DELETE FROM hostreviews WHERE hostreviews.HostID = host_id AND hostreviews.GuestID = guest_id;

                    SET message = "Host review deletion was successfull";
                COMMIT;        

            -- Review does not exist
            ELSE 
                SET message = 'Review deletion failed - review does not exist';
            END IF;  
        -- Host email does not exist
        ELSE 
            SET message = 'Review deletion failed - host email does not exist';
        END IF;        
    -- Guest email does not exist
    ELSE 
        SET message = 'Review deletion failed - guest email does not exist';
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ExteriorCreation` (IN `accommodation_name` VARCHAR(100), IN `exterior_type` VARCHAR(100), IN `exterior_description` TEXT, OUT `message` VARCHAR(128))  BEGIN
    -- Declare variables
    DECLARE accommodation_id INT;

    -- Check if the accommodation exists
    IF EXISTS(SELECT * FROM accommodations WHERE accommodations.AccommodationName = accommodation_name) THEN

        -- Query the AccommodationID
        SELECT AccommodationID INTO accommodation_id FROM accommodations WHERE accommodations.AccommodationName = accommodation_name;

        -- Check if the accommodation already has an exterior
        IF NOT EXISTS(SELECT * FROM exteriors WHERE exteriors.AccommodationID = accommodation_id) THEN

            -- Create the Exterior
            START TRANSACTION;       
                -- Insert the exterior information in the exterior table
                INSERT INTO exteriors (ExteriorType,ExteriorDescription,AccommodationID) VALUES (exterior_type,exterior_description,accommodation_id);

                SET message = "Exterior creation success";
            COMMIT;

        -- Exterior already exists
        ELSE 
            SET message = 'Exterior creation failed - accommodation already has an exterior';
        END IF;
    -- Accommodation does not exist
    ELSE 
        SET message = 'Exterior creation failed - accommodation does not exists';
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GuestBooking` (IN `guest_email_adress` VARCHAR(100), IN `guest_phone_number` VARCHAR(100), IN `accommodation_name` VARCHAR(100), IN `payment_method` VARCHAR(100), IN `check_in_date` DATE, IN `check_out_date` DATE, IN `guest_number` DECIMAL(2,0), OUT `message` VARCHAR(128))  BEGIN

    -- Declare Variables
    DECLARE host_id INT;
    DECLARE guest_id INT;
    DECLARE accommodation_id INT;
    DECLARE booking_duration INT;
    DECLARE number_of_nights DECIMAL (2,0);
    DECLARE total_price DECIMAL (20,2);
    DECLARE caluclated_price DECIMAL (20,2);
    DECLARE price_id INT;
    DECLARE possible_cancellation_time DATETIME;
    DECLARE payment_id INT;


    -- Check if the accommodation exists
    IF EXISTS(SELECT * FROM accommodations WHERE accommodations.AccommodationName = accommodation_name) THEN

        -- Query the AccommodationID
        SELECT AccommodationID INTO accommodation_id FROM accommodations WHERE accommodations.AccommodationName = accommodation_name;

        -- Query the HostID
        SELECT HostID INTO host_id FROM accommodations WHERE accommodations.AccommodationName = accommodation_name;

            -- Check if the host exists
            IF EXISTS(SELECT * FROM host WHERE host.HostID = host_id) THEN

                -- Check if the guest exists
                IF EXISTS(SELECT * FROM guestcontacts WHERE guestcontacts.GuestEmailAdress = guest_email_adress AND guestcontacts.GuestPhoneNumber = guest_phone_number) THEN

                    -- Query the GuestID
                    SELECT GuestID INTO guest_id FROM guestcontacts WHERE guestcontacts.GuestEmailAdress = guest_email_adress AND guestcontacts.GuestPhoneNumber = guest_phone_number;

                    -- Check if the reservation date is in the future and the check out date is after the check in date
                    IF check_in_date < check_out_date AND check_in_date > CURRENT_DATE THEN

                        -- Check if the accommodation has already been booked
                        IF NOT EXISTS (SELECT * FROM reservations WHERE reservations.AccommodationID = accommodation_id AND check_in_date BETWEEN reservations.CheckInDate AND reservations.CheckOutDate) THEN

                            -- Check if the Payment method exists
                            IF EXISTS(SELECT * FROM paymentmethods WHERE paymentmethods.PaymentMethod = payment_method) THEN

                                -- Check if the PriceID exists
                                IF EXISTS(SELECT * FROM prices WHERE prices.AccommodationID = accommodation_id) THEN

                                    -- Query the PriceID
                                    SELECT PriceID INTO price_id FROM prices WHERE prices.AccommodationID = accommodation_id;

                                        -- Create the reservation and payment
                                        START TRANSACTION;
                                            -- Insert the information into reservations
                                            INSERT INTO reservations (CheckInDate,CheckOutDate,GuestNumber,AccommodationID,GuestID) VALUES (check_in_date,check_out_date,guest_number,accommodation_id,guest_id);

                                            -- Calculate the date difference between check in and check out date
                                            SELECT DATEDIFF(check_in_date, check_out_date) INTO booking_duration;

                                            -- Calculate the price of the reservation
                                            SELECT NumberOfNights INTO number_of_nights FROM prices WHERE prices.AccommodationID = accommodation_id;
                                            SELECT TotalPrice INTO total_price FROM prices WHERE prices.AccommodationID = accommodation_id;
                                            SET caluclated_price = -total_price*booking_duration;

                                            -- Insert the information into the Payment table 
                                            INSERT INTO  payments (PaymentAmount,PaymentMethod,PaymentTime,GuestID,PriceID) VALUES (caluclated_price,payment_method,CURRENT_TIMESTAMP,guest_id,price_id);
                                            -- Save the PaymentID
                                            SELECT LAST_INSERT_ID() INTO payment_id;

                                            -- Calculate the possible confirmation time
                                            SELECT DATE_ADD(check_in_date, INTERVAL 1 DAY) INTO possible_cancellation_time;

                                            -- Insert the information into the PaymentConfirmations table
                                            INSERT INTO payconfirmations (ConfirmationCancellation,CancellationConfirmationTime,PossibleCancellationTime,PaymentID) VALUES (NULL,NULL, possible_cancellation_time, payment_id);

                                            SET message = "Reservation was successfull";
                                        COMMIT;

                                -- Price does not exist
                                ELSE 
                                    SET message = 'Reservation failed - price not found';
                                END IF; 
                            -- Payment method does not exist
                            ELSE 
                                SET message = 'Reservation failed - payment method not found';
                            END IF; 
                        -- Issues with the booking date
                        ELSE 
                            SET message = 'Reservation failed - the accommodation has already been booked for this date';
                        END IF; 
                    -- Issues with the booking date
                    ELSE 
                        SET message = 'Reservation failed - there are issues with the booking date';
                    END IF;                  
                -- Guest does not exist
                ELSE 
                    SET message = 'Reservation failed - guest not found';
                END IF;  
            -- Host does not exist
            ELSE 
                SET message = 'Reservation failed - host not found';
            END IF;             
    -- Accommodation does not exist
    ELSE 
        SET message = 'Reservation failed - accommodation not found';
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GuestRegister` (IN `guest_name` VARCHAR(100), IN `guest_surname` VARCHAR(100), IN `guest_age` DECIMAL(3), IN `currency_code_user` CHAR(3), IN `guest_country` VARCHAR(100), IN `guest_region` VARCHAR(100), IN `guest_town` VARCHAR(100), IN `guest_street` VARCHAR(100), IN `guest_house_number` VARCHAR(30), IN `guest_ZIPcode` VARCHAR(30), IN `guest_email_adress` VARCHAR(100), IN `guest_phone_number` VARCHAR(100), OUT `message` VARCHAR(128))  BEGIN

    -- Declare Variables
    DECLARE currency_code CHAR(3);
    DECLARE guest_id INT;

    -- Check if the currency exists
    IF EXISTS(SELECT CurrencyCode FROM currencies WHERE currencies.CurrencyCode = currency_code_user) THEN

        -- Query the currency code
        SELECT CurrencyCode INTO currency_code FROM currencies WHERE currencies.CurrencyCode = currency_code_user;

        -- Check if the exact adress information does not exists 
        IF NOT EXISTS(SELECT * FROM guestadresses WHERE guestadresses.GuestCountry = guest_country AND guestadresses.GuestRegion = guest_region AND guestadresses.GuestTown = guest_town AND guestadresses.GuestStreet = guest_street AND guestadresses.GuestHouseNumber = guest_house_number AND guestadresses.GuestZIPCode = guest_ZIPcode) THEN

            -- Check if the email or phone number exists
            IF NOT EXISTS(SELECT * FROM guestcontacts WHERE guestcontacts.GuestEmailAdress = guest_email_adress OR guestcontacts.GuestPhoneNumber = guest_phone_number) THEN

                -- Register the guest
                START TRANSACTION;
                    -- Insert the guest information into the guests table
                    INSERT INTO guests (GuestName, GuestSurname, GuestAge, CurrencyCode) VALUES (guest_name, guest_surname, guest_age, currency_code);
                    -- Query the GuestID of the guest registration
                    SELECT LAST_INSERT_ID() INTO guest_id;

                    -- Insert the guest adress information into the guestadresses table
                    INSERT INTO guestadresses (GuestCountry, GuestRegion, GuestTown, GuestStreet,GuestHouseNumber,GuestZIPCode,GuestID) VALUES (guest_country,guest_region,guest_town,guest_street,guest_house_number,guest_ZIPcode,guest_id);

                    -- Insert the guest contact information into the guestcontacts table
                    INSERT INTO guestcontacts (GuestEmailAdress,GuestPhoneNumber,GuestID) VALUES (guest_email_adress,guest_phone_number, guest_id);
                    SET message = "Guest registration success";
                COMMIT;

            -- Email or phone number already exists
            ELSE 
                SET message = 'Guest registration failed - email or phone number already exists';
            END IF;
        -- Adress already exists
        ELSE 
            SET message = 'Guest registration failed - adress already exsists';
        END IF;
    -- Invalid currency
    ELSE 
        SET message = 'Guest registration failed - currency not found';
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GuestReview` (IN `host_email_adress` VARCHAR(100), IN `guest_email_adress` VARCHAR(100), IN `guest_score` DECIMAL(1,0), IN `guest_text` TEXT, OUT `message` VARCHAR(128))  BEGIN

    -- Declare Variables
    DECLARE guest_id INT;
    DECLARE host_id INT;

    -- Check if the host exists
    IF EXISTS(SELECT * FROM hostcontacts WHERE hostcontacts.HostEmailAdress = host_email_adress) THEN

        -- Query the HostID
        SELECT HostID INTO host_id FROM hostcontacts WHERE hostcontacts.HostEmailAdress = host_email_adress;

        -- Check if the guest exists
         IF EXISTS(SELECT * FROM guestcontacts WHERE guestcontacts.GuestEmailAdress = guest_email_adress) THEN

            -- Query the GuestID
            SELECT GuestID INTO guest_id FROM guestcontacts WHERE guestcontacts.GuestEmailAdress = guest_email_adress;

            -- Check if the score is a number between 1 to 5
            IF guest_score BETWEEN 1 AND 5 THEN

                -- Create the host review
                START TRANSACTION;
                    -- Insert the information in the hostreviews table
                    INSERT INTO guestreviews (GuestScore,GuestText,GuestReviewDate,HostID,GuestID) VALUES (guest_score,guest_text,CURRENT_DATE,host_id,guest_id);

                    SET message = "Review was successfull";
                COMMIT;
            -- Score is not a number between 1 and 5
            ELSE 
                SET message = 'Review failed - the score must be between 1 and 5';
            END IF;                  
        -- Guest does not exist
        ELSE 
            SET message = 'Review failed - guest not found';
        END IF;  
    -- Host does not exist
    ELSE 
        SET message = 'Review failed - host not found';
    END IF;             
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `HostRegister` (IN `host_name` VARCHAR(100), IN `host_surname` VARCHAR(100), IN `host_age` DECIMAL(3), IN `currency_code_user` CHAR(3), IN `host_country` VARCHAR(100), IN `host_region` VARCHAR(100), IN `host_town` VARCHAR(100), IN `host_street` VARCHAR(100), IN `host_house_number` VARCHAR(30), IN `host_ZIPcode` VARCHAR(30), IN `host_email_adress` VARCHAR(100), IN `host_phone_number` VARCHAR(100), OUT `message` VARCHAR(128))  BEGIN

    -- Declare Variables
    DECLARE currency_code CHAR(3);
    DECLARE host_id INT;

    -- Check if the currency exists
    IF EXISTS(SELECT CurrencyCode FROM currencies WHERE currencies.CurrencyCode = currency_code_user) THEN

        -- Query the currency code
        SELECT CurrencyCode INTO currency_code FROM currencies WHERE currencies.CurrencyCode = currency_code_user;

        -- Check if the exact adress information does not exists 
        IF NOT EXISTS(SELECT * FROM hostadresses WHERE hostadresses.HostCountry = host_country AND hostadresses.HostRegion = host_region AND hostadresses.HostTown = host_town AND hostadresses.HostStreet = host_street AND hostadresses.HostHouseNumber = host_house_number AND hostadresses.HostZIPCode = host_ZIPcode) THEN

            -- Check if the email or phone number exists
            IF NOT EXISTS(SELECT * FROM hostcontacts WHERE hostcontacts.HostEmailAdress = host_email_adress OR hostcontacts.HostPhoneNumber = host_phone_number) THEN

                -- Register the host
                START TRANSACTION;
                    -- Insert the host information into the host table
                    INSERT INTO host (HostName, HostSurname, HostAge, CurrencyCode) VALUES (host_name, host_surname, host_age, currency_code);
                    -- Query the HostID of the host registration
                    SELECT LAST_INSERT_ID() INTO host_id;

                    -- Insert the host adress information into the hostadresses table
                    INSERT INTO hostadresses (HostCountry, HostRegion, HostTown, HostStreet,HostHouseNumber,HostZIPCode,HostID) VALUES (host_country,host_region,host_town,host_street,host_house_number,host_ZIPcode,host_id);

                    -- Insert the host contact information into the hostcontacts table
                    INSERT INTO hostcontacts (HostEmailAdress,HostPhoneNumber,HostID) VALUES (host_email_adress,host_phone_number, host_id);

                    -- Insert the accommodation
                    SET message = "Host registration success";
                COMMIT;
                    
            -- Email or phone number already exists
            ELSE 
                SET message = 'Host registration failed - email or phone number already exists';
            END IF;
        -- Adress already exists
        ELSE 
            SET message = 'Host registration failed - adress already exsists';
        END IF;
    -- Invalid currency
    ELSE 
        SET message = 'Host registration failed - currency not found';
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `HostReview` (IN `guest_email_adress` VARCHAR(100), IN `host_email_adress` VARCHAR(100), IN `host_score` DECIMAL(1,0), IN `host_text` TEXT, OUT `message` VARCHAR(128))  BEGIN

    -- Declare Variables
    DECLARE guest_id INT;
    DECLARE host_id INT;

    -- Check if the host email exists
    IF EXISTS(SELECT * FROM hostcontacts WHERE hostcontacts.HostEmailAdress = host_email_adress) THEN

        -- Query the HostID
        SELECT HostID INTO host_id FROM hostcontacts WHERE hostcontacts.HostEmailAdress = host_email_adress;

            -- Check if the host exists
            IF EXISTS(SELECT * FROM host WHERE host.HostID = host_id) THEN

                -- Check if the guest exists
                IF EXISTS(SELECT * FROM guestcontacts WHERE guestcontacts.GuestEmailAdress = guest_email_adress) THEN

                    -- Query the GuestID
                    SELECT GuestID INTO guest_id FROM guestcontacts WHERE guestcontacts.GuestEmailAdress = guest_email_adress;

                    -- Check if the score is a number between 1 and 5
                    IF host_score BETWEEN 1 AND 5 THEN

                        -- Create the host review
                        START TRANSACTION;
                            -- Insert the information in the hostreviews table
                            INSERT INTO hostreviews (HostScore,HostText,HostReviewDate,HostID,GuestID) VALUES (host_score,host_text,CURRENT_DATE,host_id,guest_id);

                            SET message = "Review was successfull";
                        COMMIT;
                    -- Score is not a number between 1 and 5
                    ELSE
                        SET message = 'Review failed - the score must be between 1 and 5';
                    END IF;
                -- Guest does not exist
                ELSE 
                    SET message = 'Review failed - guest not found';
                END IF;  
            -- Host does not exist
            ELSE 
                SET message = 'Review failed - host not found';
            END IF;             
    -- Accommodation does not exist
    ELSE 
        SET message = 'Review failed - host email does not exist';
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `KitchenCreation` (IN `accommodation_name` VARCHAR(100), IN `kitchen_name` VARCHAR(100), IN `kitchen_description` TEXT, OUT `message` VARCHAR(128))  BEGIN
    -- Declare variables
    DECLARE accommodation_id INT;
    DECLARE interior_id INT;

    -- Check if the accommodation exists
    IF EXISTS(SELECT * FROM accommodations WHERE accommodations.AccommodationName = accommodation_name) THEN

        -- Query the AccommodationID
        SELECT AccommodationID INTO accommodation_id FROM accommodations WHERE accommodations.AccommodationName = accommodation_name;

        -- Check if the interior exists
        IF EXISTS(SELECT * FROM interiors WHERE interiors.AccommodationID = accommodation_id) THEN

            -- Query the interiorID
            SELECT InteriorID INTO interior_id FROM interiors WHERE interiors.AccommodationID = accommodation_id;

            -- Create the kitchen
            START TRANSACTION;
                -- Insert the kitchen data in the kitchens table
                INSERT INTO kitchens (KitchenName,KitchenDescription,InteriorID) VALUES (kitchen_name,kitchen_description,interior_id);

                -- Change the number of rooms the interior has +1
                UPDATE interiors SET RoomNumber = RoomNumber + 1 WHERE interiors.AccommodationID = accommodation_id;

                SET message = "Kitchen creation success";
            COMMIT;

        -- Interior does not exist
        ELSE 
            SET message = 'Kitchen creation failed - Interior does not exist';
        END IF;

    -- Accommodation does not exist
    ELSE 
        SET message = 'Kitchen creation failed - accommodation does not exist';
    END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `LivingroomCreation` (IN `accommodation_name` VARCHAR(100), IN `livingroom_name` VARCHAR(100), IN `livingroom_description` TEXT, OUT `message` VARCHAR(128))  BEGIN
    -- Declare variables
    DECLARE accommodation_id INT;
    DECLARE interior_id INT;

    -- Check if the accommodation exists
    IF EXISTS(SELECT * FROM accommodations WHERE accommodations.AccommodationName = accommodation_name) THEN

        -- Query the AccommodationID
        SELECT AccommodationID INTO accommodation_id FROM accommodations WHERE accommodations.AccommodationName = accommodation_name;

        -- Check if the interior exists
        IF EXISTS(SELECT * FROM interiors WHERE interiors.AccommodationID = accommodation_id) THEN

            -- Query the interiorID
            SELECT InteriorID INTO interior_id FROM interiors WHERE interiors.AccommodationID = accommodation_id;

            -- Create the living room
            START TRANSACTION;
                -- Insert the living room data in the livingrooms table
                INSERT INTO livingrooms (LivingRoomName, LivingRoomDescription, InteriorID) VALUES (livingroom_name,livingroom_description,interior_id);

                -- Change the number of rooms the interior has +1
                UPDATE interiors SET RoomNumber = RoomNumber + 1 WHERE interiors.AccommodationID = accommodation_id;

                SET message = "Living room creation success";
            COMMIT;

        -- Interior does not exist
        ELSE 
            SET message = 'Living room creation failed - Interior does not exist';
        END IF;

    -- Accommodation does not exist
    ELSE 
        SET message = 'Living room creation failed - accommodation does not exist';
    END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `OtherroomCreation` (IN `accommodation_name` VARCHAR(100), IN `otherroom_name` VARCHAR(100), IN `otherroom_description` TEXT, OUT `message` VARCHAR(128))  BEGIN
    -- Declare variables
    DECLARE accommodation_id INT;
    DECLARE interior_id INT;

    -- Check if the accommodation exists
    IF EXISTS(SELECT * FROM accommodations WHERE accommodations.AccommodationName = accommodation_name) THEN

        -- Query the AccommodationID
        SELECT AccommodationID INTO accommodation_id FROM accommodations WHERE accommodations.AccommodationName = accommodation_name;

        -- Check if the interior exists
        IF EXISTS(SELECT * FROM interiors WHERE interiors.AccommodationID = accommodation_id) THEN

            -- Query the interiorID
            SELECT InteriorID INTO interior_id FROM interiors WHERE interiors.AccommodationID = accommodation_id;

            -- Create the other room
            START TRANSACTION;
                -- Insert the other room data in the otherrooms table
                INSERT INTO otherrooms (OtherRoomName,OtherRoomDescription,InteriorID) VALUES (otherroom_name, otherroom_description,interior_id);

                -- Change the number of rooms the interior has +1
                UPDATE interiors SET RoomNumber = RoomNumber + 1 WHERE interiors.AccommodationID = accommodation_id;

                SET message = "Other room creation success";
            COMMIT;

        -- Interior does not exist
        ELSE 
            SET message = 'Other room creation failed - Interior does not exist';
        END IF;

    -- Accommodation does not exist
    ELSE 
        SET message = 'Other room creation failed - accommodation does not exist';
    END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `PayConfirmation` (IN `guest_email_adress` VARCHAR(100), IN `guest_phone_number` VARCHAR(100), IN `accommodation_name` VARCHAR(100), IN `payment_confirmation_cancellation` BOOLEAN, OUT `message` VARCHAR(128))  BEGIN

    -- Declare Variables
    DECLARE guest_id INT;
    DECLARE accommodation_id INT;
    DECLARE price_id INT;
    DECLARE payment_id INT;
    DECLARE payment_confirmations_id INT;
    DECLARE payment_amount INT;

    -- Check if the accommodation exists
    IF EXISTS(SELECT * FROM accommodations WHERE accommodations.AccommodationName = accommodation_name) THEN

        -- Query the AccommodationID
        SELECT AccommodationID INTO accommodation_id FROM accommodations WHERE accommodations.AccommodationName = accommodation_name;

        -- Check if the guest exists
        IF EXISTS(SELECT * FROM guestcontacts WHERE guestcontacts.GuestEmailAdress = guest_email_adress AND guestcontacts.GuestPhoneNumber = guest_phone_number) THEN

            -- Query the GuestID
            SELECT GuestID INTO guest_id FROM guestcontacts WHERE guestcontacts.GuestEmailAdress = guest_email_adress AND guestcontacts.GuestPhoneNumber = guest_phone_number;

            -- Check if the PriceID exist
            IF EXISTS(SELECT * FROM prices WHERE prices.AccommodationID = accommodation_id) THEN

                -- Query the PriceID
                SELECT PriceID INTO price_id FROM prices WHERE prices.AccommodationID = accommodation_id;

                -- Check if the payment exist
                IF EXISTS(SELECT * FROM payments WHERE payments.GuestID = guest_id AND payments.PriceID = price_id) THEN

                    -- Query PaymentID
                    SELECT PaymentID INTO payment_id FROM payments WHERE payments.GuestID = guest_id AND payments.PriceID = price_id;

                    -- Check if the payment confirmation exists
                    IF EXISTS(SELECT * FROM payconfirmations WHERE payconfirmations.PaymentID = payment_id) THEN

                        -- Check if the payment has been confirmed either by the user or by the date
                        IF payment_confirmation_cancellation = TRUE OR CURRENT_TIMESTAMP > (SELECT PossibleCancellationTime FROM payconfirmations WHERE payconfirmations.PaymentID = payment_id)THEN
                            -- Update Information in the payment confirmations table and create the income
                            START TRANSACTION;
                                -- Update the information of payment confirmations
                                UPDATE payconfirmations SET payconfirmations.ConfirmationCancellation = 1, payconfirmations.CancellationConfirmationTime = CURRENT_TIMESTAMP WHERE payconfirmations.PaymentID = payment_id;

                                -- Query the PayConfirmationID
                                SELECT PayConfirmationID INTO payment_confirmations_id FROM payconfirmations WHERE payconfirmations.PaymentID = payment_id;
                                
                                -- Query the payment amount
                                SELECT PaymentAmount INTO payment_amount FROM payments WHERE payments.GuestID = guest_id AND payments.PriceID = price_id;

                                -- Insert the information into the income table
                                INSERT INTO income (Income,IncomeTime,AccommodationID,PayConfirmationID) VALUES (payment_amount,CURRENT_TIMESTAMP,accommodation_id,payment_confirmations_id);

                                SET message = "Payment was successfull";
                            COMMIT;
                        END IF;
                        -- If the payment has been cancelled
                        IF payment_confirmation_cancellation = FALSE AND NOT CURRENT_TIMESTAMP > (SELECT PossibleCancellationTime FROM payconfirmations WHERE payconfirmations.PaymentID = payment_id)THEN
                            -- Update Information in the payment confirmations and delete information from the reservations table
                            START TRANSACTION;
                                -- Update the information of payment confirmations
                                UPDATE payconfirmations SET payconfirmations.ConfirmationCancellation = 0, payconfirmations.CancellationConfirmationTime = CURRENT_TIMESTAMP WHERE payconfirmations.PaymentID = payment_id;

                                -- Delete the information from reservations
                                DELETE FROM reservations WHERE reservations.GuestID = guest_id AND reservations.AccommodationID = accommodation_id;

                                SET message = "Payment has been cancelled";
                            COMMIT;
                        END IF;
                    -- Payment confirmation does not exist
                    ELSE 
                        SET message = 'Pay confirmation failed - payment confirmation not found';
                    END IF;  
                -- Payment does not exist
                ELSE 
                    SET message = 'Pay confirmation failed - payment not found';
                END IF;       
            -- Price does not exist
            ELSE 
                SET message = 'Pay confirmation failed - price not found';
            END IF;        
        -- Guest does not exist
        ELSE 
            SET message = 'Pay confirmation failed - guest not found';
        END IF;  
    -- Accommodation does not exist
    ELSE 
        SET message = 'Pay confirmation failed - accommodation not found';
    END IF;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `accommodationreviews`
--

CREATE TABLE `accommodationreviews` (
  `AccommodationReviewID` int(11) NOT NULL,
  `AccommodationScore` decimal(1,0) NOT NULL,
  `AccommodationText` text DEFAULT NULL,
  `AccommodationReviewDate` date NOT NULL,
  `GuestID` int(11) NOT NULL,
  `AccommodationID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Daten für Tabelle `accommodationreviews`
--

INSERT INTO `accommodationreviews` (`AccommodationReviewID`, `AccommodationScore`, `AccommodationText`, `AccommodationReviewDate`, `GuestID`, `AccommodationID`) VALUES
(1, '5', 'Great place to stay if you are visiting nyc', '2021-11-02', 1, 1),
(2, '5', 'The view of the Eiffel Tower is so incredible you won’t want to leave the room. Nice to laze in bed with a cup of coffee. ', '2021-11-02', 2, 2),
(3, '3', 'The accommodation was nice, but not as good as I expected', '2021-11-02', 3, 3),
(4, '5', 'Really nice place and such a calming atmosphere. Definitely will visit again.', '2021-11-03', 4, 4),
(5, '5', 'We stayed a lovey 3 nights in Akira & Aris’ guest house. The cottage was very cozy and comfortable. Communication was very easy and the luggage drop off was very helpful when our travel plans ended up with us arriving in Ghent earlier than expected. Location was great, a quiet section but only a few minutes walk to attractions and main town center!', '2021-11-03', 5, 5),
(6, '5', 'Amazing accommodation!', '2021-11-03', 6, 6),
(7, '5', 'It was really nice, it was awesome..! I would recommend!!', '2021-11-03', 7, 7),
(8, '5', 'Beautiful and cute apartment 5 minutes from the lake and totally nice and helpful host !! ', '2021-11-03', 8, 8),
(9, '4', 'Nice little cosy 2-room appartement, close to the sea, located in one of the suburbs south of the Malmö, but with the city line. Easy to access, well connected, great palce to go for walks on the sea shore. Very kind and friendly host. Very much suited for a couple - the flat has all you need, very well equipped.', '2021-11-03', 9, 9),
(10, '5', 'This cottage is beautifully presented and has all the comforts and equipment you could wish for. ', '2021-11-03', 10, 10),
(11, '4', 'We truly enjoyed our stay in the AirBnb. Highlights of the flat were the rooftop terrace, the modern furniture and the well-equipped kitchen. The communication with the hosts was perfect and we felt very comfortable and welcome. However, it took us quite some time to get to the city centre.', '2021-11-03', 11, 11),
(12, '5', 'It is a nice house.', '2021-11-03', 12, 12),
(13, '5', 'Lovely quiet spot near the city centre that offers a much more unique experience than other hotels and guesthouses in the area. Great communication and definitely a place I\'d recommend to friends!', '2021-11-03', 13, 13),
(14, '5', 'The place and the property is beautiful. no better place to stay. we arrived in the evening and fell on love with the view. ', '2021-11-03', 14, 14),
(15, '5', ' It is a very nice little house in the middle of the woods of Börzsönyliget. If you are looking for peace and quiet, this is the right place for you.', '2021-11-03', 15, 15),
(16, '5', ' A beautiful, cozy and cozy holiday home, in which you can spend a great holiday week even in autumn. The location is unique - we saw deer in the garden again!', '2021-11-04', 16, 16),
(17, '5', 'You want to come here, it\'s brilliant.', '2021-11-04', 17, 17),
(18, '5', 'The location is very near to the city centre, i highly recommend h the stay', '2021-11-04', 18, 18),
(19, '5', 'Amazing view', '2021-11-04', 19, 19),
(20, '5', 'Another fabulous stay with plus holidays , customer service is amazing', '2021-11-04', 20, 20);

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `accommodations`
--

CREATE TABLE `accommodations` (
  `AccommodationID` int(11) NOT NULL,
  `AccommodationName` varchar(100) NOT NULL,
  `AccommodationDescription` text DEFAULT NULL,
  `AccommodationType` varchar(100) DEFAULT NULL,
  `AccommodationRules` varchar(100) DEFAULT NULL,
  `HostID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Daten für Tabelle `accommodations`
--

INSERT INTO `accommodations` (`AccommodationID`, `AccommodationName`, `AccommodationDescription`, `AccommodationType`, `AccommodationRules`, `HostID`) VALUES
(1, 'Charming Spacious Solace close to NYC', 'Guests are free to use the living area, backyard, bar and other common spaces', 'House', 'No smoking, No parties', 1),
(2, 'Wonderful new room in front of the Eiffel Tower', 'Two big windows in front of the Eiffel Tower are there to surprise you. This 20mq room completely renewed February 2020 is a lovely nest where you can sleep under the tour Eiffel but also prepare your own breakfast or dinner in the full equipped kitchen and enjoy the same very special view..', 'Apartment', 'Only 2 people are allowed in!', 2),
(3, 'Lovely apartment overlooking the Pantheon square', 'Lovely apartment overlooking the Pantheon Square, located in the very heart of Rome, featuring 1 bedroom with a double bed, smart tv and conditioned air; a second room with a sofà bed for 1 adult or 2 children (width 140 cm.) and kitchen; bathroom with shower. The mattress and the pillows are very confortable. The apartment has WI-FI, washing mashine, clotheshorse, iron, ironing board, hair dryer, fridge with a little freezer, microwave oven.', 'Apartment', 'No smoking, No pets', 3),
(4, 'Upnorth Vibes', 'This 1940s Log Cottage Sleeps 4 and is The Perfect Place For a Laid-Back Group of Friends, Couples, or a Family Looking To Explore Michigan\'s North Coast! ', 'House', 'No smoking, No parties', 4),
(5, 'Charming garden studio in the historic center', 'Complete studio with kitchen and bathroom exclusive for guests. Terrace to enjoy the garden.', 'Studio', 'No smoking, No pets, No parties', 5),
(6, 'Rosenvilla for 4 persons', 'Terrace furniture, storage room. Nice view of the garden. Available: washing machine. Internet (wireless LAN, free). Covered parking space (2 cars) by the house. Please note: non-smoking house. The furniture in the Rosenvilla is original Biedermeier. There is a grand piano in the living room. The tiled stove shown here is only used as an ornament. Because of the valuable equipment, children are only welcome from the age of 10. If fewer people are occupied than the maximum number of people, not all residential units are available.', 'House', 'No smoking, No pets', 6),
(7, 'Vllia Benicolada - Costa CarpeDiem', ' Perfect for an extended stay, this one story 3 bedroom south facing villa means you will get sunshine all day long, making it perfect for year round rental.', 'House', 'No smoking, No parties', 7),
(8, 'House Gabrijel with four season outdoor kitchen', 'The house Gabrijel is situated at a peaceful location in an unspoilt nature, away from the city hustle and bustle. Here, you can enjoy the peace, quiet and fresh air. You can also meet and play with our dog Neli and cat Ben. The Jezernica creek, which flows past the house, creates a pleasant babbling sound.', 'Log cabin', 'No smoking, No pets', 8),
(9, 'Cosy charming garden sea house CPH Airport Malmö', 'Enjoy the tranquility of newly renovated guesthouse Blomsterbo, a small cottage in the garden next to a house. Comfortable beds, separate toilette and shower. Kitchenette / mini kitchen. Wifi 300 Mbit, smartTV with Netflix. Laundry. Patio with several sitting & eating areas in the garden. Ideal for travelers with flights from Copenhagen / Malmo airport, takes only 35 minutes. Ideal for families with children or guests who wants quiet and homely accommodation. Free coffe, parking. Very welcome!', 'Cottage', 'No smoking, No parties', 9),
(10, 'Port Sunlight Station Cottage', 'This Grade 2 listed home, built in 1894, is ideally located for exploring this stunning historic village including the museum, tearooms and Lady Lever art gallery. Our closest features are the Gladstone theatre, The Lyceum and bridge and The Dell park which can be seen from the property.', 'Cottage', 'No smoking', 10),
(11, 'Rooftop studio *Old Prague view* terrace with A/C', 'This very calm and qiuet flat of 51 + 12m2 terrace is situated in a house from the late 19th century. The house is up on a hill, which allows you the perfect view of Prague city center. There is a lift in the house, however, few steps up are unavoidable, as the studio is located on the highest, 6th floor.', 'Loft', 'No smoking', 11),
(12, 'Fuku Lodge', 'Fuku Lodge is a log-house with wood scent, a living room with high floor, central heating with a wood stove, and an open kitchen with whole kitchen set where you can prepare your own meals.', 'Log cabin', 'No smoking, No pets', 12),
(13, 'Beautiful Boat in the Heart of Galway City', 'If you are looking for something a little different, lots of privacy, and peace and quiet then look no further! If generic hotels and apartments have started to become somewhat of a blur, then this may be the experience you have been looking for! Perfect for a romantic getaway...', 'Boat', 'No smoking, No parties, No pets', 13),
(14, 'Casalini Estate', 'A heritage Home owned by Mr Atwal who lives in the same premises and we have a pet who is friendly who lives with the owner ( Saint Bernard ) House has three bedroom with attached washroom . A British style dining space , A big living room , a Study room with fireplace ( operational only in winters ) . lot of open space spread across 6 acres , their is a gazebo where guest can enjoy their High tea . Guests can also trek to Taradevi temple .', 'Farm yard', 'no parties allowed , no Smoking inside the house', 14),
(15, 'Fauna Erdei Vendégház', 'The garden is led by a bridge over a small stream, where there is a warm house in winter and cool in summer. Everything revolves around relaxation here. Large terrace, barbecue and fire building, well-equipped kitchen, room with stove and bathroom.', 'Cottage', 'No smoking, No parties', 15),
(16, 'Lyren Blaavand', 'A family-friendly holiday home close to nature with good opportunities for walks in the woods, dunes, meadows and by the sea.', 'House', 'No smoking', 16),
(17, 'Maisonette', 'The large country-style apartment on two floors is equipped with many amenities, suitable for relaxing on the large loggia on the upper floor or the covered veranda in the entrance area.', 'Barn', 'No smoking, No parties', 17),
(18, 'Studio Cents', 'Lovely studio 30m2', 'Studio', 'No smoking, No parties', 18),
(19, 'Casa Cavour', 'The tastefully furnished and sunny accommodation has 90 m² and has a great view of the mountains and the lake.', 'House', 'No smoking, No pets', 19),
(20, 'Villa Remi', 'Fantastic villa with private pool', 'Villa', 'No smoking, No pets', 20);

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `bathrooms`
--

CREATE TABLE `bathrooms` (
  `BathroomID` int(11) NOT NULL,
  `BathroomName` varchar(100) NOT NULL,
  `BathroomDescription` text DEFAULT NULL,
  `InteriorID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Daten für Tabelle `bathrooms`
--

INSERT INTO `bathrooms` (`BathroomID`, `BathroomName`, `BathroomDescription`, `InteriorID`) VALUES
(1, 'Private bathroom', 'Every guest has a private bathroom', 1),
(2, 'Private bathroom', 'Bathroom with a shower, you will be in absolute privacy.', 2),
(3, 'Private bathroom', 'Every partment has a bathroom', 3),
(4, 'Bathroom', '- All clean Linens Will Be Prepared For You Including Bedding, Kitchen, Bath Towels, + Extra Blankets. - Shampoo, Conditioner, + Body Wash Provided.', 4),
(5, 'Bathroom', 'bathroom exclusive for guests.', 5),
(6, 'Bathroom', 'Bathroom with shower and bath.', 6),
(7, 'Bathroom', 'The villa also has two bathrooms, one with a bathtub, while the other has a shower.', 7),
(8, 'Bathroom', 'A normal bathroom', 8),
(9, 'Bathroom', 'A swedish bathroom, with shower, toilet and bath', 9),
(10, 'Bathroom', 'The bathroom has a walk in shower and free-standing bath.', 10),
(11, 'Bathroom', 'Normal spaced bathroom', 11),
(12, 'Bathroom', 'Normal bathroom with everything available', 12),
(13, 'Bathroom', 'The boat comes equipped with a small bathroom', 13),
(14, 'Bathroom', 'A normal spaced bathroom', 14),
(15, 'Bathroom', 'Vintage style bathroom', 15),
(16, 'Bathroom', 'A normal bathroom', 16),
(17, 'Bathroom', 'A normal bathroom', 17),
(18, 'Bathroom', 'A small bathroom', 18),
(19, 'Bathroom', 'Spacious bathroom with whirpool', 19),
(20, 'Bathroom', 'A luxorious bathroom ', 20);

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `bedrooms`
--

CREATE TABLE `bedrooms` (
  `BedroomID` int(11) NOT NULL,
  `BedroomName` varchar(100) NOT NULL,
  `BedsNumber` decimal(2,0) NOT NULL,
  `BedroomDescription` text DEFAULT NULL,
  `InteriorID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Daten für Tabelle `bedrooms`
--

INSERT INTO `bedrooms` (`BedroomID`, `BedroomName`, `BedsNumber`, `BedroomDescription`, `InteriorID`) VALUES
(1, 'Private bedroom', '2', '1 Queensized bed, 1 sleeping couch', 1),
(2, 'Bedroom', '1', 'Queensized double bed', 2),
(3, 'Bedroom', '1', 'Double bed', 3),
(4, 'Bedroom', '2', '2 Queen Size Beds. Memory Foam Mattresses + Pillows', 4),
(5, 'Bedroom', '1', '1 Double bed', 5),
(6, 'Bedroom', '2', '2 Double beds', 6),
(7, 'Bedroom', '1', '1 Double bed', 7),
(8, 'Bedroom', '2', '2 single beds', 8),
(9, 'Bedroom', '1', 'Queen sized double bed', 9),
(10, 'Bedroom', '1', 'The master bedroom is a spacious, bright room with kingsize bed and en-suite bathroom with shower.', 10),
(11, 'Bedroom', '1', 'Bedroom with double bed', 11),
(12, 'Bedroom', '1', 'King sized double bed', 12),
(13, 'Bedroom', '1', 'Double bed', 13),
(14, '1', '2', '1 Double bed and 1 sleeping couch', 14),
(15, 'Bedroom', '1', '1 Queensize-Doublebed', 15),
(16, 'Bedroom', '1', 'Normal sized bedroom with 1 double bed', 16),
(17, 'Bedroom', '1', 'A larger bedroom with a queensized double bed', 17),
(18, 'Bedroom', '1', 'A small bedroom containing a queensized double bed', 18),
(19, 'Bedroom', '1', 'Master bedroom with kingsized double bed', 19),
(20, 'Bedroom', '1', 'Master bedroom with a kingsized double bed', 20);

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `currencies`
--

CREATE TABLE `currencies` (
  `CurrencyCode` char(3) NOT NULL,
  `ConversionRate` decimal(20,10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Daten für Tabelle `currencies`
--

INSERT INTO `currencies` (`CurrencyCode`, `ConversionRate`) VALUES
('AUD', '1.6086000000'),
('BGN', '1.9558000000'),
('BRL', '6.1791000000'),
('CAD', '1.4874000000'),
('CHF', '1.0735000000'),
('CNY', '7.6818000000'),
('CUR', '0.3126770000'),
('CZK', '25.4900000000'),
('DKK', '7.4376000000'),
('EUR', '1.0000000000'),
('GBP', '0.8535500000'),
('HKD', '9.2428000000'),
('HRK', '7.5005000000'),
('HUF', '354.5900000000'),
('IDR', '16995.6400000000'),
('ILS', '3.8211000000'),
('INR', '88.2175000000'),
('ISK', '146.6000000000'),
('JPY', '129.7000000000'),
('KRW', '1364.5900000000'),
('MXN', '23.5939000000'),
('MYR', '5.0161000000'),
('NOK', '10.4343000000'),
('NZD', '1.6953000000'),
('PHP', '58.9460000000'),
('PLN', '4.5562000000'),
('RON', '4.9183000000'),
('RUB', '86.7063000000'),
('SEK', '10.2045000000'),
('SGD', '1.6056000000'),
('THB', '39.2440000000'),
('TRY', '9.9576000000'),
('USD', '1.1885000000'),
('ZAR', '17.1001000000');

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `exteriors`
--

CREATE TABLE `exteriors` (
  `ExteriorID` int(11) NOT NULL,
  `ExteriorType` varchar(100) DEFAULT NULL,
  `ExteriorDescription` text DEFAULT NULL,
  `AccommodationID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Daten für Tabelle `exteriors`
--

INSERT INTO `exteriors` (`ExteriorID`, `ExteriorType`, `ExteriorDescription`, `AccommodationID`) VALUES
(1, 'Garden', 'Guests are free to use the backyard', 1),
(2, 'Balcony', 'There is a small balcony where you can enjoy the view', 2),
(3, 'Balcony', 'Every apartment has a large balcony', 3),
(4, 'Yard', 'A luxurious outdoor hot tub for relaxing on chilly northern nights! Outdoor campfire pit for all your s\'more and story telling needs!', 4),
(5, 'Garden', 'Charming garden to enjoy!', 5),
(6, 'Garden', 'A spacious garden for relaxing!', 6),
(7, 'Garden', 'A large garden with a pool', 7),
(8, 'Forest', 'The log is surrounded by forest with a natural swimming area', 8),
(9, 'Garden', 'The garden is green and charming with lots of flowers and you have 2 cosy places to sit and eat outside your house, as well as a sitting lounge in the garden. The garden is furnitured April- October. Garden is shared with the residents in the main house.', 9),
(10, 'Garden', 'there is a paved garden area with plants and shrubs, there is also a further toilet in the converted outhouse.', 10),
(11, 'Rooftop', 'The exterior is a rooftop with a great view over Prague', 11),
(12, 'Garden', 'The log cabin has access to a vast forest and garden', 12),
(13, 'Lake', 'The exterior of the boat is the lake', 13),
(14, 'Fields', 'A private estate spread across 6 acres of Land.', 14),
(15, 'Forest', 'The cottage is surrounded by a large forest', 15),
(16, 'Garden', 'Natural plot of 1600 m²', 16),
(17, 'Garden', 'A small garden to enjoy nature', 17),
(18, 'Courtyard', 'Small courtyard outside the studio for private usage.', 18),
(19, 'Balcony', 'A large balcony to enjoy the view', 19),
(20, 'Forest and Pool', 'The villa is surrounded by a beautiful wooded property on which the large 14x5 pool is arranged. with outdoor shower and in which we can prepare and enjoy a delicious barbecue in its glazed pavilion. There is also outdoor parking for 3 vehicles.', 20);

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `guestadresses`
--

CREATE TABLE `guestadresses` (
  `GuestAdressesID` int(11) NOT NULL,
  `GuestCountry` varchar(100) NOT NULL,
  `GuestRegion` varchar(100) NOT NULL,
  `GuestTown` varchar(100) NOT NULL,
  `GuestStreet` varchar(100) NOT NULL,
  `GuestHouseNumber` varchar(30) NOT NULL,
  `GuestZIPCode` varchar(30) NOT NULL,
  `GuestID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Daten für Tabelle `guestadresses`
--

INSERT INTO `guestadresses` (`GuestAdressesID`, `GuestCountry`, `GuestRegion`, `GuestTown`, `GuestStreet`, `GuestHouseNumber`, `GuestZIPCode`, `GuestID`) VALUES
(1, 'Austria', 'Lower Austria', 'Sallingstadt', 'Holzstrasse', '92', '3931', 1),
(2, 'USA', 'California', 'San Jose', 'Fairway Drive', '2891', '95113', 2),
(3, 'USA', 'Washington DC', 'Washington', 'Goldcliff Circle', '4114', '20007', 3),
(4, 'USA', 'Illinois', 'Elk Grove Village', 'Rebecca Street', '4412', '60007', 4),
(5, 'Australia', 'Queensland', 'Sarabah', 'Treasure Island Avenue', '74', '4275', 5),
(6, 'Australia', 'New South Wales', 'Curl', 'Queen Street', '107', '2096', 6),
(7, 'Germany', 'Freistaat Thüringen', 'Ahlstädt', 'Oldesloer Strasse', '37', '98553', 7),
(8, 'United Kingdom', 'n/a', 'York', 'St Dunstans Street', '93', 'CW11 7EY', 8),
(9, 'United Kingdom', 'North east', 'Wootton Green', 'Oxford Rd', '89', 'MK43 8YY', 9),
(10, 'France', 'Provence-Alpes-Côte d\'Azur', 'Marseille', 'Quai des Belges', '111', '13016', 10),
(11, 'Italy', 'Caserta', 'Totari', 'Via Varrone', '86', '81011', 11),
(12, 'Belgium', 'Antwerp', 'Wijnegem', 'Avenue des Sartiaux', '3132', '2110', 12),
(13, 'Czech Republic', 'Olomoucký kraj', 'Protivanov', 'Karafiatova', '1837', '798 48', 13),
(14, 'Japan', 'Niigata', 'Joetsu-shi', 'Kiyosatoku Sugahara', '350-1079', '943-0506', 14),
(15, 'India', 'Andhra Pradesh', 'Hyderabad', 'R P Road', '21-2-625', '500003', 15),
(16, 'Hungary', 'Békés', 'Gyula', 'Veres Pálné ', '46', '5703', 16),
(17, 'Denmark', 'Sjælland', 'København K', 'Højbovej', '87', '1120', 17),
(18, 'Austria', 'Burgenland', 'Marz', 'Falkstrasse ', '120', '7221', 18),
(19, 'Spain', 'Barcelona', 'Argentona', 'Benito Guinea', '106', '08310', 19),
(20, 'Sweden', 'n/a', 'trollhättan', 'Sörbylund', '110', '461 57', 20);

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `guestcontacts`
--

CREATE TABLE `guestcontacts` (
  `GuestEmailAdress` varchar(100) NOT NULL,
  `GuestPhoneNumber` varchar(100) NOT NULL,
  `GuestID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Daten für Tabelle `guestcontacts`
--

INSERT INTO `guestcontacts` (`GuestEmailAdress`, `GuestPhoneNumber`, `GuestID`) VALUES
('florian.müller@yahoo.com', '0681 740 57034', 1),
('jorge.hancock@gmail.com', '707-515-9888', 2),
('essie.wilson@outlook.net', '202-625-6491', 3),
('cierra.swift@yahoo.com', '847-787-3938', 4),
('matilda.niland@gmail.com', '(07) 5648 3503', 5),
('audrey.hickey@yahoo.net', '(02) 9133 1587', 6),
('nicole.egger@hotmail.de', '036873 86638', 7),
('lara.rhodes@gmail.com', '079 1620 1803', 8),
('lily.boyle@yahoo.net', '070 2726 6337', 9),
('amelia.garreau@outlook.eu', '04.82.90.51116', 10),
('eliana.boni@gmail.eu', '0390 9648288', 11),
('serge.landheer@gmail.eu', '0491 52 43254', 12),
('jan.kucera@outlook.com', '739 629 763', 13),
('kei.takeko@gmail.net', '+8196-735-0782', 14),
('bhikkhu.patkar@gmail.net', '04055217004', 15),
('karole.mihaly@hotmail.eu', '(66) 456-848', 16),
('magnus.mathiasen@gmail.com', '81-93-21904', 17),
('max.schanz@gmx.at', '0681 960 60119', 18),
('anelida.longoria@gmx.net', '676 542 560', 19),
('willy.olsson@gmail.com', '0520-4004023', 20);

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `guestreviews`
--

CREATE TABLE `guestreviews` (
  `GuestReviewID` int(11) NOT NULL,
  `GuestScore` decimal(1,0) NOT NULL,
  `GuestText` text DEFAULT NULL,
  `GuestReviewDate` date NOT NULL,
  `HostID` int(11) NOT NULL,
  `GuestID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Daten für Tabelle `guestreviews`
--

INSERT INTO `guestreviews` (`GuestReviewID`, `GuestScore`, `GuestText`, `GuestReviewDate`, `HostID`, `GuestID`) VALUES
(1, '5', 'Florian was nice and friendly', '2021-11-02', 1, 1),
(2, '5', 'Jorge was really complient with the rules and had no issues with him', '2021-11-02', 2, 2),
(3, '3', 'Essie was a hard to please guest with occasional complaints', '2021-11-02', 3, 3),
(4, '5', 'Cierra and her friends were really nice guests!', '2021-11-03', 4, 4),
(5, '4', 'Matilda and her friends were awesome guests!', '2021-11-03', 5, 5),
(6, '5', 'Audrey and her family were nice guests!', '2021-11-03', 6, 6),
(7, '5', 'Nicole was a great guest!', '2021-11-03', 7, 7),
(8, '5', '', '2021-11-03', 8, 8),
(9, '5', '', '2021-11-03', 9, 9),
(10, '5', 'No fuss with a perfect guest', '2021-11-03', 10, 10),
(11, '5', 'Great guest with no issues', '2021-11-03', 11, 11),
(12, '5', 'Sergey was a great compliant guest', '2021-11-03', 12, 12),
(13, '5', 'Compliant to all rules and really friendly', '2021-11-03', 13, 13),
(14, '5', 'Amazing guest with good sense of humor', '2021-11-03', 14, 14),
(15, '5', '', '2021-11-03', 15, 15),
(16, '5', 'A nice guest with a good sense of humor', '2021-11-04', 16, 16),
(17, '5', 'Great guest!', '2021-11-04', 17, 17),
(18, '5', 'Max was a really nice guest!', '2021-11-04', 18, 18),
(19, '5', 'An amazing guest!', '2021-11-04', 19, 19),
(20, '5', 'Friendly guest, had no issues!', '2021-11-04', 20, 20);

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `guests`
--

CREATE TABLE `guests` (
  `GuestID` int(11) NOT NULL,
  `GuestName` varchar(100) NOT NULL,
  `GuestSurname` varchar(100) NOT NULL,
  `GuestAge` decimal(3,0) NOT NULL,
  `CurrencyCode` char(3) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Daten für Tabelle `guests`
--

INSERT INTO `guests` (`GuestID`, `GuestName`, `GuestSurname`, `GuestAge`, `CurrencyCode`) VALUES
(1, 'Florian', 'Müller', '30', 'EUR'),
(2, 'Jorge', 'Hancock', '24', 'USD'),
(3, 'Essie', 'Wilson', '62', 'USD'),
(4, 'Cierra', 'Swift', '40', 'USD'),
(5, 'Matilda', 'Niland', '19', 'AUD'),
(6, 'Audrey', 'Hickey', '35', 'AUD'),
(7, 'Nicole', 'Egger', '24', 'EUR'),
(8, 'Lara', 'Rhodes', '28', 'GBP'),
(9, 'Lily', 'Boyle', '50', 'GBP'),
(10, 'Amelia', 'Garreau', '31', 'EUR'),
(11, 'Eliana', 'Boni', '46', 'EUR'),
(12, 'Serge', 'Landheer', '52', 'EUR'),
(13, 'Jan', 'Kucera', '72', 'CZK'),
(14, 'Kei', 'Takeko', '22', 'JPY'),
(15, 'Bhikkhu', 'Patkar', '27', 'INR'),
(16, 'Karole', 'Mihály', '44', 'HUF'),
(17, 'Magnus', 'Mathiasen', '54', 'DKK'),
(18, 'Max', 'Schanz', '33', 'EUR'),
(19, 'Anelida', 'Longoria', '64', 'EUR'),
(20, 'Willy', 'Olsson', '41', 'SEK');

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `host`
--

CREATE TABLE `host` (
  `HostID` int(11) NOT NULL,
  `HostName` varchar(100) NOT NULL,
  `HostSurname` varchar(100) NOT NULL,
  `HostAge` decimal(3,0) NOT NULL,
  `CurrencyCode` char(3) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Daten für Tabelle `host`
--

INSERT INTO `host` (`HostID`, `HostName`, `HostSurname`, `HostAge`, `CurrencyCode`) VALUES
(1, 'Derrick', 'Harriman', '40', 'USD'),
(2, 'Cendrillon', 'Patel', '35', 'EUR'),
(3, 'Paola', 'Giordano', '37', 'EUR'),
(4, 'Dean', 'Gonzalez', '60', 'USD'),
(5, 'Jassin', 'Verschuren', '45', 'EUR'),
(6, 'Julia', 'Steiner', '31', 'EUR'),
(7, 'Pilmayquen', 'Tirado', '42', 'EUR'),
(8, 'Stašo', 'Randl', '41', 'EUR'),
(9, 'Iza', 'Martinsson', '31', 'SEK'),
(10, 'Jake', 'Leonard', '35', 'GBP'),
(11, 'Zdeňka', 'Fabiánková', '50', 'CZK'),
(12, 'Hideyoshi', 'Tanihata', '27', 'JPY'),
(13, 'Johnny', 'Doyle', '40', 'EUR'),
(14, 'Chinja', 'Parkar', '45', 'INR'),
(15, 'Peter', 'Szegedi', '70', 'HUF'),
(16, 'Jakob', 'Bertelsen', '22', 'DKK'),
(17, 'Klaudia', 'Zimmer', '45', 'EUR'),
(18, 'Anne', 'Thimmesch', '31', 'EUR'),
(19, 'Abelardo', 'Bellucci', '34', 'EUR'),
(20, 'Mirtha ', 'Quiroz', '50', 'EUR');

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `hostadresses`
--

CREATE TABLE `hostadresses` (
  `HostAdressesID` int(11) NOT NULL,
  `HostCountry` varchar(100) NOT NULL,
  `HostRegion` varchar(100) NOT NULL,
  `HostTown` varchar(100) NOT NULL,
  `HostStreet` varchar(100) NOT NULL,
  `HostHouseNumber` varchar(30) NOT NULL,
  `HostZIPCode` varchar(30) NOT NULL,
  `HostID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Daten für Tabelle `hostadresses`
--

INSERT INTO `hostadresses` (`HostAdressesID`, `HostCountry`, `HostRegion`, `HostTown`, `HostStreet`, `HostHouseNumber`, `HostZIPCode`, `HostID`) VALUES
(1, 'USA', 'New Jersey', 'Newark', 'Drummond Street', '3021', '07102', 1),
(2, 'France', 'Rhône-Alpes', 'lyon', 'rue de la République', '37', '69002', 2),
(3, 'Italy', 'Frosinone', 'Campoli Appennino', 'Via Partenope', '1017', '03030', 3),
(4, 'USA', 'Michigan', 'Southfield', 'Woodbridge Lane', '297', '48235', 4),
(5, 'Belgium', 'East Flanders', 'Gentbrugge', 'Rue de Fromelenne', '4104', '9050', 5),
(6, 'Austria', 'Upper Austria', 'Schwallenbach', 'Silvrettastrasse', '82', '3620', 6),
(7, 'Spain', 'Granada', 'Jerez del Marquesado', 'Cádiz', '41', '18518', 7),
(8, 'Slovenia', 'n/a', 'Maribor', 'Parmova', '68', '2503', 8),
(9, 'Sweden', 'n/a', 'Åkersberga', 'Lemesjö', '107', '184 19', 9),
(10, 'United Kingdom', 'n/a', 'Willbery', 'Ramsgate Rd', '71', 'HU10 0JA', 10),
(11, 'Czech Republic', 'Plzenský kraj', 'Stríbro', 'Na Výsluní', '14109', '349 01', 11),
(12, 'Japan', 'Okayama', 'Kita-ku Okayama-shi', 'Fukuzaki', '340-1141', '701-1357', 12),
(13, 'Ireland', 'County Wexford', 'Enniscorthy', 'Ballyhogue Enniscorthy', '14', 'n/a', 13),
(14, 'India', 'Maharashtra', 'Mumbai', 'Narayan Nagar Road', '79', '380007', 14),
(15, 'Hungary', 'n/a', 'Kámaháza', 'Kis Diófa', '19', '9982', 15),
(16, 'Denmark', 'Syddanmark', 'Vester Skerninge', 'Clematisvænget', '117', '5762', 16),
(17, 'Germany', 'Bayern', 'München', 'Kurfuerstendamm', '138', '80016', 17),
(18, 'Luxembourg', 'n/a', 'Mondorf-Les-Bains', 'Rue Des Vignes', '57', 'n/a', 18),
(19, 'Italy', 'Milano', 'Villaggio Snia', 'Via San Pietro Ad Aram', '130', '20030', 19),
(20, 'Spain', 'Salamanca', 'San Pelayo de Guareña', 'Rúa de San Pedro', '47', '37797', 20);

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `hostcontacts`
--

CREATE TABLE `hostcontacts` (
  `HostEmailAdress` varchar(100) NOT NULL,
  `HostPhoneNumber` varchar(100) NOT NULL,
  `HostID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Daten für Tabelle `hostcontacts`
--

INSERT INTO `hostcontacts` (`HostEmailAdress`, `HostPhoneNumber`, `HostID`) VALUES
('derrick.harriman@outlook.com', '973-297-1896', 1),
('cendrillon.patel@gmail.com', '04.24.79.19625', 2),
('paola.giordano@outlook.net', '0392 3885996', 3),
('dean.gonzalez@outlook.com', '248-497-2073', 4),
('jassin.verschuren@gmx.net', '0473 80 72743', 5),
('julia.steiner@gmx.at', '0664 582 03437', 6),
('pilmayquen.tirado@outlook.net', '649 148 398', 7),
('stašo.randl@yahoo.com', '051-242-051', 8),
('iza.martinsson@outlook.com', '08-4550457', 9),
('jake.leonard@outlook.com', '078 4000 6353', 10),
('zdeňka.fabiánková@yahoo.net', '374 936 715', 11),
('hideyoshi.tanihata@yahoo.net', '+8156-824-2519', 12),
('johnny.doyle@outlook.net', '(053)9247072', 13),
('chinja.parkar@outlook.com', '00792644365', 14),
('peter.szegidi@yahoo.eu', '(94) 106-852', 15),
('jakob.bertelsen@yahoo.net', '24-49-49830', 16),
('klaudia.zimmer@hotmail.de', '089 77 03905', 17),
('anne.thimmesch@yahoo.com', '621 492 152', 18),
('abelardo.belluci@yahoo.com', '0325 9727354', 19),
('mirtha.quiroz@yahoo.net', '787 269 933', 20);

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `hostreviews`
--

CREATE TABLE `hostreviews` (
  `HostReviewID` int(11) NOT NULL,
  `HostScore` decimal(1,0) NOT NULL,
  `HostText` text DEFAULT NULL,
  `HostReviewDate` date NOT NULL,
  `HostID` int(11) NOT NULL,
  `GuestID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Daten für Tabelle `hostreviews`
--

INSERT INTO `hostreviews` (`HostReviewID`, `HostScore`, `HostText`, `HostReviewDate`, `HostID`, `GuestID`) VALUES
(1, '5', 'Derrick was a great host!', '2021-11-02', 1, 1),
(2, '5', 'Cendrillon was really nice and helpful', '2021-11-02', 2, 2),
(3, '3', 'The host was nice but often unresponsive to my complaints', '2021-11-02', 3, 3),
(4, '5', '10/10', '2021-11-03', 4, 4),
(5, '5', 'Jassin was really nice and helfpful!', '2021-11-03', 5, 5),
(6, '5', 'Julia was a great host!', '2021-11-03', 6, 6),
(7, '4', 'Pilmayquen showed as everything and friendly', '2021-11-03', 7, 7),
(8, '5', ' Stašo is a great host. Communication was from start to finish too. If I have any questions or requests, always approach him. He invited me to serve myself freely in his garden, where there are salads and all kinds of cruisers. My next time at Lake Bled will definitely be back at Stašo!', '2021-11-03', 8, 8),
(9, '5', '10/10', '2021-11-03', 9, 9),
(10, '5', 'Always available for communication', '2021-11-03', 10, 10),
(11, '5', 'Beautiful apartment - nice host', '2021-11-03', 11, 11),
(12, '5', 'The host was helpful and responsive - he was kind to pick me up from the station, offered suggestions for things to do', '2021-11-03', 12, 12),
(13, '5', 'A fantastic stay! Sandra was an excellent host from communication to the surprise treats she left us. ', '2021-11-03', 13, 13),
(14, '5', 'he owner is very kind and friendly and has amazing stories to share.', '2021-11-03', 14, 14),
(15, '5', 'Great helpful host', '2021-11-03', 15, 15),
(16, '5', ' The hosts are very friendly, the handover of the keys went very well.', '2021-11-04', 16, 16),
(17, '5', 'Very wonderful hostess!', '2021-11-04', 17, 17),
(18, '5', 'great host - very friendly and helpful', '2021-11-04', 18, 18),
(19, '5', 'A nice and friendly host!', '2021-11-04', 19, 19),
(20, '5', 'Great host!', '2021-11-04', 20, 20);

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `income`
--

CREATE TABLE `income` (
  `IncomeID` int(11) NOT NULL,
  `Income` decimal(20,2) DEFAULT NULL,
  `IncomeTime` datetime NOT NULL,
  `AccommodationID` int(11) NOT NULL,
  `PayConfirmationID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Daten für Tabelle `income`
--

INSERT INTO `income` (`IncomeID`, `Income`, `IncomeTime`, `AccommodationID`, `PayConfirmationID`) VALUES
(1, '60.00', '2021-12-02 14:30:01', 1, 1),
(2, '1000.00', '2021-11-02 11:19:41', 2, 2),
(3, '500.00', '2021-11-02 11:59:45', 3, 3),
(4, '456.00', '2021-11-03 08:58:00', 4, 4),
(5, '90.00', '2021-11-03 09:10:19', 5, 5),
(6, '566.00', '2021-11-03 09:33:32', 6, 6),
(7, '750.00', '2021-11-03 09:50:54', 7, 7),
(8, '458.00', '2021-11-03 10:01:05', 8, 8),
(9, '105.00', '2021-11-03 10:11:51', 9, 9),
(10, '625.00', '2021-11-03 10:21:44', 10, 10),
(11, '170.00', '2021-11-03 10:35:04', 11, 11),
(12, '88.00', '2021-11-03 10:49:08', 12, 12),
(13, '500.00', '2021-11-03 11:17:39', 13, 13),
(14, '216.00', '2021-11-03 11:30:12', 14, 14),
(15, '175.00', '2021-11-03 11:47:42', 15, 15),
(16, '96.00', '2021-11-04 08:48:14', 16, 16),
(17, '229.00', '2021-11-04 09:05:50', 17, 17),
(18, '79.00', '2021-11-04 09:19:03', 18, 18),
(19, '440.00', '2021-11-04 09:33:57', 19, 19),
(20, '10000.00', '2021-11-04 09:47:16', 20, 20);

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `interiors`
--

CREATE TABLE `interiors` (
  `InteriorID` int(11) NOT NULL,
  `InteriorDescription` text DEFAULT NULL,
  `RoomNumber` decimal(3,0) DEFAULT NULL,
  `AccommodationID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Daten für Tabelle `interiors`
--

INSERT INTO `interiors` (`InteriorID`, `InteriorDescription`, `RoomNumber`, `AccommodationID`) VALUES
(1, 'Space is shared with two other people but they have their own bathroom and are always out of the house', '5', 1),
(2, 'Our guests have their own entrance, completely independent. A kitchen and a bathroom with a shower, they will be in absolute privacy.', '5', 2),
(3, 'The apartment is prepared with fresh linens and towels.', '5', 3),
(4, 'Indoor fireplace to stay warm & cozy on chilly northern nights!', '5', 4),
(5, 'Complete studio with kitchen and bathroom exclusive for guests.', '5', 5),
(6, '3-room villa 90 m2 on 2 levels. Very tasteful and stylish furnishings: entrance hall. Living room with tiled stove. 1 double room with shower / toilet. Kitchen (4 hot plates, oven, dishwasher, microwave) with dining area. Sep WC. Upper floor: 1 double bedroom', '5', 6),
(7, '', '5', 7),
(8, 'The house is equipped with handmade furniture. The small kitchen is spacious enough for you to prepare homemade teas and proper Slovenian coffee. Making yourself one of these drinks, you can relax on a lovely terrace with a view of the neighbouring pasture where horses graze.', '5', 8),
(9, 'Newly renovated guesthouse Blomsterbo, approximately 30 m2, which is ecxcellent for 1-2 persons, good for 3 persons for maximum a week, but can be equipted with an extra matress for a short stay of 4 people.', '5', 9),
(10, 'Accommodation - The end terraced house is refurbished to a high standard and we are positive that you will find everything you need for a very comfortable stay.', '5', 10),
(11, 'You can use anything you find in the flat, which includes Nespresso coffee, tea, dishwasher, airconditioning, hairdryer, basic cosmetics, quide books, map, binocular, umbrella if needed.', '5', 11),
(12, 'You will not share with owner or other guests.', '5', 12),
(13, 'A beautiful, romantic getaway located on the banks of Lough Atalia, just off Galway Bay. This luxurious and historical Dutch barge has been lovingly restored, transforming it into an extremely spacious and comfortable space.', '5', 13),
(14, 'Owner too lives in the same premises , guest have access to their three bedrooms , living area , dining space , Study Room , Gazebo and 6 acres of open land , guest can do trekking to our other property which is a 15 minutes trek surrounded by tall deodar trees .', '5', 14),
(15, 'The house has 2 bicycles, their use, firewood, fireplace, grill and tourist tax are included in the price. The 20s usually have reception in the house, the 30s vary, the 70s have no WiFi, so that you can completely switch off from everyday life!', '5', 15),
(16, 'The house has a well-equipped new kitchen and the bedroom can be used as a living room.', '5', 16),
(17, 'Ökologisch ausgebaute ehemalige Scheune mit viel Einsatz von Holz und anderen natürlichen Materialien (KEIN Laminat) mit einer großen Wohnküche und Veranda auf der selben Ebene lässt Urlaubsgefühle aufkommen. Im Obergeschoss grenzt die große, 12qm große Loggia an das Schlafzimmer, auf dieser Etage befindet sich auch das Badezimmer. Gäste mit Vorliebe für das Besondere werden den Aufenthalt hier genießen.', '5', 17),
(18, 'Small studio with own bathroom and kitchen facilities.', '5', 18),
(19, ' The accommodation has ironing facilities, internet access (WiFi), a hair dryer, a balcony, a gas boiler, fans, and a TV. The separate kitchen with gas hob is equipped with a refrigerator, microwave, oven, freezer, washing machine, dishwasher, dishes / cutlery, kitchen utensils, coffee machine, toaster, kettle and juicer.', '7', 19),
(20, 'Very bright villa, equipped with a pantry with washing machine, a partially open kitchen, fully equipped with gas cooker and dishwasher. The double-height living and dining room has a DVB-T / satellite TV and communicates on the one hand with the covered outdoor terrace that leads to the pool area, and on the other hand with a bedroom with double bed and air conditioning and a bathroom en suite with shower and bathtub and Access to the pool via a separate terrace. On the other hand, the villa has another double bedroom with air conditioning, a bedroom with two single beds and a separate bathroom with shower', '3', 20);

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `kitchens`
--

CREATE TABLE `kitchens` (
  `KitchenID` int(11) NOT NULL,
  `KitchenName` varchar(100) NOT NULL,
  `KitchenDescription` text DEFAULT NULL,
  `InteriorID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Daten für Tabelle `kitchens`
--

INSERT INTO `kitchens` (`KitchenID`, `KitchenName`, `KitchenDescription`, `InteriorID`) VALUES
(1, 'Private kitchen', 'Access to private kitchen with standard equipment', 1),
(2, 'Private kitchen', 'The kitchen like the bathroom, will be completly private.', 2),
(3, 'Private kitchen', 'Every apartment has their own kitchen', 3),
(4, 'Kitchen', '- Full Kitchen with Most Major Appliances + Stocked with All the Cookware, Glassware, Plates, + Utensils You May Need. - Coffee, Tea, Sugar, + Creamer Provided. - Charcoal Grill + Utensils for Grilling.', 4),
(5, 'Kitchen', 'kitchen exclusive for guests. ', 5),
(6, 'Kitchen', 'A kitchen with standard equipment', 6),
(7, 'Kitchen', 'Kitchen which fullfills all demands', 7),
(8, 'Outdoor kitchen', 'Outdor kitchen is fully equipt with two seperate kitchen work surface, where there can be used for six people. There is also space to seat, enyoj and socializing with other guest.', 8),
(9, 'Mini kitchen', 'Mini kitchen where you can cook food, a dining table, and a desk', 9),
(10, 'Kitchen', 'very well equipped with usual equipment and appliances including electric oven, gas hob, microwave and dishwasher. There is a dining area with room for up to 6 people.', 10),
(11, 'Rooftop kitchen', 'Kitchen is on the roof making for great meals', 11),
(12, 'Open kitchen', 'open kitchen with whole kitchen set where you can prepare your own meals.', 12),
(13, 'Kitchen', 'The boat is made up of a large kitchen with beautiful granite counter-tops and breakfast bar, a large open-plan dining area and lounge. We ask guests to please enjoy the kitchen but NO FRYING, or cooking anything with strong scents as the boat is open plan and we would like to protect the furnishings etc. from gathering odors.', 13),
(14, 'Kitchen', 'Old fashioned kitchen', 14),
(15, 'Kitchen', 'A small vintage style kitchen', 15),
(16, 'Kitchen', 'A normal kitchen with all accesories', 16),
(17, 'Kitchen', 'The kitchen is normal spaced', 17),
(18, 'Kitchen', 'Small kitchen with only necessities', 18),
(19, 'Kitchen', ' The separate kitchen with gas hob is equipped with a fridge, a microwave and an oven', 19),
(20, 'Kitchen', 'Spacious kitchen ', 20);

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `livingrooms`
--

CREATE TABLE `livingrooms` (
  `LivingRoomID` int(11) NOT NULL,
  `LivingRoomName` varchar(100) NOT NULL,
  `LivingRoomDescription` text DEFAULT NULL,
  `InteriorID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Daten für Tabelle `livingrooms`
--

INSERT INTO `livingrooms` (`LivingRoomID`, `LivingRoomName`, `LivingRoomDescription`, `InteriorID`) VALUES
(1, 'General living area', 'Guests are free to use the living area, which are the common spaces', 1),
(2, 'Private living room', 'Your own private living room is also included', 2),
(3, 'Public living room', 'The living room is shared with the other guests', 3),
(4, 'Living room', 'Have a larger group or want to get the whole family together!', 4),
(5, 'Living room', 'Living room is connected to the terrace to enjoy the garden.', 5),
(6, 'Living room', 'Spacious living room for your whole family', 6),
(7, 'Living room', 'A private living room for all your friends', 7),
(8, 'Living room', 'A spacious living room', 8),
(9, 'Living room', 'A small living room ', 9),
(10, 'Lounge area', 'plenty of comfy sofa space, parquet flooring.', 10),
(11, 'Living room', 'Spacious living room for you to enjoy', 11),
(12, 'Living room', 'A normal living room where you can relax', 12),
(13, 'Lounge', 'The lounge has a wood/turf burning stove and a wicker basket of turf will be supplied should the evenings in Galway get a little chilly, and you want to snuggle up in front of a real fire. ', 13),
(14, 'Living room', 'Cozy living room for you', 14),
(15, 'Living room', 'A cozy living room with a chimney', 15),
(16, 'Living room', 'Spacious living room in old fashioned style', 16),
(17, 'Living room', 'A smaller living room for cozy nights', 17),
(18, 'Living room', 'Small living room with a TV', 18),
(19, 'Living room', 'A spacious living room to enjoy the nights', 19),
(20, 'Living room', 'A spacious living room for nights with friends', 20);

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `locations`
--

CREATE TABLE `locations` (
  `LocationID` int(11) NOT NULL,
  `LocationCountry` varchar(100) NOT NULL,
  `LocationRegion` varchar(100) NOT NULL,
  `LocationTown` varchar(100) NOT NULL,
  `LocationStreet` varchar(100) NOT NULL,
  `LocationHouseNumber` varchar(30) NOT NULL,
  `LocationZIPCode` varchar(30) NOT NULL,
  `LocationDescription` text DEFAULT NULL,
  `AccommodationID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Daten für Tabelle `locations`
--

INSERT INTO `locations` (`LocationID`, `LocationCountry`, `LocationRegion`, `LocationTown`, `LocationStreet`, `LocationHouseNumber`, `LocationZIPCode`, `LocationDescription`, `AccommodationID`) VALUES
(1, 'USA', 'New Jersey', 'Rochester', 'Tuna Street', '2800', '55901', 'Looking for the perfect place to stay by NYC? Look no further! My space is perfect for people who want to visit NYC but do not want to pay NYC prices. Steps away from public transportation and very close to NYC! You will not regret staying at my space and I look forward to hosting you!', 1),
(2, 'France', 'Paris', 'Anatole France', 'Champ de Mars', '45', '75007', 'Your own piece of Paris... you won\'t have another occasion to see the Tour Eiffel this close. Just renewed this is a wonderful design room, independent, where you\'ll feel all the magic of the most beautiful city in the world. You can almost touch the Tour while lying on your bed or while having dinner you prepared your self in the mini full-equipped kitchen.', 2),
(3, 'Italy', 'Messina', 'Gallodoro', 'Via San Domenico Soriano', '146', '98030', 'This snug apartment, situated on the 3nd floor of a sonny medieval building, is just in front of the Pantheon temple, one of the most characteristic monuments of ancient Rome. The charming ancient atmosphere of this place is dreamlike.', 3),
(4, 'USA', 'Michigan', 'Phoenix', 'Crowfield Road', '102', '85017', 'Feel Inspired by TC\'s North Coast Vibes in this Beautiful 1940\'s Chalet, Perfectly Located for All Adventures! Wake Up Sipping Coffee while Taking in the Seasonal Changes and Crisp Morning Air Before Heading Out to Hit the Trails & Explore the Area\'s Most Abundantly Beautiful Time of Year. In the Evening, get in the Spirit with Local Festivities or Wander into Downtown for Shopping, Dinner, & Drinks Before Heading Back to Enjoy some much Needed Relaxation in the Hot Tub & a Cozy Fireplace!', 4),
(5, 'Belgium', 'Liège', 'Ferrières', 'Rue du Moulin', '4032', '4190', 'Find peace and tranquility right in the historic center of \"patershol\". This unique location is at a few hundred meters from the castle \"gravensteen\" but still accessible by car if needed to unload your luggage.', 5),
(6, 'Austria', 'Upper Austria', 'Forstau', 'Goethestrasse', '44', '4593', 'Historical finca \"Rosenvilla\", located in the spa gardens, from the 19th century, renovated. Central, sunny location. Private: park 1\'700 m2 with a beautiful garden to relax.', 6),
(7, 'Spain', 'Granada', 'Jayena', 'Paseo del Atlántico', '72', '18127', 'What the location? You are just about a 15-minute walk from the beach and the center of Calpe.', 7),
(8, 'Slovenia', 'n/a', 'Dornava', 'Slovenčeva', '86', '2252', 'Only a 250 m walk through a small forest takes you to the natural swimming area from where boatsmen take you with the traditional Pletna boat to the Bled Island, adorned by a medieval church with a wishing bell. Due to the excellent location of the house, you can in a very short time visit the exceptionally beautiful nearby touristic attractions and trekking routes on foot, by bike or car (Pokljuka plateau, Lake Bohinj, Julian Alps, Kranjska Gora, etc.).', 8),
(9, 'Sweden', 'n/a', 'Garphyttan', 'Sandviken', '60', '710 16', 'Wonderful beach promenade along the sea in a nature reserve with rare birds 300 meters from the accommodation. Grocery store, health center, dentist, library and church within 5-10 minutes walk. Bus stop around the corner that takes you to Copenhagen and airport within 30 minutes. Several beaches nearby. Victoria Park with SPA, massage and pool as well as good lunch in beautiful surroundings 30 minutes walk away. The limestone quarry, a wonderful walk around is located in the same area. Limhamn, Sibbarp - 2 charming fishing villages with beaches on the way to Malmö. And do not miss a walk to charming Strandhem and bring your swimsuit! Tennis court around the corner as well as several exellent golf courses, area good for kite surfing.', 9),
(10, 'United Kingdom', 'n/a', 'Midford', 'Botley Road', '44', 'BA2 3GS', 'The cottage is in the heart of the beautiful Port Sunlight on the Wirral. It is ideally located for exploring this stunning historic village as well as the Wirral peninsula, Cheshire and Merseyside. A few steps away is the Port Sunlight train station with direct trains to Liverpool and Chester leaving every few minutes We are sure you will enjoy staying here. We look forward to welcoming you soon!', 10),
(11, 'Czech Republic', 'Prague', 'Rájec-Jestrebí', 'Na Loučkách', '490', '679 02', 'Newly refurbished studio in attic with a terrace and a view of the old Prague, placed in Zizkov district, 1 tram stop from the Main train station, within a walking distance to the city center. Yet still central enough,this place will give you an unforgettable experience of the original lifestyle, as well inexhaustable choice of traditional pubs and bars in the place. Zizkov is often searched and asked by travelers, who want to experience the local life! Travelers of all nations are very welcome', 11),
(12, 'Japan', 'Hokkaido', 'Engaru-cho Mombetsu-gun', 'Ikutahara Toyohara', '306-1019', '099-0624', 'Fuku Lodge is located in Hakuba Village in the Japanese Northern Alps, Nagano Prefecture, away from the hustle and bustle of the city. When you wake up in the morning, you can find beautiful scenery and resting birds from the windows. You can meet cute creatures such as stag beetles and beetles that sometimes appear in the evening ...', 12),
(13, 'Ireland', 'County Cork', 'Cork', 'Dosco Ind. Est., Sth Douglas Rd.', 'n/a', 'n/a', ' It is located right next to the G Hotel, the hugely popular Huntsman Inn and with shops and a bus stop close by. It is approximately a 15 minute walk to Eyre Square along the banks of Lough Atalia.', 13),
(14, 'India', 'Maharashtra', 'Pune', 'Centre Street', '585', '411001', 'A Heritage property Built in the Year 1909 , Located Near Taradevi Temple surrounded by lush green environs , A private estate spread across 6 acres of Land. Ideal for folks who want to stay away from the City crowd amidst nature . writers , bird watchers and nature lovers . just 500 meter off road will take you to this hidden gem of tranquility you could call our caretaker for assistance in driving the last stretch .', 14),
(15, 'Hungary', 'n/a', 'Kismaros Börzsönyliget', 'Csavargyár', '4949', '8887', 'Our forest hut is a dog-friendly guesthouse in Kismaros Börzsönyliget.', 15),
(16, 'Denmark', 'Sjælland', 'København K', 'Lersey Allé', '52', '1240', 'Natural plot of 1600 m² with protected spaces and direct access to a protected dune plantation.', 16),
(17, 'Germany', 'Niedersachsen', 'Nordholz', 'Bissingzeile', '85', '27637', 'For lovers of an extraordinary, natural and cozy living atmosphere in a green idyll - and still close to the city - with shops very close by.', 17),
(18, 'Luxembourg', 'Luxembourg', 'Luxembourg', 'Boulevard Pierre Dupong', '34', 'n/a', 'near the city center behind a family home.', 18),
(19, 'Italy', 'Viterbo', 'Grotte Santo Stefano', 'Via Lagrange', '151', '01026', 'The accommodation is located 500 m from the La Punta sandy beach, 30 km from the city of Como, 20 km from the city of Lecco, 1 km from the supermarket \"Migross\", 200 m from the supermarket, 1 km from the supermarket \"SIDIS\", 150 km from \"Milano Malpensa\" airport, 30 km from \"Como\" train station, 25 km from \"Lecco\" train station, 100 m from the \"Bellagio Imbarcadero\" bus stop, 10 m from, 20 m from, 10 m from \"Bar Rossi\", 150 km from \"Milano Malpensa\", 100 km from \"Bergamo Orio al Serio\", in a busy area and close to shops and restaurants.', 19),
(20, 'Spain', 'Barcelona', 'Caldes de Montbui', 'Cercas Bajas', '71', '08140', 'The villa is located in the charming area of ​​Oltá, a quiet area with wonderful views of the Peñón de Ifach and just a few minutes drive from the center of Calpe.', 20);

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `otherrooms`
--

CREATE TABLE `otherrooms` (
  `OtherRoomID` int(11) NOT NULL,
  `OtherRoomName` varchar(100) NOT NULL,
  `OtherRoomDescription` text DEFAULT NULL,
  `InteriorID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Daten für Tabelle `otherrooms`
--

INSERT INTO `otherrooms` (`OtherRoomID`, `OtherRoomName`, `OtherRoomDescription`, `InteriorID`) VALUES
(1, 'Bar', 'Guests are free to use the bar', 1),
(2, 'Attic', 'You also have access to an attic, where you can watch the sky', 2),
(3, 'Cellar', 'The cellar can be used as storage room', 3),
(4, 'Attic', 'The attic can be used for sky viewing', 4),
(5, 'Attic', 'The studio has an additional attic!', 5),
(6, 'Cellar', 'The cellar can be used for storage', 6),
(7, 'Bar', 'The accommodation also has a bar for nights with guests', 7),
(8, 'Attic', 'The log also has an attic for viewing the stars', 8),
(9, 'Cellar', 'The cellar contains equipment for the beach', 9),
(10, 'Garden house', 'The property also has a small garden house', 10),
(11, 'Bar', 'A bar is also included for party nights', 11),
(12, 'Attic', 'The is used as a storage room', 12),
(13, 'Boat deck', 'The deck of the boat is also accessible, which makes for great views', 13),
(14, 'Cellar', 'The property also has a cellar', 14),
(15, 'Attic', 'The attic is locked, since it is mostly used as storage room', 15),
(16, 'Cellar', 'The property also has a cellar as storage room', 16),
(17, 'Cellar', 'A washing machine and dryer are located in the basement, which is on the front of the house and can be used at any time.', 17),
(18, 'Garden house', 'The property contains a garden house, which can also be used', 18),
(19, 'Attic', 'A spacious attic can be used as storage room', 19),
(20, 'Cellar', 'The accommodation has a cellar, which is not to be accessed', 20);

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `payconfirmations`
--

CREATE TABLE `payconfirmations` (
  `PayConfirmationID` int(11) NOT NULL,
  `ConfirmationCancellation` tinyint(1) DEFAULT NULL,
  `CancellationConfirmationTime` date DEFAULT NULL,
  `PossibleCancellationTime` date NOT NULL,
  `PaymentID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Daten für Tabelle `payconfirmations`
--

INSERT INTO `payconfirmations` (`PayConfirmationID`, `ConfirmationCancellation`, `CancellationConfirmationTime`, `PossibleCancellationTime`, `PaymentID`) VALUES
(1, 1, '2021-11-02', '2021-12-02', 1),
(2, 1, '2021-11-02', '2021-11-04', 2),
(3, 1, '2021-11-02', '2021-11-05', 3),
(4, 1, '2021-11-03', '2021-11-05', 4),
(5, 1, '2021-11-03', '2021-11-07', 5),
(6, 1, '2021-11-03', '2021-11-06', 6),
(7, 1, '2021-11-03', '2021-11-06', 7),
(8, 1, '2021-11-03', '2021-11-09', 8),
(9, 1, '2021-11-03', '2021-11-09', 9),
(10, 1, '2021-11-03', '2021-11-06', 10),
(11, 1, '2021-11-03', '2021-11-11', 11),
(12, 1, '2021-11-03', '2021-11-06', 12),
(13, 1, '2021-11-03', '2021-11-07', 13),
(14, 1, '2021-11-03', '2021-11-07', 14),
(15, 1, '2021-11-03', '2021-11-07', 15),
(16, 1, '2021-11-04', '2021-11-06', 16),
(17, 1, '2021-11-04', '2021-11-07', 17),
(18, 1, '2021-11-04', '2021-11-07', 18),
(19, 1, '2021-11-04', '2021-11-07', 19),
(20, 1, '2021-11-04', '2021-11-07', 20);

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `paymentmethods`
--

CREATE TABLE `paymentmethods` (
  `PaymentMethod` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Daten für Tabelle `paymentmethods`
--

INSERT INTO `paymentmethods` (`PaymentMethod`) VALUES
('Amazon Pay'),
('Apple Pay'),
('Authorize.net'),
('Credit Card'),
('Due'),
('Dwolla'),
('Freshbooks'),
('giropay'),
('Klarna'),
('Moneris'),
('paydirect'),
('PaymentMethod'),
('Paymorrow'),
('PayPal'),
('Saferpay'),
('sepa direct debit'),
('Skrill'),
('Square'),
('Stripe'),
('WildApricot Payments');

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `payments`
--

CREATE TABLE `payments` (
  `PaymentID` int(11) NOT NULL,
  `PaymentAmount` decimal(20,2) DEFAULT NULL,
  `PaymentMethod` varchar(100) NOT NULL,
  `PaymentTime` datetime NOT NULL,
  `GuestID` int(11) NOT NULL,
  `PriceID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Daten für Tabelle `payments`
--

INSERT INTO `payments` (`PaymentID`, `PaymentAmount`, `PaymentMethod`, `PaymentTime`, `GuestID`, `PriceID`) VALUES
(1, '60.00', 'PayPal', '2021-11-02 12:01:00', 1, 1),
(2, '1000.00', 'Amazon Pay', '2021-11-02 10:59:44', 2, 2),
(3, '500.00', 'Apple Pay', '2021-11-02 09:56:21', 3, 3),
(4, '456.00', 'Authorize.net', '2021-11-03 08:54:24', 4, 4),
(5, '90.00', 'Credit Card', '2021-11-03 09:06:53', 5, 5),
(6, '566.00', 'Due', '2021-11-03 09:33:16', 6, 6),
(7, '750.00', 'Dwolla', '2021-11-03 09:50:35', 7, 7),
(8, '457.50', 'Freshbooks', '2021-11-03 10:00:44', 8, 8),
(9, '105.00', 'giropay', '2021-11-03 10:11:22', 9, 9),
(10, '625.00', 'Klarna', '2021-11-03 10:21:24', 10, 10),
(11, '170.00', 'Moneris', '2021-11-03 10:34:49', 11, 11),
(12, '88.00', 'PaymentMethod', '2021-11-03 10:48:54', 12, 12),
(13, '500.00', 'Paymorrow', '2021-11-03 11:17:22', 13, 13),
(14, '216.00', 'Saferpay', '2021-11-03 11:29:27', 14, 14),
(15, '175.00', 'sepa direct debit', '2021-11-03 11:46:34', 15, 15),
(16, '96.00', 'Skrill', '2021-11-04 08:47:47', 16, 16),
(17, '228.60', 'Square', '2021-11-04 09:00:08', 17, 17),
(18, '79.00', 'Stripe', '2021-11-04 09:18:28', 18, 18),
(19, '440.00', 'Stripe', '2021-11-04 09:33:16', 19, 19),
(20, '10000.00', 'WildApricot Payments', '2021-11-04 09:46:57', 20, 20);

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `prices`
--

CREATE TABLE `prices` (
  `PriceID` int(11) NOT NULL,
  `IntialPrice` decimal(20,2) NOT NULL,
  `NumberOfNights` decimal(2,0) NOT NULL,
  `Discount` decimal(3,0) DEFAULT NULL,
  `TotalPrice` decimal(20,2) NOT NULL,
  `AccommodationID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Daten für Tabelle `prices`
--

INSERT INTO `prices` (`PriceID`, `IntialPrice`, `NumberOfNights`, `Discount`, `TotalPrice`, `AccommodationID`) VALUES
(1, '60.00', '1', '0', '60.00', 1),
(2, '250.00', '1', '0', '250.00', 2),
(3, '500.00', '5', '0', '100.00', 3),
(4, '228.00', '2', '0', '114.00', 4),
(5, '100.00', '1', '10', '90.00', 5),
(6, '566.00', '4', '0', '141.50', 6),
(7, '750.00', '5', '0', '150.00', 7),
(8, '183.00', '2', '0', '91.50', 8),
(9, '105.00', '2', '0', '52.50', 9),
(10, '625.00', '4', '0', '156.25', 10),
(11, '170.00', '2', '0', '85.00', 11),
(12, '88.00', '1', '0', '88.00', 12),
(13, '500.00', '2', '0', '250.00', 13),
(14, '216.00', '1', '0', '216.00', 14),
(15, '175.00', '2', '0', '87.50', 15),
(16, '96.00', '2', '0', '48.00', 16),
(17, '254.00', '3', '10', '76.20', 17),
(18, '79.00', '1', '0', '79.00', 18),
(19, '440.00', '2', '0', '220.00', 19),
(20, '5000.00', '1', '0', '5000.00', 20);

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `reservations`
--

CREATE TABLE `reservations` (
  `ReservationID` int(11) NOT NULL,
  `CheckInDate` date NOT NULL,
  `CheckOutDate` date NOT NULL,
  `GuestNumber` decimal(2,0) NOT NULL,
  `AccommodationID` int(11) NOT NULL,
  `GuestID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Daten für Tabelle `reservations`
--

INSERT INTO `reservations` (`ReservationID`, `CheckInDate`, `CheckOutDate`, `GuestNumber`, `AccommodationID`, `GuestID`) VALUES
(1, '2021-12-01', '2021-12-02', '1', 1, 1),
(2, '2021-11-03', '2021-11-07', '2', 2, 2),
(3, '2021-11-04', '2021-11-09', '1', 3, 3),
(4, '2021-11-04', '2021-11-08', '3', 4, 4),
(5, '2021-11-06', '2021-11-07', '2', 5, 5),
(6, '2021-11-05', '2021-11-09', '4', 6, 6),
(7, '2021-11-05', '2021-11-10', '1', 7, 7),
(8, '2021-11-08', '2021-11-13', '2', 8, 8),
(9, '2021-11-08', '2021-11-10', '2', 9, 9),
(10, '2021-11-05', '2021-11-09', '2', 10, 10),
(11, '2021-11-10', '2021-11-12', '2', 11, 11),
(12, '2021-11-05', '2021-11-06', '2', 12, 12),
(13, '2021-11-06', '2021-11-08', '2', 13, 13),
(14, '2021-11-06', '2021-11-07', '2', 14, 14),
(15, '2021-11-06', '2021-11-08', '1', 15, 15),
(16, '2021-11-05', '2021-11-07', '2', 16, 16),
(17, '2021-11-06', '2021-11-09', '2', 17, 17),
(18, '2021-11-06', '2021-11-07', '1', 18, 18),
(19, '2021-11-06', '2021-11-08', '2', 19, 19),
(20, '2021-11-06', '2021-11-08', '2', 20, 20);

--
-- Indizes der exportierten Tabellen
--

--
-- Indizes für die Tabelle `accommodationreviews`
--
ALTER TABLE `accommodationreviews`
  ADD PRIMARY KEY (`AccommodationReviewID`),
  ADD KEY `GuestID` (`GuestID`),
  ADD KEY `AccommodationID` (`AccommodationID`);

--
-- Indizes für die Tabelle `accommodations`
--
ALTER TABLE `accommodations`
  ADD PRIMARY KEY (`AccommodationID`),
  ADD UNIQUE KEY `AccommodationName` (`AccommodationName`),
  ADD KEY `HostID` (`HostID`);

--
-- Indizes für die Tabelle `bathrooms`
--
ALTER TABLE `bathrooms`
  ADD PRIMARY KEY (`BathroomID`),
  ADD KEY `InteriorID` (`InteriorID`);

--
-- Indizes für die Tabelle `bedrooms`
--
ALTER TABLE `bedrooms`
  ADD PRIMARY KEY (`BedroomID`),
  ADD KEY `InteriorID` (`InteriorID`);

--
-- Indizes für die Tabelle `currencies`
--
ALTER TABLE `currencies`
  ADD PRIMARY KEY (`CurrencyCode`);

--
-- Indizes für die Tabelle `exteriors`
--
ALTER TABLE `exteriors`
  ADD PRIMARY KEY (`ExteriorID`),
  ADD UNIQUE KEY `AccommodationID` (`AccommodationID`);

--
-- Indizes für die Tabelle `guestadresses`
--
ALTER TABLE `guestadresses`
  ADD PRIMARY KEY (`GuestAdressesID`),
  ADD UNIQUE KEY `GuestID` (`GuestID`);

--
-- Indizes für die Tabelle `guestcontacts`
--
ALTER TABLE `guestcontacts`
  ADD PRIMARY KEY (`GuestEmailAdress`,`GuestPhoneNumber`),
  ADD UNIQUE KEY `GuestID` (`GuestID`);

--
-- Indizes für die Tabelle `guestreviews`
--
ALTER TABLE `guestreviews`
  ADD PRIMARY KEY (`GuestReviewID`),
  ADD KEY `HostID` (`HostID`),
  ADD KEY `GuestID` (`GuestID`);

--
-- Indizes für die Tabelle `guests`
--
ALTER TABLE `guests`
  ADD PRIMARY KEY (`GuestID`),
  ADD KEY `CurrencyCode` (`CurrencyCode`);

--
-- Indizes für die Tabelle `host`
--
ALTER TABLE `host`
  ADD PRIMARY KEY (`HostID`),
  ADD KEY `CurrencyCode` (`CurrencyCode`);

--
-- Indizes für die Tabelle `hostadresses`
--
ALTER TABLE `hostadresses`
  ADD PRIMARY KEY (`HostAdressesID`),
  ADD UNIQUE KEY `HostID` (`HostID`);

--
-- Indizes für die Tabelle `hostcontacts`
--
ALTER TABLE `hostcontacts`
  ADD PRIMARY KEY (`HostEmailAdress`,`HostPhoneNumber`),
  ADD UNIQUE KEY `HostID` (`HostID`);

--
-- Indizes für die Tabelle `hostreviews`
--
ALTER TABLE `hostreviews`
  ADD PRIMARY KEY (`HostReviewID`),
  ADD KEY `HostID` (`HostID`),
  ADD KEY `GuestID` (`GuestID`);

--
-- Indizes für die Tabelle `income`
--
ALTER TABLE `income`
  ADD PRIMARY KEY (`IncomeID`),
  ADD UNIQUE KEY `PayConfirmationID` (`PayConfirmationID`),
  ADD KEY `AccommodationID` (`AccommodationID`);

--
-- Indizes für die Tabelle `interiors`
--
ALTER TABLE `interiors`
  ADD PRIMARY KEY (`InteriorID`),
  ADD UNIQUE KEY `AccommodationID` (`AccommodationID`);

--
-- Indizes für die Tabelle `kitchens`
--
ALTER TABLE `kitchens`
  ADD PRIMARY KEY (`KitchenID`),
  ADD KEY `InteriorID` (`InteriorID`);

--
-- Indizes für die Tabelle `livingrooms`
--
ALTER TABLE `livingrooms`
  ADD PRIMARY KEY (`LivingRoomID`),
  ADD KEY `InteriorID` (`InteriorID`);

--
-- Indizes für die Tabelle `locations`
--
ALTER TABLE `locations`
  ADD PRIMARY KEY (`LocationID`),
  ADD UNIQUE KEY `AccommodationID` (`AccommodationID`);

--
-- Indizes für die Tabelle `otherrooms`
--
ALTER TABLE `otherrooms`
  ADD PRIMARY KEY (`OtherRoomID`),
  ADD KEY `InteriorID` (`InteriorID`);

--
-- Indizes für die Tabelle `payconfirmations`
--
ALTER TABLE `payconfirmations`
  ADD PRIMARY KEY (`PayConfirmationID`),
  ADD UNIQUE KEY `PaymentID` (`PaymentID`);

--
-- Indizes für die Tabelle `paymentmethods`
--
ALTER TABLE `paymentmethods`
  ADD PRIMARY KEY (`PaymentMethod`),
  ADD UNIQUE KEY `PaymentMethod` (`PaymentMethod`);

--
-- Indizes für die Tabelle `payments`
--
ALTER TABLE `payments`
  ADD PRIMARY KEY (`PaymentID`),
  ADD UNIQUE KEY `PriceID` (`PriceID`),
  ADD KEY `PaymentMethod` (`PaymentMethod`),
  ADD KEY `GuestID` (`GuestID`);

--
-- Indizes für die Tabelle `prices`
--
ALTER TABLE `prices`
  ADD PRIMARY KEY (`PriceID`),
  ADD UNIQUE KEY `AccommodationID` (`AccommodationID`);

--
-- Indizes für die Tabelle `reservations`
--
ALTER TABLE `reservations`
  ADD PRIMARY KEY (`ReservationID`),
  ADD KEY `AccommodationID` (`AccommodationID`),
  ADD KEY `GuestID` (`GuestID`);

--
-- AUTO_INCREMENT für exportierte Tabellen
--

--
-- AUTO_INCREMENT für Tabelle `accommodationreviews`
--
ALTER TABLE `accommodationreviews`
  MODIFY `AccommodationReviewID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT für Tabelle `accommodations`
--
ALTER TABLE `accommodations`
  MODIFY `AccommodationID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT für Tabelle `bathrooms`
--
ALTER TABLE `bathrooms`
  MODIFY `BathroomID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT für Tabelle `bedrooms`
--
ALTER TABLE `bedrooms`
  MODIFY `BedroomID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT für Tabelle `exteriors`
--
ALTER TABLE `exteriors`
  MODIFY `ExteriorID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT für Tabelle `guestadresses`
--
ALTER TABLE `guestadresses`
  MODIFY `GuestAdressesID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=24;

--
-- AUTO_INCREMENT für Tabelle `guestreviews`
--
ALTER TABLE `guestreviews`
  MODIFY `GuestReviewID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT für Tabelle `guests`
--
ALTER TABLE `guests`
  MODIFY `GuestID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=24;

--
-- AUTO_INCREMENT für Tabelle `host`
--
ALTER TABLE `host`
  MODIFY `HostID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT für Tabelle `hostadresses`
--
ALTER TABLE `hostadresses`
  MODIFY `HostAdressesID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT für Tabelle `hostreviews`
--
ALTER TABLE `hostreviews`
  MODIFY `HostReviewID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT für Tabelle `income`
--
ALTER TABLE `income`
  MODIFY `IncomeID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT für Tabelle `interiors`
--
ALTER TABLE `interiors`
  MODIFY `InteriorID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT für Tabelle `kitchens`
--
ALTER TABLE `kitchens`
  MODIFY `KitchenID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT für Tabelle `livingrooms`
--
ALTER TABLE `livingrooms`
  MODIFY `LivingRoomID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT für Tabelle `locations`
--
ALTER TABLE `locations`
  MODIFY `LocationID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT für Tabelle `otherrooms`
--
ALTER TABLE `otherrooms`
  MODIFY `OtherRoomID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT für Tabelle `payconfirmations`
--
ALTER TABLE `payconfirmations`
  MODIFY `PayConfirmationID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT für Tabelle `payments`
--
ALTER TABLE `payments`
  MODIFY `PaymentID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=143;

--
-- AUTO_INCREMENT für Tabelle `prices`
--
ALTER TABLE `prices`
  MODIFY `PriceID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT für Tabelle `reservations`
--
ALTER TABLE `reservations`
  MODIFY `ReservationID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- Constraints der exportierten Tabellen
--

--
-- Constraints der Tabelle `accommodationreviews`
--
ALTER TABLE `accommodationreviews`
  ADD CONSTRAINT `accommodationreviews_ibfk_1` FOREIGN KEY (`GuestID`) REFERENCES `guests` (`GuestID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `accommodationreviews_ibfk_2` FOREIGN KEY (`AccommodationID`) REFERENCES `accommodations` (`AccommodationID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints der Tabelle `accommodations`
--
ALTER TABLE `accommodations`
  ADD CONSTRAINT `accommodations_ibfk_1` FOREIGN KEY (`HostID`) REFERENCES `host` (`HostID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints der Tabelle `bathrooms`
--
ALTER TABLE `bathrooms`
  ADD CONSTRAINT `bathrooms_ibfk_1` FOREIGN KEY (`InteriorID`) REFERENCES `interiors` (`InteriorID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints der Tabelle `bedrooms`
--
ALTER TABLE `bedrooms`
  ADD CONSTRAINT `bedrooms_ibfk_1` FOREIGN KEY (`InteriorID`) REFERENCES `interiors` (`InteriorID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints der Tabelle `exteriors`
--
ALTER TABLE `exteriors`
  ADD CONSTRAINT `exteriors_ibfk_1` FOREIGN KEY (`AccommodationID`) REFERENCES `accommodations` (`AccommodationID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints der Tabelle `guestadresses`
--
ALTER TABLE `guestadresses`
  ADD CONSTRAINT `guestadresses_ibfk_1` FOREIGN KEY (`GuestID`) REFERENCES `guests` (`GuestID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints der Tabelle `guestcontacts`
--
ALTER TABLE `guestcontacts`
  ADD CONSTRAINT `guestcontacts_ibfk_1` FOREIGN KEY (`GuestID`) REFERENCES `guests` (`GuestID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints der Tabelle `guestreviews`
--
ALTER TABLE `guestreviews`
  ADD CONSTRAINT `guestreviews_ibfk_1` FOREIGN KEY (`HostID`) REFERENCES `host` (`HostID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `guestreviews_ibfk_2` FOREIGN KEY (`GuestID`) REFERENCES `guests` (`GuestID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints der Tabelle `guests`
--
ALTER TABLE `guests`
  ADD CONSTRAINT `guests_ibfk_1` FOREIGN KEY (`CurrencyCode`) REFERENCES `currencies` (`CurrencyCode`) ON UPDATE CASCADE;

--
-- Constraints der Tabelle `host`
--
ALTER TABLE `host`
  ADD CONSTRAINT `host_ibfk_1` FOREIGN KEY (`CurrencyCode`) REFERENCES `currencies` (`CurrencyCode`) ON UPDATE CASCADE;

--
-- Constraints der Tabelle `hostadresses`
--
ALTER TABLE `hostadresses`
  ADD CONSTRAINT `hostadresses_ibfk_1` FOREIGN KEY (`HostID`) REFERENCES `host` (`HostID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints der Tabelle `hostcontacts`
--
ALTER TABLE `hostcontacts`
  ADD CONSTRAINT `hostcontacts_ibfk_1` FOREIGN KEY (`HostID`) REFERENCES `host` (`HostID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints der Tabelle `hostreviews`
--
ALTER TABLE `hostreviews`
  ADD CONSTRAINT `hostreviews_ibfk_1` FOREIGN KEY (`HostID`) REFERENCES `host` (`HostID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `hostreviews_ibfk_2` FOREIGN KEY (`GuestID`) REFERENCES `guests` (`GuestID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints der Tabelle `income`
--
ALTER TABLE `income`
  ADD CONSTRAINT `income_ibfk_1` FOREIGN KEY (`AccommodationID`) REFERENCES `accommodations` (`AccommodationID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `income_ibfk_2` FOREIGN KEY (`PayConfirmationID`) REFERENCES `payconfirmations` (`PayConfirmationID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints der Tabelle `interiors`
--
ALTER TABLE `interiors`
  ADD CONSTRAINT `interiors_ibfk_1` FOREIGN KEY (`AccommodationID`) REFERENCES `accommodations` (`AccommodationID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints der Tabelle `kitchens`
--
ALTER TABLE `kitchens`
  ADD CONSTRAINT `kitchens_ibfk_1` FOREIGN KEY (`InteriorID`) REFERENCES `interiors` (`InteriorID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints der Tabelle `livingrooms`
--
ALTER TABLE `livingrooms`
  ADD CONSTRAINT `livingrooms_ibfk_1` FOREIGN KEY (`InteriorID`) REFERENCES `interiors` (`InteriorID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints der Tabelle `locations`
--
ALTER TABLE `locations`
  ADD CONSTRAINT `locations_ibfk_1` FOREIGN KEY (`AccommodationID`) REFERENCES `accommodations` (`AccommodationID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints der Tabelle `otherrooms`
--
ALTER TABLE `otherrooms`
  ADD CONSTRAINT `otherrooms_ibfk_1` FOREIGN KEY (`InteriorID`) REFERENCES `interiors` (`InteriorID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints der Tabelle `payconfirmations`
--
ALTER TABLE `payconfirmations`
  ADD CONSTRAINT `payconfirmations_ibfk_1` FOREIGN KEY (`PaymentID`) REFERENCES `payments` (`PaymentID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints der Tabelle `payments`
--
ALTER TABLE `payments`
  ADD CONSTRAINT `payments_ibfk_1` FOREIGN KEY (`PaymentMethod`) REFERENCES `paymentmethods` (`PaymentMethod`) ON UPDATE CASCADE,
  ADD CONSTRAINT `payments_ibfk_2` FOREIGN KEY (`GuestID`) REFERENCES `guests` (`GuestID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `payments_ibfk_3` FOREIGN KEY (`PriceID`) REFERENCES `prices` (`PriceID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints der Tabelle `prices`
--
ALTER TABLE `prices`
  ADD CONSTRAINT `prices_ibfk_1` FOREIGN KEY (`AccommodationID`) REFERENCES `accommodations` (`AccommodationID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints der Tabelle `reservations`
--
ALTER TABLE `reservations`
  ADD CONSTRAINT `reservations_ibfk_1` FOREIGN KEY (`AccommodationID`) REFERENCES `accommodations` (`AccommodationID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `reservations_ibfk_2` FOREIGN KEY (`GuestID`) REFERENCES `guests` (`GuestID`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
