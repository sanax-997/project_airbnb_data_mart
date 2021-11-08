DELIMITER //

CREATE PROCEDURE GuestBooking (
    IN guest_email_adress VARCHAR(100),
    IN guest_phone_number VARCHAR(100),
    IN accommodation_name VARCHAR(100),
    IN payment_method VARCHAR(100),
    IN check_in_date DATE,
    IN check_out_date DATE,
    IN guest_number DECIMAL (2,0),
    OUT message VARCHAR(128)
)
BEGIN

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
END //