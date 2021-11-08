DELIMITER //

CREATE PROCEDURE DeleteGuestProfile (
    IN guest_email_adress VARCHAR(100),
    IN guest_phone_number VARCHAR(100),
    OUT message VARCHAR(128)
)
BEGIN

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
END //