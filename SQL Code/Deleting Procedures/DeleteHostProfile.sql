DELIMITER //

CREATE PROCEDURE DeleteHostProfile (
    IN host_email_adress VARCHAR(100),
    IN host_phone_number VARCHAR(100),
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
END //