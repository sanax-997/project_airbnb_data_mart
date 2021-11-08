DELIMITER //

CREATE PROCEDURE DeleteAccommodation (
    IN host_email_adress VARCHAR(100),
    IN host_phone_number VARCHAR(100),
    IN accommodation_name VARCHAR(100),
    OUT message VARCHAR(128)
)
BEGIN

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
END //